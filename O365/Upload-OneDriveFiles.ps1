<#
KtiTFaNQtK8EigDwrGKvjdy

Application Id
44c017a1-e531-4496-b370-99cc9b7bb0d1

https://localhost
#>

function Send-File
{ 
    [CmdletBinding()]
    Param 
    ( 
        [Parameter(Mandatory=$true)][String]$ClientId, 
        [Parameter(Mandatory=$true)][String]$SecretKey, 
        [Parameter(Mandatory=$true)][String]$RedirectURI, 
        [Parameter(Mandatory=$true)][String]$LocalFilePath,
        [Parameter(Mandatory=$true)][String]$OneDriveTargetPath, 
        [Parameter(Mandatory=$false)][Int]$UploadBulkCount = 1024 * 1024 * 50 
    ) 
 
    # test the local file exists or not 
    If (-Not (Test-Path $LocalFilePath))
    { 
        Throw '"$LocalFilePath" does not exists!' 
    } 
     
    # load authentication module to ease the authentication process 
    Import-Module "$PSScriptRoot\OneDriveAuthentication.psm1" 
     
    # get token 
    $Token = New-AccessTokenAndRefreshToken -ClientId $ClientId -RedirectURI $RedirectURI -SecretKey $SecretKey
 
    # you can store the token somewhere for the later usage, however the token will expired 
    # if the token is expired, please call Update-AccessTokenAndRefreshToken to update token 
    # e.g.
    # $RefreshedToken = Update-AccessTokenAndRefreshToken -ClientId $ClientId -RedirectURI $RedirectURI -RefreshToken $Token.RefreshToken -SecretKey $SecretKey 
     
    # construct authentication header 
    $Header = Get-AuthenticateHeader -AccessToken $Token.AccessToken 
 
    # api root 
    $ApiRootUrl = "https://api.onedrive.com/v1.0" 

    # 1. Create an upload session 
    $uploadSession = Invoke-RestMethod -Headers $Header -Method Post -Uri "$ApiRootUrl/drive/root:/${OneDriveTargetPath}:/upload.createSession"
 
    # 2. import the read file partial dll 
    Add-Type -Path "$PSScriptRoot\libs\ReadPartialFile.dll" 
 
    # 3. get file info 
    $fileInfo = Get-Item $LocalFilePath 
 
    # 4. Upload fragments 
    $filePos = 0 

    Do { 
        $filePartlyBytes = [ReadPartialFile.Reader]::ReadFile($FilePath, $filePos, $UploadBulkCount); 
 
        If ($filePartlyBytes -eq $Null) { 
            Break 
        } 
 
        If ($filePartlyBytes.GetType() -eq [Byte]) { 
            $uploadCount = 1 
        } Else { 
            $uploadCount = $filePartlyBytes.Length 
        } 
 
        $Header["Content-Length"] = $uploadCount 
        $Header["Content-Range"] = "bytes $filePos-$($filePos + $uploadCount - 1)/$($fileInfo.Length)" 
 
        # print progress 
        Write-Host "Uploading block [$filePos - $($filePos + $uploadCount)] among total $($fileInfo.Length)" 
 
        # call upload api 
        $uploadResult = Invoke-RestMethod -Headers $Header -Method Put -Uri $uploadSession.uploadUrl -Body $filePartlyBytes 
 
        # proceed to next postion 
        $filePos += $UploadBulkCount
 
    } While ($filePartlyBytes.GetType() -eq [Byte[]] -and $filePartlyBytes.Length -eq $UploadBulkCount) 
 
    Write-Host "Upload finished" 
    Write-Host "" 
 
    RETURN $uploadResult 
}