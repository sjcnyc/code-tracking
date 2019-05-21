#Requires -Version 2.0 
<# 
    .SYNOPSIS
      Calculates the IP subnet information

    .DESCRIPTION
      Calculates the IP subnet information 

    .NOTES 
        File Name  : Get-IPCalc
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 1/20/2015

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE
      Get-IPCalc -IPAddress 10.100.100.1 -NetMask 255.255.255.0

    .EXAMPLE
      Get-IPCalc 10.10.100.5/24
#>
function Get-IPCalc { 
  param ( 
    [Parameter(Mandatory=$True,Position=1)] 
    [string]$IPAddress, 
    [Parameter(Mandatory=$False,Position=2)] 
    [string]$Netmask 
    )
  function Get-ToBinary {
     param
     (
       [Object]
       $dottedDecimal
     )
 
    $dottedDecimal.split('.') | %{$binary=$binary + $([convert]::toString($_,2).padleft(8,'0'))} 
    return $binary 
  } 
  function Get-ToDottedDecimal {
     param
     (
       [Object]
       $binary
     )
 
    do {$dottedDecimal += '.' + [string]$([convert]::toInt32($binary.substring($i,8),2)); $i+=8 } while ($i -le 24) 
    return $dottedDecimal.substring(1) 
  }
  function Get-CidrToBin {
     param
     (
       [Object]
       $cidr
     )
 
    if($cidr -le 32){ 
        [Int[]]$array = (1..32) 
        for($i=0;$i -lt $array.length;$i++){ 
            if($array[$i] -gt $cidr){$array[$i]='0'}else{$array[$i]='1'} 
        }
        $cidr =$array -join '' 
    }
    return $cidr 
  }
  function Get-NetMasktoWildcard  {
     param
     (
       [Object]
       $wildcard
     )
 
    foreach ($bit in [char[]]$wildcard) { 
        if ($bit -eq '1') { 
            $wildcardmask += '0' 
            } 
        elseif ($bit -eq '0') { 
            $wildcardmask += '1' 
            } 
        } 
    return $wildcardmask 
    }
 
  if ($IPAddress -like '*/*') { 
    $CIDRIPAddress = $IPAddress 
    $IPAddress = $CIDRIPAddress.Split('/')[0] 
    $cidr = [convert]::ToInt32($CIDRIPAddress.Split('/')[1]) 
    if ($cidr -le 32 -and $cidr -ne 0) { 
        $ipBinary = Get-ToBinary $IPAddress 
        $smBinary = Get-CidrToBin($cidr) 
        $Netmask = Get-ToDottedDecimal($smBinary) 
        $wildcardbinary = Get-NetMasktoWildcard ($smBinary) 
        }
    else {
        Write-Warning 'Subnet Mask is invalid!' 
        Exit 
        }
    }
  else {
    if (!$Netmask) { 
        $Netmask = Read-Host 'Netmask' 
        }
    $ipBinary = Get-ToBinary $IPAddress 
    if ($Netmask -eq '0.0.0.0') { 
        Write-Warning 'Subnet Mask is invalid!' 
        Exit 
        }
    else { 
        $smBinary = Get-ToBinary $Netmask 
        $wildcardbinary = Get-NetMasktoWildcard ($smBinary) 
        }
    }
 
  $netBits=$smBinary.indexOf('0') 
  if ($netBits -ne -1) { 
    $cidr = $netBits 

    if(($smBinary.length -ne 32) -or ($smBinary.substring($netBits).contains('1') -eq $true)) { 
        Write-Warning 'Subnet Mask is invalid!' 
        Exit 
        }

    if(($ipBinary.length -ne 32) -or ($ipBinary.substring($netBits) -eq '00000000') -or ($ipBinary.substring($netBits) -eq '11111111')) { 
        Write-Warning 'IP Address is invalid!' 
        Exit 
        }

    $networkID = Get-ToDottedDecimal $($ipBinary.substring(0,$netBits).padright(32,'0')) 
    $firstAddress = Get-ToDottedDecimal $($ipBinary.substring(0,$netBits).padright(31,'0') + '1') 
    $lastAddress = Get-ToDottedDecimal $($ipBinary.substring(0,$netBits).padright(31,'1') + '0') 
    $broadCast = Get-ToDottedDecimal $($ipBinary.substring(0,$netBits).padright(32,'1')) 
    $wildcard = Get-ToDottedDecimal ($wildcardbinary) 
    $networkIDbinary = $ipBinary.substring(0,$netBits).padright(32,'0') 
    $broadCastbinary = $ipBinary.substring(0,$netBits).padright(32,'1') 
    $Hostspernet = ([convert]::ToInt32($broadCastbinary,2) - [convert]::ToInt32($networkIDbinary,2)) - 1 
   }
  else { 
    #identify subnet boundaries 
    $networkID = Get-ToDottedDecimal $($ipBinary) 
    $firstAddress = Get-ToDottedDecimal $($ipBinary) 
    $lastAddress = Get-ToDottedDecimal $($ipBinary) 
    $broadCast = Get-ToDottedDecimal $($ipBinary) 
    $wildcard = Get-ToDottedDecimal ($wildcardbinary) 
    $Hostspernet = 1 
    }

  $results = [pscustomobject]@{
    'IPAddress'  = $IPAddress
    'Netmask'    = "$($Netmask) = $($cidr)"
    'Wildcard'   = $wildcard
    'Network'    = "$($networkID)/$($cidr)"
    'Broadcast'  = $broadCast
    'HostMin'    = $firstAddress
    'HostMax'    = $lastAddress
    'Host/Net'   = $Hostspernet
  }
  $results
}