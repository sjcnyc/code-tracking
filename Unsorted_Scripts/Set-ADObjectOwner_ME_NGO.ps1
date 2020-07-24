function Set-ADObjectOwner {
    Param (
        [parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)][string]$Identity,
        [parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true)][string]$Owner
    )

    try {
        $ADObject = Get-ADObject -Filter { (Name -eq $Identity) -or (DistinguishedName -eq $Identity) };
        $AceObj = Get-Acl -Path ("ActiveDirectory:://RootDSE/" + $ADObject.DistinguishedName);
    }
    catch {
        Write-Error "Failed to find the source object.";
        return;
    }

    try {
        $ADOwner = Get-ADObject -Filter { (Name -eq $Owner) -or (DistinguishedName -eq $Owner) };
        $NewOwnAce = New-Object System.Security.Principal.NTAccount($ADOwner.Name);
    }
    catch {
        Write-Error "Failed to find the new owner object.";
        return;
    }

    try {
        $AceObj.SetOwner($NewOwnAce);
        Set-Acl -Path ("ActiveDirectory:://RootDSE/" + $ADObject.DistinguishedName) -AclObject $AceObj;
    }
    catch {
        $errMsg = "Failed to set the new new ACE on " + $ADObject.Name;
        Write-Error $errMsg;
    }
}

$comps = Get-ADObject -filter * -SearchBase "OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com" |
    Select-Object name, @{n = "owner"; e = {(Get-Acl "ad:\$($_.distinguishedname)").owner}} |
    Where-Object {$_.owner -eq "ME\admMNgo-2"}

foreach ($comp in $comps) {
    #Set-ADObjectOwner -Identity $comp -Owner "Domain Admins"
    Write-Output $comp.Name
}


# CN=admMNgo-2,OU=Employee,OU=Users,OU=GBL,OU=USA,OU=NA,OU=ADM,OU=Tier-2,DC=me,DC=sonymusic,DC=com
# CN=ULL68F7280DF322,OU=Win7,OU=Workstations,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com
# CN=Domain Admins,CN=Users,DC=me,DC=sonymusic,DC=com
# Get-QADComputer -Identity "ULL68F7280DF322" -Service "me.sonymusic.com" | Get-QADPermission -Inherited -Service "me.sonymusic.com" #-Account "ME\admMNgo-2"