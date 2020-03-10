function Start-vMotionSessions {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory, Position = 1)]
    [string]
    $VIServer,

    [Parameter(Mandatory, Position = 2)]
    [array]
    $VMs,

    [Parameter(Mandatory, Position = 3)]
    [string]
    $TargetDS,

    [Parameter(Position = 4)]
    [int]
    $MaxSession = 2,

    [Parameter(Position = 5)]
    [int]
    $RunSession = 0
  )

  $global:cred = Get-Credential -Message "Enter Your T1 Adm Credentials"
  
  Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false | Out-Null

  Connect-VIServer -Server $VIServer -Credential $Global:cred | Out-Null


  $Vms | ForEach-Object {

    Write-Host "Checking the running vMotion..."

    do {
      $RunSession = (Get-Task | Where-Object { $_.Name -like "RelocateVM_Task" -and $_.State -eq "Running" }).Count

      if ($RunSession -ge $MaxSession) {
        Write-Host "The current running vMotion sessions is $($RunSession) new vMotion will be started.  Next check will be performed in 2 minutes."
        Start-Sleep -Seconds 120
        Get-Task | Where-Object { $_.State -eq "running" }
      }
      else {
        Write-Host "The current running vMotion sessions is $($RunSession), a new storage vMotion will be started soon."
        Start-Sleep -Seconds 5
      }
    } while ($RunSession -ge $MaxSession)
    Write-Host ""
    Write-Host "The Storage vMotion for will start for below VM..."
    Write-Host $_
    Write-Host $TargetDS
    Get-VM $_ | Move-VM -Datastore $TargetDS -RunAsync -Confirm:$false
    Write-Host ""
  }
}

$Vms = @"
usculvwnmd011
usculvwpsh405
usculvwscm011
"@ -split [environment]::NewLine

Start-vMotionSessions -VIServer "usculpwvctr101.me.sonymusic.com" -TargetDS "IsilonNewDR42" -VMs $Vms
