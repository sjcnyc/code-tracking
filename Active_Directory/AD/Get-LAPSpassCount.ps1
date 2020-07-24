$ErrorActionPreference = "SilentlyContinue"
$total = Get-ADComputer -SearchBase 'OU=Windows7,OU=WST,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com' -Server 'me.sonymusic.com' -filter '*' -Properties ms-Mcs-AdmPwd
$totalCount = $total.Count
Write-Host "Total:$totalCount"
$PW = $total | Where-Object {$_.'ms-Mcs-AdmPwd' -ne $null}
$PWCount = $PW.Count
Write-Host "Passwords:$PWCount"
$noPWCount = $totalCount - $PWCount
Write-Host "no PW:$noPWCount"
$percent = ($PWCount / $totalCount) * 100
$percent = [math]::Round($percent, 2)
Write-Host "$percent%"