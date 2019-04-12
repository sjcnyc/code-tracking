Connect-Okta -Token "00jCWv0g5qQK98CQN_zG9tlwvyMyFCpFBE8t5UCzNb" -FullDomain "https://sonymusic.okta.com"

$users = Get-OktaUser

$Collection = New-Object 'System.Collections.Generic.List[string]'

foreach ($user in $users) {

    $factorInfo = oktaGetFactorsbyUser -oOrg prod -username $user.profile.login

    $result = [PSCustomObject]@{

        'Logon'             = $user.Profile.Login
        'FirstName'         = $user.Profile.FirstName
        'LastName'          = $user.Profile.LastName
        'Email'             = $user.Profile.Email
        'OktaID'            = $user.Id
        'StatusChanged'     = $user.StatusChanged
        'Activated'         = $user.Activated
        'Created'           = $user.Created.Date
        'Status'            = $user.Status
        'LastLogon'         = $user.LastLogin.Date
        'LastUpdated'       = $user.LastUpdated
        'PasswordChanged'   = $user.PasswordChanged
        '_Links'            = ($user._links | Out-String).Trim()
        'Credentials'       = $user.credentials
        'SamAccountName'    = ($user.profile).SamAccountName
        'FactorID'          = $factorInfo.ID
        'FactorType'        = $factorInfo.factorType
        'FactorProvider'    = $factorInfo.Provider
        'FactorStatus'      = $factorInfo.Status
        'FactorCreated'     = $factorInfo.Created
        'FactorLastUpdated' = $factorInfo.LastUpdated
    }

    [void]$collection.Add($obj)
}

$Collection #| Export-Csv 'C:\Temp\oktaMFATest.csv' -NoTypeInformation