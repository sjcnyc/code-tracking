    $qadParams = @{
      Properties          = @("givenName", "SurName")
      SearchBase          = "OU=Arcade,OU=USR,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com"
      Filter = '*'
    }
    #$userInfo = Get-QADUser @qadParams
    $userInfo = Get-ADUser @qadParams | Select-Object $qadParams.Properties
    $userInfo



get-aduser -Properties surname, givenname -Filter * -SearchBase "OU=Arcade,OU=USR,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com", "OU=CMR,OU=USR,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com" | Select-Object *


$attribs =
@"
userAccountControl
SamAccountName
GivenName
sn
UserPrincipalName
Description
DisplayName
pwdLastSet
LastLogonTimeStamp
telephoneNumber
physicalDeliveryOfficeName
postOfficeBox
postalCode
postalAddress
businessCategory
title
ou
o
street
st
l
c
serialNumber
"@ -split [environment]::NewLine

$users =
(C:\temp\AdFind.exe -b 'OU=USR,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com' -f '(&(objectclass=user)(objectcategory=person))' $($attribs) -tdc -tdcfmt %MM%/%DD%/%YYYY% -nodn -csv)

$users | ConvertFrom-Csv | Out-GridView



$attribs = (C:\temp\adfind\AdFind.exe -schema -f "objectClass=attributeSchema" cn lDAPDisplayName DisplayName -nodn -csv )

$attribs | ConvertFrom-Csv | Out-GridView


(C:\temp\adfind\AdFind.exe -b "CN=Adhami\, Debbie,OU=Employees,OU=USR,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com" allowedAttributesEffective -nodn)


$count = [int](((C:\temp\adfind\AdFind.exe -c -b "OU=USR,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com" -f '(&(objectclass=user)(objectcategory=person))' 2>&1)[-1]).split(" "))[0]

$users = (C:\temp\AdFind.exe -b 'OU=USR,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com' -f '(&(objectclass=user)(objectcategory=person))' $($attribs) -tdc -tdcfmt %MM%/%DD%/%YYYY% -nodn -csv)

$ProgressBar = New-ProgressBar -IsIndeterminate $false -Type Horizontal -Theme Light -IconPath .\Images\44_user_group_3x_ZEa_icon.ico
1..$count | ForEach-Object {
  Write-ProgressBar -ProgressBar $ProgressBar -Activity "Counting $_ out of $($count)" -PercentComplete $_ -Status "Scanning User Objects" -CurrentOperation "some operation"
}

Close-ProgressBar $ProgressBar

$ProgressBar = New-ProgressBar -Type Horizontal -Size large -theme light -IsIndeterminate $True
New-ProgressBar -Type Horizontal -Size Large

c:\temp\adfind.exe -b "CN=Albert\, Caryn,OU=Employees,OU=USR,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com" allowedAttributes | out-file c:\temp\ad_attributes.txt
