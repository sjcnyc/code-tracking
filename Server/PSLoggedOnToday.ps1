#!powershell.exe
# ======================================================================
# PSLoggedOnToday.ps1
# Logs a list of users who logged on during the current day
# Created by Matthew Newton
# 10.17.2012
#
# Queries each Domain Controller in the current domain and compiles a 
# list of distinguishedName and lastLogon attributes for each user. Then
# it outputs only those users who have logged on during the current day
# (since midnight) as determined by the local computer.
# ======================================================================
# 
# Heavily based on Richard L. Mueller's PSLastLogon.ps1. 
# Link: http://www.rlmueller.net/PowerShell/PSLastLogon.txt
# And:  http://www.rlmueller.net/Last%20Logon.htm
#
# Richard's header is reproduced below:
#
# ----------------------------------------------------------------------
# Copyright (c) 2011 Richard L. Mueller
# Hilltop Lab web site - http://www.rlmueller.net
# Version 1.0 - March 16, 2011
#
# This program queries every Domain Controller in the domain to find the
# largest (latest) value of the lastLogon attribute for each user. The
# last logon dates for each user are converted into local time. The
# times are adjusted for daylight savings time, as presently configured.
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the copyright owner above has no warranty, obligations,
# or liability for such use.


Trap {"Error: $_"; Break;}

$D = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$Domain = [ADSI]"LDAP://$D"
$Searcher = New-Object System.DirectoryServices.DirectorySearcher
$Searcher.PageSize = 200
$Searcher.SearchScope = 'subtree'

$Searcher.Filter = '(&(objectCategory=person)(objectClass=user))'
$Searcher.PropertiesToLoad.Add('distinguishedName') > $Null
$Searcher.PropertiesToLoad.Add('lastLogon') > $Null

# Create hash table of users and their last logon dates.
$arrUsers = @{}

# Enumerate all Domain Controllers.
ForEach ($DC In $D.DomainControllers)
{
    $Server = $DC.Name
    $Searcher.SearchRoot = "LDAP://$Server/" + $Domain.distinguishedName
    $Results = $Searcher.FindAll()
    ForEach ($Result In $Results)
    {
        $DN = $Result.Properties.Item('distinguishedName')
        $LL = $Result.Properties.Item('lastLogon')
        If ($LL.Count -eq 0)
        {
            $Last = [DateTime]0
        }
        Else
        {
            $Last = [DateTime]$LL.Item(0)
        }
        If ($Last -eq 0)
        {
            $LastLogon = $Last.AddYears(1600)
        }
        Else
        {
            $LastLogon = $Last.AddYears(1600).ToLocalTime()
        }
        If ($LastLogon -gt [DateTime]::Today)
    {

        If ($arrUsers.ContainsKey("$DN"))
            {
                If ($LastLogon -gt $arrUsers["$DN"])
                {
                    $arrUsers["$DN"] = $LastLogon
                }
            }
            Else
            {
                $arrUsers.Add("$DN", $LastLogon)
            }
    }
    }
}

# Output file names
$fileName = (Get-Date).ToString('yyyy-MM-dd') + '_' + $arrUsers.Count + '.csv'
$reportName = 'DailyReport.csv'

# Output List of Users to CSV
&{ $arrUsers.GetEnumerator() | ForEach { New-Object PSObject -Property @{DN = $_.name; lastLogon = $_.value}} } | Export-CSV $fileName -NoType

# Append Total Count to CSV
$totalRow = 'User Count: ' + $arrUsers.Count
Add-Content $fileName $totalRow

# Output Time and User Count to report CSV
$reportRow = '"' + (Get-Date).ToString() + '",' + $arrUsers.Count
Add-Content $reportName $reportRow