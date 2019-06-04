#v3 Object Field Separator

$Test = 'Ryan', 'John', 'Mark'
[String]$Test

$OFS = "`r`n"
[String]$Test

$OFS = ', '
[String]$Test

Remove-Variable OFS
[String]$Test
