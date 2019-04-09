$users = Get-ADUser -Server 'me.sonymusic.com' -LDAPFilter "(&(sAMAccountName=adm*-*)(sAMAccountName>=0))" -Properties memberof

$finaloutput = New-Object 'System.Collections.Generic.List[object]'
$roles       = New-Object 'System.Collections.Generic.List[object]'

foreach ($user in $users) {
    $RoleGrps = $user.memberof
    foreach ($RoleGrp in $RoleGrps) {
        $rg = Get-ADGroup -Server 'me.sonymusic.com' $RoleGrp -Properties MemberOf
        $obj = [PSCustomObject]@{
            Role  = $rg.name
            Tasks = (($rg.memberof).ForEach{(Get-ADGroup -Server 'me.sonymusic.com' $_).name} | Out-String).Trim()
        }
        [void]$roles.Add($obj)
    }
    foreach ($role in $roles) {
        $fobj = [PSCustomObject]@{
            AdminName  = $user.samaccountname
            RoleGroups = $role.role
            TaskGroups = ($role.Tasks | Out-String).Trim()
        }
        $finaloutput.Add($fobj)
    }
}

$finaloutput | Export-Csv "C:\Temp\fulladmgrpreport-5-5.csv" -NoTypeInformation