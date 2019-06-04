function Set-UAC {
<#
  
.SYNOPSIS
    
Enables or disables User Account Control (UAC) on a computer, locally or remote.
  
.DESCRIPTION
    
Enables or disables User Account Control (UAC) on a computer, locally or remote.
  
.AUTHOR
    
Jeff Wouters
  
.NOTES
    
PowerShell 2.0 or higher is required for proper execution of this script.
  
.EXAMPLE
    
Set-UAC -Enabled 
  
.EXAMPLE
    
Set-UAC -Disabled -Restart
  
.EXAMPLE
    
Set-UAC -ComputerName [ComputerName] -Enabled -Restart
  
.EXAMPLE
    
Set-UAC -ComputerName [ComputerName] -Disabled
  
.INPUTS
    
N/A.
#>
  [cmdletBinding(SupportsShouldProcess = $True)]
  param(
    [parameter(ValueFromPipeline = $False, ValueFromPipelineByPropertyName = $True, Mandatory = $False)][Alias('Computer')] [string]$ComputerName = $env:ComputerName,
    [parameter(ValueFromPipeline = $False, ValueFromPipelineByPropertyName = $True, Mandatory = $False)][switch]$Enable,
    [parameter(ValueFromPipeline = $False, ValueFromPipelineByPropertyName = $True, Mandatory = $False)][switch]$Disable,
    [parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)][switch]$Restart
  )
  [string]$RegPath = 'Software\Microsoft\Windows\CurrentVersion\Policies\System'
  [string]$RegValue = 'EnableLUA'
  $AccessReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$ComputerName)
  $Subkey = $AccessReg.OpenSubKey($RegPath,$True)
  $Subkey.ToString() | Out-Null
  if (!($Enable) -and !($Disable)){
    $UACMessage = 'Please use either the -Enable or -Disable parameter to change the status of UAC.'
  } elseif ($Enable) {
    $Subkey.SetValue($RegValue, 1)
  } elseif ($Disable) {
    $Subkey.SetValue($RegValue, 0)
  }
  if ($Restart) {
    Restart-Computer $ComputerName -Force
    $RestartMessage = "$ComputerName will now perform a in order for the UAC configuration change to take affect."
  }
  else {
    $RestartMessage = "Please restart $ComputerName in order for the UAC configuration change to take affect."
  }
  return $UACMessage
  return $RestartMessage
}