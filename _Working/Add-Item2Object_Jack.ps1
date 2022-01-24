$Results = foreach ($User in (Import-Csv "D:\temp\unknown.csv")) {

  $Companyname = (Get-ADUser -Filter "sAMAccountName -eq '$($User.MailNickName)'" -Properties Company).Company

  [pscustomobject]@{
    UserPrincipalName            = $User.UserPrincipalName
    DisplayName                  = $User.DisplayName
    CompanyName                  = $Companyname
    Mail                         = $User.Mail
    Country                      = $User.Country
    City                         = $User.City
    Department                   = $User.Department
    UsageLocation                = $User.UsageLocation
    JobTitle                     = $User.JobTitle
    Mail2                        = $User.Mail2
    MailNickName                 = $User.MailNickName
    Mobile                       = $User.Mobile
    GivenName                    = $User.GivenName
    Surname                      = $User.Surname
    PhysicalDeliveryOfficeName   = $User.PhysicalDeliveryOfficeName
    StreetAddress                = $User.StreetAddress
    State                        = $User.State
    PostalCode                   = $User.PostalCode
    TelephoneNumber              = $User.TelephoneNumber
    FacsimileTelephoneNumber     = $User.FacsimileTelephoneNumber
    AccountEnabled               = $User.AccountEnabled
    ObjectId                     = $User.ObjectId
    ObjectType                   = $User.ObjectType
    OnPremisesSecurityIdentifier = $User.OnPremisesSecurityIdentifier
  }
}
$Results | Export-Csv -Path "D:\Temp\companyName.csv" -NoTypeInformation