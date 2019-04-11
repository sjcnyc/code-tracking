#Requires -Version 3.0 
<# 
    .SYNOPSIS 


    .DESCRIPTION 

 
    .NOTES 
        File Name  : Test-ADCredential
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 4/3/2014

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE

    .EXAMPLE

#>
function Test-ADCredential
{
  param(
    [System.Management.Automation.Credential()]
    $Credential
  )

    Add-Type -AssemblyName System.DirectoryServices.AccountManagement 
    $info = $Credential.GetNetworkCredential()
    if ($info.Domain -eq '') { $info.Domain = $env:USERDOMAIN }

    $TypeDomain = [System.DirectoryServices.AccountManagement.ContextType]::Domain
    try
    {
        $pc = New-Object System.DirectoryServices.AccountManagement.PrincipalContext $TypeDomain,$info.Domain
        $pc.ValidateCredentials($info.UserName,$info.Password)
    }
    catch
    {
     Write-Warning "Unable to contact domain '$($info.Domain)'. Original error:$_"
    }
}