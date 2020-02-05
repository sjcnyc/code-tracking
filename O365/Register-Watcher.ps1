Function Register-Watcher 
{
  param ([Parameter(Mandatory=$true)]$folder)
  $filter = '*.*' #all files
  $watcher = New-Object -TypeName IO.FileSystemWatcher -ArgumentList $folder, $filter -Property @{
    IncludeSubdirectories = $false
    EnableRaisingEvents   = $true
  }

  $scripblock = @"
  write-output "File changed"
"@

  $changeAction = [scriptblock]::Create($scripblock)

  Register-ObjectEvent -InputObject $watcher -EventName 'Created' -Action $changeAction
}

Register-Watcher -folder 'C:\temp\O365_cutover'