# $users = import-csv <path>
$users =
@"
Sam Bruce
Paula Erickson
Ron Mirro
Andrew Ross
Sue Zotian
Frank Lipari
Caroline Symannek
"@ -split [environment]::NewLine

$PSArray = New-Object System.Collections.ArrayList

try {
    foreach ($user in $users) {
        $userReorder = "$($user.Split(" ")[1]), $($user.Split(" ")[0])"
        $userSam = Get-ADUser -filter { Name -eq $userReorder } -Properties SAMAccountName, DisplayName -ErrorAction Stop | Select-Object SAMAccountName, DisplayName

        $psobj = [pscustomobject]@{
            SAMAccountName = if ($null -eq $userSam) { "User Not Found" } else { $userSam.SAMAccountName }
            DisplayName    = if ($null -eq $userSam) { "" } else { $userSam.DisplayName }
        }
        [void]$PSArray.Add($psobj)
    }
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    $Error[0].Exception.GetType().FullName
}

$PSArray