Function Get-LatestScript {

[cmdletbinding()]

Param(
[Parameter(Position=0)]
[ValidateScript({Test-Path $_})]
[string]$Path=$global:ScriptPath,
[Parameter(Position=1)]
[ValidateScript({$_ -ge 1})]
[int]$Newest=25
)

if (-Not $path) {
    $Path=(Get-Location).Path
}

#define a list of file extensions
$include="*.ps1","*.psd1","*.psm1","*.ps1xml"

Write-Verbose ("Getting {0} PowerShell files from {1}" -f $newest,$path)

#construct a title for Out-GridView
$Title=("Recent PowerShell Files in {0}" -f $path.ToUpper())

Get-ChildItem -Path $Path -Include $include -Recurse | 
Sort-Object -Property lastWriteTime -Descending |
Select-Object -First $newest -Property LastWriteTime,CreationTime,
@{Name="Size";Expression={$_.length}},
@{Name="Lines";Expression={(Get-Content $_.Fullname | Measure-object -line).Lines}},
Directory,Name,FullName | 
Out-Gridview -Title $Title -PassThru | % {$_; ise $_.FullName} | Out-Null
}