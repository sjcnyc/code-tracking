Enum EmployeeType{
    Employees
    Consultant
}

Enum FullTimeBaseGroups{
    USA_WifiUsers
}

Enum ConsultantBaseGroups{
    USA_NonEmployeeUsers
}

Class Employee {

    [ValidatePattern("^[a-zA-Z]+$")]
    [string]$FirstName
    [ValidatePattern("^[a-z A-Z]+$")]
    [string]$LastName
    hidden [string]$UserName
    [EmployeeType]$EmployeeType
    [ValidatePattern('^OU=')]
    [string]$OU

    hidden static [string]$DomainName = 'DC=BMG,DC=BAGINT,DC=COM'
    hidden [String]$BaseGroupsEnumName
    [array]$groupslist

    #Constructors

    Employee() {
        if ($this.GetType() -eq [Employee]) {
            throw 'This class cannot be used to create an instance. Please inherit from this class only.'
        }
    }

    Employee ([String]$FirstName, [String]$Lastname, [EmployeeType]$EmployeeType) {
        #Initialising variables
        #$UserOU = ''
        #Setting properties
        $this.EmployeeType = $EmployeeType
        $this.FirstName = $FirstName
        $this.LastName = $Lastname
        #Call to static method
        $this.UserName = [Employee]::GetNewUserName($FirstName, $Lastname)
        #Call to static property
        $this.OU = "OU=$($EmployeeType)," + 'OU=USR,OU=GBL,OU=USA,' + [employee]::DomainName
    }

    #Methods

    [string]static GetNewUserName([string]$FirstName, [string]$Lastname) {
        $start = $Lastname.replace(' ', '').Substring(0, 5)
        $end = $FirstName.Substring(0, 2)
        $UName = ($start + $end).ToLower()
        $AllNames = Get-ADUser -Filter "SamaccountName -like '$UName*'"
        [int]$LastUsed = $AllNames |
            ForEach-Object -Process {
            $_.SamAccountName.trim($UName)
        } |
            Select-Object -Last 1
        $Next = $LastUsed + 1
        $nextNumber = $Next.tostring().padleft(2, '0')
        $SamAccountName = $UName + $nextNumber
        return $SamAccountName
    }

    [employee]Create() {
        New-ADUser -SamAccountName $this.UserName `
            -GivenName $this.FirstName `
            -Surname $this.LastName `
            -Name $this.UserName `
            -UserPrincipalName $this.UserName `
            -DisplayName ($this.FirstName + ' ' + $this.LastName) `
            -Description ($this.FirstName + ' ' + $this.LastName) `
            -Path $this.OU -WhatIf

        return $this
    }

    hidden [void]AddGroupsFromEnum([String]$GroupList) {
        $AllGroups = [System.Enum]::GetNames($GroupList)
        foreach ($group in $AllGroups) {
            ([Employee]$this).AddToGroup($group)
        }
    }

    hidden [void]AddToGroup([string]$AdGroup) {
        Add-ADGroupMember -Identity $AdGroup -Members (Get-ADUser $this.UserName) #-WhatIf
    }
    # method (polymorphic)
    [void]AddToBaseGroups() {
        $this.AddGroupsFromEnum($this.BaseGroupsEnumName)
    }
}

Class Consultant : Employee {

    Consultant([String]$FirstName, [String]$Lastname) {
        $this.BaseGroupsEnumName = 'ConsultantBaseGroups'
        #Call to static property
        $this.EmployeeType = [EmployeeType]::Consultant
        $this.FirstName = $FirstName
        $this.LastName = $Lastname
        #Call static method
        $this.UserName = [Employee]::GetNewUserName($FirstName, $Lastname)
        #Call to static property
        $this.OU = "OU=Non Employee Users,OU=USR,OU=GBL,OU=USA," + [employee]::DomainName
    }
}

Class FullTime : Employee {

    FullTime([string]$FirstName, [string]$Lastname) {
        $this.BaseGroupsEnumName = 'FullTimeBaseGroups'
        #Call to static property
        $this.EmployeeType = [EmployeeType]::Employees
        $this.FirstName = $FirstName
        $this.LastName = $Lastname
        #Call static method
        $this.UserName = [Employee]::GetNewUserName($FirstName, $Lastname)
        #Call to static property
        $this.OU = "OU=Employees,OU=USR,OU=GBL,OU=USA," + [employee]::DomainName
    }
}

$newFullTime = [FullTime]::New('Sean', 'Connealy')
$newConsultant = [Consultant]::New('Test', 'UserTwo')

$newFullTime.Create()
$newConsultant.Create()

$newFullTime.AddToBaseGroups()
$newConsultant.AddToBaseGroups()

[System.Enum]::GetValues([EmployeeType])

$newFullTime