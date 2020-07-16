$users = @"
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
SAND205
"@ -split [environment]::NewLine

foreach ($user in $users) {
  try {
    Get-ADUser $user -Properties DisplayName, sAMAccountName |
      Select-Object DisplayName, sAMAccountName |
      Export-Csv D:\Temp\OneDriveMigration_Nashvile.csv -Append
  }
  catch {
    $_.ErrorDetails
  }
}

$AllUsers = Import-Csv D:\Temp\OneDriveReport_Nashville.csv
$NashvilleUsers = Import-Csv D:\Temp\OneDriveMigration_Nashvile.csv

Join-Object -Left $AllUsers -Right $NashvilleUsers -LeftJoinProperty DisplayName -RightJoinProperty DisplayName | Export-Csv D:\Temp\OneDriveMigration_Joined.csv

Import-Module Sharegate
$csvFile = "C:\MigrationPlanning\onedrivemigration.csv"
$table = Import-Csv $csvFile -Delimiter ","
$mypassword = ConvertTo-SecureString "mypassword" -AsPlainText -Force
Set-Variable dstSite, dstList
foreach ($row in $table) {
  Clear-Variable dstSite
  Clear-Variable dstList
  $dstSite = Connect-Site -Url $row.ONEDRIVEURL -Username "myusername" -Password $mypassword
  Add-SiteCollectionAdministrator -Site $dstSite
  $dstList = Get-List -Name Documents -Site $dstSite
  Import-Document -SourceFolder $row.DIRECTORY -DestinationList $dstList
  Remove-SiteCollectionAdministrator -Site $dstSite
}