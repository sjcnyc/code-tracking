#Requires -Version 2.0
 
Function Get-LastBootTime{
<#
.SYNOPSIS
Uses WMI to query one or more computers and returns a sorted table of names and date/times of since last boot.
.DESCRIPTION
Works with any windows computer that can accept remote WMI queries
.PARAMETER ComputerName
Specifies one or more server names.
.EXAMPLE
Get-Content .\serverlist.txt | Get-LastBootTime | export-csv .\report.csv
Reads in a list of servers, queries them for last boot time, writes report to csv.
.EXAMPLE
Get-LastBootTime -ComputerName 'server1','server2'
Queries two servers and returns their last boot time.
.LINK
http://www.bryanvine.com/2015/06/powershell-script-get-lastboottime.html
.LINK
Get-WmiObject
.NOTES
Author: Bryan Vine
Last updated: 6/25/2015
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,valuefrompipeline=$true,Position=0)]
        [alias('CN','MachineName','ServerName','Server')][ValidateNotNullOrEmpty()][string[]]
        $ComputerName
    )
    BEGIN{
        $allcomputers = @()
        $reportoutput = @()
    }
    PROCESS{
        #Little hack that allows you to use pipeline while still taking advantage of Get-WmiObject's multithreading capabilities
        $allcomputers += $ComputerName
    }
    END{
        #WMI call to all computers
        $allwmi = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $allcomputers -ErrorAction SilentlyContinue
 
        #Error handling: Compare which computers failed WMI queries and output their uptime as unknown
        if($allwmi){
            Compare-Object -ReferenceObject $allcomputers -DifferenceObject ($allwmi | Select-Object -ExpandProperty CSName) | `
                Select-Object -ExpandProperty inputobject | ForEach-Object{
                    $obj = New-Object PSObject
                    $obj | Add-Member NoteProperty Name $_
                    $obj | Add-Member NoteProperty UpSince 'Unknown'
                    $reportoutput += $obj
                }
        }
        else{
        #Error - all computers failed to query
            $allcomputers | ForEach-Object{
                $obj = New-Object PSObject
                $obj | Add-Member NoteProperty Name $_
                $obj | Add-Member NoteProperty UpSince 'Unknown'
                $reportoutput += $obj
            }
        }
        
        #For successful queries, return a nice PS object for each computer
        foreach($wmi in $allwmi){
            $obj = New-Object PSObject
            $obj | Add-Member NoteProperty Name $wmi.CSName
            $obj | Add-Member NoteProperty UpSince $wmi.ConvertToDateTime($wmi.LastBootUpTime)
            $reportoutput += $obj
        }
        Write-Output ($reportoutput | Sort-Object Name)
    }
}

