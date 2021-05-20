function Search-ADWithLDAPQuery {
    param (
        [ValidateSet('user', 'group')][string]$filter,
        [string[]]$query,
        [string[]]$Properties,
        [string]$SearchRoot = 'LDAP://DC=mnet,dc=biz'

    )

    if ($SearchRoot) {
        $Root = [ADSI]$SearchRoot
    }
    else {
        $Root = [ADSI]''
    }

    if ($filter -eq 'user') {
        $LDAP = '(&(objectcategory=user)(name=*{0}*))' -f ($query -join ')(')
    }

    if ($filter -eq 'group') {
        $LDAP = '(&(objectcategory=group)(name=*{0}*))' -f ($query -join ')(')
    }


    if (!$Properties) {
        $Properties = 'Name', 'ADSPath'
    }

    (New-Object ADSISearcher -ArgumentList @(
            $Root,
            $LDAP,
            $Properties
        ) -Property @{
            PageSize = 1000
        }).FindAll() | ForEach-Object {
        $ObjectProps = @{}
        $_.Properties.GetEnumerator() |
            Foreach-Object {
            $ObjectProps.Add(
                $_.Name,
                ( -join $_.Value)
            )
        }
        New-Object PSObject -Property $ObjectProps |
            Select-Object $Properties
    }  | Select-Object -Property *
}