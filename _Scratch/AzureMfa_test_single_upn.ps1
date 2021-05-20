using namespace System.Collections.Generic

function Get-IsAzGroupmember {
  param (
    [string]
    $GroupObjectId,
    [string]
    $UserName
  )

  $g = New-Object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck
  $g.GroupIds = $GroupObjectId
  $User = (Get-AzureADUser -Filter "userprincipalname eq '$($Username)'").ObjectId
  $InGroup = Select-AzureADGroupIdsUserIsMemberOf -ObjectId $User -GroupIdsForMembershipCheck $g

  if ($InGroup -eq $GroupObjectId) {
    return $true
  }
  else {
    return $false
  }
}

$AutomationPSCredentialName = "t2_cloud_cred"
$Credential = Get-AutomationPSCredential -Name $AutomationPSCredentialName -ErrorAction Stop

Connect-MsolService -Credential $Credential -ErrorAction SilentlyContinue
Connect-AzureAD -Credential $Credential -ErrorAction SilentlyContinue

$output = Get-IsAzGroupmember -GroupObjectId $NoMfaGroup -UserName "sean.connealy.peak@sonymusic.com"

Write-Output -InputObject $output