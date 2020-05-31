enum SyslogSeverity
{
    Emergency = 0
    Alert = 1
    Critical = 2
    Error = 3
    Warning = 4
    Notice = 5
    Informational = 6
    Debug = 7
}

enum SyslogFacility
{
kern = 0
user = 1
mail = 2
daemon = 3
auth = 4
syslog = 5
lpr = 6
news = 7
uucp = 8
cron = 9
authpriv = 10
ftp = 11
ntp = 12
audit = 13
alert = 14
clockdaemon = 15
local0 = 16
local1 = 17
local2 = 18
local3 = 19
local4 = 20
local5 = 21
local6 = 22
local7 = 23
}

Class PsLogger
{
    hidden $loggingScript =
    {
        function Start-Logging
        {
            $loggingTimer = new-object Timers.Timer
            $action = {logging}
            $loggingTimer.Interval = 1000
            $null = Register-ObjectEvent -InputObject $loggingTimer -EventName elapsed -Sourceidentifier loggingTimer -Action $action
            $loggingTimer.start()
        }
    
        function logging
        {
            $sw = $logFile.AppendText()
            while (-not $logEntries.IsEmpty)
            {
                $entry = ''
                $null = $logEntries.TryDequeue([ref]$entry)
                $sw.WriteLine($entry)
            }
            $sw.Flush()
            $sw.Close()
        }
    
        $logFile = New-Item -ItemType File -Name "$($env:COMPUTERNAME)_$([DateTime]::UtcNow.ToString(`"yyyyMMddTHHmmssZ`")).log" -Path $logLocation
    
        Start-Logging
    }
    hidden $_loggingRunspace = [runspacefactory]::CreateRunspace()
    hidden $_logEntries = [System.Collections.Concurrent.ConcurrentQueue[string]]::new()
    hidden $_processId = $pid
    hidden $_processName
    hidden $_logLocation = $env:temp
    hidden $_fqdn
    hidden [SyslogFacility]$_facility = [SyslogFacility]::local7
    
    PsLogger([string]$logLocation)
	{
        $this._logLocation = $logLocation
        $this._processName = (Get-process -Id $this._processId).processname
        $comp = Get-CimInstance -ClassName win32_computersystem
        $this._fqdn = "$($comp.DNSHostName).$($comp.Domain)"

        # Add Script Properties for all severity levels
        foreach ($enum in [SyslogSeverity].GetEnumNames()) 
        {
            $this._AddSeverities($enum)
        }

        # Start Logging runspace
        $this._StartLogging()
    }
    
    hidden _LogMessage([string]$message, [string]$severity)
    {
        $addResult = $false
        while ($addResult -eq $false)
        {
            $msg = '<{0}>1 {1} {2} {3} {4} - - {5}' -f ($this._facility*8+[SyslogSeverity]::$severity), [DateTime]::UtcNow.tostring('yyyy-MM-ddTHH:mm:ss.fffK'), $this._fqdn, $this._processName, $this._processId, $message
            $addResult = $this._logEntries.TryAdd($msg)
        }
    }

    hidden _StartLogging()
    {
        $this._LoggingRunspace.ThreadOptions = "ReuseThread"
        $this._LoggingRunspace.Open()
        $this._LoggingRunspace.SessionStateProxy.SetVariable("logEntries", $this._logEntries)
        $this._LoggingRunspace.SessionStateProxy.SetVariable("logLocation", $this._logLocation)
        $cmd = [PowerShell]::Create().AddScript($this.loggingScript)
      
        $cmd.Runspace = $this._LoggingRunspace
        $null = $cmd.BeginInvoke()
    }

    hidden _AddSeverities([string]$propName)
    {
        $property = New-Object management.automation.PsScriptMethod $propName, {param($value) $propname = $propname; $this._LogMessage($value, $propname)}.GetNewClosure()
        $this.psobject.methods.add($property)
    }
}