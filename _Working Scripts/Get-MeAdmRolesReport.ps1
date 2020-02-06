Function Get-RolesReport {
    Param (
        [int]$Tier = 3,
        [string]$OutDir = $ENV:TEMP,
        [string]$OutFile = "RolesReport-$((Get-Date).ToString("MM.dd.yy-HHmmss")).csv"
    )

    if ($Tier -eq 3) {
        $filt = "adm*-*"
    }
    else {
        $filt = "adm*-$($Tier)"
    }

    $users = Get-ADUser -Filter {samaccountname -like $filt -and enabled -eq $true} -Properties memberof -Server 'me.sonymusic.com'

    $output = New-Object System.Collections.ArrayList

    foreach ($u in $users) {
        switch -Wildcard ($u.name) {
            "adm*-2" {$admtier = "Tier-2"}
            "adm*-1" {$admtier = "Tier-1"}
            "adm*-0" {$admtier = "Tier-0"}
        }

        $groups = @()
        foreach ($g in $u.memberof) {
            $groups += (Get-ADGroup -Identity $g -Server 'me.sonymusic.com').name
        }

        $PSObj = [PSCustomObject]@{
            ADMTier            = "$admtier"
            Name               = "$($u.givenname) $($u.surname)"
            UserName           = "$($u.name)"
            RoleAssignments    = "$((@($groups | Where-Object {$_ -like "*-Role"}) | out-string).trim())"
            NonRoleAssignments = "$((@($groups | Where-Object {$_ -notlike "*-Role" -and $_ -notlike "Admin_Tier-*_Users" -and $_ -notlike "tier-0_Users"}) | Out-String).trim())"
            InTierGroup        = "$(if($groups | Where-Object {$_ -like "Admin_Tier-*_Users" -or $_ -like "Tier-0_Users"}){$true}else{$false})"
        }
        [void]$output.Add($PSObj)
    }

    $output | Export-Csv "$($OutDir)\$($OutFile)" -NoTypeInformation
    Invoke-Item $OutDir
}

Get-RolesReport -Tier 3 -OutDir d:\Temp