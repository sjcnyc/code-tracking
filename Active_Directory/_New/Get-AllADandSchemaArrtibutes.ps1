# Import the Active Directory module:
Import-Module ActiveDirectory

# Now, obtain a reference to the assembly itself:
$ADAssembly = [Microsoft.ActiveDirectory.Management.ADEntity].Assembly

# Now we'll need to retrieve the internal class that defines the constants:
$LDAPAttributes = $ADAssembly.GetType('Microsoft.ActiveDirectory.Management.Commands.LdapAttributes')

# Then use GetFields() to retrieve the internal constants
$LDAPNameConstants = $LDAPAttributes.GetFields('Static,NonPublic') | Where-Object { $_.IsLiteral }

# Finally build a hashtable with the Property Names -> LDAP Name mapping
$LDAPPropertyMap = @{ }
$LDAPNameConstants | ForEach-Object {
  $LDAPPropertyMap[$_.Name] = $_.GetRawConstantValue()
}

