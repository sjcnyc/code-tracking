$Users = @"
username
"@ -split [environment]::NewLine

foreach ($user in $users) {

  Get-QADUser $user -IncludedProperties samaccountname | Select-Object samaccountname, @{N='UPN'; E={$user}} | Export-Csv d:\temp\linkedinUsers1.csv -NoTypeInformation -Append
  
}