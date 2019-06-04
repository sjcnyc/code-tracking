# 
# Change service user name and password 
# www.sivarajan.com 
# 
Clear-Host 
$UserName = 'Infralab\santhosh'  
$Password = 'Password' 
$Service = 'MpsSvc' #Change service name with your service name 
$Cred = Get-Credential #Prompt you for user name and password 
Import-CSV C:\Scripts\input.csv | % {  
$ServerN = $_.ServerName 
$svcD=Get-WmiObject win32_service -computername $ServerN -filter "name='$service'" -Credential $cred 
$StopStatus = $svcD.StopService() 
If ($StopStatus.ReturnValue -eq '0') # validating status - http://msdn.microsoft.com/en-us/library/aa393673(v=vs.85).aspx 
    {write-host "$ServerN -> Service Stopped Successfully"} 
$ChangeStatus = $svcD.change($null,$null,$null,$null,$null,$null,$UserName,$Password,$null,$null,$null) 
If ($ChangeStatus.ReturnValue -eq '0')  
    {write-host "$ServerN -> Sucessfully Changed User Name"} 
$StartStatus = $svcD.StartService() 
If ($ChangeStatus.ReturnValue -eq '0')  
    {write-host "$ServerN -> Service Started Successfully"} 
}