[CmdletBinding(SupportsShouldProcess = $true)]
Param()

Import-Module -Name ActiveDirectory -Verbose:$false

function Remove-UsersFromGroup 
{
  param(
    [Parameter(Mandatory = $true)][string]$group,
    [Parameter(Mandatory = $true)][string]$user
  )
  try
  {
    Remove-ADGroupMember -Identity $group -Members $user
  }
  catch
  {
    ('Error: {0}' -f $_)
  }
}

$group = 'WWI-O365-LinkSwapEnabled'

#(Import-Csv "$env:HOMEDRIVE\temp\imput.csv").SAMAccountName | 

@'

'@ -split [environment]::NewLine | 

ForEach-Object -Process {
  Remove-UsersFromGroup -group $group -user $_
}