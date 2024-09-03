<#
.SYNOPSIS
  Retrieves the group memberships of Active Directory groups and exports the results to a CSV or PDF file.

.DESCRIPTION
  The Get-ADGroupMemberships function retrieves the group memberships of Active Directory groups and provides options to export the results to a CSV or PDF file.
  The function takes an array of group names as input and returns a custom object with properties including user details, group name, and group path.

.PARAMETER Groups
  Specifies the array of group names for which to retrieve the group memberships.

.PARAMETER Export
  Indicates whether to export the results to a file. If specified, the function exports the results based on the specified extension.

.PARAMETER ReportPath
  Specifies the path where the exported report file will be saved. The default path is 'C:\Temp\'.

.PARAMETER ReportName
  Specifies the name of the exported report file. The default name is 'Share_Report'.

.PARAMETER ReportDate
  Specifies the date format to append to the report name. The default format is '_MM-dd-yyyy'.

.PARAMETER Extension
  Specifies the file extension for the exported report file. Valid values are 'csv' and 'pdf'.

.OUTPUTS
  The function outputs a custom object with the following properties:
  - GivenName
  - SurName
  - SamaccountName
  - Enabled
  - DistinguishedName
  - UserPrincipalName
  - Description
  - GroupName
  - Path

.EXAMPLE
  $Groups = @(
    'USA-GBL Member Server Administrators'
  )

  Get-ADGroupMemberships -Groups $Groups -Export -Extension csv -ReportName 'Server_admins' -ReportPath 'C:\Temp\'

  This example retrieves the group memberships for the specified groups and exports the results to a CSV file named 'Server_admins_MM-dd-yyyy.csv' in the 'C:\Temp\' directory.

#>

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
USA-GBL ISI-Data GHUB_Development Modify
USA-GBL ISI-Data GHUB_Development Read
USA-GBL ISI-Data GHUB_Test Modify
USA-GBL ISI-Data GHUB_Test Read
'@ -split [System.Environment]::NewLine

Write-Host "$(Get-Date)"

Get-ADGroupMemberships -Groups $Groups -Export -Extension csv

