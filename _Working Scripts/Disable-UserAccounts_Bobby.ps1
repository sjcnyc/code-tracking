@"
AGUI078
ALONS03
ALVA004
andra01
CALDE08
CALV018
CARI035
CARM001
casta02
CERE010
DEMU001
ELIZ002
EQUI002
FRIA001
GARC189
giro001
GOME001
GUAJ017
HERN184
herr001
hvargas
KARL039
LATH008
LOMB016
LOPE155
LOZA002
MANCI03
MEND005
MEND110
nav.cgarcía
OROZ001
SALA080
SEGU012
SERVI03
STEP060
VERO004
VICEN03
VIDA001
VILL099
admargu001
fall012
MUJI006
samcr01
usuarioftp
wusuario
ALED002
ANTEN01
AUME001
CABE001
CIAL001
croci01
DOMI063
FERR017
GERB028
gsbmg08
juar005
MART401
MONS020
OSPI001
SARA025
toran01
ABRE007
ALEN003
AMOR001
Borg053
Brag003
brimm01
BRUM011
burz001
CABR001
camp004
cane001
Casi009
CAVA022
CHAV001
CRUZ104
DIME004
EGUE002
Fari016
FERR002
Flau006
FREI001
GOMI001
guid002
JULI001
koel001
Lage008
LEIT016
LENC002
LOUR001
MACH001
matto01
mauro01
MEND068
mesqu01
NARV006
NUNE028
OLIV069
PINH007
PIRE009
PIRE010
RODR178
RODR252
SA00001
sant005
sant006
SANT202
schu008
Sobm61
teles01
VIDA013
VIEI008
VILL093
"@ -split [environment]::NewLine | ForEach-Object {

  try {
    Disable-ADAccount -Identity $_ -WhatIf
    #Remove-ADUser -Identity $_ -WhatIf
  }
  catch {
    $Error.Message
  }
}