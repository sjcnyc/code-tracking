function Get-ADGroupMemberProperties {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Identity,
        [Parameter(Mandatory = $false)]
        $Properties
    )

    begin {
        $members = (Get-ADGroupMember -Identity $Identity).ObjectGUID
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