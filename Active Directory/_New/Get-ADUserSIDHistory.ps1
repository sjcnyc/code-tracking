using namespace System.Collections.Generic

$UserList = [List[PSObject]]::new()

function Convert-IntTodate {
    Param ($Integer = 0)
    if ($null -eq $Integer) {
        $date = $null
    }
    else {
        $date = [datetime]::FromFileTime($Integer).ToString('g')
        if ($date.IsDaylightSavingTime) {
            $date = $date.AddHours(1)
        }
        $date
    }
}

$GetADObjectSplat = @{
    Properties = 'objectClass', 'distinguishedname', 'samAccountName', 'objectSID', 'sIDHistory', 'LastLogonTimeStamp', 'LastLogon', 'CanonicalName', 'Enabled'
    Server     = 'me.sonymusic.com'
    LDAPFilter = "(sIDHistory=*)"
}
$Users = Get-ADObject @GetADObjectSplat | Where-Object { $_.objectClass -eq "user" } | Select-Object $GetADObjectSplat.Properties -ExpandProperty SIDHistory

foreach ($User in $Users) {
    $UserAttrib = Get-ADUser $User.SamAccountName -properties co, Country, Enabled -Server 'me.sonymusic.com' | Select-Object co, Country, Enabled
    $PSObj = [PSCustomObject]@{
        ObjectClass        = $User.objectClass
        DistinguishedName  = $User.DistinguishedName
        CanonicalName      = $User.CanonicalName -replace "me.sonymusic.com/Tier-2/", ""
        SamAccountName     = $User.SamAccountName
        SID                = $User.ObjectSID
        SIDHistory         = $User.Value
        LastLogonTimeStamp = (Convert-IntTodate $User.LastLogonTimeStamp)
        LastLogon          = (Convert-IntTodate $User.LastLogon)
        Co                 = $UserAttrib.co
        Country            = $UserAttrib.Country
        Enabled            = ($UserAttrib.Enabled).Enabled
    }
    [void]$UserList.Add($PSObj)
}

$UserList | Export-Csv D:\Temp\Me_SIDHistory_User4.csv -NoTypeInformation
