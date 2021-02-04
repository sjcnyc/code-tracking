Import-Module UniversalDashboard.Community

$Dashboard = New-UDDashboard -Title "Create New AD User" -Content {
  New-UDInput -Title "Create new user" -Content {
    New-UDInputField -Name "FirstName" -Placeholder "First Name" -Type "textbox"
    New-UDInputField -Name "LastName" -Placeholder "Last Name" -Type "textbox"
    New-UDInputField -Name "UserName" -Placeholder "Account Name" -Type "textbox"
    New-UDInputField -Name "Department" -Placeholder "Department" -Values "Tecnologia", "Recursos Humanos", "Contabilidade", "Marketing" -Type "select"
  } -Endpoint {
    param(
      [Parameter(Mandatory)]
      [string]$FirstName,
      [Parameter(Mandatory)]
      [string]$LastName,
      [Parameter(Mandatory)]
      [string]$UserName,
      [Parameter(Mandatory)]
      [ValidateSet("Tecnologia", "Recursos Humanos", "Contabilidade", "Marketing")]
      [string]$Department
    )

    $password = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 20 | ForEach-Object -Process { [char]$_ } )
    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force

    $NewAdUserParameters = @{
      GivenName             = $FirstName
      Surname               = $LastName
      Name                  = $UserName
      AccountPassword       = $securePassword
      Department            = $Department
      Enabled               = $true
      UserPrincipalName     = '{0}@{1}' -f $UserName, $((Get-ADDomain).DNSRoot)
      ChangePasswordAtLogon = $true
    }

    New-ADUser @NewAdUserParameters -WhatIf

    New-UDInputAction -Content {

      New-UDCard -Title "Temporary Password" -Text $Password
    }
  }
}
Start-UDDashboard -Dashboard $Dashboard -Port 8080