<#
    .SYNOPSIS
    <This is a small script that will launch different AD and Exchange MMC Consoles. v2>
    .DESCRIPTION
    <When the script is launched you will be presented with a series of options to chose from, after you chose the appropriate option it will launch the appropriate mmc console.>
    .PARAMETER <paramName>
    <Description of script parameter>
    .EXAMPLE
    <./Get-MMC>
#>
 
Function MMC-ADUSERS
{
  param([int]$a)
  switch ($a)
  {
    1 {Start-Process -FilePath $env:windir\system32\mmc.exe -ArgumentList $env:windir\system32\dsa.msc -Credential $cred}
    2 {Start-Process -FilePath $env:windir\system32\mmc.exe -ArgumentList $env:windir\system32\gpmc.msc -Credential $cred}
    3 {     $argList = '-noexit -command',". 'C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto"
      Start-Process powershell.exe -ArgumentList $argList -Credential $cred
    }
    4 {Start-Process -FilePath $env:windir\system32\mmc.exe -ArgumentList $env:windir\system32\ServerManager.msc -Credential $cred}
    5 { $argList2 = '-noexit -command','Import-Module ActiveDirectory'
    Start-Process powershell.exe -ArgumentList $argList2 -Credential (Get-Credential)}
    6 {Start-Process -FilePath $env:windir\system32\mmc.exe -ArgumentList $env:windir\system32\dnsmgmt.msc -Credential $cred}
    7 {Start-Process -FilePath $env:windir\system32\mmc.exe -ArgumentList $env:windir\system32\dsac.msc -Credential $cred}
    8 {Start-Process -FilePath $env:windir\system32\mmc.exe -ArgumentList $env:windir\system32\dssite.msc -Credential $cred}
  }
}
Function xCheck
{
  param([int]$b)
  if($b -ge 1 -and $b -le 8)
  {
    MMC-ADUSERS $b
    OptionList
  }
  elseif ($b -eq 9)
  {
    Write-Host 'EXITING' -ForegroundColor 'RED'
    exit
  }
  else
  {
    Write-Host 'You inserted an incorrect selection, please choose again.'
    OptionList
  }
}
Function OptionList
{ Clear-Host;
  @"
1: Users and Computers--MMC
2: Group Policy Management--MMC
3: Exchange Management Shell--Powershell
4: Server Manager--MMC
5: Active Directory Management Shell--Powershell
6: DNS Management--MMC
7: Active Directory Administrative Center MMC
8: AD Sites and Service--MMC
9: EXIT
"@
  $x = Read-Host 'Please choose 1 - 9'
  xCheck $x
}
Clear-Host;
$cred = Get-Credential
OptionList