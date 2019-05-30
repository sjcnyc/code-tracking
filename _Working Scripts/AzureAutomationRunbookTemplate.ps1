<#PSScriptInfo

.VERSION 1.0.0

.GUID d5033d8e-237f-42dc-84b7-6d2d20605e9f

.AUTHOR Sean Connealy. https://dev.azure.com/sjcnyc

.COMPANYNAME

.COPYRIGHT

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Change Log:
1.0.0 - Initial Version
#>
<# 
 .Synopsis
        Awesome template for Azure Automation.
 .DESCRIPTION
#>

[CmdletBinding()]
[OutputType([Object])] #Set to specific object type if possible (fx. if script gets a ADUser, set output type to ADUser)
Param
(
    [Parameter (Mandatory = $true)]
    [String] $ResourceGroupName
)

    $ErrorActionPreference = "stop"
    $VerbosePreference = "silentlycontinue"

    #//----------------------------------------------------------------------------
    #//
    #//  Global constant and variable declarations
    #//  Shared Resource retrieval (Assets)
    #//
    #//----------------------------------------------------------------------------
    #Constants
    #$Date = $(Get-Date)

    #Assets
    #$Credential = Get-AutomationCredential -Name "Admin"

    #//----------------------------------------------------------------------------
    #//  Procedures (Logging etc.)
    #//----------------------------------------------------------------------------
    #region Procedures
    Function Add-Tracelog {
    <#
    .Synopsis
    Adds a tracelog message to tracelog 
    .DESCRIPTION
    Uses a script scope tracelog variable to have alle scopes write to a sinlg etracelog.
    Outputs each message to the Verbose stream.
    #>
    param($Message, $TraceLog)

        $Message = "$(get-date) - $Message`n"
        Write-Verbose $Message
        if ([String]::IsNullOrEmpty($TraceLog)) {
            $TraceLog = $Message
        }
        else {
            $TraceLog += $Message
        }
    }
    Function ConvertTo-IndexedTable {
    <#
    .Synopsis
    Converts an array of objects to a array of hashtables for performance
    .DESCRIPTION
    Converts an array of objects to a hashtable of hashtables for performance
    The hashtable has takes one field as index, for example name
    and the index field can be used to filter/sort much quicker than and array of objects.
    (see example for details)
    .Example
    Get-CMDevice -CollectionName "All Systems" -Fast | ConvertTo-IndexedTable Name

    Name                           Value
    ----                           -----
    Object                         ...
    Name                           NCOP-CCMP-CCM01

    the index field is available directly, while the complete object is available in the object key of the hash table.
    #>
        param(
            [Parameter(Mandatory = $true,
                ValueFromPipelineByPropertyName = $false,
                Position = 0)]
            $IndexFieldName,
            [Parameter(Mandatory = $true,
                ValueFromPipelineByPropertyName = $true,
                ValueFromPipeline = $true,
                Position = 1)]
            [Object]$Object
        )

        #begin { $ReturnArray = @() } #New-Object System.Collections.ArrayList }
        process {
            @{
                $IndexFieldName = $Object.$IndexFieldName
                Object          = $Object
            }
        }
        #end { $ReturnArray }
    }
    #endregion

    #//----------------------------------------------------------------------------
    #//  Main routines
    #//----------------------------------------------------------------------------

    Try { #Main Catch
        $script:TraceLog = $null #when testing in ISE, tracelog is not reset
        $StartTime = get-date
        Add-Tracelog -TraceLog $TraceLog -Message "Job Started at $StartTime"
        Add-Tracelog -TraceLog $TraceLog -Message "Running on: $env:computername"

        $OutputData = @{}

        #region Main Code
        #Import Modules
        Add-Tracelog -TraceLog $TraceLog -Message "Import AzureRM Module"
        Import-Module AzureRM
        #Code here

        #Redirect all outputs to $null
        $null = . {




        }
    
        #endregion
        $EndTime = Get-date
        Add-Tracelog -TraceLog $TraceLog -Message "Finished at: $EndTime"
        Add-Tracelog -TraceLog $TraceLog -Message "Total Runtime: $($Endtime - $StartTime)"

        $OutputData.Add("TraceLog", $TraceLog)
        $OutputData.Add("Status", "Success")
        
        Write-Output $OutputData

        Write-Verbose $TraceLog
    }
    Catch {
        $ErrorMessage = $_.Exception.Message + "`nAt Line number: $($_.InvocationInfo.ScriptLineNumber)"
        Write-Error -Message $ErrorMessage
        $OutputData.Add("ErrorMessage", $ErrorMessage)
        $OutputData.Add("Status", "Failed")
        Write-Output $OutputData
    } 
    
    #//----------------------------------------------------------------------------
    #//  End Script
    #//----------------------------------------------------------------------------
    #>