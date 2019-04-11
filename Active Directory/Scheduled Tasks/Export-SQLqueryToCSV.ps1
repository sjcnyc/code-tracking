#requires -PSSnapin Quest.ActiveRoles.ADManagement
#requires -Version 5.0
#requires -Modules HTMLTable

# update module Install-Module PSHTMLTable -Scope CurrentUser -AllowClobber

# Notes from Heather : 
# As discussed, this can be sent every six months (starting in February, 2017).
# Rohan will supply the distribution list.

# vars
$ServerFQDN = 'USSMEVWSQL001.bmg.bagint.com'
$savePath = '\\storage\infradev$\HummingBirdSQL\'
$currentDate = (Get-Date -Format MM-dd-yyyy)
$StartTime = Get-Date -Format G
$title = 'Hummingbird User Report'
$msg = "Server : $($ServerFQDN)"
$msg1 = "Save Path : $($savePath)"
$countMsg = 'Tables Exported.'

$databases = @'
Arista
Employment
LAW
Publishing
RCA
SMI
'@-split [environment]::NewLine

$style1 = '<style>
  body {color:#333333;font-family:Calibri,Tahoma,arial,verdana;font-size: 8pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #666666;}
  h4 {font-size: 8pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#eeeeee;background-color:#333333;border:1px solid black;padding:4px;}
  td {padding:4px; border:1px solid black;}
  .odd { background-color:#ffffff; }
  .even { background-color:#CFCFCF; }
</style>'

function Export-SQLqueryToCSV {
  param (
    [Parameter(Mandatory)][string]$server,
    [Parameter(Mandatory)][string]$database,
    [Parameter(Mandatory)][string]$path
  )
   
  $sqlcn = New-Object -TypeName System.Data.SqlClient.SqlConnection
  $sqlcn.ConnectionString = "Server=$($server);Integrated Security=true;Initial Catalog=$($database)"
  $sqlcn.Open()
  $sqlcmd = $sqlcn.CreateCommand()
  $query = @'
SELECT docsadm.people.USER_ID, docsadm.people.FULL_NAME, docsadm.people.ALLOW_LOGIN, 
docsadm.groups.GROUP_NAME, docsadm.people.LAST_LOGIN_DATE, docsadm.people.APPROVER 
FROM docsadm.PEOPLE 
JOIN docsadm.GROUPS on docsadm.people.PRIMARY_GROUP=docsadm.groups.SYSTEM_ID
'@
  $sqlcmd.CommandText = $query
  $adp = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter -ArgumentList $sqlcmd
  $data = New-Object -TypeName System.Data.DataSet
  $null = $adp.Fill($data)
  $objTable = $data.Tables[0] 
  $newTable = New-Object -TypeName System.Collections.ArrayList
  
  foreach ($dataitem in $objTable.Rows) {
    $dt = [pscustomobject]@{
      'USER_ID'         = $dataitem[0]
      'FULL_NAME'       = $dataitem[1]
      'ALLOW_LOGIN'     = $dataitem[2]
      'GROUP_NAME'      = $dataitem[3]
      'LAST_LOGIN_DATE' = $dataitem[4]
      'APPROVER'        = $dataitem[5]   
      'LOCATION'        = Get-QADUser -Identity $dataitem[0] | Select-Object -ExpandProperty Office
      'TABLE'           = $database
    }
    
    $null = $newTable.add($dt)
  }
  
  $newTable | Export-Csv -Path "$($path)HummingBird_User_Report_$($currentDate).csv" -NoTypeInformation -Append
}

$result = New-Object -TypeName System.Collections.ArrayList
$attachments = @()
foreach ($database in $databases) {
  $info = [pscustomobject]@{
    'Name'    = $database
    'Type'    = 'Table'
  }
  
  Export-SQLqueryToCSV -server $ServerFQDN -database $database -path $savePath
  $null = $result.Add($info)
}

$attachments = "$($savePath)HummingBird_User_Report_$($currentDate).csv"

$count = $result.Count

$HTML = New-HTMLHead -title $title -style $style1
$HTML += "<h3>$($title)</h3>" 
$HTML += "<h4>$($msg)</h4>"
$HTML += "<h4>$($msg1)</h4>"
$HTML += "<h4>($($count)) $($countMsg) </h4>"
$HTML += "<h4>Script Started: $($StartTime)</h4>"
$HTML += New-HTMLTable -InputObject $($result)
$HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

$emailParams = @{
  to          = 'sean.connealy@sonymusic.com' #service.desk@sonymusic.com
  from        = 'Posh Alerts poshalerts@sonymusic.com'
  subject     = $title
  smtpserver  = 'ussmtp01.bmg.bagint.com'
  body        = ($HTML | Out-String)
  bodyashtml  = $true
  Attachments = $attachments
}

Send-MailMessage @emailParams