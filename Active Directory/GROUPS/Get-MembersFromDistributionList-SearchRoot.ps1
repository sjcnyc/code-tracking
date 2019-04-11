#Requires -Version 3.0 
<#
.SYNOPSIS

.DESCRIPTION


.NOTES
    File Name  : Get-MembersFromDistributionList-SearchRoot
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0
.LINK
    This script posted to:
        http://www.github/sjcnyc
.EXAMPLE

.EXAMPLE

#>

@"
Domain Admins
"@ -split [environment]::NewLine |

Get-QADGroup -SizeLimit 0 |
    ForEach-Object {
    $_ |
        Get-QADGroupMember | Select-Object DisplayName, eMail -Unique |
        Add-Member -MemberType NoteProperty -Name 'Group Name' -Value $_.displayname -PassThru |
        Add-Member -MemberType NoteProperty -Name 'Alias' -Value $_.alias -PassThru | Format-Table -auto
} |
    Export-Csv c:\temp\DLReport.csv -NoTypeInformation -Append