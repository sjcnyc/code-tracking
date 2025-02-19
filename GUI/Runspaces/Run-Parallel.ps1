Function Run-Parallel {
<#
.SYNOPSIS
Function to control parallel processing using runspaces

.PARAMETER ScriptFile
File to run against all computers.  Must include parameter to take in a computername.  Example: C:\script.ps1

.PARAMETER ScriptBlock
Scriptblock to run against all computers.  Must include parameter to take in a computername.

.PARAMETER ComputerName
Run script against specified computer(s).  Example: Run-Parallel -computername c-is-ts-91, c-is-ts-92 ...

.PARAMETER ComputerList
Run script file against specified file.  Example: C:\listOfComputers.txt

.PARAMETER queryAllAD
Run script file against all computer accounts in AD

.PARAMETER queryWksAD
Run script file against all computer accounts in workstation OUs in AD

Note:  You must define these, if desired.  Default:
                    "OU=example workstation OU,DC=blah,DC=org",
                    "CN=Computers,DC=blah,DC=org"

.PARAMETER querySvrAD
Run script file against all computer accounts in server OUs in AD

Note:  You must define these, if desired:  Default:
                    "OU=example server OU,DC=blah,DC=org",
                    "CN=Computers,DC=blah,DC=org"

.PARAMETER ADResultSetSize
Limit Active Directory queries to this many computer accounts per OU/CN.  Integer.  Default: 10  All: 0

.PARAMETER Throttle
Maximum number of threads open at a single time.  Default: 20

.PARAMETER SleepTimer
Milliseconds to sleep after checking for completed runspaces.  Default: 200 (milliseconds)

.PARAMETER maxRunTime
Maximum time in minutes a single thread can run.  If execution of your scriptblock takes longer than this, it is disposed.  Default: 3 (minutes)

.EXAMPLE
Each example uses Test-ForPacs.ps1 which includes the following code:
    param($computer)

    if(test-connection $computer -count 1 -quiet -BufferSize 16){
        $object = [pscustomobject] @{
            Computer=$computer;
            Available=1;
            Kodak=$(
                if((test-path "\\$computer\c$\users\public\desktop\Kodak Direct View Pacs.url") -or (test-path "\\$computer\c$\documents and settings\all users\desktop\Kodak Direct View Pacs.url") ){"1"}else{"0"}
            )
        }
    }
    else{
        $object = [pscustomobject] @{
            Computer=$computer;
            Available=0;
            Kodak="NA"
        }
    }

    $object

EXAMPLE
Run-Parallel -scriptfile C:\public\Test-ForPacs.ps1 -queryWksAD -ADResultSetSize 100 -maxRunTime 1

    Queries AD for all workstations (queryWksAD),
    Pulls the first 10 for each OU/Container in AD (ADResultSetSize 10)
    Runs Test-ForPacs against each
    If any query takes longer than 1 minute, dispose of it

.EXAMPLE
Run-Parallel -scriptfile C:\public\Test-ForPacs.ps1 -queryAllAD -ADResultSetSize 0

    Queries AD for all computer accounts (queryAllAD),
    Does not limit the AD query (-ADResultSetSize 0)
    Runs Test-ForPacs against each

.EXAMPLE
Run-Parallel -scriptfile C:\public\Test-ForPacs.ps1 -computername c-is-ts-91, c-is-ts-95

    Runs against c-is-ts-91, c-is-ts-95 (-computername)
    Runs Test-ForPacs against each

.FUNCTIONALITY
PowerShell Language

.NOTES
Credit to Boe Prox 
http://learn-powershell.net/2012/05/10/speedy-network-information-query-using-powershell/
http://gallery.technet.microsoft.com/scriptcenter/Speedy-Network-Information-5b1406fb#content
#>
  [cmdletbinding()]
  Param (   
    [ValidateScript({test-path $_ -pathtype leaf})]
    $ScriptFile,
    
    [scriptblock]$scriptBlock,
    
    [parameter(ValueFromPipeline = $True,ValueFromPipeLineByPropertyName = $True, ParameterSetName='Computer')]
    [Alias('CN','__Server','IPAddress','Server')]
    [string[]]$Computername = $Env:Computername,
    
    [Parameter(Position=0, ValueFromPipeline=$true,ParameterSetName='File')]
    [ValidateScript({test-path $_ -pathtype leaf})]
    $ComputerList,
    
    [Parameter(Position=0, ValueFromPipeline=$true,ParameterSetName='All')]
    [switch]$queryAllAD,
    
    [Parameter(Position=0, ValueFromPipeline=$true,ParameterSetName='Wks')]
    [switch]$queryWksAD,
    
    [Parameter(Position=0, ValueFromPipeline=$true,ParameterSetName='Svr')]
    [switch]$querySvrAD,
    
    [parameter()]
    [int]$Throttle = 15,
    
    $SleepTimer = 200,
    
    $maxRunTime = 3,
    
    $ADResultSetSize = 10
  )
  Begin {
    
    #Function that will be used to process runspace jobs
    Function Get-RunspaceData {
      [cmdletbinding()]
      param(
        [switch]$Wait
      )
      
      Do {
        #set more to false
        $more = $false
        
        Write-Progress  -Activity 'Running Query'`
        -Status 'Starting threads'`
        -CurrentOperation "$count threads created - $($runspaces.count) threads open"`
        -PercentComplete (($totalcount - $runspaces.count) / $totalcount * 100)
        
        #run through each runspace.           
        Foreach($runspace in $runspaces) {
          
          $runtime = (get-date) - $runspace.startTime
          #If runspace completed, end invoke, dispose, recycle, counter++
          If ($runspace.Runspace.isCompleted) {
            $runspace.powershell.EndInvoke($runspace.Runspace)
            $runspace.powershell.dispose()
            $runspace.Runspace = $null
            $runspace.powershell = $null
          }
          
          #If runtime exceeds max, dispose the runspace
          ElseIf ( ( (get-date) - $runspace.startTime ).totalMinutes -gt $maxRunTime) {
            $runspace.powershell.dispose()
            $runspace.Runspace = $null
            $runspace.powershell = $null
          }
          
          #If runspace isn't null set more to true  
          ElseIf ($runspace.Runspace -ne $null) {
            $more = $true
          }
        }
        
        #After looping through runspaces, if more and wait, sleep
        If ($more -AND $PSBoundParameters['Wait']) {
          Start-Sleep -Milliseconds $SleepTimer
        }   
        
        #Clean out unused runspace jobs
        $temphash = $runspaces.clone()
        $temphash | Where-Object {
          $_.runspace -eq $Null
        } | ForEach {
          Write-Verbose ('Removing {0}' -f $_.computer)
          $Runspaces.remove($_)
        }
        
        #Stop this loop only when $more if false and wait                 
      } while ($more -AND $PSBoundParameters['Wait'])
      
      #End of runspace function
    }
    
    #Define hash table for Get-RunspaceData function
    $runspacehash = @{}
    
    #If scriptblock is not specified, convert script file to script block.
    if(! $scriptblock){
      [scriptblock]$scriptblock = [scriptblock]::Create($((get-content $scriptfile) | out-string))
    }
    #if scriptblock is specified, add parameter definition to first line
    else{
      $ScriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock("param(`$_)`r`n" + $Scriptblock.ToString())
    }
    
    #Create runspace pool
    Write-Verbose ('Creating runspace pool and session states')
    $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
    $runspacepool = [runspacefactory]::CreateRunspacePool(1, $Throttle, $sessionstate, $Host)
    $runspacepool.Open()  
    
    Write-Verbose ('Creating empty collection to hold runspace jobs')
    $Script:runspaces = New-Object System.Collections.ArrayList        
  }
  
  Process {        
    
    #Initialize counter and AD pc list
    $pcs = @()
    $count = 0
    if($ADResultSetSize -eq 0){set-variable -name ADResultSetSize -value $null -force}
    
    #set $computers to the list of computers, depending on parameter specified
    switch ($PSCmdlet.ParameterSetName){
      'Computer' {
        $computers = $computername
      }
      
      'All' {
        #Get all computer accounts in AD
        $pcs = get-adcomputer -filter * -resultsetsize $ADResultSetSize
        
        $computers = $pcs.name
      }
      
      'Svr' {
        #Define distinguished names for all OUs or containers in AD that might have a server
        $locations =
        'OU=example servers OU,DC=blah,DC=org',
        'CN=Computers,DC=blah,DC=org'
        
        #Loop through each distinguished name and get all computer accounts under it
        Foreach($dn in $locations){
          $pcs += get-adcomputer -filter * -resultsetsize $ADResultSetSize -searchbase $dn -searchscope 2
        }
        
        #Retrieve the computer name for each
        $computers = $pcs.name      
        
      }
      
      'Wks' {
        #Define distinguised names for all OUs or containers in AD that might have a workstation
        $locations =
        'OU=example workstation OU,DC=blah,DC=org',
        'CN=Computers,DC=blah,DC=org'
        
        #Loop through each distinguished name and get all computer accounts under it
        Foreach($dn in $locations){
          $pcs += get-adcomputer -filter * -resultsetsize $ADResultSetSize -searchbase $dn -searchscope 2
        }
        
        #Retrieve the computer name for each
        $computers = $pcs.name
        
      }
      
      'File' {
        #Retieve list of computers
        $Computers = Get-Content $ComputerList
      }
      
    }
    
    #initialize total count of PCs, counter
    $totalcount = $computers.count
    
    ForEach ($Computer in $Computers) {
      
      #Create the powershell instance and supply the scriptblock with the other parameters 
      $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($computer)
      
      #Add the runspace into the powershell instance
      $powershell.RunspacePool = $runspacepool
      
      #Create a temporary collection for each runspace
      $temp = '' | Select-Object PowerShell,Runspace,Computer,StartTime
      $temp.Computer = $Computer
      $temp.PowerShell = $powershell
      $temp.StartTime = get-date
      
      #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
      $temp.Runspace = $powershell.BeginInvoke()
      Write-Verbose ('Adding {0} collection' -f $temp.Computer)
      $runspaces.Add($temp) | Out-Null
      
      Write-Verbose ('Checking status of runspace jobs')
      Get-RunspaceData @runspacehash
      
      $count++
    }                        
  }
  End {                     
    Write-Verbose ('Finish processing the remaining runspace jobs: {0}' -f (@(($runspaces | Where-Object {$_.Runspace -ne $Null}).Count)))       
    $runspacehash.Wait = $true
    
    Get-RunspaceData @runspacehash
    
    Write-Verbose ('Closing the runspace pool')
    $runspacepool.close()               
  }
}
