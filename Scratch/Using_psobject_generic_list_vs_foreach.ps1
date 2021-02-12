using namespace System.Collections.Generic

$List = [List[PSObject]]::new()

foreach ($item in $items) {
  $Obj = [pscustomobject]@{
    foo = $foo
    bar = $bar
  }
  [void]$List.Add($Obj)
}





$result = foreach ($item in $array) {
  [pscustomobject][ordered]@{
    foo = $foo
    bar = $item.bar
  }
}

$result