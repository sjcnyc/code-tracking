$from = 'C:\TEMP\NetworkConfig'
$to = 'C:\TEMP\NetworkConfig\COMPRESSED_BACKUPS'

$exclude = @('*.log')
$excludeMatch = @('legacy_archives', 'COMPRESSED_BACKUPS')
[regex] $excludeMatchRegEx = ‘(?i)‘ + (($excludeMatch | ForEach-Object {[regex]::escape($_)}) –join '|') + ‘’
Get-ChildItem -Path $from -Recurse | 
    Where-Object { $excludeMatch -eq $null -or $_.FullName.Replace($from, '') -notmatch $excludeMatchRegEx} |
    Copy-Item -Destination {
    if ($_.PSIsContainer) {
        Join-Path $to $_.Parent.FullName.Substring($from.length)
    }
    else {
        Join-Path $to $_.FullName.Substring($from.length)
    }
} -Force

$exclude1 = @('legacy_archives', 'COMPRESSED_BACKUPS', '.log')

$Selectprop = @{'Property' = 'Fullname', 'Length', 'PSIsContainer'}

$array = @(Get-Childitem $from -recurse -ea 0 -force | Select-Object @SelectProp)

$folders = @($array | Where-Object {$_.PSIsContainer -eq $True})
$files = @($array | Where-Object {$_.PSIsContainer -eq $False})

for ($j = 0; $j -lt $exclude1.count; $j++) {
    $files = $files |
        Where-Object {
        $_.fullname -notmatch $exclude1[$j]
    }
    $exclude1[$j] = $exclude1[$j].substring(0, $exclude1[$j].length - 2)
    $folders = $folders | 
        Where-Object {
        $_.fullname -notmatch $exclude1[$j]
    }
}

foreach ($file in $files) {
    $file.FullName | ConvertFrom-Gzip -ErrorAction 0 -Encoding UTF8 | Out-String | Out-File "$($file.FullName).log"
    Remove-Item $file.FullName
}

Function ConvertFrom-Gzip {
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default')]
        [Alias('Fullname')]
        # [ValidateScript({$_.endswith('.gz*')})]
        [String]$Path,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'Default')]
        [ValidateSet('ASCII', 'Unicode', 'BigEndianUnicode', 'Default', 'UTF32', 'UTF7', 'UTF8')]
        [String]$Encoding = 'ASCII'
    )
    Begin {
        Set-StrictMode -Version Latest
        $enc = [System.Text.Encoding]::$encoding
    }
    Process {
        if (-not ([system.io.path]::IsPathRooted($path))) {
            Try {$path = (Resolve-Path -Path $Path -ErrorAction Stop).Path} catch {throw 'Failed to resolve path'}
        }
        $file = New-Object System.IO.FileStream $path, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
        $stream = new-object -TypeName System.IO.MemoryStream
        $GZipStream = New-object -TypeName System.IO.Compression.GZipStream -ArgumentList $file, ([System.IO.Compression.CompressionMode]::Decompress)
        $buffer = New-Object byte[](1024)
        $count = 0
        do {
            $count = $gzipstream.Read($buffer, 0, 1024)
            if ($count -gt 0) {
                $Stream.Write($buffer, 0, $count)
            }
        }
        While ($count -gt 0)
        $array = $stream.ToArray()
        $GZipStream.Close()
        $stream.Close()
        $file.Close()
        $enc.GetString($array).Split("`n")
    }
    End {}
}