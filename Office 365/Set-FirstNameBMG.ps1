@'
rhubard
pire01
ireyes
rconsta
basse02
epicmar
kario01
gott015
lreid01
aburke
bret009
ggupta1
JANE005
SOBM30
STRO047
GALL033
KUMA031
TAYL038
CORO006
ALIS010
SCOT049
BHOI001
LEED011
HISL001
MAGE014
'@ -split [environment]::NewLine | ForEach-Object { 

  #$user = Get-QADUser $_ -Service 'nycmnetads001.mnet.biz:389' | Select-Object FirstName, LastName 
  Get-QADUser $_ -Service 'GTLSMEADS0012' | Select-Object FirstName, LastName 
  
  # Set-ADUser -Identity $_ -GivenName $user.firstname -Server 'GTLSMEADS0012'
  
  } | ft -AutoSize
