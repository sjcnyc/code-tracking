#requires -Version 1
$logfile = 'C:\Temp\EnableSpam_.txt'
 
function Get-Log
{
    param
    (
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

# instantiate internet explorer
$global:ie = New-Object -ComObject 'InternetExplorer.Application'

# this could be set to false to avoid privacy issues maybe?
$global:ie.visible = $true

do 
{
    Start-Sleep -Seconds 5 
}
while ( $ie.busy )
Function Get-WaitForPage
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
  <#  $global:doc = $global:ie.Document #>
 }
Function Get-NavigateTo
{
    param(   
        [string] $url,
         [int]$delayTime = 100 
         )
    Get-Log -string "Navigating to $($url)" -color Green
    $global:ie.Navigate($url)  
    Get-WaitForPage -delayTime $delayTime
}
Function Get-ClickElementById
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
        $global:ie.Application.Quit()
        Get-Log -string ''
        break
    }
}

$casServer = 'http://nycmnet7ct001'

# add user email addresses to here string.  no spaces between @""@
$users = @"
sconnea@sonymusic.com
"@ -split[environment]::NewLine

foreach ($user in $users)
{
    Get-Log -string "User: $($user)"
    Get-NavigateTo -url "$($casServer)/owa/$($user)" -delayTime 1000
    Get-NavigateTo -url "$($casServer)/owa/$($user)/?ae=Options&t=JunkEmail" -delayTime 1000
    Get-ClickElementById -id 'rdoEnbl' -delayTime 100
   # Get-ClickElementById -id 'rdoDsbl' -delayTime 100 # uncomment to disable, comment above rdoEnbl
    Get-NavigateTo -url "$($casServer)/owa/$($user)/?ae=Options&opturl=Messaging" -delayTime 1000
    Get-ClickElementById -id 'save' -delayTime 100
    Get-Log -string 'Operation successful' -color Green
    Get-Log -string ''
    $global:ie.Application.Quit()
}
