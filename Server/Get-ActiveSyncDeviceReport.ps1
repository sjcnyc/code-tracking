
$Collection = @() 

$output = "$env:HOMEDRIVE\Temp\abhisyncdevice.csv" 

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://<CAS_SERVER>/PowerShell/ -Authentication Kerberos 
Import-PSSession -Session $Session 
$Mailboxes = Get-CASMailbox -ResultSize unlimited 
$Mailboxes | foreach-object{ 
  $user = get-user $_.name 
  $devices = Get-ActiveSyncDeviceStatistics -Mailbox $_.Identity | 
    Where-Object {$_.LastSuccessSync -gt (Get-Date).AddDays(-30)} | 
    Select-Object -Property DeviceType,DeviceID,DeviceOS,DeviceFriendlyName,DeviceUserAgent,LastSuccessSync,FirstSyncTime,LastPolicyUpdateTime,Status,DeviceAccessState 
  $devices | foreach-object { 
    $column = '' | Select-Object -Property Userid,DeviceType,DeviceID,DeviceOS,DeviceFriendlyName,DeviceUserAgent,LastSuccessSync,FirstSyncTime,LastPolicyUpdateTime,Status,DeviceAccessState 

    $result = New-Object -TypeName System.Collections.ArrayList
    $info = [pscustomobject]@{
      $column.Userid = $user.name 
      $column.DeviceType = $_.DeviceType 
      $column.DeviceID = $_.DeviceID 
      $column.DeviceOS = $_.DeviceOS 
      $column.DeviceFriendlyName = $_.DeviceFriendlyName  
      $column.DeviceUserAgent = $_.DeviceUserAgent 
      $column.LastSuccessSync = $_.LastSuccessSync 
      $column.FirstSyncTime = $_.FirstSyncTime 
      $column.LastPolicyUpdateTime = $_.LastPolicyUpdateTime 
      $column.Status = $_.Status 
      $column.DeviceAccessState = $_.DeviceAccessState 
    }
     
    $null = $result.Add($info) 
  } 

  $result | export-csv -Path $output -NoTypeInformation 
} 


$SMTPServer = 'ussmtp01.bmg.bagint.com'  
$emailFrom = 'Posh Alerts poshalerts@sonymusic.com' 
$emailTo = 'sconnea@sonymusic.com' 
$TXTFile = $output   
$subject = 'Active Sync devices Report'    
$emailBody = 'Active Sync devices Report'   
  
Send-MailMessage -SmtpServer $SMTPServer -From $emailFrom -To $emailTo -Subject $subject -Body $emailBody -Attachments $TXTFile 