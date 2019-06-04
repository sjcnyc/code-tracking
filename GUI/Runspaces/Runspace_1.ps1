# Variables for Powershell RunspaceJobs
$RunspacePoolSize = 5

# Create a runspace pool for the runspaces
$RunspacePool = [runspacefactory]::CreateRunspacePool(1, $RunspacePoolSize)  
$RunspacePool.Open()  

# Create the arrays
$RunspaceJobs = @()  
$PowerShellInstance = @()

$computers = 'ny1','ly2','usnaspwfs01','usnycpwfs01'
 
for ($i = 0; $i -lt $computers.Length; $i++) {  
     
   # Create a PowerShell runspace 
   $PowerShellInstance += [powershell]::create()  
     
   # Set the correct pool for the runspace  
   $PowerShellInstance[$i].runspacepool = $RunspacePool 

   $Scriptblock = {
        param (
            [string]$computer
        )
            Get-WmiObject win32_networkadapterconfiguration -ComputerName $computer | Select-Object description, macaddress
            Start-Sleep -Seconds 2
    }

   $Argument = $computers[$i]

   [void]$PowerShellInstance[$i].AddScript($Scriptblock).AddArgument($Argument)
   $RunspaceJobs += $PowerShellInstance[$i].BeginInvoke()
}  
 
# Wait for jobs to be finished, new jobs will be added when queue drains of runspace jobs
for ($i = 0; $i -lt $computers.Length; $i++) {  
 
    try {  
        $CurrentThreads = if ($RunspacePoolSize -gt ($computers.Length-$i)) {$computers.Length-$i} else {$RunspacePoolSize}
        $ProgressSplat = @{
            Activity = 'Running Query'
            Status = 'Starting threads'
            CurrentOperation = "$($computers.Length) threads created - $CurrentThreads threads concurrently running - $($computers.Length-$i) threads open"
            PercentComplete = $i / $computers.Length * 100 
        }
        Write-Progress @ProgressSplat

        Write-Host $computers[$i]
        $PowerShellInstance[$i].EndInvoke($RunspaceJobs[$i])
        
    } catch {
        write-warning "error: $_" 
    }  
}  