$files = Get-ChildItem Y: | Select-Object -Last 90

function Process-RADIUSLogs () {
  [CmdletBinding()]
  param(
    $file,
    [switch]$onlyAccepted
  )
  Write-Verbose "Processing $file"
  $data = Get-Content $file
  for ($i = 0; $i -lt $data.count; $i++) {
    Write-Verbose "Processing line $i"
    if ($onlyAccepted) {
      Write-Verbose "Processing only authenticated attempts"
      $data[$i] -match '".+?",".+?",(?<date>.+?),2,,"(?<distinguishedname>.+?)"' | Out-Null
      if ($matches) {
        New-Object -TypeName PSObject -Property @{
          Date              = $matches['date']
          DistinguishedName = $matches['distinguishedname']
        }
        $matches = $Null
      }
    }
    else {
      $data[$i] -match '"(?<server>.+?)","(?<process>.+?)",(?<date>.+?),(?<status>1|2|3),"(?<username>.+?)","(?<distinguishedname>.+?)","(?<publicIP>.+?)","(?<srcIP>.+?)",' | Out-Null
      if ($matches) {
        New-Object -TypeName PSObject -Property @{
          Date              = $matches['date']
          Status            = $matches['status']
          Username          = $matches['username']
          DistinguishedName = $matches['distinguishedname']
          SourceIP          = $matches['srcIP']
        }
        $matches = $Null
      }
    }
        
  }
}


$results = $files | ForEach-Object { Process-RADIUSLogs -file $_.fullname -Verbose }

$results | Export-Csv C:\temp\RADIUSLOGS.csv -NoTypeInformation