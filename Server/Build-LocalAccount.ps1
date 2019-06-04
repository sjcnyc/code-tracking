Function New-LocalAccount {
  [CmdletBinding()]
  Param (
    [parameter(Mandatory=$true)][string]$user,
    [parameter(Mandatory=$false)][string]$computer,
    [parameter(Mandatory=$false)][string]$hostfile,
    [parameter(Mandatory=$false)][string]$log = 'log.csv'
  )
  
  $timestamp = get-date -f MM/dd/yyyy--hh:mm:ss
  $arrlist = @()
  $password = Read-Host 'Type password -- VERIFY BEFORE CLICKING RETURN!!!'
  
  If ($hostfile) {
    $computer = (Get-Content $hostfile)
  }
  
  $computers = $computer 
  
  ForEach ($Computer in $Computers) {
    Try {
      Test-Connection $computer -Count 1
    }
    Catch {
      Write-Warning "$($server): Unable to connect!"
      $list = '' | Select-Object Computer, Account, Status, TimeStamp
      $list.Account = $user
      $list.Computer = $computer
      $list.Status = 'Connection Timed Out'
      $list.TimeStamp = $timestamp
      $arrlist += $list
      
      Break
    }  
    
    Write-Host -foregroundcolor Green "Changing password on $computer..."
    
    Try {
      #Create User account
      $account = ([adsi]("WinNT://$computer")).Create('user',$user)
      
      #Set password on account
      $account.psbase.invoke('SetPassword', $password)
      
      #Commit the changes made
      $account.psbase.CommitChanges()
      
      #Set flag for password to not expire
      $ADS_UF_DONT_EXPIRE_PASSWD = 0x10000
      $account.userflags = $account.userflags[0] -bor $ADS_UF_DONT_EXPIRE_PASSWD
      
      #Set flag for not allow user to change password
      $ADS_UF_DO_NOT_ALLOW_PASSWD_CHANGE = 0x0040
      $account.userflags = $account.userflags[0] -bor $ADS_UF_DO_NOT_ALLOW_PASSWD_CHANGE
      
      #Commit the changes
      $account.psbase.CommitChanges()
      
      #Add account to Local Administrators group
      $localadmin = ([adsi]("WinNT://$computer/Administrators"))
      $localadmin.PSBase.Invoke('Add',$account.PSBase.Path)
      
      #Build the array for report
      $list = '' | Select-Object Computer, Account, Status, TimeStamp
      $list.Account = $user
      $list.Computer = $computer
      $list.Status = 'Account Created'
      $list.TimeStamp = $timestamp
      $arrlist += $list
    }
    Catch {
      Write-Warning "$($server): Unable to connect!"
      $list = '' | Select-Object Computer, Account, Status, TimeStamp
      $list.Account = $user
      $list.Computer = $computer
      $list.Status = "$_"
      $list.TimeStamp = $timestamp
      $arrlist += $list
      Break   
    }   
  }
  
  $arrlist | export-csv -NoTypeInformation $log
  Write-Host -foregroundcolor Green 'Finished!'
}