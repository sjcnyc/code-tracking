Import-Module Az
$ErrorActionPreference = "Continue"
$LocalCSVPath = "D:\CsvDrop"
$ConnectionString = "storage connection string"
$SourceStorageContext = New-AzStorageContext -ConnectionString $ConnectionString
$SrcContainer = "storage container name"
#$Cred = Get-AutomationPSCredential -Name 'T2_Cred' # use with AD Cmdlets

Write-Output "Getting CSV Files..."
$Blobs = Get-AzStorageBlob -Container $SrcContainer -Context $SourceStorageContext

if ($Blobs) {
  foreach ($Blob in $Blobs) {

    Write-Output "Processing: $($Blob.Name)"

    $getAzStorageBlobContentSplat = @{
      Blob        = $Blob.Name
      Container   = $SrcContainer
      Destination = $LocalCSVPath
      Context     = $SourceStorageContext
    }

    Get-AzStorageBlobContent @getAzStorageBlobContentSplat -Force
    Write-Output "Copying: $($Blob.Name) to: $($LocalCSVPath)"

    Get-AzStorageBlob -Context $SourceStorageContext -Container $SrcContainer -Blob $Blob.Name | Remove-AzStorageBlob
    Write-Output "Removing: $($Blob.Name) from: $($SrcContainer)"

    $LocalCSVFile = Import-Csv -Path "$($LocalCSVPath)/$($Blob.Name)"
    Write-Output "Processing: $($LocalCSVFile)"

    try {

      # $LocalCSVFile var contains CSV object data
      # Your AD command here
      # Email report?

      # Remove-Item $LocalCSVFile
      # Write-Output "Removing: $($Blob.Name) from: $($LocalCSVPath)"
    }
    catch {
      Write-Output "$($Error[0].Exception.Message)"
    }
  }
}
else {
  Write-Output "No CSV files to process..."
}