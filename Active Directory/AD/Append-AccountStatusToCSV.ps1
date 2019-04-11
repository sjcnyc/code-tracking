$csv = Import-Csv -Path "C:\temp\MNETLinkedMasterAccount_02012017_Afternoon_AdditionalInfo.csv"

$result = New-Object System.Collections.ArrayList

foreach ($entry in $csv) {
    $accountStat = Get-QADUser -Service 'NYCSMEADS0012:389' -Identity $entry.Alias |
        Select-Object -Property AccountIsDisabled, @{
        N = 'accountStatus'
        E = {
            if ($_.AccountIsDisabled -eq 'TRUE') {
                'Disabled'
            }
            else {
                'Enabled'
            }
        }
    }

    $info = [pscustomobject]@{
        'DistinguishedName'           = $entry.DistinguishedName
        'AD OrganizationalUnit'       = $entry."AD OrganizationalUnit"
        'Exchange OrganizationalUnit' = $entry."Exchange OrganizationalUnit"
        'Identity'                    = $entry.Identity
        'Alias'                       = $entry.Alias
        'UserPrincipalName'           = $entry.UserPrincipalName
        'PrimarySmtpAddress'          = $entry.PrimarySmtpAddress
        'LinkedMasterAccount'         = $entry.LinkedMasterAccount
        'Country Code'                = $entry."Country Code"
        'Country'                     = $entry.Country
        'RecipientType'               = $entry.RecipientType
        'RecipientTypeDetails'        = $entry.RecipientTypeDetails
        'AccountStatus'               = $accountStat.accountstatus
    }

    $null = $result.Add($info)

    $result | Export-Csv -Path "C:\temp\mnetmaster7.csv" -NoTypeInformation -Append
    $result.Clear()
}