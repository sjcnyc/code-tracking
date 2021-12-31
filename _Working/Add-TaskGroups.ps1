function Add-TaskGroups {
  <#
      .SYNOPSIS
      Add taskgroups to roles
      .DESCRIPTION
      Add taskgroups to roles
      .EXAMPLE
      Add-TaskGroups -RGroups 'T2_G_Global_AD_Operations-Role' -TGroups 'T2_ADM_AP_L_Modify_General_Tab'
      another example
      Add-TaskGroups -RGroups 'T2_G_Global_AD_Operations-Role' -TGroups @("T2_ADM_AP_L_Modify_General_Tab","T2_ADM_AP_L_Modify_Organization_Tab")
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true, HelpMessage = 'RoleGroups', Position = 0)]
    [string]
    $RGroups,

    [Parameter(Mandatory = $true, HelpMessage = 'Task Groups', Position = 1)]
    [string]
    $TGroups
  )
  
  try {
    
    foreach ($TGroup in $TGroups) {
      Add-ADGroupMember -Identity $RGroups -Members $_ -ErrorAction Stop -WhatIf
    }
  }
  catch [Microsoft.ActiveDirectory.Management.ADException] {
    $_.Exception.Message
  }
}

$TaskGroups =
@'
T2_ADM_AP_L_Modify_General_Tab
T2_ADM_AP_L_Modify_Organization_Tab
T2_ADM_AP_L_Modify_Profile_Tab
T2_ADM_AP_L_Rename_User_Objects
T2_ADM_EU_L_Modify_General_Tab
T2_ADM_EU_L_Modify_Organization_Tab
T2_ADM_EU_L_Modify_Profile_Tab
T2_ADM_EU_L_Rename_User_Objects
T2_ADM_LA_L_Modify_General_Tab
T2_ADM_LA_L_Modify_Organization_Tab
T2_ADM_LA_L_Modify_Profile_Tab
T2_ADM_LA_L_Rename_User_Objects
T2_ADM_NA_L_Modify_General_Tab
T2_ADM_NA_L_Modify_Organization_Tab
T2_ADM_NA_L_Modify_Profile_Tab
T2_ADM_NA_L_Rename_User_Objects
'@ -split [Environment]::NewLine

Add-TaskGroups -RGroups 'T2_G_Global_AD_Operations-Role' -TGroups $TaskGroups

Show-Command -Name 'Add-TaskGroups' -PassThru Add-TaskGroups