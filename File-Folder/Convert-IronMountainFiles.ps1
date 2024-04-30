function Merge-CSVFiles {
  param (
    [string]$CSVFolder, # = $destination2.Directory.FullName
    [string]$OutputFile #= "$($destination2.Directory.FullName)\PDF_INDEX_$($newName1.Split('_')[0]).csv"
  )

  $CSV= @();
  $files = Get-ChildItem -Path $CSVFolder -Filter *.csv
  foreach ($file in $files) {
 
    $CSV += @(Import-Csv -Path $file.FullName)
  }

  $CSV | Export-Csv -Path $OutputFile -NoTypeInformation -Force;

  $files | Remove-Item -Force
}

function Invoke-IfExists
{
   param
   (
     [Object]$Identity
   )
    [bool] (Get-QADObject -Identity $Identity -ErrorAction SilentlyContinue)
}

function New-SecurityGroup {
  [cmdletbinding()]
    Param(
    [Parameter(Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]$ou='ISI Iron Mountain',
    [Parameter(Position=1)]
    [string]$name
    )

  $sgname = "USA-GBL $($ou) $($name)"
  $description = "\\storage\data$\iron mountain\$($name)"
  $container = "OU=$($ou),OU=FileShare Access,OU=Non-Restricted,OU=GRP,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com"
  New-QADGroup `
      -ParentContainer $container `
      -Name $sgname `
      -samAccountName $sgname `
      -GroupScope 'Global' `
      -GroupType 'Security' `
      -Description $description

    Start-Sleep -Seconds 5
}

$SourceFolder = '\\storage\ifs$\infra\temp\'
$targetFolder =  '\\storage\data$\Iron Mountain\'

Get-ChildItem -Path $SourceFolder -Recurse -File | Where-Object {$_.name -notlike '*.csv'} | % { 
  [System.IO.FileInfo]$destination = (Join-Path -Path $targetFolder -ChildPath  ($_.Name.Split('_')[0] + '\'))

  if(!(Test-Path -Path $destination.Directory )){
    New-item -Path $destination.Directory.FullName -ItemType Directory 
  }

  $parent = $destination.Directory.FullName
  $newName = $_.Name
  $pos = $newName.IndexOf('_')
  $rightIndex = $newName.Substring($pos+1)

  copy-item -Path $_.FullName -Destination $($Destination.FullName + $rightIndex)
}

Get-ChildItem $SourceFolder -Recurse -File | Where-Object {$_.Name -like '*.csv'} | % {
  [System.IO.FileInfo]$destination2 = (Join-Path -Path $parent -ChildPath  ($_.Name.Split('_')[0] + '\'))

  if(!(Test-Path -Path $destination2.Directory )){
    New-item -Path $destination2.Directory.FullName -ItemType Directory 
  }
  $newName1 = $_.Name
  $pos1 = $newName1.IndexOf('_')
  $rightIndex1 = $newName1.Substring($pos1+1)
  Copy-Item -Path $_.FullName -Destination $($destination2.FullName + $rightIndex1)
}

Merge-CSVFiles -CSVFolder $destination2.Directory.FullName -OutputFile "$($destination2.Directory.FullName)\PDF_INDEX_$($newName1.Split('_')[0]).csv"

$folders = (Get-ChildItem -Path C:\TEMP\Testing2 -Recurse -Directory)

  foreach ($folder in $folders) {

    $securityGroup = "BMG\USA-GBL ISI Iron Mountain $($folder.Name)"
    $ntfsPath = $folder.FullName

    if (Invoke-IfExists $securityGroup) {
      
      Write-Host "$($securitygroup) Exists"
     }
     else {
     
      New-SecurityGroup -name $folder.Name | Out-Null

     }

     Add-NTFSAccess -Path $ntfsPath -Account $securityGroup.ToString() -AccessRights 'Modify'
  }