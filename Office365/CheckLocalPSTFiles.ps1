$destDir = "\\YOUR_SERVER_HERE" 
$hostName = [System.Net.Dns]::GetHostName()
$userName = [Environment]::UserName
$fullPath = $destDir + $hostName + "-" + $userName + ".txt"

New-Item -Path $fullPath -type file
if ($? -eq $False) #last command unsuccessful file probably already exists
    {exit}

$userPath = Get-ChildItem Env:USERPROFILE #grab the user profile path 
$userProfile = $userPath.Value

if ($userProfile -match '^C:') #regex to match only profiles on C:
    {
    $files = Get-ChildItem -Recurse -Path $userProfile -Include *.pst -Force -Erroraction 'silentlycontinue'`
    | Where-Object {$_.PSIsContainer -ne $True} #where it isn't a container (folder)
    foreach ($file in $files)
        {
        Add-Content -path $fullPath $file.FullName
        }
    }
    
    