function Get-isMember {
    Param(
        [string]$GroupName,
        [string]$UserName = $env:USERNAME
    )
    if (@(([ADSISearcher]("Name={0}" -f $UserName)).FindOne().properties.memberof -match $GroupName).count -gt 0) {
        return $true
    }
}

$SmbDriveList =
@"
H
S
O
U
V
"@ -split [environment]::NewLine

try {

    Foreach ($drive in $SmbDriveList) {

        Get-PSDrive -Name $drive -ErrorAction 0 | Remove-PSDrive -Force | Out-Null
    }

    if (Get-isMember -GroupName 'USA-GBL New Logon Script') {
        Write-Output "$env:USERNAME is a member of USA-GBL New Logon Script"
        Write-Output "Starting Drive Mapping..."
    }
    else {
        break
    }

    Write-Output "Mapping H: To: \\storage.bmg.bagint.com\Home$\$env:USERNAME"
    New-PSDrive –Name "H" –PSProvider FileSystem –Root "\\storage.bmg.bagint.com\Home$\$env:USERNAME" –Persist | Out-Null

    if (Get-isMember -GroupName 'USA-GBL MapS Logon Isilon Data') {
        Write-Output "Mapping S: To: \\storage.bmg.bagint.com\Data$"
        New-PSDrive –Name "S" –PSProvider FileSystem –Root "\\storage.bmg.bagint.com\Data$" –Persist | Out-Null
    }
    if (Get-isMember -GroupName 'USA-GBL MapO Logon Isilon Outlook') {
        Write-Output "Mapping O: To: \\storage.bmg.bagint.com\Outlook$\$env:USERNAME"
        New-PSDrive –Name "O" –PSProvider FileSystem –Root "\\storage.bmg.bagint.com\Outlook$\$env:USERNAME" –Persist | Out-Null
    }
    if (Get-isMember -GroupName 'USA-GBL MapU&V Logon Isilon Updates-Applications') {
        Write-Output "Mapping U: To: \\storage.bmg.bagint.com\Updates$"
        New-PSDrive –Name "U" –PSProvider FileSystem –Root "\\storage.bmg.bagint.com\Updates$" –Persist | Out-Null
        Write-Output "Mapping V: To: \\storage.bmg.bagint.com\Applications$"
        New-PSDrive –Name "V" –PSProvider FileSystem –Root "\\storage.bmg.bagint.com\Applications$" –Persist | Out-Null
    }
    Write-Output "Drive Mapping Finished."
}
catch {
    Write-Output $Error
}