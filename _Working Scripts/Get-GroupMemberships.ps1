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
    [System.String]$ReportPath = "D:\Temp\",

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
GTL-ADA Juniper SSL 105 Music
GTL-ADA Juniper SSL Arvato Dev
GTL-ADA Juniper SSL BMG Rights
GTL-ADA Juniper SSL CMG Restricted Access
GTL-ADA Juniper SSL Coyo
GTL-ADA Juniper SSL Gieman Restricted Access
GTL-ADA Juniper SSL Hanse Orga
GTL-ADA Juniper SSL Italy ExtCon
GTL-ADA Juniper SSL Italy ExtCon2
GTL-ADA Juniper SSL KSF Kiev
GTL-ADA Juniper SSL Licensee users
GTL-ADA Juniper SSL Munich Online
GTL-ADA Juniper SSL Munich WiPro
GTL-ADA Juniper SSL Token Users
GTL-ADA Juniper SSL UK WMW
GTL-ADA Juniper SSL Universum Film
GTL-ADA Juniper SSL users
HKG-APRO Juniper SSL DADC Users
HKG-APRO Juniper SSL HK AS400
HKG-APRO Juniper SSL India AS400
HKG-APRO Juniper SSL Users
WWI-Juniper-SSL-Asia Pacific Users
WWI-Juniper-SSL-BitTitanUsers
WWI-Juniper-SSL-CenturyMediaUsers
WWI-Juniper-SSL-CulverCityLot
WWI-Juniper-SSL-DADC-ACCT-MGT
WWI-Juniper-SSL-DADC-Media-Prod
WWI-Juniper-SSL-European Users
WWI-Juniper-SSL-Latin Users
WWI-Juniper-SSL-North America Users
WWI-Juniper-SSL-North America-Pulsar Users
WWI-Juniper-SSL-OrchardUsers
WWI-US-Juniper SSL VPN Token Users
WWI-US-Juniper SSL VPN UltraMusic Token Users
WWI-US-Juniper SSL VPN Users
WWI-US-Juniper SSL VPN Users SonyMusicCentralONLY
"@ -split [System.Environment]::NewLine

Get-ADGroupMemberships -Groups $Groups -Domain BMG -Export -Extension csv