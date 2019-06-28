Function Get-ADGroupMemberSamAccountName {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName
    )
    process {
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.Protocols")
        $name = $GroupName
        $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
        $dc = $domain.FindDomainController([System.DirectoryServices.ActiveDirectory.LocatorOptions]::WriteableRequired)
        $rootDn = $domain.GetDirectoryEntry().DistinguishedName
        $ldapConnection = [System.DirectoryServices.Protocols.LdapConnection]::new($dc.Name)
        $groupSearchRequest = [System.DirectoryServices.Protocols.SearchRequest]::new()
        $groupSearchRequest.DistinguishedName = $rootDn
        $groupSearchRequest.Filter = "(samaccountname=$name)"
        $groupSearchRequest.Attributes.Clear()
        [void]$groupSearchRequest.Attributes.Add("1.1")
        $groupSearchResult = $ldapConnection.SendRequest($groupSearchRequest)
        if ($groupSearchResult.ResultCode -eq 'Success' -and $groupSearchResult.Entries[0] -ne $null) {
            $groupDN = $groupSearchResult.Entries[0].DistinguishedName
            $pageRequestControl = [System.DirectoryServices.Protocols.PageResultRequestControl]::new(1000)
            $asqRequestControl = [System.DirectoryServices.Protocols.AsqRequestControl]::new('member')
            $memberSearchRequest = [System.DirectoryServices.Protocols.SearchRequest]::new()
            $memberSearchRequest.DistinguishedName = $groupDN
            $memberSearchRequest.Scope = [System.DirectoryServices.Protocols.SearchScope]::Base
            $memberSearchRequest.Filter = "(objectclass=person)"
            [void]$memberSearchRequest.Attributes.Clear()
            [void]$memberSearchRequest.Attributes.Add('samaccountname')
            [void]$memberSearchRequest.Controls.Add($asqRequestControl)
            [void]$memberSearchRequest.Controls.Add($pageRequestControl)
            do {
                $memberSearchResult = $ldapConnection.SendRequest($memberSearchRequest)
                $pageResultResponse = $memberSearchResult.Controls | Where-Object {$_ -is [System.DirectoryServices.Protocols.PageResultResponseControl]}
                $pageRequestControl.Cookie = $pageResultResponse.Cookie
                $memberSearchResult.Entries | ForEach-Object {
                    $_.Attributes['samaccountname'].GetValues([string])
                }
            } while ($pageResultResponse.Cookie.Count -ne 0)
        }
        else {
            throw "A single group named $name was not found"
        }
    }
}

$Name = "WWI-Denied Logon for ME Migrated Users"

Measure-Command { Get-ADGroupMemberSamAccountName -GroupName $Name } | Select-Object TotalMilliseconds
Measure-Command { (Get-ADGroup $Name -Properties Members).Members | Get-ADUser | Select-Object samaccountname } | Select-Object TotalMilliseconds
