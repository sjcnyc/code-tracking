Function Get-HorizontalLine {
    param
    (
        [System.String]
        $InputString = '.',
    
        [System.Int32]
        $Count = 1
    )
  
    # How long to make the hr
    $width = $host.UI.RawUI.BufferSize.Width - 1
  
    # How many times to repeat $Character in full
    $repetitions = [System.Math]::Floor($width / $InputString.Length)

    # How many characters of $InputString to add to fill each line
    $remainder = $width - ($InputString.Length * $repetitions)
  
    # Make line(s)
    1..$Count | ForEach-Object { ($InputString * $repetitions) + $InputString.Substring(0, $remainder)}
}

Set-Alias -Name hr -Value Get-HorizontalLine