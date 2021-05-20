$search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")

$search.filter = "(servicePrincipalName=*)"

$results = $search.Findall() |
    Where-Object {$_.path -like '*Domain Controllers*'}

foreach ($result in $results) {

    $userEntry = $result.GetDirectoryEntry()

    Write-host "Object Name = " $userEntry.name
    Write-host "DN          = " $userEntry.distinguishedName
    Write-host "Object Cat. = " $userEntry.objectCategory
    Write-host "servicePrincipalNames"
    $i = 1

    foreach ($SPN in $userEntry.servicePrincipalName) {

        Write-host "SPN(" $i ")   =      " $SPN
        $i++
    }

    Write-Output ''
}