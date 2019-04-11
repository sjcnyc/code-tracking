#requires -Version 3.0
#requires -PSSnapin Quest.ActiveRoles.ADManagement

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet('Group', 'User')]$query,
    [Parameter(Mandatory = $true)]
    [string]$name
)

try {
    Add-PSSnapin -Name Quest.ActiveRoles.ADManagement 

    $array = New-Object -TypeName System.Collections.ArrayList

    if ($query -eq 'Group') {
        $results = Get-QADGroupMember -Identity $name |
            Get-QADUser | Select-Object -Property Name, PasswordLastSet
    }
    elseif ($query -eq 'User') {
        $results = Get-QADUser -Identity $name | Select-Object -Property Name, PasswordLastSet
    }
    foreach ($result in $results) {
        $info = [pscustomobject]@{
            'Username'       = $result.name
            'PasswordLasSet' = $result.passwordlastset
        }
        $null = $array.Add($info)
    }
    $array
}
catch {
    "Error: $_"
}