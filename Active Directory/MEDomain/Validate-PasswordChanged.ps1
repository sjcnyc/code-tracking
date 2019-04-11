$QADParams = @{
    PageSize                         = '1000'
    DontUseDefaultIncludedProperties = $true
    IncludedProperties               = @('SamAccountName', 'DisplayName', 'Mail', 'UserPrincipalName', 'Description', 'msDS-UserPasswordExpiryTimeComputed', 'AccountIsDisabled', 'PasswordLastSet', 'PasswordNeverExpires', 'AccountIsLockedOut', 'PasswordExpires', 'PasswordIsExpired', 'DistinguishedName', 'ParentContainer', 'UserMustChangePassword', 'PasswordStatus')
    Service                          = 'me.sonymusic.com'
}

$result = New-Object -TypeName System.Collections.ArrayList

#$users = (Import-Csv '<path_to_csv_file').SamAccountName

# if using csv comment out below $user here string
$users = @"
npatel1
"@ -split [environment]::NewLine

try {

    $users | Get-QADUser @QADParams |

    ForEach-Object {

        $info = [pscustomobject]@{
            'SamAccountName'         = $_.SamAccountName
            'DisplayName'            = $_.DisplayName
            'EmailAddress'           = $_.Mail
            'UserPrincipalName'      = $_.UserPrincipalName
            'DistinguishedName'      = $_.DistinguishedName
            'ParentContainer'        = $_.parentContainer
            'Description'            = $_.Description
            'AccountStatus'          = if ($_.AccountIsDisabled -eq 'TRUE') {'Disabled'} else {'Enabled'}
            'AccountLocked'          = if ($_.AccountIsLockedOut -eq 'TRUE') {'True'} else {'False'}
            'PasswordNeverExpires'   = $_.PasswordNeverExpires
            'PasswordLastSet'        = $_.PasswordLastSet
            'PasswordExpires'        = $_.PasswordExpires
            'PasswordIsExpired'      = if ($_.PasswordIsExpired -eq 'TRUE') {'True'} else {'False'}
            'UserMustChangePassword' = if ($_.UserMustChangePassword -eq 'TRUE') {'TRUE'} else {'False'}
            'PasswordStatus'         = $_.PasswordStatus
        }
        [void]$result.Add($info)
    }
}
catch {

$_.Error
}

$result #| Export-Csv "C:\Temp\PasswordResetVerificationlist_$(Get-Date -Format "MM-dd-yyyy_hh-mm-ss").csv" -NoTypeInformation