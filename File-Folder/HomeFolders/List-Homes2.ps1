#requires -Version 3
#requires -PSSnapin Quest.ActiveRoles.ADManagement
@"
jcassell
"@ -split [environment]::NewLine | 
 
ForEach-Object -Process {
  Get-QADUser -Identity $_ -Enabled  `
  -DontUseDefaultIncludedProperties `
  -SizeLimit 0 `
  -IncludedProperties samaccountname, homedirectory, homedrives | 
  Select-Object -Property samaccountname, HomeDrive, HomeDirectory # | 
  # Where-Object { 
  #  $_.homedirectory -eq $null 
  # }
} |
Export-Csv -Path C:\TEMP\homes_USA_NEW.csv -NoTypeInformation -Append