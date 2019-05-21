function Get-IPfromFQDN {

#Requires -Version 3.0 
<# 
    .SYNOPSIS 
        Gets IP addresses by input FQDN list. 

    .DESCRIPTION 
        Gets IP addresses by input FQDN list. 
 
    .NOTES 
        File Name  : Get-IPfromFQDN
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 4/4/2014

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE
        Get-IPfromFQDN -FqdnArray ly2,ny1,usnaspwfs01

    .EXAMPLE

#>

param( 
    [parameter(Mandatory=$False)] 
    [string[]]$FqdnArray, 
     
    [parameter(Mandatory=$False)] 
    [string]$OutputFile = [string]::Format('FQDN_IP_{0}.csv', (Get-Date).Tostring('yyyy-MM-dd_HHmmss')) 
) 
 
$data = @() 
$fqdnArraySize = $fqdnArray.Length 
$i = 0 
 
foreach($fqdn in $fqdnArray) 
{  
 
    # Progress Bar 
    $i++ 
    Write-Progress -Activity 'Collecting IPs' -Status "Collected: $i/$arrsize" -PercentComplete (($i / $fqdnArraySize) * 100) 
    $addr = @([System.Net.Dns]::GetHostAddresses($fqdn)) 
    if($addr -and $addr.Count -gt 0) 
    { 
        $ip = $addr[0].IPAddressToString 
        $all_IP_Addresses = ([string]::join(',', ($addr | Select-Object -ExpandProperty IPAddressToString))) 
    } 
    else 
    { 
        $ip = 'N/A' 
        $all_IP_Addresses = 'N/A' 
    } 
     
    $data += [pscustomobject] @{ 
        FQDN = $fqdn 
        IP = $ip
        All_IP_Addresses = (($all_IP_Addresses) | Out-String).Trim() 
    } | Select-Object FQDN,IP,All_IP_Addresses 
} 
         
return $data
}