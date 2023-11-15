function Get-ADGroupMemberships {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param(
    [parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $true, Position = 0)]
    [System.Array]$Groups,

    [parameter(Position = 2)]
    [System.Management.Automation.SwitchParameter]$Export,

    [parameter(Position = 3)]
    [System.String]$ReportPath = 'C:\Temp\',

    [parameter(Position = 4)]
    [System.String]$ReportName = 'Share_Report',

    [parameter(Position = 5)]
    [System.String]$ReportDate = "_$(Get-Date -Format 'MM-dd-yyy')",

    [parameter(Position = 6)]
    [ValidateSet('csv', 'pdf')]
    [System.String]$Extension
  )

  try {
    $obj = $Groups | Get-ADGroup -PipelineVariable Grp -Properties Name, Description | Get-ADGroupMember |
    Get-ADUser -Properties GivenName, SurName, SamaccountName, Enabled, DistinguishedName, UserPrincipalName, Description |
    Select-Object -Property GivenName, SurName, SamaccountName, Enabled, DistinguishedName, UserPrincipalName, Description, @{N = 'GroupName'; E = { $Grp.SamAccountName } }, @{N = 'Path'; E = { $Grp.Description} }
    if ($Export) {
      switch ($Extension) {
        csv { $obj | Export-Csv -Path "$($ReportPath)$($ReportName)$($ReportDate).$($Extension)" -NoTypeInformation }
        pdf { $obj | Out-PTSPDF -Path "$($ReportPath)$($ReportName)$($ReportDate).$($Extension)" -FontSize 8 -AutoSize }
      }
    } else {
      Write-Output $obj
    }
    Write-Output "Member Count : $(($obj).Count)"
  } catch {
    $_.Exception.Message
  }
}

$Groups = @'
USA-GBL Member Server Administrators
'@ -split [System.Environment]::NewLine

Write-Host "$(Get-Date)"

Get-ADGroupMemberships -Groups $Groups -Export -Extension csv -ReportName 'Server_admins' -ReportPath 'C:\Temp\'

<#
AZ_AVD_DSC_FullDesktop
AZ_AVD_DAG_FullDesktop
AZ_AVD_RDC_FullDesktop
AZ_AVD_SCUBA_FullDesktop
AZ_AVD_UltraRecords_FullDesktop
#>
