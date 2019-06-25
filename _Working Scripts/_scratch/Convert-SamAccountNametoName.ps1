function Convert-SamAccountnametoName {
  param (
    [string]$SamName
  )
  $UserName = (Get-ADUser -Identity $SamName -Properties Name).Name
  return $UserName
}

# single SamAccountname
Convert-SamAccountnametoName -SamName sconnea

# use csv file wiht SamAccountName header
#$users = (Import-Csv c:\users.csv).SamAccountname

$ hashtable of SamAccountnames
$users = @"
sconnea
klee123
"@ -split [environment]::NewLine


# loop SamAccountname, optionally export
foreach ($user in $users) {
  Convert-SamAccountnametoName -SamName $user # export-csv c:\usernames.csv -notype -append
}
