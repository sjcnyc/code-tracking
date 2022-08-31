Function Get-DirectReport {
    #requires -Module ActiveDirectory
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]

        [string]  $SamAccountName,

        [switch]  $NoRecurse
    )

    BEGIN {}

    PROCESS {
        $UserAccount = Get-ADUser $SamAccountName -Properties DirectReports, DisplayName
        $UserAccount | Select-Object -ExpandProperty DirectReports | ForEach-Object {
            $User = Get-ADUser $_ -Properties DirectReports, DisplayName, Title, EmployeeID
            if (-not $NoRecurse) {
                Get-DirectReport $User.SamAccountName
            }
            [PSCustomObject]@{
                SamAccountName    = $User.SamAccountName
                UserPrincipalName = $User.UserPrincipalName
                DisplayName       = $User.DisplayName
                Manager           = $UserAccount.DisplayName
            }
        }
    }

    END {}

}