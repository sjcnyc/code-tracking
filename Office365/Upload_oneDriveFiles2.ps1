#Specify tenant admin and site URL
$User = "admin@tenant.onmicrosoft.com"
$SiteURL = "https://tenant.sharepoint.com/sites/site"
$Folder = "C:\FilesToUpload"
$DocLibName = "DocLib"

#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString

#Bind to site collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User, $Password)
$Context.Credentials = $Creds

#Retrieve list
$List = $Context.Web.Lists.GetByTitle($DocLibName)
$Context.Load($List)
$Context.ExecuteQuery()

#Upload file
Foreach ($File in (dir $Folder -File)) {
    $FileStream = New-Object IO.FileStream($File.FullName, [System.IO.FileMode]::Open)
    $FileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
    $FileCreationInfo.Overwrite = $true
    $FileCreationInfo.ContentStream = $FileStream
    $FileCreationInfo.URL = $File
    $Upload = $List.RootFolder.Files.Add($FileCreationInfo)
    $Context.Load($Upload)
    $Context.ExecuteQuery()
}