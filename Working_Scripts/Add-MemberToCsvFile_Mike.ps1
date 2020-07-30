$CSVFile = Import-Csv C:\<yourcsvfile>.csv

$Output = # Array of psobjects
foreach ($Item in $CSVFile) {
  # this will get the DisplayName for all valid sAMAccountName 's in your csv file
  $User = (Get-ADUser -Filter "sAMAccountName -eq '$($Item.User_Name0)'" -Properties DisplayName).DisplayName
  # this will construct and object
  [pscustomobject]@{
    "name0"          = $Item.name0
    "User_Name0"     = $Item.User_Name0
    "Value"          = $Item.Value
    "Installed Date" = $Item.'Installed Date'
    "Client Version" = $Item.'Client Version'
    "LastHWScan"     = $Item.LastHWScan
    "Policy Request" = $Item.'Policy Request'
    "Status"         = $Item.Status
    "Country"        = $Item.Country
    "Notes"          = $Item.Notes
    "UserName"       = $User # this adds DisplayName to you object
  }
}
# $Output will contain the new object created by pscustomobject with DisplayName added
$Output | Export-Csv D:\Temp\Windows_os_upgrades_username.csv

# Future use
# Replace the $item. value in pscustomobject with headers from
# your csv file.  values will need to be quotes if there are spaces in header names <- boo
# E.g $Item.'Policy Request'.