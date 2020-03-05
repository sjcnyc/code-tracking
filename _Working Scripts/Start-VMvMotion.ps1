# CSV file headers
#
#vmname
#vm_1
#vm_2

$csvinput = "path to csv"
$maxsession = 2
$runsession = 2
targetds = "target_datastore"

import-csv $csvinput | ForEach-Object {

  Write-Output "Checking the running vMotion..."

  Do {

    $runsession = (get-task | Where-Object { $_.name -like "RelocateVM_Task" -and $_.State -eq "Running" }).count

    if ($runsession -ge $maxsession) {
      Write-Output "The current running vMotion sessions is $($runsession.No) new vMotion will be started.  Next check will be performed in 1 minute."
      Start-Sleep -s 60
      get-task | Where-Object { $_.State -eq "running" }
    }

    else {
      Write-Output "The current running vMotion sessions is $($runsession), a new storage vMotion will be started soon."
      Start-Sleep -s 5
    }

  } While ( $runsession -ge $maxsession)


  Write-Output ""
  Write-Output "The Storage vMotion for will start for below VM..."
  Write-Output $_.vmname
  Write-Output $_.targetds
  Get-VM $_.vmname | Move-VM -Datastore $_.targetds -RunAsync -Confirm:$false
  Write-Output ""
}