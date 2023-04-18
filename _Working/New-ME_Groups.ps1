$Groups = @"
STG-SEP Royalties
STG-SEP Royalties Owner
STG-SEP Royalties - CO - R
STG-SEP Royalties - CO - RW
STG-SEP Royalties - SE - R
STG-SEP Royalties - SE - RW
STG-SEP Royalties - UI - R
STG-SEP Royalties - UI - RW
"@ -split [environment]::NewLine

foreach ($Group in $Groups) {

  $newADGroupSplat = @{
    Path          = "OU=Groups,OU=STG,OU=CHL,OU=LA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
    GroupCategory = 'Security'
    #GroupScope    = 'Global'
    Description   = 'Owner: Myriam Bilardu'
    PassThru      = $true
    Verbose       = $true
    Name          = $Group
  }

  New-ADGroup @newADGroupSplat
}