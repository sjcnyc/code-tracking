
@"
USA-GBL BES Junior Helpdesk
USA-GBL BES Senior Helpdesk
"@ -split [environment]::NewLine |
Get-QADGroup |
    ForEach-Object {
    Write-Host "SID: $($_.sid.value)"
        $GID = [int]$_.SID.Value.Substring([int]$_.SID.Value.Lastindexof('-')+1)+1000000
        Write-Host "New GID: $($GID)"
        $_ | Set-QADGroup -ObjectAttributes @{gidNumber=$GID} -Verbose -WhatIf
        Write-Host ''
}