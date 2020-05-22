function Get-LapsPassword {
  [CmdletBinding()]
  param (
    [parameter(ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true)]
    [string[]]$ComputerName = $env:COMPUTERNAME,
    [switch]$AsSecureString,
    [switch]$IncludeLocalAdministratorAccountName,
    [System.Management.Automation.PSCredential]$Credential = [System.Management.Automation.PSCredential]::Empty
  )

  begin {
  }
  process {
    $ErrorActionPreference = 'Stop'
    $LapsPasswordAttributeName = 'ms-Mcs-AdmPwd'

    foreach ($Computer in $ComputerName) {
      try {
        # Gather local administrator account information if specified
        if ($IncludeLocalAdministratorAccountName) {
          Write-Verbose -Message "Getting local administrator account information from $Computer"
          try {
            $getWmiObjectSplat = @{
                ComputerName = $Computer
                Class        = 'Win32_UserAccount'
                Filter       = "LocalAccount='True' And Sid like '%-500'"
                Credential   = $Credential
            }
            $LocalAdministratorAccount = $LocalAdministratorAccount = Get-WmiObject @getWmiObjectSplat
            $LocalAdministratorAccountName = $LocalAdministratorAccount.Name
          }
          catch [System.UnauthorizedAccessException] {
            Write-Warning -Message $_.Exception.Message
            $LocalAdministratorAccountName = '-ACCESS DENIED-'
          }
          catch {
            Write-Warning -Message $_.Exception.Message
            $LocalAdministratorAccountName = '-UNKNOWN-'
          }
        }
        # Gather LAPS password
        Write-Verbose -Message "Getting LAPS password information for $Computer"
        if ($null -ne $Credential.UserName) {
          $ADComputer = Get-ADComputer -Identity $Computer -Properties $LapsPasswordAttributeName -Credential $Credential
        }
        else {
          $ADComputer = Get-ADComputer -Identity $Computer -Properties $LapsPasswordAttributeName
        }
        if ($ADComputer.$LapsPasswordAttributeName) {
          if ($AsSecureString) {
            $LapsPassword = ConvertTo-SecureString -String $ADComputer.$LapsPasswordAttributeName -AsPlainText -Force
          }
          else {
            $LapsPassword = $ADComputer.$LapsPasswordAttributeName
          }
        }
        else {
          $LapsPassword = '-ACCESS DENIED-'
        }
        $LapsPasswordProperties = [ordered]@{
          ComputerName = $Computer
          LapsPassword = $LapsPassword
        }
        if ($IncludeLocalAdministratorAccountName) {
          $LapsPasswordProperties.Add('Username', $LocalAdministratorAccountName)
        }
        $LapsPassword = New-Object -TypeName PSCustomObject -Property $LapsPasswordProperties
        $LapsPassword
      }
      catch {
        Write-Error -Message $_.Exception.Message
      }
    }
  }
  end {
  }
}