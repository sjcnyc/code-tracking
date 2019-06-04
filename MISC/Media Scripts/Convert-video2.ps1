Function Convert-Video {
    [CmdletBinding()]
    Param(  [Parameter(Mandatory=$True,Position=1)] 
        [string]$path,
        [string]$Source = '.avi',
        $DeleteOriginal = $true
        )

$results = @()

Get-ChildItem -Path:$path -Include:"*$Source" -Recurse |  ForEach-Object  {
        $file = $_.Name.Replace($_.Extension,'.mp4')
        $input = $_.FullName
        $output = $_.DirectoryName
        $output = "$output\$file"

        write-host $input
        $arguments = "-i `"$input`" -c:v copy -c:a copy `"$output`" -y"
        $ffmpeg = ". 'C:\Program Files\ffmpeg\bin\ffmpeg.exe'"
       
        $Status = Invoke-Expression "$ffmpeg $arguments 2>&1"

        $t = $Status[$Status.Length-2].ToString() + " " + $Status[$Status.Length-1].ToString()
        $results += $t.Replace("`n","")
       
        if($DeleteOriginal -and $t.Replace("`n","").contains("%")) {
           # Remove-Item -Path $_.FullName 
            Remove-Item -Path $_.FullName -Force
        }
    }
    
    if ($results) {
        return $results
    }
    else {
        return 'No file found'
    }
}



<#Function Convert-Audio{
    [CmdletBinding()]
    Param(  [Parameter(Mandatory=$True,Position=1)] [string]$path,
            [string]$Source = '.wav', #The source or input file format
            $rate = '192k', #The encoding bit rate
            $DeleteOriginal = $true)

$results = @()
#This script was derived from Scott Wood's post at this site http://blog.abstractlabs.net/2013/01/batch-converting-wma-or-wav-to-mp3.html
#Thanks Scott.
Get-ChildItem -Path:$path -Include:"*$Source" -Recurse | ForEach-Object -Process: {
        $file = $_.Name.Replace($_.Extension,'.mp3')
        $input = $_.FullName
        $output = $_.DirectoryName
        $output = "$output\$file"
#-i Input file path
#-id3v2_version Force id3 version so windows can see id3 tags
#-f Format is MP3
#-ab Bit rate
#-ar Frequency
# Output file path
#-y Overwrite the destination file without confirmation
        $arguments = "-i `"$input`" -id3v2_version 3 -f mp3 -ab $rate -ar 44100 `"$output`" -y"
        $ffmpeg = ".'C:\Users\Greg\Programming\ffmpeg\bin\ffmpeg.exe'"
       
        #Hide the output
        $Status = Invoke-Expression "$ffmpeg $arguments 2>&1"
        $t = $Status[$Status.Length-2].ToString() + " " + $Status[$Status.Length-1].ToString()
        $results += $t.Replace("`n","")
       
        #Delete the old file when finished if so requested
        if($DeleteOriginal -and $t.Replace("`n","").contains("%")) {
            Remove-Item -Path:$_
        }
    }
    if ($results) {
        return $results
    }
    else {
        return "No file found"
    }
}#>
