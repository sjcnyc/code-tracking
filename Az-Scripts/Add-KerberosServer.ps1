# Specify the on-premises Active Directory domain. A new Azure AD
# Kerberos Server object will be created in this Active Directory domain.
$domain = $env:USERDNSDOMAIN

# Enter an Azure Active Directory global administrator username and password.
$cloudCred = Get-Credential -Message 'An Active Directory user who is a member of the Global Administrators group for Azure AD.'

# Enter a domain administrator username and password.
$domainCred = Get-Credential -Message 'An Active Directory user who is a member of the Domain Admins group.'

# Create the new Azure AD Kerberos Server object in Active Directory
# and then publish it to Azure Active Directory.
Set-AzureADKerberosServer -Domain $domain -CloudCredential $cloudCred -DomainCredential $domainCred