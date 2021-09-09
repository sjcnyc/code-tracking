$VpnGroups = @'
GlobalProtectVPN-NorthAmericaUsers
GlobalProtectVPN-LatinUsers
GlobalProtectVPN-EuropeanUsers
GlobalProtectVPN-AsiaPacificUsers
'@ -split [environment]::NewLine

$ADUserParameters = @{
    Name                  = '{0} {1}' -f $User.Firstname, $User.Lastname
    DisplayName           = '{0} {1}' -f $User.Firstname, $User.Lastname
    GivenName             = $User.Firstname
    Surname               = $User.Lastname
    DN                    = $User.OU
    SamAccountName        = $User.SAM
    UserPrincipalName     = '{0}.{1}@{2}' -f $User.Firstname, $User.Lastname, $User.'sonymusic.com'
    Description           = $User.Description
    AccountPassword       = ConvertTo-SecureString $User.Password -AsPlainText -Force
    Enabled               = $true
    ChangePasswordAtLogon = $true
    PasswordNeverExpires  = $false
    Server                = 'me.sonymusic.com'
}
New-ADUser @ADUserParameters



if (Get-ADUser $ADUserParameters.SamAccountName) {

    Set-ADAccountExpiration -Identity $ADUserParameters.SamAccountName -DateTime 'timespan' -ErrorAction 0

    $Proxys = @()
    if ($null -ne $Proxys) {
        foreach ($Proxy in $Proxys) {
            Set-ADUser $User -Add @{ proxyAddresses = $Proxy } -ErrorAction 0
        }
    }

    Set-ADUser $User -Add @{ mailNickname = $mailNickname } -ErrorAction 0


    foreach ($VpnGroup in $VpnGroups) {
        Get-ADGroup -Identity $VpnGroup | Add-ADGroupMember -Members $ADUserParameters.SamAccountName
    }
}



$paramNewADUser = @{
    Name                  = ($textboxDisplayName.Text)
    GivenName             = ($textboxFirstName.Text)
    Surname               = ($textboxLastName.Text)
    Initials              = ($textboxInitials.Text)
    DisplayName           = ($textboxDisplayName.Text)
    SamAccountName        = ($textboxSamAccount.Text)
    UserPrincipalName     = (($textboxUserLogonName.Text) + ($comboboxDomains.SelectedItem))
    EmailAddress          = (($textboxUserLogonName.Text) + ($comboboxDomains.SelectedItem))
    Description           = ($textboxDescription.Text)
    Office                = ($textboxoffice.Text)
    OfficePhone           = ($textboxTelephone.Text)
    HomePage              = ($textboxWebPage.Text)
    StreetAddress         = ($textboxStreet.Text)
    State                 = ($textboxstate.Text)
    #Country               = ($textboxCountryC.Text)
    PostalCode            = ($textboxzipcode.Text)
    City                  = ($textboxcity.Text)
    Title                 = ($textboxjobtitle.Text)
    Department            = ($textboxDepartment.Text)
    Company               = ($textboxCompany.Text)
    POBox                 = ($textboxPOBox.Text)
    ProfilePath           = ($textboxprofilepath.Text)
    ScriptPath            = ($textboxlogonscript.Text)
    PasswordNeverExpires  = ($checkboxPasswordNeverExpires.Checked)
    CannotChangePassword  = ($checkboxUserCannotChangePass.checked)
    ChangePasswordAtLogon = ($checkboxUserMustChangePasswo.Checked)
    AccountPassword       = $PasswordSecureString
    HomeDrive             = ($comboboxDriveLetter.SelectedItem)
    HomeDirectory         = ($textboxhomedirectory.Text)
    Path                  = "$SelectedOU"
    Enabled               = $AccountStatus
    OtherAttributes       = @{
        'c' = $textboxCountryC.Text; 'co' = $textboxCountryCO.Text
    }
    ErrorAction           = 'Stop'
}