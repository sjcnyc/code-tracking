#  Performs a inner join on two collections of objects based on a common key column.

$FirstCollection =
$SecondCollection =

function Join-Collections {
PARAM(
   $FirstCollection
,  [string]$FirstJoinColumn
,  $SecondCollection
,  [string]$SecondJoinColumn=$FirstJoinColumn
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
      [Parameter(Position=0)]
      $First
   ,
      [Parameter(ValueFromPipeline=$true)]
      $Second
   )
   BEGIN {
      [string[]] $p1 = $First | Get-Member -type Properties | Select-Object -expand Name
   }
   Process {
      $Output = $First | Select-Object $p1
      foreach($p in $Second | Get-Member -type Properties | Where-Object { $p1 -notcontains $_.Name } | Select-Object -expand Name) {
         Add-Member -in $Output -type NoteProperty -name $p -value $Second."$p"
      }
      $Output
   }
   }
}
}