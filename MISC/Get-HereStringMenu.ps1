
function Get-HashMenu {

  #define a prompt
  $p=@"

  1 - Get Running Services
  2 - Get Processes
  3 - Get Recent System Errors

Please select a task
"@
  $r=read-host $p

  Switch ($r) {

    1 {Get-service | Where-Object {$_.status -eq 'Running'} | Format-Table -auto }
    2 {Get-process | Format-Table -auto}
    3 {Get-eventlog system -EntryType Error -Newest 5 | Format-Table -auto}
    Default {Write-Host "Invalid choice: $r" -fore Yellow}

  }

  Get-HashMenu

}

Get-HashMenu