#  phillip.gee@sonymusic.com => pgee@raymondgubbay.co.uk


function Update-RGUserUpn {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string]$csvFile
    )

    $userMail = Import-Csv -Path $csvFile

    foreach ($user in $userMail) {

        try {
            # verify account from email, return sAMAccountName
            if ($PSCmdlet.ShouldProcess($user.EmailSME, 'Verifying user account in AD')) {
                $newUser = Get-ADUser -Filter "Mail -eq '$($user.EmailSME)'" -props sAMAccountName
                Write-Output "$($user.EmailSME)"
            }
            # sets new UserPrincipalName from csv
            if ($PSCmdlet.ShouldProcess($user.EmailRG, 'Updating UPN')) {
                Get-ADUser $newUser | Set-ADUser -UserPrincipalName "$($user.EmailRG)"
                Write-Output "$($user.EmailRG)"
            }
        } catch {
            $Error.message
        }
    }
}