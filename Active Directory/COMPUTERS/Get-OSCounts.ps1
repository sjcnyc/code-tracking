function ImportADModule
{
  Import-Module ActiveDirectory
  if (!($?))
  { 
    #Only works for Windows Server OS with PS running as admin, download RSAT if using desktop OS
    Add-WindowsFeature RSAT-AD-PowerShell
    Import-Module ActiveDirectory
  }
}

function Get-DN
{
  param($domain)
  $names = $domain.Split('.')
  $bFirst = $true
  foreach ($name in $names)
  {
    if ($bFirst)
    {
      $dn += 'DC=' + $name
      $bFirst = $false
    }
    else { $dn += ',DC=' + $name }
  }
  return $dn
}

function Get-DNs
{
  param($domains)
  $dns = @{}
  foreach ($domain in $domains)
  {
    $dns.Add($domain, (Get-DN -domain $domain))
  }
  return $dns
}

function Get-OSCountsPerDomain
{
  param($dns, $enabled, $daysOld)
  $osCounts = @{}
  $cutOffDate = ((Get-Date).Adddays(-($daysOld))).ToFileTime()
  Write-Host 'Getting Data' -NoNewline -ForegroundColor Yellow

  $filter = "(PwdLastSet -gt {0}) -and (Enabled -eq '{1}')" -f $cutOffDate, $enabled
  foreach ($domain in $dns.GetEnumerator())
  {
    $i = 0
    $domains = @{}
    Write-Host '.' -NoNewline -ForegroundColor Yellow
    $computers = Get-ADComputer -Filter $filter -SearchBase $domain.Value -Server $domain.Key -Properties OperatingSystem, OperatingSystemVersion
    foreach ($computer in $computers)
    {
      if ($computer.OperatingSystem -eq $null) { $os = 'NULL'}
      else { $os = $computer.OperatingSystem }
      if ($computer.OperatingSystemVersion -eq $null) { $osver = 'NULL'}
      else { $osver = $computer.OperatingSystemVersion }
      try { $domains.Add(($os + ' - ' + $osver), 1) }
      catch { $domains.Set_Item(($os + ' - ' + $osver), ($domains.Get_Item($os + ' - ' + $osver))+1) }
    }
    $osCounts.Add($domain.Key, $domains)
  }
  Write-Host
  return $osCounts
}

function Get-DisplayOutput
{
  param($osCounts)
  Write-Host
  foreach ($osCount in $osCounts.GetEnumerator())
  {
    Write-Host $OSCount.Key -ForegroundColor Green
    $osCount.Value.GetEnumerator() | Sort-Object Value -Descending | Format-Table -AutoSize
   #$osCount.Value.GetEnumerator() | Export-Csv c:\temp\osCounts.csv -NoTypeInformation
  }
}

#Main

#Import AD Module for PowerShell
ImportADModule

#Get list of domains from current forest
$Domains =  'bmg.bagint.com' #(Get-ADForest).domains

#Get hash table of domains and distinguished names from current forest
$DNs = Get-DNs -domains $Domains

#Get OS counts per domain (specify age here)
$OSCounts = Get-OSCountsPerDomain -dns $DNs -enabled $true -daysOld 200

#Display Results
Get-DisplayOutput -osCounts $OSCounts