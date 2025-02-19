$group = 'WWI-CrashPlan-Americas Users'

 $group | Get-QADGroup  | ForEach-Object { $_ | 
Get-QADGroupMember |
Select-Object -Property Name,Description | 
Add-Member -MemberType NoteProperty -Name GroupName -Value $_.Name -PassThru } | 
Format-Table -GroupBy GroupName  -AutoSize