function Test-RegistryValue {
<#
.SYNOPSIS
This function is used to test a registry value.

.DESCRIPTION
The Test-RegistryValue function is designed to check the existence of a registry value and return a boolean result.

.PARAMETER ValueName
Specifies the name of the registry value to test.

.PARAMETER RegistryPath
Specifies the path to the registry key containing the value to test.

.EXAMPLE
Test-RegistryValue -ValueName "ExampleValue" -RegistryPath "HKLM:\Software\Example"

This example tests the existence of the registry value "ExampleValue" under the "HKLM:\Software\Example" registry key.

#>

    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            Position = 1,
            HelpMessage = 'HKEY_LOCAL_MACHINE\SYSTEM')]
        [ValidatePattern('Registry::.*|HKEY_')]
        [ValidateNotNullOrEmpty()]
        [String]$Path,

        [parameter(Mandatory = $true,
            Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [parameter(Position = 3)]
        $ValueData
    )

    Set-StrictMode -Version 2.0

    #Add Regdrive if it is not present
    if ($Path -notmatch 'Registry::.*'){
        $Path = 'Registry::' + $Path
    }

    try {
        #Reg key with value
        if ($ValueData) {
            if ((Get-ItemProperty -Path $Path -ErrorAction Stop | Select-Object -ExpandProperty $Name -ErrorAction Stop) -eq $ValueData) {
                return $true
            }
            else {
                return $false
            }
        }
        #Key key without value
        else {
            $RegKeyCheck = Get-ItemProperty -Path $Path -ErrorAction Stop | Select-Object -ExpandProperty $Name -ErrorAction Stop
            if ($null -eq $RegKeyCheck) {
                #if the Key Check returns null then it probably means that the key does not exist.
                return $false
            }
            else {
                return $true
            }
        }
    }
    catch {
        return $false
    }
}
Function Get-RDSActiveSessions {
<#
.SYNOPSIS
    Remove local file system profiles.
.DESCRIPTION
    This script removes local file system profiles from the system. It supports removing profiles for UPDs (User Profile Disks) and FSL (FSLogix) profiles.
    For UPDs, it excludes currently logged in users and specific profiles defined in the $profilesToExclude array.
    For FSL profiles, it excludes currently logged in users, the local_ folder of logged in users, and specific profiles defined in the $profilesToExclude array.
    The script uses the DelProf2.exe command-line tool for profile removal.
.PARAMETER None
    This script does not accept any parameters.
.EXAMPLE
    Remove-LocalFSLProfiles.ps1
    This example runs the script to remove local file system profiles.
#>

    Begin {
        $Name = $env:COMPUTERNAME
        $ActiveUsers = @()
    }
    Process {
        $result = qwinsta /server:$Name
        If ($result) {
            ForEach ($line in $result[1..$result.count]) {
                #avoiding the line 0, don't want the headers
                $tmp = $line.split(" ") | Where-Object { $_.length -gt 0 }
                If (($line[19] -ne " ")) {
                    #username starts at char 19
                    If ($line[48] -eq "A") {
                        #means the session is active ("A" for active)
                        $ActiveUsers += New-Object PSObject -Property @{
                            "ComputerName" = $Name
                            "SessionName"  = $tmp[0]
                            "UserName"     = $tmp[1]
                            "ID"           = $tmp[2]
                            "State"        = $tmp[3]
                            "Type"         = $tmp[4]
                        }
                    }
                    Else {
                        $ActiveUsers += New-Object PSObject -Property @{
                            "ComputerName" = $Name
                            "SessionName"  = $null
                            "UserName"     = $tmp[0]
                            "ID"           = $tmp[1]
                            "State"        = $tmp[2]
                            "Type"         = $null
                        }
                    }
                }
            }
        }
        Else {
            Write-Error "Unknown error, cannot retrieve logged on users"
        }
    }
    End {
        Return $ActiveUsers
    }
}

#Array that will store the command and all parameters
$CommandToExecute = @()

#The basic command
$CommandToExecute += 'C:\Support\DelProf2.exe /u /i /ed:svc_wvdjoin_usa-2'

$diskSolutionRunning = $False

#UPDs
if (Test-RegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Terminal Server\ClusterSettings' -Name UvhdEnabled -Value 1) {
    #UvhdCleanupBin is also excluded since it is unknown what deleting it will do
    $CommandToExecute += '/ed:UvhdCleanupBin'

    #Exclude logged in users
    $CommandToExecute += "/ed:$((Get-RDSActiveSessions).username -join ' /ed:')"

    $diskSolutionRunning = $True
}

#FSL Profiles
if (Test-RegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles' -Name 'Enabled' -ValueData 1) {
    #Exclude Currently logged in users
    $CommandToExecute += "/ed:$((Get-RDSActiveSessions).username -join ' /ed:')"

    #Exclude local_ folder of logged in users
    $CommandToExecute += "/ed:local_$((Get-RDSActiveSessions).username -join ' /ed:Local_')"

    $diskSolutionRunning = $True
}

if($diskSolutionRunning){
    $profilesToExclude = @(
        '.NET*',
        'DefaultAppPool*'
    )

    $CommandToExecute += "/ed:$($profilesToExclude -join ' /ed:')"

    Invoke-Expression -Command ($CommandToExecute -join ' ')
}
else{
    Write-Output "No disk profile application found"
}