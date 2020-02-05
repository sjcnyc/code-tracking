#UPLOAD file to OneDrive

$modulesToLoad = @("msonline", "Microsoft.Online.SharePoint.Powershell")
$modulesToLoad | ForEach-Object {
    if (!(Get-Module | Where-Object {$_.Name -like "$_"})) {
        Import-Module $_
    }
}

function Check-OneDrive {
    param (
        [Parameter(Mandatory = $true)]
        [String]$upn
    )
    $oneDriveSite = ($MySitePrefix + ($upn -replace '[\.\@]', '_').Insert(0, '/personal/'))
    try {
        Get-SPOSite $oneDriveSite
        return $true
    }
    catch {
        return $false
    }
}

#variables for making the 0365 connection
$AdminURI = "https://yoursite-admin.sharepoint.com"
$o365AdminAccount = "account@yoursite.onmicrosoft.com"  #<-- This account needs access to the OneDrive Site
$o365encPass = "SomeLongRandomNumbersAndLetters="
$o365key = Get-Content "C:\Keys\key.aes"
$MySitePrefix = "https://yoursite-my.sharepoint.com"

#variables for OneDrive account and file transfer
$odUserAccount = "account@yoursiteupn.com"
$odUserDocumentLib = "Documents" #This is the default document library in OneDrive

#Create the credential Objects for connection to MSOL
$msolCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $o365AdminAccount, ($o365encPass | ConvertTo-SecureString -Key $o365key)
#Connect to Sharepoint Online Service
Connect-SPOService -Url $AdminURI -Credential $msolCred
#Create the credential Objects for connection to SPOL
$spolCred = New-Object -TypeName Microsoft.SharePoint.Client.SharePointOnlineCredentials($o365AdminAccount, ($o365encPass | ConvertTo-SecureString -Key $o365key))


$oneDriveSite = (Check-OneDrive $odUserAccount).Url #this converts UPN to OneDrive Personal Site URI

#Connect to OneDrive Site
$context = New-Object Microsoft.SharePoint.Client.ClientContext($oneDriveSite)
$context.RequestTimeout = 16384000
$context.Credentials = $spolCred  #Connect to users oneDrive with ONMICROSOFT Administrator account
$context.ExecuteQuery()

#Load web context
$web = $context.Web
$context.Load($web)
$context.ExecuteQuery()

#Get OneDrive Document List
$oneDriveList = $web.Lists.GetByTitle($odUserDocumentLib)
$context.Load($oneDriveList.RootFolder)
$context.ExecuteQuery()

#Uploading File to oneDrive Site
$localfile = Get-ChildItem $deltaFile
$folderRelativeUrl = $oneDriveList.RootFolder.ServerRelativeUrl
$fileURL = $folderRelativeUrl + "/" + $localfile.Name
[Microsoft.SharePoint.Client.File]::SaveBinaryDirect($web.Context, $fileURL, $localfile.OpenRead(), $true)
