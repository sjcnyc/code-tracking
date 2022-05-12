$UserName = Read-Host -Prompt "Enter user sAMAccountName"
$ObjectUser = New-Object System.Security.Principal.NTAccount("me.sonymusic.com", $UserName)

Try {
    $strSid = $ObjectUser.Translate([System.Security.Principal.SecurityIdentifier])

    # Set variables to indicate value and key to set
    $RegSplat = @{
        Path         = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileService\References\$($strSid.Value)"
        Name         = "RefCount"
        Value        = ([byte[]](0x00, 0x00, 0x00, 0x00))
        PropertyType = 'BINARY'
        Force        = $true
    }
    # Create the key if it does not exist
    If (-NOT (Test-Path $RegSplat.Path)) {
        Write-Output "$($strSid.Value) does not exist"
    } else {
        # Now set the value
        New-ItemProperty @RegSplat | Out-Null
        Write-Host "Reset RefCount to zero" -ForegroundColor Green
    }
} catch {
    Write-Host "$($UserName) does not exist" -foregroundcolor red
}