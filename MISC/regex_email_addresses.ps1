
# Regex valid email address out of file dump 
# sean connealy
# 
$pattern = '\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b'
$text = 'My email -- is alexm@zomba.com blah@{mail=Alex.Moldoveanu@sonymusic.com}and@.com also foo@bar.com@'

filter Matches {
  param
  (
    [System.Object]
    $pattern
  )
  
  $_ | Select-String -AllMatches $pattern | Select-Object -Expand Matches | Select-Object -Expand Value
}

$text | Matches $pattern