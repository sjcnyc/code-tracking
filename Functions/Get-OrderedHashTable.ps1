$info = [Ordered]@{}
 
$info.'BIOS Serial' = (Get-WmiObject Win32_BIOS).SerialNumber
$info.'Currently logged-in user' = $env:username
$info.'Date of day' = Get-Date
$info.Remark = 'Some remark'
 
New-Object PSObject -Property $info | Format-List | Out-String