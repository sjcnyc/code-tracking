<# 
    .Author 
    Abdul Wajid 
    .SYNOPSIS 
    Queries a remote iLO interface for fimware version and initiates the upgrade if its having an old version
    .DESCRIPTION 
    Queries a remote iLO interface for fimware version and initiates the upgrade if its having an old version
    #> 
#Import POSH-SSH Module 
Import-Module -Name Posh-SSH

#iLO Firmware binary path. You can create a small webserver. There are plenty of tiny webservers avialble that you can use. I used Fenix.
$v2 = 'http://webserver/ilo2_229.bin'
$v3 = 'http://webserver/ilo3_188.bin'
$v4 = 'http://webserver/ilo4_250.bin'

#Get iLO Admin credentials and pass them on to a variable.
$iloCreds = Get-Credential
#Get the list of iLO Management Processors.
$servers = Get-Content C:\CSV\ilo_addresses_all.txt

ForEach($server in $servers)

{
#Create an SSH Session with the remote server through iLO interface

#Get the Current FIrmware version information using Invoke-Webrequest
[xml]$XMLOutput = Invoke-WebRequest "http://$server/xmldata?item=All"
$CurrentVersion = $XMLOutput.RIMP.MP

#iLO Version confirmation for Version 2
if($CurrentVersion.PN -match 'iLO 2')
{
    #Validate whether a firmware upgrade is required. You can change the values as per the new binary availability.
    if($CurrentVersion.FWRI -eq '2.29')
    {
    Write-Host "$Server is already updated with latest Firmware" $CurrentVersion.PN $CurrentVersion.FWRI -ForegroundColor Green
    }
    if($CurrentVersion.FWRI -ne '2.29')
    {
    Write-Host "$server is having an old firmware version" $CurrentVersion.PN $CurrentVersion.FWRI -ForegroundColor Red
    Write-Host "Initiating the Upgrade Process..." -ForegroundColor Green
    #Create an SSH Session to initiate firmware upgrade commands
    $SSHSession = New-SSHSession -ComputerName $server -Credential $iloCreds -Verbose -AcceptKey -ConnectionTimeout 2000
    $Command = Invoke-SSHCommand -Command "cd /map1/firmware1" -SessionId $SSHSession.SessionId -Verbose -TimeOut 2000
    $Command.output
    $Command = $null
    $Command = Invoke-SSHCommand -Command "load -source $v2" -SessionId $SSHSession.SessionId -Verbose -TimeOut 2000
    $Command.output
    #Remove the SSH Session
    Remove-SSHSession -SessionId $SSHSession.SessionId
    }
}


#iLO Version confirmation for Version 3
if($CurrentVersion.PN -match 'iLO 3')
{
    #Validate whether a firmware upgrade is required. You can change the values as per the new binary availability.
    if($CurrentVersion.FWRI -eq '1.88')
    {
    Write-Host "$Server is already updated with latest Firmware" $CurrentVersion.PN $CurrentVersion.FWRI -ForegroundColor Green
    }
    else
    {
    Write-Host "$server is having an old firmware version" $CurrentVersion.PN $CurrentVersion.FWRI -ForegroundColor Red
    Write-Host "Initiating the Upgrade Process..." -ForegroundColor Green
    #Create an SSH Session to initiate firmware upgrade commands
    $SSHSession = New-SSHSession -ComputerName $server -Credential $iloCreds -Verbose -AcceptKey -ConnectionTimeout 2000
    $Command = Invoke-SSHCommand -Command "cd /map1/firmware1" -SessionId $SSHSession.SessionId -Verbose -TimeOut 2000
    $Command.output
    $Command = $null
    $Command = Invoke-SSHCommand -Command "load -source $v3" -SessionId $SSHSession.SessionId -Verbose -TimeOut 2000
    $Command.output
    #Remove the SSH Session
    Remove-SSHSession -SessionId $SSHSession.SessionId
    }

}

#iLO Version confirmation for Version 4
if($CurrentVersion.PN -match 'iLO 4')
{
    #Validate whether a firmware upgrade is required. You can change the values as per the new binary availability.
    if($CurrentVersion.FWRI -eq '2.50')
    {
    Write-Host "$Server is already updated with latest Firmware" $CurrentVersion.PN $CurrentVersion.FWRI -ForegroundColor Green
    }

    else
    {
    Write-Host "$server is having an old firmware version" $CurrentVersion.PN $CurrentVersion.FWRI -ForegroundColor Red
    Write-Host "Initiating the Upgrade Process..." -ForegroundColor Green
    #Create an SSH Session to initiate firmware upgrade commands
    $SSHSession = New-SSHSession -ComputerName $server -Credential $iloCreds -Verbose -AcceptKey -ConnectionTimeout 2000
    $Command = Invoke-SSHCommand -Command "cd /map1/firmware1" -SessionId $SSHSession.SessionId -Verbose -TimeOut 2000
    $Command.output
    $Command = $null
    $Command = Invoke-SSHCommand -Command "load -source $v4" -SessionId $SSHSession.SessionId -Verbose -TimeOut 2000
    $Command.output
    #Remove the SSH Session
    Remove-SSHSession -SessionId $SSHSession.SessionId  
      }
}

$SSHSession = $null
$Command = $null
}

