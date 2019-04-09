Class Employee {

    [ValidatePattern("^[a-zA-Z]+$")]
    [string]$FirstName
    [ValidatePattern("^[a-z A-Z]+$")]
    [string]$LastName
    hidden [string]$UserName
    [ValidateSet('Employees', 'Non Employee Users')]
    [string]
    $EmployeeType
    [ValidatePattern("^OU=")]
    [string]$OU
    hidden static [string]$DomainName = "DC=bmg,DC=bagint,DC=com"

    #Constructors
    Employee () {
    }
    Employee ([String]$FirstName, [String]$Lastname, [String]$EmployeeType) {
        #Initializing variables
        $OUResult = ""
        #Setting properties
        $this.EmployeeType = $EmployeeType
        $this.FirstName = $FirstName
        $this.LastName = $Lastname
        #Call to a static method
        $this.UserName = [Employee]::GetNewUserName($FirstName, $Lastname)
        $this.OU = [Employee]::GetOUPickerResults($OUResult)
        #Call to a static property
        #$this.OU = "OU=$($EmployeeType)," + "OU=USR,OU=GBL,OU=USA," + [employee]::DomainName

    }

    #Methods
    [string]static GetNewUserName([string]$FirstName, [string]$LastName) {
        $start = $LastName.replace(" ", "").Substring(0, 5)
        $end = $FirstName.Substring(0, 2)
        $UName = ($start + $end).ToLower()
        $AllNames = Get-ADUser -Filter "SamaccountName -like '$UName*'"
        [int]$LastUsed = $AllNames | ForEach-Object {$_.SamAccountName.trim($Uname)} | Select-Object -Last 1
        $Next = $LastUsed + 1
        $nextNumber = $Next.tostring().padleft(2, '0')
        $SamAccountName = $UName + $nextNumber
        return $SamAccountName
    }

    [string] GetOUPickerResults([string]$OUResult) {

        return $this.$OUResult
    }

    [employee]Create() {
        New-ADUser -SamAccountName $this.UserName `
            -GivenName $this.FirstName `
            -Surname $this.LastName `
            -Name $this.UserName `
            -UserPrincipalName $this.UserName `
            -DisplayName ($this.FirstName + " " + $this.LastName) `
            -Description ($this.FirstName + " " + $this.LastName) `
            -Path $this.OU -WhatIf
        return $this
    }
}

$NewEmployee = [employee]::new("Test", "User", "Non Employee Users").Create()

$NewEmployee | Get-Member