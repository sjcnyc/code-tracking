$Users = @"
bali.zheng@sonymusic.com
bo.plantinga@sonymusic.com
johnny.richards@sonymusic.com
melinda.shopsin@sonymusic.com
ninad.kawale@sonymusic.com
"@ -split [environment]::NewLine

foreach ($user in $users) {

  Get-QADUser $user -IncludedProperties samaccountname | Select-Object samaccountname #, @{N='UPN'; E={$user}} | Export-Csv d:\temp\linkedinUsers1.csv -NoTypeInformation -Append

}



ZHEN003;
PLAN002;
RICH001;
SHOP001;
kawa001;
