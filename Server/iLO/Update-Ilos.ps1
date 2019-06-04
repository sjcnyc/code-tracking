
Import-Module -Name Posh-SSH

$v2 = '\\storage\infradev$\iloFW\ilo2_229.bin'
$v3 = '\\storage\infradev$\iloFW\ilo3_188.bin'
$v4 = '\\storage\infradev$\iloFW\ilo4_250.bin'
 

$iloCreds = Get-Credential

$servers = Get-Content C:\CSV\ilo_addresses_all.txt
 
ForEach($server in $servers){

[xml]$XMLOutput = Invoke-WebRequest "http://$server/xmldata?item=All"
$CurrentVersion = $XMLOutput.RIMP.MP
 

if($CurrentVersion.PN -match 'iLO 2')
{
    if($CurrentVersion.FWRI -eq '2.29')
    {
    Write-Host "$Server is already updated with latest Firmware" $CurrentVersion.PN $CurrentVersion.FWRI -ForegroundColor Green
    }
    if($CurrentVersion.FWRI -ne '2.29')
    {
    Write-Host "$server is having an old firmware version" $CurrentVersion.PN $CurrentVersion.FWRI -ForegroundColor Red
    Write-Host "Initiating the Upgrade Process..." -ForegroundColor Green

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