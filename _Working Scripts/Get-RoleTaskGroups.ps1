function Get-RoleTaskGroups {
  [CmdletBinding()]
  param (
    [string]$ServerName = "me.sonymusic.com",
    [array]$RoleGroups
  )

  foreach ($Role in $RoleGroups) {
    $getADGroupSplat = @{
        Properties       = 'Name', 'DistinguishedName', 'CanonicalName'
        PipelineVariable = 'Role1'
        Server           = $ServerName
        Identity         = $Role
    }
    Get-ADGroup @getADGroupSplat | Get-ADPrincipalGroupMembership -Server $ServerName |
    Select-Object  @{N = "Role"; E = { $role1.Name } }, Name, @{N = "ParentContainer"; E = { $($role1.CanonicalName.Replace("$($ServerName)/","")) } }
  }
}

Get-RoleTaskGroups -RoleGroups "T1_G_Country_AP_TWN_Local-IST-Role"