function Sync-PrintServers {
  [CmdletBinding()]
  <#
    .SYNOPSIS
    Backup, Restore, Print Servers

    .DESCRIPTION
    For use in the automated backup and restore of print servers

    .PARAMETER PrintServer
    Describe parameter -PrintServer.

    .PARAMETER Operation
    Describe parameter -Operation.

    .PARAMETER SavePath
    Describe parameter -SavePath.

    .PARAMETER File
    Describe parameter -File.

    .EXAMPLE
    Sync-PrintServers -PrintServer Value -Operation Value -SavePath Value -File Value
    Describe what this call does

    .NOTES
    File Name  : Sync-PrintServers.ps1
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0
    Date       : 1/15/2013

    .LINK
    This script posted to: http://www.github/sjcnyc

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>
  param
  (
    [parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)]
    [string]
    $PrintServer,

    [Parameter(Mandatory = $true, Position = 1)]
    [ValidateSet('Backup', 'Restore')]
    [string]
    $Operation,

    [Parameter(Mandatory = $true, Position = 2)]
    $SavePath,

    [Parameter(Mandatory = $true, Position = 3)]
    $File
  )

  $currentDate = (Get-Date -Format MM-dd-yyyy)

  Set-Location -Path 'C:\Windows\System32\spool\tools' # path to printbrm.exe

  switch ($Operation) {
    Backup {
      $PrintServer |
      ForEach-Object -Process {
        Start-Process 'printbrm.exe' -ArgumentList "-S \\$($PrintServer) -B -f $($SavePath)\$($File)_$($currentDate).printerExport" -Wait
      }
    }
    Restore {
      $PrintServer |
      ForEach-Object -Process {
        Start-Process 'printbrm.exe' -ArgumentList "-S \\$($PrintServer) -R -f $($SavePath)\$($File).printerExport" -Wait
      }
    }
  }
}

# Print servers 
@"
usculvwprt403
"@ -split [environment]::NewLine | ForEach-Object {
  Sync-PrintServers -PrintServer $_ -Operation Backup -SavePath '\\storage.me.sonymusic.com\data$\infra_dev\PrintServer_Backups' -File $_
}
