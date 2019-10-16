$users =
@"
AART001
"@ -split [environment]::NewLine

foreach ($user in $users) {
  $SamExists = (Get-ADUser -Identity $user -ErrorAction 0).SamAccountName

        if ($SamExists -eq $user -and $null -ne $SamExists) {

          Set-ADUser -Identity $user -Replace @{ telephoneNumber = "+442073618639" } -WhatIf
        }
}