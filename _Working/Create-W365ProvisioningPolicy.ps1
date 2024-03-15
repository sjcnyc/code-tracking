#Install Microsoft Graph Module
Install-Module Microsoft.Graph

#Read-only  Scope
Connect-MgGraph -Scopes "CloudPC.Read.All"

#Read-Write Scope
Connect-MgGraph -Scopes "CloudPC.ReadWrite.All"

#Beta APIs
Select-MgProfile -Name "beta"

#Production APIs
Select-MgProfile -Name "v1.0"

$params = @{
	displayName = "Orchard-Users"
	description = "Orchard-Users Prov Policy"
	provisioningType = "shared"
	managedBy = "windows365"
	imageId = "MicrosoftWindowsDesktop_windows-ent-cpc_win11-22h2-ent-cpc-os"
	imageDisplayName = "Windows 11 Enterprise + OS Optimizations 22H2"
	imageType = "gallery"
	microsoftManagedDesktop = @{
		type = "starterManaged"
		profile = $null
	}
	enableSingleSignOn = $true
	domainJoinConfigurations = @(
		@{
			type = "azureADJoin"
			regionGroup = "EASTUS"
			regionName = "automatic"
		}
	)
	windowsSettings = @{
		language = "en-US"
	}
	cloudPcNamingTemplate = "ORC-%USERNAME:5%-%RAND:5%"
	OnPremisesConnectionId = "4e47d0f6-6f77-44f0-8893-c0fe1701ffff"
}

New-MgDeviceManagementVirtualEndpointProvisioningPolicy -BodyParameter $params