#Requires -Version 3.0 
<# 
    .SYNOPSIS 
       Parse robocopy log information

    .DESCRIPTION 
       Parses robocopy logs into a collection of objects summarizing each robocopy operation
 
    .NOTES 
        File Name  : 
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 8/13/2014

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE
       onvertFrom-RobocopyLog C:\robocopy.log
    .EXAMPLE
       onvertFrom-RobocopyLog C:\robocopy.log | Export-CSV C:\RobocopySummary.csv
#>

function ConvertFrom-RobocopyLog
{
    Param
    (
        # Robocopy logfile to parse
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $LogFile
    )
    Process {
        Get-Content $LogFile |
        foreach {
            if ($_ -like '   ROBOCOPY     ::     Robust File Copy for Windows                              ') {
                $result = New-Object System.Object
            }
            if ($_ -like '  Started : *') {
                $started = Get-Date $_.Replace('  Started : ','')
                $result | Add-Member -MemberType NoteProperty -Name Started -Value $started
            }
            if ($_ -like '   Source = *') {
                $result | Add-Member -MemberType NoteProperty -Name Source -Value $_.Replace('   Source = ','')
            }
            if ($_ -like '     Dest = *') {
                $result | Add-Member -MemberType NoteProperty -Name Dest -Value $_.Replace('     Dest = ','')
            }
            if ($_ -like '    Files : *') {
                $result | Add-Member -MemberType NoteProperty -Name Files -Value $_.Replace('    Files : ','')
            }
            if ($_ -like '  Options : *') {
                $result | Add-Member -MemberType NoteProperty -Name Options -Value $_.Replace('  Options : ','')
            }
            if ($_ -like '    Dirs : *' -or $_ -like '   Files : *' -or $_ -like '   Bytes : *') {
                $resultIem = $($_[0..8] -join '').Trim()
                $result | Add-Member -MemberType NoteProperty -Name "Total $resultIem" -Value $($_[10..19] -join '').Trim().Replace(' k','KB').Replace(' m','MB').Replace(' g','GB')
                $result | Add-Member -MemberType NoteProperty -Name "Copied $resultIem" -Value $($_[20..29] -join '').Trim().Replace(' k','KB').Replace(' m','MB').Replace(' g','GB')
                $result | Add-Member -MemberType NoteProperty -Name "Skipped $resultIem" -Value $($_[30..39] -join '').Trim().Replace(' k','KB').Replace(' m','MB').Replace(' g','GB')
                $result | Add-Member -MemberType NoteProperty -Name "Mismatched $resultIem" -Value $($_[40..49] -join '').Trim().Replace(' k','KB').Replace(' m','MB').Replace(' g','GB')
                $result | Add-Member -MemberType NoteProperty -Name "FAILED $resultIem" -Value $($_[50..59] -join '').Trim().Replace(' k','KB').Replace(' m','MB').Replace(' g','GB')
                $result | Add-Member -MemberType NoteProperty -Name "Extra $resultIem" -Value $($_[60..69] -join '').Trim().Replace(' k','KB').Replace(' m','MB').Replace(' g','GB')
            }
            if ($_ -like '   Ended : *') {
                $ended = Get-Date $_.Replace('   Ended : ','')
                $result | Add-Member -MemberType NoteProperty -Name Ended -Value $ended
                Write-Output $result
            }
        }
    }
}

