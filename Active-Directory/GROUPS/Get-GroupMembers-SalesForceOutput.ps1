#requires -PSSnapin Quest.ActiveRoles.ADManagement
#Requires -Version 1 
<# 
    .SYNOPSIS 
    Get security group members with custom host output

    .DESCRIPTION 
    Get security group members.  Displays optput for use
    in SalesForce tickets & changes
 
    .NOTES 
    File Name  : Get-GroupMembers-SalesForceOutput
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0 
    Date       : 3/28/2014
    .LINK 
    This script posted to: 
    http://www.github/sjcnyc
    .EXAMPLE

    .EXAMPLE

#>

@"
USA-GBL ISI CreativeNY Creative-NY RW
"@ -split [environment]::NewLine |

ForEach-Object -Process {
    $_
    Get-QADGroup -Identity $_ |
        Get-QADGroupMember -Type user |
        Select-Object -Property samaccountname , name, mail | Format-Table -auto -HideTableHeaders
}
