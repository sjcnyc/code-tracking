function Get-ServiceState 
{
  [cmdletbinding()]
  param(
    [string]$SvcName = 'Spooler',
    [string]$SvrName = 'USDF48E38ABF907'
  )

  #Initialize variables:
  [string]$WaitForIt = ''
  [string]$Verb = ''
  [string]$Result = 'FAILED'
  $svc = (Get-Service -ComputerName $SvrName -Name $SvcName)
  $resultArry = @()
  $resultArry += '<h3 style="font-family:verdana">'
  Write-Verbose -Message "$SvcName on $SvrName is $($svc.status)"
  $resultArry += "$SvcName on $SvrName is $($svc.status)"
  Switch ($svc.status) {
    'Stopped' 
    {
      Write-Verbose -Message "Starting $SvcName..."
      $resultArry += "Starting $SvcName..."
      $Verb = 'start'
      $WaitForIt = 'Running'
      $svc.Start()
    }
    'Running' 
    {
      Write-Verbose -Message "Stopping $SvcName..."
      $resultArry += "Stopping $SvcName..."
      $Verb = 'stop'
      $WaitForIt = 'Stopped'
      $svc.Stop()
    }
    Default 
    {
      Write-Verbose -Message "$SvcName is $($svc.status).  Taking no action."
      $resultArry += "$SvcName is $($svc.status).  Taking no action."
    }
  }
  if ($WaitForIt -ne '') 
  {
    Try 
    {
      # For some reason, we cannot use -ErrorAction after the next statement:
      $svc.WaitForStatus($WaitForIt,'00:03:00')
    }
    Catch 
    {
      Write-Verbose -Message "After waiting for 3 minutes, $SvcName failed to $Verb."
      $resultArry += "After waiting for 3 minutes, $SvcName failed to $Verb."
    }
    $svc = (Get-Service -ComputerName $SvrName -Name $SvcName)
    if ($svc.status -eq $WaitForIt) 
    {
      $Result = 'SUCCESS'
    }
    Write-Verbose -Message "$Result`: $SvcName on $SvrName is $($svc.status)"
    $resultArry += "$Result`: $SvcName on $SvrName is $($svc.status)"
  }

  $resultArry = $resultArry -join '<br />'
<#  $resultArry += '</h3>'
  
  $smtp    = 'ussmtp01.bmg.bagint.com'
  $from    = 'Posh Alerts poshalerts@sonymusic.com'   
  $to      = 'sean.connealy@sonymusic.com'
  $subject = '[Stop Apache Tomcat 7.0.61 Server Service] Execution Report.'
  
  $emailParams = @{
    to         = $to
    from       = $from
    subject    = $subject
    smtpserver = $smtp
    body       = ($resultArry | Out-String)
    bodyashtml = $true
  }

  if ($resultArry -ne $null) 
  {
    Send-MailMessage @emailParams
  }#>
}

Get-ServiceState -Verbose