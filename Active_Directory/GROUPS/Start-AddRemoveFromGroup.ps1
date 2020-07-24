[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][ValidateSet('User', 'Computer')]$Object,
    [Parameter(Mandatory)][ValidateSet('AddMember', 'RemoveMember')]$Option,
    [Parameter(Mandatory)][string]$Group,
    [Parameter(Mandatory)][string]$SamAccountName,
    [string]$server = 'NYCSMEADS0012'
)

Import-Module -Name ActiveDirectory -Verbose:$false

try {
    if ($Option -eq 'AddMember') {
        if ($Object -eq 'User') {
            Add-ADGroupMember -Server $server -Identity $Group -Members $SamAccountName -Confirm:$false
        }
        else {
            Add-ADGroupMember -Server $server -Identity $group -Members "$($SamAccountName)$" -Confirm:$false
        }
        Write-Output  -InputObject ('Adding user {0} to {1}' -f ($SamAccountName), ($Group))
    }
    elseif ($Option -eq 'RemoveMember') {
        if ($Object -eq 'User') {
            Remove-ADGroupMember -Server $server -Identity $Group -Members $SamAccountName -Confirm:$false
        }
        else {
            Remove-ADGroupMember -Server $server -Identity $Group -Members "$($SamAccountName)$" -Confirm:$false
        }
        Write-Output -InputObject ('Removing user {0} from {1}' -f ($SamAccountName), ($Group))
    }
}
catch {
    Write-Error -Message $Error[0].Exception
}