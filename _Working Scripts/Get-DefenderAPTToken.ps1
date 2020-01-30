function Get-AtpToken {
  param(
    [string]$TenantID,
    [string]$ApplicationID,
    [string]$ApplicationSecret
  )

  $resourceAppIdUri = 'https://api.securitycenter.windows.com'
  $oAuthUri = "https://login.windows.net/$TenantId/oauth2/token"
  $authBody = [Ordered] @{
    resource      = "$resourceAppIdUri"
    client_id     = "$appId"
    client_secret = "$appSecret"
    grant_type    = 'client_credentials'
  }
  $authResponse = Invoke-RestMethod -Method Post -Uri $oAuthUri -Body $authBody -ErrorAction Stop
  $token = $authResponse.access_token
  return $token
}

$getAtpTokenSplat = @{
    TenantID          = "04fe1413-7bc4-4d52-a4ec-832569ea001c"
    ApplicationID     = "a429f199-6708-4bfb-a4fc-176a191cba6d"
    ApplicationSecret = "v4xu-ppsUqgEIkbGo[N1g64YB_@B??Gt"
}
Get-AtpToken @getAtpTokenSplat