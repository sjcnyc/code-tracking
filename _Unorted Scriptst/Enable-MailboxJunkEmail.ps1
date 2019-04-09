#Requires -Version 3.0 
<# 
    .SYNOPSIS
        Enable or Disable Junk Email Filter on OWA via IExplorer COM automation
    
    .DESCRIPTION
        Enable or Disable Junk Email Filter on OWA via IExplorer COM automation

    .PARAMS
         casServer: Name of Exchange CAS server
         emailFile: Path to plain text file containing email addresses
         logFile:   Path and log file name (will be created if not exist)
         filter:    Junk email filter validation set, selections: Enable ? Disable 
         delay:     Generalt tick count (1000 = 1 second)

    .NOTES 
        File Name  : Enable-MailboxJunkEmail.ps1
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 9/30/2015
    
    .LINK 
    This script posted to: http://www.github/sjcnyc
    
    .EXAMPLE
        Enable-MailboxJunkEmail
                    
    .EXAMPLE
        Enable-MailboxJunkEmail -casServer 'NYCMNET7CT001' -emailFile 'C:\TEMP\email.txt' -logfile 'C:\TEMP\newLog.txt' -filter Disable -delay '3000'
#>
function Get-Log
{
    param (
        [Object]$string,
        [Object]$color 
    )
    if ($color -eq $null) 
    {
        $color = 'white'
    }
    Write-Host -Object $string -ForegroundColor $color
    $string | Out-File -FilePath $logfile -Append
}

function Get-WaitForPage
{
    param (
        [int]$delayTime = 100 
    )
    $loaded = $false  
    while ($loaded -eq $false) 
    {
        [System.Threading.Thread]::Sleep($delayTime)     
        #If the browser is not busy, the page is loaded
        if (-not $global:ie.Busy)
        {
            $loaded = $true
        }
    }  
    $global:doc = $global:ie.Document
}
function Get-NavigateTo
{
    param(   
        [string] $url,
        [int]$delayTime = 100 
    )
    Get-Log -string "Navigating to $($url)" -color Green
    $global:ie.Navigate($url)  
    Get-WaitForPage -delayTime $delayTime
}
function Get-ClickElementById
{
    param( 
        [Object]$id,
        [int]$delayTime = 100 
    )

    $element = $global:doc.getElementById($id)
    if ($element -ne $null) 
    {
        $element.Click()
        Get-Log -string "Found element ID: $($id)" -color Green
        Get-WaitForPage
    }
    else 
    {
        Get-Log -string "Couldn't find element with ID: $($id)" -color Red
        Get-Log -string 'Operation not successful' -color Red
        Get-Log -string ''
    }
}

function Get-IEURL {
    Param([switch]$Full, [switch]$Location, [switch]$Content)
    $urls = (New-Object -ComObject Shell.Application).Windows() |
    Where-Object {$_.LocationUrl -match '(^https?://.+)'} |
    Where-Object {$_.LocationUrl}
    if($Full)
    {
        $urls
    }
    elseif($Location)
    {
        $urls | Select-Object Location*
    }
    elseif($Content)
    {
        $urls | ForEach-Object {
            $ie.LocationName;
            $ie.LocationUrl;
            $_.Document.body.innerText
        }
    }
    else
    {
        $urls | ForEach-Object {$_.LocationUrl}
    }
}

function Enable-MailboxJunkEmail {
    Param(
        [string] $casServer = 'nycmnet7ct001',
        [string] $emailFile = 'C:\TEMP\email.txt',
        [string] $logfile = 'C:\TEMP\EnableSpam_.txt',
        [ValidateSet('Enable','Disable')] [String] $filter = 'Enable',
        [int] $delay = '2000'
    )

    $users = Get-Content -LiteralPath $emailFile

    # instantiate internet explorer
    $global:ie = New-Object -ComObject 'InternetExplorer.Application'
    Enable-MailboxJunkEmail 
    # this could be set to false to avoid privacy issues maybe?
    $global:ie.visible = $true
    do 
    {
        Start-Sleep -Seconds 5 
    }
    while ( $ie.busy )

    foreach ($user in $users)
    {
        Get-Log -string "User: $($user)"
        Get-NavigateTo -url "http://$($casServer)/owa/$($user)" -delayTime $delay
        Get-WaitForPage -delayTime $delay
        $URL = Get-IEURL -Location
        if ($URL.LocationURL -eq "http://$($casServer)/owa/$($user)/") {
            Get-NavigateTo -url "http://$($casServer)/owa/$($user)/?ae=Options&t=JunkEmail" -delayTime $delay
            if ($filter -eq 'Enable'){
                Get-ClickElementById -id 'rdoEnbl' -delayTime $delay
            }
            if ($filter -eq 'Disable') {
                Get-ClickElementById -id 'rdoDsbl' -delayTime $delay
            }
            if ($global:doc.getElementByID('lnkHdrsave')) { 
                Get-ClickElementById -id 'lnkHdrsave' -delayTime $delay
                Get-Log -string 'Operation successful' -color Green
                Get-Log -string ''
            }
            else {
                Get-NavigateTo -url "http://$($casServer)/owa/$($user)/?ae=Options&opturl=Messaging" -delayTime $delay
                if ($global:doc.getElementByID('save')) {
                    Get-ClickElementById -id 'save' -delayTime $delay  
                    Get-Log -string 'Operation successful' -color Green
                    Get-Log -string ''
                }
                Get-WaitForPage -delayTime $delay
            }
        }
        else {
            Get-Log -string "$($user) has never logged onto OWA"
            Get-Log -string ''
            Get-WaitForPage -delayTime $delay
        }
    }
}