function Add-PnPFoldersItems {
  [CmdletBinding()]

  param
  (
    [Parameter( 
      Mandatory = $False, 
      ValueFromPipeline = $True, 
      ValueFromPipelineByPropertyName = $True,
      ParameterSetName = 'Connect')] 
    [Alias('uri')]
    [Uri] $Url,

    [Parameter( 
      Mandatory = $False, 
      ValueFromPipeline = $True, 
      ValueFromPipelineByPropertyName = $True)] 
    [Alias('path')]
    [String] $FolderSiteRelativeUrl,

    [Parameter( 
      Mandatory = $True, 
      ValueFromPipeline = $True, 
      ValueFromPipelineByPropertyName = $True)] 
    [Alias('src')]
    [String] $Source,
        
    [Parameter( 
      Mandatory = $False, 
      ValueFromPipeline = $True, 
      ValueFromPipelineByPropertyName = $True)] 
    [String[]] $ExcludeFileExtension,

    [Parameter( 
      Mandatory = $False, 
      ValueFromPipeline = $True, 
      ValueFromPipelineByPropertyName = $True,
      ParameterSetName = 'Connect')]
    [SharePointPnP.PowerShell.Commands.Base.PipeBinds.CredentialPipeBind] $Credential
  )

  begin {
    $ProgressCounter = 0

    if (!(Get-Module -Name 'SharePointPnPPowerShellOnline' -ListAvailable) -and !(Get-Module -Name 'SharePointPnPPowerShell2013' -ListAvailable) -and !(Get-Module -Name 'SharePointPnPPowerShell2016' -ListAvailable)) {
      Write-Warning -Message ([String]::Format('"{0}" {1} "{2}" {3}', 'Get-PnPFoldersItems', 'cmdlet requires', 'SharePointPnPPowerShellOnline or SharePointPnPPowerShell2013 or SharePointPnPPowerShell2016', 'SharePoint Online PowerShell Module to be installed.')) ;

      Write-Warning -Message ([String]::Format('{0} "{1}" {2}: {3}', 'Please kindly install the', 'SharePointPnPPowerShellOnline or SharePointPnPPowerShell2013 or SharePointPnPPowerShell2016', 'SharePoint PowerShell Module using the following command',           'Install-Module -Name SharePointPnPPowerShellVERSION')) ;

      Break ;
    }
    #rely on auto load module instead of importing explicitly

    if ($Credential -ne (Out-Null)) {
            
      try {
        Connect-PnPOnline -Url $Url.AbsoluteUri -Credentials $Credential ;

        $Connection = Get-PnPConnection ;

      }
      catch [System.Exception] {
        throw($_) ;
      }
    }
    else {
      try {
        $Connection = Get-PnPConnection ;
      }
      catch [System.Exception] {
        throw($_) ;
      }
    }
  }

  process {
    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("ExcludeFileExtension")) {
      $FileExtensions = $ExcludeFileExtension |ForEach-Object { $_.Replace('.', '*.') } ;

      $Items = @(Get-ChildItem -Path $Source -File -Recurse -Exclude $FileExtensions) ;
    }
    else {
      $Items = @(Get-ChildItem  -Path $Source -File -Recurse) ;
    }

    foreach ($Item in $Items) {

      $ChildFolder = ($Item.DirectoryName).Replace($Source, '').Replace('\', '/') ;

      if ($ChildFolder -eq [String]::Empty) {
        try {

          Write-Verbose -Message ([String]::Format('{0} [{1}] {2} [{3}]', 'Uploading', $Item.Name, 'from', $Item.DirectoryName)) ;

          Write-Progress -Activity ([String]::Format('{0} [{1}] {2} [{3}]', 'Uploading', $Item.Name, 'from', $Item.DirectoryName)) -Status ([String]::Format('{0}: {1} {2} {3}', 'Uploading', $ProgressCounter, 'of', $($Items.Count))) -PercentComplete (($ProgressCounter / $Items.Count) * 100) ;

          Add-PnPFile -Path $Item.FullName -Folder $FolderSiteRelativeUrl |Out-Null ;

          Write-Verbose -Message ([String]::Format('{0} [{1}] {2} [{3}/{4}]', 'Uploaded', $Item.Name, 'to', $Connection.Url, $FolderSiteRelativeUrl)) ;

          $ProgressCounter++ ;
        }
        catch [Microsoft.SharePoint.Client.ClientRequestException] {
          throw($_) ;
        }
      }
      else {
        try {

          Write-Verbose -Message ([String]::Format('{0} [{1}] {2} [{3}]', 'Uploading', $Item.Name, 'from', $Item.DirectoryName)) ;

          Write-Progress -Activity ([String]::Format('{0} [{1}] {2} [{3}]', 'Uploading', $Item.Name, 'from', $Item.DirectoryName)) -Status ([String]::Format('{0}: {1} {2} {3}', 'Uploading', $ProgressCounter, 'of', $($Items.Count))) -PercentComplete (($ProgressCounter / $Items.Count) * 100) ;

          Add-PnPFile -Path $Item.FullName -Folder $($FolderSiteRelativeUrl + $ChildFolder) |Out-Null ;

          Write-Verbose -Message ([String]::Format('{0} [{1}] {2} [{3}/{4}]', 'Uploaded', $Item.Name, 'to', $Connection.Url, $($FolderSiteRelativeUrl + $ChildFolder))) ;

          $ProgressCounter++ ;
        }
        catch [Microsoft.SharePoint.Client.ClientRequestException] {
          throw($_) ;
        }
      }
    }
  }

  end {
  }
}


$addPnPFoldersItemsSplat = @{
    Url = 'https://amce.sharepoint.com/sites/powershellcommunity'
    ExcludeFileExtension = '.txt', '.xlsx'
    FolderSiteRelativeUrl = 'Shared Documents'
    Credential = (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList (Read-Host -Prompt 'Input your Username'), (ConvertTo-SecureString -String (Read-Host -Prompt 'Input your Password') -AsPlainText -Force))
    Source = 'C:\Temp'
}
Add-PnPFoldersItems @addPnPFoldersItemsSplat