function Get-ADGroupMemberships {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param(
    [parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $true, Position = 0)]
    [System.Array]$Groups,

    [parameter(Position = 2)]
    [System.Management.Automation.SwitchParameter]$Export,

    [parameter(Position = 3)]
    [System.String]$ReportPath = "D:\Temp\",

    [parameter(Position = 4)]
    [System.String]$ReportName = "Report",

    [parameter(Position = 5)]
    [System.String]$ReportDate = "_$(get-date -format 'MM-dd-yyy')_1",

    [parameter(Position = 6)]
    [ValidateSet("csv", "pdf")]
    [System.String]$Extension
  )

  try {
    $obj = $Groups | Get-ADGroup -PipelineVariable Grp -Properties Name | Get-ADGroupMember |
      Get-ADUser -Properties GivenName, SurName, SamaccountName, DistinguishedName |
      Select-Object -Property GivenName, SurName, SamaccountName, DistinguishedName, @{N = 'GroupName'; E = {$Grp.SamAccountName}}
    if ($Export) {
      switch ($Extension) {
        csv { $obj | Export-CSV -Path "$($ReportPath)$($ReportName)$($ReportDate).$($Extension)" -NoTypeInformation }
        pdf { $obj | Out-PTSPDF -Path "$($ReportPath)$($ReportName)$($ReportDate).$($Extension)" -FontSize 8 -AutoSize }
      }
    }
    else {
      Write-Output $obj
    }
    Write-Output "Member Count : $(($obj).Count)"
  }
  catch {
    $_.Exception.Message
  }
}

$Groups = @"
T1_App_Global_G_Jamf_Admin
T1_App_Global_G_Jamf_Admin_FullAccess
T1_App_Global_G_Jamf_Auditor_ReadOnly
T1_App_Global_G_Jamf_DesktopTechnicians
T1_App_Global_G_Jamf_ServiceDesk
"@ -split [System.Environment]::NewLine

Get-ADGroupMemberships -Groups $Groups -Export -Extension csv