#Requires -Modules ActiveDirectory, Az, AzFilesHybrid, MSOnline
#Requires -Version 5.1

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$DistName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$GroupsOu,

    [Parameter(Mandatory = $false)]
    [string]$ContribGroup = "AZ_AVD_$($DistName)_Contributor_Users",

    [Parameter(Mandatory = $false)]
    [string]$DesktopGroup = "AZ_AVD_$($DistName)_FullDesktop",

    [Parameter(Mandatory = $false)]
    [string]$CAGroup = "AZ_AVD_ConditionalAcccess_Users",

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Users,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$TenantID,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SubscriptionID,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetOu,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$CreatedBy = $env:USERNAME,

    [Parameter(Mandatory = $false)]
    [ValidateSet('eastus')]
    [string]$Location = 'eastus',

    [Parameter(Mandatory = $false)]
    [PSCredential]$AzureADCreds,

    [Parameter(Mandatory = $false)]
    [switch]$SkipADSync
)

# Enable verbose logging
$VerbosePreference = 'Continue'

# Function for consistent logging
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        'Info' { Write-Verbose $logMessage }
        'Warning' { Write-Warning $logMessage }
        'Error' { Write-Error $logMessage }
    }
}

function Start-AzureADSync {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [PSCredential]$Credentials
    )

    try {
        Write-Log "Initiating Azure AD sync..."
        
        # Connect to MSOnline if not already connected
        try {
            Get-MsolDomain -ErrorAction Stop | Out-Null
        }
        catch {
            if ($Credentials) {
                Connect-MsolService -Credential $Credentials -ErrorAction Stop
            }
            else {
                Connect-MsolService -ErrorAction Stop
            }
        }

        # Start AD sync
        $syncServer = Get-MsolDirSyncConfiguration
        if ($syncServer) {
            $serverAddress = $syncServer.DirectorySynchronizationClientMachine
            Write-Log "Found sync server: $serverAddress"
            
            # Trigger sync using Invoke-Command if the sync server is accessible
            if (Test-Connection -ComputerName $serverAddress -Count 1 -Quiet) {
                Invoke-Command -ComputerName $serverAddress -ScriptBlock {
                    Start-ADSyncSyncCycle -PolicyType Delta
                } -ErrorAction Stop
                Write-Log "Successfully triggered AD sync"
                return $true
            }
            else {
                Write-Log -Level Warning "Sync server not accessible. Manual sync may be required."
                return $false
            }
        }
        else {
            Write-Log -Level Warning "No sync server configuration found. Manual sync may be required."
            return $false
        }
    }
    catch {
        Write-Log -Level Warning "Failed to trigger AD sync: $_"
        return $false
    }
}

function Wait-ForADSync {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [int]$TimeoutMinutes = 20,
        [Parameter(Mandatory = $false)]
        [int]$RetryIntervalSeconds = 30
    )

    try {
        $timeout = (Get-Date).AddMinutes($TimeoutMinutes)
        $groupFound = $false
        
        Write-Log "Waiting for AD sync to complete (timeout: $TimeoutMinutes minutes)..."
        
        while ((Get-Date) -lt $timeout -and -not $groupFound) {
            # Check if the contributor group exists in Azure AD
            try {
                $group = Get-AzADGroup -DisplayName $ContribGroup -ErrorAction Stop
                if ($group) {
                    $groupFound = $true
                    Write-Log "Group '$ContribGroup' found in Azure AD"
                    return $group.Id
                }
            }
            catch {
                Write-Log "Group not found yet, waiting $RetryIntervalSeconds seconds..."
                Start-Sleep -Seconds $RetryIntervalSeconds
            }
        }

        if (-not $groupFound) {
            throw "Timeout waiting for AD sync to complete after $TimeoutMinutes minutes"
        }
    }
    catch {
        Write-Log -Level Error "Error waiting for AD sync: $_"
        throw
    }
}

function New-AvdSecurityGroups {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Groups,
        [string]$GroupsOu
    )

    try {
        Write-Log "Creating AVD security groups..."
        
        foreach ($group in $Groups.GetEnumerator()) {
            # Check if group already exists
            if (Get-ADGroup -Filter "Name -eq '$($group.Key)'" -ErrorAction SilentlyContinue) {
                Write-Log -Level Warning "Group '$($group.Key)' already exists, skipping creation"
                continue
            }

            $newADGroupSplat = @{
                Name        = $group.Key
                Description = $group.Value
                GroupScope  = 'Global'
                Path       = $GroupsOu
            }

            Write-Log "Creating group: $($group.Key)"
            New-ADGroup @newADGroupSplat -ErrorAction Stop
        }
    }
    catch {
        Write-Log -Level Error "Failed to create security groups: $_"
        throw
    }
}

function Add-AvdGroupMemberships {
    [CmdletBinding()]
    param(
        [string]$ContribGroup,
        [string]$DesktopGroup,
        [string]$CAGroup,
        [string[]]$Users
    )

    try {
        Write-Log "Adding nested group memberships..."
        
        # Add nested group memberships
        $currentMembers = Get-ADGroupMember -Identity $ContribGroup -ErrorAction SilentlyContinue
        if ($currentMembers.Name -notcontains $DesktopGroup) {
            Add-ADGroupMember -Identity $ContribGroup -Members $DesktopGroup -ErrorAction Stop
        }
        
        $currentCAMembers = Get-ADGroupMember -Identity $CAGroup -ErrorAction SilentlyContinue
        if ($currentCAMembers.Name -notcontains $ContribGroup) {
            Add-ADGroupMember -Identity $CAGroup -Members $ContribGroup -ErrorAction Stop
        }

        Write-Log "Adding users to desktop group..."
        foreach ($user in $Users) {
            if (Get-ADUser -Filter "SamAccountName -eq '$user'" -ErrorAction SilentlyContinue) {
                Add-ADGroupMember -Identity $DesktopGroup -Members $user -ErrorAction Stop
            }
            else {
                Write-Log -Level Warning "User '$user' not found in AD, skipping"
            }
        }
    }
    catch {
        Write-Log -Level Error "Failed to add group memberships: $_"
        throw
    }
}

function New-AvdAzureInfrastructure {
    [CmdletBinding()]
    param(
        [string]$DistName,
        [string]$Location,
        [string]$CreatedBy,
        [string]$ContribGroupId,
        [string]$TargetOu
    )

    try {
        Write-Log "Creating Azure infrastructure using Bicep template..."
        
        # Create resource group
        $ResourceGroupName = "RG-$($DistName)-P-EUS"
        Write-Log "Creating resource group: $ResourceGroupName"
        New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force

        # Deploy Bicep template
        $templateFile = Join-Path $PSScriptRoot "avd-infrastructure.bicep"
        $deploymentName = "avd-$($DistName.ToLower())-$(Get-Date -Format 'yyyyMMddHHmm')"
        
        $deploymentParams = @{
            distName = $DistName
            location = $Location
            createdBy = $CreatedBy
            contribGroupId = $ContribGroupId
        }

        Write-Log "Deploying Bicep template..."
        $deployment = New-AzResourceGroupDeployment -Name $deploymentName `
            -ResourceGroupName $ResourceGroupName `
            -TemplateFile $templateFile `
            -TemplateParameterObject $deploymentParams

        # Join storage account to AD
        Write-Log "Joining storage account to AD..."
        $joinStorageAccountSplat = @{
            ResourceGroupName                   = $deployment.Outputs.resourceGroupName.Value
            StorageAccountName                  = $deployment.Outputs.storageAccountName.Value
            DomainAccountType                   = "ComputerAccount"
            OrganizationalUnitDistinguishedName = $TargetOu
        }
        Join-AzStorageAccountForAuth @joinStorageAccountSplat -ErrorAction Stop

        return @{
            ResourceGroupName  = $deployment.Outputs.resourceGroupName.Value
            StorageAccountName = $deployment.Outputs.storageAccountName.Value
            ShareName         = $deployment.Outputs.shareName.Value
        }
    }
    catch {
        Write-Log -Level Error "Failed to create Azure infrastructure: $_"
        throw
    }
}

# Main script execution
try {
    Write-Log "Starting AVD deployment for distribution: $DistName"

    # Connect to Azure
    Write-Log "Connecting to Azure..."
    Connect-AzAccount -Tenant $TenantID -SubscriptionId $SubscriptionID -ErrorAction Stop

    # Create security groups
    $groups = @{
        $ContribGroup = "AVD $($DistName) FSLogix Users"
        $DesktopGroup = "AVD $($Distname) Full Desktop"
    }
    New-AvdSecurityGroups -Groups $groups -GroupsOu $GroupsOu

    # Add group memberships
    Add-AvdGroupMemberships -ContribGroup $ContribGroup -DesktopGroup $DesktopGroup -CAGroup $CAGroup -Users $Users

    # Handle AD sync
    if (-not $SkipADSync) {
        $syncStarted = Start-AzureADSync -Credentials $AzureADCreds
        if ($syncStarted) {
            Write-Log "AD sync initiated successfully"
            $contribGroupId = Wait-ForADSync -TimeoutMinutes 20 -RetryIntervalSeconds 30
        }
        else {
            Write-Log -Level Warning "Could not automatically trigger AD sync. Please ensure sync is completed manually."
            $confirmation = Read-Host "Has AD sync completed? (y/n)"
            if ($confirmation -ne 'y') {
                throw "AD sync must complete before proceeding"
            }
            $contribGroupId = (Get-AzADGroup -DisplayName $ContribGroup).Id
        }
    }
    else {
        $contribGroupId = (Get-AzADGroup -DisplayName $ContribGroup).Id
    }

    # Create Azure infrastructure using Bicep
    $infrastructure = New-AvdAzureInfrastructure -DistName $DistName -Location $Location -CreatedBy $CreatedBy `
        -ContribGroupId $contribGroupId -TargetOu $TargetOu

    Write-Log "AVD deployment completed successfully!"
    Write-Log "Resource Group: $($infrastructure.ResourceGroupName)"
    Write-Log "Storage Account: $($infrastructure.StorageAccountName)"
    Write-Log "Share Name: $($infrastructure.ShareName)"

    return $infrastructure
}
catch {
    Write-Log -Level Error "AVD deployment failed: $_"
    throw
}
