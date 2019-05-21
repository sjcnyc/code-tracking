#Requires -Version 2
<# 
    .SYNOPSIS
      Generates a random password

    .DESCRIPTION

    .NOTES 
    File Name  : New-RandomPassword.ps1
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0 
    Date       : 7/7/2015

    .LINK 
    This script posted to: http://www.github/sjcnyc

    .EXAMPLE
      New-RandomPassword -Length 20
#>

function New-RandomPassword 
{
  [CmdletBinding()]
  param(
    [int]$Length=15
  )

  $PassCharCodes = {
    33..126
  }.invoke()

  #Exclude ",',/,`,O,0
  34, 39, 47, 96, 48, 79 | ForEach-Object -Process {
    [void]$PassCharCodes.Remove($_)
  }

  $PassChars = [char[]]$PassCharCodes 

  do 
  { 
    $NewPass = $(foreach ($i in 1..$Length) 
      {
        Get-Random -InputObject $PassChars
      }
    ) -join '' 
  }

  until (
    ( $NewPass -cmatch '[A-Z]' ) -and
    ( $NewPass -cmatch '[a-z]' ) -and
    ( $NewPass -imatch '[0-9]' ) -and 
    ( $NewPass -imatch '[^A-Z0-9]' )
  ) 
        
  $NewPass 
}