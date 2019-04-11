function Get-EmailAddress {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True)]
        [string[]]$EmailAddress,
        [string]$domain
    )

    process {
        foreach ($address in $EmailAddress) {
            Get-ADObject -Properties mail, proxyAddresses -Filter "proxyAddresses -like '*$address*'" -Server $domain
        }
    }
}

$email = (Import-Csv C:\temp\EmaiAddresses.csv).Email
$result = New-Object -TypeName System.Collections.ArrayList

foreach ($address in $email) {

    $MEEmail = Get-EmailAddress -EmailAddress $address -domain 'mnet.biz'

    $info = [pscustomobject]@{

        'Email'  = $address
        'Exists' = if ($MEEmail.ProxyAddresses) {'True'} else {'False'}
    }
    $null = $result.Add($info)
}

$result | Export-Csv C:\Temp\Me_Email_Check_005.csv -NoTypeInformation