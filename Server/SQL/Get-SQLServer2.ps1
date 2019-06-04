#Requires -Version 3.0 
<# 
.SYNOPSIS 
    This script Gets a list of SQL Severs on the Subnet 
.DESCRIPTION 
    This script uses SMO to Find all the local SQL Servers  
    and displays them 
 
.NOTES 
    File Name  : Get-SQLServer2.ps1 
    Author     : Thomas Lee - tfl@psp.co.uk 
    Requires   : PowerShell Version 3.0 
.LINK 
    This script posted to: 
        http://www.pshscripts.blogspot.com 
.EXAMPLE 
    PS>  # On a Lync Server looking at Lync Implementation 
    PS>  Get-SQLServer2 
    There are 7 SQL Server(s) on the Local Subnet 
 
    ServerName      InstanceName Version      
    ----------      ------------ -------      
    2013-LYNC-MGT   MON          10.50.2500.0 
    2013-LYNC-MGT   SCOM         10.50.2500.0 
    2013-TS         RTCLOCAL     11.0.2100.60 
    2013-SHAREPOINT SPSDB        11.0.3000.0  
    2013-LYNC-FE    RTC          11.0.2100.60 
    2013-LYNC-FE    RTCLOCAL     11.0.2100.60 
    2013-LYNC-FE    LYNCLOCAL    11.0.2100.60 
     
#> 
Import-Module SQLPS 
 
# Now get all the database servers on the local subnet 
 
$SQLservers = [Data.Sql.SqlDataSourceEnumerator]::Instance.GetDataSources() 
$Srvs= @() 
 
# Convert collection to an array 
Foreach ($srv in $SQLservers) { 
$srvs += $srv 
} 
 
# Now display results 
If ($Srvs.count -LE 0) { 
'There are no SQL Servers on the Local Subnet' 
return
} 
 
# Now print server details 
'There are {0} SQL Server(s) on the Local Subnet' -f $Srvs.count 
$Srvs | Select-Object ServerName, InstanceName, Version | Format-Table -AutoSize 