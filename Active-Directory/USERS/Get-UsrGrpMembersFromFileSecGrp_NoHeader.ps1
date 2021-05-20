$filter = '^.*Administrators$|^.*All Share Access$'
$p ="\\storage\ifs$\infra\data\Production_Shares\data\finance\"

$p | 

Get-Acl |
ForEach-Object {
	$_.Access } | Select-Object IdentityReference |
Where-Object { 
	$_.IdentityReference -like 'BMG\*' -and $_.IdentityReference -notmatch $filter } |
ForEach-Object {
	Write-Host 'Group: ' $_.IdentityReference.value.replace('BMG\','') 
    Get-QADGroupMember $_.IdentityReference.value.replace('BMG\','') |
	Select-Object samaccountname, name | Format-Table -hide }
