#Add-QADGroupMember -Identity 'USA-GBL Airwatch MDM Users' -Member (Get-QADUser -SearchRoot 'bmg.bagint.com/USA/GBL/USR' -Enabled) -WhatIf

#requires -Modules HTMLTable
#requires -Version 2
#requires -PSSnapin Quest.ActiveRoles.ADManagement
Add-PSSnapin -Name Quest.ActiveRoles.ADManagement

$StartTime = Get-Date -Format G
$title     = 'Add Users to Security Group.'
$countMsg  = 'Users Added.'
$group     = 'CN=USA-GBL Airwatch MDM Users,OU=Restricted,OU=GRP,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com'
$msg       = 'Group: USA-GBL Airwatch MDM Users'

$QADParams = @{
    SizeLimit                        = '0'
    PageSize                         = '2000'
    DontUseDefaultIncludedProperties = $true
    IncludedProperties               = @('Name', 'SamAccountName', 'ParentContainer', 'MemberOf')
    SearchRoot                       = @('bmg.bagint.com/USA/GBL/USR')
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

$users = Get-QADUser @QADParams -Enabled

$i = 0
$result = New-Object System.Collections.ArrayList

if ($users -ne $null) {
    foreach ($user in $users) {
        if ($user.MemberOf -ne $group) {
            $i++
            $info = [pscustomobject]@{
                'Username'        = ($user.Name).ToUpper()
                'ParentContainer' = $user.ParentContainer.Replace('bmg.bagint.com/', '')
            }

            Add-QADGroupMember -Identity $group -Member $user.SamAccountName -ErrorAction 0 -WhatIf

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
            to         = 'sean.connealy@sonymusic.com'
            from       = 'Posh Alerts poshalerts@sonymusic.com'
            subject    = $title
            smtpserver = 'ussmtp01.bmg.bagint.com'
            body       = ($HTML | Out-String)
            bodyashtml = $true
        }
        Send-MailMessage @emailParams
    }
}