﻿$notfound = @()
$users =
@'
BERE019
oberegov
sconnea
SAVC001
voro005
NGOM002
ZHOV001
DURO001
SAVC002
ZHOR001
STOL002
PRUS001
YANU001
SIDE001
KUZE002
FEDO001
CHER008
LOZI001
PRUS002
PEST001
LAZU004
BEZR002
RYMA002
VORO006
SIDE002
SALM004
DIDU001
PONO001
HAVR002
DANI010
SIED001
ZAVS001
BERE003
SADO003
PAVL002
FEDO002
blynch
sconnea
ofussal
MERC015
TOLE016
NGOM002
ack03
ALLM003
ASCAN01
bar21
baum48
broc27
bru17
dre06
frei33
fran05
Gil04
ger38
gnu01
GROS187
han11
hen09
Kla02
Jung21
jame023
sie17
torw01
koe18
lie16
LINNE15
Loc01
loe17
pap03
Lue18
mai05
milk01
reh10
Rei06
rum01
SAGE08
spa07
twe02
STOFF02
STR13
Scmi10
Suka02
ter09
vogt01
Sal05
WOITZ01
mcclu01
GRAE057
list08
bra60
hea02
udov01
kund01
kubs02
CAGE001
ecke12
yhaense
hota001
JUENG02
kach001
KARA318
kre40
yede001
WABE003
herd09
keiss01
SArmout
moss015
UPreuss
JSmithl
simac
YSilberf
Ovoicu
SCHU002
SING005
STONA01
ISTS001
HILB022
NAGE001
HALL005
SOMM003
EDEN001
GIEV001
CHAI002
BUDD001
LOWE004
MORR006
JUDI001
KUHN001
SCHU015
THAD002
meye002
HALL008
SKRI001
SCHL002
ROLL006
BENT002
LANN001
SCHU017
CHEN018
KAPP002
CHRI008
MAZZ002
TALD001
TATU001
GROO005
GUED003
SURE001
GIEH001
HOHL001
SCHE008
BOUK002
PERU001
DERC001
BERD001
PAPA006
GUER005
BIER002
SELV002
SCHR008
SCHA008
BOET002
PUET001
IORG001
SALI005
BERG010
TOPU001
BENT006
GRAZ001
STEI020
BOEL002
MERG019
SCHU025
BUER001
KRAT002
SAAJ001
blynch
sconnea
DURA026
MURU003
REGU002
SASI006
NGOM002
IISM001
SHAR008
FELI003
mool001
BK00001
DAS0004
NARA002
RAMA006
MARI012
SRIR002
TUGA001
KARU002
APPA004
MASL002
JEGA001
KARU003
MADH005
blynch
sconnea
NGOM002
Kra95
pap03
GUPT017
SING097
vit05
SAHU005
zimm136
TIMM001
JAIN004
BUDD001
meye002
KILL001
CHAN020
STEI018
PATE038
KUMA054
'@ -split [environment]::NewLine

foreach ($user in $users) {
    $result = Get-QADUser -Identity $user -Service 'me.sonymusic.com'
    if (!($result)) {
        $notfound += $user
    }
    else {
        "$($result.SAMAccountName);"
    }
}

if ($notfound) {
    Write-Host -Object ''
    Write-Host -Object 'Users Not found in AD' -ForegroundColor Red

    $notfound
}