using namespace System.Collections.Generic

function Get-RolesReport {
  Param (
    [int]$Tier = 3,
    [string]$OutDir = "d:\temp",
    [string]$OutFile = "RolesReport-Tier-$($Tier)-$((Get-Date).ToString("MM.dd.yy-HHmmss")).csv"
  )

  $List = [List[PSObject]]::new()

  $Filter = ($Tier -eq 3) ? "adm*-*" : "adm*-$($Tier)" # Ternary Conditional Operator only works in v7.0

  $ADUserSplat = @{
    Properties = 'MemberOf', 'Lastlogontimestamp', 'Enabled'
    Filter     = { sAMAccountName -like $Filter -and Enabled -eq $true }
  }

  $Users = Get-ADUser @ADUserSplat

  foreach ($User in $Users) {
    switch -Wildcard ($User.Name) {
      "adm*-2" { $admtier = "Tier-2" }
      "adm*-1" { $admtier = "Tier-1" }
      "adm*-0" { $admtier = "Tier-0" }
    }

    foreach ($Group in $User.MemberOf) {
      $Groups = (Get-ADGroup -Identity $Group -Properties Name, ManagedBy |
        Select-Object Name, @{N = 'Manager'; E = { (Get-ADUser -Identity $_.managedBy -Properties Name).Name } })

      $RoleAssignment      = (($Groups).Where{ $_.Name -like "*-Role" }).Name
      $Manager             = (($Groups).Where{ $_.Name -like "*-Role" }).Manager
      $NonRoleAssignaments = (($Groups).Where{ $_.Name -notlike "*-Role" -and $_.Name -notlike "Admin_Tier-*_Users" -and $_.Name -notlike "tier-0_Users" }).Name
      $InTierGroup         = (($Groups).Where{ $_.Name -like "Admin_Tier-*_Users" -or $_.Name -like "Tier-0_Users" }) ? $true : $false

      $PsObj = [PSCustomObject]@{
        ADMTier            = $admtier
        Name               = "$($User.GivenName) $($User.SurName)"
        UserName           = $User.Name
        RoleAssignments    = $RoleAssignment
        ManagedBy          = $Manager
        NonRoleAssignments = $NonRoleAssignaments
        InTierGroup        = $InTierGroup
        LastLogonTimeStamp = ([datetime]::FromFileTime($User.LastLogonTimestamp))
        Enabled            = $User.enabled
      }
      [void]$List.Add($PsObj)
    }
  }
  $List | Export-Csv "$($OutDir)\$($OutFile)" -NoTypeInformation
}

Get-RolesReport -Tier '3' -OutDir 'D:\Temp'