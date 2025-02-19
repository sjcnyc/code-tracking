function New-PrintServerName {
    [CmdletBinding(
        SupportsShouldProcess
    )]
    Param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $newPrintServer,

        [Parameter(Mandatory, Position = 1)]
        [string]
        $oldPrintServer
    )
    function Write-Log {
        [CmdletBinding(
            SupportsShouldProcess
        )]
        param (
            [Parameter(Mandatory)]
            [string]
            $Message,

            [string]
            $Path = "PowerShellLog.txt"
        )

        Write-Verbose -Message $Message
        Write-Output "$(Get-Date) $Message" | Out-File -FilePath $path -Append
    }
    try {
        Write-Log -Message ("{0}: Checking for printers mapped to old print server" -f $Env:USERNAME)
        $printers = @(Get-WmiObject -Class Win32_Printer -Filter "SystemName='\\\\$oldPrintServer'" -ErrorAction Stop)
        $defaultPrinter = Get-WmiObject -Class Win32_Printer |Where-Object {$_.Default -eq $true}

        if ($printers.count -gt 0) {
            foreach ($printer in $printers) {
                Write-Log -Message ("{0}: Replacing with new print server name: {1}" -f $Printer.Name, $newPrintServer)
                $newPrinter = $printer.Name -replace $oldPrintServer, $newPrintServer
                $returnValue = ([wmiclass]"Win32_Printer").AddPrinterConnection($newPrinter).ReturnValue
                if ($returnValue -eq 0) {
                    if ($printer.Default) {
                        $defaultPrinter = $newPrinter -replace "\\", '\\'
                        $createdPrinter = Get-WmiObject -Class Win32_Printer -Filter "Name='$defaultPrinter'"
                        Write-Log -Message ("{0}: Setting Default: {1}" -f $printer.Name, $createdPrinter.Name)
                        [void]$createdPrinter.SetDefaultPrinter()
                    }
                    Write-Log -Message ("{0}: Removing" -f $printer.Name)
                    [void]$printer.Delete()
                }
                else {
                    Write-Log -Message ("{0} returned error code: {1}" -f $newPrinter, $returnValue)
                }
            }
        }
    }
    catch {
        Write-Log -Message $_.Exception.Message
    }
}

$oldQ = Read-Host -Prompt "Enter the alias of the host"
$newQ = Read-Host -Prompt "Enter the FQDN of the host"

New-PrintServerName -newPrintServer $newQ -oldPrintServer $oldQ -Verbose