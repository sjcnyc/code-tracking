function Get-ATPToken {
  param(
    [string]$TenantID,
    [string]$ApplicationID,
    [string]$ApplicationSecret
  )

  $resourceAppIdUri = 'https://api.securitycenter.windows.com'
  $oAuthUri = "https://login.windows.net/$TenantId/oauth2/token"
  $authBody = [Ordered] @{
    resource      = "$resourceAppIdUri"
    client_id     = "$ApplicationID"
    client_secret = "$ApplicationSecret"
    grant_type    = 'client_credentials'
  }
  $authResponse = Invoke-RestMethod -Method Post -Uri $oAuthUri -Body $authBody -ErrorAction Stop
  $token = $authResponse.access_token
  return $token
}

$getAtpTokenSplat = @{
    TenantID          = "04fe1413-7bc4-4d52-a4ec-832569ea001c"
    ApplicationID     = "a429f199-6708-4bfb-a4fc-176a191cba6d"
    ApplicationSecret = "Xo.5oGy99/.p7w@vAo-]Yie@egs=N8vj"
}
Get-ATPToken @getAtpTokenSplat