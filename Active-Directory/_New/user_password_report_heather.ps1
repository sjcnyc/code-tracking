<# Get-ADUser -Filter {
    PasswordNeverExpires -eq $true
} -Properties msDS-UserPasswordExpiryTimeComputed |
    Select-Object -Property 'SamAccountName', @{
    Name       = 'MustChangePass'
    Expression = {
        if ($_.'msDS-UserPasswordExpiryTimeComputed' -eq 0) {
            'True'
        }
        else {
            'False'
        }
    }
}, @{Name      = 'PassNotRequired'
    Expression = {
        if (Get-ADUser -LDAPFilter "(&(userAccountControl:1.2.840.113556.1.4.803:=32)(!(IsCriticalSystemObject=TRUE)))") {'False'} else {'True'}
    }
} #>





Get-ADUser -Server "me.sonymusic.com" -SearchBase "OU=RIO,OU=BRA,OU=LA,OU=Provision,OU=STG,OU=Tier-0,DC=me,DC=sonymusic,DC=com" -Properties GivenName, Surname, Samaccountname, DistinguishedName, PasswordNeverExpires, PasswordNotRequired, Enabled, PasswordLastSet, PasswordExpired -Filter * |
    Select-Object GivenName, Surname, SamAccountName, DistinguishedName, PasswordNeverExpires, PasswordNotRequired, @{N = 'AccountStatus'; E = {if ($_.Enabled -eq 'True') {'Enabled'}else {'Disabled'}}}, PasswordLastSet, PasswordExpired |
    Export-Csv C:\Temp\passNotRQ_103117_002240.csv -NoTypeInformation

Get-ADUser -Server "me.sonymusic.com" -Properties GivenName, Surname, Samaccountname, DistinguishedName, PasswordNeverExpires, Enabled, PasswordLastSet, PasswordExpired -Filter *  |
    Select-Object GivenName, Surname, SamAccountName, DistinguishedName, PasswordNeverExpires, @{N = 'AccountStatus'; E = {if ($_.Enabled -eq 'True') {'Enabled'}else {'Disabled'}}}, PasswordLastSet, PasswordExpired |
    Export-Csv C:\Temp\PassNeverExpires.csv -NoTypeInformation

<# (Get-ADUser -Filter 'useraccountcontrol -band 32' -Properties useraccountcontrol).count

(Get-ADUser -filter {PasswordNotRequired -eq $true}).count

(Get-ADUser -Filter 'useraccountcontrol -band 65536' -Properties useraccountcontrol).count

(Get-ADUser -filter {PasswordNeverExpires -eq $true}).count


<# pass #> #>

#$users = get-aduser -LDAPfilter "(&(objectCategory=person)(objectClass=user)(!userAccountControl:1.2.840.113556.1.4.803:=2048)(userAccountControl:1.2.840.113556.1.4.803:=32))" -properties useraccountcontrol -SearchScope Subtree

# (&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=32))

Get-QADUser

$usersWithNoPwdRequired = Get-ADUser -Identity 'kwahs01' #-LDAPFilter "(&(objectClass=user)(objectCategory=person)(userAccountControl:1.2.840.113556.1.4.803:=544))"
foreach ($user in $usersWithNoPwdRequired ) {
    Set-ADAccountControl $user -PasswordNotRequired $false
}