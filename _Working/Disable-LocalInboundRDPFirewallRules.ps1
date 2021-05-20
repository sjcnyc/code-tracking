<# Invoke-Command –Computername 'USNYCVWAPP015.me.sonymusic.com' `
    –ScriptBlock {
    Get-NetFirewallRule -DisplayGroup "Remote Desktop" -PolicyStore ActiveStore | Where-Object {$_.PolicyStoreSourceType -ne 'GroupPolicy' } }

Invoke-Command –Computername 'USNYCVWAPP015.me.sonymusic.com' `
    –ScriptBlock {
    Get-NetFirewallRule -DisplayGroup "Remote Desktop" -PolicyStore ActiveStore | Where-Object {$_.PolicyStoreSourceType -eq 'GroupPolicy' } }


Invoke-Command –Computername 'USNYCVWAPP015.me.sonymusic.com' `
    –ScriptBlock {
    Disable-NetFirewallRule -Name "RemoteDesktop*" -Direction Inbound | 
    Where-Object {$_.PolicyStoreSourceType -ne 'GroupPolicy'} }


Invoke-Command –Computername 'USNYCVWAPP016.me.sonymusic.com' `
    –ScriptBlock {

    Disable-NetFirewallRule -DisplayGroup 'Remote Desktop' | Where-Object {$_.PolicyStoreSourceType -ne 'GroupPolicy'}
} #>

function Disable-LocalInboundRDPFirewallRules {
    param(
        [Parameter(Mandatory = $true)][string]
        $ServerName
    )
    function Write-Log {
        param (
            [Parameter(Mandatory = $true)][string]
            $Message,

            [string]
            $Path = "c:\temp\PowerShellLog2.txt"
        )
        Write-Verbose -Message $Message
        Write-Output "$(Get-Date) $Message" | Out-File -FilePath $path -Append
    }
    try {
        if (Test-Connection -ComputerName $ServerName -Count 1 -Quiet) {
            Write-Log -Message "Disabling RDP firewall rule: $Servername" -Verbose
            Invoke-Command –Computername $ServerName –ScriptBlock {
                try {
                    Disable-NetFirewallRule -DisplayGroup 'Remote Desktop' | Where-Object {$_.PolicyStoreSourceType -ne 'GroupPolicy'}
                }
                catch {
                    Write-Log -Message "Error $Servername : $_" -Verbose
                }
            } -ErrorAction 0
        }
        else {
            Write-Log -Message "Cannot connect to: $ServerName" -Verbose
        }
    }
    catch {
        Write-Log -Message "Error $Servername : $_" -Verbose
    }
}

@"
EUGTLPWPKI12
"@ -split [environment]::NewLine |

foreach-object {
    Disable-LocalInboundRDPFirewallRules -ServerName $_
}