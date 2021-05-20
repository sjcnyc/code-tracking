function Get-ScreenShot {
  Param(
    # Specify the directory to create the files in.
    # The files names are a combination of the display name and a timestamp
    [Parameter()]
    [Alias("Path")]
    [string]$Directory = ".",

    #The lower the number specified, the higher the compression and therefore the lower the quality of the image. Zero would give you the lowest quality image and 100 the highest.
    [Parameter()]
    [ValidateRange(0, 100)]
    [int]$Quality = 100,

    # By default, only the PRIMARY display is captured
    [Parameter()]
    [Switch]$AllScreens
  )


  Set-StrictMode -Version 2
  Add-Type -AssemblyName System.Windows.Forms

  if ($AllScreens) {
    $Capture = [System.Windows.Forms.Screen]::AllScreens
  }
  else {
    $Capture = [System.Windows.Forms.Screen]::PrimaryScreen
  }
  foreach ($C in $Capture) {
    $FileName = '{0}-{1}.jpg' -f (Join-Path (Resolve-Path $Directory) ($c.DeviceName -split "\\")[3]), (Get-Date).ToString('yyyyMMdd_HHmmss')


    $Bitmap = New-Object System.Drawing.Bitmap($C.Bounds.Width, $C.Bounds.Height)
    $G = [System.Drawing.Graphics]::FromImage($Bitmap)
    $G.CopyFromScreen($C.Bounds.Location, (New-Object System.Drawing.Point(0, 0)), $C.Bounds.Size)
    $g.Dispose()

    $EncoderParam = [System.Drawing.Imaging.Encoder]::Quality
    $EncoderParamSet = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $EncoderParamSet.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($EncoderParam, $Quality)
    $JPGCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where {$_.MimeType -eq 'image/jpeg'}
    $Bitmap.Save($FileName , $JPGCodec, $EncoderParamSet)
    $FileSize = [INT]((Get-Childitem $FileName).Length / 1KB)
    Write-Verbose ("Display [$($c.DeviceName)] ScreenCapture saved to File [$FileName] Size [$FileSize] KB")
  }
}