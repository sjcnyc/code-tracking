function Get-SVCPass {
    $Manager = (Get-ADUser sconnea -Properties DistinguishedName).DistinguishedName

    $getADUserSplat = @{
        Filter     = { Manager -eq $Manager }
        Properties = 'sAMAccountName', 'PasswordExpired', 'PasswordNeverExpires', 'msDS-UserPasswordExpiryTimeComputed'
    }

    $selectObjectSplat = @{
        Property = 'sAMAccountName', 'PasswordExpired', 'PasswordNeverExpires', @{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
    }

    Get-ADUser @getADUserSplat | Select-Object @selectObjectSplat | Sort-Object PasswordExpired
}