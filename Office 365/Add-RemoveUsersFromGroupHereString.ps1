[CmdletBinding(SupportsShouldProcess)]
Param()

Import-Module -Name ActiveDirectory -Verbose:$false

function Start-UsersGroupOperation {
    param(
        [Parameter(Mandatory)][ValidateSet('AddMember', 'RemoveMember')]$option,
        [Parameter(Mandatory)][string]$group,
        [Parameter(Mandatory)][string]$user,
        [string]$server = 'NYCSMEADS0012'
    )
    Add-Type -AssemblyName Microsoft.ActiveDirectory.Management
    try {
        if ($option -eq 'AddMember') {
            Add-ADGroupMember -Server $server -Identity $group -Members $user -Confirm:$false -ErrorAction Stop
            Write-Output -InputObject ('Adding user {0} to {1}' -f ($user), ($group))
        }
        elseif ($option -eq 'RemoveMember') {
            Remove-ADGroupMember -Server $server -Identity $group -Members $user -Confirm:$false
            Write-Output -InputObject ('Removing user {0} from {1}' -f ($user), ($group))
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADException] {
        [Management.Automation.ErrorRecord]$e = $_

        $info = [PSCustomObject]@{
            Exception = "$($e.Exception.Message) $($e.CategoryInfo.TargetName)"
        }
        Write-Output -InputObject $info.Exception
    }
    catch {
        $line = $_.InvocationInfo.ScriptLineNumber
        Write-Output -InputObject ('Error was in Line {0}, {1}' -f ($line), $_)
    }
}

$server        = 'GTLSMEADS0012'
$addGroup      = 'WWI-O365-MigratedUsers'
$removeGroup   = 'WWI-O365-LinkSwapEnabled'

# Will process SamAccountNames inside Here string
@'

'@ -split [environment]::NewLine |

ForEach-Object -Process {

    Start-UsersGroupOperation -option AddMember -group $addGroup -user $_ -server $server
    Start-UsersGroupOperation -option RemoveMember -group $removeGroup -user $_ -server $server
 }