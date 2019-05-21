#requires -version 2.0

<#
 -----------------------------------------------------------------------------
 Script: Test-Subnet.ps1
 Version: 1.0
 Author: Jeffery Hicks
    http://jdhitsolutions.com/blog
    http://twitter.com/JeffHicks
    http://www.ScriptingGeek.com
 Date: 11/12/2011
 Keywords:
 Comments:

 inspired by http://www.thomasmaurer.ch/2011/11/powershell-ping-ip-range/
 
 "Those who forget to script are doomed to repeat their work."

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************
 -----------------------------------------------------------------------------
 #>
 

Function Test-Subnet {

<#
.SYNOPSIS
Ping an IP subnet
.DESCRIPTION
This command is a wrapper for Test-Connection. It will ping an IP subnet 
range and return a custom object.

TestDate   : 11/7/2011 8:30:22 AM
Buffersize : 32
TTL        : 80
Pinged     : True
IPAddress  : 172.16.10.105
Delay      : 1

The command by default pings all hosts from 1 to 254 on the specfied subnet
 value. Enter the subnet value like this: 172.16.10

A regular expression pattern will validate the subnet value.
.PARAMETER Subnet
The IP subnet such as 192.168.10. 
.PARAMETER Range
The range of host IP addresses. The default is 1..254.
.PARAMETER Count
The number of pings to send. The default is 1.
.PARAMETER Delay
The delay between pings in seconds. The default is 1.
.PARAMETER Buffer
Specifies the size, in bytes, of the buffer sent with this command.
The buffer default is 32.
.PARAMETER TTL
Specifies the maximum time, in seconds, that each echo request packet 
("pings") is active. The default value is 80 (seconds). 
.PARAMETER AsJob
Run the command as a background job.
.EXAMPLE
PS C:\> Test-Subnet 192.168.10
Ping all computers in the 192.168.10 subnet.
.EXAMPLE
PS C:\> Test-Subnet 192.168.10 (100..200) -asjob
Ping computers 192.168.10.100 through 192.168.10.200. Run the command as a background job.
.NOTES
NAME        :  Test-Subnet
VERSION     :  1.0   
LAST UPDATED:  11/12/2011
AUTHOR      :  Jeffery Hicks
.LINK
http://jdhitsolutions.com/blog/2011/11/ping-ip-range/
.LINK
Test-Connection 
.INPUTS
None
.OUTPUTS
Custom object
#>

[cmdletbinding()]

Param (
[Parameter(Position=0)]
[ValidatePattern('\d{1,3}\.\d{1,3}\.\d{1,3}')]
[string]$Subnet,
[Parameter(Position=1)]
[int[]]$Range=1..254,
[int]$Count=1,
[int]$Delay=1,
[int]$Buffer=32,
[int]$TTL=80,
[switch]$AsJob
)


$sb={
Param($range,$subnet,$count,$delay,$buffer,$ttl)
$range | % {
    $target="$subnet.$_"
    Write-verbose $target
    $ping=Test-Connection -ComputerName $target -count $count -Delay $delay -BufferSize $Buffer -TimeToLive $ttl -Quiet 
    New-Object -TypeName PSObject -Property @{
        IPAddress=$Target
        Pinged=$ping
        TTL=$TTL
        Buffersize=$buffer
        Delay=$Delay
        TestDate=Get-date
    } 
} 
}  #close scriptblock

if ($AsJob) {
    Start-Job -ScriptBlock $sb -Name "Ping $subnet" -ArgumentList $range,$subnet,$count,$delay,$buffer,$ttl
}
else {
 #run the command normally
  Invoke-Command -ScriptBlock $sb -ArgumentList $range,$subnet,$count,$delay,$buffer,$ttl 
 
} 

}  #end function


Test-Subnet 10.12.112 (190..200) | Format-Table -auto