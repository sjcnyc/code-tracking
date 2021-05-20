Get-QADGroupMember -Identity 'WWI-Crashplan-Americas Users' | Select-Object SamaccountName, Name, ParentContainer | Export-Csv -Path C:\TEMP\crashPlan_users.csv -NoTypeInformation

(Get-QADGroupMember -Identity 'WWI-Crashplan-Americas Users').count