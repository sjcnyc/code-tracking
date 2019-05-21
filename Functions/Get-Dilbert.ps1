#requires -Version 3
function Get-Dilbert
{
  [CmdletBinding()]
  [OutputType([int])]
  Param
  (
    [Parameter(ValueFromPipelineByPropertyName = $true, Position = 0)]
    [ValidateSet ('-1', '-2', '-3', '-4')][int]$Last        
  )
  Process
  {
      
   $emailParams =@{
    to         = 'sean.connealy@sonymusic.com'  
    from       = 'Posh Alerts poshalerts@sonymusic.com'
    smtpserver = 'ussmtp01.bmg.bagint.com'
    bodyashtml = $true
    }
  
    $VerbosePreference = 'Continue'
    if ($Last)
    {
      $lastDate = (Get-Date).AddDays($Last) | Get-Date -Format 'yyyy-MM-dd'
      $dil = Invoke-WebRequest -Uri "http://dilbert.com/strip/$lastDate" -UseBasicParsing
      $bild = $dil.Images |
      Where-Object -FilterScript { $_.class -eq 'img-responsive img-comic' } |
      Select-Object -Property src
      Invoke-WebRequest -Uri $bild.src -OutFile "$PSScriptRoot\$lastDate.gif" -UseBasicParsing

    $image = @{ 
    image1 = "$PSScriptRoot\$lastDate.gif" 
    }  
    
    $body = '<html>  
               <body>  
                 <img src="cid:image1"><br> 
               </body>  
             </html>'  

      Send-InlineMailMessage @emailParams -InlineAttachments $image -Subject "Dilbert $lastDate" -Body $body
    }
    else
    {
      $today = (Get-Date -Format 'yyyy-MM-dd')
      $dil = Invoke-WebRequest -Uri "http://dilbert.com/strip/$today" -UseBasicParsing
      $bild = $dil.Images |
      Where-Object -FilterScript { $_.class -eq 'img-responsive img-comic' } |
      Select-Object -Property src
      Invoke-WebRequest -Uri $bild.src -OutFile "$PSScriptRoot\$today.gif"
    $image = @{ 
    image1 = "$PSScriptRoot\$today.gif" 
    }  
    
    $body = '<html>  
               <body>  
                 <img src="cid:image1"><br> 
               </body>  
             </html>'  

      Send-InlineMailMessage @emailParams -InlineAttachments $image -Subject "Dilbert $today" -Body $body
    }
  }
}

Get-Dilbert
