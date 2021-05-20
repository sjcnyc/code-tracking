function Get-SecurityGroups {
    param(
        [string] $user,
        [string] $filter
    )
    try {
        $groups = ((get-qaduser $user).memberof| Get-QADGroup).where{$_ -like "*$filter*"} | Select-Object Name
        return $groups.Name
    }
    catch {
        $Error
    }
}