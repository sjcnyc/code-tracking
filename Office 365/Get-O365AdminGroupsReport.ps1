function Get-O365AdminGroupsReport {
    [CmdletBinding()]
    param (
        [Parameter( Mandatory = $false )]
        [ValidatePattern('.csv$')]
        [string]$ReportFile = "Office365AdminGroupMembers.csv",

        [Parameter( Mandatory = $false )]
        [switch]$Overwrite
    )

    $O365AdminGroupReport = New-Object System.Collections.ArrayList
    $now = Get-Date
    $ShortDate = $now.ToShortDateString() -replace "/", ""

    $ReportFileSplit = $ReportFile.Split(".")
    $OutputFileNamePrefix = $ReportFileSplit[0..($ReportFileSplit.length - 2)]
    $OutputFileName = "$($OutputFileNamePrefix)-$($ShortDate).$($ReportFileSplit[-1])"

    Write-Verbose "Retrieving Azure AD admin roles"
    try {
        $AzureADRoles = @(Get-AzureADDirectoryRole -ErrorAction Stop)
    }
    catch {
        if ($_.Exception.Message -ieq "You must call the Connect-AzureAD cmdlet before calling any other cmdlets.") {
            try {
                $AzureADRoles = @(Get-AzureADDirectoryRole -ErrorAction Stop)
            }
            catch {
                throw $_.Exception.Message
            }
        }
        else {
            throw $_.Exception.Message
        }
    }

    foreach ($AzureADRole in $AzureADRoles) {

        Write-Verbose "Processing $($AzureADRole.DisplayName)"

        $RoleMembers = @(Get-AzureADDirectoryRoleMember -ObjectId $AzureADRole.ObjectId)

        foreach ($RoleMember in $RoleMembers) {
            $ObjectProperties = [pscustomobject]@{
                "Role"                = $AzureADRole.DisplayName
                "Display Name"        = $RoleMember.DisplayName
                "Object Type"         = $RoleMember.ObjectType
                "Account Enabled"     = $RoleMember.AccountEnabled
                "User Principal Name" = $RoleMember.UserPrincipalName
                "Password Policies"   = $RoleMember.PasswordPolicies
                "HomePage"            = $RoleMember.HomePage
            }

           # $RoleMemberObject = New-Object -TypeName PSObject -Property $ObjectProperties

            [void]$O365AdminGroupReport.Add($ObjectProperties)
        }
    }

    Write-Verbose "Outputting report"

    if (Test-Path -Path $OutputFileName) {
        if (-not $Overwrite) {
            $RandomString = -join (48..57 + 65..90 + 97..122 | ForEach-Object {[char]$_} | Get-Random -Count 4)
            $OutputFileNameSplit = $OutputFileName.Split(".")
            $OutputFileNamePrefix = $OutputFileNameSplit[0..($OutputFileNameSplit.length - 2)]
            $OutputFileName = "$($OutputFileNamePrefix)-$($RandomString).$($OutputFileNameSplit[-1])"
            Write-Verbose "A file with the desired name already exists. New file name will be $($OutputFileName)"
        }
    }

    if ($Overwrite) {
        $O365AdminGroupReport | Export-CSV -Path $OutputFileName -Force -NoTypeInformation
    }
    else {
        $O365AdminGroupReport | Export-CSV -Path $OutputFileName -NoClobber -NoTypeInformation
    }
}