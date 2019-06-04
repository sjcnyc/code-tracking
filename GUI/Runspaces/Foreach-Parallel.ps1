function ForEach-Parallel {
<#
.SYNOPSIS
A parallel ForEach that uses runspaces
.PARAMETER ScriptBlock
ScriptBlock to execute for each InputObject
.PARAMETER ScriptFile
Script file to execute for each InputObject
.PARAMETER InputObject
Object(s) to run script against in parallel
.PARAMETER MaxThreads
Maximum number of threads to run at one time.  Default: 5
.PARAMETER maxRunTime
Stop each thread after this many minutes.  Default: 3  
.PARAMETER SleepTimer
When looping through open threads, wait this many milliseconds before looping again.  Default: 200

.EXAMPLE
(0..50) | ForEach-Parallel -MaxThreads 4 { $_; sleep (Get-Random -Minimum 0 -Maximum 5) }
}

Send the number 0 through 50 to scriptblock.  For each, display the number and then sleep for 0 to 5 seconds.  Only execute 4 threads at a time.

.EXAMPLE
$servers | Foreach-Parallel -MaxThreads 20 -MaxRunTime 2 -sleeptimer 200 -verbose -scriptFile C:\query.ps1

Run query.ps1 against each computer in $servers.  Run 20 threads at a time, timeout a thread if it takes longer than 2 minutes to run, give verbose output.

.FUNCTIONALITY 
PowerShell Language

.NOTES
Credit to Tome Tanasovski
http://powertoe.wordpress.com/2012/05/03/foreach-parallel/
#>
    param(
        [Parameter(Mandatory=$false,position=0,ParameterSetName='ScriptBlock')]
            [System.Management.Automation.ScriptBlock]$ScriptBlock,

        [Parameter(Mandatory=$false,ParameterSetName='ScriptFile')]
        [ValidateScript({test-path $_ -pathtype leaf})]
            $scriptFile,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
            [PSObject]$InputObject,

            [int]$MaxThreads=5,

            [double]$sleepTimer = 200,

            [int]$maxRunTime = 3
    )
    BEGIN {
        
        #Build the scriptblock depending on the parameter used
        switch ($PSCmdlet.ParameterSetName){
            'ScriptBlock' {$ScriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock("param(`$_)`r`n" + $Scriptblock.ToString())}
            'ScriptFile' {$scriptblock = [scriptblock]::Create($(get-content $scriptFile | out-string))}
            Default {Write-Error ('Must provide ScriptBlock or ScriptFile'); Return}
        }
        
        #Define the initial sessionstate, create the runspacepool
        Write-Verbose "Creating runspace pool with $maxthreads threads"
        $sessionState = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $pool = [Runspacefactory]::CreateRunspacePool(1, $maxthreads, $sessionState, $host)
        $pool.open()
        
        #array to hold details on each thread
        $threads = @()
        
    }
    PROCESS {
        #For each pipeline object, create a new powershell instance, add to runspacepool

        $powershell = [powershell]::Create().addscript($scriptblock).addargument($InputObject)
        $powershell.runspacepool=$pool
        $startTime = get-date

        #add references to inputobject, instance, handle and startTime to threads array
        $threads += [pscustomobject]@{
            inputObject = $inputObject;
            instance = $powershell;
            handle = $powershell.begininvoke();
            startTime = $startTime
        }

        Write-Verbose "Added $inputobject to the runspacepool at $startTime"
    
    }
    END {
        $notdone = $true
        
        #Loop through threads.
        while ($notdone) {

            $notdone = $false
            for ($i=0; $i -lt $threads.count; $i++) {
                $thread = $threads[$i]
                if ($thread) {

                    #If thread is complete, dispose of it.
                    if ($thread.handle.iscompleted) {
                        Write-verbose "Closing thread for $($thread.inputObject)"
                        $thread.instance.endinvoke($thread.handle)
                        $thread.instance.dispose()
                        $threads[$i] = $null
                    }

                    #Thread exceeded maxruntime timeout threshold
                    elseif( ( (get-date) - $thread.startTime ).totalminutes -gt $maxRunTime ){
                        Write-Error "Closing thread for $($thread.inputObject): Thread exceeded $maxRunTime minute limit" -TargetObject $thread.inputObject
                        $thread.instance.dispose()
                        $threads[$i] = $null
                    }

                    #Thread is running, loop again!
                    else {
                        $notdone = $true
                    }
                }           
            }

            #Sleep for specified time before looping again
            Start-Sleep -Milliseconds $sleepTimer
        }
    }
} 