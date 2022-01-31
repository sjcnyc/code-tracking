function Get-o365License {

  param
  (
    $Output = (Get-Date -Format yyyy-MM-dd) + '_LicenseReport.csv',
    [string]$CSVFile,
    [ValidateSet('PerSKU', 'PerUser')]$ReportType,
    [ValidateScript({ if ($_ -notmatch '\w*\:\w*') { throw "`$SkuValue must be in the form of tenant:SKUID" } $true })]$SkuValue
  )
  $Users = (Import-Csv -Path C:\temp\users.csv).UserPrincipalName
  $TotalUsers = $Users.Count

  function ChooseSKU {
    # Get SKUs and put into a menu
    $Skus = Get-MsolAccountSku
    $SkuMenu = @{ }
    $Choice = $null
    Write-Host -Fore Yellow 'Select SKU'
    For ($i = 1; $i -le $Skus.Count; $i++) {
      Write-Host "$i. $($Skus[$i - 1].AccountSkuId)"
      $SkuMenu.Add($i, ($Skus[$i - 1].AccountSkuId))
    }
    
    If (!($SkuValue)) {
      [int]$Skuselection = Read-Host 'Enter value for SKU to report on'
      $SkuValue = $SkuMenu.Item($Skuselection)
    }
    
    Write-Host -NoNewline 'Select SKU is: '; Write-Host -ForegroundColor Green "$($SkuValue)"
    
    $Choice = Read-Host 'Correct? [Y/N]'
    
    while ($Choice -ne 'Y') {
      Exit
    }
  }

  If ($ReportType -eq 'PerSKU' -and !$SkuValue) {
    ChooseSKU
  }
  $i = 1
  $global:Report = @()
  switch ($ReportType) {
    PerUser {
      foreach ($User in $Users) {
        Write-Progress -Activity "Processing user $($User.DisplayName) - $($i)/$TotalUsers" -PercentComplete (($i / $TotalUsers) * 100)
        $UserData = [ordered]@{
          DisplayName       = $User.DisplayName
          UserPrincipalName = $User.UserPrincipalName
          AssignedSKUs      = ($User.Licenses.AccountSkuId | ForEach-Object { ($_ -split ':')[1] }) -join ';'
        }
        $UserDataObj = New-Object PSObject -Property $UserData
        $global:Report += $UserDataObj
        $Obj = $null
        $i++
      }
    }
    
    PerSKU {
      foreach ($User in $Users) {
        Write-Progress -Activity "Processing user $($User.DisplayName) - $($i)/$TotalUsers" -PercentComplete (($i / $TotalUsers) * 100)
        $UserData = $null
        If ($User.Licenses.AccountSkuId -match $SkuValue) {
          $UserData = [ordered]@{
            DisplayName       = $User.DisplayName
            UserPrincipalName = $User.UserPrincipalName
            AssignedSKUs      = $SkuValue.Split(':')[1]
          }
          $Obj = New-Object PSObject -Property $UserData
          $global:Report += $Obj
        }
        $i++
      }
    }
  }
  $Report | Export-Csv $Output -Force
}


Get-o365License -Output c:\temp\LicenseReport.csv -ReportType PerUser -CSVFile c:\temp\Users.csv