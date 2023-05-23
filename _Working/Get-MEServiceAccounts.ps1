$getADUserSplat = @{
    SearchBase = "OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
    Properties = 'DisplayName', 'SamAccountName', 'DistinguishedName', 'Enabled', 'CanonicalName', ''
    Server     = 'me.sonymusic.com'
    Filter     = { DistinguishedName -like "OU=Service*" }
  }
  Get-ADUser @getADUserSplat | Select-Object $getADUserSplat.Properties | Export-Csv C:\Temp\enabled_users_me2.csv -NoTypeInformation

  # t1/t2/t0 service accounts



$Date = (get-date -f yyyyMMdd)
$ServiceOus = (Get-ADOrganizationalUnit -filter 'Name -eq "Service"').DistinguishedName

$Results =
foreach ($OU in $ServiceOus) {

  $ADUserSplat = @{
    SearchBase = $OU
    Properties = 'DisplayName', 'SamAccountName', 'DistinguishedName', 'CanonicalName', 'Enabled', 'Description'
  }

  Get-ADUser @ADUserSplat -Filter * | select-object $ADUserSplat.Properties
}

$Results | Export-Csv C:\Temp\ME_Service_Accounts_$($Date).csv -NoTypeInformation