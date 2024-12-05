<#
.SYNOPSIS
    Provisions a new Windows 365 Cloud PC for a user.

.DESCRIPTION
    This script provisions a new Windows 365 Cloud PC for a user. It includes steps to ensure required modules are installed,
    connect to Microsoft Graph, retrieve available SKUs and provisioning policy groups, verify the user exists, add the user to the selected group,
    and assign the selected SKU license.

.PARAMETER ModuleName
    The name of the module to check and install if not already installed.

.PARAMETER ClientId
    The client ID of the Azure AD application used to authenticate to Microsoft Graph.

.PARAMETER TenantId
    The tenant ID of the Azure AD tenant.

.PARAMETER CertificateThumbprint
    The thumbprint of the certificate used to authenticate to Microsoft Graph.

.EXAMPLE
    .\Provision-CloudPC.ps1
    This example runs the script to provision a new Windows 365 Cloud PC for a user.

.NOTES
    Author: Sean Connealy
    Date: 12-05-2024
    Version: 1.0.0
#>

# Function to check and install required modules
function Get-EnsureModule {
    param (
        [string]$ModuleName
    )
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "Module $ModuleName is not installed. Installing..."
        Install-Module -Name $ModuleName -Scope CurrentUser -Force -AllowClobber
    } else {
        Write-Host "Module $ModuleName is already installed."
    }
}

# Ensure required modules are installed
Get-EnsureModule -ModuleName "Microsoft.Graph"
Get-EnsureModule -ModuleName "Microsoft.Graph.Authentication"

# Define the parameters for connecting to Microsoft Graph
$connectMgGraphSplat = @{
    NoWelcome             = $true
    ClientId              = '91152ce4-ea23-4c83-852e-05e564545fb9'
    TenantId              = 'f0aff3b7-91a5-4aae-af71-c63e1dda2049'
    CertificateThumbprint = 'c838457e980e940c42d9950fa3b3bd8f05b6e919'
}

# Connect to Microsoft Graph
Connect-MgGraph @connectMgGraphSplat | Out-Null

Clear-Host

# Retrieve and display all subscribed SKUs
$skus = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -like 'CPC_E_*' } | Select-Object SkuPartNumber, SkuId, ConsumedUnits

# Define the pattern for provisioning policy groups
$pattern = "az_w365_*users"

# Get all groups with advanced query parameters
$groups = Get-MgGroup -Filter "startswith(displayName,'az_w365_')" -ConsistencyLevel eventual -CountVariable count

# Filter groups in PowerShell
$provisioningPolicies = $groups | Where-Object { $_.DisplayName -like $pattern }

# Prompt for user principal name
$userPrincipalName = Read-Host "Enter the User Principal Name (UPN) of the user"

# Ensure the user exists
$user = Get-MgUser -Filter "userPrincipalName eq '$userPrincipalName'" -ErrorAction SilentlyContinue
while (-not $user) {
    Write-Host "User with UPN $userPrincipalName does not exist. Please enter a valid UPN."
    $userPrincipalName = Read-Host "Enter the User Principal Name (UPN) of the user"
    $user = Get-MgUser -Filter "userPrincipalName eq '$userPrincipalName'" -ErrorAction SilentlyContinue
}

# Prompt user for choices using Out-ConsoleGridView
$selectedSku = $skus | Out-ConsoleGridView -Title "Select Cloud PC SKU" -OutputMode Single
if ($null -eq $selectedSku) {
    Write-Host "No SKU selected. Exiting script."
    Disconnect-MgGraph | Out-Null
    exit
}

$selectedGroup = $provisioningPolicies | Out-ConsoleGridView -Title "Select Provisioning Policy Group" -OutputMode Single
if ($null -eq $selectedGroup) {
    Write-Host "No provisioning policy group selected. Exiting script."
    Disconnect-MgGraph | Out-Null
    exit
}

# Add the user to the selected group
try {
    # Use the correct cmdlet to add a member to a group
    New-MgGroupMember -GroupId $selectedGroup.Id -DirectoryObjectId $user.Id | Out-Null
    Write-Host "Successfully added $userPrincipalName to group $($selectedGroup.DisplayName)"
} catch {
    Write-Host "Failed to add $userPrincipalName to group $($selectedGroup.DisplayName): $_"
}

# Assign the selected SKU license to the user
try {
    $assignedLicense = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphAssignedLicense]@{
        SkuId = $selectedSku.SkuId
    }
    Set-MgUserLicense -UserId $user.Id -AddLicenses $assignedLicense -RemoveLicenses @() | Out-Null
    Write-Host "Successfully assigned SKU $($selectedSku.SkuPartNumber) to $($userPrincipalName)"
} catch {
    Write-Host "Failed to assign SKU $($selectedSku.SkuPartNumber) to $($userPrincipalName) $_"
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph | Out-Null