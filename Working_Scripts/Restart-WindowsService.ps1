
<#PSScriptInfo

.VERSION 1.0.0

.GUID 5c3750ee-7328-41a1-9ec5-6df23a9fae3a

.AUTHOR sconnea@sonymusic.com.com

.COMPANYNAME Sony Music

.COPYRIGHT 2020 Sony Music. All rights reserved.

.TAGS Windows WMI Remote Service Restart Tag2 Tag3

.LICENSEURI https://contoso.com/License

.PROJECTURI https://contoso.com/

.ICONURI https://contoso.com/Icon

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
  Restart Windows Service over Wmi on local and remote system 

.LINK


.EXAMPLE
 Restart-WindowsService -Name winr*,term* -ComputerName dc-01,dc-02

PSComputerName Action Name  DisplayName
-------------- ------ ----  -----------
dc-01          None   WinRM Windows Remote Management (WS-Management)
dc-02          None   WinRM Windows Remote Management (WS-Management)

#> 

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string[]]$Name,
  [Parameter(ValueFromPipelineByPropertyName = $true)][alias("DNSHostName")]$ComputerName = '.',
  [PSCredential]$Credential,
  [switch]$PassThru
)

BEGIN {
  $LocalHosts = @(
    '.',
    'localhost',
    $env:COMPUTERNAME,
    ($env:COMPUTERNAME, (Get-WmiObject -Class Win32_ComputerSystem).Domain -join '.')
  )

  [string]$Filter = 'Name like "' + ( @($Name | ForEach-Object { $_ -replace @('\*', '%') }) -join '" or Name like "' ) + '"'
  [string]$ErrorVariable = 'WmiRequestError'

}

PROCESS {
  Foreach ($Comp in $ComputerName) {
    $param = @{
      'ComputerName'  = $Comp
      'Class'         = 'Win32_Service'
      'Filter'        = $Filter
      'ErrorVariable' = $ErrorVariable
    }

    if ($Credential -and ($Comp -notin $LocalHosts)) {
      $param.Credential = $Credential
    }

    try {
      Get-WmiObject @param | ForEach-Object {
        [string]$Action = 'None'

        $InvokeStop = $_ | Invoke-WmiMethod -Name StopService -ErrorVariable $ErrorVariable
        if ($InvokeStop.ReturnValue -eq 0) {
          $Action = 'Stop'
        }
        Start-Sleep -s 1

        $InvokeStart = $_ | Invoke-WmiMethod -Name StartService -ErrorVariable $ErrorVariable
        if ($InvokeStart.ReturnValue -eq 0 -and $Action -eq 'None') {
          $Action = 'Start'
        }
        elseif ($InvokeStart.ReturnValue -eq 0 -and $Action -eq 'Stop') {
          $Action = 'Restart'
        }

        if ($PassThru) {
          if ($Action -eq 'Start' -or $Action -eq 'Restart') { $_ }
        }
        else {
          $_ | Select-Object -Property PSComputerName, @{'Name' = 'Action'; 'Expression' = { $Action } }, Name, DisplayName
        }
      }
    }
    catch {
      $WmiRequestError
      break
    }
  }
}

END {}
