using namespace System.Collections.Generic
Connect-EXOService

$List = [List[PSObject]]::new()

foreach ($RoleGroup in (Get-RoleGroup)) {
  $RoleGroupMembers = Get-RoleGroupMember -Identity $RoleGroup.Name
  foreach ($Member in $RoleGroupMembers) {1
    $PsObject = [pscustomobject]@{
      RoleGroup = $RoleGroup.Name
      User      = $Member
    }
    [void]$List.Add($PsObject)
  }
}

$List | Select-Object User, RoleGroup | Export-Csv c:\temp\UserRoleGroups.csv -NoTypeInformation