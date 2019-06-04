



#Write-Progress -Id 1 -Activity $source -PercentComplete $i -Status $dest
Start-Job { 
$source="C:\temp\source"
$dest="C:\temp\dest"

$what = @("/COPYALL","/B","/SEC","/MIR")
$options = @("/R:0","/W:0","/NFL","/NDL")

$cmdArgs = @("$source","$dest",$what,$options)

robocopy @cmdArgs } > $null
