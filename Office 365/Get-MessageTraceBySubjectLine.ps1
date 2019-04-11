<#
    .PARAMETER  Days
        Number of days back to search.
    .PARAMETER  Subject
        Subject of message to search.
    .PARAMETER  OutputFile
        Name of CSV file to populate with results.
#>

function Get-MessageTraceBySubject {

    Param(
        [Parameter(Mandatory = $True)]
        [int]$Days,
        [Parameter(Mandatory = $True)]
        [string]$Subject,
        [Parameter(Mandatory = $True)]
        [string]$OutputFile
    )


    [DateTime]$DateEnd = Get-Date
    [DateTime]$DateStart = $DateEnd.AddDays($Days * -1)

    $FoundCount = 0

    # Maximum allowed pages is 1000
    For ($i = 1; $i -le 1000; $i++) {
        $Messages = Get-MessageTrace -StartDate $DateStart -EndDate $DateEnd -PageSize 5000 -Page $i

        If ($Messages.count -gt 0) {
            $Status = $Messages[-1].Received.ToString("MM/dd/yyyy HH:mm") + " - " + $Messages[0].Received.ToString("MM/dd/yyyy HH:mm") + "  [" + ("{0:N0}" -f ($i * 5000)) + " Searched | " + $FoundCount + " Found]"

            Write-Progress -activity "Checking Messages (Up to 5 Million)..." -status $Status

            $Entries = $Messages | Where-Object {$_.Subject -like $Subject} | Select-Object Received, SenderAddress, RecipientAddress, Subject, Status, FromIP, Size, MessageId
            $Entries | Export-Csv $OutputFile -NoTypeInformation -Append

            $FoundCount += $Entries.Count
        }
        Else {
            Break
        }
    }

    Write-Host $FoundCount "Entries Found & Logged In" $OutputFile
}

Get-MessageTraceBySubject -Days '7' -Subject 'Transferencia Banca en Linea' -OutputFile 'C:\Temp\MessageTrace_001.csv'
