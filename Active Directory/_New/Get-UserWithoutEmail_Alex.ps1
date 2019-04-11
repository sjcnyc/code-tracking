@"
artes03
"@ -split [environment]::NewLine | ForEach-Object {

    $user = Get-QADUser -Service 'mnet.biz' $_ -IncludeAllProperties | Select-Object Name, Mail, ParentContainer, AccountIsDisabled

    $PSobj                = [pscustomobject]@{
        SamAccountName    = $_
        Name              = $user.Name
        Mail              = $user.Mail
        ParentContainer   = $user.ParentContainer
        AccountIsDisabled = $user.AccountIsDisabled
    }
    $PSobj | Export-Csv c:\temp\users_without_email_2.csv -NoTypeInformation -Append
}