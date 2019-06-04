#########
### Script to modify primary and secondary DNS on remote machine.
###
### http://poshdepo.codeplex.com/
#########

### Multiple machines;
#$servers = "server1","server2","server3"

### Single machine
$servers = "server1"

foreach($server in $servers)
{
    Write-Host "Connecting to $server..."
    $nics = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $server -ErrorAction Inquire | Where{$_.IPEnabled -eq "TRUE"}
    $newDNS = "10.10.10.101","10.10.10.102"
    foreach($nic in $nics)
    {
        Write-Host "`tExisting DNS Servers " $nic.DNSServerSearchOrder
        $x = $nic.SetDNSServerSearchOrder($newDNS)
        if($x.ReturnValue -eq 0)
        {
            Write-Host "`tSuccessfully Changed DNS Servers on " $server
        }
        else
        {
            Write-Host "`tFailed to Change DNS Servers on " $server
        }
    }
}
