﻿$objResult = @()
$result=@()
$subnet = Ping-Subnet -IP 10.12.96.1 -Netmask 255.255.255.0 -ErrorAction SilentlyContinue

<#$subnet=@"
10.12.96.1
"@ -split [environment]::NewLine#>




foreach ($ip in $subnet) {
$objResult = $null
$rawxml = $null
$xd = $null
 $tp = Test-Port -ComputerName $ip -TCPport 17988

 if ($tp -eq $true) {
 # $result = [System.Net.Dns]::gethostentry($ip)

  [System.Xml.XmlDocument] $xd = new-object System.Xml.XmlDocument
  $url = "http://$ip/xmldata?item=ALL"
  $rawxml = (new-object System.Net.WebClient).DownloadString($url)
  $xd = $rawxml
 
  $ilo = new-object System.Object
  #$ilo | Add-Member -MemberType NoteProperty -Name Computername -Value $result.HostName
  $ilo | add-member -MemberType NoteProperty -Name iloIP -value $ip
  $ilo | add-member -MemberType NoteProperty -Name iloHW $xd.RIMP.MP.PN
  $ilo | add-member -MemberType NoteProperty -Name iloFW $xd.RIMP.MP.FWRI
  $ilo | add-member -MemberType NoteProperty -Name ServerSN $xd.RIMP.MP.SN
  $ilo | add-member -MemberType NoteProperty -Name ServerModel $xd.RIMP.HSI.SPN
 
  $objResult += $ilo

  $objResult
 
}
else {
 write-host "$ip is not iLo"
 }
 }



$objResult #| export-csv c:\temp\ilo.csv -NoTypeInformation


#requires -Version 2.0
Function Ping-Subnet {
    #.Synopsis
    # Ping a subnet returning all alive hosts.
    #.Example
    # Ping-Subnet -IP 192.168.1.0 -Netmask /24
    #.Example
    # Ping-Subnet -IP 192.168.1.128 -Netmask 255.255.255.128
    Param(
        [string]
        $IP,
        [string]
        $netmask
    )
    Begin {
        $IPs = New-Object System.Collections.ArrayList
        $Jobs = New-Object System.Collections.ArrayList
        $max = 50
        
        Function Get-NetworkAddress {
            #.Synopsis 
            # Get the network address of a given lan segment
            #.Example 
            # Get-NetworkAddress -IP 192.168.1.36 -mask 255.255.255.0
            Param (
                [string]
                $IP, 
                
                [string]
                $Mask, 
                
                [switch]
                $Binary
            )
            Begin {
                $NetAdd = $null
            }
            Process {
                $BinaryIP = ConvertTo-BinaryIP $IP
                $BinaryMask = ConvertTo-BinaryIP $Mask
                0..34 | %{
                    $IPBit = $BinaryIP.Substring($_,1)
                    $MaskBit = $BinaryMask.Substring($_,1)
                    IF ($IPBit -eq '1' -and $MaskBit -eq '1') {
                        $NetAdd = $NetAdd + '1'
                    } elseif ($IPBit -eq '.') {
                        $NetAdd = $NetAdd +'.'
                    } else {
                        $NetAdd = $NetAdd + '0'
                    }
                }
                if ($Binary) {
                    return $NetAdd
                } else {
                    return ConvertFrom-BinaryIP $NetAdd
                }
            }
        }
        
        Function ConvertTo-BinaryIP {
            #.Synopsis
            # Convert an IP address to binary
            #.Example 
            # ConvertTo-BinaryIP -IP 192.168.1.1
            Param (
                [string]
                $IP
            )
            Process {
                $out = @()
                Foreach ($octet in $IP.split('.')) {
                    $strout = $null
                    0..7|% {
                        IF (($octet - [math]::pow(2,(7-$_)))-ge 0) { 
                            $octet = $octet - [math]::pow(2,(7-$_))
                            [string]$strout = $strout + '1'
                        } else {
                            [string]$strout = $strout + '0'
                        }   
                    }
                    $out += $strout
                }
                return [string]::join('.',$out)
            }
        }


        Function ConvertFrom-BinaryIP {
            #.Synopsis 
            # Convert from Binary to an IP address
            #.Example 
            # Convertfrom-BinaryIP -IP 11000000.10101000.00000001.00000001
            Param (
                [string]
                $IP
            )
            Process {
                $out = @()
                Foreach ($octet in $IP.split('.')) {
                    $strout = 0
                    0..7|% {
                        $bit = $octet.Substring(($_),1)
                        IF ($bit -eq 1) { 
                            $strout = $strout + [math]::pow(2,(7-$_))
                        } 
                    }
                    $out += $strout
                }
                return [string]::join('.',$out)
            }
        }

        Function ConvertTo-MaskLength {
            #.Synopsis 
            # Convert from a netmask to the masklength
            #.Example 
            # ConvertTo-MaskLength -Mask 255.255.255.0
            Param (
                [string]
                $mask
            )
            Process {
                $out = 0
                Foreach ($octet in $Mask.split('.')) {
                    $strout = 0
                    0..7|% {
                        IF (($octet - [math]::pow(2,(7-$_)))-ge 0) { 
                            $octet = $octet - [math]::pow(2,(7-$_))
                            $out++
                        }
                    }
                }
                return $out
            }
        }

        Function ConvertFrom-MaskLength {
            #.Synopsis 
            # Convert from masklength to a netmask
            #.Example 
            # ConvertFrom-MaskLength -Mask /24
            #.Example 
            # ConvertFrom-MaskLength -Mask 24
            Param (
                [int]
                $mask
            )
            Process {
                $out = @()
                [int]$wholeOctet = ($mask - ($mask % 8))/8
                if ($wholeOctet -gt 0) {
                    1..$($wholeOctet) |%{
                        $out += '255'
                    }
                }
                $subnet = ($mask - ($wholeOctet * 8))
                if ($subnet -gt 0) {
                    $octet = 0
                    0..($subnet - 1) | %{
                         $octet = $octet + [math]::pow(2,(7-$_))
                    }
                    $out += $octet
                }
                for ($i=$out.count;$i -lt 4; $I++) {
                    $out += 0
                }
                return [string]::join('.',$out)
            }
        }
        Function Get-IPRange {
            #.Synopsis 
            # Given an Ip and subnet, return every IP in that lan segment
            #.Example 
            # Get-IPRange -IP 192.168.1.36 -Mask 255.255.255.0
            #.Example 
            # Get-IPRange -IP 192.168.5.55 -Mask /23
            Param (
                [string]
                $IP,
                
                [string]
                $netmask
            )
            Process {
                iF ($netMask.length -le 3) {
                    $masklength = $netmask.replace('/','')
                    $Subnet = ConvertFrom-MaskLength $masklength
                } else {
                    $Subnet = $netmask
                    $masklength = ConvertTo-MaskLength -Mask $netmask
                }
                $network = Get-NetworkAddress -IP $IP -Mask $Subnet 
                
                [int]$FirstOctet,[int]$SecondOctet,[int]$ThirdOctet,[int]$FourthOctet = $network.split('.')
                $TotalIPs = ([math]::pow(2,(32-$masklength)) -2)
                $blocks = ($TotalIPs - ($TotalIPs % 256))/256
                if ($Blocks -gt 0) {
                    1..$blocks | %{
                        0..255 |%{
                            if ($FourthOctet -eq 255) {
                                If ($ThirdOctet -eq 255) {
                                    If ($SecondOctet -eq 255) {
                                        $FirstOctet++
                                        $secondOctet = 0
                                    } else {
                                        $SecondOctet++
                                        $ThirdOctet = 0
                                    }
                                } else {
                                    $FourthOctet = 0
                                    $ThirdOctet++
                                }  
                            } else {
                                $FourthOctet++
                            }
                            Write-Output ('{0}.{1}.{2}.{3}' -f `
                            $FirstOctet,$SecondOctet,$ThirdOctet,$FourthOctet)
                        }
                    }
                }
                $sBlock = $TotalIPs - ($blocks * 256)
                if ($sBlock -gt 0) {
                    1..$SBlock | %{
                        if ($FourthOctet -eq 255) {
                            If ($ThirdOctet -eq 255) {
                                If ($SecondOctet -eq 255) {
                                    $FirstOctet++
                                    $secondOctet = 0
                                } else {
                                    $SecondOctet++
                                    $ThirdOctet = 0
                                }
                            } else {
                                $FourthOctet = 0
                                $ThirdOctet++
                            }  
                        } else {
                            $FourthOctet++
                        }
                        Write-Output ('{0}.{1}.{2}.{3}' -f `
                        $FirstOctet,$SecondOctet,$ThirdOctet,$FourthOctet)
                    }
                }
            }
        }
    }
    Process {
        #get every ip in scope
        Get-IPRange $IP $netmask | %{
            [void]$IPs.Add($_)
        }
        #loop untill we've pinged them all
        While ($IPs.count -gt 0 -or $jobs.count -gt 0) {
            #if we have open spots kick off some more
            IF ($jobs.count -le $max) {
                # determin how many to kick off
                $addjobs = ($max - $jobs.count)
                Foreach ($IP in ($IPS | Select -first $addjobs)) {
                    #save the job id, and move on
                    [VOID]$Jobs.Add((gwmi -q "SELECT Address,StatusCode FROM Win32_Pingstatus WHERE Address = `'$IP`'" -asjob).Id)
                    #remove the IP from our pool
                    $IPs.Remove($IP)
                }
            }
            #we'll use this array to track what's comeback
            $Clean = @()
            
            Foreach ($J in $jobs) {
                # If this job is done get the results
                if ((Get-Job -id $j).JobStateInfo.state -eq 'Completed') {
                    # if the ping was sucessfull return the IP Address
                    write-output (Receive-Job -id $j) | ?{$_.StatusCode -eq 0}| select -expand Address
                    # dispose of the job
                    remove-job -id $j
                    $clean += $j
                }
            }
            Foreach ($c in $Clean) {
                #remove the jobs that we just processed
                $jobs.remove($c)
            }
        }
    }
}