function start-Svc {
    param($svc, $computer)
    [CmdletBinding()]
    $tempDir = "c:\temp"
    if (!(Test-Path $tempDir)) {
        try {
            $null = New-Item $tempDir -ItemType directory -Force -ErrorAction Stop -ErrorVariable DirectoryError
        }
        Catch {
            write-Error "An error occurred created the archive folder $tempDir. Error: $DirectoryError"
        }
    }

    function mailit {
        param($subj, $msg)
        $EmailList = "johndoe@acme.com"
        $MailMessage = @{
            To          = $EmailList
            From        = "DONOTREPLY@acme.com"
            Subject     = $subj
            Body        = $msg
            SmtpServer  = "smtp.acme.com"
            ErrorAction = "SilentlyContinue"
        }
        Send-MailMessage @MailMessage
    }

    $UniqueName = "$computer" + "$svc"
    $counterFile = "c:\temp\counter$UniqueName.txt"

    if (!(Test-Path $counterFile)) {
        try {
            $null = New-Item $counterFile -ItemType file -Force -ErrorAction Stop -ErrorVariable FileError
        }
        Catch {
            Write-Warning "An error occurred creating the file $counterFile. Error: $FileError"
        }
    }

    if ((Get-ChildItem $counterFile).length -eq 0) {
        Write-Output 1 > $counterFile
    }

    [int]$counter = Get-Content $counterFile
    if ($counter -gt 2) {
        $Subj = "***Restarting $svc service"
        $msg = "Service $svc has stopped $counter times. Restarting..."
        try {
            get-Service -Name $svc -ComputerName $computer| set-service -StartupType Automatic -ErrorAction Stop
            get-Service -Name $svc -ComputerName $computer| set-service -Status Running -ErrorAction Stop
            mailit $subj $msg
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
        }
        Write-Output 1 > $counterFile
    }
    else {
        $counter = $counter + 1
        Write-Output $counter > $counterFile
        try {
            get-Service -Name $svc -ComputerName $computer| set-service -StartupType Automatic -ErrorAction Stop
            get-Service -Name $svc -ComputerName $computer| set-service -Status Running -ErrorAction Stop
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
        }
    }
}

$servicesToMonitor = "Spooler", "SNMPTRAP"
$computer = "ACMETSTSERVER"
foreach ($serviceToMonitor in $servicesToMonitor) {
    $Stopped = (Get-WmiObject win32_service -filter "Name='$serviceToMonitor' AND startmode='auto' AND state<>'Running'" -ComputerName $computer).State
    if ($Stopped) {
        start-Svc $serviceToMonitor $computer
    }
}

check-Svc