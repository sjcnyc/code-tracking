@"
AKL-CGR OU Administrators
ATH-IOA OU Administrators
BER-BVS OU Administrators
BNE-SCP OU Administrators
BOG-CAL OU Administrators
BOM-SAR OU Administrators
BUD-LEV OU Administrators
BUE-HUM OU Administrators
BVH-WIL OU Administrators
CCS-LCL OU Administrators
CPH-ONV OU Administrators
DUB-EBH OU Administrators
EUR-CZE OU Administrators
EUR-DEN OU Administrators
EUR-ESP OU Administrators
EUR-FRA OU Administrators
EUR-GBR OU Administrators
EUR-GER OU Administrators
EUR-ITA OU Administrators
FLL-LARO OU Administrators
FUK-HAK OU Administrators
GTL-ADA-G OU Administrators
GTL-AOB OU Administrators
HEL-VAT OU Administrators
HKG-APRO OU Administrators
HKG-TMA OU Administrators
IST-MCT OU Administrators
JKT-JIJ OU Administrators
JNB-JSA OU Administrators
KUL-WSM OU Administrators
LIS-JSH OU Administrators
LON-FHS OU Administrators
MAD-ALM OU Administrators
MEL-PST OU Administrators
MIL-AME OU Administrators
MIL-LOM OU Administrators
MOW-MAS OU Administrators
MPL-EDI OU Administrators
MUC-ASY OU Administrators
MUC-EROS OU Administrators
MUC-EXT OU Administrators
MUC-GDB OU Administrators
MUC-IST OU Administrators
MUC-NMS OU Administrators
MXC-ALA OU Administrators
NAG-NIS OU Administrators
OSA-TOY OU Administrators
OSL-OCG OU Administrators
PAR-BRS OU Administrators
PEK-HIB OU Administrators
PER-HRD OU Administrators
PRA-HMA OU Administrators
RIO-ADA OU Administrators
SAP-OHD OU Administrators
SBME-ALL OU Administrators
SEL-SCD OU Administrators
SHA-NRW OU Administrators
SIN-CCR OU Administrators
SIN-SCR OU Administrators
SJO-NDN OU Administrators
SMS-SRV OU Administrators
STG-SEP OU Administrators
STO-NBA OU Administrators
SYD-HGS OU Administrators
TOR-LBS OU Administrators
TPE-THS OU Administrators
TYO-CTB OU Administrators
TYO-TOB OU Administrators
UIO-ADD OU Administrators
USA-GBL OU Administrators
VEN-FFG OU Administrators
VIE-FAV OU Administrators
WAR-OKR OU Administrators
ZRH-LGN OU Administrators
"@ -split [environment]::NewLine | ForEach-Object -Process {

    Add-ADGroupMember -Identity $_ -Members "_svcdmmpc" -WhatIf
}