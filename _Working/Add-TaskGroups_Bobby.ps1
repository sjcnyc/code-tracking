$TGroups =
@"
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
"@ -split [System.Environment]::NewLine

try {

  foreach ($TGroup in $TGroups) {
    Add-ADGroupMember -Identity "T2_G_Global_AD_Operations-Role" -Members $_ -ErrorAction Stop -WhatIf
  }
}
catch [Microsoft.ActiveDirectory.Management.ADException] {
  $_.Exception.Message
}