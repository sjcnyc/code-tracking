function Get-OuUserCounts {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
  [CmdletBinding(SupportsShouldProcess = $true)]
  param(
    [parameter(Mandatory = $true, Position = 0)]
    [System.String]
    $SearchBase,

    [parameter(Mandatory = $true, Position = 1)]
    [System.String]
    $Filter,

    [parameter(Mandatory = $true, Position = 2)]
    [System.String]
    $Server
  )

  $ADOrgSplat = @{
    SearchScope = 'SubTree'
    Server      = $Server
    LDAPFilter  = "(name=$Filter)"
    SearchBase  = $SearchBase
    Properties  = 'Distinguishedname', 'CanonicalName'
  }
  Get-ADOrganizationalUnit @ADOrgSplat | ForEach-Object {

    $Count = (Get-ADObject -SearchBase $_.DistinguishedName -Server $Server -Filter *).Count
    $psobj = [PSCustomObject]@{
      OrganizationalUnit = $_.CanonicalName.Replace("$Server/", "")
      UserCount          = ($Count |Out-String).Trim()
    }
    $psobj
  }
}

Get-OuUserCounts -SearchBase 'OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com' -Filter '*Employees' -Server 'me.sonymusic.com'