# Ensure we're using Pester 5.0 or later
$MinimumPesterVersion = "5.0.0"
if (-not (Get-Module -ListAvailable -Name Pester | Where-Object { $_.Version -ge $MinimumPesterVersion })) {
    Install-Module -Name Pester -MinimumVersion $MinimumPesterVersion -Force -SkipPublisherCheck
}
Import-Module Pester -MinimumVersion $MinimumPesterVersion -Force

# Import the ADUser.ps1 file
. "$PSScriptRoot\ADUser.ps1"

BeforeAll {
    # Mock AD cmdlets
    function Get-ADUser { param($Identity, $Properties) }
    function Enable-ADAccount { param($Identity, $Credential) }
    function Disable-ADAccount { param($Identity, $Credential) }
    function Set-ADAccountPassword { param($Identity, $NewPassword, $Credential, $Reset) }
    function Move-ADObject { param($Identity, $TargetPath, $Credential) }
    function Set-ADUser { param($Identity, $Description, $Company, $Credential) }
    function Clear-ADAccountExpiration { param($Identity, $Credential) }
    function Add-ADGroupMember { param($Identity, $Members, $Credential) }
    function Get-ADPrincipalGroupMembership { param($Identity) }
    function Remove-ADGroupMember { param($Identity, $Members, $Credential, $Confirm) }

    # Create a mock credential
    $script:mockCred = New-Object System.Management.Automation.PSCredential ("username", (ConvertTo-SecureString "password" -AsPlainText -Force))
}

Describe "Logger Class Tests" {
    BeforeAll {
        $script:testLogFile = "TestDrive:\test.log"
    }

    Context "Constructor and basic functionality" {
        It "Creates a new Logger instance with default values" {
            $logger = [Logger]::new()
            $logger | Should -Not -BeNull
            $logger.LogFilePath | Should -Be ".\log.txt"
            $logger.MinimumLogLevel | Should -Be ([LogLevel]::Info)
        }

        It "Creates a new Logger instance with custom values" {
            $logger = [Logger]::new($script:testLogFile, [LogLevel]::Warning)
            $logger.LogFilePath | Should -Be $script:testLogFile
            $logger.MinimumLogLevel | Should -Be ([LogLevel]::Warning)
        }
    }

    Context "Logging methods" {
        BeforeEach {
            $script:logger = [Logger]::new($script:testLogFile)
            if (Test-Path $script:testLogFile) { Remove-Item $script:testLogFile -Force }
        }

        It "Logs an Info message" {
            $script:logger.Info("Test info message")
            $content = Get-Content $script:testLogFile
            $content | Should -Match "\[Info\] Test info message"
        }

        It "Logs a Warning message" {
            $script:logger.Warning("Test warning message")
            $content = Get-Content $script:testLogFile
            $content | Should -Match "\[Warning\] Test warning message"
        }

        It "Logs an Error message" {
            $script:logger.Error("Test error message")
            $content = Get-Content $script:testLogFile
            $content | Should -Match "\[Error\] Test error message"
        }

        It "Does not log Info when minimum level is Warning" {
            $warningLogger = [Logger]::new($script:testLogFile, [LogLevel]::Warning)
            $warningLogger.Info("This should not be logged")
            $content = Get-Content $script:testLogFile
            $content | Should -BeNullOrEmpty
        }
    }
}

Describe "ADUser Class Tests" {
    BeforeAll {
        # Mock AD cmdlets
        Mock Get-ADUser {
            return [PSCustomObject]@{
                SamAccountName = "testuser"
                City = "TestCity"
                CN = "Test User"
                Company = "TestCompany"
                Country = "TestCountry"
                Department = "TestDepartment"
                Description = "TestDescription"
                EmailAddress = "test@example.com"
                EmployeeID = "12345"
                EmployeeNumber = 67890
                Enabled = $true
                GivenName = "Test"
                HomeDirectory = "C:\Users\testuser"
                Manager = "CN=Manager,DC=contoso,DC=com"
                MemberOf = @("Group1", "Group2")
                OfficePhone = "555-1234"
                Surname = "User"
                Title = "Tester"
                ObjectGuid = [guid]::NewGuid()
            }
        }
        Mock Enable-ADAccount { $true }
        Mock Disable-ADAccount { $true }
        Mock Set-ADAccountPassword { $true }
        Mock Move-ADObject { $true }
        Mock Set-ADUser { $true }
        Mock Clear-ADAccountExpiration { $true }
        Mock Add-ADGroupMember { $true }
        Mock Get-ADPrincipalGroupMembership { @("Group1", "Group2") }
        Mock Remove-ADGroupMember { $true }
    }

    Context "Constructor and basic functionality" {
        It "Creates a new ADUser instance" {
            $adUser = [ADUser]::new("testuser")
            $adUser | Should -Not -BeNull
            $adUser.SamAccountName | Should -Be "testuser"
            $adUser.City | Should -Be "TestCity"
        }

        It "Throws an error for empty SamAccountName" {
            { [ADUser]::new("") } | Should -Throw "SamAccountName cannot be null or empty"
        }
    }

    Context "ADUser methods" {
        BeforeEach {
            $script:adUser = [ADUser]::new("testuser")
        }

        It "Enables an AD account" {
            $script:adUser.Enable($script:mockCred)
            Should -Invoke Enable-ADAccount -Times 1 -Exactly -ParameterFilter {
                $Identity -eq "testuser" -and $Credential -eq $script:mockCred
            }
        }

        It "Disables an AD account" {
            $script:adUser.Disable($script:mockCred)
            Should -Invoke Disable-ADAccount -Times 1 -Exactly -ParameterFilter {
                $Identity -eq "testuser" -and $Credential -eq $script:mockCred
            }
        }

        It "Sets a new password" {
            $newPassword = ConvertTo-SecureString "NewP@ssw0rd!" -AsPlainText -Force
            $script:adUser.SetPassword($newPassword, $script:mockCred)
            Should -Invoke Set-ADAccountPassword -Times 1 -Exactly -ParameterFilter {
                $Identity -eq "testuser" -and $NewPassword -eq $newPassword -and $Credential -eq $script:mockCred -and $Reset -eq $true
            }
        }

        It "Moves user to a new OU" {
            $newOU = "OU=NewOU,DC=contoso,DC=com"
            $script:adUser.MoveOU($newOU, $script:mockCred)
            Should -Invoke Move-ADObject -Times 1 -Exactly -ParameterFilter {
                $Identity -eq $script:adUser.ObjectGuid -and $TargetPath -eq $newOU -and $Credential -eq $script:mockCred
            }
        }

        It "Sets user description" {
            $newDescription = "Test description"
            $script:adUser.SetDescription($newDescription, $script:mockCred)
            Should -Invoke Set-ADUser -Times 1 -Exactly -ParameterFilter {
                $Identity -eq "testuser" -and $Description -eq $newDescription -and $Credential -eq $script:mockCred
            }
        }

        It "Sets user company" {
            $newCompany = "Test Company"
            $script:adUser.SetCompany($newCompany, $script:mockCred)
            Should -Invoke Set-ADUser -Times 1 -Exactly -ParameterFilter {
                $Identity -eq "testuser" -and $Company -eq $newCompany -and $Credential -eq $script:mockCred
            }
        }

        It "Clears account expiration" {
            $script:adUser.ClearExpiration($script:mockCred)
            Should -Invoke Clear-ADAccountExpiration -Times 1 -Exactly -ParameterFilter {
                $Identity -eq "testuser" -and $Credential -eq $script:mockCred
            }
        }

        It "Adds user to a group" {
            $groupName = "TestGroup"
            $script:adUser.AddToGroup($groupName, $script:mockCred)
            Should -Invoke Add-ADGroupMember -Times 1 -Exactly -ParameterFilter {
                $Identity -eq $groupName -and $Members -eq "testuser" -and $Credential -eq $script:mockCred
            }
        }

        It "Gets group memberships" {
            $memberships = $script:adUser.GetGroupMemberships()
            $memberships | Should -Not -BeNullOrEmpty
            $memberships.Count | Should -Be 2
            Should -Invoke Get-ADPrincipalGroupMembership -Times 1 -Exactly -ParameterFilter {
                $Identity -eq "testuser"
            }
        }

        It "Removes user from groups" {
            $groups = @("Group1", "Group2")
            $failedGroups = $script:adUser.RemoveFromGroup($groups, $script:mockCred)
            $failedGroups | Should -BeNullOrEmpty
            Should -Invoke Remove-ADGroupMember -Times 2 -Exactly -ParameterFilter {
                $Members -eq "testuser" -and $Credential -eq $script:mockCred -and $Confirm -eq $false
            }
        }
    }
}