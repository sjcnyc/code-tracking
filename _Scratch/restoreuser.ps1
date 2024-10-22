[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string[]]$users
)

# Set global error and warning preferences
$ErrorActionPreference = 'Stop'
$WarningPreference = 'SilentlyContinue'

# Function to add user to a group in Microsoft Graph
function Add-UserToGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$userId,
        [Parameter(Mandatory)]
        [string]$groupId
    )

    try {
        New-MgGroupMember -GroupId $groupId -DirectoryObjectId $userId | Out-Null
        Write-Output "Successfully added user to group with ID: $groupId"
    }
    catch {
        Write-Error "Failed to add user to group with ID: $groupId. Error: $_"
    }
}

foreach ($user in $users) {
    Write-Output "Processing user: $user"

    # Active Directory operations
    try {
        $Creds = $secret:Tier2Cred
        $userUPN = (Get-ADUser -Identity $user -Credential $Creds).UserPrincipalName

        # Enable AD account
        Enable-ADAccount -Identity $user -Credential $Creds -Confirm:$false
        Write-Output "Enabled AD account for $user"

        # Show user in Global Address List
        Set-ADUser -Identity $user -Replace @{msExchHideFromAddressLists = $false } -Credential $Creds
        Write-Output "Showed $user in Global Address List"

        # Add user to VPN group
        Add-ADGroupMember -Identity "GlobalProtectVPN-NorthAmericaUsers" -Members $user -Credential $Creds
        Write-Output "Added $user to: GlobalProtectVPN-NorthAmericaUsers"
    }
    catch {
        Write-Error "Error in Active Directory operations for $user: $_"
    }

    # Microsoft Graph operations
    try {
        # Connect to Graph API
        $connectMgGraphSplat = @{
            NoWelcome             = $true
            ClientId              = '91152ce4-ea23-4c83-852e-05e564545fb9'
            TenantId              = 'f0aff3b7-91a5-4aae-af71-c63e1dda2049'
            CertificateThumbprint = 'c838457e980e940c42d9950fa3b3bd8f05b6e919'
        }

        Connect-MgGraph @connectMgGraphSplat | Out-Null
        Write-Output "Connected to Microsoft Graph"

        # Enable user account in Azure AD
        $params = @{
            accountEnabled = $true
        }
        Update-MgUser -UserId $userUPN -BodyParameter $params
        Write-Output "Enabled Azure AD account for $userUPN"

        # Add user to specified groups
        [string[]]$groupIds = @(
            "aa54896b-f792-4e67-b970-f5471dd808bd",
            "e9dc8225-1705-4f2d-9630-901b5dd19fee",
            "196af4e3-e1b4-44aa-940c-fb6fd1ce6d67"
        )

        $user = Get-MgUser -UserId $userUPN

        foreach ($groupId in $groupIds) {
            Add-UserToGroup -userId $user.Id -groupId $groupId
        }

        Disconnect-MgGraph | Out-Null
        Write-Output "Disconnected from Microsoft Graph"
    }
    catch {
        Write-Error "Error in Microsoft Graph operations for $user: $_"
    }

    # Exchange Online operations
    try {
        $o365cred = $secret:Tier2CloudCred
        Connect-ExchangeOnline -Credential $o365cred -ShowBanner:$false
        Write-Output "Connected to Exchange Online"

        Set-Mailbox -Identity $userUPN -Type Regular
        Write-Output "Set mailbox type to Regular for $userUPN"

        Start-Sleep -Seconds 20
        $userEXO = Get-EXOMailbox -Identity $userUPN | Select-Object UserPrincipalName, RecipientTypeDetails
        Write-Output "Exchange Online mailbox details for $userUPN:"
        Write-Output $userEXO

        Disconnect-ExchangeOnline -Confirm:$false
        Write-Output "Disconnected from Exchange Online"
    }
    catch {
        Write-Error "Error in Exchange Online operations for $user: $_"
    }
}

<#
.SYNOPSIS
This script restores user accounts and performs various operations in Active Directory, Azure AD, and Exchange Online.

.DESCRIPTION
The script takes an array of users and performs the following operations:
1. Enables the user account in Active Directory
2. Shows the user in the Global Address List
3. Adds the user to a VPN group
4. Enables the user account in Azure AD
5. Adds the user to specified Azure AD groups
6. Sets the user's mailbox type to Regular in Exchange Online

.PARAMETER users
An array of user identities to process.

.EXAMPLE
.\restoreuser.ps1 -users @("user1", "user2")

.NOTES
This script uses $secret: syntax for credentials, which is specific to a particular platform.
Ensure that the necessary secret variables (Tier2Cred and Tier2CloudCred) are properly set in the environment before running the script.
#>
