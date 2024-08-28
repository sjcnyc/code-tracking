$Date      = (Get-Date -f yyyy-MM-dd)
$CSVFile   = "C:\Temp\All_Users_$($Date).csv"

$getADUserSplat = @{
    #SearchBase = "OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
    Properties = 'SamAccountName', 'Mail', 'Name', 'StreetAddress', 'City', 'Country', 'Company', 'Department', 'Title', 'Manager', 'EmployeeType', 'Enabled', 'canonicalName', 'extensionAttribute1', 'DisplayName', 'Division'
    Server     = 'me.sonymusic.com'
    Filter     =  { enabled -eq $true }
  }

$Results = Get-ADUser @getADUserSplat | Select-Object $getADUserSplat.Properties
$Results | Export-Csv -Path $CSVFile -NoTypeInformation



<#

SamAccountName
EmailAddress
Name
StreetAddress
City
Country
Company
Department
Title
Manager
EmployeeType
Division
extensionAttribute1
Display Name

#>