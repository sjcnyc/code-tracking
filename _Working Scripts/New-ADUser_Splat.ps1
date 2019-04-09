$ADUserParameters = @{
    Name                  = "{0} {1}" -f $User.Firstname, $User.Lastname
    DisplayName           = "{0} {1}" -f $User.Firstname, $User.Lastname
    GivenName             = $User.Firstname
    Surname               = $User.Lastname
    DN                    = $User.OU
    SamAccountName        = $User.SAM
    UserPrincipalName     = "{0}.{1}@{2}" -f $User.Firstname, $User.Lastname, $User.'me.sonymusic.com'
    Description           = $User.Description
    AccountPassword       = ConvertTo-SecureString $User.Password -AsPlainText -Force
    Enabled               = $true
    ChangePasswordAtLogon = $true
    PasswordNeverExpires  = $false
    Server                = 'me.sonymusic.com'
}
New-ADUser @ADUserParameters