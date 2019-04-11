[CmdletBinding(SupportsShouldProcess)]
Param()

Import-Module -Name ActiveDirectory -Verbose:$false

#region Start-UsersGroupOperation
function Start-UsersGroupOperation 
{
  param(
    [Parameter(Mandatory)][ValidateSet('AddMember', 'RemoveMember')]$option,
    [Parameter(Mandatory)][string]$group,
    [Parameter(Mandatory)][string]$user,
    [string]$server = 'NYCSMEADS0012'
  )
  try
  {
    if ($option -eq 'AddMember') 
    {
      Add-ADGroupMember -Server $server -Identity $group -Members $user -Confirm:$false
      Write-Verbose -Message "Adding user $($user) to $($group)"
    }
    elseif ($option -eq 'RemoveMember')
    {
      Remove-ADGroupMember -Server $server -Identity $group -Members $user -Confirm:$false
      Write-Verbose -Message "Removing user $($user) from $($group)"
    }
  }
  catch
  {
    ('Error: {0}' -f $_)
  }
}
#endregion Start-UsersGroupOperation

#Vars
$server        = 'GTLSMEADS0010'
$addGroup      = 'WWI-O365-MigratedUsers'
$removeGroup   = 'WWI-O365-LinkSwapEnabled'
$airwatchGroup = 'CN=USA-GBL Airwatch MDM Users,OU=Restricted,OU=GRP,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com'

# (Import-Csv "$env:HOMEDRIVE\temp\imput.csv").SAMAccountName | 

#Users
@'
cmarsha
dabreuc
gball
jmontei
jduches
jdavies
nathuko
rnagle1
smorenc
sbarre
'@ -split [environment]::NewLine | 

ForEach-Object -Process {
  Start-UsersGroupOperation -option AddMember -group $addGroup -user $_ -server $server
  Start-UsersGroupOperation -option RemoveMember -group $removeGroup -user $_ -server $server
  
  #Airwatch 
  if (-not (Get-QADUser -Identity $_).MemberOf -eq $airwatchGroup) 
  {
    Start-UsersGroupOperation -option AddMember -group $airwatchGroup -user $_ -server $server
  }
}