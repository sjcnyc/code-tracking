#EXAMPLE: Join-Object -left (Import-Csv $users) -leftKey { $_.Surname + ", " + $_.GivenName } -right (Import-Csv $dcas) -rightKey { $_."Last Name" + ", " + $_."First Name" }
Function Join-Object2 {
  Param(
    $left,    #a table of data, possibily read from a csv
    $leftKey, #a block that returns a value on which to match
    $right,   #a table of data, possibily read from a csv
    $rightKey #a block that returns a value on which to match
  )

  function Join {
     param
     (
       [Object]
       $k,

       [Object]
       $l,

       [Object]
       $r
     )

    [pscustomobject]@{
        Key    = $k
        Left   = $l
        Right  = $r
    }
  }
 
  $l = $left  | Group-Object $leftKey  -AsHashTable -AsString
  $r = $right | Group-Object $rightKey -AsHashTable -AsString
 
  $l.Keys | Where-Object {  $r.ContainsKey($_) } | % { join $_ $l."$_" $r."$_" }
  $l.Keys | Where-Object { !$r.ContainsKey($_) } | % { join $_ $l."$_" $null   }
  $r.Keys | Where-Object { !$l.ContainsKey($_) } | % { join $_ $null   $r."$_" }
}

$l = Import-Csv C:\Temp\csiscan.csv
$r = Import-Csv C:\temp\exceptions.csv

Join-Object2 -left $l -leftKey code -right $r -rightKey code