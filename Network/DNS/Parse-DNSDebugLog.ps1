#Requires -Version 3.0 
<# 
    .SYNOPSIS
      Parses a Windows DNS Debug log

    .DESCRIPTION
      When a DNS log is converted with this script it will be turned into objects for further parsing

    .NOTES 
      File Name  : Parse-DNSDebugLog.ps1
      Author     : Sean Connealy
      Requires   : PowerShell Version 3.0 
      Date       : 12/10/2015

    .LINK 
      This script posted to: http://www.github/sjcnyc

    .EXAMPLE
      Get-DNSDebugLog -DNSLog ".\Something.log" | Format-Table

    .EXAMPLE
      Get-DNSDebugLog -DNSLog ".\Something.log" | Export-Csv .\ProperlyFormatedLog.csv
      
    .PARAMETER DNSLog
      Path to the DNS log or DNS log data. Supports pipelining DNS log data.      
#>
function Get-DNSDebugLog
{
    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
      [Alias('Fullname')]
      [string] $DNSLog = 'StringMode')

    BEGIN { }

    PROCESS {

        $TheReverseRegExString='\(\d\)in-addr\(\d\)arpa\(\d\)'

        Get-DNSLogLines -DNSLog $DNSLog | % {
                if ( $_ -match '^\d\d' -AND $_ -notlike '*EVENT*') {
                    $Date=$null
                    $Time=$null
                    $DateTime=$null
                    $Protocol=$null
                    $Client=$null
                    $SendReceive=$null
                    $QueryType=$null
                    $RecordType=$null
                    $Query=$null
                    $Result=$null

                    $Date=($_ -split ' ')[0]

                    # Check log time format and set properties
                    if ($_ -match ':\d\d AM|:\d\d  PM') {
                        $Time=($_ -split ' ')[1,2] -join ' '
                        $Protocol=($_ -split ' ')[7]
                        $Client=($_ -split ' ')[9]
                        $SendReceive=($_ -split ' ')[8]
                        $RecordType=(($_ -split ']')[1] -split ' ')[1]
                        $Query=($_.ToString().Substring(110)) -replace '\s' -replace '\(\d?\d\)','.' -replace '^\.' -replace "\.$"
                        $Result=(((($_ -split '\[')[1]).ToString().Substring(9)) -split ']')[0] -replace ' '
                    }
                    elseif ($_ -match '^\d\d\d\d\d\d\d\d \d\d:') {
                        $Date=$Date.Substring(0,4) + '-' + $Date.Substring(4,2) + '-' + $Date.Substring(6,2)
                        $Time=($_ -split ' ')[1] -join ' '
                        $Protocol=($_ -split ' ')[6]
                        $Client=($_ -split ' ')[8]
                        $SendReceive=($_ -split ' ')[7]
                        $RecordType=(($_ -split ']')[1] -split ' ')[1]
                        $Query=($_.ToString().Substring(110)) -replace '\s' -replace '\(\d?\d\)','.' -replace '^\.' -replace "\.$"
                        $Result=(((($_ -split '\[')[1]).ToString().Substring(9)) -split ']')[0] -replace ' '
                    }
                    else {
                        $Time=($_ -split ' ')[1]
                        $Protocol=($_ -split ' ')[6]
                        $Client=($_ -split ' ')[8]
                        $SendReceive=($_ -split ' ')[7]
                        $RecordType=(($_ -split ']')[1] -split ' ')[1]
                        $Query=($_.ToString().Substring(110)) -replace '\s' -replace '\(\d?\d\)','.' -replace '^\.' -replace "\.$"
                        $Result=(((($_ -split '\[')[1]).ToString().Substring(9)) -split ']')[0] -replace ' '
                    }

                    $DateTime=Get-Date("$Date $Time") -Format 'yyyy-MM-dd HH:mm:ss'


                    if ($_ -match $TheReverseRegExString) {
                        $QueryType='Reverse'
                    }
                    else {
                        $QueryType='Forward'
                    }

                    $returnObj = new [pscustomobject] @{
                    
                      'Data'= $DateTime
                      'QueryType' = $QueryType
                      'Client' = $Client
                      'SendRecieve' = $SendReceive
                      'Protocol' = $Protocol
                      'RecordType' = $RecordType
                      'Query' = $Query
                      'Results' = $Results
                    }

                    if ($returnObj.Query -ne $null) {
                        Write-Output $returnObj
                    }
                }
            }

    }

    END { }
}

function Get-DNSLogLines
{
param($DNSLog)

$PathCorrect = try { Test-Path $DNSLog -ErrorAction Stop } catch { $false }

    if ($DNSLog -match '^\d\d' -AND $DNSLog -notlike '*EVENT*' -AND $PathCorrect -ne $true) {
        $DNSLog
    }
    elseif ($PathCorrect -eq $true) {
        Get-Content $DNSLog | % { $_ }
    }
}