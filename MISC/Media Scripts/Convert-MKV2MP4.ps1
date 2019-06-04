function Write-Log 
    { 
        param
        (
            [string]$strMessage
        )

            $LogDir = 'C:\temp\'
            $Logfile = "\Conversion-Log.txt"
            $Path = $logdir + $logfile
            [string]$strDate = get-date
            add-content -path $Path -value ($strDate + "`t:`t"+ $strMessage)
}


function Convert-VideoContainers {
 [CmdletBinding()]
    Param(  
    [Parameter(Mandatory=$False,Position=1)] 
    [string]$SearchPath="F:\Media\Movies\_2010s\12 Years a Slave (2013)\",
    [string]$Extention=".mkv"
     )


$results = @()

#$SearchPath = 'F:\Media\Movies\_2010s\13 Assassins (2011)\'
$oldVideos = Get-ChildItem -Include @("*.mkv") -Path $SearchPath -Recurse;
$newVideo = [io.path]::ChangeExtension($oldVideos.FullName, '.mp4')

$ffmpeg = ". 'C:\Program Files\ffmpeg\bin\ffmpeg.exe'"
$arguments = "-i `"$oldVideos`" -c:v copy -c:a copy `"$newVideo`""

Set-Location -Path $SearchPath

Get-ChildItem -Path $SearchPath -Include "*$Extention" -Recurse | ForEach-Object -Process: {



foreach ($OldVideo in $oldVideos) 
{
   # $newVideo = [io.path]::ChangeExtension($OldVideo.FullName, '.mp4')
    #& 'C:\Program Files\ffmpeg\bin\ffmpeg.exe' -i $($OldVideo) -c:v copy -c:a copy $($NewVideo)

    $Status = Invoke-Expression "$ffmpeg $arguments 2>&1"
    $t = $Status[$Status.Length-2].ToString() + " " + $Status[$Status.Length-1].ToString()
    $results += $t.Replace("`n","")

 #   $OriginalSize = (Get-Item $OldVideo).length 
 #   $ConvertedSize = (Get-Item $Newvideo).length 
 #   [long]$Lbound = [Math]::Ceiling($OriginalSize * .85);
 #   [long]$Ubound = [Math]::Ceiling($OriginalSize * 1.15);


   }
  }
      if ($results) {
        return $results

    }
    else {
        return "No file found"
    }
}




# $arguments = "-i `"$input`" -id3v2_version 3 -f mp3 -ab $rate -ar 44100 `"$output`" -y"
# $ffmpeg = ".'C:\Users\Greg\Programming\ffmpeg\bin\ffmpeg.exe'"