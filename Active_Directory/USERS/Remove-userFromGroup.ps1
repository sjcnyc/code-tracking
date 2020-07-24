$users = @"
acahn12
tsearle
cmollis
emansfi
MIRA040
BRUN094
MELN002
SEIN002
ROBL008
rsangst
mkirkeb
tsengt
kellykyriss
FERN097
kadibi1
draf002
wool011
treb004
inks01
GILL023
SMIT037
VAND102
VITA005
damaquie
diacogn
Imarand
GCR20004386
lsonkin
dwenger
apolloc
GCR20004488
"@ -split[environment]::NewLine

$group = 'CN=WWI-O365-LinkSwapEnabled,OU=O365,OU=GRP,OU=WWI,DC=bmg,DC=bagint,DC=com'


foreach ($user in $users) 
{
  try
  {
    Remove-QADGroupMember -Identity $group -Member $user -WhatIf
  }
  catch
  {
    "Error was $_"
  }
}
