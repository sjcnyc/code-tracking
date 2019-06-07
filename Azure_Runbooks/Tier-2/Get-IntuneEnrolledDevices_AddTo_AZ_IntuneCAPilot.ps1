using namespace System.Collections.Generic

function Get-IsAzGroupMember {
  param (
    [string]
    $GroupObjectId,
    [string]
    $UserName
  )

  $g = New-Object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck
  $g.GroupIds = $GroupObjectId
  $User = (Get-AzureADUser -Filter "userprincipalname eq '$($Username)'").ObjectId
  $InGroup = Select-AzureADGroupIdsUserIsMemberOf -ObjectId $User -GroupIdsForMembershipCheck $g

  if ($InGroup -eq $GroupObjectId) {
    return $true
  }
  else {
    return $false
  }
}

$AZ_SeanScriptTesting_Id = "22a3d5b1-083e-4dee-b19a-a267cb432a5e"

Write-Output -InputObject "Loading DLLs, Importing Modules..."
add-type -path "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Intune\Newtonsoft.Json-6.0.1.dll"
add-type -path "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Intune\Microsoft.AspNet.SignalR.Client.dll"
add-type -path "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Intune\Microsoft.Practices.ServiceLocation.dll"
add-type -path "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Intune\Microsoft.WindowsAzure.Storage.dll"
add-type -path "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Intune\Microsoft.ServiceBus.dll"
add-type -path "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Intune\Microsoft.Data.Services.Client.dll"
add-type -path "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Intune\Microsoft.Data.Edm.dll"
add-type -path "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Intune\Microsoft.Data.OData.dll"
add-type -path "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Intune\System.Spatial.dll"

try {
  Import-Module "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Intune\Microsoft.Graph.Intune.psd1" -Scope Local -Force
}
catch {
  $_.Exception.GetBaseException().LoaderExceptions
}

try {
  Write-Output "Retrieving runbook credential object"
  $Credential = Get-AutomationPSCredential -Name 'T2_Cloud_Cred'
  Write-Output "Credentials retrieved"
}
catch {
  Write-Error "Failed to retrieve runbook credentials" -ErrorAction Continue
  Write-Error $_ -ErrorAction Stop
}

$connection = Connect-MSGraph -PSCredential $Credential
Connect-AzureAD -Credential $Credential -ErrorAction SilentlyContinue
Connect-MsolService -Credential $Credential -ErrorAction SilentlyContinue

Write-Output -InputObject "$connection"

$Date = (get-date -f yyyy-MM-dd)
$ManagedDevices_Csv = "C:\support\IntuneEnrolledDevices_Report_$($Date).csv"
$AZ_SeanScriptTesting_Csv = "C:\support\AZ_SeanScriptTesting_Report_$($Date).csv"

$CSVFiles = @()

$Style1 =
'<style>
  body {color:#333333;font-family:Calibri,Tahoma,arial,verdana;font-size: 10pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #E9E9E9;}
  h4 {font-size: 10pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#FFFFFF;background-color:#2980B9;border:1px solid #2980B9;padding:4px;}
  td {padding:4px; border:1px solid #E9E9E9;}
  .odd { background-color:#F6F6F6; }
  .even { background-color:#E9E9E9; }
  </style>'


$ManagedDevices = Get-IntuneManagedDevice | Where-Object { $_.managementAgent -eq "mdm" }

try {
  foreach ($Device in $ManagedDevices) {
    $User_Id = (Get-AzureADUser -Filter "userprincipalname eq '$($Device.UserPrincipalName)'").ObjectId
    Write-Output -InputObject $User_Id
    #Add-AzureADGroupMember -ObjectId $AZ_SeanScriptTesting_Id -RefObjectId $User_Id
    Add-MsolGroupMember -GroupObjectId $AZ_SeanScriptTesting_Id -GroupMemberObjectId $User_Id
  }  
}
catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
  Write-Output $_.Exception.Message
}
catch {
  Write-Output $_.Exception.Message
}

$AZ_SeanScriptTesting_Users = Get-MsolGroupMember -GroupObjectId $AZ_SeanScriptTesting_Id 
$ManagedDevices_Count = $ManagedDevices.Count
$AZ_SeanScriptTesting_Count = $AZ_SeanScriptTesting_Users.Count

$ManagedDevices_Obj = [pscustomobject]@{
  'Task'        = "Azure Hybrid Runbook Worker - Tier-2"
  'Action'      = "Intune Enrolled Devices"
  'Total Users' = $ManagedDevices_Count
}

$AZ_SeanScriptTesting_Obj = [pscustomobject]@{
  'Task'        = "Azure Hybrid Runbook Worker - Tier-2"
  'Action'      = "Total Unique Users"
  'Total Users' = $AZ_SeanScriptTesting_Count
}

if ($null -ne $ManagedDevices_Count) {
  $ManagedDevices | Export-Csv $ManagedDevices_Csv -NoTypeInformation
  $CSVFiles += $ManagedDevices_Csv
}

if ($null -ne $AZ_SeanScriptTesting_Count) {
  $AZ_SeanScriptTesting_Users | Export-Csv $AZ_SeanScriptTesting_Csv -NoTypeInformation
  $CSVFiles += $AZ_SeanScriptTesting_Csv
}

$HTML = New-HTMLHead -title "Intune Enrolled Devices Report" -style $Style1
$HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $ManagedDevices_Obj)
$HTML += "<br>"
$HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $AZ_SeanScriptTesting_Obj)
$HTML += "<h4>See Attached CSV Report</h4>"
$HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

$EmailParams = @{
  To          = "sconnea@sonymusic.com", "intune_automation_reports@sonymusic.com"
  From        = 'PwSh Alerts poshalerts@sonymusic.com'
  Subject     = "Intune Enrolled Devices Report"
  SmtpServer  = 'cmailsony.servicemail24.de'
  Body        = ($HTML | Out-String)
  BodyAsHTML  = $true
  Attachments = $CSVFiles
}

Write-Output -InputObject "Sending Email"
Send-MailMessage @EmailParams
Start-Sleep -Seconds 5

Write-Output -InputObject "Removing Csv File"
foreach ($Item in $CSVFiles) {
  Remove-Item $item
}

# finished for now
Write-Output -InputObject "Completed."