#Requires -Version 3.0
<#
.SYNOPSIS

.DESCRIPTION

.NOTES
    File Name  : Get-MembersFromDistributionList
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0
.LINK
    This script posted to:
        http://www.github/sjcnyc
.EXAMPLE

.EXAMPLE

#>

@"
GDL00004570
GDL00004563
GDL00005636
GDL00004571
GDL00005732
GDL00004562
GDL00006088
GDL00004566
GDL00005396
GDL00005395
GDL00004564
GDL00004578
"@ -split [environment]::NewLine |

Get-QADGroup -Service 'nycmnetads001.mnet.biz:389' -SizeLimit '0'   |
    ForEach-Object {
    $_ |
        Get-QADGroupMember -IncludeAllProperties | Select-Object Firstname, Lastname, parentcontainer, mail -Unique |
        Add-Member -MemberType NoteProperty -Name 'Group Name' -Value $_.displayname -PassThru |
        Add-Member -MemberType NoteProperty -Name 'Alias' -Value $_.alias -PassThru
} | Export-Csv -Path "$env:HOMEDRIVE\temp\DLReport_001002.csv" -NoTypeInformation -Append