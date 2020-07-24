function Move-FilesOlderThan {
  [cmdletbinding(SupportsShouldProcess = $True)]
  param(

    [System.String]
    $SourcePath,

    [System.String]
    $DestPath,

    [System.Int32]
    $Days = 120,

    [System.Array[]]
    $FileExclude,

    [System.Management.Automation.SwitchParameter]
    $SendEmail,

    [System.Management.Automation.SwitchParameter]
    $ReportOnly
  )

  $MAXItems = '50'
  $CSVFile = "C:\Support\MPisilon_Cleanup_Report-$($Date).csv"
  $StartTime = Get-Date -Format G
  $Attachment = $false

  $Style1 =
  '<style>
  body {color:#333333;font-family:Calibri,Tahoma,arial,verdana;font-size: 10pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #E9E9E9;}
  h4 {font-size: 10pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#FFFFFF;background-color:#2980B9;border:1px solid #2980B9;padding:4px;}
  td {padding:4px; border:1px solid #E9E9E9;}
  .odd { background-color:#F6F6F6; }
  .even { background-color:#E9E9E9; }
</style>'
  function Write-Log {
    param (
      [Parameter(Mandatory = $true)][string]
      $Message,
      [string]
      $Path = "\\storage.bmg.bagint.com\mpisilon$\X_DELETION\MPIsilon_file_cleanup.log"
    )
    Write-Verbose -Message $Message
    Write-Output "$(Get-Date) $Message" | Out-File -FilePath $path -Append
  }

  $PSArrayList = New-Object System.Collections.ArrayList
  $MoveFiles = (Get-LongChildItem -Path $SourcePath -Recurse -Filter *.* -File).Where( {($_.CreationTime -le $(Get-Date).AddDays(- $Days))})

  try {
    foreach ($MoveFile in $MoveFiles) {
      $SourceSubFolder = $MoveFile.DirectoryName.Replace("\\storage.bmg.bagint.com\MPIsilon$\WORKSPACE\VIDEO\", "")

      $DestinationPath = $DestPath + $SourceSubFolder
      $PSObj = [pscustomobject]@{
        Source      = "$("$MoveFile")"
        Destination = "$("$DestinationPath")"
        FileName    = $MoveFile.Name
      }
      if (!($ReportOnly)) {

        if (!(Test-Path $DestinationPath)) {
          New-LongItem -Path $DestinationPath -ItemType Directory
          Write-Log -Message "Moving $($movefile.Name) to: $DestinationPath" -Verbose
          Move-LongItem -Path $MoveFile -Destination $DestinationPath
        }
        else {
          Write-Log -Message "Moving $($movefile.Name) to: $DestinationPath" -Verbose
          Move-LongItem -Path $MoveFile -Destination $DestinationPath
        }
      }
      [void]$PSArrayList.Add($PSObj)
    }    

      if ($ReportOnly) { $Action = "Files Matched:" } else { $Action = "Files Moved:" }

      $HTML = New-HTMLHead -title "MP Isilon File Cleanup Report" -style $Style1
      $HTML += "<h3>MP Isilon File Cleanup Report</h3>"
      $HTML += "<h4>Azure Hybrid Runbook Worker: Tier-2</h4>"
      $HTML += "<h4>Source: $($SourcePath)</h4>"
      $HTML += "<h4>Destination: $($DestPath)</h4>"
      $HTML += "<h4>Days: ($Days)</h4>"
      $HTML += "<h4>Script started: $($StartTime)</h4>"

      if ($MoveFiles.Count -lt $MAXItems ) {
        $HTML += New-HTMLTable -InputObject $($PSArrayList)
      }
      else {
            $Attachment = $True
            $PSArrayList | Export-Csv $CSVFile -NoTypeInformation
            $HTML += "<h4>See Attached CSV Report</h4>"
      }
      $HTML += "<h4>$($Action) ($($MoveFiles.Count))</h4>"
      $HTML += "<h4>Script completed: $(Get-Date -Format G)</h4>" | Close-HTML

    if ($SendEmail) {
      $EmailParams = @{
        To         = "sean.connealy@sonymusic.com" #, "michael.catandella@sonymusic.com", "jonathan.chinn@sonymusic.com"
        From       = 'Posh Alerts poshalerts@sonymusic.com'
        Subject    = 'MP Isilon File Cleanup Report'
        SmtpServer = 'cmailsony.servicemail24.de'
        Body       = ($HTML | Out-String)
        BodyAsHTML = $true
      }
      if ($Attachment) {
        Send-MailMessage @EmailParams -Attachments $CSVFile
        Start-Sleep -Seconds 5
        Remove-Item $CSVFile
      }
      else {
        Send-MailMessage @EmailParams
      }
    }
  }
  catch {
    Write-Log -Message $_.Exception.Message -Verbose
    #break
  }
}

Move-FilesOlderThan -SourcePath '\\storage.bmg.bagint.com\MPIsilon$\WORKSPACE\VIDEO\SHORTFORM\' -DestPath '\\storage.bmg.bagint.com\mpisilon$\X_DELETION\VIDEO\' -Days 90 -Verbose -SendEmail -ReportOnly