function Get-ADGroupMemberships {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param(
    [parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $true, Position = 0)]
    [System.Array]$Groups,

    [parameter(Mandatory = $true, Position = 1)]
    [ValidateSet("BMG", "ME")]
    [System.String]$Domain,

    [parameter(Position = 2)]
    [System.Management.Automation.SwitchParameter]$Export,

    [parameter(Position = 3)]
    [System.String]$ReportPath = "C:\Temp\",

    [parameter(Position = 4)]
    [System.String]$ReportName = "Report",

    [parameter(Position = 5)]
    [System.String]$ReportDate = "_$(get-date -F 'MM-dd-yyy')",

    [parameter(Position = 6)]
    [ValidateSet("csv", "pdf")]
    [System.String]$Extension
  )

  try {
    switch ($Domain) {
      BMG {"bmg.bagint.com"};
      ME  {"me.sonymusic.com"}
    }
    $obj = $Groups | Get-ADGroup -Server $Domain -PipelineVariable Grp -Properties Name | Get-ADGroupMember |
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
USA-GBL ISI-Data DROYALTY
"@ -split [System.Environment]::NewLine

Get-ADGroupMemberships -Groups $Groups -Domain ME -Export -Extension csv