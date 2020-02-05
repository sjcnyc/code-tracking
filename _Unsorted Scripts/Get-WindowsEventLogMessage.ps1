<#

.DESCRIPTION
 Expand WinEventLog Message and generating objects

.EXAMPLE
 Get-WindowsEventLogMessage -Id 4624 -LogName Security -MaxEvents 10

.EXAMPLE
 Get-WindowsEventLogMessage Security -StartTime (Get-Date).AddHours(-1) -Property Id,TimeCreated,TargetUserName


 HKLM\System\CurrentControlSet\Services\eventlog\Security
#>

$style1 = '<style>
  body {color:#666666;font-family:Calibri,Tahoma,arial,verdana;font-size: 10pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #666666;}
  h4 {font-size: 8pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#eeeeee;background-color:#666666;border:1px solid black;padding:4px;}
  td {padding:4px; border:1px solid black;}
  .odd { background-color:#ffffff; }
  .even { background-color:#E5E7E9; }
</style>'

$emailParams = @{
    to         = 'sean.connealy@sonymusic.com'
    from       = 'Posh Alerts poshalerts@sonymusic.com'
    subject    = "EventLog Report"
    smtpserver = 'ussmtp01.bmg.bagint.com'
    bodyashtml = $true
}

$eventArry = @('4873','4874','4882','4885','4887','4891','4896','4898','4899','4900','15','55','60','4657')

function Get-WindowsEventLogMessages {
    [CmdletBinding()]
    param(
        [string]$LogName,
        [string]$ProviderName,
        [int[]]$Id,
        [string]$Path,
        [int]$MaxEvents,
        [string]$ComputerName,
        [switch]$Force,
        [PSCredential]$Credential,
        [switch]$Oldest,
        [switch]$All,
        [string]$PropertyPrefix = '',
        [alias('After')][datetime]$StartTime,
        [alias('Before')][datetime]$EndTime,
        [string]$TimeCreatedFormat,
        [string[]]$Property = @('*')
    )

    $FilterHashtable = [Hashtable]@{}
    $Param = [Hashtable]@{}
    $SelectParam = [Hashtable]@{'Property' = $Property}

    if ($ProviderName) {$FilterHashtable.ProviderName = $ProviderName}
    if ($Id) {$FilterHashtable.Id = $Id}
    if ($LogName) {$FilterHashtable.LogName = $LogName}
    if ($StartTime) {$FilterHashtable.StartTime = $StartTime}
    if ($EndTime) {$FilterHashtable.EndTime = $EndTime}
    if ($MaxEvents) {$Param.MaxEvents = $MaxEvents}
    if ($Path) {$Param.Path = $Path}
    if ($ComputerName) {$Param.ComputerName = $ComputerName}
    if ($Credential) {$Param.Credential = $Credential}
    if ($Force) {$Param.Force = $Force}
    if ($Oldest) {$Param.Oldest = $Oldest}
    if ($FilterHashtable) {$Param.FilterHashtable = $FilterHashtable}

    Get-WinEvent @Param | ForEach-Object {
        ([xml]($_.ToXml())).Event.EventData.Data | ForEach-Object -Begin {
            $Hash = [ordered]@{
                'Id'               = $_.Id
                'ProviderName'     = $_.ProviderName
                'TimeCreated'      = $(@{$true = $_.TimeCreated; $false = $_.TimeCreated.ToString($TimeCreatedFormat)}[[string]::IsNullOrEmpty($TimeCreatedFormat)])
                'LevelDisplayName' = $_.LevelDisplayName
                'TaskDisplayName'  = $_.TaskDisplayName
                'MachineName'      = $_.MachineName
            }
            if ($All) {
                $Hash.UserId = $_.UserId
                $Hash.KeywordsDisplayNames = $_.KeywordsDisplayNames
                $Hash.Version = $_.Version
                $Hash.Qualifiers = $_.Qualifiers
                $Hash.Level = $_.Level
                $Hash.Task = $_.Task
                $Hash.Opcode = $_.Opcode
                $Hash.Keywords = $_.Keywords
                $Hash.RecordId = $_.RecordId
                $Hash.ProviderId = $_.ProviderId
                $Hash.ProcessId = $_.ProcessId
                $Hash.ThreadId = $_.ThreadId
                $Hash.ActivityId = $_.ActivityId
                $Hash.RelatedActivityId = $_.RelatedActivityId
                $Hash.ContainerLog = $_.ContainerLog
                $Hash.MatchedQueryIds = $_.MatchedQueryIds
                $Hash.Bookmark = $_.Bookmark
                $Hash.OpcodeDisplayName = $_.OpcodeDisplayName
                $Hash.Properties = $_.Properties
                $Hash.Message = $_.Message
            }
        } -Process {
            $Hash.Add($($PropertyPrefix + $_.Name), $_.'#text')
        } -End {
            [pscustomobject]$Hash | Select-Object @SelectParam
        }
    }
}

$events = Get-WindowsEventLogMessages -LogName System -Id $eventArry -All -MaxEvents 30 | Select-Object Id, LevelDisplayname, ProviderName, MachineName, Message # -Starttime (get-date).AddHours(-12)

$eventTable = $events | New-HTMLTable -setAlternating $false |
    Add-HTMLTableColor -Argument "Warning" -Column "LevelDisplayname" -AttrValue "background-color:#FFCC66;" -WholeRow |
    Add-HTMLTableColor -Argument "Error" -Column "LevelDisplayname" -AttrValue "background-color:#FFCC99;" -WholeRow
$HTML = New-HTMLHead -title "EventLog Report" -style $style1
$HTML += "<h3>EventLog Report</h3>"
$HTML += $eventTable | Close-HTML

Send-MailMessage @emailParams -Body ($HTML | Out-String)