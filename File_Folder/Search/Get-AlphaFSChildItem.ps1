function Get-AlphaFSChildItem {
    param(
        [Parameter(
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )
        ][string]$Path = (Get-Location).Path,
        [string]$SearchPattern = '*',
        [array]$Include,
        [array]$Exclude,
        [Switch]$Recurse
    )
    $Error.Clear()
	
    if (!(Get-Module -name PSAlphaFS -ErrorAction SilentlyContinue)) {
        Install-Module -Name PSAlphaFS -Scope CurrentUser

    }
    if ($Error) {
        return
    }
	
    $items = @()
    $FileSystemEntryInfo = @()
    if ($recurse) {
        $SearchOption = 'AllDirectories'
    }
    else {
        $SearchOption = 'TopDirectoryOnly'
    }
    $array = @()
    Try {
        $array = [Alphaleonis.Win32.Filesystem.Directory]::EnumerateDirectories($Path, $SearchPattern, [System.IO.SearchOption]::$SearchOption)
        Foreach ($file in $array) {
            $items += $file
        }
    }
    Catch [System.UnauthorizedAccessException] {
    }
    Try {
        $array = [Alphaleonis.Win32.Filesystem.Directory]::EnumerateFiles($Path, $SearchPattern, [System.IO.SearchOption]::$SearchOption)
        Foreach ($file in $array) {
            $items += $file
            }
    }
    Catch [System.UnauthorizedAccessException] {
    }
    foreach ($item in $items) {
        $FileSystemEntryInfo += [Alphaleonis.Win32.Filesystem.File]::GetFileSystemEntryInfo($item)
    }
    if ($Include) {
        $IncludedItems = @()
        foreach ($inc in $Include) {
            $IncludedItems += $FileSystemEntryInfo | Where-Object {$_.FullPath -like "$inc"}
        }
        $FileSystemEntryInfo = $IncludedItems
    }	
    if ($Exclude) {
        foreach ($Exc in $Exclude) {
            $FileSystemEntryInfo = $FileSystemEntryInfo | Where-Object {$_.FullPath -notlike "$Exc"}
        }
    }
    return $FileSystemEntryInfo | Select-Object @{N = 'FullName'; E = {$_.FullPath}}, @{N = 'LongFullName'; E = {$_.LongFullPath}}, *
}