
$PSArrayList = New-Object System.Collections.ArrayList

@"

"@ -split [environment]::NewLine | ForEach-Object -Process {

    $accountStat = Get-QADUser -Service 'NYCSMEADS0012:389' -Identity $_ |
        Select-Object -Property AccountIsDisabled, @{N = 'accountStatus'; E = { if ($_.AccountIsDisabled -eq 'TRUE') {'Disabled'}else {'Enabled'}}}

    $PSObj = [pscustomobject]@{

        'SamAccountName' = $_
        'AccountStatus'  = $accountStat.accountStatus
    }
        $null = $PSArrayList.Add($PSObj)

    $PSArrayList | Export-Csv -Path c:\temp\accountStatus4.csv -NoTypeInformation
}