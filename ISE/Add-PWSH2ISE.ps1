$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Clear()
$null = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Switch to PowerShell 7", { 
        function New-OutOfProcRunspace {
            param([Parameter(Mandatory=$true)]$ProcessId)

            $ci = New-Object -TypeName System.Management.Automation.Runspaces.NamedPipeConnectionInfo -ArgumentList @($ProcessId)
            $tt = [Management.Automation.Runspaces.TypeTable]::LoadDefaultTypeFiles()

            $Runspace = [runspacefactory]::CreateRunspace($ci, $Host, $tt)

            $Runspace.Open()
            $Runspace
        }

        $PowerShell = Start-Process -FilePath PWSH -ArgumentList @("-NoExit") -PassThru -WindowStyle Hidden
        $Runspace = New-OutOfProcRunspace -ProcessId $PowerShell.Id
        $Host.PushRunspace($Runspace)
}, 'ALT+F5')

$null = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Switch to Windows PowerShell", { 
    $Host.PopRunspace()

    $Child = Get-CimInstance -ClassName win32_process | Where-Object {$_.ParentProcessId -eq $Pid}
    $Child | ForEach-Object { Stop-Process -Id $_.ProcessId }

}, 'ALT+F6')