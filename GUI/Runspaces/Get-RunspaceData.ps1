<#
    .SYNOPSIS


    .DESCRIPTION


    .PARAMETER Computername
        List of computers to run the query against.

        Default value is: Local Computer ($Env:Computername)

    .PARAMETER Throttle
        Number of concurrently running jobs to run at a time.

        Default value is: 10

    .PARAMETER TimeOut
        Sets a timeout on the runspace to complete before being forcefully closed in seconds.

        Default value is: 20

    .PARAMETER ShowProgress
        Display a progress bar during operation.

    .NOTES
        Author: 
        Name: 
        Date Created: 
        Last Modified: 
        Version 1.0 - Initial Creation            

    .EXAMPLE


        Description
        -----------

#>

[cmdletbinding()]
#region Parameters
Param (
    [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [Alias('Computer','__Server','IPAddress','CN','dnshostname')]
    [string[]]$Computername = $env:COMPUTERNAME,
    [parameter()]
    [Alias('MaxJobs')]
    [ValidateRange(1,65535)]
    [int]$Throttle = 10,
    [parameter()]
    [ValidateRange(1,65535)]
    [int]$Timeout = 20,
    [parameter()]
    [switch]$ShowProgress
)
#endregion Parameters
Begin {
    #Get current titlebar
    $origTitle = [console]::Title
    #region Functions
    #Function to perform runspace job cleanup
    Function Get-RunspaceData {
        [cmdletbinding()]
        param(
            [switch]$Wait
        )
        Do {
            $more = $false         
            Foreach($runspace in $runspaces) {
                $StartTime = $runspacetimer.($runspace.ID)
                If ($runspace.Handle.isCompleted) {
                    $runspace.powershell.EndInvoke($runspace.Handle)
                    $runspace.powershell.dispose()
                    $runspace.Handle = $null
                    $runspace.powershell = $null                 
                } ElseIf ($runspace.Handle -ne $null) {
                    $more = $true
                }
                If ($Timeout -and $StartTime) {
                    If ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell) {
                        Write-Warning ('Timeout {0}' -f $runspace.Computer)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                }
            }
            If ($more -AND $PSBoundParameters['Wait']) {
                Start-Sleep -Milliseconds 100
            }   
            #Clean out unused runspace jobs
            $temphash = $runspaces.clone()
            $temphash | Where-Object {
                $_.Handle -eq $Null
            } | ForEach {
                Write-Verbose ('Removing {0}' -f $_.computer)
                $Runspaces.remove($_)
            }  
            [console]::Title = ('Remaining Runspace Jobs: {0}' -f ((@($runspaces | Where-Object {$_.Handle -ne $Null}).Count)))  
            If ($ShowProgress) {
                $ProgressSplatting = @{
                    Activity = 'Performing Scan'
                    Status = '{0} of {1} total threads done' -f ($RunspaceCounter - $runspaces.Count), $RunspaceCounter
                    PercentComplete = ($RunspaceCounter - $runspaces.Count) / $RunspaceCounter * 100
                }
                Write-Progress @ProgressSplatting
            }                   
        } while ($more -AND $PSBoundParameters['Wait'])
    }
    #endregion Functions
    
    #region Runspace related variables
    #Define counter for runspaces
    $runspaceCounter = 0
    
    #Define hashtable for timer
    $Global:runspacetimer = [HashTable]::Synchronized(@{})
    #Define hash table for Get-RunspaceData function
    $runspacehash = @{}
    
    Write-Verbose ('Creating empty collection to hold runspace jobs')
    $Global:runspaces = New-Object System.Collections.ArrayList 


    #endregion Runspace related variables

    #region ScriptBlock
    $scriptBlock = {
        Param (
            [string]$Computername,
            [int]$RunspaceID
            ## ADD OTHER PARAMETERS HERE THAT ARE REQUIRED FOR THE SCRIPTBLOCK!!!
        )        
        ## REQUIRED FOR TIMEOUT OF RUNSPACE -- DO NOT REMOVE!!
        $runspacetimer.$RunspaceID = Get-Date       
        <#
        ADD CODE FOR SCRIPTBLOCK
        #>                     
    }
    #endregion ScriptBlock

    #region Runspace Creation
    Write-Verbose ('Creating runspace pool and session states')
    $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
    # Add a variable that is available through all sessions; Variable Name, Variable Value, Description (Null in this case)
    $sessionstate.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList runspaceTimer, (Get-Variable -Name runspaceTimer -ValueOnly), ''))
    $runspacepool = [runspacefactory]::CreateRunspacePool(1, $Throttle, $sessionstate, $Host)
    $runspacepool.Open()                
    #endregion Runspace Creation
}
Process {
    ForEach ($Computer in $Computername) {
        $runspaceCounter++
        #Create the powershell instance and supply the scriptblock with the other parameters 
        $powershell = [powershell]::Create().AddScript($scriptBlock)
        $null = $powershell.AddParameter('Computername',$computer)
        $null = $powershell.AddParameter('RunspaceID',$runspaceCounter)
        ## ADD OTHER PARAMETERS HERE THAT ARE REQUIRED FOR THE SCRIPTBLOCK!!!
           
        #Add the runspace into the powershell instance
        $powershell.RunspacePool = $runspacepool
        
       $null = $runspaces.Add(
            (@{
                Handle = $powershell.BeginInvoke()
                Computer = $Computer
                PowerShell = $PowerShell
                ID = $runspaceCounter
            })
        )  
        Write-Verbose ('Adding {0} collection' -f $Computer)
           
        Write-Verbose ('Checking status of runspace jobs')
        Get-RunspaceData @runspacehash        
    }
}
End {
    Write-Verbose ('Finish processing the remaining runspace jobs: {0}' -f ((@($runspaces | Where-Object {$_.Runspace -ne $Null}).Count)))
    $runspacehash.Wait = $true
    Get-RunspaceData @runspacehash
    [console]::Title = $origTitle
    If ($ShowProgress) {
        Write-Progress -Activity 'Performing Scan' -Status 'Done' -Completed
    }

    #region Cleanup Runspace
    Write-Verbose ('Closing the runspace pool')
    $runspacepool.close()  
    $runspacepool.Dispose() 
    #endregion Cleanup Runspace
}