# https://msdn.microsoft.com/en-us/library/system.collections.arraylist(v=vs.110).aspx
# https://msdn.microsoft.com/en-us/library/6sh2ey19(v=vs.90).aspx

Clear-Host
# Standard array
(1..10).ForEach{ Measure-Command -Expression {
  $Array = @()
  (1..10000).Foreach{ $Array += "Foo Bar" }
} } | ForEach-Object { $t = 0 ; $c = 0 } { ++$c ; $t += $_.TotalMilliseconds } { [pscustomobject] @{ Name = "Array"; Time = $t/$c } }

# Array list - untyped, holds any object
(1..10).ForEach{ Measure-Command -Expression {
  $ArrayList = New-Object System.Collections.ArrayList
  (1..10000).Foreach{ $ArrayList.Add("Foo Bar") }
} } |% { $t = 0 ; $c = 0 } { ++$c ; $t += $_.TotalMilliseconds } { [pscustomobject] @{ Name = "ArrayList"; Time = $t/$c } }

# Generic list - typed, holds a string in this case
(1..10).ForEach{ Measure-Command -Expression {
  $List = New-Object System.Collections.Generic.List[string]
  (1..10000).Foreach{ $List.Add("Foo Bar") }
} } |% { $t = 0 ; $c = 0 } { ++$c ; $t += $_.TotalMilliseconds } { [pscustomobject] @{ Name = "List" ; Time = $t/$c } }

# Pipeline
(1..10).ForEach{ Measure-Command {
  ($List = 1..10000).ForEach{ "Foo Bar" }
} } |% { $t = 0 ; $c = 0 } { ++$c ; $t += $_.TotalMilliseconds } { [pscustomobject] @{ Name = "Pipeline"; Time = $t/$c } }

<#
Name            Time
----            ----
Array     7901.60966
ArrayList   49.48256
List       135.65933
Pipeline    58.96792
#>