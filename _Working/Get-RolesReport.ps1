using namespace System.Collections.Generic
function Get-RolesReport {
  param (
    [int]
    $Tier = 3,

    [string]
    $OutDir,

    [string]
    $OutFile = "RolesReport-Tier-$($Tier)-$((Get-Date).ToString('MM.dd.yy-HHmmss')).csv"
  )

  $List = [List[PSObject]]::new()

  $Filter = if ($Tier -eq 3) { 'adm*-*' } else { "adm*-$($Tier)" }

  $ADUserSplat = @{
    Properties = 'MemberOf', 'Lastlogontimestamp', 'Enabled'
    Filter     = { sAMAccountName -like $Filter -and Enabled -eq $true }
  }

  $Users = Get-ADUser @ADUserSplat

  foreach ($User in $Users) {
    switch -Wildcard ($User.Name) {
      'adm*-2' { $admtier = 'Tier-2' }
      'adm*-1' { $admtier = 'Tier-1' }
      'adm*-0' { $admtier = 'Tier-0' }
    }

    foreach ($Group in $User.MemberOf) {
      $Groups = (Get-ADGroup -Identity $Group -Properties Name, ManagedBy, DistinguishedName |
        Select-Object Name, DistinguishedName, @{N = 'Manager'; E = { (Get-ADUser -Identity $_.managedBy -Properties Name).Name } })

      $RoleAssignment = (($Groups) | Where-Object { $_.Name -like '*-Role' }).Name

      $Manager = (($Groups) | Where-Object { $_.Name -like '*-Role' }).Manager

      $NonRoleAssignaments = $Groups |
      Where-Object { $_.Name -notlike '*-Role' -and $_.Name -notlike 'Admin_Tier-*_Users' -and $_.Name -notlike 'tier-0_Users' } |
      Select-Object Name, DistinguishedName

      $InTierGroup = if (($Groups) |
        Where-Object { $_.Name -like 'Admin_Tier-*_Users' -or $_.Name -like 'Tier-0_Users' }) { $true } else { $false }

      if ($null -ne $NonRoleAssignaments) {
        switch -wildcard ($NonRoleAssignaments.DistinguishedName) {
          '*OU=NA*' { $owner = 'Moldoveanu, Alex' }
          '*OU=EU*' { $owner = 'Elgar, Pete' }
          '*OU=LA*' { $owner = 'Scherer, Pablo' }
          '*OU=AP*' {
            if ($NonRoleAssignaments.DistinguishedName -like '*AUS*' -or $NonRoleAssignaments.DistinguishedName -like '*NZL*') {
              $owner = 'McClung, Dustin'
            }
            else {
              $owner = 'Kwan, Ether'
            }
          }
          Default {}
        }
      }
      else {
        $owner = ''
      }

      $PsObj = $PsObj |
      Where-Object { $NonRoleAssignaments.Name -ne '' -and $RoleAssignments -ne '' }

      $PsObj = [pscustomobject]@{
        ADMTier            = $admtier
        Name               = "$($User.SurName), $($User.GivenName)"
        UserName           = $User.Name
        RoleAssignments    = $RoleAssignment
        ManagedBy          = $Manager
        NonRoleAssignments = $NonRoleAssignaments.Name
        ManagedBy2         = $owner
        InTierGroup        = $InTierGroup
        LastLogonTimeStamp = ([datetime]::FromFileTime($User.LastLogonTimestamp))
        Enabled            = $User.enabled
      }
      [void]$List.Add($PsObj)
    }
  }
  $List | Export-Csv "$($OutDir)\$($OutFile)" -NoTypeInformation
}

Get-RolesReport -Tier '3' -OutDir D:\temp\