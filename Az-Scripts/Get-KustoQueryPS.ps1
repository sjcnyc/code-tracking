Connect-AzAccount

# Log Analyitics Workspace Id
[string]$WorkspaceID = 'befe52e2-e148-4bd2-8445-1e977749a9c6'

# Kusto query in here string
$lawQuery = @'
let Events = WVDConnections;
Events
| where TimeGenerated > ago(7d)
| where State == "Connected"
| project CorrelationId, SessionHostName, UserName, ResourceAlias , StartTime=TimeGenerated
| join (Events
| where State == "Completed"
| project EndTime=TimeGenerated, CorrelationId)
on CorrelationId
| project StartTime, EndTime, Duration = EndTime - StartTime, UserName, SessionHostName
| sort by StartTime asc

'@ # need the blank space above in the here string

$Results = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $lawQuery

$Results.Results | Export-Csv -Path D:\Temp\sessions_2.csv