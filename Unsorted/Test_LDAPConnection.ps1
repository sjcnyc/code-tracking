﻿Function Test-LDAPConnection {
    [CmdletBinding()]
               
    # Parameters used in this function
    Param
    (
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "Provide domain controllers names, example DC01", ValueFromPipeline = $true)] 
        [array] $DCs,

        [Parameter(Position = 1, Mandatory = $False, HelpMessage = "Provide port number for LDAP", ValueFromPipeline = $true)]
        [int] $Port = "636",

        [Parameter(Position = 1, Mandatory = $False, HelpMessage = "Provide port number for LDAP", ValueFromPipeline = $true)]
        [string] $domain = 'bmg.bagint.com'

    ) 
  
    $ErrorActionPreference = "Stop"
    $Results = @()
    Try { 
        Import-Module ActiveDirectory -ErrorAction Stop
    }
    Catch {
        $_.Exception.Message
        Break
    } 
         
    ForEach ($DC in $DCs) {
        $DC = $DC.trim()
        Write-Verbose "Processing $DC"
        Try {
            $DCName = (Get-ADDomainController -Identity $DC -Server $domain).hostname
        }
        Catch {
            $_.Exception.Message
            Continue
        }
  
        If ($DCName -ne $Null) {  
            Try {
                $Connection = [adsi]"LDAP://$($DCName):$Port"
            }
            Catch {
                $ExcMessage = $_.Exception.Message
                throw "Error: Failed to make LDAP connection. Exception: $ExcMessage"
            }
  
            If ($Connection.Path) {
                $Object = New-Object PSObject -Property ([ordered]@{ 
                       
                        DC   = $DC
                        Port = $Port
                        Path = $Connection.Path
                    })

                $Results += $Object
            }         
        }
    }
  
    If ($Results) {
        Return $Results
    }
}


Test-LDAPConnection -DCs NYCSMEADS0102.me.sonymusic.com -Port 636 -domain me.sonymusic.com