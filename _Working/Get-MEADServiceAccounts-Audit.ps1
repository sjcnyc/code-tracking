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