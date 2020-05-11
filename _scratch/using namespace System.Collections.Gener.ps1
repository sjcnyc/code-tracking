using namespace System.Collections.Generic

$List = [List[PSObject]]::new()

$role = Get-RoleGroup
foreach ($Group in $role) {

  $obj = [pscoustomobject]@{
    name = $group.name
    Admin = Get-RoleGroupMember -Identity $name | Select-Object Name
  }
  [void]$list.Add($obj)
}

$list