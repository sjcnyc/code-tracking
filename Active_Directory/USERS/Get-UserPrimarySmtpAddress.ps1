$PSArrayList = New-Object -TypeName System.Collections.ArrayList
@"
abalasanyan
ABDE029
WALT136
"@ -split [System.Environment]::NewLine | ForEach-Object -Process {

    try {

        $PSMTP = Get-Recipient $_ | Select-Object PrimarySmtpAddress

        $PSObj = [pscustomobject]@{
            'SamAccountName'   = $_
            PrimarySmtpAddress = $PSMTP.PrimarySmtpAddress
        }
        $null = $PSArrayList.Add($PSObj)
    }
    catch {
        $Error
    }
}

$PSArrayList | Export-Csv C:\Temp\psmtp.csv -NoTypeInformation