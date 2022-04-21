$UltraGroups = @'
USA-GBL ISI UltraMusic$ Users
USA-GBL ISI UltraMusic$ Admins
USA-GBL ISI UltraMusic$ Ultra_Legal_Dept_Docs_Dropbox_Snapshot
USA-GBL ISI UltraMusic$ Ultra_Record_Maestro_Server
USA-GBL ISI UltraMusic$ Audio
USA-GBL ISI UltraMusic$ Label Copy
USA-GBL ISI UltraMusic$ Remix Parts USE
USA-GBL ISI UltraMusic$ Artwork
USA-GBL ISI UltraMusic$ A&R
USA-GBL ISI UltraMusic$ Accounting
USA-GBL ISI UltraMusic$ Agreements
USA-GBL ISI UltraMusic$ Approved Ultra Assets
USA-GBL ISI UltraMusic$ Copyright Registrations
USA-GBL ISI UltraMusic$ Cover Art Audio Videos
USA-GBL ISI UltraMusic$ Finance
USA-GBL ISI UltraMusic$ HR
USA-GBL ISI UltraMusic$ IDEAS
USA-GBL ISI UltraMusic$ Incoming Royalty Statements
USA-GBL ISI UltraMusic$ International
USA-GBL ISI UltraMusic$ LABEL COPY VIDEOS
USA-GBL ISI UltraMusic$ Legal Template Agreements
USA-GBL ISI UltraMusic$ LegalAndFinance
USA-GBL ISI UltraMusic$ Licensing Speadsheets
USA-GBL ISI UltraMusic$ Marketing
USA-GBL ISI UltraMusic$ Misc Legal Word Docs
USA-GBL ISI UltraMusic$ New Media
USA-GBL ISI UltraMusic$ Resume Bank
USA-GBL ISI UltraMusic$ Sales
USA-GBL ISI UltraMusic$ Team Projects
USA-GBL ISI UltraMusic$ Trademark Registrations-Filings
USA-GBL ISI UltraMusic$ Ultra Docs
USA-GBL ISI UltraMusic$ Ultra Release Schedule
USA-GBL ISI UltraMusic$ Video Docs
USA-GBL ISI UltraMusic$ Ultra Legal Dept Docs Digital
'@ -split [environment]::NewLine

$UserNames = @("CHIN023","")

foreach ($Group in $UltraGroups) {
    Add-ADGroupMember -Identity $Group -Member $UserNames -WhatIf
}