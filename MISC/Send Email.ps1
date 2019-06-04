Function Send-Email{

  Param (

       [Parameter(Mandatory=$True,Position=0)]
       [String]$EmailFrom,

       [Parameter(Mandatory=$True,Position=1)]
       [String]$EmailTo,

       [Parameter(Mandatory=$True,Position=2)]
       [String]$Subject,

       [Parameter(Mandatory=$True,Position=3)]
       [String]$Body,

       [Parameter(Mandatory=$True,Position=4)]
       [String]$SMTPServer,

       [Parameter(Mandatory=$True,Position=5)]
       [String]$SMTPPort,

       [Parameter(Mandatory=$True,Position=6)]
       [String]$Username,

       [Parameter(Mandatory=$True,Position=7)]
       [String]$Password
     )
 
  $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, $smtpport) 
  $SMTPClient.EnableSsl = $true 
  $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($username, $password); 
  $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
}