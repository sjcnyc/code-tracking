$path = "\\storage\ifs$\data\Production_Shares\home\jmckay\"
$fn=@{n='fileName';e={$file}};
$name=@{n='Name';e={$_.IdentityReference}};
$dir = cmd.exe /c dir $path /s /b

$dir | % { $file=$_; $file | Get-Acl -ea 0 | % { $_.Access  } |
  Where-Object {$_.IdentityReference -match 'jmckay' -and $file -like '*.doc'} | 
  Select-Object $name, $fn} |Format-Table -auto