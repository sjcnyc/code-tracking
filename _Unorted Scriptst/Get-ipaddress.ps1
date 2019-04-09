$data = ipconfig | select-string 'IPv4'; [regex]::Matches($data,"\b(?:\d{1,3}\.){3}\d{1,3}\b") | Select-Object -ExpandProperty Value

$data