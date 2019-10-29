#requires -Version 2
function Get-IPInfo {
  param (
    [Parameter(ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True,
    Mandatory = $True)]
    [Alias('IP')]
    [STRING[]]$IPAddress,
    [Parameter(ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True,
    Mandatory = $True)]
    [Alias('Mask')]
    [int[]]$SubnetMask
  )
  BEGIN{}
     
  PROCESS{
    $TestIP = '8.8.8.8'
    If ([IPAddress]::TryParse($IPAddress,[ref]$TestIP)){Foreach ($IPAddress in $IPAddress) {GetIPInfo -IPAddr "$IPAddress" -mask "$SubnetMask"}} else {Write-Output -InputObject 'Please Enter a Valid IP'}
  }
  END{}
}
function GetIPInfo {
  param($IPAddr, $mask)
  $Class = $null
  $remainder = $null
  $IsPrivate = $False

  $IPSplit = $IPAddr.Split('.')
  $SimOctets = [math]::DivRem($mask,8,[ref]$remainder)
  $InvSub = [math]::Pow(2,(8 - $remainder))
  $Subnet = (256 - [math]::Pow(2,(8 - $remainder)))
  $UsableIP = [Math]::pow(2,(((3-$SimOctets)*8) + (8 - $remainder))) - 2
  If ((([math]::floor(($IPSplit[$SimOctets] / $InvSub))) * $InvSub) -eq $IPSplit[$SimOctets])
  {$GateIP = ([math]::floor(($IPSplit[$SimOctets] / $InvSub))) * $InvSub} else {$GateIP = ([math]::floor(($IPSplit[$SimOctets] / $InvSub))) * $InvSub + 1}

  if ($SimOctets -lt 3)
  {$SubnetMask = (([string]'255.') * $SimOctets)+ $Subnet + (([String]'.0')*(3 - $SimOctets))
  } else {$SubnetMask = (([string]'255.') * $SimOctets)+ $Subnet
  }

  $SimIP = $null
  For ( $b = ($SimOctets - $SimOctets); $b -lt $SimOctets; $b++)
  {$SimIP += $IPSplit[$b] + '.'}
  if ($SimOctets -lt 3)
  {
    $FinalIP = $SimIP + [String]($GateIP + $InvSub - 1) + (([String]'.0')*(2 - $SimOctets)) + ([String]'.254')
    $Gateway = $SimIP + [String]$GateIP + (([String]'.0')*(2 - $SimOctets)) + ([String]'.1')
    $BroadIP = $SimIP + [String]($GateIP + $InvSub - 1) + (([String]'.0')*(2 - $SimOctets)) + ([String]'.255')
  } else
  {
    $Gateway = $SimIP + $GateIP
    $FinalIP = $SimIP + ($GateIP + $InvSub - 3)
    $BroadIP = $SimIP + ($GateIP + $InvSub - 2)
  }


  If ($IPSplit[0] -eq 10)
  {
    $IsPrivate = $True
    $Class = 'A'
  } elseif ($IPSplit[0] -eq 172 -and ( 16 -ge $IPSplit[1] -le 31))
  {
    $IsPrivate = $True
    $Class = 'B'
  } elseif ($IPSplit[0] -eq 192 -and $IPSplit[1] -eq 168)
  {
    $IsPrivate = $True
  $Class = 'C'}

  [PSCustomObject]@{
    IPAddress     = $IPAddr
    SubnetMask    = $mask
    Netmask       = $SubnetMask
    FirstUsableIP = $Gateway
    LastUsableIP  = $FinalIP
    BroadcastIP   = $BroadIP
    IPRange       = ("$Gateway - $FinalIP")
    UsableIPs     = $UsableIP
    IsPrivate     = $IsPrivate
    Class         = $Class
  }

  $PC
}
#Get-IPInfo -IPAddress 192.168.2.5 -SubnetMask 24 

#New-Alias GIP Get-IPInfo

#Export-ModuleMember -Function Get-IPInfo
#Export-ModuleMember -alias GIP
