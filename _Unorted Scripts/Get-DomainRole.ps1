Function Get-DomainRole {
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "Provide computername", ValueFromPipeline = $true)]
        $Computername
    )
    $Results = @()
    $Role = $Val1 = $Val2 = $Object = $FQDN = $null
    $FQDN = ([System.Net.Dns]::GetHostByName(("$Computername")))
    If (!$FQDN) {
        Write-Warning "$Computername does not exist"
    }
    Else {
        Try {
            $Role = Get-Wmiobject -Class 'Win32_computersystem' -ComputerName $Computername -ErrorAction Stop
        }
        Catch {
            $_.Exception.Message
            Continue
        }
        If ($Role) {
            Switch ($Role.pcsystemtype) {
                "1" { $Val1 = "Desktop"}
                "2" { $Val1 = "Mobile / Laptop"}
                "3" { $Val1 = "Workstation"}
                "4" { $Val1 = "Enterprise Server"}
                "5" { $Val1 = "Small Office and Home Office (SOHO) Server"}
                "6" { $Val1 = "Appliance PC"}
                "7" { $Val1 = "Performance Server"}
                "8" { $Val1 = "Maximum"}
                default { $Val1 = "Not a known Product Type"}
            }
            Switch ($Role.domainrole) {
                "0" { $Val2 = "Stand-alone workstation"}
                "1" { $Val2 = "Member workstation"}
                "2" { $Val2 = "Stand-alone server"}
                "3" { $Val2 = "Member server"}
                "4" { $Val2 = "Domain controller"}
                "5" { $Val2 = "Pdc emulator domain controller"}
            }
            $Object = New-Object PSObject -Property ([ordered]@{
                    Computer   = $Computername
                    IPAddress  = $FQDN.AddressList[0].IPAddressToString
                    PCType     = $Val1
                    DomainRole = $Val2
                })
            $Results += $Object
        }
    }
    Return $Results
}