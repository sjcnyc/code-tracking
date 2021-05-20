$getADUserSplat = @{
  Filter     = { homedirectory -like "\\usnaspwfs01*" }
  Properties = 'SamAccountName', 'HomeDirectory', 'HomeDrive', 'DistinguishedName'
  Server     = 'me.sonymusic.com'
}
$Users = Get-ADUser @getADUserSplat | Select-Object $getADUserSplat.Properties

$Users =
@"
HAAR006
malliso
abrown
jburrel
jcatino
CHAM041
DOYL015
dduarte
jeasler
GARB016
rgordon
GOOD013
cwons01
HODG011
HOPP035
JENS022
jjohnso
LIND073
cstaton
MARC064
bmartino
mmcco01
dnelson1
ROBO002
cryan
lsantia
rsherri
jsledg1
sstache
astines
csurren
lthomas
TOML010
nevan1
WONG018
amagill
hmcbee
avehec
vwillis
EATH001
MCCA043
SULL010
UPCH001
BERI020
FITZ038
WAYJ001
ALBE060
COST063
ZARL001
KING056
MCAN004
OWEN024
SLAV002
UTLE003
ELLI044
DHIL001
MARI002
DAVI007
ophe001
CLOG001
"@ -split [environment]::NewLine

foreach ($User in $Users) {
  $setADUserSplat = @{
    HomeDrive     = 'H:'
    HomeDirectory = "\\USNASPLSYN001.me.sonymusic.com\home$\$($User)"
    Server        = 'me.sonymusic.com'
    WhatIf        = $true
    Identity      = $User
  }
  Set-ADUser @setADUserSplat
}