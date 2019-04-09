Measure-Command {1..10000| ForEach-Object {[System.Collections.Generic.List[PSObject]]::new()}}
Measure-Command {1..10000| ForEach-Object {[System.Collections.Generic.List[PSObject]]@()}}
Measure-Command {1..10000| ForEach-Object {New-Object System.Collections.Generic.List[PSObject]}}
Measure-Command {1..10000| ForEach-Object {[System.Collections.ArrayList]::new()}}
Measure-Command {1..10000| ForEach-Object {[System.Collections.ArrayList]@()}}
Measure-Command {1..10000| ForEach-Object {New-Object System.Collections.ArrayList}}