function Find-Cmdlet {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromRemainingArguments)]
        [String[]]
        $Terms
    )
    try {
        $Uri = 'https://find-cmdlet.com/search?q={0}&t=json' -f ($Terms -join '+')
        $JsonObject = Invoke-WebRequest -Uri $Uri | Select-Object -ExpandProperty Content | ConvertFrom-Json
        $OGVSelection = $JsonObject | Out-GridView -PassThru
        Start-Process $OGVSelection.url
    }
    catch {
      Write-Output "Module not found"
    }
}

Find-Cmdlet -Terms "active directory"