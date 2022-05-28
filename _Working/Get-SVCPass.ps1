function Get-SVCPass {
    $Manager = (Get-ADUser sconnea -Properties DistinguishedName).DistinguishedName

    $getADUserSplat = @{
        Filter     = { Manager -eq $Manager }
        Properties = 'sAMAccountName', 'PasswordExpired', 'Description'
    }

    Get-ADUser @getADUserSplat | Select-Object sAMAccountName, PasswordExpired, Description | Sort-Object PasswordExpired
}