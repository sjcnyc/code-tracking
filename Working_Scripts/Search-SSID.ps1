[CmdletBinding()]
param (

  [Parameter(Mandatory)]
  [string[]]
  $ComputerName,

  [Parameter()]
  [string]
  $SSID,

  [Parameter()]
  [switch]
  $IncludeNonResponding
)

# Scriptblock for Invoke-Command
$InvokeCommandScriptBlock = {

  $VerbosePreference = $Using:VerbosePreference

  Write-Verbose "Querying $env:COMPUTERNAME for SSID $Using:SSID."

  $Result = [PSCustomObject]@{

    ComputerName = $env:COMPUTERNAME
    SSID         = $Using:SSID
    Found        = $false
  }

  $SSIDs = netsh wlan show profiles | 
  Select-String -Pattern 'All User Profile' | 
  Foreach-Object { $_.ToString().Split(':')[-1].Trim() }

  if ($SSIDs -contains $Using:SSID) {

    $Result.Found = $true
  }

  $Result
}

# Parameters for Invoke-Command
$InvokeCommandParams = @{

  ComputerName = $ComputerName
  ScriptBlock  = $InvokeCommandScriptBlock
  ErrorAction  = $ErrorActionPreference
}

switch ($IncludeNonResponding.IsPresent) {

  'True' {

    $InvokeCommandParams.Add('ErrorVariable', 'NonResponding')

    Invoke-Command @InvokeCommandParams | 
    Select-Object -Property *, ErrorId -ExcludeProperty PSComputerName, PSShowComputerName, RunspaceId

    if ($NonResponding) {

      foreach ($Computer in $NonResponding) {

        [PSCustomObject]@{

          ComputerName = $Computer.TargetObject.ToUpper()
          SSID         = $null
          Found        = $null
          ErrorId      = $Computer.FullyQualifiedErrorId
        }
      }
    }
  }
  'False' {

    Invoke-Command @InvokeCommandParams | 
    Select-Object -Property * -ExcludeProperty PSComputerName, PSShowComputerName, RunspaceId
  }
}