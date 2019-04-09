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
#Connect-AzureAD
#c7df2760-2c81-4ef7-b578-5b5392b571df   ENTERPRISEPREMIUM

function ModifyAzureServicePlans {
  [CmdletBinding()]
  param (
    [string]
    $AzUser,

    [string]
    $SKUId
  )

  $plansToEnable = @("TEAMS1", "MCOMEETADV")

  $SKU = Get-AzureADSubscribedSku | Where-Object {$_.SkuId -eq $SKUId}
  try {
    foreach ($user in Get-AzureADUser -ObjectId $AzUser | Where-Object {$_.AssignedLicenses}) {
      $userLicenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
      foreach ($license in $user.AssignedLicenses | Where-Object {$_.SkuId -eq $SKUId}) {
        foreach ($planToEnable in $plansToEnable) {
          if ($planToEnable -notmatch "^[{(]?[0-9A-F]{8}[-]?([0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$") {
            $planToEnable = ($SKU.ServicePlans | Where-Object {$_.ServicePlanName -eq "$planToEnable"}).ServicePlanId
          }
          if (($planToEnable -in $SKU.ServicePlans.ServicePlanId) -and ($planToEnable -in $license.DisabledPlans)) {
            $license.DisabledPlans = ($license.DisabledPlans | Where-Object {$_ -ne $planToEnable } | Sort-Object -Unique)
            Write-ToConsoleAndLog -Output "Added plan $planToEnable from license $($SKUId) to user $($AZUser)" -Log C:\Temp\e5_success.log
          }
        }
        $userLicenses.AddLicenses += $license
      }
      Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $userLicenses
    }
  }
  catch {
    $_.Exception.Message
    Write-ToConsoleAndLog -Output $($_.Exception.Message) -Log C:\Temp\e5_error.log
    # $Exception.Message
  }
}

#@"
#sean.connealy.peak@xsonymusic.com
#"@ -split [environment]::NewLine | ForEach-Object {

#ModifyAzureServicePlans -AzUser $_ -SKUId "c7df2760-2c81-4ef7-b578-5b5392b571df"
#}

$users = (import-csv C:\Temp\ToEnable.csv).UserPrincipalName

foreach ($user in $users) {

  ModifyAzureServicePlans -AzUser $user -SKUId "c7df2760-2c81-4ef7-b578-5b5392b571df"
}