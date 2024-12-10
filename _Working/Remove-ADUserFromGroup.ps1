$users = @"
KLIN090

"@ -split [System.Environment]::NewLine

function Remove-UsersFromADGroup {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupName,

        [Parameter(Mandatory = $true)]
        [string[]]$UserNames
    )

    Import-Module ActiveDirectory

    foreach ($userName in $UserNames) {
        try {
            Remove-ADGroupMember -Identity $GroupName -Members $userName -Confirm:$false -ErrorAction Stop
            Write-Host "Successfully removed $userName from group $GroupName"
        } catch {
            Write-Host "Failed to remove $userName from group $GroupName $_"
        }
    }
}

foreach ($user in $users) {
    Remove-UsersFromADGroup -GroupName "AZ_AVD_GSA_FullDesktop" -UserNames $user
}
