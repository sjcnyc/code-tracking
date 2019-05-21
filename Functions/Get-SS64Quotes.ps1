#Requires -Version 3.0 
<# 
    .SYNOPSIS

    .DESCRIPTION
 
    .NOTES 
        File Name  : 
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 4/14/2015

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE

#>

function Get-SS64Quotes
{
  param(
        [ValidateSet('Powershell','CMD','VBScript')] 
        [String]$language, 
        [string]$command
  )

  Switch ($language) {
        'Powershell' { $code='ps'}
        'CMD' {  $code='cmd'}
        'VBScript' { $code='vb'}
    } #switch
  $command = $command.ToLower()
  $geturl = Invoke-WebRequest -uri "ss64.com/$code/$command.html"

  $quote = $geturl.AllElements | Where-Object { $_.Class -eq 'quote' } | Select-Object innertext

  Write-Host $quote.innerText
  Get-Help $command
}