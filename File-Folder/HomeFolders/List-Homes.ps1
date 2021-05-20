$userlist = Get-Content -Path .\userlist.txt

$userlist -split [environment]::NewLine | ForEach-Object -Process {

  Get-QADUser $_ | Select-Object SAMAccountName, HomeDrive, HomeDirectory | Export-Csv 'C:\TEMP\homeDrive_Directory.csv' -NoTypeInformation -Append

} 