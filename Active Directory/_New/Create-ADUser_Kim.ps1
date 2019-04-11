$Server = "me.sonymusic.com"
$Cred = Get-Credential
$Password = "S0nyW1nter2017" | ConvertTo-SecureString -AsPlainText -Force

$users = Import-Csv C:\temp\adm-2_users_forKim.csv

foreach ($user in $users) {
    try {
        New-ADUser -Server $Server -Credential $Cred -Name $user.SamAccountName -GivenName $user.FirstName -Surname $user.LastName -DisplayName $user.DisplayName -SamAccountName $user.SamAccountName -Description $user.description -Path $user.ou -AccountPassword $Password -ChangePasswordAtLogon $True -Enabled $True -UserPrincipalName ("{0}@{1}" -f $user.SamAccountName, $Server)
    }
    catch {
        $_
    }
}