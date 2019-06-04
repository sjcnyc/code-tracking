  #Requires -Version 3.0 
  <# 
  .SYNOPSIS  
  
  .DESCRIPTION  
  
  .NOTES 
      File Name  : Enable-OWAJunkEmailSetting
      Author     : Sean Connealy
      Requires   : PowerShell Version 3.0 
      Date       : 6/25/2015
  
  .LINK 
      This script posted to: http://www.github/sjcnyc
  
  .EXAMPLE
  
  #>
  

$global:ie = New-Object -com 'InternetExplorer.Application'
$global:ie.Navigate('about:blank')
$global:ie.visible = $true

Function Get-WaitForPage
{
   param
   (
     [int]
     $delayTime = 100
   )

  $loaded = $false
  
  while ($loaded -eq $false) {
    [System.Threading.Thread]::Sleep($delayTime) 
    
    #If the browser is not busy, the page is loaded
    if (-not $global:ie.Busy)
    {
      $loaded = $true
    }
  }
  
  $global:doc = $global:ie.Document
}

Function Get-NavigateTo
{
   param
   (
     [string]
     $url,

     [int]
     $delayTime = 100
   )

  Write-Verbose "Navigating to $url";
  
  $global:ie.Navigate($url)
  
  Get-WaitForPage $delayTime
}


Function Get-ClickElementById
{
   param
   (
     [Object]
     $id
   )

  $element = $global:doc.getElementById($id)
  if ($element -ne $null) {
    $element.Click()
    Get-WaitForPage
  }
  else {
    Write-Error "Couldn't find element with id ""$id"""
    break
  }
}

Get-NavigateTo -url 'http://nycmnet7ct001/owa/?ae=Options&t=JunkEmail' -delayTime 2
Get-ClickElementById -id 'rdoEnbl'
Get-ClickElementById -id 'lnkHdrsave'
