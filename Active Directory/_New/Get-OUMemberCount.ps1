$PSArray = New-Object System.Collections.ArrayList

$ous = Get-QADObject -SizeLimit 0 -SearchScope OneLevel -Type 'organizationalunit' | Select-Object dn

foreach ($ou in $ous) {

    $psObject = [pscustomobject]@{

        'OU'    = $ou.DN
        'Count' = (Get-QADUser -SearchRoot $ou.DN -SizeLimit 0).count
    }
    [void]$PSArray.Add($psObject)
}

$PSArray | Export-Csv C:\Temp\ou_count_bmg.csv -NoTypeInformation