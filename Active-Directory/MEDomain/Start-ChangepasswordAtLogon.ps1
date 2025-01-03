function Get-RandomPassword {
    param(
        $length = 15,
        $characters = 'abcdefghkmnprstuvwxyzABCDEFGHKLMNPRSTUVWXYZ123456789!@#$%^&*()_-+=[{]};:<>|./?.'
    )
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs = ""
    [String]$characters[$random]
}

#region change password at logon
function Start-ChangepasswordAtLogon {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [string]$username,
        [System.Management.Automation.CredentialAttribute()] [SecureString] $credential
    )
    try {
        if (Get-ADUser -Identity $username -Credential $credential) {
            $password = Get-RandomPassword | ConvertTo-SecureString -AsPlainText -Force
            Set-ADAccountPassword $username -NewPassword $password -Reset -PassThru -Credential $credential |
                Set-ADUser -PasswordNeverExpires:$false -ChangePasswordAtLogon:$false -Credential $credential

            $object = [PSCustomObject]@{
                SamAccountName = $username
                Password       = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
            }
            # keeps list of user, and random password
            $object | Export-Csv "c:\temp\resetUsers$(Get-Date -Format "MM-dd-yyyy_hh-mm-ss").csv" -NoTypeInformation -Append
        }
    }
    catch {
        $line = $_.InvocationInfo.ScriptLineNumber
        ('Error was in Line {0}, {1}' -f ($line), $_)
    }
}
#endregion

# use credential that has right to change password in tier-2
$cred = (Get-Credential -UserName 'me\admsconnea-2' -Message 'Cred')

# csv with samaccountname
$#users = (Import-Csv '<path_to_Csv_file>').SamAccountName

# or hash of samaccount/upn names
$users =
@"
jcolson
CRUZ013
"@

# process user array
$users | ForEach-Object -Process {

    Start-ChangepasswordAtLogon -username $_ -credential $cred
}