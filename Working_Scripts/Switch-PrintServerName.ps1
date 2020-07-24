function Switch-PrintServerName {
    Param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $NewPrintServer,

        [Parameter(Mandatory = $true)]
        [System.String]
        $OldPrintServer
    )
    function Write-Log {
        param (
            [Parameter(Mandatory = $true)]
            [System.String]
            $Message,

            [System.String]
            $Path = "\\storage.me.sonymusic.com\logs$\_SwapPrintserverNames.txt"
        )
        Write-Verbose -Message $Message
        Write-Output "$(Get-Date) $Message" | Out-File -FilePath $path -Append
    }
    try {
        Write-Log -Message ("{0}: Checking for printers mapped to old print server" -f $Env:USERNAME)
        $printers = @(Get-WmiObject -Class Win32_Printer -Filter "SystemName='\\\\$OldPrintServer'" -ErrorAction Stop)
        $defaultPrinter = Get-WmiObject -Class Win32_Printer | Where-Object {$_.Default -eq $true}
        if ($printers.count -gt 0) {
            foreach ($printer in $printers) {
                Write-Log -Message ("{0}: Replacing with new print server name: {1}" -f $Printer.Name, $NewPrintServer)
                $newPrinter = $printer.Name -replace $OldPrintServer, $NewPrintServer
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

Switch-PrintServerName -NewPrintServer "usculvwprt402.me.sonymusic.com" -OldPrintServer "usbvhpwfs01.me.sonymusic.com"
Switch-PrintServerName -NewPrintServer "usculvwprt402.me.sonymusic.com" -OldPrintServer "usbvhpwfs01"

Switch-PrintServerName -NewPrintServer "usnaspwfs02.me.sonymusic.com" -OldPrintServer "usnaspwfs01.me.sonymusic.com"
Switch-PrintServerName -NewPrintServer "usnaspwfs02.me.sonymusic.com" -OldPrintServer "usnaspwfs01"


#Switch-PrintServername -newPrintServer usbvhpwfs01 -oldPrintServer stm



<# Regex for 25mad printer names

$newServer = '$1{0}$2' -f "usculvwprt405"

$string = '\\25mad\25mad-413-NW'

$string -replace '(.*?)25mad(.*)', $newServer 
#>