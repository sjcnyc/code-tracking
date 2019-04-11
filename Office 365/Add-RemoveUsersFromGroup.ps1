# requires -Modules PSHTMLTable
# requires -Module ActiveDirectory
# requires -Module WriteToLogs

[CmdletBinding(SupportsShouldProcess)]
Param()

Import-Module -Name ActiveDirectory -Verbose:$false

$style1 = '<style>
  body {color:#333333;font-family:Calibri,Tahoma,arial,verdana;font-size: 8pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #666666;}
  h4 {font-size: 8pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#eeeeee;background-color:#333333;border:1px solid black;padding:4px;}
  td {padding:4px; border:1px solid black;}
  .odd { background-color:#ffffff; }
  .even { background-color:#CFCFCF; }
</style>'

function Start-UsersGroupOperation {
    param(
        [Parameter(Mandatory)][ValidateSet('AddMember', 'RemoveMember')]$option,
        [Parameter(Mandatory)][string]$group,
        [Parameter(Mandatory)][string]$user,
        [string]$server = 'NYCSMEADS0012'
    )
    Add-Type -AssemblyName Microsoft.ActiveDirectory.Management
    try {
        if ($option -eq 'AddMember') {
            Add-ADGroupMember -Server $server -Identity $group -Members $user -Confirm:$false -ErrorAction Stop
            Write-ToConsoleAndLog -Output ('Added user {0} to {1}' -f ($user), ($group)) -Log $log -Verbose
        }
        elseif ($option -eq 'RemoveMember') {
            Remove-ADGroupMember -Server $server -Identity $group -Members $user -Confirm:$false
            Write-ToConsoleAndLog -Output ('Removed user {0} from {1}' -f ($user), ($group)) -Log $log -Verbose 
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADException] {
        [Management.Automation.ErrorRecord]$e = $_

        $info = [PSCustomObject]@{
            Exception = "$($e.Exception.Message) $($e.CategoryInfo.TargetName)"
        }
        Write-ToConsoleAndLog -Output $info.Exception -Log $log -Verbose
    }
    catch {
        $line = $_.InvocationInfo.ScriptLineNumber
        Write-ToConsoleAndLog -Output ('Error was in Line {0}, {1}' -f ($line), $_) -Log $log -Verbose
    }
}

$StartTime      = Get-Date -Format G
$CSVPath        = '\\storage\O365Migration$\'
$log            = $CSVPath + "_log\O365MigrationLog_$(get-date -Format yyyy-MM-dd_HH.MM.ss).log"
$server         = 'GTLSMEADS0012'
$addGroup       = 'WWI-O365-MigratedUsers'
$removeGroup    = 'WWI-O365-LinkSwapEnabled'
$result         = New-Object System.Collections.ArrayList
$info           = 0

# Will process any csv in $CSVPath
$users = Get-ChildItem -Path $CSVPath -Include *.csv |
    ForEach-Object {
    import-csv $_.FullName | Select-Object Alias, Status | Where-Object {$_.Status -eq 'Completed'}}  

$users.Alias | 

ForEach-Object -Process {
    $info++
    Start-UsersGroupOperation -option AddMember -group $addGroup -user $_ -server $server
    Start-UsersGroupOperation -option RemoveMember -group $removeGroup -user $_ -server $server
    Write-ToConsoleAndLog -Output "" -log $log -Verbose
    $null = $result.Add($info)
    }

$count = $result.Count

$HTML = New-HTMLHead -title "O365/AirWatch Group Swap" -style $style1
$HTML += "<h3>O365/AirWatch Group Swap</h3>"
$HTML += "<h4>Added to : $($addGroup)</h4>"
$HTML += "<h4>Removed from : $($removeGroup)</h4>"
$HTML += "<h4>($($count)) Users processed.</h4>"
$HTML += "<h4>Script Started: $($StartTime)</h4>"
$HTML += "<h3>See attached log file</h3>"
$HTML += "<h4>Script Completed: $(Get-Date -Format G)</h4>" | Close-HTML

$emailParams = @{
    To = 'sean.connealy@sonymusic.com'#, 'Alex.Moldoveanu@sonymusic.com'
    From = 'Posh Alerts poshalerts@sonymusic.com'
    Subject = 'O365/AirWatch Group Swap'
    SmtpServer = 'ussmtp01.bmg.bagint.com'
    BODY = ($HTML | Out-String)
    BodyAsHTML = $true
    Attachment = $log
}

Send-MailMessage @emailParams