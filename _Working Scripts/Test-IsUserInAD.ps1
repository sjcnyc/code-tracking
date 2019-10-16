using namespace System.Collections.Generic

function Test-IsUserInAD {
  param (
    [string]
    $UserName,

    [string]
    $Domain
  )

  $UserList = [List[PSObject]]::new()
  foreach ($User in $UserName) {
    try {

      $getADUserSplat = @{
        Properties  = 'Displayname', 'sAMAccountName', 'mail', 'enabled'
        Server      = $Domain
        ErrorAction = 'Stop'
        Identity    = $UserName
      }
      $User = Get-ADUser @getADUserSplat
      $Result = $true
    }
    catch {
      $Result = $false
    }

    $PSObject = [pscustomobject]@{
      UserChecked    = $UserName
      SamAccountName = $User.sAMAccountName
      DisplayName    = $User.DisplayName
      IsInAD         = $Result
    }
    [void]$UserList.Add($PSObject)
  }

  return $UserList
}


@"
ABOOTH
abrown
aelliot
alaidla
ALBE060
amagill
ASTINES
avehec
bbruing
bcooper
BESS024
bfrashe
bkaplan
bmartino
bore004
bsterl1
ccranfo
cham041
cisaacs
cmccar01
cmelanc
COST063
CRYAN
cstaton
csurren
cwons01
ddame
dduarte
dhobson
dlarsen
DOYL015
EATH001
fish014
FITZ038
garb016
good013
HMCBEE
hodg011
hopp035
JBAINES
JBLAIR
jburnso
jburrel
jeasler
jens022
jfox1
jfreel
jhutchi
JJOHNSO
jmorris
jone113
jsledg1
jtanner2
jwills
KING056
KMETOYE
lgreens
lind073
lmccurr
lperkins
lsomerv
lthomas
LYNC019
madams2
malliso
marc064
MARI002
MCCA043
mcraft1
mgalvin
mmcco01
mole003
MOOR001
mrivers
nevan1
nnix
ocon008
PBARNAB
PEAR003
PIN0001
purd001
rdokke1
rgordon
RJONES
rlgrcpt
rmeacham
robo002
rsherri
sbishop
SMIT001
sstache
tbaskett
tcleek
toml010
twelch
upch001
UTLE003
VONL009
vwillis
WAYJ001
wong018
wvause1
ZARL001
"@ -split [environment]::NewLine | ForEach-Object {

  Test-IsUserInAD $_ -Domain me.sonymusic.com | Export-Csv D:\Temp\Nash_home_shares_InAD.csv -NoTypeInformation -Append
}