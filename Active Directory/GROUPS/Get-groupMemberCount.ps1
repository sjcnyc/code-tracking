Function Get-GroupMemberCount {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [string[]]$searchRoot,
        [string[]]$filter,
        [string]$path,
        [string]$filename,
        [switch]$export
    )
    BEGIN {
        $scriptblock = Get-QADGroup -SizeLimit 0 -SearchRoot "bmg.bagint.com/$($searchRoot)" |
            Where-Object { $_.samaccountname -notmatch "^*$($filter)*"} |
            Select-Object Name, `
        @{n = 'MemberCount'; e = { (Get-QADGroupMember $_ -SizeLimit 0 | Measure-Object).Count}}, `
        @{n = 'MemberOfCount'; e = { ((Get-QADGroup $_).MemberOf | Measure-Object).Count}}
    }
    PROCESS {
        if ($export) {
            $scriptblock | Export-Csv $path\$filename.csv -NoTypeInformation
        }
        else {
            $scriptblock
        }
    }
    END {}
}


Get-GroupMemberCount -searchRoot 'bvh' -filter 'ISI' -path 'c:\temp' -filename 'nas'