#requires -Version 3.0
function Export-SQLqueryToCSV {
  param (
    [Parameter(Mandatory)][string]$server,
    [Parameter(Mandatory)][array]$database,
    [Parameter(Mandatory)][string]$path
  )

  $currentDate = (Get-Date -Format MM-dd-yyyy)
   
  $sqlcn = New-Object -TypeName System.Data.SqlClient.SqlConnection
  $sqlcn.ConnectionString = "Server=$($server);Integrated Security=true;Initial Catalog=$($database)"
  $sqlcn.Open()
  $sqlcmd = $sqlcn.CreateCommand()
  $query = @'
SELECT docsadm.people.USER_ID, docsadm.people.FULL_NAME, docsadm.people.ALLOW_LOGIN, 
docsadm.groups.GROUP_NAME, docsadm.people.LAST_LOGIN_DATE
FROM docsadm.PEOPLE 
JOIN docsadm.GROUPS on docsadm.people.PRIMARY_GROUP=docsadm.groups.SYSTEM_ID
'@
  $sqlcmd.CommandText = $query
  $adp = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter -ArgumentList $sqlcmd
  $data = New-Object -TypeName System.Data.DataSet
  $null = $adp.Fill($data)
  $objTable = $data.Tables[0] 
  $objTable | Export-Csv -Path "$($path)$($database)_$($currentDate).csv" -NoTypeInformation
}

$ServerFQDN = 'ussmevwapp3331.bmg.bagint.com'

<#
10.12.111.123	ussmevwapp333
10.12.111.124	ussmevwapp334
10.12.111.125	ussmevwapp335
10.12.111.126	ussmevwapp336
#>

$databases = @'
Arista
Employment
LAW
Publishing
RCA
SMI
'@-split [environment]::NewLine

foreach ($database in $databases) {Export-SQLqueryToCSV -server $ServerFQDN -database $database -path "c:\temp\"}