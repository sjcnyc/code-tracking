# Create explicit collection for missing computers.
$MissingComputers = New-Object 'System.Collections.Generic.List[object]'

# Any standard output inside the foreach loop is captured and returned in the
# variable.  This is an easy way to create a new collection of objects.
$ActionedComputers = foreach ($Computer in $Report)
{
    # check if string is '$null'/empty/whitespace in 1 condition
    if ([string]::IsNullOrWhiteSpace($Computer.'Asset Name')) {
        Write-Warning "Report is missing computer name for this entry"
    }
    else {
        Write-Output "Updating computer = $($Computer."Asset Name")"
        try
        {
            # Here-Strings for multi-line string text.
            Write-Verbose @"
Computer: $($Computer."Asset Name")
Tag: $($Computer."Asset Tag")
Checked out to: $($Computer."Checked Out")
Checkout Date: $($Computer."Checkout Date")
"@

            # Parameter Splatting -
            #   brings all the parameters into the main view of the script.
            $setArgs = @{
                Identity = $Computer.'Asset Name'
                Replace = @{
                    extensionAttribute1 = $Computer.'Asset Tag'
                    extensionAttribute2 = $Computer.'Checked Out'
                    extensionAttribute3 = $Computer.'Checkout Date'
                }
                WhatIf = $true
            }

            Set-ADComputer @setArgs

            # Select-Object creates the resulting PSObject for you.
            $Computer | Select-Object 'Asset Name', 'Asset Tag', 'Checked Out', 'Checkout Date'
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            Write-Warning "Computer $($Computer."Asset Name") not found, skipping"
            $MissingComputers.Add($Computer.'Asset Name')   # uses native 'Add' method.
        }
    }
}

$ActionedComputers