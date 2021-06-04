Param
(
  [Parameter(Mandatory = $true)]
  [string]$UserUPN
)

$Usr = Get-ADUser -Identity $UserUPN -Properties *
$UsrUPN = $usr.UserPrincipalName
$UsrName = $Usr.GivenName
$UsrSurname = $Usr.SN
$UsrFullName = $UsrName + ' ' + $UsrSurname
$UsrManager = Get-ADUser $UserUPN -Properties * | Select-Object -ExpandProperty Manager
$UsrManagerEmail = Get-ADUser -Identity "$UsrManager" -Properties * | Select-Object Name

Write-Host $UsrManagerEmail