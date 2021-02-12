#Requires -RunAsAdministrator
#Requires -Version 5
<#
.Synopsis
Activates Windows via KMS
.DESCRIPTION
It's a drop in replacement for slmgr scripts
.EXAMPLE
Start-WindowsActivation -Verbose # Activates the local computer
.EXAMPLE
Start-WindowsActivation -Computer WS01 # Activates the computer named WS01
#>
function global:Start-WindowsActivation {
  [CmdletBinding(SupportsShouldProcess = $true, 
    PositionalBinding = $false,
    ConfirmImpact = 'Medium')]
  Param
  (
    # Type localhost or . for local computer or do not use the parameter
    [Parameter(Mandatory = $false,
      Position = 0,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      ValueFromRemainingArguments = $false)]
    [String[]]
    $Computers
  )
  Process {
    if ($pscmdlet.ShouldProcess("Computer", "Activate license via KMS")) {
      $ErrorActionPreference = "Stop"
      Write-Verbose "ErrorActionPreference: Stop"

      # Enum for a meaningful check. Reference: https://docs.microsoft.com/en-us/previous-versions/windows/desktop/sppwmi/softwarelicensingproduct
      enum LicenseStatusCodes {
        Unlicensed
        Licensed
        OOBGrace
        OOTGrace
        NonGenuineGrace
        Notification
        ExtendedGrace
      }
      Write-Verbose "Enums: LicenseStatusCodes loaded"

      Write-Verbose "Enumerating computers: $($Computers.Count) computer(s)."
      foreach ($Computer in $Computers) {
        # Get Computer name
        if ($Computer -eq "." -or $Computer -eq "localhost" -or $Computer -eq "127.0.0.1" -or $null -eq $Computer) {
          $Computer = $ENV:COMPUTERNAME
        }
        Write-Verbose "Computer name: $Computer"

        # Check Windows Activation Status
        $product = Get-WmiObject -Query "SELECT * FROM SoftwareLicensingProduct" -ComputerName $Computer | Where-Object { $_.PartialProductKey }
        Write-Verbose "License Status: $([LicenseStatusCodes]( $product | Select-Object LicenseStatus).LicenseStatus)"

        $activated = (( $product | Select-Object LicenseStatus).LicenseStatus -eq [int][LicenseStatusCodes]::Licensed)
        if ($activated) { Write-Warning "The product is already activated."; continue; }

        # Get Operating System Version
        $osVersion = ((Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer).Caption)
        Write-Verbose "OS Version: $osVersion"

        # KMS Client License Keys - https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys
        $productKey = switch -Wildcard ($osVersion) {

          "Microsoft Windows Server 2016 Standard*" { "WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY" }
          "Microsoft Windows Server 2016 Datacenter*" { "CB7KF-BWN84-R7R2Y-793K2-8XDDG" }
          "Microsoft Windows Server 2019 Standard*" { "N69G4-B89J2-4G8F4-WWYCC-J464C" }
          "Microsoft Windows Server 2019 Datacenter*" { "WMDGN-G9PQG-XVVXX-R3X43-63DFG" }
          "Microsoft Windows 10 Enterprise*" { "NPPR9-FWDCX-D2C8J-H872K-2YT43" }
          "Microsoft Windows Server 2008 R2 Enterprise*" { "489J6-VHDMP-X63PK-3K798-CPX3Y" }
          "Microsoft Windows Server 2012 R2 Standard*" { "D2N9P-3P6X9-2R39C-7RTCD-MDVJX" }
          "Microsoft Windows Server 2012 Standard*" { "D2N9P-3P6X9-2R39C-7RTCD-MDVJX" }
          "Microsoft Windows 7 Enterprise*" { "33PXH-7Y6KF-2VJC9-XBBR8-HVTHH" }
          "Microsoft Windows 7 Professional*" { "FJ82H-XT6CR-J8D7P-XQJJ2-GPDD4" }
          default { "Unknown" }
        }
        Write-Verbose "Product Key: $productKey"

        # Activate Windows
        # If operating system is listed, activate captured product key.
        if ($productKey -ne "Unknown") {
          $service = Get-WmiObject -Query "SELECT * FROM SoftwareLicensingService" -ComputerName $Computer
          $service.InstallProductKey($productKey) > $null
          $service.RefreshLicenseStatus() > $null
        }

        # Check Windows Activation Status
        $activated = (( $product | Select-Object LicenseStatus).LicenseStatus -eq [int][LicenseStatusCodes]::Licensed)
        # Check result
        if ($activated) {
          Write-Verbose "The computer activated succesfully."
        }
        else {
          Write-Error "Activation failed."
        }
      }
    }
  }
}