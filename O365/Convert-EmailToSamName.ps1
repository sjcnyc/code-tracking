function Get-SamFromEmail {

    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [string]$InputCSV,
        [string]$OutputCSV,
        [string]$username
    )

    Import-Module -Name ActiveDirectory

    $result = New-Object System.Collections.ArrayList

    $props = @{
        Properties = @('SamAccountName', 'Mail')
    }


            $user = Get-ADUser -Filter { Mail -eq $username } @props -Server me.sonymusic.com | Select-Object $props.Properties

            $info = [pscustomobject]@{
                'originalName'    = $username
                'SamaccountaName' = $user.SamAccountName
                'Mail'            = $user.Mail
            }
            $null = $result.Add($info)

    $result #| Export-Csv $OutputCSV -NoTypeInformation -Append
}

$users =@"
lukas.kempf@sonymusic.com
florence.muteba@sonymusic.com
mariana.ortega@sonymusic.com
lisa.mastrianni@sonymusic.com
natalie.garcia@sonymusic.com
katelyn.lester@sonymusic.com
naima.alisultan.stage@sonymusic.com
zineb.benomar@sonymusic.com
alex.burford@sonymusic.com
nora.thuering@sonymusic.com
yufang.cheng@sonymusic.com
nadjer.aboubakari@sonymusic.com
amy.eason@sonymusic.com
gines.ochoa@sonymusic.com
mariana.nunez@sonymusic.com
lina.gutierrez@sonymusic.com
layla.mustafa@sonymusic.com
ario.wibawa@sonymusic.com
thomas.balmayer@sonymusic.com
bo.plantinga@sonymusic.com
"@ -split [environment]::NewLine

foreach ($user in $users) {
    Get-SamFromEmail -username $user  | select * # Export-Csv D:\Temp\users_for_mike2.csv -NoTypeInformation -Append
}

#skhfksdhfkhsdkfhssdfs