#Get-ChildItem Cert:\localmachine\my -recurse | where-object { $_.issuer -like "*bmg*"} | ForEach-Object {Remove-Item -path $_.PSPath -recurse -Force -WhatIf}

$myCerts = Get-Item Cert:\localmachine\My
$myCerts.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
$bmgCert = Get-ChildItem $myCerts.PSPath -Recurse | Where-Object { $_.issuer -like "*bmg*"}
ForEach ($Cert in $bmgCert) {
    #$myCerts.Remove($Cert)
    Write-Output "$cert"
 }

 $myCerts.Close()
