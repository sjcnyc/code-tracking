$eod={function hx{Param([string]$t)$t.Split("-“)|%{write-host -object ([CHAR][BYTE]([CONVERT]::toint16($_,16))) –n}}
[datetime]$e="5:30PM";$s=$e-(get-date);$s=$s.ToString().Substring(0,5)
$s=$s.Split(":");$h=$s[0];$m=$s[1];write-host $h -n;hx "20-48-6f-75-72-73-20-61-6e-64-20"
write-host $m -n;hx "20-4d-69-6e-75-74-65-73-20-75-6e-74-69-6c-20-79-6f-75-20-63-61-6e-20-6c-65-61-76-65"};&$eod

 



