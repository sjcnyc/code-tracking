class SimpleMenu {
    [System.Collections.Generic.List[PSObject]]$Items
    [String]$Title
    [ConsoleColor]$TitleForeGround = [ConsoleColor]::Cyan


    SimpleMenu() {
        $This.Items = New-Object System.Collections.Generic.List[PSObject]
    }

    [PSObject]GetItem($id) {
        $out = ($this.Items | Where-Object {$_.ID -eq $ID} | Select-Object -First 1)
        return $out
    }

    Print() {
        $TitleParams = @{}
        $TitleParams.Add('ForegroundColor', $this.TitleForeGround)
       
        Write-Host "   $($this.Title)" @TitleParams

        $NumberIndex = 0 
        Foreach ($Item in $this.Items) {

            if (-not [String]::IsNullOrWhiteSpace($Item.Key)) {
                $item.runtimeKey = $item.Key
            }
            else {
                $NumberIndex++
                $item.runtimeKey = $NumberIndex
            }
            Write-host "$($item.runtimeKey). $($Item.Title)"
        }
    }
}

enum WarningMessages{
    Undefined
    None
    InvalidChoice
    NoActionDefined
}
function New-SimpleMenu($Title, $Items, [ConsoleColor]$TitleForegroundColor, $Id) {
    $Menu = New-Object -TypeName SimpleMenu
    $Menu.Title = $Title
    if ($PSBoundParameters.ContainsKey('TitleForegroundColor')) {
        $Menu.TitleForeGround = $TitleForegroundColor
    }
    $AllKeys = New-Object System.Collections.ArrayList
    Foreach ($Item in $Items) {
        if (-not [String]::IsNullOrWhiteSpace($item.Key)) {
            if ($AllKeys.Contains($Item.Key)) {
                Write-Error "The key $($item.key) is already assigned to another element of this menu and cannot be assigned to item $($item.Title)."
            }
            else {
                $AllKeys.Add($Item.Key) | Out-Null
            }
        }
        $Menu.Items.Add($Item)
    }
    return $Menu
}
function New-SimpleMenuItem {
    [cmdletbinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()] #No value
        [String]$Title,
        [System.ConsoleColor]$ForegroundColor,
        $Id, 
        [ValidatePattern('^[a-zA-Z]$')]$Key = $null,
        [ScriptBlock]$Action = $null,
        [Switch]$Quit,
        [Switch]$NoPause,
        $Submenu
    )
    Begin {
        $MenuItem = New-Object  PSObject -Property  @{
            'Title'      = ''
            'Id'         = ''
            'Key'        = ''
            'runtimeKey' = ''
            Action       = ''
            IsExit       = $false
            Submenu      = $Null
            NoPause      = $NoPause
        }

        $WriteHostParams = @{}
        if ($PSBoundParameters.ContainsKey('ForegroundColor')) {
            $WriteHostParams.add('ForegroundColor', $ForegroundColor)
        }

        $MenuItem.Id      = $Id
        $MenuItem.Key     = $Key
        $MenuItem.Action  = $Action
        $MenuItem.IsExit  = $Quit
        $MenuItem.Submenu = $Submenu
    }
    Process {
        if ($_ -eq $null) {
            $_ = $Title
        }
        $MenuItem.Title = $_
    }
    End {
        return $MenuItem
    }
}
function Invoke-SimpleMenu {
    [cmdletbinding()]
    param(
        [SimpleMenu]$Menu
    )
    $Debug = ($psboundparameters.debug.ispresent -eq $true)

    [WarningMessages]$InvalidChoice = [WarningMessages]::None
    while ($true) {
        if (-not   $Debug ) {Clear-Host}

        $Menu.Print()
        if (-not ($InvalidChoice -eq [WarningMessages]::None) ) {
            Switch ($InvalidChoice) {
                ([WarningMessages]::NoActionDefined) {  Write-Warning 'No actions have been defined for this menu item.'}
                ([WarningMessages]::InvalidChoice) {
                    Write-Warning "'$Line' is not a valid choice"
                    $IDs = ($menu.Items | Select-Object -ExpandProperty runtimeKey) -join ','
                    Write-Host "Valid choices are: $IDs"
                }
            }

            $InvalidChoice = [WarningMessages]::Undefined
        }
        if ([console]::IsInputRedirected) {
            $Line = Read-Host
        }
        else {
            [System.ConsoleKeyInfo]$LineRaw = [Console]::ReadKey($true)
            $Line = $LineRaw.KeyChar.ToString()
        }

        $Result = @($Menu.Items | Where-Object runtimeKey -eq $Line )
               
        if ($Result.Count -gt 0) {
            $ShouldNotPause = $Result.NoPause

            if ($InvalidChoice -eq [WarningMessages]::Undefined) {
                if (-not   $Debug ) {Clear-Host}
                $Menu.Print()
                
                $InvalidChoice = [WarningMessages]::None
            }
            if ($Result.Action -ne $null) {
                try {
                    ($Result.Action).invoke()
                }
                catch {
                    Write-Error $_
                    $ShouldNotPause = $false
                }
                if ($ShouldNotPause -eq $false) {Pause}
            }
            else {
                if (-not ($Result.IsExit) -and ($Result.Submenu -eq $null)) {
                    $InvalidChoice = [WarningMessages]::NoActionDefined
                }
            }
        }
        else {
            $InvalidChoice = [WarningMessages]::InvalidChoice
        }
        if ($Result.Submenu -ne $Null) {
            Invoke-SimpleMenu $Result.Submenu -debug:$Debug
        }
        if ($Result.IsExit -eq $true) {
            return
        }
    }
}

#Requires -Version 2.0
$ErrorActionPreference = 'Stop'
Set-PSDebug -Strict

Add-Type -TypeDefinition @"
    public enum MsgCategory
    {
       INF   = 0,
       WAR   = 1,
       ERR   = 2
    }
"@
$Global:Delimiter = ','

Function Write-PSLogger {
    <#
.SYNOPSIS
   Utility cmdlet to write logs to disk in an easy and pragmatic way. 

.DESCRIPTION
   This cmdlet allows to write timestamped and nice formatted logs with a header and footer. 
   It also allows to specify if the log entry being written is an info, a warning or an error.
   
   The header contains the following information :
       - full script path of the caller, 
       - account under the script was run,
       - computer name of the machine whose executed the script,
       - and more...
   The footer contains the elapsed time from the beginning of the log session.

.PARAMETER Header
    Mandatory switch to start a log session.

.PARAMETER Category
    Category can be one of the following value : INF, WAR, ERR

.PARAMETER Message
    Specify the content of the data to log.

.PARAMETER Footer
    Mandatory switch to end a log session. If you omit to close your log session, you won't know how much time 
    your script was running.

.EXAMPLE
   First thing to do is write a header and define a log file where the data will be written.

   Write-PSLogger -Header -LogFile C:\logs\mylogfile.log
   
   Next, anywhere in your script when you need to write a log, do one of the folowing command:

   Write-PSLogger -Category INF -Message 'This is an info to be written in the log file'
   Write-PSLogger -Category WAR -Message 'This is a warning to be written in the log file'
   Write-PSLogger -Category ERR -Message 'This is an error to be written in the log file'

   Finaly, to close your logfile you need to write a footer, just do that:

   Write-PSLogger -Footer

.EXAMPLE
   If you want to see the logs in the PowerShell console whereas they are still written to disk, 
   you can specify the -ToScreen switch.
   Info entries will be written in cyan color, Yellow for warnings, and Red for the errors.

   Write-PSLogger -Category WAR -Message 'This is a warning to be written in the log file' -ToScreen

.NOTES
   AUTHOR: Arnaud PETITJEAN - arnaud@powershell-scripting.com
   LASTEDIT: 2016/09/21
   Modified by Sean Connealy 2018/01/08

#>
    [cmdletBinding(DefaultParameterSetName = "set1", SupportsShouldProcess = $False)]
    PARAM (
        [parameter(Mandatory = $true, ParameterSetName = "set1", ValueFromPipeline = $false, position = 0)]
        [MsgCategory]$Category,
       
        [parameter(Mandatory = $true, ParameterSetName = "set1", ValueFromPipeline = $false, position = 1)]
        [Alias("Msg")]
        [String]$Message,
       
        [parameter(Mandatory = $true, ParameterSetName = "set2", ValueFromPipeline = $false)]
        [Switch]$Header,

        [parameter(Mandatory = $true, ParameterSetName = "set3", ValueFromPipeline = $false)]
        [Switch]$Footer,

        [parameter(Mandatory = $true, ParameterSetName = "set2", ValueFromPipeline = $false)]
        [String]$LogFile,

        [parameter(Mandatory = $false, ParameterSetName = "set2", ValueFromPipeline = $false)]
        [Char]$Delimiter = ",",

        [parameter(Mandatory = $false, ValueFromPipeline = $false)]
        [Switch]$ToScreen = $false
    )
   
    $Color = 'Cyan'

    $currentScriptName = $myinvocation.ScriptName
    $StartDate_str = Get-Date -UFormat "%Y-%m-%d %H:%M:%S"

    if (Get-Command Get-WmiObject -ErrorAction SilentlyContinue) {
        $currentUser = $ENV:USERDOMAIN + '\' + $ENV:USERNAME
        $currentComputer = $ENV:COMPUTERNAME  
        $WmiInfos = Get-WmiObject win32_operatingsystem
        $OSName = $WmiInfos.caption
        $OSArchi = $WmiInfos.OSArchitecture
        $StrTerminator = "`r`n"
    }
    elseif (Get-Command uname -ErrorAction SilentlyContinue) {
        $currentUser = $ENV:USER
        $currentComputer = uname -n
        $OSName = uname -s
        $OSArchi = uname -m
        $StrTerminator = "`r"
    }
    else {
        $OSName = $OSArchi = 'Unknown'
        $StrTerminator = "`r"
    }
    #New-Variable -Name $StrTerminator -Value "AA" -Option ReadOnly -Visibility Public -Scope Global -force
        
    Switch ($PsCmdlet.ParameterSetName) {
        "set1" {
            $date = Get-Date -UFormat "%Y-%m-%d %H:%M:%S"
            $Delimiter = $Global:Delimiter
            switch ($Category) {
                INF { $Message = ("$date{0} INF{0} $Message{1}" -f $Global:PSLoggerDelimiter, $StrTerminator); $Color = 'Green'   ; break }
                WAR { $Message = ("$date{0} WAR{0} $Message{1}" -f $Global:PSLoggerDelimiter, $StrTerminator); $Color = 'Yellow' ; break }
                ERR { $Message = ("$date{0} ERR{0} $Message{1}" -f $Global:PSLoggerDelimiter, $StrTerminator); $Color = 'Red'    ; break }
            }

            Add-Content -Path $Global:PSLoggerFile -Value $Message -NoNewLine
            break
        }
         
        "set2" {
            New-Variable -Name PSLoggerFile -Value $LogFile -Option ReadOnly -Visibility Public -Scope Global -force
            New-Variable -Name PSLoggerDelimiter -Value $Delimiter -Option ReadOnly -Visibility Public -Scope Global -force

            $Message = "+----------------------------------------------------------------------------------------+{0}"
            $Message += "Script fullname          : $currentScriptName{0}"
            $Message += "When generated           : $StartDate_str{0}"
            $Message += "Current user             : $currentUser{0}"
            $Message += "Current computer         : $currentComputer{0}"
            $Message += "Operating System         : $OSName{0}"
            $Message += "OS Architecture          : $OSArchi{0}"
            $Message += "+----------------------------------------------------------------------------------------+{0}"
            $Message += "{0}"

            $Message = $Message -f $StrTerminator
            # Log file creation
            [VOID] (New-Item -ItemType File -Path $Global:PSLoggerFile -Force)
            Add-Content -Path $Global:PSLoggerFile -Value $Message -NoNewLine
            break
        }

        "set3" {
            # Extracting start date from the file header
            [VOID]( (Get-Content $Global:PSLoggerFile -TotalCount 3)[-1] -match '^When generated\s*: (?<date>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})$' )
            if ($Matches.date -eq $null) {
                throw "Cannot get the start date from the header. Please check if the file header is correctly formatted."
            }
            $StartDate = [DateTime]$Matches.date
            $EndDate = Get-Date
            $EndDate_str = Get-Date $EndDate -UFormat "%Y-%m-%d %H:%M:%S"

            $duration_TotalSeconds = [int](New-TimeSpan -Start $StartDate -End $EndDate | Select-Object -ExpandProperty TotalSeconds)
            $duration_TotalMinutes = (New-TimeSpan -Start $StartDate -End $EndDate | Select-Object -ExpandProperty TotalMinutes)
            $duration_TotalMinutes = [MATH]::Round($duration_TotalMinutes, 2)

            $Message = "{0}"
            $Message += "+----------------------------------------------------------------------------------------+{0}"
            $Message += "End time                 : $EndDate_str{0}"
            $Message += "Total duration (seconds) : $duration_TotalSeconds{0}"
            $Message += "Total duration (minutes) : $duration_TotalMinutes{0}"
            $Message += "+----------------------------------------------------------------------------------------+{0}"

            $Message = $Message -f $StrTerminator
            #$host.EnterNestedPrompt()
            # Append the footer to the log file
            Add-Content -Path $Global:PSLoggerFile -Value $Message -NoNewLine
            break
        }
    } # End switch

    if ($ToScreen) {
        Write-Host $Message -ForegroundColor $Color
    }
}