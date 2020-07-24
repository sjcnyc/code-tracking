$s1 = (Import-CSV C:\Temp\DLs_1016csv.csv).ALIAS
#$s2 = (Import-CSV C:\Temp\Shared_mbx_1016.csv).ALIAS

#Join-Object -Left $s1 -Right $s2 -LeftJoinProperty Group -RightJoinProperty ALIAS -Type AllInBoth | Export-Csv c:\temp\mergedCSV5.csv -NoTypeInformation

#        Join-Object -Left $s1 -Right $s2 -LeftJoinProperty IP_ADDRESS -RightJoinProperty IP -Prefix 'j_' -Type AllInBoth |
#            Export-CSV $MergePath -NoTypeInformation



$s1 | Get-QADGroup -Service 'mnet.biz' -PipelineVariable grp |
    Get-QADGroupMember -Indirect -SizeLimit 0 |
    Select-Object -Property SamAccountName, DN, @{N = 'GroupName'; E = {$grp.SamAccountName}} | Export-Csv C:\Temp\groupmembers001.csv -NoTypeInformation



<# $DLs = (Import-Csv -Path C:\temp\DLs_1016csv.csv).ALIAS

$PSArrayList = New-Object -TypeName System.Collections.ArrayList

$dls | Get-ADGroup -Server 'mnet.biz' -Prop member, DisplayName, Name -PipelineVariable gr | ForEach-Object {
    $gr.member | Get-ADGroup -Server 'mnet.biz' -EA 0 -prop SamAccountName, DisplayName | ForEach-Object {

        $PsObj = [PSCustomObject]@{

            'Group'             = $gr.Name
            'DisplayName'       = $gr.DisplayName
            'Member'            = $_.SamAccountName
            'MemberDisplayName' = $_.DisplayName
        }
        $null = $PSArrayList.Add($PsObj)
    }
}

$PSArrayList | Export-Csv -Path C:\Temp\Nested_dls3.csv -NoTypeInformation #>