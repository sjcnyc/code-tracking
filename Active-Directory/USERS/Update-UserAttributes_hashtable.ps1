$input_csv = Import-Csv C:\temp\attribute_mod_1.csv

$domain = "bmg.bagint.com"

$headers = $input_csv | Get-Member -MemberType NoteProperty | ForEach-Object {$_.name}

foreach ( $row in $input_csv) {
    $hashTable = @{}
    foreach ($header in $headers) {
        $hashTable.$header = $row.$header
    }
    try {
        Set-ADUser -Identity $row.userID -Server $domain -Replace $hashTable -WhatIf
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        [Management.Automation.ErrorRecord]$e = $_
        $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
        }
        $info.Exception
    }
}