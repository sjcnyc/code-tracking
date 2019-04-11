function Get-UserPasswordInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Group', 'User')]$query,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    try {
        Add-PSSnapin -Name Quest.ActiveRoles.ADManagement

        $Props = @{

            'Properties' = @('Name', 'SamAccountName', 'PasswordLastSet', 'msDS-UserPasswordExpiryTimeComputed')
        }

        $array = New-Object -TypeName System.Collections.ArrayList

        if ($query -eq 'Group') {
            $results = Get-ADGroupMember -Identity $Name -Recursive | 
                Get-ADUser @Props |
                Select-Object 'Name', 'SamAccountName', 'PasswordLastSet', @{
                Name       = 'PasswordExpires'
                Expression = {
                    [datetime]::FromFileTime($_.'msDS-UserPasswordExpiryTimeComputed')
                }
            }
        }
        elseif ($query -eq 'User') {
            $results = Get-ADUser -Identity $Name @Props |
                Select-Object 'Name', 'SamAccountName', 'PasswordLastSet', @{
                Name       = 'PasswordExpires'
                Expression = {
                    [datetime]::FromFileTime($_.'msDS-UserPasswordExpiryTimeComputed')
                }
            }
        }
        foreach ($result in $results) {
            $info = [pscustomobject]@{
                'Name'            = $result.Name
                'SamAccountName'  = $result.SamAccountName
                'PasswordLastSet' = $result.PasswordLastSet
                'PasswordExpires' = $result.PasswordExpires
            }
            $null = $array.Add($info)
        }
        $array
    }
    catch {
        "Error: $_"
    }
}

@"
LEE0002
DEWE012
TOBI017
dmarmo
BILL004
jdunca1
"@ -split [environment]::NewLine | ForEach-Object {
    get-userpasswordinfo -query user -name $_
}
