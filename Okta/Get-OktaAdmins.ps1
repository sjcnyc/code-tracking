Import-Module -Name Okta.Core.Automation
Import-Module Okta
try {

  Connect-Okta "00chPAuehUa8QFafEyPSQyUXm76lH4dSv1Z-zACcud" "https://sonymusic.okta.com"

$result = New-Object -TypeName System.Collections.ArrayList

$adminGroup = Get-OktaGroupMember "Admins"

    Foreach ($user in $adminGroup) {

        $info = [pscustomobject]@{

            Email           = $username.Profile.Login
            FirstName       = $userName.Profile.FirstName
            LastName        = $userName.Profile.LastName
            Status          = $user.status
            Created         = $user.created
            Activated       = $user.activated
            StatusChanged   = $user.statusChanged
            LastLogin       = $user.lastLogin
            LastUpdated     = $user.LastUpdated
            PasswordChanged = $user.PasswordChanged
            ID              = $user.ID
        }

        $null = $result.Add($info)
    }
    $result
}
catch {
    [Management.Automation.ErrorRecord]$e = $_

    $er = [PSCustomObject]@{ Exception = $e.Exception.Message }
$er
}