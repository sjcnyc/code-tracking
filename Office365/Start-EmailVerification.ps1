<#$email = (Import-Csv C:\temp\EmaiAddresses.csv).Email
$result = New-Object -TypeName System.Collections.ArrayList

foreach ($address in $email) {

    $MEEmail = Get-QADUser -Service 'nycmnetads001.mnet.biz:389' -Identity $address -IncludeAllProperties |
        Select-Object Name, Mail, proxyAddresses|
        Where-Object {"proxyAddresses -eq '$address'"}

    $info = [pscustomobject]@{

        'Email' = $address
        'Exists' = if ($MEEmail.ProxyAddresses) {'True'}
        else {'False'}
    }
    $null = $result.Add($info)
}

$result #| Export-Csv C:\Temp\Me_Email_Check_002.csv -NoTypeInformation
#>



function Get-EmailAddress {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True)]
        [string[]]$EmailAddress
    )

    process {
        foreach ($address in $EmailAddress) {
            Get-ADUser -Properties mail, proxyAddresses -Filter "proxyAddresses -like '$address'" -Server 'nycmnetads002.mnet.biz'
        }
    }
}