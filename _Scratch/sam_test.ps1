using namespace System.Collections.Generic

$results = [List[PSObject]]::new()

Connect-MgGraph -Scopes 'User.Read.All'
Select-MgProfile -Name "beta"

$groups = @'
aa54896b-f792-4e67-b970-f5471dd808bd
f8a8c972-da89-42d3-82a1-d44189e2cd49
'@ -split [environment]::NewLine

$members = foreach ($group in $groups) {
    $grp = get-MgGroup -groupid $group
    Get-MgGroupTransitiveMember -all -GroupId $grp.Id | Select-Object -First 100
}

Write-Output "Loop started at: $(Get-Date)"

foreach ($member in $members) {
    $user = Get-MgUser -UserId $member.Id -Property SignInActivity | Select-Object SignInActivity
    $userObject = [pscustomobject]@{
        displayName           = $member.additionalproperties.displayName
        userPrincipalName     = $member.additionalproperties.userPrincipalName
        Email                 = $member.AdditionalProperties.mail
        SamAccountName        = $member.AdditionalProperties.onPremisesSamAccountName
        Title                 = $member.AdditionalProperties.jobTitle
        Enabled               = $member.AdditionalProperties.accountEnabled
        Department            = $member.AdditionalProperties.department
        CompanyName           = $member.AdditionalProperties.companyName
        City                  = $member.AdditionalProperties.city
        LastSignIn            = $user.SignInActivity.lastSigninDateTime
        AZ_CAPhase5_UserGroup = if (Confirm-MgUserMemberGroup -UserId $member.Id -GroupIds "e9dc8225-1705-4f2d-9630-901b5dd19fee") { "Yes" }else { "No" }
        AZ_CAPhase5_MAC_TS    = if (Confirm-MgUserMemberGroup -UserId $member.Id -GroupIds "92ffa0cf-f5a1-4e55-a547-b39bdc5e42b2") { "Yes" }else { "No" }
    }
    [void]$results.Add($userObject)
}

Write-Output "Loop ended at: $(Get-Date)"