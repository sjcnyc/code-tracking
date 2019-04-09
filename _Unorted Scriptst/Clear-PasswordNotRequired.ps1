$users =@"
admgtlaob
admmucasy
gsony18
germa39
"@ -split [environment]::NewLine | ForEach-Object {

  #Set-ADUser $_ -PasswordNeverExpires:$false -ChangePasswordAtLogon:$true
  


  get-qaduser $_  -IncludeAllProperties | Select-Object @{N="SamAccountName"; E= {$_}},userAccountControl, PasswordLastSet, PasswordExpires, PasswordAge, AccountIsDisabled, AccountIsLockedOut, PasswordNeverExpires, UserMustChangePassword, AccountIsExpired, PasswordIsExpired, AccountExpirationStatus | Export-Csv c:\temp\disabled_users_password_Report32.csv -NoTypeInformation -Append 
}
function Get-RandomPassword {
    param(
        $length = 15,
        $characters = 'abcdefghkmnprstuvwxyzABCDEFGHKLMNPRSTUVWXYZ123456789!@#$%^&*()_-+=[{]};:<>|./?.'
    )
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs = ""
    [String]$characters[$random]
}

function Start-ChangepasswordAtLogon {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [string]$username,
        [System.Management.Automation.CredentialAttribute()] [SecureString] $credential
    )
    try {
        if (Get-ADUser -Identity $username ) {
            $password = Get-RandomPassword | ConvertTo-SecureString -AsPlainText -Force
            Set-ADAccountPassword $username -NewPassword $password -Reset -PassThru #| Set-ADUser -PasswordNeverExpires:$false -ChangePasswordAtLogon:$true

            $object = [PSCustomObject]@{
                SamAccountName = $username
                Password       = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
            }
            $object | Export-Csv 'c:\temp\resetUsers4.csv' -NoTypeInformation -Append
        }
    }
    catch {
        $line = $_.InvocationInfo.ScriptLineNumber
        ('Error was in Line {0}, {1}' -f ($line), $_)
    }
}

#$cred = (Get-Credential -UserName 'bmg\admsconnea' -Message 'Cred')

foreach ($user in $users ) {
    #Set-ADAccountControl $user -PasswordNotRequired $false
    Start-ChangepasswordAtLogon -username $user
}
