function Get-ADGroupMemberProperties {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Group,
        [Parameter(Mandatory = $false)]
        $Properties
    )

    begin {
        $members = (Get-ADGroupMember -Identity $Group).ObjectGUID
    }

    process {
        foreach ($member in $members) {
        
            $params = @{
                'Identity' = $member
            }

            if ($PSBoundParameters.ContainsKey('Properties')) {
                $params.Add('Properties', $Properties)
            }

            Get-ADUser @params
        }
    }

    end {
    }
}