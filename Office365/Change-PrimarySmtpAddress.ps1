Param
(
[Parameter(Mandatory=$true)]
[string]$oldDomain,
[Parameter(Mandatory=$true)] 
[string]$newDomain
)

$script:nl = "`r`n"
Clear-host
$error.Clear()
$countErr = 0
$countMbxs = 0
$timeStamp = get-date -f yyyy_MM_dd_hh_mm
$logFile = "logsmtp-" + $Timestamp + ".txt"

# Log header
"OLD,NEW" | Out-File $logFile 

# Mailbox collection
$mailboxes = @(get-mailbox -ResultSize unlimited | Where-Object {$_.PrimarySmtpAddress -like "*@$oldDomain" -and $_.RecipientTypeDetails -eq "UserMailbox"})

# Check if accepted domain exists in the organization
if (([bool](Get-AcceptedDomain -errorAction SilentlyContinue | Where-Object {$_.DomainName -eq $newDomain})) -eq $false)
    {
    Write-warning "Cannot find an accepted domain for: $newDomain"
    "Cannot find an accepted domain for: $newDomain" | out-file $logFile -append
    $countErr++
    }

# Check if no users uses the former domain name in primary smtp address
elseif (!$mailboxes.count)
    {
     write-warning "Cannot find any mailbox with primary smtp domain $oldDomain"
     "Cannot find any mailbox with primary smtp domain $oldDomain" | out-file $logFile -append
    }

# Start processing
else
    {
    write-host "Processing..." -foregroundColor Green
    foreach ($mbx in $mailboxes)

        {
        $error.clear()
        $count = $error.Count
        $smtp = $mbx.PrimarySmtpAddress
        $oldSmtp = $smtp.ToString()
        $alias = $smtp.Local
        $newSmtp = "$alias@$newDomain"

        $log = "$oldSmtp,$newSmtp"

        # Set new primary SMTP address using old local part and new domain
        Set-Mailbox $mbx -PrimarySmtpAddress $newSMTP -confirm:$false -EmailAddressPolicyEnabled $false

        if ($error.Count -ne $count)
		       
        	{
		    [string]$problema = $error[0].Exception
		    write-host $problema
		    $problema | out-file $logFile -Append
		    $countErr = 1
		    }
        else
            {
            $log | out-file $logFile -Append
            write-host $log
            $countMbxs++
            }
        } # close foreach
    } # close else

if ($countErr -ne 0)
    {
     write-warning "The process finished with errors"
    }

else
    {
    $nl
    write-host "The process finished succesfully" -ForegroundColor Cyan
    }
write-host "$countMbxs mailboxes processed" -ForegroundColor Cyan
$location = Get-Location
write-host "Saved log location: $location\$logFile" -ForegroundColor Cyan
