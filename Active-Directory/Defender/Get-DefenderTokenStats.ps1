# PowerShell script to send an email if any Defender License exceeds a defined percentage.

$ErrorActionPreference = 'silentlycontinue'

#Get Defender license information
Add-PSSnapin Quest.Defender.AdminTools

$store = Get-DefenderLicense

#extract each row and calculate percentage of license used.
#foreach ($var in $store)
#{
$percent = 0
$licensetype = $store.LicenseType
$userassigned = $store.AssignedUsers
$usertotal = $store.TotalUsers
$tokensfree = ($usertotal - $userassigned)
$percent = $percent + ($userassigned / $usertotal) * 100



#determine percentage value of license usage to trigger email (change ’90’ value to percentage you wish to use).
If ($percent -ge 80) { $sendemail++ }

$percent = '{0:N2}' -f ($percent)
$body += @"
$percent percent of license used.
$tokensfree tokens left for distribution.
  
$licensetype License has $userassigned users assigned.
The total number of Licenses is: $usertotal. 
"@
#}

$body

if ($sendemail -ge 1) {
    Send-MailMessage -From 'Posh Alerts poshalerts@sonymusic.com' `
  -To 'sconnea@sonymusic.com' `
  -Subject 'Quest Defender - Daily Token Summary' `
  -Body "$body" `
  -SmtpServer 'ussmtp01.bmg.bagint.com'
}

Remove-Variable -Name * -Scope global -Force


## End Script