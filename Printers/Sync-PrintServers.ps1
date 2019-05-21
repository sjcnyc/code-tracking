function Sync-PrintServers  {
  <#
    .SYNOPSIS
    Backup, Restore, or Sync Print Servers

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
    [Parameter(Mandatory)]$PrintServer,
    [Parameter(Mandatory)][ValidateSet('Backup','Restore', 'Sync')][string]$Operation,
    [Parameter(Mandatory)]$SavePath,
    [Parameter(Mandatory)]$File
  )

  $currentDate = (get-date -Format MM-dd-yyyy)

  Set-Location -Path 'C:\Windows\System32\spool\tools' # path to printbrm.exe

  switch($Operation) {
    Backup {
      $PrintServer |
      ForEach-Object -Process {Start-Process 'printbrm.exe' -ArgumentList "-S \\$($PrintServer) -B -f $($SavePath)\$($File)_$($currentDate).printerExport" -Wait
      }
    }
    Restore {
      $PrintServer |
      ForEach-Object -Process {Start-Process 'printbrm.exe' -ArgumentList "-S \\$($PrintServer) -R -f $($SavePath)\$($File).printerExport" -Wait
      }
    }
    Sync {
       Write-Verbose -Message 'Not emplemented yet'
    }
  }
}


# Print servers 
@"
usnaspwfs01
"@ -split [environment]::NewLine | ForEach-Object {

  Sync-PrintServers -PrintServer $_ -Operation Backup -SavePath '\\storage\infradev$\PrintServer_Backups\' -File $_

}

#Sync-PrintServers -PrintServer "USDF48E38ABF907" -Operation Backup -SavePath '\\USDF48E38ABF907\c$\Temp' -File 'printer_bak'

#Sync-PrintServers -PrintServer 'USCULVWPRT005' -Operation Restore -SavePath '\\storage\infradev$\PrintServer_Backups\' -File 'usnycvwprt306_04-04-2017'
#Sync-PrintServers -PrintServer 'USCULVWPRT006' -Operation Restore -SavePath '\\storage\infradev$\PrintServer_Backups\' -File 'usnycvwprt001_04-04-2017' #>

<#
usnycvwprt306
usbvhpwfs01
usnaspwfs01
usnycvwprt002
usnycvwprt001
#>