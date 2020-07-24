using namespace System.Management.Automation
using namespace System.DirectoryServices.ActiveDirectory

#OU=$($RegionOu)

class ValidOrgGenerator : IValidateSetValuesGenerator {
  [string[]] GetValidValues() {
    $RegionOu = ""
    $Values =
    ((Get-ADOrganizationalUnit -LDAPFilter '(name=*Employees*)' -SearchBase "OU=$($RegionOu),OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com" -SearchScope 'Subtree' -Properties 'CanonicalName').CanonicalName) -replace "me.sonymusic.com/Tier-2/STD/", ""
    return $Values
  }
}

function Get-TierOUs {
  [CmdletBinding(SupportsShouldProcess)]
  param (
    [parameter(Position = 0, Mandatory)]
    [ValidateSet([ValidOrgGenerator])]
    [string]
    $RegionOu,

    [parameter(Position = 1, Mandatory)]
    [ValidateSet([ValidOrgGenerator])]
    [string]
    $Country
  )

  if ($PSCmdlet.ShouldProcess("blah", "show selected OU")) {
    Write-Output "$($Country)"
  }
  else {
    Write-Output "nope"
  }
}
