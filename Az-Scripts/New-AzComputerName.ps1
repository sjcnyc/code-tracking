function New-AzComputerName {

    $prefix = "usaz"
    $os = Read-Host -Prompt "Enter the OS you want to create: (1) Windows, (2) Linux"

    $result = switch ( $os ) {
        1 { 'vw' }
        2 { 'vl' }
    }

    $type = Read-Host -Prompt "Enter the tyepe you want to create: (1) INF, (2) APP, (3) Custom"

    $result2 = switch ( $type ) {
        1 { 'inf' }
        2 { 'app' }
        3 { (Read-Host -Prompt "Enter the custom type") }
    }

    $ComputerName = $($prefix + $result + $result2)

    $charcodes = @()
    $charsLower = 97..122 | ForEach-Object { [Char] $_ }
    $charsNumber = 48..57 | ForEach-Object { [Char] $_ }
`   $charcodes += $charsLower
    $charcodes += $charsNumber

    $LengthOfName = 14
    $pw = ($charcodes | Get-Random -Count ($LengthOfName - $ComputerName.Length)) -join ""


    return Write-Output "$($ComputerName)-$($pw)"
}   }    
    Clear-Host

    $ComputerName = $($prefix + $osswitch + $typeswitch.ToLower())

    $pw = New-RandomComputerName -ComputerName $ComputerName
    
    return $pw    
}

function New-RandomComputerName {
    param (
      [Parameter(Mandatory=$true)]
      [string] $ComputerName
    )

    $charcodes = @()
    $charsLower = 97..122 | ForEach-Object { [Char] $_ }
    $charsNumber = 48..57 | ForEach-Object { [Char] $_ }
    $charcodes += $charsLower
    $charcodes += $charsNumber

    $LengthOfName = 14
    $pw = ($charcodes | Get-Random -Count ($LengthOfName - $ComputerName.Length)) -join ""
    
    try {
        $checkName = @(Get-ADComputer -Identity "$($ComputerName)-$($pw)")
        if ($checkName.Count -eq 1) {
            New-RandomComputerName -ComputerName $ComputerName
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        return "$($ComputerName)-$($pw)"
    }     
}

function Read-HostWithDefault {
    param(
        [parameter(Mandatory=$true,HelpMessage='Add help message for user')]
        [string] $Default,

        [parameter()]
        [string] $Prompt = 'Enter a password value or accept default of'
    )

    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"
    }

    Process {
        $Response = read-host -Prompt ($Prompt + " [$Default]")
        if ('' -eq $response) {
            $Default
        }
        else {
            $Response
        }
    }

    End {
        Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
    }
}