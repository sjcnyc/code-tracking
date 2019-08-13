function Start-UsersGroupOperation {
    param(
        [Parameter(Mandatory)][ValidateSet('AddMember', 'RemoveMember')]$option,
        [Parameter(Mandatory)][string]$group,
        [Parameter(Mandatory)][string]$user,
        [string]$server
    )
    $log = "c:\temp\log.log"
    Add-Type -AssemblyName Microsoft.ActiveDirectory.Management
    try {
        switch ($Option) {
            'AddMember' {
                Add-ADGroupMember -Server $server -Identity $group -Members $user -Confirm:$false -ErrorAction Stop
                Write-ToConsoleAndLog -Output ('Added user {0} to {1}' -f ($user), ($group)) -Log $log -Verbose
            }
            'RemoveMember' {
                Remove-ADGroupMember -Server $server -Identity $group -Members $user -Confirm:$false
                Write-ToConsoleAndLog -Output ('Removed user {0} from {1}' -f ($user), ($group)) -Log $log -Verbose
            }
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADException] {
        [Management.Automation.ErrorRecord]$e = $_

        $info = [PSCustomObject]@{
            Exception = "$($e.Exception.Message) $($e.CategoryInfo.TargetName)"
        }
        Write-ToConsoleAndLog -Output $info.Exception -Log $log -Verbose
    }
    catch {
        $line = $_.InvocationInfo.ScriptLineNumber
        Write-ToConsoleAndLog -Output ('Error was in Line {0}, {1}' -f ($line), $_) -Log $log -Verbose
    }
}

@"
CHAMB01
"@ -split [environment]::NewLine | ForEach-Object {

    Start-UsersGroupOperation -option AddMember -group "FLL-LARO MapX Logon Miami Sharefiles" -user $_
}

#some comments