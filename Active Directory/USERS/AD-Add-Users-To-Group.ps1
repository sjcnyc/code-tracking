Import-Module -Name ActiveDirectory

$ErrorActionPreference = 'Continue'

# Point this to your csv file
$Filename = 'userlist.csv'

$Group = Read-Host -Prompt 'Enter the name of the group'

if ((Test-Path $Filename) -and ((Get-Item $Filename).length -gt 0kb)) 
{
  $Userlist = Import-Csv -Path $Filename | ForEach-Object -Process {
    $_.SamAccountName
  }

  ForEach ($User in $Userlist) 
  {
    Add-ADGroupMember $Group -Members $User

    Write-Verbose -Message 'User ' 
    Write-Verbose -Message $User 
    Write-Verbose -Message ' has been added to the following group: ' 
    Write-Verbose -Message $Group
  }

  Write-Verbose -Message 'All done'
}

else 
{
  Write-Verbose -Message 'CSV file is empty or not found' 
}


Add-ADGroupMember -Identity '' -Members ''