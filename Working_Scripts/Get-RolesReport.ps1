function Get-RolesReport {
  Param (
    [int]$Tier = 3,
    [string]$OutDir = "d:\temp",
    [string]$OutFile = "RolesReport-$((Get-Date).ToString("MM.dd.yy-HHmmss")).csv"
  )

  if ($Tier -eq 3) {
    $Filter = "adm*-*"
  }
  else {
    $Filter = "adm*-$($Tier)"
  }

  $getADUserSplat = @{
    Properties = 'MemberOf', 'Lastlogontimestamp', 'Enabled'
    Filter     = { sAMAccountName -like $Filter -and Enabled -eq $true }
  }

  $Users = Get-ADUser @getADUserSplat

  $Output = @()

  foreach ($User in $Users) {
    switch -Wildcard ($User.Name) {
      "adm*-2" { $admtier = "Tier-2" }
      "adm*-1" { $admtier = "Tier-1" }
      "adm*-0" { $admtier = "Tier-0" }
    }

    $Groups = @()

    foreach ($Group in $User.MemberOf) { $Groups += (Get-ADGroup -Identity $Group).Name }

    $Output += [PSCustomObject]@{
      ADMTier            = "$admtier"
      Name               = "$($User.GivenName) $($User.SurName)"
      UserName           = "$($User.Name)"
      RoleAssignments    = "$((@($Groups | Where-Object {$_ -like "*-Role"}) | Out-String).trim())"
      NonRoleAssignments = "$((@($Groups | Where-Object {$_ -notlike "*-Role" -and $_ -notlike "Admin_Tier-*_Users" -and $_ -notlike "tier-0_Users"}) | Out-String).trim())"
      InTierGroup        = ($Groups | Where-Object {$_ -like "Admin_Tier-*_Users" -or $_ -like "Tier-0_Users"}) ? $true : $false
      LastLogonTimeStamp = ([datetime]::FromFileTime($User.LastLogonTimestamp))
      Enabled            = "$($User.enabled)"
    }
  }

  $Output | Export-Csv "$($OutDir)\$($OutFile)" -NoTypeInformation
  Invoke-Item $OutDir
}

Get-RolesReport -Tier '3' -OutDir 'D:\Temp'