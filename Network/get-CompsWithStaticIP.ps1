function Get-CompsWithStaticIP 
 {
    param
    (
      [System.String]
      $LDAPFilter,

      [System.Management.Automation.SwitchParameter]
      $verbose
    )

  $comps = Get-QADComputer -SearchRoot 'bmg.bagint.com/usa/gbl/wst/xp' -SizeLimit 0 | ForEach-Object { $_ } | 
    Where-Object { $_.computername -like $LDAPFilter }  
  $comps | 
    ForEach-Object {  
     $name = $_.DNSHostName; 
     if ($Verbose.IsPresent) 
      { 
        Write-Host -ForegroundColor Yellow "Connecting to $name..." }  
       $ints = Get-WmiObject `
           -ErrorAction SilentlyContinue `
           -ComputerName $name `
           -Query 'select IPAddress, DefaultIPGateway from Win32_NetworkAdapterConfiguration where IPEnabled=TRUE and DHCPEnabled=FALSE'; 
    if ($ints -ne $null) 
        { 
            foreach ($int in $ints) 
            { 
                foreach ($addr in $int.IPAddress) 
                { 
                    $ip = $null 
                    if ($addr -match '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}') 
                    { 
                        $ip = $addr 
                        $gw = $null 
                        foreach ($gw_addr in $int.DefaultIPGateway) 
                        { 
                            if ($gw_addr -match '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}') 
                            { 
                                $gw = $gw_addr 
                                break 
                            } 
                        } 
                        if ($ip -ne $null) 
                        { 
                            $info = New-Object PSObject -Property `
                            @{ 
                                Name = $name 
                                IP = $ip 
                                Gateway = $gw 
                            } 
                            $info 
                            if ($Verbose.IsPresent) 
                                { Write-Host -ForegroundColor Yellow $info } 
                        } 
                    } 
                } 
            } 
        } 
    } | Select-Object Name, IP, Gateway
}


get-CompsWithStaticIP -LDAPFilter 'US-*'



 