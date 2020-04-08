Function Convert-BytesToSize {
    [CmdletBinding()]
    Param ( [parameter(Mandatory = $False, Position = 0)][int64]$Size )
    Switch ($Size) {
        {$Size -gt 1PB}
        {$NewSize = "$([math]::Round(($Size / 1PB),2))PB"; Break}
        {$Size -gt 1TB}
        {$NewSize = "$([math]::Round(($Size / 1TB),2))TB"; Break}
        {$Size -gt 1GB}
        {$NewSize = "$([math]::Round(($Size / 1GB),2))GB"; Break}
        {$Size -gt 1MB}
        {$NewSize = "$([math]::Round(($Size / 1MB),2))MB"; Break}
        {$Size -gt 1KB}
        {$NewSize = "$([math]::Round(($Size / 1KB),2))KB"; Break}
        Default
        {$NewSize = "$([math]::Round($Size,2))Bytes"; Break}
    }
    Return $NewSize
}