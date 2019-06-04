function script:Start-ProcessAndLog {
  param (
    [Parameter(Mandatory=$true)]
    $exePath,
    $logFile,
    [Parameter(Mandatory=$true)]$args
  )

  $proc = Start-Process -FilePath $exePath -ArgumentList $args -PassThru 
  $handle = $proc.Handle
  $proc.WaitForExit()


  if ($proc.ExitCode -eq '0') {
    
    Write-Warning "$($proc.Name) exited with status code $($proc.ExitCode)"
    
  }
}


Start-ProcessAndLog -exePath notepad -args "new.txt"