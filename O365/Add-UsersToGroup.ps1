[CmdletBinding(SupportsShouldProcess = $true)]
Param()

Import-Module -Name ActiveDirectory -Verbose:$false

function Add-UsersToGroup 
{
  param(
    [Parameter(Mandatory = $true)][string]$group,
    [Parameter(Mandatory = $true)][string]$user
  )

  #Add-QADGroupMember -Identity $group -Member $user
  Add-ADGroupMember -Identity $group -Members $user
  
  $a = (Get-Host).PrivateData
  $a.VerboseForegroundColor = 'Green'

  Write-Verbose -Message ('Added {0} to: {1}' -f ($_), ($group))
}

$group = 'WWI-O365-LinkSwapEnabled'
#$group = '_sjc_test_group'

#(Import-Csv "$env:HOMEDRIVE\temp\imput.csv").SAMAccountName | 

@'
BACC003
DEGU007
lpalm01
lmarand
tdelgro
DIST011
gmartin
'@ -split [environment]::NewLine | 

ForEach-Object -Process {
  $user = $_
  
  try 
  {
    Add-UsersToGroup -group $group -user $_
  }
  catch 
  {
    [Management.Automation.ErrorRecord]$e = $_

    $info = [pscustomobject] @{
      Exception = $e.Exception.Message
    }

    $a = (Get-Host).PrivateData
    $a.VerboseForegroundColor = 'Red'

    Write-Verbose -Message ('{0} already member of {1}' -f ($user), ($group))
  }
}