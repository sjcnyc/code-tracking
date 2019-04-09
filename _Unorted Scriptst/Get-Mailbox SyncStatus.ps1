$now = Get-Date	
$report = @()
$age = '90'

$stats = @('DeviceID',
    'DeviceAccessState',
    'DeviceAccessStateReason',
    'DeviceModel'
    'DeviceType',
    'DeviceFriendlyName',
    'DeviceOS',
    'LastSyncAttemptTime',
    'LastSuccessSync'
)

Write-Host 'Fetching list of mailboxes with EAS device partnerships'

$MailboxesWithEASDevices = @(Get-CASMailbox -Resultsize Unlimited | Where-Object {$_.HasActiveSyncDevicePartnership})

Write-Host "$($MailboxesWithEASDevices.count) mailboxes with EAS device partnerships"

Foreach ($Mailbox in $MailboxesWithEASDevices) {
    
    $EASDeviceStats = @(Get-ActiveSyncDeviceStatistics -Mailbox $Mailbox.Identity -WarningAction SilentlyContinue)
    
    Write-Host "$($Mailbox.Identity) has $($EASDeviceStats.Count) device(s)"

    $MailboxInfo = Get-Mailbox $Mailbox.Identity | Select-Object DisplayName, PrimarySMTPAddress, OrganizationalUnit
    
    Foreach ($EASDevice in $EASDeviceStats) {
        Write-Host -ForegroundColor Green "Processing $($EASDevice.DeviceID)"
        Write-Host $EASDevice.LastSyncAttemptTime
        $lastsyncattempt = ($EASDevice.LastSyncAttemptTime)

        if ($lastsyncattempt -eq $null) {
            $syncAge = 'Never'
        }
        else {
            $syncAge = ($now - $lastsyncattempt).Days
        }

        if ($syncAge -ge $age -or $syncAge -eq 'Never') {
            Write-Host -ForegroundColor Yellow "$($EASDevice.DeviceID) sync age of $syncAge days is greater than $age, adding to report"

            $reportObj = New-Object PSObject
            $reportObj | Add-Member NoteProperty -Name 'Display Name' -Value $MailboxInfo.DisplayName
            $reportObj | Add-Member NoteProperty -Name 'Organizational Unit' -Value $MailboxInfo.OrganizationalUnit
            $reportObj | Add-Member NoteProperty -Name 'Email Address' -Value $MailboxInfo.PrimarySMTPAddress
            $reportObj | Add-Member NoteProperty -Name 'Sync Age (Days)' -Value $syncAge
                
            Foreach ($stat in $stats) {
                $reportObj | Add-Member NoteProperty -Name $stat -Value $EASDevice.$stat
            }

            $report += $reportObj
        }
    }
}

Write-Host -ForegroundColor White 'Saving report to c:\temp\activesyncdevices.csv'
$report | Export-Csv -NoTypeInformation 'c:\temp\activesyncdevices.csv'