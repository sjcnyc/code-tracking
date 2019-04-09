<#
    https://msdn.microsoft.com/en-us/library/aa373208(VS.85).aspx

    C++
    EXECUTION_STATE WINAPI SetThreadExecutionState(
        _In_ EXECUTION_STATE esFlags
    );
#>

param (
    [string]$aliveTime = '300000'
)

$timer = new-object timers.timer
$action = {Write-Output "Timer Elapse Event: $(get-date -Format 'HH:mm:ss')"}

$Code = @'
[DllImport("kernel32.dll", CharSet = CharSet.Auto,SetLastError = true)]
public static extern void SetThreadExecutionState(uint esFlags);
'@

$ste = Add-Type -memberDefinition $Code -name System -namespace Win32 -passThru

$ES_CONTINUOUS = [uint32]"0x80000000"
$ES_AWAYMODE_REQUIRED = [uint32]"0x00000040"

try {

    $ste::SetThreadExecutionState($ES_CONTINUOUS -bor $ES_AWAYMODE_REQUIRED)


        Write-Verbose "Executing sctiptblock"
        $timer.Interval = $aliveTime
        Register-ObjectEvent -InputObject $timer -EventName elapsed -SourceIdentifier  thetimer -Action $action
        $timer.start()
        $ste::SetThreadExecutionState($ES_CONTINUOUS)
    $timer.Stop()
    Unregister-Event thetimer

    }

catch { $_
}
