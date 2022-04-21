$import_users = Import-Csv C:\Support\SomLivre2.csv

#$import_users = $import_users | Select-Object * -First 1

$import_users | ForEach-Object {

$Password1 = ([char[]]([char]33 .. [char]95) + ([char[]]([char]97 .. [char]126)) + 0 .. 20 | Sort-Object { Get-Random })[0 .. 20] -join ''
$Password = $(ConvertTo-SecureString $Password1 -AsPlainText -Force)

    $newADUserSplat = @{
        GivenName         = $_.FirstName
        Surname           = $_.LastName
        #Initials             = $_.Initials
        DisplayName       = "$($_.LastName), $($_.FirstName)"
        Name              = "$($_.LastName), $($_.FirstName)"
        SamAccountName    = $_.SamAccountName
        UserPrincipalName = $_.EmailAddress
        EmailAddress      = $_.EmailAddress
        OtherAttributes   = @{'c' = "BR"; 'co' = "BRAZIL"; 'countrycode' = '076' }
        Title             = $_.Title
        Department        = $_.Department
        AccountPassword   = $Password
        Path              = "OU=Employees,OU=Users,OU=RIO,OU=BRA,OU=LA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"          
        ErrorAction       = 'Stop'
    }
 
    New-ADUser @newADUserSplat -Enabled $true


    Start-Sleep -Seconds 10

    $User = Get-ADUser -Identity $_.SamAccountName

    if ($user) {

        Add-ADGroupMember -Identity "GlobalProtectVPN-LatinUsers" -Members $User -ErrorAction 0

        Set-ADUser $User -Add @{mailNickname = $User.Samaccountname } -ErrorAction 0
        Set-ADUser $User -Add @{ProxyAddresses = "SMTP:$($User.EmailAddress)" }
        Set-ADUser $User -EmployeeID $User.EmployeeID -ErrorAction 0
        Set-ADUser $User -EmployeeNumber $User.EmployeeNumber -ErrorAction 0

        $NewObj = [pscustomobject]@{
            SamaccountName = $User.SamAccountName
            DisplayName    = $user.Name
            PassWord       = $Password1
        }
        $Newobj | Export-Csv C:\Support\New_users_created.csv -Append -NoTypeInformation
    }

}