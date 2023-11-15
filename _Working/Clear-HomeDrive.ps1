'@
USER001
USER002
USER003
@' -split [environment]::NewLine |

ForEach-Object {
    try {
        Get-ADUser -Identity $_ -ea Continue | Set-ADUser -Clear HomeDirectory -ea Continue
    }
    catch {
        Write-Host "Failed to clear HomeDirectory for $_"
    }
}



$upnfilter = "*.WNS@*"

$getaduserSplat = @{
    Filter     = {userprincipalname -like $upnfilter}
    Properties = 'userPrincipalName', 'Name', 'sAMAccountName', 'canonicalName'
}

Get-ADUser @getaduserSplat | Select-Object $getaduserSplat.Properties | Export-Csv C:\Temp\WnsUsers.csv -NoTypeInformation