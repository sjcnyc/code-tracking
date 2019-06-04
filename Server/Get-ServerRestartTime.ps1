$servers    = 'ly2','ny1'

foreach ($serv in $servers) {

    $wmi=Get-WmiObject -class Win32_OperatingSystem -computer $serv 
    
    $rebootTime =$wmi.ConvertToDateTime($wmi.Lastbootuptime)
    
    $server     = (Get-WmiObject -class Win32_ComputerSystem -comp $serv)
    $ipaddress  = (Get-WmiObject Win32_NetworkAdapterConfiguration -comp $serv | 
        Where-Object {$_.IPEnabled -eq 'True'} | Select-Object @{N='IPAddress';E={$_.IPAddress}}) 
    
    $myarr = @()
    
    $myset             = ''| Select-Object Name, IPaddress, Model, RestartTime
    $myset.Name        = $server.name
    $myset.ipaddress   = $ipaddress.ipaddress
    $myset.Model       = $server.model
    $myset.RestartTime = $RebootTime
   
    $myarr += $myset
    $myarr
}


