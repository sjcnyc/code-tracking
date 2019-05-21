
Function Get-Uptime {
	[cmdletbinding()]
	param (
	[parameter(mandatory=$true,position=0)]$comp
	)
	begin {}
	process {
		
		ForEach-Object { 		
			
			$System  = (Get-WmiObject  Win32_OperatingSystem -comp $comp) 
			
			$IPaddress = (Get-WmiObject Win32_NetworkAdapterConfiguration -comp $comp | 
			Where-Object { $_.IPEnabled -eq $True -and $_.DHCPEnabled -eq $False}) 
			
			foreach ($ip in $IPaddress )
			{  
				if(Test-Connection -comp $comp -Count 1 -ea 0) {          
					
					$Bootup = $System.LastBootUpTime
					$LastBootUpTime = $System.ConvertToDateTime($System.LastBootUpTime)
					$IsDHCPEnabled = $false
					if ($ip.DHCPEnabled) {
						$IsDHCPEnabled = $true
					}
					[pscustomobject]@{
						ComputerName = $comp.ToUpper()
						IPaddress = $ip.ipaddress[0]
						SubnetMask = $ip.ipsubnet[0]
						DNSServers = (($ip.DNSServerSearchOrder) | Out-String).Trim()
						DefaultGateway = $ip.DefaultIPGateway[0]
						LastBootUpTime = $LastBootUpTime
						DHCP = $IsDHCPEnabled
					}			
					
					#New-Object psobject -Property $NewObjProps
				}
			}
		}
	}
	end {}
}

Get-Uptime -comp ny1


