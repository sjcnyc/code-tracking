Import-Module VMware.VimAutomation.Core

$CULvCenter = "usculpwvctr101.me.sonymusic.com"

#$global:cred = Get-Credential -Message "Enter Your T1 Adm Credentials"

#Connect-VIServer -Server $CULvCenter -Credential $global:cred

$CULvCenterVMs = Get-VM -Server $CULvCenter |
Where-Object { $_.Name -like "*jmp4*" -and $_.PowerState -eq "PoweredOn" }

$VMCount = 0

foreach ($VM in $CULvCenterVMs | Sort-Object) {
  if (++$VMCount % 5 -eq 1) {
    Start-Sleep -Seconds 2 #900
    #Write-Output "VM count is $($VMCount), pausing for 2 secounds"
  }
  Write-Output "Restarting VM: $($VM.Name)"
  Restart-VM $VM -RunAsync -Confirm: $false -WhatIf
}