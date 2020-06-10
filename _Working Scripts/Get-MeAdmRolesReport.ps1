using namespace System.Collections.Generic

function Get-RolesReport {
    [CmdletBinding()]
    Param (
        [int]
        $Tier = 3,

        [string]
        $OutDir = $ENV:TEMP,

        [string]
        $OutFile = "RolesReport-$((Get-Date).ToString("MM.dd.yy-HHmmss")).csv"
    )

    $Tier -eq '3' ? ($Filter = "adm*-*") : ($Filter = "adm*-$($Tier)")

    $getADUserSplat = @{
        Properties = 'MemberOf', 'Lastlogontimestamp', 'Enabled'
        Filter     = { sAMAccountName -like $Filter -and Enabled -eq $true }
    }

    $Users = Get-ADUser @getADUserSplat

    $Output = [List[PSObject]]::new()

    foreach ($User in $Users) {
        switch -Wildcard ($User.Name) {
            "adm*-2" { $admtier = "Tier-2" }
            "adm*-1" { $admtier = "Tier-1" }
            "adm*-0" { $admtier = "Tier-0" }
        }

        $Groups = @()
        $Groups = foreach ($Group in $User.memberOf) {
            (Get-ADGroup -Identity $Group).Name
        }

        $PsObj = [PSCustomObject]@{
            ADMTier            = "$admtier"
            Name               = "$($User.givenName) $($User.surName)"
            UserName           = "$($User.Name)"
            RoleAssignments    = "$((@(($Groups).Where{$_ -like "*-Role"}) | Out-String).trim())"
            NonRoleAssignments = "$((@(($Groups).Where{$_ -notlike "*-Role" -and $_ -notlike "Admin_Tier-*_Users" -and $_ -notlike "tier-0_Users"}) | Out-String).trim())"
            InTierGroup        = (($Groups).Where{ $_ -like "Admin_Tier-*_Users" -or $_ -like "Tier-0_Users" }) ? $true : $false
            LastLogonTimeStamp = ([datetime]::FromFileTime($User.LastLogonTimestamp))
            Enabled            = "$($User.Enabled)"
        }
        [void]$Output.Add($PsObj)
    }

    $Output | Export-Csv "$($OutDir)\$($OutFile)" -NoTypeInformation
    #Invoke-Item $OutDir
}

Get-RolesReport