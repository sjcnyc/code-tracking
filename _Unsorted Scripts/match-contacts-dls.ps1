$users =@"
WindowsEmailAddress
digital.technologies@sonymusic.de
"@ -split [System.Environment]::NewLine

$users | Where-Object {$_ -ne $null} -PipelineVariable mbx1 |

ForEach-Object -Process {

    Get-QADObject -Type 'Contact' -Identity $_ -Service 'mnet.biz' | Get-QADMemberOf -Service 'mnet.biz' | Select-Object @{N='UserName'; E={$mbx1}}, SamAccountName, DisplayName | Export-Csv C:\Temp\report001.csv -Append -NoTypeInformation

}