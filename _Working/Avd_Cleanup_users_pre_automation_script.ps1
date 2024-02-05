$users = Import-Csv C:\Temp\avd_remove_list.csv

foreach ($user in $users){
    #Write-Output "$($user.SamaccountName) in: $($user.GroupName)"
    Remove-ADGroupMember -Identity $user.GroupName -Members $user.SamaccountName -Confirm:$false -whatif
}

#fix git sync