<#
	The sample scripts are not supported under any Microsoft standard support 
	program or service. The sample scripts are provided AS IS without warranty  
	of any kind. Microsoft further disclaims all implied warranties including,  
	without limitation, any implied warranties of merchantability or of fitness for 
	a particular purpose. The entire risk arising out of the use or performance of  
	the sample scripts and documentation remains with you. In no event shall 
	Microsoft, its authors, or anyone Else involved in the creation, production, or 
	delivery of the scripts be liable for any damages whatsoever (including, 
	without limitation, damages for loss of business profits, business interruption, 
	loss of business information, or other pecuniary loss) arising out of the use 
	of or inability to use the sample scripts or documentation, even If Microsoft 
	has been advised of the possibility of such damages 
#>

# get authorize code
Function Get-AuthroizeCode
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$ClientId,
		[Parameter(Mandatory=$true)][String]$RedirectURI
	)
	# the login url
	$loginUrl = "https://login.live.com/oauth20_authorize.srf?client_id=$ClientId&scope=onedrive.readwrite offline_access&response_type=code&redirect_uri=$RedirectURI";

	# open ie to do authentication
	$ie = New-Object -ComObject "InternetExplorer.Application"
	$ie.Navigate2($loginUrl) | Out-Null
	$ie.Visible = $True

	While($ie.Busy -Or -Not $ie.LocationURL.StartsWith($RedirectURI)) {
		Start-Sleep -Milliseconds 500
	}

	# get authorizeCode
	$authorizeCode = $ie.LocationURL.SubString($ie.LocationURL.IndexOf("=") + 1).Trim();
	$ie.Quit() | Out-Null

	RETURN $authorizeCode
}

# get access token and refresh token
Function New-AccessTokenAndRefreshToken
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$ClientId,
		[Parameter(Mandatory=$true)][String]$RedirectURI,
		[Parameter(Mandatory=$true)][String]$SecretKey
	)
	# get authorize code firstly
	$AuthorizeCode = Get-AuthroizeCode -ClientId $ClientId -RedirectURI $RedirectURI

	$redeemURI = "https://login.live.com/oauth20_token.srf"
	$header = @{"Content-Type"="application/x-www-form-urlencoded"}

	$postBody = "client_id=$ClientId&redirect_uri=$RedirectURI&client_secret=$SecretKey&code=$AuthorizeCode&grant_type=authorization_code"
	$response = Invoke-RestMethod -Headers $header -Method Post -Uri $redeemURI -Body $postBody

	$AccessRefreshToken = New-Object PSObject
	$AccessRefreshToken | Add-Member -Type NoteProperty -Name AccessToken -Value $response.access_token
	$AccessRefreshToken | Add-Member -Type NoteProperty -Name RefreshToken -Value $response.refresh_token

	RETURN $AccessRefreshToken
}

# refresh token
Function Update-AccessTokenAndRefreshToken
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$ClientId,
		[Parameter(Mandatory=$true)][String]$RedirectURI,
		[Parameter(Mandatory=$true)][String]$RefreshToken,
		[Parameter(Mandatory=$true)][String]$SecretKey
	)
	$redeemURI = "https://login.live.com/oauth20_token.srf"
	$header = @{"Content-Type"="application/x-www-form-urlencoded"}

	$postBody = "client_id=$ClientId&redirect_uri=$RedirectURI&client_secret=$SecretKey&refresh_token=$RefreshToken&grant_type=refresh_token"
	$response = Invoke-RestMethod -Headers $header -Method Post -Uri $redeemURI -Body $postBody

	$AccessRefreshToken = New-Object PSObject
	$AccessRefreshToken | Add-Member -Type NoteProperty -Name AccessToken -Value $response.access_token
	$AccessRefreshToken | Add-Member -Type NoteProperty -Name RefreshToken -Value $response.refresh_token

	RETURN $AccessRefreshToken
}

# get autheticate header
Function Get-AuthenticateHeader
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$AccessToken
	)

	RETURN @{"Authorization" = "bearer $AccessToken"}
}

Export-ModuleMember -Function "New-AccessTokenAndRefreshToken", "Update-AccessTokenAndRefreshToken", "Get-AuthenticateHeader"
