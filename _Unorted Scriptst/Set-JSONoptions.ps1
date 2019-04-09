# define options object
$options = [PSCustomObject]@{
    Color  = 'Red'
    Height = 12
    Name   = 'Weltner'
}
 
# play with options settings 
$options.Color = 'Blue'

# save options to file 
$Path = "c:\temp\options.json"
$options | ConvertTo-Json | Set-Content -Path $Path
 
# load options from file
$options2 = Get-Content -Path $Path | ConvertTo-Json