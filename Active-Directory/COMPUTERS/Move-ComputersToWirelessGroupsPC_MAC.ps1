#requires -Modules PSHTMLTable
#requires -Version 2

Add-PSSnapin -Name Quest.ActiveRoles.ADManagement 

$StartTime   = Get-Date -Format G
$title       = 'Add Computers to Security Group.'
$countMsg    = 'Computers Added.'
$TargetWin   = 'CN=WWI-Wireless-PC-PKI,OU=GRP,OU=WWI,DC=bmg,DC=bagint,DC=com'
$TargetMac   = 'CN=WWI-Wireless-MAC-PKI,OU=GRP,OU=WWI,DC=bmg,DC=bagint,DC=com'
$msg        = 'Groups: WWI-Wireless-PC-PKI & WWI-Wireless-MAC-PKI'


$QADParams = @{
  SizeLimit                        = '0'
  PageSize                         = '2000'
  DontUseDefaultIncludedProperties = $true
  IncludedProperties               = @('Name', 'SamAccountName', 'ParentContainer', 'MemberOf', 'OSName')
  SearchRoot                       = @('bmg.bagint.com/USA/GBL/WST/MAC', 'bmg.bagint.com/USA/GBL/WST/Windows7', 'bmg.bagint.com/FLL/LARO/WST')
}

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

$computers = Get-QADComputer @QADParams 

$i = 0
$result = New-Object System.Collections.ArrayList

if ($computers -ne $null) {
  foreach ($comp in $computers) {
    if (! $comp.MemberOf -eq $TargetWin -or ! $comp.MemberOf -eq $TargetMac){
      $i++
      $info = [pscustomobject]@{
        'ComputerName'    = ($comp.Name).ToUpper()
        'ParentContainer' = $comp.ParentContainer.Replace('bmg.bagint.com/','')
        'OSName'           = $comp.OSName
      }
	
      if ($comp.OSName -match 'MAC') 
      {
        Add-QADGroupMember -Identity $TargetMac -Member $comp.SamAccountName -ErrorAction 0
      }
      elseif ($comp.OSName -match 'Windows') 
      {
        Add-QADGroupMember -Identity $TargetWin -Member $comp.SamAccountName -ErrorAction 0
      }

      $null = $result.Add($info)
    }
    $count = $i
  }

  if ($result -ne $null) {

    $HTML = New-HTMLHead -title $title -style $style1
    $HTML += "<h3>$($title)</h3>"
    $HTML += "<h4>$($msg)</h4>"
    $HTML += "<h4>($($count)) $($countMsg)</h4>"
    $HTML += "<h4>Script Started: $($StartTime)</h4>"
    $HTML += New-HTMLTable -InputObject $($result)
    $HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

    $emailParams = @{
      to         = 'sean.connealy@sonymusic.com'#,'Brian.Lynch@sonymusic.com','Alfredo.Torres.PEAK@sonymusic.com','ist.macadmin@sonymusic.com'
      from       = 'Posh Alerts poshalerts@sonymusic.com'
      subject    = $title
      smtpserver = 'ussmtp01.bmg.bagint.com'
      body       = ($HTML | Out-String)
      bodyashtml = $true
    }     

    Send-MailMessage @emailParams
  }
}