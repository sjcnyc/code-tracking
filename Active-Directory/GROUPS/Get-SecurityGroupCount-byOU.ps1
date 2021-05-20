<#
    .SYNOPSIS

    .DESCRIPTION

    .NOTES
        File Name:             Get-SecurityGroupCount-byOU
        Author:                Sean Connealy
        Requires:              PowerShell Version 3.0
        Date:                  3/28/2014
    .LINK
        This script posted to:
            http://www.github/sjcnyc
#>

Get-QADGroup -SizeLimit 0 -SearchRoot 'bmg.bagint.com/USA/GBL/GRP/Non-Restricted/FileShare Access' |
    ForEach-Object {
    $count = (Get-QADGroupMember -SizeLimit 0 -Identity $($_.DN)).Count
    if ($count -eq $null) { $count = 0 }
    $data = [PSCustomObject] @{

        Name              = $($_.Name)
        DistinguishedName = $($_.DN)
        ParentContainer   = $_.parentcontainer
        MemberCount       = $count
    }
    $data | Select-Object Name, parentcontainer, Membercount
}
