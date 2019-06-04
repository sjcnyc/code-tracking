# Variables for Powershell RunspaceJobs
$RunspacePoolSize = 5
$NumberofLoops = 15

# Create a runspace pool for the runspaces
$RunspacePool = [runspacefactory]::CreateRunspacePool(1, $RunspacePoolSize)  
$RunspacePool.Open()  

# Create the arrays
$RunspaceJobs = @()  
$PowerShellInstance = @()   
 
for ($i = 0; $i -lt $NumberofLoops; $i++) {  
     
   # Create a PowerShell runspace 
   $PowerShellInstance += [powershell]::create()  
     
   # Set the correct pool for the runspace  
   $PowerShellInstance[$i].runspacepool = $RunspacePool 

   # Example of scriptblock that will be executed
   $Scriptblock = {
        param (
            [string]$Server
        )
            Get-WinEvent -ListLog * -ComputerName $Server
            Start-Sleep -Seconds 2
    }

   # Arguments for the scriptblock 
   $Argument = "computer$i"

   # Add the script to the runspace 
   [void]$PowerShellInstance[$i].AddScript($Scriptblock).AddArgument($Argument)
   
   # Execute runspace job
   $RunspaceJobs += $PowerShellInstance[$i].BeginInvoke()
}  
 
# Wait for jobs to be finished, new jobs will be added when queue drains of runspace jobs
for ($i = 0; $i -lt $NumberofLoops; $i++) {  
 
    try {  
        $CurrentThreads = if ($RunspacePoolSize -gt ($NumberofLoops-$i)) {$NumberofLoops-$i} else {$RunspacePoolSize}
        $ProgressSplat = @{
            Activity = 'Running Query'
            Status = 'Starting threads'
            CurrentOperation = "$NumberofLoops threads created - $CurrentThreads threads concurrently running - $($NumberofLoops-$i) threads open"
            PercentComplete = $i / $NumberofLoops * 100 
        }
        Write-Progress @ProgressSplat

        $PowerShellInstance[$i].EndInvoke($RunspaceJobs[$i])
    } catch {
        write-warning "error: $_" 
    }  
}  