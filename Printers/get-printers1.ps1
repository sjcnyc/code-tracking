Function Get-Printers 
{ 
    [CmdletBinding()] 
    Param 
        ( 
        [String]$ComputerName,
        [switch]$export,
        [string]$exportPath 
        ) 
    Begin 
    { 
        $Host.Runspace.ThreadOptions = 'ReuseThread' 
        if ((Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture -eq '64-bit') 
        { 
            $SystemPrinting = Get-ChildItem "$($env:systemroot)\assembly\GAC_64\System.Printing" 
            $SystemPrintingFile = Get-ChildItem -Name '*system.printing*' -Recurse -Path $SystemPrinting.FullName 
            $SystemPrintingFile = "$($SystemPrinting.FullName)\$($SystemPrintingFile)" 
            } 
        else 
        { 
            $SystemPrinting = Get-ChildItem "$($env:systemroot)\assembly\GAC_32\System.Printing" 
            $SystemPrintingFile = Get-ChildItem -Name '*system.printing*' -Recurse -Path $SystemPrinting.FullName 
            $SystemPrintingFile = "$($SystemPrinting.FullName)\$($SystemPrintingFile)" 
            } 
        $ErrorActionPreference = 'Stop' 
        Try 
        { 
            Add-Type -Path $SystemPrintingFile 
            $PrintServer = New-Object System.Printing.PrintServer("\\$($ComputerName)") 
            $PrintQueues = $PrintServer.GetPrintQueues() 
            } 
        Catch 
        { 
            Write-Error $Error[0].Exception 
            Break 
            } 
        $Printers = @() 
        } 
    Process 
    { 
        Foreach ($PrintQueue in $PrintQueues | Where-Object {$_.Name -ne 'Microsoft XPS Document Writer'}) 
        { 
            $ThisPrinter = [pscustomobject] @{
              Name = $PrintQueue.Name
              Location = $PrintQueue.Location
              IPAddress = $PrintQueue.Comment
            }
            $Printers += $ThisPrinter 
         } 
       } 
    End 
    { 
      if ($export) {
          $Printers | Export-Csv "$($exportPath)\printers.csv" -NoTypeInformation
      }
      else 
      {
        Return $Printers
       }
   } 
}

