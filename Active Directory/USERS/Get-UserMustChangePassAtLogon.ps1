$result = New-Object -TypeName System.Collections.ArrayList
$QADParams = @{
    SizeLimit = '0'
    PageSize = '2000'
    DontUseDefaultIncludedProperties = $true
    IncludedProperties = @('SamAccountName', 'DisplayName', 'EmailAddress', 'msDS-UserPasswordExpiryTimeComputed', 'AccountIsDisabled', 'PasswordLastSet', 'PasswordNeverExpires')
    Service = 'NYCSMEADS0012:389'
} 
 
Get-QADUser @QADParams | 
    Select-Object  $QADParams.IncludedProperties |
    ForEach-Object  -Process {

    $info = [pscustomobject]@{
        'SamAccountName'       = $_.SamAccountName
        'DisplayName'          = $_.DisplayName
        'EmailAddress'         = $_.EmailAddress
        'AccountStatus'        = if ($_.AccountIsDisabled -eq 'TRUE') {'Disabled'} else {'Enabled'}
        'MustChangePass'       = if ($_.'msDS-UserPasswordExpiryTimeComputed' -eq 0) {'True'} else {'False'}
        'PasswordNeverExpires' = $_.PasswordNeverExpires
        'PasswordLastSet'      = $_.PasswordLastSet
    }
    $null = $result.Add($info)
}

$result | Export-Csv C:\Temp\userMustChangePass_BMG_005.csv -NoTypeInformation