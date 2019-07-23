Import-Module ActiveDirectory

# csv header should be SamAccountName
# E.g.
#
# SamAccountName
# sconnea
# klee123

$Users = (Import-Csv c:\NameOfFileWithUsers.csv).SamAccountName

foreach ($user in $Users) {
  # Remove -whatif for production run, leave for testing
  Set-ADUser -Identity $user -Enabled $false -WhatIf
}