Add-Type -AssemblyName System.Web

# Define Logger class
enum LogLevel {
    Info = 1
    Warning = 2
    Error = 3
}

class Logger {
    [string]$LogFilePath
    [LogLevel]$MinimumLogLevel

    Logger([string]$logFilePath = ".\log.txt", [LogLevel]$minimumLogLevel = [LogLevel]::Info) {
        $this.LogFilePath = $logFilePath
        $this.MinimumLogLevel = $minimumLogLevel
    }

    hidden [void] WriteLogEntry([LogLevel]$level, [string]$message) {
        if ($level.value__ -ge $this.MinimumLogLevel.value__) {
            $logEntry = "{0} [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $level, $message
            Add-Content -Path $this.LogFilePath -Value $logEntry
            Write-Host $logEntry
        }
    }

    [void] Info([string]$message) {
        $this.WriteLogEntry([LogLevel]::Info, $message)
    }

    [void] Warning([string]$message) {
        $this.WriteLogEntry([LogLevel]::Warning, $message)
    }

    [void] Error([string]$message) {
        $this.WriteLogEntry([LogLevel]::Error, $message)
    }
}

# Define ADUser class
class ADUser {
    # Properties
    [String]$City
    [String]$FullName
    [String]$Company
    [String]$Country
    [String]$Department
    [String]$Description
    [String]$EmailAddress
    [String]$EmployeeID
    [Int]$EmployeeNumber
    [Bool]$Enabled
    [String]$Firstname
    [String]$HomeDirectory
    [String]$Manager
    [Array]$MemberOf
    [String]$OfficePhone
    [String]$SamAccountName
    [String]$LastName
    [String]$Title
    [String]$ObjectGuid
    [Logger]$Logger

    # Constructor
    ADUser([String]$SamAccountName, [string]$LogPath = "c:\temp\ADUser.log" ,[Logger]$Logger = $null) {
        if ([string]::IsNullOrWhiteSpace($SamAccountName)) {
            throw "SamAccountName cannot be null or empty"
        }
        if ($null -eq $Logger) {
            $this.Logger = [Logger]::new($LogPath, [LogLevel]::Info)
        }
        else {
            $this.Logger = $Logger
        }
        $this.Logger.Info("Initializing ADUser for $SamAccountName")
        $this._getADUser($SamAccountName)
    }

    # Method: Get User Information
    hidden [void] _getADUser([String]$SamAccountName) {
        try {
            $this.Logger.Info("Retrieving AD user information for $SamAccountName")
            $user = Get-ADUser $SamAccountName -Properties * -ErrorAction Stop
            $this._mapUserProperties($user)
            $this.Logger.Info("Successfully retrieved AD user information for $SamAccountName")
        }
        catch {
            $errorMessage = "No ADUser matches the SAMAccountName: $SamAccountName. Error: $($_.Exception.Message)"
            $this.Logger.Error($errorMessage)
            throw $errorMessage
        }
    }

    # Helper method to map user properties
    hidden [void] _mapUserProperties($user) {
        if ($null -eq $user) {
            $errorMessage = "Invalid user object provided for property mapping"
            $this.Logger.Error($errorMessage)
            throw $errorMessage
        }
        $this.City = $user.City
        $this.FullName = $user.CN
        $this.Company = $user.Company
        $this.Country = $user.Country
        $this.Department = $user.Department
        $this.Description = $user.Description
        $this.EmailAddress = $user.EmailAddress
        $this.EmployeeID = $user.EmployeeID
        $this.OfficePhone = $user.OfficePhone
        $this.SamAccountName = $user.SamAccountName
        $this.LastName = $user.Surname
        $this.Title = $user.Title
        $this.ObjectGuid = $user.ObjectGuid
        $this.Firstname = $user.GivenName
        $this.HomeDirectory = $user.HomeDirectory
        $this.Manager = $user.Manager
        $this.EmployeeNumber = $user.EmployeeNumber
        $this.Enabled = $user.Enabled
        $this.MemberOf = $user.MemberOf
        $this.Logger.Info("Mapped properties for user $($this.SamAccountName)")
    }

    # Method: Check if SamAccountName is unique
    hidden [bool] _isSamAccountNameUnique($SamAccountName) {
        $user = Get-ADUser -Filter { SamAccountName -eq $SamAccountName } -ErrorAction SilentlyContinue
        return $null -eq $user
    }

    # Method: Generate random alphanumeric password
    hidden [string] _generateRandomPassword() {
        $length = 12
        $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
        $password = -join (1..$length | ForEach-Object { $chars | Get-Random })
        return $password
    }

    # Method: Create new ADUser
    [void] CreateNewUser([string]$GivenName, [string]$Surname, [string]$SamAccountName, [bool]$Enabled) {
        if (-not $this._isSamAccountNameUnique($SamAccountName)) {
            throw "SamAccountName '$SamAccountName' is already in use"
        }

        $password = $this._generateRandomPassword()
        $userParams = @{
            GivenName         = $GivenName
            Surname           = $Surname
            SamAccountName    = $SamAccountName
            Name              = "$GivenName $Surname"
            UserPrincipalName = "$SamAccountName@yourdomain.com"
            Enabled           = $Enabled
            AccountPassword   = (ConvertTo-SecureString -AsPlainText $password -Force)
            Path              = "OU=Users,DC=yourdomain,DC=com"
        }

        try {
            New-ADUser @userParams -ErrorAction Stop
            $this.Logger.Info("Successfully created AD user $SamAccountName with password $password")
        }
        catch {
            $this.Logger.Error("Failed to create AD user $SamAccountName $_")
            throw $_
        }
    }

    # Method: Enable ADUser
    [void] Enable([System.Management.Automation.PSCredential]$Credential) {
        if ($null -eq $Credential) {
            throw "Credential cannot be null"
        }
        $this._executeADCommand({
                $this.Logger.Info("Enabling AD account for $($this.SamAccountName)")
                Enable-ADAccount -Identity $this.SamAccountName -Credential $Credential -ErrorAction Stop
                $this.Logger.Info("Successfully enabled AD account for $($this.SamAccountName)")
            }, "Unable to Enable User")
    }

    # Method: Disable ADUser
    [void] Disable([System.Management.Automation.PSCredential]$Credential) {
        if ($null -eq $Credential) {
            throw "Credential cannot be null"
        }
        $this._executeADCommand({
                $this.Logger.Info("Disabling AD account for $($this.SamAccountName)")
                Disable-ADAccount -Identity $this.SamAccountName -Credential $Credential -ErrorAction Stop
                $this.Logger.Info("Successfully disabled AD account for $($this.SamAccountName)")
            }, "Unable to Disable User")
    }

    # Method: Set Password
    [void] SetPassword([SecureString]$Password, [System.Management.Automation.PSCredential]$Credential, [int]$Length) {
        if ($null -eq $Password) {
            throw "Password cannot be null"
        }
        if ($null -eq $Credential) {
            throw "Credential cannot be null"
        }
        if ($Password.Length -lt $Length) {
            $errorMessage = "Password must be at least $($Length) characters long"
            $this.Logger.Error($errorMessage)
            throw $errorMessage
        }
        $this._executeADCommand({
                $this.Logger.Info("Setting new password for $($this.SamAccountName)")
                Set-ADAccountPassword -Identity $this.SamAccountName -Credential $Credential -Reset -NewPassword $Password -ErrorAction Stop
                $this.Logger.Info("Successfully set new password for $($this.SamAccountName)")
            }, "Unable to Set Password")
    }

    # Method: Move OU
    [void] MoveOU([String]$NewOU, [System.Management.Automation.PSCredential]$Credential) {
        if ([string]::IsNullOrWhiteSpace($NewOU)) {
            throw "NewOU cannot be null or empty"
        }
        if ($null -eq $Credential) {
            throw "Credential cannot be null"
        }
        if (-not ($NewOU -match '^OU=.*,DC=.*')) {
            $errorMessage = "Invalid OU format. Expected format: 'OU=...,DC=...'"
            $this.Logger.Error($errorMessage)
            throw $errorMessage
        }
        $this._executeADCommand({
                $this.Logger.Info("Moving $($this.SamAccountName) to OU: $NewOU")
                Move-ADObject -TargetPath $NewOU -Identity $this.ObjectGuid -Credential $Credential -Confirm:$False -ErrorAction Stop
                $this.Logger.Info("Successfully moved $($this.SamAccountName) to OU: $NewOU")
            }, "Unable to Change OUs")
    }

    # Method: Set Description
    [void] SetDescription([String]$Description, [System.Management.Automation.PSCredential]$Credential) {
        if ($null -eq $Description) {
            throw "Description cannot be null"
        }
        if ($null -eq $Credential) {
            throw "Credential cannot be null"
        }
        if ($Description.Length -gt 1024) {
            $errorMessage = "Description exceeds maximum length of 1024 characters"
            $this.Logger.Error($errorMessage)
            throw $errorMessage
        }
        $this._executeADCommand({
                $this.Logger.Info("Setting description for $($this.SamAccountName)")
                Set-ADUser $this.SamAccountName -Description $Description -Credential $Credential -Confirm:$False -ErrorAction Stop
                $this.Logger.Info("Successfully set description for $($this.SamAccountName)")
            }, "Unable to set the description")
    }

    # Method: Set Company
    [void] SetCompany([String]$Company, [System.Management.Automation.PSCredential]$Credential) {
        if ([string]::IsNullOrWhiteSpace($Company)) {
            throw "Company cannot be null or empty"
        }
        if ($null -eq $Credential) {
            throw "Credential cannot be null"
        }
        $this._executeADCommand({
                $this.Logger.Info("Setting company for $($this.SamAccountName) to: $Company")
                Set-ADUser $this.SamAccountName -Company $Company -Credential $Credential -Confirm:$False -ErrorAction Stop
                $this.Logger.Info("Successfully set company for $($this.SamAccountName) to: $Company")
            }, "Unable to set the company")
    }

    # Method: Clear Account Expiration Date
    [void] ClearExpiration([System.Management.Automation.PSCredential]$Credential) {
        if ($null -eq $Credential) {
            throw "Credential cannot be null"
        }
        $this._executeADCommand({
                $this.Logger.Info("Clearing account expiration date for $($this.SamAccountName)")
                Clear-ADAccountExpiration -Identity $this.SamAccountName -Credential $Credential -Confirm:$False -ErrorAction Stop
                $this.Logger.Info("Successfully cleared account expiration date for $($this.SamAccountName)")
            }, "Unable to clear expiration date")
    }

    # Method: Add To AD Group
    [void] AddToGroup([String]$GroupName, [System.Management.Automation.PSCredential]$Credential) {
        if ([string]::IsNullOrWhiteSpace($GroupName)) {
            throw "GroupName cannot be null or empty"
        }
        if ($null -eq $Credential) {
            throw "Credential cannot be null"
        }
        $this._executeADCommand({
                $this.Logger.Info("Adding $($this.SamAccountName) to group: $GroupName")
                Add-ADGroupMember -Identity $GroupName -Members $this.SamAccountName -Confirm:$False -Credential $Credential -ErrorAction Stop
                $this.Logger.Info("Successfully added $($this.SamAccountName) to group: $GroupName")
            }, "Unable to add to specified group")
    }

    # Method: Get Group Memberships
    [Array] GetGroupMemberships() {
        try {
            $this.Logger.Info("Retrieving group memberships for $($this.SamAccountName)")
            $memberships = Get-ADPrincipalGroupMembership $this.SamAccountName -ErrorAction Stop
            $this.Logger.Info("Successfully retrieved group memberships for $($this.SamAccountName)")
            return $memberships
        }
        catch {
            $errorMessage = "Unable to get group memberships: $($_.Exception.Message)"
            $this.Logger.Error($errorMessage)
            throw $errorMessage
        }
    }

    # Method: Remove From Groups
    [String[]] RemoveFromGroup([String[]]$Groups, [System.Management.Automation.PSCredential]$Credential) {
        if ($null -eq $Groups) {
            throw "Groups cannot be null"
        }
        if ($null -eq $Credential) {
            throw "Credential cannot be null"
        }
        $failedGroups = @()
        foreach ($group in $Groups) {
            if ([string]::IsNullOrWhiteSpace($group)) {
                $this.Logger.Warning("Skipping empty or null group name")
                continue
            }
            try {
                $this.Logger.Info("Removing $($this.SamAccountName) from group: $group")
                Remove-ADGroupMember -Identity $group -Members $this.SamAccountName -Credential $Credential -Confirm:$False -ErrorAction Stop
                $this.Logger.Info("Successfully removed $($this.SamAccountName) from group: $group")
            }
            catch {
                $errorMessage = "Failed to remove $($this.SamAccountName) from group $($group): $($_.Exception.Message)"
                $this.Logger.Error($errorMessage)
                $failedGroups += $group
            }
        }
        return $failedGroups
    }

    # Helper method to execute AD commands with error handling
    hidden [void] _executeADCommand($command, $errorMessage) {
        try {
            & $command
        }
        catch {
            $fullErrorMessage = "$errorMessage : $($_.Exception.Message)"
            $this.Logger.Error($fullErrorMessage)
            throw $fullErrorMessage
        }
    }
}

# Example usage of the ADUser class
function New-ADUserUsageExample {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SamAccountName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$ADMCredential
    )

    $logger = [Logger]::new("c:\temp\ADUserExample.log", [LogLevel]::Info)
    $logger.Info("Starting Example-ADUserUsage for $SamAccountName")

    try {
        $user = [ADUser]::new($SamAccountName, $logger)
        $logger.Info("User Object Created for $SamAccountName")

        # Disable User Account
        $user.Disable($ADMCredential)
        $logger.Info("Disabled AD User Account for $SamAccountName")

        # Reset User Password
        $newPassword = ConvertTo-SecureString -String ([System.Web.Security.Membership]::GeneratePassword(16, 6)) -AsPlainText -Force
        $user.SetPassword($newPassword, $ADMCredential)
        $logger.Info("Reset AD User Password for $SamAccountName")

        # Move User OU
        $disabledUserOU = 'OU=Disabled Accounts,DC=place,DC=contoso,DC=com'
        $user.MoveOU($disabledUserOU, $ADMCredential)
        $logger.Info("Moved AD User $SamAccountName To Disabled OU")

        # Set AD Description
        $leaveDate = Read-Host "Please enter the 'leave date'"
        $description = "Left the Firm $leaveDate reset pw by $ENV:USERNAME"
        $user.SetDescription($description, $ADMCredential)
        $logger.Info("Set AD User Description for $SamAccountName")

        # Set AD Company
        $user.SetCompany('No Longer With the Firm', $ADMCredential)
        $logger.Info("Set AD User Company Field for $SamAccountName")

        # Clear AD Expiration
        $user.ClearExpiration($ADMCredential)
        $logger.Info("Removed AD User Expiration Date for $SamAccountName")

        # Get Group Memberships
        $groups = $user.GetGroupMemberships()
        $logger.Info("Gathered Group Memberships for $SamAccountName")

        # Remove From Groups
        $failedGroups = $user.RemoveFromGroup($groups, $ADMCredential)
        if ($failedGroups.Count -eq 0) {
            $logger.Info("Removed User $SamAccountName from All Groups")
        }
        else {
            $logger.Warning("Failed to remove User $SamAccountName from the following groups: $($failedGroups -join ', ')")
        }

        $logger.Info("Completed Example-ADUserUsage for $SamAccountName")
    }
    catch {
        $logger.Error("An error occurred in Example-ADUserUsage for $$SamAccountName): $($_.Exception.Message)")
    }
}

# Uncomment the following line to run the example (replace with actual credentials)
# Example-ADUserUsage -SamAccountName "SAMACCOUNTNAME" -ADMCredential $ADMCredential