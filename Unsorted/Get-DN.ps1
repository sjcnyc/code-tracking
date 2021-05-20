$CSVFile = Import-Csv 'C:\Temp\Copy of Mailboxes that need BMG account.csv'

$result = New-Object -TypeName System.Collections.ArrayList

foreach ($csv in $CSVFile) {

    $UserDN = (Get-QADUser -Identity $csv.Alias -IncludedProperties SamAccountName, DistinguishedName -Service 'nycmnetads002.mnet.biz').DistinguishedName

    $info = [pscustomobject]@{

        'DisplayName'          = $csv.DisplayName
        'LinkedMasterAccount'  = $csv.LinkedMasterAccount
        'RecipientTypeDetails' = $csv.RecipientTypeDetails
        'PrimarySmtpAddress'   = $csv.PrimarySmtpAddress
        'Alias'                = $csv.Alias
        'AADConnect'           = $csv.AADConnect
        'Send On Behalf'       = $csv.'Send On Behalf'
        'DistinguishedName'    = $UserDN
    }

    $null = $result.Add($info)
}

$result | Export-Csv -Path 'c:\temp\MailboxesThatNeedBMGAccount.csv' -NoTypeInformation