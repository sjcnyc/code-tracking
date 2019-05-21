#Requires -Version 3.0 
<# 
    .SYNOPSIS 


    .DESCRIPTION 

 
    .NOTES 
        File Name  : Get-IPAddresses
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 4/4/2014

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE

    .EXAMPLE

#>
function Get-IPAddresses {
	Param([string]$computername)
	
	[regex]$ip4='\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
	
	get-wmiobject win32_networkadapterconfiguration -filter "IPEnabled='True'" -computer $computername | 
	Select-Object `
            DNSHostname, `
            Index, `
            Description, `
            @{Name='IPv4';Expression={ $_.IPAddress -match $ip4}}, `
            @{Name='IPv6';Expression={ $_.IPAddress -notmatch $ip4}}, `
            MACAddress
}