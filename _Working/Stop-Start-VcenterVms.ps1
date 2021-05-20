Import-Module VMware.VimAutomation.Core

Set-PowerCLIConfiguration -Scope User -ParticipateInCeip:$false
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

$CULvCenter = "usculpwvctr102.me.sonymusic.com"

#$AutomationPSCredentialName = "Vcenter_Cred"
#$Credential = Get-AutomationPSCredential -Name $AutomationPSCredentialName -ErrorAction Stop

Connect-VIServer -Server $CULvCenter #-Credential $Credential

$whereObjectSplat = @{
  FilterScript = {
    #$_.Name -ne "USCULVLBAS023" -and
    #$_.Name -ne "USCULVLISE199" -and
    #$_.Name -ne "USCULVWJMP408" -and
    #$_.Name -ne "USCULVWJMP409" -and
    #$_.Name -like "*JMP4*" -or
    #$_.Name -like "*JMP5*" -and
    $_.PowerState -eq "PoweredOff"
  }
}

$CULvCenterVMs = Get-VM -Server $CULvCenter | Where-Object @whereObjectSplat

$VMCount = 0

foreach ($VM in $CULvCenterVMs | Sort-Object) {
  if (++$VMCount % 20 -eq 1) {
    Start-Sleep -Seconds 600
    Write-Output "VM count is $($VMCount)"
  }
  Write-Output "Starting VM: $($VM.Name)"
  #Restart-VM $VM -RunAsync -Confirm: $false -WhatIf
  #Stop-VM $VM -RunAsync -Confirm:$false #-WhatIf
  #Shutdown-VMGuest -VM $VM -Confirm:$False
  Start-VM -VM $VM -RunAsync -Confirm:$false | Out-Null
}