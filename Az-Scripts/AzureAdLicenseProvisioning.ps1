<#
MYANALYTICS_P2
PAM_ENTERPRISE
BPOS_S_TODO_3
FORMS_PLAN_E5
STREAM_O365_E5
THREAT_INTELLIGENCE
Deskless
FLOW_O365_P3
POWERAPPS_O365_P3
TEAMS1
ADALLOM_S_O365
EQUIVIO_ANALYTICS
LOCKBOX_ENTERPRISE
EXCHANGE_ANALYTICS
SWAY
ATP_ENTERPRISE
4NOcr5bc5cHj
MCOMEETADV
BI_AZURE_P2
INTUNE_O365
PROJECTWORKMANAGEMENT
RMS_S_ENTERPRISE
YAMMER_ENTERPRISE
OFFICESUBSCRIPTION
MCOSTANDARD
EXCHANGE_S_ENTERPRISE
SHAREPOINTENTERPRISE
SHAREPOINTWAC
#>

#Connect-AzureAD -Credential $UserCredential

$UserToLicense = Get-AzureADUser -ObjectId "sean.connealy.peak@sonymusic.com"

$EnabledPlans = (Get-AzureADUser -ObjectId "sean.connealy.peak@sonymusic.com" | Select-Object -ExpandProperty AssignedPlans)

$PlansToEnable = 'MCOMEETADV', 'SWAY'

$LicenseSku = Get-AzureADSubscribedSku | Where-Object {$_.SkuPartNumber -eq 'ENTERPRISEPREMIUM'}

foreach ($plan in $EnabledPlans.ServicePlanId) {

  $DisabledPlans = $LicenseSku.ServicePlans |
    ForEach-Object -Process {
    $_ | Where-Object -FilterScript {
      $_.ServicePlanName -notin $PlansToEnable -or $_.ServicePlanId -ne $plan
    }
  }
}

$License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$License.SkuId = $LicenseSku.SkuId
$License.DisabledPlans = $DisabledPlans.ServicePlanId

$AssignedLicenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$AssignedLicenses.AddLicenses = $License
$AssignedLicenses.RemoveLicenses = @()
Set-AzureADUserLicense -ObjectId $UserToLicense.ObjectId -AssignedLicenses $AssignedLicenses