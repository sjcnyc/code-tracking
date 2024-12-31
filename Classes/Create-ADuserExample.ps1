# Import the ADUser.ps1 script
. ./Classes/ADUser.ps1

# Create an instance of the ADUser class
$adUser = [ADUser]::new()

# Test data
$givenName = "John"
$surname = "Doe"
$samAccountName = "jdoe"
$enabled = $true

# Test the CreateNewUser method
try {
    $adUser.CreateNewUser($givenName, $surname, $samAccountName, $enabled)
    Write-Host "User created successfully"
} catch {
    Write-Host "Failed to create user: $_"
}

# Test the _isSamAccountNameUnique method (should be hidden, but for testing purposes)
try {
    $isUnique = $adUser._isSamAccountNameUnique($samAccountName)
    Write-Host "SamAccountName is unique: $isUnique"
} catch {
    Write-Host "Failed to check SamAccountName uniqueness: $_"
}

# Test the _generateRandomPassword method (should be hidden, but for testing purposes)
try {
    $password = $adUser._generateRandomPassword()
    Write-Host "Generated password: $password"
} catch {
    Write-Host "Failed to generate password: $_"
}