$sourceGPO = "USA-GBL-SCCMClientDeployment"

$targerGPOs =@"
ATH-IOA-SCCMClientDeployment
DE-BER-C-SCCMClientDeployment
BNX-BNL-SCCMClientDeployment
BOG-CAL-SCCMClientDeployment
BOM-SAR-SCCMClientDeployment
BUD-LEV-SCCMClientDeployment
BUE-HUM-SCCMClientDeployment
CCS-LCL-SCCMClientDeployment
CPH-ONV-SCCMClientDeployment
HEL-VAT-SCCMClientDeployment
HKG-APRO-SCCMClientDeployment
HKG-TMA-SCCMClientDeployment
USA-GBL-SCCMClientDepmiyment
IST-MCT-SCCMClientDeployment
JKT-JIJ-SCCMClientDeployment
JNB-JSA-SCCMClientDeployment
KUL-WSM-SCCMClientDeployment
LIS-JSH-SCCMClientDeployment
LON-FHS-SCCMClientDeployment
MAD-ALM-SCCMClientDeployment
MIL-AME-SCCMClientDeployment
MOW-MAS-SCCMClientDeployment
DE-MUC-C-SCCMClientDeployment
MXC-ALA-SCCMClientDeployment
OSL-OCG-SCCMClientDeployment
PAR-BRS-SCCMClientDeployment
PEK-HIB-SCCMClientDeployment
PRA-HMA-SCCMClientDeployment
RIO-ADA-SCCMClientDeployment
SEL-SCD-SCCMClientDeployment
SHA-NWR-SCCMClientDeployment
STG-SEP-SCCMClientDeployment
STO-NBA-SCCMClientDeployment
SYD-HGS-SCCMClientDeployment
TPE-THS-SCCMClientDeployment
AT-VIE-C-SCCMClientDeployment
WAR-OKR-SCCMClientDeployment
ZRH-LGN-SCCMClientDeployment
"@ -split [System.Environment]::NewLine

foreach ($targetGPO in $targerGPOs) {

    Copy-GPO -SourceName $sourceGPO -TargetName $targetGPO -CopyAcl -SourceDomainController "GTLSMEADS0012" -TargetDomainController "GTLSMEADS0012"


}