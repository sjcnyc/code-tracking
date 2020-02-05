#requires -Version 3.0 -Modules MSOnline
#requires -PSSnapin Quest.ActiveRoles.ADManagement

$QADParams = @{
    PageSize                         = '1000'
    DontUseDefaultIncludedProperties = $true
    IncludedProperties               = @('SamAccountName', 'DisplayName', 'Mail', 'UserPrincipalName', 'Description', 'msDS-UserPasswordExpiryTimeComputed', 'AccountIsDisabled', 'PasswordLastSet', 'PasswordNeverExpires', 'AccountIsLockedOut', 'PasswordExpires', 'PasswordIsExpired', 'PasswordStatus', 'DistinguishedName', 'ParentContainer')
    Service                          = 'NYCSMEADS0012:389'
}

$result = New-Object -TypeName System.Collections.ArrayList

# $_.isLicensed -eq $true for MSOL, $false for NOT MSOL
 ((Get-MsolUser -All | Where-Object {$_.isLicensed -eq $true}).UserPrincipalName |
   Get-QADUser -Service 'me.sonymusic.com' -DontUseDefaultIncludedProperties -IncludedProperties SamAccountName).SamAccountName | Get-QADUser @QADParams |

ForEach-Object {

    $info = [pscustomobject]@{
        'SamAccountName'       = $_.SamAccountName
        'DisplayName'          = $_.DisplayName
      #  'EmailAddress'         = $_.Mail
        'UserPrincipalName'    = $_.UserPrincipalName
        'DistinguishedName'    = $_.DistinguishedName
        'ParentContainer'      = $_.parentContainer
        'Description'          = $_.Description
        'AccountStatus'        = if ($_.AccountIsDisabled -eq 'TRUE') {'Disabled'} else {'Enabled'}
        'AccountLocked'        = if ($_.AccountIsLockedOut -eq 'TRUE') {'True'} else {'False'}
        'MustChangePass'       = $_.'msDS-UserPasswordExpiryTimeComputed'
        'PasswordLastSet'      = $_.PasswordLastSet
        'PasswordExpires'      = $_.PasswordExpires
        'PasswordIsExpired'    = $_.PasswordIsExpired
        'PasswordNeverExpires' = if ($_.PasswordNeverExpires -eq 'Ttrue') {'True'} else {'False'}
        'PasswordStatus'       = $_.PasswordStatus

    }
    [void]$result.Add($info)
}

$result | Export-Csv 'C:\Temp\Global_MSOLPasswordReport_20170905-1030.csv' -NoTypeInformation
$result.Clear()
[GC]::Collect()