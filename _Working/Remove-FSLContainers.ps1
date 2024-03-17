<#
.SYNOPSIS
This script is used to delete FSLogix containers for disabled, inactive, and non-existing users.

    1.  $FSLogixPath       : The location where the containers are stored.
    2.  $ExcludeFolders    : Is the location has folders which must not be processed you can add them here.
    3.  $DaysInactive      : Minimum amount of days when the last logon occured.
    4.  $DeleteDisabled    : Set this to 0 or 1. 0 will NOT delete conainters from disabled user accounts. 1 will ;)
    5.  $DeleteNotExisting : When an user is deleted and the conainers aren't deleted set this to 1 and the containers will be deleted.
    6.  $DeleteInactive    : Users with a last logon longer the the $DaysInactive will be deleted if this is set to 1.
    7.  $OnlyDeleteODFC    : Only the Office cache container will be deleted. Keeping the Profile container.
    8.  $FlipFlopEnabled   : When the folder starts with the username set this to 1.
    9.  $ShowTable         : Set this to 1 to show a table at the end of the script.
    10. $DryRun            : When this is set to 1, nothing will be deleted regardless the settings.

.DESCRIPTION
    Can automatically cleanup FSLogix containers if they match the criteria. This will reduce the used space.

.DESCRIPTION
The script scans the specified FSLogix containers path and deletes containers for users who meet the specified criteria.
The criteria include disabled users, inactive users, and non-existing users in Active Directory.
The script provides options to delete only the Office cache container or both the profile and Office cache containers.
A dry run option is available to simulate the deletion without actually deleting any containers.

.EXAMPLE
.\Untitled-2.ps1 -FSLogixPath "\\NUTANIX_FILES\UserProfiles" -ExcludeFolders @('FSLogix_Redirections', 'Template') -DaysInactive 90 -DeleteDisabled 0 -DeleteNotExisting 0 -DeleteInactive 1 -OnlyDeleteODFC 1 -FlipFlopEnabled 1 -ShowTable 1 -DryRun 1
Runs the script with the specified parameters in dry run mode.

.NOTES
This script requires the Active Directory module to be installed.

#>

# Tune this variables to your needs
$FSLogixPath = "\\stsmewns001.file.core.windows.net\wns-userprofiles"                       # Set FSLogix containers path.
#[string[]]$ExcludeFolders = @('FSLogix_Redirections', 'Template')   # Excluded directories from the FSLogix containers path.
$DaysInactive      = 90                                             # Days of inactivity before FSLogix containers are removed.
$DeleteDisabled    = 1                                              # Delete containers from disabled users.
$DeleteNotExisting = 1                                              # Delete containers from not existing users.
$DeleteInactive    = 1                                              # Delete containers from inactive users.
$OnlyDeleteODFC    = 0                                              # When this is 1 only the office cache container will be deleted and not the profile container.
$FlipFlopEnabled   = 0                                              # When 1 the default naming convention of the folders is used.
$ShowTable         = 1                                              # Show table at the end of the script.
$DryRun            = 0                                              # Override switch, nothing will be deleted, script will also output user names and what will be deleted.

# Script Start
$PotentialSpaceReclamation = 0
$SpaceReclaimed            = 0
$SpaceDisabled             = 0
$SpaceNotExisting          = 0
$SpaceInactive             = 0
$Counter                   = 0
$UsersTable                = @()

if ($DryRun -eq 1) {
    Write-Host "!! DryRun Active, nothing will be deleted !!" -ForegroundColor Green -BackgroundColor Blue
} else {
    Write-Host "!! DryRun NOT Active, containers will be deleted !!" -ForegroundColor Red -BackgroundColor White
    Write-Host -nonewline "Continue? (Y/N) "
    $Response = Read-Host
    if ($Response -ne "Y") {
        EXIT
    }
}

$PathItems = Get-ChildItem -Path "$($FSLogixPath)" -Directory #-Exclude $ExcludeFolders


foreach ($PathItem in $PathItems) {
    if ($FlipFlopEnabled -eq 1) {
        $UserName = $PathItem.Name.Substring(0, $PathItem.Name.IndexOf('_S-1-5'))
    }
    if ($FlipFlopEnabled -eq 0) {
        $UserName = $PathItem.Name.Substring($PathItem.Name.IndexOf('_') + 1)
    }
    $Counter ++
    try {
        $Information = Get-ADUser -Identity $UserName -Properties sAMAccountName, Enabled, lastLogon, lastLogonDate
        if ($False -eq $Information.Enabled) {
            $UserSpace = (Get-ChildItem -Path "$PathItem" | Measure-Object Length -Sum).Sum / 1Gb
            $UsersTable += (@{UserName = "$UserName"; State = "Disabled"; SpaceinGB = "$UserSpace" })
            if ($DryRun -eq 1) {
                Write-host "User $UserName is disabled. Dryrun activated, nothing will be deleted." -ForegroundColor Green
            }
            $PotentialSpaceReclamation = $PotentialSpaceReclamation + $UserSpace
            $SpaceDisabled = $SpaceDisabled + $UserSpace
            # Deleting Disabled Users.
            if ($DeleteDisabled -eq 1) {
                if ($DryRun -eq 0) {
                    if ($OnlyDeleteODFC -eq 1) {
                        Write-Host "Deleting only ODFC container from $UserName" -ForegroundColor Red
                        $SpaceReclaimed = $SpaceReclaimed + $UserSpace
                        $DeleteFile = $PathItem.FullName + "\ODFC*.*"
                        Remove-Item -Path $DeleteFile -Force
                    } else {
                        Write-Host "Deleting containers from $UserName" -ForegroundColor Red
                        $SpaceReclaimed = $SpaceReclaimed + $UserSpace
                        Remove-Item -Path $PathItem -Recurse -Force
                    }
                }
            }
            # Deleting Inactive Users
            elseif ($Information.lastLogonDate -lt ((Get-Date).Adddays( - ($DaysInactive)))) {
                $UserSpace = (Get-ChildItem -Path "$PathItem" | Measure-Object Length -Sum).Sum / 1Gb
                $UsersTable += (@{UserName = "$UserName"; State = "Inactive"; SpaceinGB = "$UserSpace" })
                if ($DryRun -eq 1) {
                    Write-Host "User $UserName is more than $DaysInactive days inactive. Dryrun activated, nothing will be deleted." -ForegroundColor Green
                }
                $PotentialSpaceReclamation = $PotentialSpaceReclamation + $UserSpace
                $SpaceInactive = $SpaceInactive + $UserSpace
                if ($DeleteInactive -eq 1) {
                    if ($DryRun -eq 0) {
                        if ($OnlyDeleteODFC -eq 1) {
                            Write-Host "Deleting only ODFC container from $UserName" -ForegroundColor Red
                            $SpaceReclaimed = $SpaceReclaimed + $UserSpace
                            $DeleteFile = $PathItem.FullName + "\ODFC*.*"
                            Remove-Item -Path $DeleteFile -Force
                        } else {
                            Write-Host "Deleting containers from $UserName" -ForegroundColor Red
                            $SpaceReclaimed = $SpaceReclaimed + $UserSpace
                            Remove-Item -Path $PathItem -Recurse -Force
                        }
                    }
                }
            }
        }
    }

    # Non Existing Users in AD.
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        $UserSpace = (Get-ChildItem -Path "$PathItem" | Measure-Object Length -Sum).Sum / 1Gb
        $UsersTable += (@{UserName = "$UserName"; State = "DoesntExist"; SpaceinGB = "$UserSpace" })
        if ($DryRun -eq 1) {
            Write-Host "User $UserName doesn't exist. Dryrun activated, nothing will be deleted." -ForegroundColor Green
        }
        $PotentialSpaceReclamation = $PotentialSpaceReclamation + $UserSpace
        $SpaceNotExisting = $SpaceNotExisting + $UserSpace
        if ($DeleteNotExisting -eq 1) {
            if ($DryRun -eq 0) {
                if ($OnlyDeleteODFC -eq 1) {
                    Write-Host "Deleting only ODFC container from $UserName" -ForegroundColor Red
                    $SpaceReclaimed = $SpaceReclaimed + $UserSpace
                    $DeleteFile = $PathItem.FullName + "\ODFC*.*"
                    Remove-Item -Path $DeleteFile -Force
                } else {
                    Write-Host "Deleting containers from $UserName" -ForegroundColor Red
                    $SpaceReclaimed = $SpaceReclaimed + $UserSpace
                    Remove-Item -Path $PathItem -Recurse -Force
                }
            }
        }
    }
}

$PotentialSpaceReclamation = "{0:N2} GB" -f $PotentialSpaceReclamation
$SpaceReclaimed            = "{0:N2} GB" -f $SpaceReclaimed
$SpaceDisabled             = "{0:N2} GB" -f $SpaceDisabled
$SpaceNotExisting          = "{0:N2} GB" -f $SpaceNotExisting
$SpaceInactive             = "{0:N2} GB" -f $SpaceInactive

Write-Host ""
if ($ShowTable -eq 1) {
    Write-Host "========================================="
    $UsersTable | ForEach-Object { [PSCustomObject]$_ } | Format-Table UserName, State, SpaceinGB
}
Write-Host "========================================="
Write-Host "FLS Path: $FSLogixPath"
Write-Host "Processed Container Folderss:"$Counter
if ($DryRun -eq 1) {
    Write-Host "Potential $PotentialSpaceReclamation can be reclaimed."
}
Write-Host "Disabled users are claiming $SpaceDisabled"
Write-Host "Not Existing users are claiming $SpaceNotExisting"
Write-Host "Inactive users are claiming $SpaceInactive"
Write-Host "$SpaceReclaimed total reclaimed."