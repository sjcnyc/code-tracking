function Copy-TaskGroups {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $SourceTaskGroup,

        [Parameter(Mandatory = $true)]
        [string]
        $TargetTaskGroup,

        [Parameter(Mandatory)]
        [ValidateSet("T0", "T1", "T2", "All")]
        [string]
        $Tier
    )

    if ($Tier -eq "All") {
        $Tiers = $null
    } else {
        $Tiers = "$Tier"
    }

    $Groups = Get-ADGroup -Filter "Name -like '*$($Tiers)*$($SourceTaskGroup)*'" -Properties Name, DistinguishedName | Where-Object { $_.DistinguishedName -like "*OU=Tasks,OU=Groups*" }
    $Groups.count

    $Output = foreach ($Group in $Groups) {

        [pscustomobject] @{
            Name = $Group.Name -replace "$($SourceTaskGroup)", "$($TargetTaskGroup)"
            DN   = ($Group.DistinguishedName -replace "$($SourceTaskGroup)", "$($TargetTaskGroup)") -replace '^CN=.+?(?<!\\),'
        }
    }

    #$Output

    foreach ($Group in $Output) {

        $newADGroupSplat = @{
            Path          = $Group.DN
            GroupCategory = 'Security'
            GroupScope    = 'DomainLocal'
            #Description  = 'Task Group'
            PassThru      = $true
            Verbose       = $true
            Name          = $Group.Name
        }

        New-ADGroup @newADGroupSplat -WhatIf
    }
}

#Copy-TaskGroups -SourceTaskGroup "Modify_Organization_Tab" -TargetTaskGroup "Modify_Extension_Attributes" -Tier T1