<#
  .SYNOPSIS
  Get-ADMap will create a visual representation of your AD structure
  .DESCRIPTION
  Get-ADMap will create a visual representation of the Container and Organizational Unit structure within your Active Directory Domain starting from the root, or from a specified OU.
  .PARAMETER OU
  Represents the OU that you would like to start the mapping from.
  .PARAMETER Name
  A switch to toggle between outputting distinguished names and just names of OUs and containers
  .EXAMPLE
  Get-ADMap
	
  This will return a mapping of AD starting at the root, ouputting distinguished names.
  .EXAMPLE
  Get-ADMap "OU=Users,DC=Contoso,DC=local" -name
	
  This will return a mapping of AD starting at "OU=Users,DC=Contoso,DC=local", ouputting names.
  .OUTPUTS
  Ex. ouput:
  DC=Contoso,DC=local
  | --- Computers
  | ------ Local
  | ------ Remote
  | --- Users
  | ------ Local
  | ------ Remote
  .NOTES
  Author: Twon Of An
  .LINK
  ActiveDirectory
#>
Function Get-ADMap
{
  Param
  (
    $OU
    ,
    [switch]$names
  )
  Import-Module ActiveDirectory
  If(!($OU))
  {
    [string[]]$temp = (Get-ADOrganizationalUnit -filter * -ResultSetSize 1).distinguishedname.split(',')
    [string]$OU = $($temp[$temp.count-2]) + ',' + $($temp[$temp.count-1])
  }
  If($ou.distinguishedname)
  {
    $depth = $ou.distinguishedname.split(',').count - 2
  }
  Else
  {
    $depth = -1
  }
  If(($depth -gt 0))
  {
    If($names)
    {
      Write-Host '|'('-' * $Depth * 4) $OU.name
    }
    Else
    {
      Write-Host '|'('-' * $Depth * 3) $OU.distinguishedname
    }
  }
  Else
  {
    $OU
  }
  If($tmp = Get-ChildItem AD:"$OU" | Where-Object{($_.objectclass -eq 'container') -or ($_.objectclass -eq 'organizationalUnit') -and ($_.distinguishedname -notlike '*-*-*-*-*')})
  {
    ForEach($child in $tmp)
    {
      If($names)
      {
        Get-ADMap $child -name
      }
      Else
      {
        Get-ADMap $child
      }
    }
  }
}