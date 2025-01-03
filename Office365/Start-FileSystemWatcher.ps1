﻿Function Start-FileSystemWatcher {
    [cmdletbinding()]
    Param (
        [parameter()][string]$Path,
        [parameter()][ValidateSet('Changed', 'Created', 'Deleted', 'Renamed')]
        [string[]]$EventName,
        [parameter()][string]$Filter,
        [parameter()][System.IO.NotifyFilters]$NotifyFilter,
        [parameter()][switch]$Recurse,
        [parameter()][scriptblock]$Action
    )

    $FileSystemWatcher = New-Object -TypeName System.IO.FileSystemWatcher

    If (-NOT $PSBoundParameters.ContainsKey('Path')) {
        $Path = $PWD
    }

    $FileSystemWatcher.Path = $Path

    If ($PSBoundParameters.ContainsKey('Filter')) {
        $FileSystemWatcher.Filter = $Filter
    }

    If ($PSBoundParameters.ContainsKey('NotifyFilter')) {
        $FileSystemWatcher.NotifyFilter = $NotifyFilter
    }

    If ($PSBoundParameters.ContainsKey('Recurse')) {
        $FileSystemWatcher.IncludeSubdirectories = $True
    }

    If (-NOT $PSBoundParameters.ContainsKey('EventName')) {
        $EventName = 'Changed', 'Created', 'Deleted', 'Renamed'
    }

    If (-NOT $PSBoundParameters.ContainsKey('Action')) {
        $Action = {
            Switch ($Event.SourceEventArgs.ChangeType) {

                'Renamed' {
                    $Object = '{0} was  {1} to {2} at {3}' -f $Event.SourceArgs[-1].OldFullPath,
                    $Event.SourceEventArgs.ChangeType,
                    $Event.SourceArgs[-1].FullPath,
                    $Event.TimeGenerated
                }

                Default {
                    $Object = '{0} was  {1} at {2}' -f $Event.SourceEventArgs.FullPath,
                    $Event.SourceEventArgs.ChangeType,
                    $Event.TimeGenerated
                }
            }

            $WriteHostParams = @{
                ForegroundColor = 'Green'
                BackgroundColor = 'Black'
                Object = $Object
            }
            Write-Host  @WriteHostParams
        }
    }

    $ObjectEventParams = @{
        InputObject = $FileSystemWatcher
        Action = $Action
    }

    ForEach ($Item in  $EventName) {
        $ObjectEventParams.EventName = $Item
        $ObjectEventParams.SourceIdentifier = "File.$($Item)"
        Write-Verbose  -Message "Starting watcher for Event: $($Item)"
        $Null = Register-ObjectEvent  @ObjectEventParams
    }
}

$path = '\\storage\O365Migration$'

$FileSystemWatcherParams = @{

    Path         = '\\storage\O365Migration$'
    EventName    = 'Created'
    NotifyFilter = 'FileName'
    Verbose      = $True
    Action       = {
        $Item = Get-Item -Path $Event.SourceEventArgs.FullPath

        $WriteHostParams = @{
            ForegroundColor = 'Green'
            BackgroundColor = 'Black'
        }
        Switch  -regex ($Item.Extension) {
            '\.csv' {$WriteHostParams.Object = "Processing  CSV spreadsheet: $($Item.Name)"}
            Default {$WriteHostParams.Object = "Processing  File: $($Item.Name)"}
        }
        Start-Process -FilePath powershell.exe -ArgumentList { .\Add-RemoveUsersFromGroup.ps1 } -Wait -WindowStyle Normal
        $Item | Move-Item -Destination '\\storage\O365Migration$\_processedCSVs' -Force
        Get-ChildItem -Path '\\storage\O365Migration$\_processedCSVs\' -Filter '*.csv' | Rename-Item -NewName {[io.path]::ChangeExtension($_.Name, 'bak')}
        Write-Host  @WriteHostParams
    }
}
@('Created') | ForEach-Object {
    $FileSystemWatcherParams.EventName = $_
    Start-FileSystemWatcher  @FileSystemWatcherParams
}