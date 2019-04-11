$group = 'CN=USA-GBL Wireless Computers Certificate,OU=Non-Restricted,OU=GRP,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com'

Get-QADComputer -SearchRoot 'bmg.bagint.com/USA/GBL/WST/Windows7' -SizeLimit 0 -IncludedProperties MemberOf | 
    ForEach-Object { 
    if (! $_.MemberOf -eq $group) {
        write-host "$($_.Name) is not member"
    }
}

$AdminCredentials = Get-Credential "me\admsconnea"

Get-ADPrincipalGroupMembership -server me.sonymusic.com -Credential $AdminCredentials -Identity sconnea | Select-Object samaccountname
