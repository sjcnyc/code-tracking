#
#
#  Download, install and configure FSLogix on multisession machines
#
#
#
#   Changelog
#
#   0.01 - 04-04-2021 - Initial release
#
#



#
# Define variables 
#

# Set the location where to store the WVD files for the profiles
$FSLogixProfilelocation = "\\woofarfwoof.file.core.windows.net\woofarfwoof"

# Define inclusion and excludion groups for profile redirection
$FSLogixProfileExcludelist = @("somedomain\Domain Admins")
$FSLogixProfileIncludelist = @("somedomain\somegroup")

# Specify if "everyone" should be removed from the FSLogix Include group
$RemoveEveryoneFromIncludelist = $true



#
# Define regwrite function
#

Function RegWrite {

  Param ($RegPath, $RegName, $RegValue, $RegType)
    
  If (-NOT (Test-Path $RegPath)) { 

    New-Item -Path $RegPath -Force | Out-Null 

  }

  New-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -PropertyType $RegType -Force | Out-Null  

}



#
# Define Cleanup function
#

Function Cleanup {

  If ( Test-Path "$env:temp\FSLogix.zip" ) { 

    Remove-Item -Path "$env:temp\FSLogix.zip" -Force 

  }

  If ( Test-Path "$env:temp\FSLogixInstall" ) { 

    Remove-Item -Path "$env:temp\FSLogixInstall" -Recurse -Force 

  }

}



# Cleanup in case a previous attempt failed
Cleanup



#
# Download FSLogix
#
# https://docs.microsoft.com/en-us/fslogix/install-ht
#

Try {
 
  (New-Object System.Net.WebClient).DownloadFile("https://aka.ms/fslogix_download", "$env:temp\FSLogix.zip")

}
CATCH {

  Write-Host "Download error" -ForegroundColor Red
  EXit 1

}



#
# Extract FSLogix archive
#

Expand-Archive -Path "$env:temp\FSLogix.zip" -DestinationPath "$env:temp\FSLogixInstall"

If ( -not (Test-Path "$env:temp\FSLogixInstall\x64\Release\FSLogixAppsSetup.exe")) { 

  Write-Host "FSLogix agent source not found" -ForegroundColor Red
  Cleanup
  Exit 1

}



#
# Install FSLogix client
#
# https://docs.microsoft.com/en-us/fslogix/install-ht
#

$Process = Start-Process "$env:temp\FSLogixInstall\x64\Release\FSLogixAppsSetup.exe" -ArgumentList "/install /quiet /norestart" -PassThru -Wait -WindowStyle Hidden

Write-Host $Process.ExitCode # Diagnosic line. May be removed in final release

if ($process.ExitCode -eq 0) { 

  Write-Host "Success"

}
Elseif ($process.ExitCode -eq -2147024546) { 

  Write-Host "reboot needed"

}
Else { 

  Write-Host "Failed to install"
  Cleanup
  Exit 1

}



#
# Configure FSLogix
#
# https://docs.microsoft.com/en-us/fslogix/configure-profile-container-tutorial
#

# 0: Profile Containers disabled. 1: Profile Containers enabled
RegWrite "HKLM:\Software\FSLogix\Profiles" Enabled 1 DWORD

# A list of file system locations to search for the user's profile VHD(X) file. If one isn't found, one will be created in the first listed location.
RegWrite "HKLM:\Software\FSLogix\Profiles" VHDLocations $FSLogixProfilelocation String

# 0: no deletion. 1: delete local profile if exists and matches the profile being loaded from VHD.
RegWrite "HKLM:\Software\FSLogix\Profiles" DeleteLocalProfileWhenVHDShouldApply 1 DWORD

# When set to '1' the SID folder is created as "%username%%sid%" instead of the default "%sid%%username%"
RegWrite "HKLM:\Software\FSLogix\Profiles" FlipFlopProfileDirectoryName 0 DWORD

# If set to 1 Profile Container will load FRXShell if there's a failure attaching to, or using an existing profile VHD(X).
RegWrite "HKLM:\Software\FSLogix\Profiles" PreventLoginWithFailure 0 DWORD

# If set to 1 Profile Container will load FRXShell if it's determined a temp profile has been created
RegWrite "HKLM:\Software\FSLogix\Profiles" PreventLoginWithTempProfile 1 DWORD

# Set the disk type (VHD or VHDX)
RegWrite "HKLM:\Software\FSLogix\Profiles" VolumeType VHDX String

# VHD(X)s will be dynamically allocated (VHD(X) file size will grow as data is added to the VHD(X)). If set to 0, VHD(X)s that are auto-created will be fully allocated. 
RegWrite "HKLM:\Software\FSLogix\Profiles" IsDynamic 1 DWORD

# Specify the size for auto-created VHD(X) files. Default is 30,000 (30 GBs).
RegWrite "HKLM:\Software\FSLogix\Profiles" SizeInMBs 1500 DWORD



# Exclude groups from FSLogix profile exclude list
If ( $FSLogixProfileExcludelist ) {

  Foreach ( $Exclusion in $FSLogixProfileExcludelist ) {

    Add-LocalGroupMember -Group "FSLogix Profile Exclude List" -Member $Exclusion

  }

}



# Add groups to FSLogix profile include list
If ( $FSLogixProfileIncludelist ) {

  Foreach ( $Inclusion in $FSLogixProfileIncludelist ) {

    Add-LocalGroupMember -Group "FSLogix Profile Include List" -Member $Inclusion

  }

}



# Remove the evenryone group from the FSLogix include group (if specified)
If ( $RemoveEveryoneFromIncludelist ) {
    
  Remove-LocalGroupMember -Group "FSLogix Profile Include List" -Member "Everyone"

}

Cleanup