function IPTools {
 
param([switch]$DCs, 
    [switch]$Domain, 
    [string]$BaseDN, 
    [string]$inputfile, 
    [string]$DNSServerFind,         
    [string]$DNSServerReplace) 
 
 
### Ping function to test connectivity 
Function DotNetPing 
{ 
    param($computername) 
    $Reachable = 'FALSE' 
    $Reply = $Null 
    $ReplyStatus= $Null 
    $ping = new-object System.Net.NetworkInformation.Ping 
    Trap {continue} 
    $Reply = $ping.send($computername) 
    $ReplyStatus = $Reply.status 
    If($ReplyStatus -eq 'Success') {$Reachable ='TRUE'} 
    else {$Reachable='FALSE'} 
    $Reachable  
}             
 
### DCDiscovery - All DCs in the Forest 
Function EnumerateDCs 
{ 
    $arrDCs =@() 
    $rootdse=new-object directoryservices.directoryentry('LDAP://rootdse') 
    $Configpath=$rootdse.configurationNamingContext 
    $adsientry=new-object directoryservices.directoryentry("LDAP://cn=Sites,$Configpath") 
    $adsisearcher=new-object directoryservices.directorysearcher($adsientry) 
    $adsisearcher.pagesize=1000 
    $adsisearcher.searchscope='subtree' 
    $strfilter='(ObjectClass=Server)' 
    $adsisearcher.filter=$strfilter 
    $colAttributeList = 'cn','dNSHostName','ServerReference','distinguishedname' 
 
    Foreach ($c in $colAttributeList) 
    { 
        [void]$adsiSearcher.PropertiesToLoad.Add($c) 
    } 
    $objServers=$adsisearcher.findall() 
 
    forEach ($objServer in $objServers) 
        { 
        $serverDN = $objServer.properties.item('distinguishedname') 
        $ntdsDN = "CN=NTDS Settings,$serverDN" 
        if ([adsi]::Exists("LDAP://$ntdsDN")) 
        { 
            $serverdNSHostname = $objServer.properties.item('dNSHostname') 
            $arrDCs += "$serverDNSHostname" 
        } 
        $serverdNSHostname=$Null 
    } 
     
    $arrDCs 
} 
 
### Function Return List of AD Computers From a BaseDN 
Function EnumerateComputers 
{ 
    Param ($baseDN) 
    $arrComputers =@() 
    $adsientry=new-object directoryservices.directoryentry("LDAP://$baseDN") 
    $adsisearcher=new-object directoryservices.directorysearcher($adsientry) 
    $adsisearcher.pagesize=1000 
    $adsisearcher.searchscope='subtree' 
    $strfilter='(objectclass=computer)'  
    $adsisearcher.filter=$strfilter 
    $colAttributeList = 'distinguishedname','dNSHostname','description','lastLogonTimeStamp' 
    Foreach ($c in $colAttributeList){[void]$adsiSearcher.PropertiesToLoad.Add($c)} 
    $objServers=$adsisearcher.findall() 
    forEach ($objServer in $objServers) 
    { 
        $serverDN = $objServer.properties.item('distinguishedname') 
        $serverdNSHostname = $objServer.properties.item('dNSHostname') 
        $arrComputers += "$serverDNSHostname" 
        $serverdNSHostname=$Null 
    } 
        $arrComputers 
} 
 
### Function Pull IP Info Using WMI 
Function GetIPInfo 
{ 
    Param ($computername,$DNSServerFind,$DNSServerReplace) 
    $colofRecords = @() 
    try 
    { 
        $objnicinfo=Get-WmiObject -Computername $computername -Class win32_networkadapterconfiguration -ea stop | Where-Object {$_.ipenabled} 
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
 
##### Evaluate Parameters ####### 
If ($DNSServerFind -AND $DNSServerReplace) {$PressAny = Read-Host "REPLACING ALL STATIC DNS SERVER ENTRIES OF $DNSServerFind WITH $DNSServerReplace.  PRESS ANY KEY TO CONTINUE, OR CTRL-C TO TERMINATE"} 
 
##### Get Scope of Computers against which to run 
$computerList = $null 
If ($DCs) {$computerList = EnumerateDCs} 
If ($Domain) 
{ 
    $rootdse=new-object directoryservices.directoryentry('LDAP://rootdse') 
    $rootpath=$rootdse.defaultnamingcontext 
    $computerList = EnumerateComputers $rootpath 
} 
If ($BaseDN) 
{ 
    if ([adsi]::Exists("LDAP://$BaseDN")) {$computerList = EnumerateComputers $BaseDN} 
    Else {$computerList = $null;Write-Host "CANNOT FIND CONTAINER $BaseDN" -foregroundColor Red}  
} 
If ($inputfile) 
{ 
    Try {$computerList = Get-Content $inputFile} 
    Catch {$computerList = $null;Write-Host "CANNOT FIND/READ FILE $inputfile" -foregroundColor Red} 
} 
     
$colofRecords = @() 
 
#### Walk through list of Computers, Pinging them first to be sure they are reachable 
If ($computerList) 
{ 
    Foreach ($computer in $ComputerList) 
    { 
        $Reachable = DotNetPing $computer 
        if ($reachable -eq 'FALSE') 
        { 
            $record = '' | Select-Object Hostname,IP,IP2,SubnetMask,Gateway,PrimDNS,SecDNS,TerDNS,PrimWINS,SecWins,NetBios,DHCP 
            $record.Hostname = $computer 
            $record.IP = "Can't Ping" 
            Write-Host "Can't Ping $computer" -foregroundcolor red 
            if (-NOT $DNSServerFind){$colofRecords += $record} 
        } 
        Else 
        { 
            $record = GetIPInfo $computer $DNSServerfind $DNSServerReplace 
            If ($record){$colofRecords += $record}             
        } 
    } 
} 
 
$colofRecords | Format-Table -auto 
$colofRecords | export-csv c:\temp\IPinfo.csv

}