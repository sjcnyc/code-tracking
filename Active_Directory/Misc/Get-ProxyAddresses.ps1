[array]$Collection = $null
$OutputFile = "$ENV:USERPROFILE\Desktop\AllEmailAddresses.csv"

$Collection = Get-ADUser -SearchBase "OU=USA,DC=bmg,DC=bagint,DC=com" -Filter "Enabled -eq $true" -Properties * | ForEach-Object {
    $Addresses = $_ | Select-Object -ExpandProperty ProxyAddresses | Where-Object { $_.DisplayName -notlike $_.mailNickName -and $_ -notlike "x400:*" }
    $Addresses = $Addresses -join ';'
    $obj = New-Object PSObject -Property @{
        "FirstName" = $_.GivenName;
        "LastName" = $_.SurName;
        "DisplayName" = $_.DisplayName;
        "Email" = $Addresses;
        "FInitialLast" = $_.mailNickName
    }
    Write-Output $obj
}

$Collection | Select-Object FirstName, LastName, DisplayName, Email, FInitialLast | Sort-Object LastName | Export-Csv -Path $OutputFile -Encoding UTF8 -NoTypeInformation

notepad $OutputFile