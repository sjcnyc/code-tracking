$SearchPath = 'F:\Media\Tv'

$oldVideos = Get-ChildItem -Include @("*.avi") -Path $SearchPath -Recurse;

Set-Location -Path 'C:\Program Files\ffmpeg\bin\';

foreach ($OldVideo in $oldVideos) 
{
    $newVideo = [io.path]::ChangeExtension($OldVideo.FullName, '.mp4')

        write-host $oldVideo
        $arguments = "-i `"$oldVideo`" -c:v copy -c:a copy `"$newVideo`" -y"
        $ffmpeg = ". 'C:\Program Files\ffmpeg\bin\ffmpeg.exe'"

    Invoke-Expression "$ffmpeg $arguments" >$null 2>&1

    $OriginalSize =  (Get-Item -Path $oldVideos.FullName).Length
    $ConvertedSize = (Get-Item -Path $newVideo).Length
        
    [long]$Lbound = [Math]::Ceiling($OriginalSize * .85);
    [long]$Ubound = [Math]::Ceiling($OriginalSize * 1.15);


        Write-Log "$($NewVideo) has been successfully updated"
        Remove-Item $OldVideo
        If (Test-Path $OldVideo)
        {
            write-host "Unable to remove $($OldVideo)"
        }

        Else
        {
            write-host "Successfully removed $($OldVideo)"
        }
}