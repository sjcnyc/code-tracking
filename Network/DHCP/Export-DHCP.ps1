$DHCP_EnumSubnets = @'          
    [DllImport("dhcpsapi.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern uint DhcpEnumSubnets(
        string ServerIpAddress,
        ref uint ResumeHandle,
        uint PreferredMaximum,
        out IntPtr EnumInfo,
        ref uint ElementsRead,
        ref uint ElementsTotal
    );
'@

$DHCP_EnumSubnetClients = @'          
   [DllImport("dhcpsapi.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern uint DhcpEnumSubnetClients(
       string ServerIpAddress,
       uint SubnetAddress,
       ref uint ResumeHandle,
       uint PreferredMaximum,
       out IntPtr ClientInfo,
       ref uint ElementsRead,
       ref uint ElementsTotal);
'@
 
$DHCP_Structs = @'
namespace mystruct {
    using System;
    using System.Runtime.InteropServices;

   public struct CUSTOM_CLIENT_INFO
   {
       public string ClientName;
       public string IpAddress;
       public string MacAddress;
   }
 
   [StructLayout(LayoutKind.Sequential)]
   public struct DHCP_CLIENT_INFO_ARRAY
   {
       public uint NumElements;
       public IntPtr Clients;
   }
 
   [StructLayout(LayoutKind.Sequential)]
   public struct DHCP_CLIENT_UID
   {
       public uint DataLength;
       public IntPtr Data;
   }
   
    [StructLayout(LayoutKind.Sequential)]
    public struct DHCP_IP_ARRAY
    {
        public uint NumElements;
        public IntPtr IPAddresses;
    } 
        
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
    public class DHCP_IP_ADDRESS
    {
        public UInt32 IPAddress;
    } 

   [StructLayout(LayoutKind.Sequential)]
   public struct DATE_TIME
   {
       public uint dwLowDateTime;
       public uint dwHighDateTime;
   
       public DateTime Convert()
       {
           if (dwHighDateTime== 0 && dwLowDateTime == 0)
           {
           return DateTime.MinValue;
           }
           if (dwHighDateTime == int.MaxValue && dwLowDateTime == UInt32.MaxValue)
           {
           return DateTime.MaxValue;
           }
           return DateTime.FromFileTime((((long) dwHighDateTime) << 32) | (UInt32) dwLowDateTime);
       }
   }
   
   [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
   public struct DHCP_HOST_INFO
   {
       public uint IpAddress;
       public string NetBiosName;
       public string HostName;
   }
 
   [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
   public struct DHCP_CLIENT_INFO
   {
       public uint ClientIpAddress;
       public uint SubnetMask;
       public DHCP_CLIENT_UID ClientHardwareAddress;
       [MarshalAs(UnmanagedType.LPWStr)]
       public string ClientName;
       [MarshalAs(UnmanagedType.LPWStr)]
       public string ClientComment;
       public DATE_TIME ClientLeaseExpires;
       public DHCP_HOST_INFO OwnerHost;
   }
}
'@

function uIntToIP {
    param ($intIP)
    $objIP = new-object system.net.ipaddress($intIP)
    $arrIP = $objIP.IPAddressToString.split('.')
    return $arrIP[3] + '.' + $arrIP[2] + '.' + $arrIP[1] + '.' + $arrIP[0]
}

$resumeHandle = 0
$clientInfo = 0
$subnetInfo = 0
$subnetElementsRead = 0
$subnetElementsTotal = 0
$clientElementsRead = 0
$clientElementsTotal = 0
 
Add-Type $DHCP_Structs
Add-Type  -MemberDefinition $DHCP_EnumSubnetClients -Name GetDHCPInfo -Namespace Win32DHCP
Add-Type  -MemberDefinition $DHCP_EnumSubnets -Name GetDHCPSubnets -Namespace Win32DHCP

# Add your DHCP servers to array below
$DHCPServers = @('192.168.1.45')
$array=@()
for ($k=0;$k -lt $DHCPServers.Count;$k++)
{

    $DHCPServerIP = $DHCPServers[$k]
    $resumeHandle = 0

    # Generate List of Subnets defined in DHCP Scopes    
    [void][Win32DHCP.GetDHCPSubnets]::DhcpEnumSubnets($DHCPServerIP,[ref]$resumeHandle,65536,[ref]$subnetInfo,[ref]$subnetElementsRead,[ref]$subnetElementsTotal)
    $subnets = [system.runtime.interopservices.marshal]::PtrToStructure($subnetInfo,[mystruct.DHCP_IP_ARRAY])

    [int]$subSize = $subnets.NumElements
    $outArray = $subnets.IPAddresses
    $sub_ptr_array = new-object mystruct.DHCP_IP_ADDRESS[]($subSize)
    [IntPtr]$subCurrent = $outArray
    for ($i = 0; $i -lt $subSize; $i++)
    {
        $sub_ptr_array[$i] = new-object -TypeName mystruct.DHCP_IP_ADDRESS
        [system.runtime.interopservices.marshal]::PtrToStructure($subCurrent, $sub_ptr_array[$i])
        $subCurrent = [IntPtr]([int]$subCurrent + [system.runtime.interopservices.marshal]::SizeOf([system.IntPtr]));
        #echo "$(uIntToIP($sub_ptr_array[$i].IPAddress))"
    }
    
    # Iterate through subnets to gather clients registered in each scope
    for ($j=0;$j -lt $subSize;$j++)
    {
        $resumeHandle = 0
        
        # Generate list of clients registered in subnet
        [void][Win32DHCP.GetDHCPInfo]::DhcpEnumSubnetClients($DHCPServerIP,$sub_ptr_array[$j].IPAddress,[ref]$resumeHandle,65536,[ref]$clientInfo,[ref]$clientElementsRead,[ref]$clientElementsTotal)
        $clients = [system.runtime.interopservices.marshal]::PtrToStructure($clientInfo,[mystruct.DHCP_CLIENT_INFO_ARRAY])
         
        [int]$size = $clients.NumElements
        [int]$current = $clients.Clients
        $ptr_array = new-object system.intptr[]($size)
        $current = new-object system.intptr($current)

        for ($i=0;$i -lt $size;$i++)
        {
            $ptr_array[$i] = [system.runtime.interopservices.marshal]::ReadIntPtr($current)
            $current = $current + [system.runtime.interopservices.marshal]::SizeOf([system.IntPtr])
        }

        [array]$clients_array = new-object mystruct.CUSTOM_CLIENT_INFO
        
        #Gather client info
        for ($i=0;$i -lt $size;$i++)
        {
            $objDHCPInfo = New-Object psobject
            $current_element = [system.runtime.interopservices.marshal]::PtrToStructure($ptr_array[$i],[mystruct.DHCP_CLIENT_INFO])
            add-member -inputobject $objDHCPInfo -memberType noteproperty -name ClientIP -value $(uIntToIP $current_element.ClientIpAddress)
            add-member -inputobject $objDHCPInfo -memberType noteproperty -name ClientName -value $current_element.ClientName
            add-member -inputobject $objDHCPInfo -memberType noteproperty -name OwnerIP -value $(uIntToIP $current_element.Ownerhost.IpAddress)
            add-member -inputobject $objDHCPInfo -memberType noteproperty -name OwnerName -value $current_element.Ownerhost.NetBiosName
            add-member -inputobject $objDHCPInfo -memberType noteproperty -name SubnetMask -value $(uIntToIP $current_element.SubnetMask)
            add-member -inputobject $objDHCPInfo -memberType noteproperty -name LeaseExpires -value $current_element.ClientLeaseExpires.Convert()
             
            $mac = [System.String]::Format(
                '{0:x2}-{1:x2}-{2:x2}-{3:x2}-{4:x2}-{5:x2}',
                [system.runtime.interopservices.marshal]::ReadByte($current_element.ClientHardwareAddress.Data),
                [system.runtime.interopservices.marshal]::ReadByte($current_element.ClientHardwareAddress.Data, 1),
                [system.runtime.interopservices.marshal]::ReadByte($current_element.ClientHardwareAddress.Data, 2),
                [system.runtime.interopservices.marshal]::ReadByte($current_element.ClientHardwareAddress.Data, 3),
                [system.runtime.interopservices.marshal]::ReadByte($current_element.ClientHardwareAddress.Data, 4),
                [system.runtime.interopservices.marshal]::ReadByte($current_element.ClientHardwareAddress.Data, 5)
            )
             
            add-member -inputobject $objDHCPInfo -memberType noteproperty -name MacAddress -value $mac
            
            # Output client data
            $array += $objDHCPInfo
            # Below line can be used to output data to CSV file when uncommented
            "$($objDHCPInfo.MacAddress),$($objDHCPInfo.ClientName),$($objDHCPInfo.ClientIP)" | out-file '\\uhlig.com\staff\Technology\1. Computer Network\1. Databases\TE_DHCP_leases.csv' -Encoding ASCII -Append
        }
    }
}