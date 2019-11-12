function New-ADSIDirectoryEntry {
  <#
.SYNOPSIS
    Function to create a DirectoryEntry instance
.DESCRIPTION
    Function to create a DirectoryEntry instance
    This function is typically a helper function used by some of the other functions
    in the module ADSIPS
.PARAMETER Path
    The path of this DirectoryEntry.
    Default is $(([adsisearcher]"").Searchroot.path)
    https://msdn.microsoft.com/en-us/library/system.directoryservices.directoryentry.path.aspx
.PARAMETER Credential
    Specifies alternative credential to use
.PARAMETER AuthenticationType
    Specifies the optional AuthenticationType secure flag(s) to use
    The Secure flag can be used in combination with other flags such as ReadonlyServer, FastBind.
    See the full detailed list here:
    https://msdn.microsoft.com/en-us/library/system.directoryservices.authenticationtypes(v=vs.110).aspx
.EXAMPLE
    New-ADSIDirectoryEntry
    Create a new DirectoryEntry object for the current domain
.EXAMPLE
    New-ADSIDirectoryEntry -Path "LDAP://DC=FX,DC=lab"
    Create a new DirectoryEntry object for the domain FX.Lab
.EXAMPLE
    New-ADSIDirectoryEntry -Path "LDAP://DC=FX,DC=lab" -Credential (Get-Credential)
    Create a new DirectoryEntry object for the domain FX.Lab  with the specified credential
.LINK
    https://msdn.microsoft.com/en-us/library/system.directoryservices.directoryentry.aspx
.LINK
    http://www.lazywinadmin.com/2013/10/powershell-using-adsi-with-alternate.html
.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
  [CmdletBinding(SupportsShouldProcess = $true)]
  param (
    [Alias('DomainName')]
    $Path = $(([adsisearcher]"").Searchroot.path),

    [Alias("RunAs")]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential = [System.Management.Automation.PSCredential]::Empty,

    [System.DirectoryServices.AuthenticationTypes[]]$AuthenticationType
  )
  try {
    #If path isn't prefixed with LDAP://, add it
    if ($PSBoundParameters['Path']) {
      if ($Path -notlike "LDAP://*") {
        $Path = "LDAP://$Path"
      }
    }

    #Building Argument
    if ($PSBoundParameters['Credential']) {
      $ArgumentList = $Path, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
    }
    else {
      $ArgumentList = $Path
    }

    if ($PSBoundParameters['AuthenticationType']) {
      $ArgumentList += $AuthenticationType
    }

    if ($PSCmdlet.ShouldProcess($Path, "Create Directory Entry")) {
      # Create object
      New-Object -TypeName DirectoryServices.DirectoryEntry -ArgumentList $ArgumentList
    }
  }
  catch {
    $PSCmdlet.ThrowTerminatingError($_)

  }
}

function New-ADSIPrincipalContext {
  <#
.SYNOPSIS
    Function to create an Active Directory PrincipalContext object
.DESCRIPTION
    Function to create an Active Directory PrincipalContext object
.PARAMETER Credential
    Specifies the alternative credentials to use.
    It will use the current credential if not specified.
.PARAMETER ContextType
    Specifies which type of Context to use. Domain, Machine or ApplicationDirectory.
.PARAMETER DomainName
    Specifies the domain to query. Default is the current domain.
    Should only be used with the Domain ContextType.
.PARAMETER Container
    Specifies the scope. Example: "OU=MyOU"
.PARAMETER ContextOptions
    Specifies the ContextOptions.
    Negotiate
    Sealing
    SecureSocketLayer
    ServerBind
    Signing
    SimpleBind
.EXAMPLE
    New-ADSIPrincipalContext -ContextType 'Domain'
.EXAMPLE
    New-ADSIPrincipalContext -ContextType 'Domain' -DomainName "Contoso.com" -Cred (Get-Credential)
.NOTES
    https://github.com/lazywinadmin/ADSIPS
.LINK
    https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.principalcontext(v=vs.110).aspx
#>

  [CmdletBinding(SupportsShouldProcess = $true)]
  [OutputType('System.DirectoryServices.AccountManagement.PrincipalContext')]
  param
  (
    [Alias("RunAs")]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential = [System.Management.Automation.PSCredential]::Empty,

    [Parameter(Mandatory = $true)]
    [System.DirectoryServices.AccountManagement.ContextType]$ContextType,

    $DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::Getcurrentdomain(),

    $Container,

    [System.DirectoryServices.AccountManagement.ContextOptions[]]$ContextOptions
  )

  begin {
    $ScriptName = (Get-Variable -name MyInvocation -Scope 0 -ValueOnly).MyCommand
    Write-Verbose -Message "[$ScriptName] Add Type System.DirectoryServices.AccountManagement"
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
  }
  process {
    try {
      switch ($ContextType) {
        "Domain" {
          $ArgumentList = $ContextType, $DomainName
        }
        "Machine" {
          $ArgumentList = $ContextType, $ComputerName
        }
        "ApplicationDirectory" {
          $ArgumentList = $ContextType
        }
      }

      if ($PSBoundParameters['Container']) {
        $ArgumentList += $Container
      }

      if ($PSBoundParameters['ContextOptions']) {
        $ArgumentList += $($ContextOptions)
      }

      if ($PSBoundParameters['Credential']) {
        # Query the specified domain or current if not entered, with the specified credentials
        $ArgumentList += $($Credential.UserName), $($Credential.GetNetworkCredential().password)
      }

      if ($PSCmdlet.ShouldProcess($DomainName, "Create Principal Context")) {
        # Query
        New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList $ArgumentList
      }
    } #try
    catch {
      $PSCmdlet.ThrowTerminatingError($_)
    }
  } #process
}

function Get-ADSIUser
{
    <#
.SYNOPSIS
    Function to retrieve a User in Active Directory
.DESCRIPTION
    Function to retrieve a User in Active Directory
.PARAMETER Identity
    Specifies the Identity of the User
    You can provide one of the following properties
    DistinguishedName
    Guid
    Name
    SamAccountName
    Sid
    UserPrincipalName
    Those properties come from the following enumeration:
    System.DirectoryServices.AccountManagement.IdentityType
.PARAMETER Credential
    Specifies the alternative credential to use.
    By default it will use the current user windows credentials.
.PARAMETER DomainName
    Specifies the alternative Domain where the user should be created
    By default it will use the current domain.
.PARAMETER NoResultLimit
    Remove the SizeLimit of 1000
    SizeLimit is useless, it can't go over the server limit which is 1000 by default
.PARAMETER LDAPFilter
    Specifies the LDAP query to apply
.EXAMPLE
    Get-ADSIUser
    This example will retrieve all accounts in the current domain using
    the current user credential. There is a limit of 1000 objects returned.
.EXAMPLE
    Get-ADSIUser -NoResultLimit
    This example will retrieve all accounts in the current domain using
    the current user credential. Using the parameter -NoResultLimit will remove the Sizelimit on the Result.
.EXAMPLE
    Get-ADSIUser -Identity 'testaccount'
    This example will retrieve the account 'testaccount' in the current domain using
    the current user credential
.EXAMPLE
    Get-ADSIUser -Identity 'testaccount' -Credential (Get-Credential)
    This example will retrieve the account 'testaccount' in the current domain using
    the specified credential
.EXAMPLE
    Get-ADSIUSer -LDAPFilter "(&(objectClass=user)(samaccountname=*fx*))" -DomainName 'fx.lab'
    This example will retrieve the user account that contains fx inside the samaccountname
    property for the domain fx.lab. There is a limit of 1000 objects returned.
.EXAMPLE
    Get-ADSIUSer -LDAPFilter "(&(objectClass=user)(samaccountname=*fx*))" -DomainName 'fx.lab' -NoResultLimit
    This example will retrieve the user account that contains fx inside the samaccountname
    property for the domain fx.lab. There is NO limit of 1000 objects returned.
.EXAMPLE
    $user = Get-ADSIUser -Identity 'testaccount'
    $user.GetUnderlyingObject()| Select-Object -Property *
    Help you find all the extra properties and methods available
.NOTES
    https://github.com/lazywinadmin/ADSIPS
.LINK
    https://msdn.microsoft.com/en-us/library/System.DirectoryServices.AccountManagement.UserPrincipal(v=vs.110).aspx
#>

    [CmdletBinding(DefaultParameterSetName = "All")]
    [OutputType('System.DirectoryServices.AccountManagement.UserPrincipal')]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Identity")]
        [string]$Identity,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [String]$DomainName,

        [Parameter(Mandatory = $true, ParameterSetName = "LDAPFilter")]
        [string]$LDAPFilter,

        [Parameter(ParameterSetName = "LDAPFilter")]
        [Parameter(ParameterSetName = "All")]
        [Switch]$NoResultLimit

    )

    begin
    {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement

        # Create Context splatting
        $ContextSplatting = @{ ContextType = "Domain" }

        if ($PSBoundParameters['Credential'])
        {
            $ContextSplatting.Credential = $Credential
        }
        if ($PSBoundParameters['DomainName'])
        {
            $ContextSplatting.DomainName = $DomainName
        }

        $Context = New-ADSIPrincipalContext @ContextSplatting
    }
    process
    {
        if ($Identity)
        {
            Write-Verbose -Message "Identity"
            try {
                [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($Context, $Identity)
            } catch {
                if ($_.Exception.Message.ToString().EndsWith('"Multiple principals contain a matching Identity."')) {     
                    $errorMessage = "[Get-ADSIUser] On line $($_.InvocationInfo.ScriptLineNumber) - We found multiple entries for Identity: '$($Identity)'. Please specify a samAccountName, or something more specific."              
                    $MultipleEntriesFoundException = [System.Exception]::new($errorMessage)
                    throw $MultipleEntriesFoundException
                } else {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }
        }
        elseif ($PSBoundParameters['LDAPFilter'])
        {

            # Directory Entry object
            $DirectoryEntryParams = $ContextSplatting
            $DirectoryEntryParams.remove('ContextType')
            $DirectoryEntry = New-ADSIDirectoryEntry @DirectoryEntryParams

            # Principal Searcher
            $DirectorySearcher = new-object -TypeName System.DirectoryServices.DirectorySearcher
            $DirectorySearcher.SearchRoot = $DirectoryEntry

            $DirectorySearcher.Filter = "(&(objectCategory=user)$LDAPFilter)"
            #$DirectorySearcher.PropertiesToLoad.AddRange("'Enabled','SamAccountName','DistinguishedName','Sid','DistinguishedName'")

            if (-not$PSBoundParameters['NoResultLimit'])
            {
                Write-Warning -Message "Result is limited to 1000 entries, specify a specific number on the parameter SizeLimit or 0 to remove the limit"
            }
            else
            {
                # SizeLimit is useless, even if there is a$Searcher.GetUnderlyingSearcher().sizelimit=$SizeLimit
                # the server limit is kept
                $DirectorySearcher.PageSize = 10000
            }

            $DirectorySearcher.FindAll() | Foreach-Object -Process {
                [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($Context, $_.Properties["distinguishedname"])
            }# Return UserPrincipale object
        }
        else
        {
            Write-Verbose -Message "Searcher"

            $UserPrincipal = New-object -TypeName System.DirectoryServices.AccountManagement.UserPrincipal -ArgumentList $Context
            $Searcher = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalSearcher
            $Searcher.QueryFilter = $UserPrincipal

            if (-not$PSBoundParameters['NoResultLimit'])
            {
                Write-Warning -Message "Result is limited to 1000 entries, specify a specific number on the parameter SizeLimit or 0 to remove the limit"
            }
            else
            {
                # SizeLimit is useless, even if there is a$Searcher.GetUnderlyingSearcher().sizelimit=$SizeLimit
                # the server limit is kept
                $Searcher.GetUnderlyingSearcher().pagesize = 10000

            }
            #$Searcher.GetUnderlyingSearcher().propertiestoload.AddRange("'Enabled','SamAccountName','DistinguishedName','Sid','DistinguishedName'")
            $Searcher.FindAll() # Return UserPrincipale
        }
    }
}