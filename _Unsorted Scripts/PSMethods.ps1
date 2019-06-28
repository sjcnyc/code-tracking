[IO.File]::WriteAllText("c:\temp\test.txt", (get-childitem c:\ | Out-String))

#[IO.File]::AppendAllText(filename, contents)

#Convert character to code
[byte][char]"A"
[int][char]"A"
 
#Convert code to character
[char][byte]65
[char][int]65