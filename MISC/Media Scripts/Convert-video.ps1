function Convert-VideoToMPG {

    [CmdletBinding()]
    Param(  [Parameter(Mandatory = $True, Position = 1)]
        [string]$path,
        $Source = @("*.mkv", "*.avi", "*.mp4"),
        $DeleteOriginal = $true
    )

    $count = 0

    $results = @()

    $collection = Get-ChildItem -Path $path -Include $Source -Recurse

    Get-ChildItem -Path $path -Include $Source -Recurse |  ForEach-Object -Process: {

        foreach ($item in $collection) {

            $count++
            $percentComplete = ($count / $collection.count) * 100

            Write-InlineProgress -Activity "$($item.Name)" -PercentComplete $percentComplete -ProgressCharacter ([char]9632) -ProgressFillCharacter ([char]9632) -ProgressFill ([char]183) -BarBracketStart '[' -BarBracketEnd ']'

            $file = $item.Name.Replace($item.Extension, '.mp4')
            $input = $item.FullName
            $output = $item.DirectoryName
            $output = "$output\_$file"

            #write-host $input
            $arguments = "-i `"$input`" -c:v copy -c:a copy `"$output`" -y"
            $ffmpeg = ". 'C:\Program Files\ffmpeg\bin\ffmpeg.exe'"

            $Status = Invoke-Expression "$ffmpeg $arguments 2>&1"

            $t = $Status[$Status.Length - 2].ToString() + ' ' + $Status[$Status.Length - 1].ToString()
            $results += $t.Replace("`n", '')


            if ($DeleteOriginal) {
                Remove-Item -Path $input

                if ($results) {
                    #write-host "converted $($input)"
                }
                else {
                    return 'No file found'
                }
            }
        }
        Write-InlineProgress -Activity 'Finished processing all items' -Complete
    }
}
