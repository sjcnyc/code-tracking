$PSArrayList = New-Object -TypeName System.Collections.ArrayList

Get-ADGroup -Server 'mnet.biz' -Filter {Name -Like "*GDL*"} -Prop member, DisplayName, Name -PipelineVariable gr  | ForEach-Object {
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

$PSArrayList | Export-Csv -Path C:\Temp\Nested_dls2.csv -NoTypeInformation
