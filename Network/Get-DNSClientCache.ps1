Function Get-DNSClientCache{
$DNSCache = @()

Invoke-Expression 'IPConfig /DisplayDNS' |
Select-string -Pattern 'Record Name' -Context 0,5 |
    %{
        $Record = New-Object PSObject -Property @{
        Name=($_.Line -Split ':')[1]
        Type=($_.Context.PostContext[0] -Split ':')[1]
        TTL=($_.Context.PostContext[1] -Split ':')[1]
        Length=($_.Context.PostContext[2] -Split ':')[1]
        Section=($_.Context.PostContext[3] -Split ':')[1]
        HostRecord=($_.Context.PostContext[4] -Split ':')[1]
        }
        $DNSCache +=$Record
    }
    return $DNSCache
}

Get-DNSClientCache | Format-Table -AutoSize