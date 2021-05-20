function GetAuthToken {
    param
    (
        [Parameter(Mandatory = $true)]
        $TenantName
    )

    $adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"

    $adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
 
    [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null

    [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null

    $clientId = "1950a258-227b-4e31-a9cf-717495945fc2"

    $redirectUri = "urn:ietf:wg:oauth:2.0:oob"

    $resourceAppIdURI = "https://graph.windows.net"

    $authority = "https://login.windows.net/$TenantName"

    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

    $authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId, $redirectUri, "Auto")

    return $authResult
}

$tenant = "SONYMUSICENTERTAINMENT.ONMICROSOFT.COM"

$token = GetAuthToken -TenantName $tenant

$authHeader = @{
    'Content-Type'  = 'application\json'
    'Authorization' = $token.CreateAuthorizationHeader()
}

#$resource = "tenantDetails"

$resource = "users"
$uri = "https://graph.windows.net/$tenant/$($resource)?api-version=1.6"
$users = (Invoke-RestMethod -Uri $uri –Headers $authHeader –Method Get –Verbose).value
$users.Count