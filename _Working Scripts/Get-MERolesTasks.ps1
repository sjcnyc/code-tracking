$Server = "me.sonymusic.com"

$getADObjectSplat = @{
  Filter     = { Name -eq "Roles" }
  Properties = 'CanonicalName', 'DistinguishedName'
  Server     = $Server
}
$RolesOUS = Get-ADObject @getADObjectSplat | Select-Object CanonicalName, DistinguishedName

$Roles = foreach ($RoleOU in $RolesOUS) {
  $RoleCN = $RoleOU.CanonicalName
  $getADObjectSplat = @{
    Filter     = { ObjectClass -eq "Group" }
    Server     = $Server
    SearchBase = $RoleOU.DistinguishedName
  }
  Get-ADObject @getADObjectSplat | Select-Object Name, DistinguishedName |
  Add-Member -MemberType NoteProperty -Name CanonicalName -Value $RoleCN -PassThru
}

$Tasks = foreach ($Role in $Roles) {
  $RoleCN1 = $Role.CanonicalName
  $getADGroupSplat = @{
    Server           = $Server
    PipelineVariable = 'Role'
    Identity         = $Role.DistinguishedName
  }
  Get-ADGroup @getADGroupSplat | Get-ADPrincipalGroupMembership -Server $Server |
  Select-Object @{N = "Role"; E = { $Role.Name } }, Name |
  Add-Member -MemberType NoteProperty -Name ParentContainer -Value $($RoleCN1.Replace("$($Server)/", "")) -PassThru
}

$Tasks | Export-Csv D:\Temp\Role_task.csv -NoTypeInformation