Function Get-LatestScript1 {
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0)]
        [ValidateScript( {Test-Path $_})]
        [string]$path = $dev,
        [Parameter(Position = 1)]
        [ValidateNotNullorEmpty()]
        [int]$Last = 200,
        [switch]$Recurse
    )
  
    $files = Get-ChildItem -File -Recurse:$True -Filter '*.ps1' |
        Sort-Object -Property LastWriteTime -Descending | 
        Select-Object -First $Last -Property name, directory, LastWriteTime, Length, Extension, fullname |
        Out-GridView -Title 'Select one or more files to edit and click OK' -PassThru
    if ($files) {
        if ($Host.name -match "Visual Studio Code Host") {
          "C:\Program Files\Microsoft VS Code\Code.exe $($files).FullName"
        }
        else {
            ("$PSHome\powershell_ise.exe ({0}.FullName -join ',')" -f $files)
        }
    }
}

Get-LatestScript1