class BackgroundJob {
  # Properties
  hidden $PowerShell = [powershell]::Create()
  hidden $Handle = $null
  hidden $Runspace = $null
  $Result = $null
  $RunspaceID = $This.PowerShell.Runspace.ID
  $PSInstance = $This.PowerShell

  # Constructor (just code block)
  BackgroundJob ([scriptblock]$Code) {
    $This.PowerShell.AddScript($Code)
  }

  # Constructor (code block + arguments)
  BackgroundJob ([scriptblock]$Code, $Arguments) {
    $This.PowerShell.AddScript($Code)
    foreach ($Argument in $Arguments) {
      $This.PowerShell.AddArgument($Argument)
    }
  }

  # Constructor (code block + arguments + functions)
  BackgroundJob ([scriptblock]$Code, $Arguments, $Functions) {
    $InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
    $Scope = [System.Management.Automation.ScopedItemOptions]::AllScope
    foreach ($Function in $Functions) {
      $FunctionName = $Function.Split('\')[1]
      $FunctionDefinition = Get-Content $Function -ErrorAction Stop
      $SessionStateFunction = New-Object -TypeName System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList $FunctionName, $FunctionDefinition, $Scope, $null
      $InitialSessionState.Commands.Add($SessionStateFunction)
    }
    $This.Runspace = [runspacefactory]::CreateRunspace($InitialSessionState)
    $This.PowerShell.Runspace = $This.Runspace
    $This.Runspace.Open()
    $This.PowerShell.AddScript($Code)
    foreach ($Argument in $Arguments) {
      $This.PowerShell.AddArgument($Argument)
    }
  }

  # Start Method
  Start() {
    $This.Handle = $This.PowerShell.BeginInvoke()
  }

  # Stop Method
  Stop() {
    $This.PowerShell.Stop()
  }

  # Receive Method
  [object]Receive() {
    $This.Result = $This.PowerShell.EndInvoke($This.Handle)
    return $This.Result
  }

  # Remove Method
  Remove() {
    $This.PowerShell.Dispose()
    If ($This.Runspace) {
      $This.Runspace.Dispose()
    }
  }

  # Get Status Method
  [object]GetStatus() {
    return $This.PowerShell.InvocationStateInfo
  }
}

<# Function Ping-Computers {
  Param([String[]]$ComputerName, $Count)
  $ComputerName | ForEach-Object {
    Test-Connection -ComputerName $_ -Count $Count
  }
}

$ComputerName = "usnaspwfs01", "usbvhpwfs01", "usmiapwfs02"
$Count = 2

$Code = {
  Param($ComputerName, $Count)
  Ping-Computers -ComputerName $ComputerName -Count $Count
}

$Job = [BackgroundJob]::New($Code, @($ComputerName, $Count), "Function:\Ping-Computers")

$Job.Start()
$Job.Receive()
$Job.Remove() #>

# Create multiple jobs
$Jobs = @{
  Job1 = [BackgroundJob]::New( {Test-Connection -ComputerName usnaspwfs01 -Count 1})
  Job2 = [BackgroundJob]::New( {Test-Connection -ComputerName usbvhpwfs01 -Count 1})
  Job3 = [BackgroundJob]::New( {Test-Connection -ComputerName usmiapwfs02 -Count 1})
}

# Start each job
$Jobs.GetEnumerator() | ForEach-Object {
  $_.Value.Start()
}

# Wait for the results
Do {}
Until (($Jobs.GetEnumerator() | ForEach-Object {$_.Value.GetStatus().State}) -notcontains "Running")

# Output the results
$Jobs.GetEnumerator() | ForEach-Object {$_.Value.Receive()}
$Jobs.GetEnumerator() | ForEach-Object {$_.Value.Remove()}