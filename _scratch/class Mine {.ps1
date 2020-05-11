class Mine {
    [string] $Header
    [string] $Information
}

$Data = @(
    @{ Header = 'test0'; Information = 'apple' }
    @{ Header = 'test1'; Information = 'orange' }
    @{ Header = 'test2'; Information = 'lemon' }
)

$Data | Foreach-Object { [Mine] $_ }