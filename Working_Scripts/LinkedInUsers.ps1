$Users = @"
adam.sapper@sonymusic.com
denis.andreev.sme@sonymusic.com
diana.rasulova.sme@sonymusic.com
ekaterina.stupak.sme@sonymusic.com
ekaterina.urlova@sonymusic.com
hayley.marchant@sonymusic.com
jacqueline.painten@sonymusic.com
kate.mishkin@sonymusic.com
kris.winter@sonymusic.com
lyubov.ilvohina.sme@sonymusic.com
mariajose.avilez@sonymusic.com
tural.mamedov.sme@sonymusic.com
vladimir.kuzmichev@sonymusic.com
"@ -split [environment]::NewLine

foreach ($user in $users) {

  Get-QADUser $user -IncludedProperties samaccountname | Select-Object samaccountname #, @{N='UPN'; E={$user}} | Export-Csv d:\temp\linkedinUsers1.csv -NoTypeInformation -Append

}

