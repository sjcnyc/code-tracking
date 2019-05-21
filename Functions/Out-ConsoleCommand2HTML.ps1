#requires -Version 1
function Out-ConsoleCommand2HTML {
  param(
    [string]$command, 
    [string]$file
  )
    
  $result = & cmd.exe /c $command | ForEach-Object -Process {"$_<br/>"}
  $body = @"
<html>
    <head>
    <title>Report $command</title>
    </head>
    <body>
      <h1>$command</h1>
      <pre>$result</pre>
    </body>
</html>
"@
  $body | Out-File -FilePath "$($file).html"
}