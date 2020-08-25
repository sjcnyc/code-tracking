@"
ana.garcia@sonymusic.com
alexandre.nzeza@sonymusic.com
brodrick.williams@sonymusic.com
elie.hakim@sonymusic.com
hunnit.lee@sonymusic.com
jessica.barlow@sonymusic.com
lauren.soloway@sonymusic.com
moa.egonson@sonymusic.com
ngoc-phuc.huynh@sonymusic.com
tavis.chaguay@sonymusic.com
till.rentschler@sonymusic.com
"@ -split [environment]::NewLine | ForEach-Object {

  Get-ADUser -Filter "userPrincipalName -eq '$($User)'" -Properties sAMAccountName | Add-ADGroupMember -Identity ""
}
