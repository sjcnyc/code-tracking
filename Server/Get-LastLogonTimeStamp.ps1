$comps = @"

"@-split[environment]::NewLine


foreach ($comp in $comps) {

get-qadcomputer $comp -IncludeAllProperties | Select-Object LastLogonTimeStamp | 
Add-Member -MemberType NoteProperty -Name 'Computername' -Value $comp -PassThru |
Export-Csv C:\TEMP\disabledComps3.csv -NoTypeInformation -Append

}