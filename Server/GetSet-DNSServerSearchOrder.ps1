function Set-DNSServerSearchOrder {
  [cmdletbinding(SupportsShouldProcess=$True)]
  Param(
    [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    $ComputerName=$Env:ComputerName,
    [String[]]$DNSServers
  )
  
  $NICs = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $ComputerName -Filter 'IPEnabled=TRUE'
  
  foreach($NIC in $NICs) {$NIC.SetDNSServerSearchOrder($DNSServers) | out-null}
}

function Get-DNSServerSearchOrder {
  [cmdletbinding(SupportsShouldProcess=$True)] 
  Param(
    [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    $ComputerName=$Env:ComputerName
  )
  
  Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $ComputerName -Filter 'IPEnabled=TRUE' | 
  Select-Object PSComputerName,DNSServerSearchOrder,@{N='IPAddress';E={$_.IPAddress}} | Format-Table -auto
  
}

# add comps to hash below @""@

<#@"
ly2
"@ -split [environment]::NewLine |

ForEach-Object {
  #Get-DNSServerSearchOrder -ComputerName ny1 -WhatIf
  # Set-DNSServerSearchOrder -DNSServers '10.12.1.40' , '10.12.1.38' 
    } #>

    Get-DNSServerSearchOrder -ComputerName ny1 -WhatIf