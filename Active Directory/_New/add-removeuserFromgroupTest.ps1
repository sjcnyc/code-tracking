[CmdletBinding(SupportsShouldProcess=$True)]
Param()

Import-Module -Name ActiveDirectory -Verbose:$false
function Start-UsersGroupOperation 
{
[CmdletBinding(SupportsShouldProcess=$True)]
  param(
    [Parameter(Mandatory)][ValidateSet("AddMember", "RemoveMember")]$option,
    [Parameter(Mandatory)][string]$group,
    [Parameter(Mandatory)][string]$user,
    [string]$server="NYCSMEADS0012"
  )
  try
  {
    if ($option -eq 'AddMember') {
      Add-ADGroupMember -Server $server -Identity $group -Members $user -Confirm:$false
      Write-Verbose -Message "Adding user $($user) to $($group)"
    }
    elseif ($option -eq 'RemoveMember'){
      Remove-ADGroupMember -Server $server -Identity $group -Members $user -Confirm:$false
      Write-Verbose -Message "Removing user $($user) from $($group)"
    }
  }
  catch
  {
    ('Error: {0}' -f $_)
  }
}