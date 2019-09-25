using namespace System.Collections.Generic

$AutomationPSCredentialName = "T2_Cloud2_Cred"

$Credential = Get-AutomationPSCredential -Name $AutomationPSCredentialName

Connect-MsolService -Credential $Credential -ErrorAction SilentlyContinue

$PSSessionSplat = @{
    Credential        = $Credential
    ConnectionUri     = 'https://outlook.office365.com/powershell-liveid'
    AllowRedirection  = $true
    Authentication    = 'Basic'
    ConfigurationName = 'Microsoft.Exchange'
}
$Session = New-PSSession @PSSessionSplat

[void](Import-PSSession -Session $Session -DisableNameChecking:$true -AllowClobber:$true)

function Get-RecentGroups {
  Param(
    [int]
    $Days = 1
  )

  $FromDate = (Get-Date).AddDays(-$Days).ToString('MM/dd/yyyy')
  $Groups = Get-UnifiedGroup -Filter "WhenCreated -gt '$FromDate'" | Select-Object ExternalDirectoryObjectId, DisplayName, AccessType, WhenCreated

  $PSList = [List[PSObject]]::new()

  foreach ($Group in $Groups) {

    $SelectSplat = @{
      Property = 'Name', 'PrimarySmtpAddress', 'CountryOrRegion', 'City', 'Department'
    }
    $Owners  = Get-UnifiedGroupLinks -Identity $Group.ExternalDirectoryObjectId -LinkType Owners | Select-Object @SelectSplat
    $Members = Get-UnifiedGroupLinks -Identity $Group.ExternalDirectoryObjectId -LinkType Members | Select-Object @SelectSplat

    $PSObject = [pscustomobject] @{
      Group         = $Group.DisplayName
      AccessType    = $Group.AccessType
      WhenCreated   = $Group.WhenCreated
      OwnersName    = $Owners.Name
      OwnersSMTP    = $Owners.PrimarySmtpAddress
      OwnersCount   = ($Owners | Measure-Object).Count
      MembersSMTP   = $Members.PrimarySmtpAddress
      MemberCount   = ($Members | Measure-Object).Count
      OwningCountry = $Owners.CountryOrRegion | Select-Object -First 1
    }

    [void]$PSList.Add($PSObject)
  }

  Write-Output $PSList
}

Get-RecentGroups -Days 10