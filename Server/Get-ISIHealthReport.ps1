

function New-ISIHealthReport {
  param (
    [string]$ClusterName,
    [string]$reportPath
  )
  $body= (Get-Content $reportPath | out-string )

  $HeaderHTML = 
  @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html><head><title>$($ClusterName) Cluster Health Report..</title>
<style type="text/css">
<!--

pre {
   font-family: "courier new", courier, monospace;
   font-size: 11px;
}

-->
</style>
</head>
<body>
<h1>$($ClusterName) Cluster Health Report.</h1>
"@


  $body ="<pre> $($body) </pre>"

  $FooterHTML = 
  @"
<pre>
Report Generated: $(get-date -f dd-MM-yyyy)
</pre>
</body>
</html>
"@

  $html = $HeaderHTML + $body + $FooterHTML


  $smtpProps =@{
    smtpserver = 'ussmtp01.bmg.bagint.com'
    From = 'Posh Alerts poshalerts@sonymusic.com'
    To = 'sean.connealy@sonymusic.com'#,'Alex.Moldoveanu@sonymusic.com','kim.lee@sonymusic.com'
    Subject = "$($ClusterName) Cluster Health Report."
    Body = $html
    BodyasHTML = $true
  }
    
  Send-MailMessage @smtpProps
}

#New-ISIHealthReport -ClusterName 'Storage' -reportPath '\\storage\ifs$\infra\Test\isilon_status*.txt'

#New-ISIHealthReport -ClusterName 'MPIsilon' -reportPath '\\mpisilon\ifs\infra\Test\isilon_status*.txt'