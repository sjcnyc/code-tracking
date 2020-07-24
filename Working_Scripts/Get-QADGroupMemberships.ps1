function Get-QADGroupMemberships {
  Param(
    [parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $true, Position = 0)]
    [array]$Groups,

    [parameter(Mandatory = $true, Position = 1)]
    [ValidateSet("BMG", "ME")]
    [string]$Domain,

    [parameter(Position = 2)]
    [switch]$Export,

    [parameter(Position = 3)]
    [string]$ReportPath = "C:\Temp\",

    [parameter(Position = 4)]
    [string]$ReportName = "Report",

    [parameter(Position = 5)]
    [string]$ReportDate = "_$(get-date -F 'MM-dd-yyy')",

    [parameter(Position = 6)]
    [ValidateSet("csv", "pdf")]
    [string]$Extension
  )

  try {
    $obj = $Groups | Get-QADGroup -Service $Domain -PipelineVariable grp | Get-QADGroupMember -Indirect -Sizelimit 0 |
      Select-Object -Property FirstName, LastName, SamAccountName, DN, @{N = 'GroupName'; E = {$grp.SamAccountName}}
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