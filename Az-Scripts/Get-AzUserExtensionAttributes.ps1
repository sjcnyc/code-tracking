# Define the parameters for connecting to Microsoft Graph
$connectMgGraphSplat = @{
    NoWelcome             = $true
    ClientId              = '91152ce4-ea23-4c83-852e-05e564545fb9'
    TenantId              = 'f0aff3b7-91a5-4aae-af71-c63e1dda2049'
    CertificateThumbprint = 'c838457e980e940c42d9950fa3b3bd8f05b6e919'
}

# Connect to Microsoft Graph
Connect-MgGraph @connectMgGraphSplat

# Get all users with the specified properties
$users = Get-MgUser -All -Property DisplayName, UserPrincipalName, OnPremisesExtensionAttributes

# Create a list of properties to select
$properties = @(
    'DisplayName',
    'UserPrincipalName'
)

# Add extension attributes to the properties list
for ($i = 1; $i -le 15; $i++) {
    $properties += @{
        Name       = "ExtensionAttribute$i"
        Expression = { $_.OnPremisesExtensionAttributes.("extensionAttribute$i") }
    }
}

# Select the desired properties and export to CSV
$users | ForEach-Object {
    $user = $_
    $output = [ordered]@{
        DisplayName       = $user.DisplayName
        UserPrincipalName = $user.UserPrincipalName
    }
    for ($i = 1; $i -le 15; $i++) {
        $output["ExtensionAttribute$i"] = $user.OnPremisesExtensionAttributes.("extensionAttribute$i")
    }
    [PSCustomObject]$output
} | Export-Csv -Path "C:\temp\AzureAD_Users_ExtAttribs.csv" -NoTypeInformation

# Disconnect from Microsoft Graph
Disconnect-MgGraph