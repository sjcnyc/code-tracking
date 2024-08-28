$connectMgGraphSplat = @{
    NoWelcome             = $true
    ClientId              = '91152ce4-ea23-4c83-852e-05e564545fb9'
    TenantId              = 'f0aff3b7-91a5-4aae-af71-c63e1dda2049'
    CertificateThumbprint = 'c838457e980e940c42d9950fa3b3bd8f05b6e919'
}

Connect-MgGraph @connectMgGraphSplat

$AzGroups = @{
    #"AZ_All_SMEJ_Users"          = "aa54896b-f792-4e67-b970-f5471dd808bd"
    "AZ_O365_License_Birthright" = "aa54896b-f792-4e67-b970-f5471dd808bd"
    #"AZ_3rdParty_Apps"           = "4bd5fcbf-a80c-4880-bf82-8a7923bdeb67"
}

$AZGroups.GetEnumerator() | ForEach-Object {
    $GroupSplat = @{
        GroupName = $_.key
        ObjectId  = $_.value
    }
    Write-Output "Getting $($GroupSplat.GroupName) Members"

    $selectObjectSplat = @{
        Property = 'displayName', 'userprincipalName', 'givenName', 'surName', 'mail', 'onPremisesSamAccountName', @{N="ProxyAddresses"; E={($_.ProxyAddresses | Where-Object {$_ -clike 'smtp:*' -and $_ -notmatch 'onmicrosoft'}) -replace 'smtp:', ' '}}
    }

    Get-MgGroupMemberAsUser -GroupId $GroupSplat.ObjectId -Property "displayName, userprincipalName, givenName, surName, mail, onPremisesSamAccountName, proxyAddresses" -ConsistencyLevel eventual -All | Select-Object @selectObjectSplat |
        Export-Csv -Path "c:\Temp\$($GroupSplat.GroupName)_Members.csv" -NoTypeInformation
}