$mbxs =@"
<samaccountnames goes here
"@ -split [System.Environment]::NewLine

$mbxs | Where-Object {$_ -ne $null} -PipelineVariable mbx1 |

ForEach-Object -Process {

    Get-QADUser -Identity $_ -Service 'mnet.biz' | Get-QADMemberOf -Service 'mnet.biz' | Select-Object @{N='SharedMBX'; E={$mbx1}}, SamAccountName, DisplayName | Export-Csv C:\Temp\_sharedMBXs\report001.csv -Append -NoTypeInformation

}