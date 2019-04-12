<#$u = @{

    'GivenName' = 'Sean'
    'Lastname'  = 'Connealy'
}

$SamPrefix = $u.Givenname.Substring(0, 1).ToLower() + $u.Lastname.Substring(0, 4).ToLower()
$ADOK = $True
$SamOK = $False
$Index = 1
Do {
    $sam = $SamPrefix + ("{0:D2}" -f $Index++)
    "Trying '$($sam)' ... " | Write-Host -NoNewline
    Try {
        If (Get-ADUser -LDAPFilter "(sAMAccountName=$sam)" -ErrorAction Stop) {
            "already taken." | Write-Host
        }
        Else {
            "OK, still free." | Write-Host
            $SamOK = $True
        }
    }
    Catch {
        "Error!" | Write-Host
        $_.Exception | Out-String | Write-Error
        $ADOK = $False
    }
} Until ($SamOK -Or !$ADOK -Or ($Index -ge 99))
If ($SamOK) {
    "Creating new user with samid '$sam'" | Write-Host
}
ElseIf (!$ADOK) {
    "Error accessing AD!" | Write-Host
}
Else {
    "Unable to find a free index between 1 and 99!" | Write-Host
}#>

Param(
    $firstName = 'Sean',
    $LastName = 'Connealy',
    $MI = ''
)

BEGIN {
    Import-Module -Name ActiveDirectory
}

PROCESS {
    Function Get-UserName($UserName) {
        if (Get-ADUser -f {
                samaccountname -eq $UserName
            } -ea 0) {
            Return $False
        }
        Else {
            Return $True
        }
    }

    $UserNames = @()
    $UserNames += $firstName.substring(0, 1) + $LastName.Substring(0, 6)
    $UserNames += $firstName.substring(0, 1) + $MI + $LastName.Substring(0, 6)
  
    $i = 1
    do {
        $UserNames += $firstName.substring(0, 1) + $LastName + $i
    
        $i++
    }
    while ($i -lt 99)
    
    foreach ($UserName in $UserNames) {
        if (Check-UserName $UserName -eq 'True') {
            $UserName.ToLower()
            Break
        }
    }
}

END {
    Clear-Variable -Name UserNames
}
 
