<#
.SYNOPSIS
Set-LocalAdminPassword queries AD for a list of computers and changes the password of a local account 
you specify (Administrator by default).
.DESCRIPTION
Written to set local passwords domain wide after MS14-025 GPP vulnerability disallowed saving passwords 
in Group Policy Preferences (http://support.microsoft.com/kb/2962486).
.NOTES
 Author: Jesse Kaufman
 Date: 6/19/2014
.PARAMETER account
Default to Administrator, but can be changed to any local account.
.PARAMETER logfilelocation
Defaults to same location as script was run from.  Change to save to a different location.
.PARAMETER LDAPfilter
Use either this or csvlocation. Defaults to use LDAPfilter. By default will apply to ALL computers in the domain.  
Use LDAP Query to identify subset of machines
.PARAMETER csvlocation
Use either this or LDAPFilter.  Defaults to use LDAPfilter. .csv specified should only contain computernames
.REQUIREMENTS
At least Powershell v2, Powershell remoting enabled on remote machine, account must have administrative privlidges on remote machine.  
To run the LDAP filter parameter, you must have imported the ActiveDirectory Powershell module.  
.EXAMPLE
Set-LocalAdminPassword -account ops -logfile \\files\logs -filter "(objectClass=computer)(name=*laptop*)"
Set-LocalAdminPassword -account Administrator -logfile C:\Logs -csvlocation \\files\logs\
 
#>
 
function Set-LocalAdminPassword { 
  [CmdletBinding(DefaultParameterSetName='UseADfilter')]
  Param(
    [Parameter(Mandatory=$true, Position=0, HelpMessage='Input new password')]
    [SecureString]$pass,
    [string]$account = 'administrator',
    [string]$logfilelocation = 'C:\',
    [Parameter(Mandatory=$True, ParameterSetName='UseCSV')][string]$csvlocation,
    
    
    [Parameter(Mandatory=$True, ParameterSetName='UseADFilter')] [string]$LDAPfilter = '(objectClass=computer)(name=L1132E-WS1)'
  )
  
  $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))
  $logname = 'change'+$account+'password.csv'
  $logfile = $logfilelocation+'\'+$logname
  
  
  Function Get-MyModule
  {
    Param([string]$name)
    if(-not(Get-Module -name $name))
    {
      if(Get-Module -ListAvailable |
      Where-Object { $_.name -eq $name })
      {
        Import-Module -Name $name
        $true
      } #end if module available then import
      else { $false } #module not available
    } # end if not module
    else { $true } #module already loaded
  } #end function get-MyModule
  
  
  
  # Check Parameter set and set Computers variable accordingly.  
  If ($PSCmdlet.ParameterSetName -eq 'UseADfilter'){
    # Check if ActiveDirectory Powershell module is installed
    If (get-mymodule -name 'ActiveDirectory'){
      $Computers = Get-ADComputer -LDAPFilter "$LDAPfilter" | Select-Object -expand name
    }
    Else {'ActiveDirectory Module not installed on this system. Please run this script from a system with the ActiveDirectory Module';exit}
  }
  Else{}
  IF ($PSCmdlet.ParameterSetName -eq 'UseCSV'){
    $Computers = Get-Content $csvlocation
  }
  Else{}
  
  
  # Add properties to ADComputers array
  $Computers | add-member -membertype NoteProperty -Name ComputerName -Value $null -PassThru
  $Computers | add-member -membertype NoteProperty -Name Online -Value "$null" -passthru
  $Computers | add-member -membertype NoteProperty -Name ChangePasswordSuccess -Value "$null" -passthru
  $Computers | add-member -membertype NoteProperty -Name ChangePasswordError -Value $null -PassThru
  
  
  # Meaty part of script - for each computer, ping it (record error as a variable if it exists), then try 
  # to use Invoke-Command to run net user command on remote machine (record error as a variable if it exists)
  foreach ($Computer in $Computers) {
    Test-Connection $Computer -count 1 -quiet -ov pingreturn
    if ($pingreturn -eq 'True') {Invoke-Command -Computername $Computer {net.exe user "$account" "$password"} -ov passwordchange -ea SilentlyContinue -ev passwordchangeerror}
    # fill in properties for each object
    $Computer.Computername = $Computer
    $Computer.changepassworderror = $passwordchangeerror
    $Computer.online = $pingreturn
    $Computer.changepasswordsuccess = [boolean]$passwordchange
    Clear-variable passwordchangeerror
    Clear-variable passwordchange
  }
  
  # write out in a table for export
  $Computers | Select-Object -property `
  @{n='Computer';e={$_.computername}},
  @{n='Online?';e={$_.online}},
  @{n='Success';e={$_.changepasswordsuccess}},
  @{n='Error Message';e={$_.changepassworderror}} | Export-CSV $logfile
}