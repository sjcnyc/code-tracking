$Groups = @"
GF_WORKFLOW_IT
GF_WORKFLOW_SUPPLY
GF_WORKFLOW_FINANCE
GF_WORKFLOW_DRH
GF_WORKFLOW_SG
GF_WORKFLOW_SGX
GF_WORKFLOW_COMM
GF_WORKFLOW_BA
"@ -split [environment]::NewLine

foreach ($Group in $Groups) {

  $newADGroupSplat = @{
    Path          = "OU=Groups,OU=PAR,OU=FRA,OU=EU,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
    GroupCategory = 'Security'
    GroupScope    = 'Global'
    Description   = 'Owner: Myriam Bilardu'
    PassThru      = $true
    Verbose       = $true
    Name          = $Group
  }

  New-ADGroup @newADGroupSplat
}