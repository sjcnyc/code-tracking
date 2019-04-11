@'
Organization Management
Recipient Management
View-Only Organization Management
UM Management
Help Desk
Records Management
Discovery Management
Hygiene Management
Compliance Management
RIM-MailboxAdmins339fa76789b140aca40174b8db4ddb79
ISVMailboxUsers_562176623
HelpdeskAdmins_80b73
TenantAdmins_0ce0a
ExchangeServiceAdmins_1356026661
Address List Management
Sony Music View-Only/Email Quarantine Admins
Sony Music Legal Team
Sony Music Office 365 Admin Team
Sony Music InfoSec Team
Sony Music Access Control Team
Sony Music Global Service Desk Team
Sony Music Global Service Desk Manager
Security Reader
Security Administrator
Powershell AW
'@ -split [System.Environment]::NewLine | ForEach-Object -Process {

    $rolegroups = Get-RoleGroup -Identity $_

    foreach ($role in $rolegroups) {

        $object = [PSCustomObject]@{

            'SamAccountName'  = $role.SamAccountName
            'Description'     = $role.Description
            'Roles'           = ($role.Roles | Out-String).Trim()
            'RoleAssignments' = ($role.RoleAssignments | Out-String).Trim()
            'Members'         = ($role.Members | Out-String).Trim()
            #'MFAState'        = if ((Get-MsolUser -UserPrincipalName $_.EmailAddress -ErrorAction Ignore | Select-Object -ExpandProperty StrongAuthenticationRequirements).State -eq 'Enforced') {'Enabled'} else {'Disabled'}

        }
        $object | Export-Csv C:\Temp\roleGroups.csv -NoTypeInformation -Append
    }
}