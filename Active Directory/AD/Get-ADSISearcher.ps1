$root = [ADSI]''
$search = [adsisearcher]$root
$search.Filter = '(&(objectclass=user)(objectcategory=user)(useraccountcontrol:1.2.840.113556.1.4.803:=2))'
$search.SizeLimit = 3000
$results = $search.FindAll() | Where-Object path -match 'LARO'

foreach ($result in $results) {
    $result.Properties |
        Select-Object -Property @{N = 'Name'; E = {$_.name}}, @{N = 'DistinguishedName'; E = {$_.distinguishedname}}
}



# Retrieve DN of local computer.
$SysInfo = New-Object -ComObject "ADSystemInfo"
$ComputerDN = $SysInfo.GetType().InvokeMember("NYCMNETADS001", "GetProperty", $Null, $SysInfo, $Null)

# Bind to computer object in AD.
$Computer = [ADSI]"LDAP://$ComputerDN"

# Specify target OU.
$TargetOU = "ou=Computers,ou=West,dc=MyDomain,dc=com"

# Bind to target OU.
$OU = [ADSI]"LDAP://$TargetOU"

# Move computer to target OU.
$Computer.psbase.MoveTo($OU)