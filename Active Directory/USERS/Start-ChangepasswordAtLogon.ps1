function Start-ChangepasswordAtLogon {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [string]$username
    )

    try {
        if (Get-ADUser -Identity $username) {
            Set-ADUser -Identity $username -ChangePasswordAtLogon:$true
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADException] {
        [Management.Automation.ErrorRecord]$e = $_

        $info = [PSCustomObject]@{
            Exception = "$($e.Exception.Message) $($e.CategoryInfo.TargetName)"
        }
        Write-Output -InputObject $info.Exception
    }
}