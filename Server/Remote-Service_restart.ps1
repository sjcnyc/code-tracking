# 1 
Restart-Service -InputObject $(Get-Service -Computer 10.12.112.191 -Name spooler) -PassThru

# 2
$sb= { Param([array]$computername=$env:computername) `
     Get-WmiObject -computer $computername Win32_Service -Filter "Name='spooler'" | Restart-Service -PassThru }

& $sb 10.12.112.191 


#either should work