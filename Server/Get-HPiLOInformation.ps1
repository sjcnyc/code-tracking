  #Requires -Version 3.0 
  <# 
    .SYNOPSIS
      Retrieves iLO management controller firmware information
      for HP servers.

    .DESCRIPTION 
      The Get-HPiLOInformation function works through WMI and requires
      that the HP Insight Management WBEM Providers are installed on
      the server that is being quiered.
  
    .PARAMETER Computername
      The HP server for which the iLO firmware info should be listed.
      This parameter is optional and if the parameter isn't specified
      the command defaults to local machine.
      First positional parameter. 
  
    .NOTES 
      File Name  : Get-HPiLOInformation
      Author     : Sean Connealy
      Requires   : PowerShell Version 3.0 
      Date       : 2/18/2014
  
    .LINK 
      This script posted to: http://www.github/sjcnyc
  
    .EXAMPLE
      Get-HPiLOInformation
      Lists iLO firmware information for the local machine
  
    .EXAMPLE
      Get-HPiLOInformation SRV-HP-A
      Lists iLO firmware information for server SRV-HP-A
  
    .EXAMPLE
      "SRV-HP-A", "SRV-HP-B", "SRV-HP-C" | Get-HPiLOInformation
      Lists iLO firmware information for three servers  
  #>
  
function Get-HPiLOInformation
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
    [Parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position = 1)][string]$Computername=$env:computername
    )
 
    Process{
 
        if ($pscmdlet.ShouldProcess('Retrieve iLO information from server ' +$Computername)){
            $MpFirmwares =  Get-WmiObject -Computername $ComputerName -Namespace root\hpq -Query 'select * from HP_MPFirmware'
            ForEach ($fw in $MpFirmwares){
                $Mp = Get-WmiObject -Computername $ComputerName -Namespace root\hpq `
                 -Query ("ASSOCIATORS OF {HP_MPFirmware.InstanceID='" + $fw.InstanceID + "'} WHERE AssocClass=HP_MPInstalledFirmwareIdentity")
 
                $obj = @{
                  'ComputerName'     = $Computername
                  'ControllerName'   = $fw.Name
                }
 
                Switch ($Mp.HealthState){
                    5 {$stat = 'OK'; break}
                    10 {$stat = 'Degraded/Warning'; break}
                    20 {$stat = 'Major Failure'; break}
                    default {$stat = 'Unknown'}
                }

                $obj += $obj = @{
                  'HealthState'      = $stat
                  'UniqueIdentifier' = $Mp.UniqueIdentifier.Trim()
                  'Hostname'         = $Mp.Hostname
                  'IPAddress'        = $Mp.IPAddress
                } 
                 
                Switch ($Mp.NICCondition){
                    2 {$stat = 'OK'; break}
                    3 {$stat = 'Disabled'; break}
                    4 {$stat = 'Not in use'; break}
                    5 {$stat = 'Disconnected'; break}
                    6 {$stat = 'Failed'; break}
                    default {$stat = 'Unknown'}
                }

               $obj +=  $obj = @{
                  'NICCondition'     = $stat
                  'FirmwareVersion'  = $fw.VersionString
                  'ReleaseDate'      =($fw.ConvertToDateTime($fw.ReleaseDate))
                } 
                Write-Output $obj
            }
        }
    }
}
