#Requires -Version 3.0 
<# 
    .SYNOPSIS 


    .DESCRIPTION 

 
    .NOTES 
        File Name  : Get-IPInfo
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 4/3/2014

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE

    .EXAMPLE

#>

### Function Pull IP Info Using WMI 
Function Get-IPInfo
{ 
    Param ($computername,$DNSServerFind,$DNSServerReplace) 
    $colofRecords = @() 
    try 
    { 
        $objnicinfo=Get-WmiObject -Computername $computername -Class win32_networkadapterconfiguration -ea stop | 
        Where-Object {$_.ipenabled} 
    } 
    catch 
    { 
        $IP='WMI Error collecting Data' 
        $record = '' | Select-Object Hostname,IP,IP2,SubnetMask,GateWay,PrimDNS,SecDNS,TerDNS,PrimWINS,SecWins,NetBios,DHCP 
        $record.Hostname = $computername 
        $record.IP = $IP 
    } 
 
    If($IP -eq 'WMI Error collecting Data') {write-host "Can't WMI connect to $computername" -foregroundcolor red} 
    Else 
    { 
        Write-host "Connecting to $computername" -foregroundcolor green 
        Foreach ($nic in $objnicinfo) 
        {               
            $DHCP = $Nic.DHCPEnabled 
            $PrimDNS = $Null 
            $SecDNS = $Null 
            $TerDNS = $Null 
            $DNSMatch = 'FALSE' 
            If ($NIC.DNSServerSearchOrder) 
            { 
                If (-NOT $DHCP -AND $DNSServerFind -AND $DNSServerReplace) 
                { 
                    $DNSServerSearchORder = $Nic.DNSServerSearchOrder 
                    $NewSearchOrder = $DNSServerSearchOrder 
                    ForEach ($DNSServer in $DNSServerSearchOrder) 
                    { 
                        If ($DNSServer -eq $DNSServerFind) 
                        { 
                            Write-Host "Found $DNSServerFind...Replacing with $DNSServerReplace" 
                            $NewSearchOrder = $DNSServerSearchORder | ForEach {$_ -Replace $DNSServerFind,$DNSServerReplace} 
                            $Nic.SetDNSServerSearchOrder($NewSearchOrder) > $junk 
                            $DNSMatch='TRUE' 
                        } 
                    } 
                    $PrimDNS = $NewSearchOrder[0] 
                    $SecDNS = $NewSearchOrder[1] 
                    $TerDNS = $NewSearchOrder[3] 
                     
                } 
                Else 
                { 
                    $PrimDNS=$NIC.DNSserversearchorder[0] 
                    $SecDNS=$NIC.DNSserversearchorder[1] 
                    $TerDNS=$NIC.DNSserversearchorder[2] 
                    If ($DNSServerFind -eq $PrimDNS -OR $DNSServerFind -eq $SecDNS -OR $DNSServerfind -eq $TerDNS){$DNSMatch='TRUE'}              
                } 
            } 
            If (-Not $DNSServerfind -OR $DNSMatch -eq 'TRUE') 
            { 
                $record = '' | Select-Object Hostname,IP,IP2,SubnetMask,Gateway,PrimDNS,SecDNS,TerDNS,PrimWINS,SecWins,NetBios,DHCP 
                $record.Hostname = $computername 
                $IP=$NIC.IPaddress[0] 
                $IP2=$NIC.IPaddress[1] 
            $SubnetMask = $NIC.IPSubnet[0] 
            $Gateway = $NIC.DefaultIPGateway[0] 
                $PrimWINS=$NIC.WINSPrimaryServer 
                $SecWINS=$NIC.WINSSecondaryServer 
                If ($NIC.tcpipnetbiosoptions -eq 0){$netBIOS='Default'} 
                If ($NIC.tcpipnetbiosoptions -eq 1){$netBIOS='Enabled'} 
                If ($NIC.tcpipnetbiosoptions -eq 2){$netBIOS='Disabled'} 
                $record.IP = $IP 
                $record.IP2 = $IP2 
            $record.SubnetMask = $SubnetMask 
            $record.Gateway = $Gateway 
                $record.PrimDNS = $PrimDNS 
                $record.SecDNS = $SecDNS 
                $record.TerDNS = $TerDNS 
                $record.PrimWINs = $PrimWINS 
                $record.SecWINS = $SecWins 
                $record.NetBIOS = $NetBIOS 
                $record.DHCP = $DHCP 
                $colofRecords+= $record 
            } 
        } 
    } 
    $colOfRecords 
} 