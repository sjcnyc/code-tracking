Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

$CSVFile = "d:\temp\Auditlogs_$(Get-Date -f dd-MM-yyyy-hhmmss).csv"

# https://docs.microsoft.com/en-us/microsoft-365/compliance/search-the-audit-log-in-security-and-compliance?view=o365-worldwide#file-and-page-activities

$searchUnifiedAuditLogSplat = @{
    StartDate  = (Get-Date).AddDays(-4)
    EndDate    = (Get-Date)
    Operations = @('PageViewed','FileAccessed','FileDownloaded','FileDeleted')
    ResultSize = 5000
    ObjectIds  = @("https://sonymusicentertainment.sharepoint.com/sites/Teams_LA_BRA_OpsDigitais/*")
}

$FileAccessLog = Search-UnifiedAuditLog @searchUnifiedAuditLogSplat

$FileAccessLog.auditdata | ConvertFrom-Json | Select-Object CreationTime, UserId, Operation, ObjectID, SiteUrl, SourceFileName, ClientIP |
    Export-Csv $CSVFile -NoTypeInformation -Force -Append