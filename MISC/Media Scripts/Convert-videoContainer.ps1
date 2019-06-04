#requires -Version 1
function Write-Log 
{ 
  param
  (
    [string]$strMessage
  )

  $LogDir = 'C:\windows\temp\'
  $Logfile = '\Conversion-Log.txt'
  $Path = $LogDir + $Logfile
  [string]$strDate = Get-Date
  Add-Content -Path $Path -Value ($strDate + "`t:`t"+ $strMessage)
}

function Convert-VideoToMP4 {
  param (
    [string]$searchPath ,
    [string]$fileType = '.avi'   
  )

  $oldVideos = Get-ChildItem -Path $searchPath -Include:"*$filetype" -Recurse
  #$oldVideos = "F:\Media\Movies\_2010s\Solace (2015)\solace.2015.avi"

  #Set-Location -Path 'C:\Program Files\ffmpeg\bin\'

  foreach ($OldVideo in $oldVideos) 
  {
    $newVideo = [io.path]::ChangeExtension($OldVideo.FullName, '.mp4')
    & 'C:\Program Files\ffmpeg\bin\ffmpeg.exe' -i $($OldVideo) -c:v copy -c:a copy $($newVideo) >$null 2>&1
    $OriginalSize = (Get-Item $OldVideo).length 
    $ConvertedSize = (Get-Item $newVideo).length 
    [long]$Lbound = [Math]::Ceiling($OriginalSize * .85)
    [long]$Ubound = [Math]::Ceiling($OriginalSize * 1.15)

    If($ConvertedSize -eq $OriginalSize -or ($ConvertedSize -ge $Lbound -and $ConvertedSize -le $Ubound))
    {
      Write-Log "$($newVideo) has been successfully updated"
      Remove-Item $OldVideo
      If (Test-Path $OldVideo)
      {
        Write-Log "Unable to remove $($OldVideo)"
      }

      Else
      {
        Write-Log "Successfully removed $($OldVideo)"
      }
    }
    elseif($ConvertedSize -lt $Lbound)
    {
      Write-Log "$($newVideo) Is too small. Size is $($ConvertedSize)"
    }
    elseif($ConvertedSize -gt $Ubound)
    {
      Write-Log "$($newVideo) Is too big. Size is $($ConvertedSize)"
    }
  }
}
