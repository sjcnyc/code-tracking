$obj = New-Object -ComObject shell.application
$folder = $obj.NameSpace('C:\windows\System32')
$file = $folder.ParseName('notepad.exe')
$file.Verbs() | Select-Object name
$file.Verbs() | ForEach-Object { if ($_.name -eq '&Open') { $_.DoIt()}}
