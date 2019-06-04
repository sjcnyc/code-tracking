# Requires ADAudit Module
# Get-Command -Module ADAudit
# 
<#CommandType     Name                                               ModuleName                               
-----------     ----                                               ----------                               
Function        Convert-GUIDtoLDAPGUID                             adaudit                                  
Function        Get-ADGroupMembershipAudit                         adaudit                                  
Function        Get-ADObjectPagedAttribute                         adaudit                                  
Function        Get-ADUserAttributeChanges                         adaudit                                  
Function        Get-ADUserLogonTimes                               adaudit                                  
Function        Get-ADUserMembershipAudit                          adaudit                                  
Function        New-RandomPassword                                 adaudit                                  
Function        Test-ADUserCredentials                             adaudit                                  
Function        Test-ADUserLogonStatus                             adaudit  #>

function Get-UserLogonTime {
  [CmdletBinding()]
  param(
    [string]$SAMAccountName
    )

    if ($psBoundParameters['verbose'])
    {
      Get-ADUser -Filter {SAMAccountName -eq $SAMAccountName} | Get-ADUserLogonTimes -Verbose
    }
    else
    {
      $VerbosePreference = 'SilentlyContinue'
      Get-ADUser -Filter {SAMAccountName -eq $SAMAccountName} | Get-ADUserLogonTimes
    }
}

