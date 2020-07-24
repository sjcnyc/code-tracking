Import-Module -Name ActiveDirectory -Verbose:$false;
Import-Csv -Path 'C:\SomeUsers.csv' |
ForEach-Object -Process {
    $userDN = (Get-ADUser -Identity $_.SamAccountName).DistinguishedName
    $ou = 'OU=ADL,OU=zLegacy,DC=me,DC=sonymusic,DC=com' # change to your no-sync ou
    Move-ADObject -Identity $userDN -TargetPath $ou -WhatIf
    Write-Output -InputObject ('Moving User: {0} to: {1}' -f $_.SamAccountName, $ou)
  }

<#Import-Module -Name ActiveDirectory;
Import-Csv C:\temp\ME_parentcontainers.csv | ForEach-Object -Process { 
  $userDN = (Get-ADUser -Identity $_.SamAccountName).DistinguishedName 
  Move-ADObject -Identity $userDN -TargetPath $_.ParentContainer -WhatIf
  Write-Output -InputObject ('Moving User: {0} to: {1}' -f $_.SamAccountName, $_.parentContainer)}#>