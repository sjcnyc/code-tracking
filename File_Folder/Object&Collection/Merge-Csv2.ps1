<# $FirstCollection = @"
  FirstName,  LastName,   MailingAddress,    EmployeeID
  John,       Doe,        123 First Ave,     J8329029
  Susan Q.,   Public,     3025 South Street, K4367143
"@.Split("`n") | ConvertFrom-Csv                              
#
 $SecondCollection = @"
  ID,    Week, HrsWorked,   PayRate,  EmployeeID
  12276, 12,   40,          55,       J8329029
  12277, 13,   40,          55,       J8329029
  12278, 14,   42,          55,       J8329029
  12279, 12,   35,          40,       K4367143
  12280, 13,   32,          40,       K4367143
  12281, 14,   48,          40,       K4367143
"@.Split("`n") | ConvertFrom-Csv       #>                       
#
             
$FirstCollection = Import-Csv C:\temp\ActiveSyncPartnerships.csv
$SecondCollection = Import-Csv C:\TEMP\Airwatch_Matrix.csv 
function Join-Collections {
  PARAM(
    $FirstCollection,
    [string]$FirstJoinColumn,
    $SecondCollection,
    [string]$SecondJoinColumn=$FirstJoinColumn
  )
  PROCESS {
    $ErrorActionPreference = 'Inquire'
    foreach($first in $FirstCollection) {
      $SecondCollection | Where-Object{ $_."$SecondJoinColumn" -eq $first."$FirstJoinColumn" } | Join-Object $first
    }
  }
  BEGIN {
    function Join-Object {
      Param(
        [Parameter(Position=0)]$First,
        [Parameter(ValueFromPipeline=$true)]$Second
      )
      BEGIN {
        [string[]] $p1 = $First | Get-Member -type Properties | Select-Object -expand Name
      }
      Process {
        $Output = $First | Select-Object $p1
        foreach($p in $Second | Get-Member -type Properties | Where-Object { $p1 -notcontains $_.Name } | 
        Select-Object -expand Name) {
           Add-Member -in $Output -type NoteProperty -name $p -value $Second."$p"
        }
        $Output
      }
    }
  }
}

 Join-Collections $FirstCollection DeviceUserAgent $SecondCollection | ft -auto 