@"
SomeUser
"@ -split [environment]::NewLine | ForEach-Object {

    $proxyUpper = Get-aduser sconnea -Server 'me.sonymusic.com' -pr proxyaddresses |Select-Object -ExpandProperty proxyaddresses | Where-Object {$_ -cmatch '^SMTP' -and $_ -like "*@sonymusic.com"}
    Set-ADUser -identity $_ -Remove @{ProxyAddresses = $proxyUpper} -Add @{ProxyAddresses = $proxyUpper.ToLower()}
}

$pmg = Get-ADUser bbarcus -Server 'me.sonymusic.com' -pr proxyaddresses |Select-Object -ExpandProperty proxyaddresses | Where-Object {$_ -like "*pmgsonymusic.com"}
$bmg = $pmg.Substring(0, $pmg.IndexOf('@')).Insert($pmg.IndexOf('@'), '@sonymusic.com')

Write-Output "Setting $pmg to $bmg"
Write-Output "Removing $pmg, Adding $bmg"

Set-AdUser bbarcus -Server 'me.sonymusic.com' -Remove @{ProxyAddresses = $pmg} -Add @{ProxyAddresses = $bmg } -WhatIf

<#
Get-ADUser bbarcus -Server 'me.sonymusic.com' -pr proxyaddresses | Select-Object -ExpandProperty proxyaddresses

SMTP:Blaine.Barcus@pmgsonymusic.com
SMTP:Blaine.Barcus@sonymusic.com

Set-AdUser bbarcus -Server 'me.sonumusic.com' -Remove @{ProxyAddresses='SMTP:Blaine.Barcus@pmgsonymusic.com'} -Add @{ProxyAddresses='SMTP:Blaine.Barcus@sonymusic.com'} #>




@"
sconnea@sonymusic.com
"@ -split [environment]::NewLine | ForEach-Object {

    Get-ADUser -Server 'me.sonymusic.com' -Properties SamAccountname -Filter {"ProxyAddresses" -like $_} | Select-Object SamAccountname
}