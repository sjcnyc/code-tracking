function Add-Win7user {
    [cmdletBinding(SupportsShouldProcess = $True)]
    param(
        [Parameter(Mandatory = $true)] [string]$user)

    begin { }

    process {
        Clear-Host
        try {
            $output = get-qaduser $user -IncludeAllProperties
            $loc = $output.DN.Split(',')[-4 ]
            $usr = $output.DN.Split(',')[-7 ]
            $group = @('USA-GBL New Logon Script', 'USA-GBL MapO Logon Isilon Outlook', 'USA-GBL MapS Logon Isilon Data')
            Write-host "Checking $($user) OU Location..."
            if ($loc -eq 'OU=USA') { Write-Host "`tLocation: " -NoNew ; Write-Host "$($loc),$($usr)" -fore green }
            else {
                Write-Host "`tMoving $user to: " -NoNew ; Write-Host "OU=USA,$usr" -fore red -NoNew
                Move-QADObject -I $user -NewParentContainer "$($usr),ou=usr,ou=gbl,ou=usa,dc=bmg,dc=bagint,dc=com" | Out-Null
                1 .. (50 - ($loc.length + $usr.length + 1)) | ForEach-Object { Write-Host '.' -NoNew ; } ; Write-Host '[ OK ]'
            }
            Write-Host "`n`rChecking $($user) Groups..."

            foreach ($grp in $group) {
                Get-IsMember $user
            }
        }
        catch { $_.exception.message ; continue }
    }
    end { }
}
function Get-IsMember
($user) {
    if (Get-QADUser $user | Get-QADMemberOf | Where-Object { $_.name -eq $grp }) {
        Write-Host "`tMember of: " -NoNew
        Write-Host $grp -fore green
    }
    else {
        Write-Host "`tAdding $($user) to: " -NoNew ; Write-Host $grp -fore red -NoNew ; Add-QADGroupMember -I $grp -Member $user | Out-Null
        1 .. (50 - $grp.Length) | ForEach-Object { Write-Host '.' -NoNew ; } ; Write-Host '[ OK ]'
    }
}

Add-Win7user -user sc_testuser