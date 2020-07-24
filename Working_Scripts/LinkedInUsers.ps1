$Users = @"
alexander.franco@sonymusic.com
annette.gevert@sonymusic.com
janay.marie@sonymusic.com
julianne.myers@sonymusic.com
"@ -split [environment]::NewLine

foreach ($user in $users) {

  Get-QADUser $user -IncludedProperties samaccountname | Select-Object samaccountname #, @{N='UPN'; E={$user}} | Export-Csv d:\temp\linkedinUsers1.csv -NoTypeInformation -Append

}