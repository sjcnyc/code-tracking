@"
mcolter
FASU001
"@ -split [environment]::NewLine | ForEach-Object {

    $BMGUser = Get-QADUser $_ -Service 'me.sonymusic.com' | Select-Object FirstName, LastName, Email, SamAccountName

    $PSObj = [pscustomobject]@{
        SourceID       = $_
        FirstName      = $BMGUser.FirstName
        LastName       = $BMGUser.LastName
        Email          = $BMGUser.Email
        SamAccountName = $BMGuser.SamAccountName
    }

    $PSObj | Export-Csv c:\temp\me_users.csv -NoTypeInformation -Append
}