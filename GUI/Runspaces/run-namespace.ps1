﻿<#
.SYNOPSIS
   Executes a set of parameterized script blocks asynchronously using runspaces, and returns the resulting data.
.DESCRIPTION
  Encapsulates generic logic for using Powershell background runspaces to execute parameterized script blocks in an 
  efficient, multi-threaded fashion.
  
  For detailed examples of how to use the function, see http://awanderingmind.com/tag/execute-runspacejob/.
  
.PARAMETER ScriptBlock
   The script block to execute. Should contain one or more parameters.
.PARAMETER ArgumentList
  A hashtable containing data about the entity to be processed. The key should be a unique string to 
  identify the entity to be processed, such as a server name. The value should be another hashtable
  of arguments to be passed into the script block.
.PARAMETER ThrottleLimit
  The maximum number of concurrent threads to use. Defaults to 10.
.PARAMETER RunAsync
  If specified, the function will not wait for all the background runspaces to complete. Instead, it will return
  an array of runspace objects that can be used to further process the results at a later time.
.NOTES
  Author: Josh Feierman
  Date: 7/15/2012
  Version: 1.1
   
#>

function Execute-RunspaceJob
{
	[Cmdletbinding()]
	param
	(
		[parameter(mandatory=$true)]
		[System.Management.Automation.ScriptBlock]$ScriptBlock,
		[parameter(mandatory=$true,ValueFromPipeline=$true)]
		[System.Collections.Hashtable]$ArgumentList,
		[parameter(mandatory=$false)]
		[int]$ThrottleLimit = 10,
    [parameter(mandatory=$false)]
    [switch]$RunAsync
	)

	begin
  {
    try
    {
      #Instantiate runspace pool
      $runspacePool = [runspacefactory]::CreateRunspacePool(1,$ThrottleLimit)
      $runspacePool.Open()
      
      #Array to hold runspace data
      $runspaces = @()
      
      #Array to hold return data
      $data = @()
    }
    catch
    {
      Write-Warning 'Error occurred initializing function setup.'
      Write-Warning $_.Exception.Message
      break
    }
  }
  process
  {
    # Queue all sets of parameters for execution
    foreach ($Argument in $ArgumentList.Keys)
    {
      try
      {
        $rowIdentifier = $Argument
        Write-Verbose "Queuing item $rowIdentifier for processing."
        
        $runspaceRow = '' | Select-Object @{n='Key';e={$rowIdentifier}},
                                          @{n='Runspace';e={}},
                                          @{n='InvokeHandle';e={}}
        $powershell = [powershell]::Create()
        $powershell.RunspacePool = $runspacePool
        $powershell.AddScript($scriptBlock).AddParameters($ArgumentList[$rowIdentifier]) | Out-Null
        
        $runspaceRow.Runspace = $powershell
        $runspaceRow.InvokeHandle = $powershell.BeginInvoke()
        $runspaces += $runspaceRow
      }
      catch
      {
        Write-Warning "Error occurred queuing item '$Argument'."
        Write-Warning $_.Exception.Message
      }
    }
  }
  
  end
  {
    try
    {
      if ($RunAsync)
      {
        Write-Output $runspaces
      }
      else
      {
        $totalCount = $runspaces.Count
    
        # Wait for all runspaces to complete
        while (($runspaces | Where-Object {$_.InvokeHandle.IsCompleted -eq $false}).Count -gt 0)
        {
          $completedCount = ($runspaces | Where-Object {$_.InvokeHandle.IsCompleted -eq $true}).Count
          Write-Verbose "Completed $completedCount of $totalCount"
          Start-Sleep -Seconds 1
        }
        
        # Retrieve returned data and handle any threads that had errors
        foreach ($runspaceRow in $runspaces)
        {
          try
          {
            Write-Verbose "Retrieving data for item $($runspaceRow.Key)."
            if ($runspaceRow.Runspace.InvocationStateInfo.State -eq 'Failed')
            {
              $errorMessage = $runspaceRow.Runspace.InvocationStateInfo.Reason.Message
              Write-Warning "Processing of item $($runspaceRow.Key) failed with error: $errorMessage"
            }
            else
            {
              $data += $runspaceRow.Runspace.EndInvoke($runspaceRow.InvokeHandle)
            }
          }
          catch
          {
            Write-Warning "Error occurred processing result of runspace for set '$($runspaceRow.Key)'."
            Write-Warning $_.Exception.Message
          }
          finally
          {
            $runspaceRow.Runspace.dispose()
          }
          
        }
        
        $runspacePool.Close()
        
        Write-Output $data
      }
    }
    catch
    {
      Write-Warning 'Error occurred processing returns of runspaces.'
      Write-Warning $_.Exception.Message
    }
  }
}


$scriptblock =
{
    param ($ouName)
    Add-PSSnapin Quest.ActiveRoles.ADManagement
    $ErrorActionPreference = 'stop'
    Get-QADUser @parameters | Select-Object firstname,lastname,samaccountname
}

$parameters =@{}

$ounames = @('usa','nyc','lyn')

foreach ($ou in $ounames) {
    $paramValue = @{
        'searchroot' = $ou
        }
        $parameters.Add($ou,$paramValue)
    }


$data = @()

$data = Execute-RunspaceJob -ScriptBlock $scriptblock -ArgumentList $parameters -ThrottleLimit 12

