Function Update-ADUsers {
<#
      .SYNOPSIS
      Update-ADUsers is a PowerShell function that updates Active Directory users with information in a CSV file. 	
      .DESCRIPTION
      Update-ADUsers is a PowerShell function that updates Active Directory users with information in a CSV file
      The function has full error logging, and onscreen information display informing what task it is performing
      at any point in time.
      .PARAMETER ADServer
      Specifies the Domain Controler to query. This is required in W2K3 Domains where one DC
      has Active Directory web services installed. 
      .PARAMETER Credential
      Specifies credential that runs the Update-ADUsers. This account MUST have write permission
      to Active Directory. 
      .PARAMETER  CSVPath
      Specifies the CSV containing the user info. This must be specified with the full path to the 
      CSV file (Including the extension, .CSV. I have attached a sample CSV file with examples
      of fields populated. 
      .EXAMPLE
      To update user's from a CSV file called User_Info.csv:
      PS Z:\> Update-ADUsers -CSVPath C:\CSV\User_Info.csv -Credential 70411lab\admin -ADServer servername
#>

  [CmdletBinding(DefaultParameterSetName = 'CSVPath')]
  Param
  (
    [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'CSVPath')]
    [ValidateNotNullOrEmpty()]
    [String]$CSVPath
  )

  Begin {
    # Get script Start Time (used to measure run time)
    $startDTM = (Get-Date)
    #Define script path
    $Scriptpath = (Split-Path -Path $script:MyInvocation.MyCommand.Path) + '\'
    $logpath = $Scriptpath + '\Errorlogs'
    if (!(Test-Path $logpath)) {
      $null = New-Item -ItemType Directory -Path $logpath
    } #Out-Null suppreses console info

    $Logfiletime = (Get-Date).ToString('dd-MM-yyyy')
    $logfile = $logpath + "\logfile_$Logfiletime.txt"
    $datestamp = ((Get-Date).ToString('dd-MM-yyyy(hh:mm:ss)'))
    '' | Out-File $logfile -Append #appends a space on top each time for easy reading
    'Update-ADUsers errors logged ' + $datestamp + ': ' | Out-File $logfile -Append
    '---------------------------------------------------' | Out-File $logfile -Append #appends a line beneath each log stamp for easy reading
    #Test that the specified csv file is valid before inporting it, else throw an error and quit
    if ((Get-ChildItem $CSVPath).Extension -eq '.csv') {
      $csvfile = Import-Csv -Path $CSVPath
    }
    else {
      Write-Host -Object 'The specified file is not a valid CSV file, please check your file and try again' -ForegroundColor Red
      'The specified file is not a valid CSV file, please check your file and try again' | Out-File $logfile -Append
      break
    }
    Write-Host -Object 'Importing Active Directory Modules and performing pre-tasks...' -ForegroundColor Red
    #import the ActiveDirectory Module
    Import-Module -Name ActiveDirectory -WarningAction SilentlyContinue

  }

  process {
    Write-Host -Object 'Users update in progress, this might take some time, please wait' -ForegroundColor Magenta
    $csvfile |
      ForEach-Object -Process {
      $GivenName      = $_.'First Name'
      $Surname        = $_.'Last Name'
      $StreetAddress  = $_.'Full address'
      $SamAccountName = $_.UserName
      $City           = $_.City
      $State          = $_.State
      $PostCode       = $_.'Post Code'
      $Country        = $_.'Country/Region'
      $Title          = $_.'Job Title'
      $Company        = $_.Company
      $Description    = $_.Description
      $Department     = $_.Department
      $Office         = $_.Office
      $Phone          = $_.Phone
      $Mail           = $_.Email
      $Manager        = $_.Manager
      #This script below is useful because some domains may not have
      #a uniform way of displaying DisplayNames. Some users may have
      #display name as 'Lastname FirstName', others may have it as 
      #'FirstNameLastname'. Below I have split the $Manager name into
      #$ManagerFirstname and $ManagerLastname
      if ($Manager) {
        $ManagerFirstname = $Manager.Split('')[0]
        $ManagerLastname = $Manager.Split('')[-1]
        #Then create different possible combinations to use in the $ManagerDN Search
        $ManagerDN1 = "$ManagerFirstname" + "$ManagerLastname"
        $ManagerDN2 = "$ManagerLastname" + " $ManagerFirstname"
        $ManagerDN3 = "$ManagerLastname" + "$ManagerFirstname"
        #Convert names to lower case. Appears to be case sensitive
        $ManagerLC = $Manager.ToLower()
        $ManagerDNLC1 = $ManagerDN1.ToLower()
        $ManagerDNLC2 = $ManagerDN2.ToLower()
        $ManagerDNLC3 = $ManagerDN3.ToLower()
      }
      #Included the If clause below to ignore execution if the $Manager variable
      #from the csv is blank. Avoids throwing errors and saves execution time
      #Used different possible displaynames to search for a managername
      $ManagerDN = if ($Manager) {
        (Get-ADUser -Filter `
          {
            (Name -like $Manager) -or (Name -like $ManagerDN1) -or (Name -like $ManagerDN2) `
              -or (Name -like $ManagerDN3) -or (Name -like $ManagerLC) -or (Name -like $ManagerDNLC1) `
              -or (Name -like $ManagerDNLC2) -or (Name -like $ManagerDNLC3)
          }).DistinguishedName
      } #Manager required in DN format

      #Import country codes and convert country to codes 
      #for use in $Country
      #TODO: Update to use json file
      $Countrycsvfile = $Scriptpath + '\Country_Codes.csv'
      Import-Csv -Path $Countrycsvfile |

      ForEach-Object -Process {
        $CountryName = $_.'Country Name'
        $CountryCode = $_.Codes

        if ($Country -eq "$CountryName") {
          $Country = "$CountryCode"
        }
      }

      #Check whether $SamAccountName exisits in Active Directory.
      try {
        $SamAccountNameExists = (Get-ADUser -Identity $SamAccountName -ErrorAction SilentlyContinue).SamAccountName
      }
      catch {
        #TODO: SamAccountName does not exist is AD, LOG this
      }
      # Execute set-aduser below only if $SamAccountName is in AD and also is in the Csv file, else ignore
      if ($SamAccountNameExists -eq $SamAccountName -and $null -ne $SamAccountNameExists) {

        if ($GivenName) {
          Set-ADUser -Identity $SamAccountName -Replace @{ givenname = $GivenName }
        }
        if ($Surname) {
          Set-ADUser -Identity $SamAccountName -Replace @{ sn = $Surname }
        }
        if ($StreetAddress) {
          Set-ADUser -Identity $SamAccountName -Replace @{ StreetAddress = $StreetAddress }
        }
        if ($City ) {
          Set-ADUser -Identity $SamAccountName -Replace @{ l = $City }
        }
        if ($State) {
          Set-ADUser -Identity $SamAccountName -State $State
        }
        if ($PostCode) {
          Set-ADUser -Identity $SamAccountName -Replace @{ postalCode = $PostCode }
        }
        #Country did not accept the -Replace switch. It works with the -Country switch
        if ($Country) {
          Set-ADUser -Identity $SamAccountName -Country $Country
        }
        if ($Title) {
          Set-ADUser -Identity $SamAccountName -Replace @{ Title = $Title }
        }
        if ($Company ) {
          Set-ADUser -Identity $SamAccountName -Replace @{ Company = $Company }
        }
        if ($Description ) {
          Set-ADUser -Identity $SamAccountName -Replace @{ Description = $Description }
        }
        if ($Department) {
          Set-ADUser -Identity $SamAccountName -Replace @{ Department = $Department }
        }
        if ($Office) {
          Set-ADUser -Identity $SamAccountName -Replace @{ physicalDeliveryOfficeName = $Office }
        }
        if ($Phone) {
          Set-ADUser -Identity $SamAccountName -Replace @{ telephoneNumber = $Phone }
        }
        if ($Mail) {
          Set-ADUser -Identity $SamAccountName -Replace @{ mail = $Mail }
        }
        #Manager did not accept the -Replace switch. It works with the -manager switch
        if ($Manager -and $ManagerDN) {
          Set-ADUser -Identity $SamAccountName -Manager $ManagerDN
        }
      }
      else
      {
        #TODO: Log error for users that are not in Active Directory or with no Logon name in excel file
      }
    }
  }
  End {
    #The lines below calculates how long
    #it takes to run this script
    # Get End Time
    $endDTM = (Get-Date)
    #TODO: Add this to log, and console
    Write-Host 'Completed, total run time is'$(($endDTM - $startDTM).totalminutes) minutes". Check log file for errors and information" -ForegroundColor Cyan
  }
}