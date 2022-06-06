$users = @'
nleguillow.fb2@theorchard.com
mari.yamanaka@sonymusic.co.jp
mariko.ishihara@sonymusic.co.jp
dan.smith@ultramusic.com
shoko.tanaka@sonymusic.co.jp
'@ -split [System.Environment]::NewLine

$groups = Get-Group -ResultSize unlimited

$results =
foreach ($user in $users) {
    $contact = Get-Contact -identity $user
    $groups | Where-Object { $_.Members -contains $contact } | ForEach-Object {
        [PSCustomObject]@{
            User  = $contact.DisplayName
            Group = $_.displayname
        }
    }
}

$results | Export-Csv C:\Temp\groups.csv -NoTypeInformation
