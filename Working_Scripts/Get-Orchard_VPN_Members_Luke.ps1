using namespace System.Collections.Generic

# Ignore Errors in this case
$ErrorActionPreference = "silentlycontinue"

# Import csv into $Users object variable
$Users = Import-Csv 'D:\Temp\Orchard users.csv'

# $Result List holds all our new data
$Results = [List[PSObject]]::new()

# Loop through each record in $Users object
foreach ($User in $Users) {
  $VPNaccess = $null

  # Get a list of user group memberhips and store in $VPNAccess variable
  $VPNaccess = (Get-ADUser -Filter "sAMAccountName -eq '$($User.Alias)'" -Properties MemberOf).MemberOf

  # These are all the headers in original csv file + vpnaccess
  # Csv header names must be unique
  $CsvObject = [pscustomobject]@{
    DisplayName                = $User.DisplayName
    Alias                      = $User.Alias
    RecipientTypeDetails       = $User.RecipientTypeDetails
    PrimarySmtpAddress         = $User.PrimarySmtpAddress
    UserPrincipalName          = $User.UserPrincipalName
    IsDirSynced                = $User.IsDirSynced
    WhenMailboxCreate          = $User.WhenMailboxCreate
    WhenCreated                = $User.WhenCreated
    UsageLocation              = $User.UsageLocation
    ForwardingSmtpAddress1     = $User.ForwardingSmtpAddress1
    DeliverToMailboxAndForward = $User.PhysicalDeliveryOfficeName
    Orchard                    = $User.Orchard
    ForwardingSmtpAddress2     = $User.ForwardingSmtpAddress2
    Guest                      = $User.Guest
    Licensed                   = $User.Licensed
    Shared                     = $User.Shared
    Disable                    = $User.Disable
    vpnaccess                  = if ($VPNaccess -match "GlobalProtectVPN-") { "true" } else { "false" }
    # ^^ If user is member of GlobalProtectVPN-* set vpnaccess to true, else false
  }
  # all $CsvObject to $Results list
  [void]$Results.Add($CsvObject)
}

# Export $Result List to csv
$Results | Export-Csv 'D:\Temp\Orchard_users_vpnaccess.csv' -NoTypeInformation