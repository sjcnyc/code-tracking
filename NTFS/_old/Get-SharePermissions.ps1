#requires -Version 2
function Get-SharePerms{
  [cmdletbinding(
      DefaultParameterSetName = 'computer',
      ConfirmImpact = 'low'
  )]
  Param(
    [Parameter(
        Mandatory = $True,
        Position = 0,
        ParameterSetName = 'computer',
    ValueFromPipeline = $True)]
    [String[]]$ComputerName,
    [Parameter(
        Mandatory = $False,
        Position = 1,
        ParameterSetName = 'computer',
    ValueFromPipeline = $False)]  
    [String[]]$ShareName
  )
  Begin {
    $sharereport = @()  
  }  
  Process {
    ForEach ($target in $ComputerName) {
      Try {
        $ShareSec = Get-WmiObject -Class Win32_LogicalShareSecuritySetting -ComputerName $target -ea stop
        if ($ShareName)
        {$ShareSec = @($ShareSec | Where-Object -FilterScript {$ShareName -contains $_.name } )}
                    
        ForEach ($Shares in $ShareSec) {  
          Write-Verbose -Message "Share: $($Shares.name)"
          $SecurityDescriptor = $Shares.GetSecurityDescriptor()
          ForEach ($DACL in $SecurityDescriptor.Descriptor.DACL) {
            $arrshare = New-Object -TypeName PSObject
            $arrshare | Add-Member NoteProperty 'ComputerName' $target
            $arrshare | Add-Member NoteProperty 'ShareName' $Shares.Name 
            $arrshare | Add-Member NoteProperty 'UserID' $DACL.Trustee.Name
            Switch ($DACL.AccessMask) {
              2032127 {$AccessMask = 'FullControl'}
              1179785 {$AccessMask = 'Read'}
              1180063 {$AccessMask = 'Read, Write'}
              1179817 {$AccessMask = 'ReadAndExecute'}
              -1610612736 {$AccessMask = 'ReadAndExecuteExtended'}
              1245631 {$AccessMask = 'ReadAndExecute, Modify, Write'}
              1180095 {$AccessMask = 'ReadAndExecute, Write'}
              268435456 {$AccessMask = 'FullControl (Sub Only)'}
              default {$AccessMask = $DACL.AccessMask}
            }  
            $arrshare | Add-Member NoteProperty 'Permission' $AccessMask
            Switch ($DACL.AceType) {
              0 {$AceType = 'Allow'}
              1 {$AceType = 'Deny'}
              2 {$AceType = 'Audit'}
            }
            $arrshare | Add-Member NoteProperty 'Type' $AceType
            $sharereport += $arrshare
          }
        }
      }
      Catch {
        $arrshare | Add-Member NoteProperty Computer $target
        $arrshare | Add-Member NoteProperty Name 'NA'
        $arrshare | Add-Member NoteProperty ID 'NA'
        $arrshare | Add-Member NoteProperty AccessMask 'NA'
      }
      Finally {
        #Add to existing array
        $sharereport += $arrshare
      }
    }
  }
  End{
    $sharereport
  }
}

#Get-SharePerms -computername '\\usnycsms002' -ShareName 'SBMEPACKAGES'

#\\usculvwweb001\c$\inetpub\wwroot\brain