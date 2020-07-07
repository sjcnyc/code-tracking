get-aduser -filter * -properties samaccountname, displayname, passwordlastset, passwordneverexpires, distinguishedname -SearchBase "OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com" |
Select-Object samaccountname, displayname, passwordlastset, passwordneverexpires, distinguishedname |
export-csv d:\temp\user_pass_full_usa.csv


$searchdate = "2020-03-01"
$searchbase = "OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"

$passwordsNotChangedSince = $([datetime]::parseexact($searchdate,'yyyy-MM-dd',$null)).ToFileTime()

Get-ADUser -filter { Enabled -eq $True } –Properties pwdLastSet, passwordneverexpires, passwordlastset -searchbase $searchbase |
    Where-Object { $_.pwdLastSet -lt $passwordsNotChangedSince -and $_.pwdLastSet -ne 0 } |
    Select-Object name,sAmAccountName, passwordneverexpires, distinguishedname, @{Name="PasswordLastSet1";Expression={[datetime]::FromFileTimeUTC($_.pwdLastSet)}}, passwordlastset |
    Export-Csv d:\temp\user_pass_90_usa22.csv