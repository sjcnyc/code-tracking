#Requires -Version 3.0
<#
  .SYNOPSIS


  .DESCRIPTION
  Clone AD users Security Groups to test AD user account.

  .NOTES
  File Name  : Get-CloneUserGroups
  Author     : Sean Connealy
  Requires   : PowerShell Version 3.0
  Date       : 3/12/2015

  .LINK
  This script posted to: https://gist.github.com/sjcnyc/7c22f174842bb00ad173

  .EXAMPLE

  .EXAMPLE

#>


function Get-Dots
{
  $dot = $_.samaccountname.length
  1..(60 - $dot) | ForEach-Object -Process {
    Write-Host -Object '.' -NoNewline
  }
  Write-Host -Object '[ OK ]'
}

function Get-CloneUserGroups
{
  [cmdletBinding(SupportsShouldProcess = $True)]
  param (
    [Parameter(Mandatory = $True, ValueFromPipeline = $True)][string]$CloneFrom,
  [Parameter(Mandatory = $True, ValueFromPipeline = $True)][string]$CloneTo)
  process {
    Clear-Host
    $erroractionpreference = 'silentlycontinue'
    Write-Host -Object "Removing $($CloneTo) Security Groups"
    $null = Get-QADUser -Identity $CloneTo |
    Get-QADMemberOf |
    ForEach-Object -Process {
      Write-Host '- '$_.samaccountname -NoNewline -ForegroundColor Red
      Remove-QADGroupMember -Identity $_ -Member $CloneTo
      Get-Dots
    }
    Write-Host -Object ''
    Write-Host -Object "Cloning $($CloneFrom) Security groups"
    $null = Get-QADUser -Identity $CloneFrom |
    Get-QADMemberOf |
    ForEach-Object -Process {
      Write-Host '+ '$_.samaccountname -NoNewline -ForegroundColor Green
      Add-QADGroupMember -Identity $_ -Member $CloneTo
      Get-Dots
    }
  }
}