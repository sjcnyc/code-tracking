#Define some input data.  This can also be from Import-CSV

$Users = @'
sAMAccountName,   DisplayName
"sconnea",        "Connealy, Sean, Peak"
"amoldove",       "Moldoveanu, Alex, Sony Music"
"blynch",         "Lynch, Brian, IS&T"
"klee123",        "Lee, Kim, Sony Music"
'@ -split [environment]::NewLine


#loop $users
$Results =
foreach ($User in $Users | ConvertFrom-Csv) {
  # Get CanonicalName from AD
  $CanonicalName = (Get-ADUser -Filter "sAMAccountName -eq '$($User.sAMAccountName)'" -Properties CanonicalName).CanonicalName
  # Create custom object
  [pscustomobject]@{
    sAMAccountName = $User.sAMAccountName
    DisplayName    = $User.DisplayName
    CanonicalName  = $CanonicalName # Add member "CanonicalName" to the custom object
  }
}

$Results