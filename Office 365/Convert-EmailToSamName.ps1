function Get-SamFromEmail {

    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [string]$InputCSV,
        [string]$OutputCSV
    )

    Import-Module -Name ActiveDirectory

    $result = New-Object System.Collections.ArrayList

    $props = @{
        Properties = @('SamAccountName', 'GivenName', 'Surname', 'Mail')
    }

    Import-Csv -Path $InputCSV |
        Foreach-Object {
        Get-ADUser -Filter { Mail -eq $_.Mail } @props | Select-Object $props.Properties

        $info = [pscustomobject]@{
            'GivenName'       = $_.GivenName
            'Surname        ' = $_.Surname
            'SamaccountaName' = $_.SamAccountName
            'Mail'            = $_.Mail
        }
        $null = $result.Add($info)
    }
    $result | Export-Csv $OutputCSV -NoTypeInformation
}

Get-SamFromEmail -InputCSV 'C:\Temp\RED User Emails.csv' -OutputCSV 'C:\Temp\RED_User_Alais.csv'