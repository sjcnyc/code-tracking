#requires -Modules ActiveDirectory
#Requires -Version 2
Function Get-LockedOutLocation
{
  [CmdletBinding()]

  Param(
    [Parameter(Mandatory = $True)]
    [String]$Identity      
  )

  Begin
  { 
    $DCCounter = 0 
    $LockedOutStats = @()   
                
    Try
    {Import-Module -Name ActiveDirectory -ErrorAction Stop}
    Catch
    {
      Write-Warning -Message $_
      Break
    }
  }#end begin
  Process
  {
        
    #Get all domain controllers in domain
    $DomainControllers = Get-ADDomainController -Filter *                                                                      
                                                                                                                
    $PDCEmulator = ($DomainControllers | Where-Object -FilterScript {$_.OperationMasterRoles -contains 'PDCEmulator'})
        
    Write-Verbose -Message 'Finding the domain controllers in the domain'
    Foreach($DC in $DomainControllers)
    {
      $DCCounter++
      Write-Progress -Activity 'Contacting DCs for lockout info' -Status "Querying $($DC.hostname)" -PercentComplete (($DCCounter/$DomainControllers.Count) * 100)
      Try
      {$UserInfo = Get-ADUser -Identity $Identity  -Server $DC.hostname -Properties AccountLockoutTime, LastBadPasswordAttempt, BadPwdCount, LockedOut -ErrorAction Stop}
      Catch
      {
        Write-Warning -Message $_
        Continue
      }
      If($UserInfo.LastBadPasswordAttempt)
      {
    
        $LockedOutStats += New-Object -TypeName PSObject -Property @{
          Name                   = $UserInfo.SamAccountName
          SID                    = $UserInfo.SID.Value
          LockedOut              = $UserInfo.LockedOut
          BadPwdCount            = $UserInfo.BadPwdCount
          BadPasswordTime        = $UserInfo.BadPasswordTime            
          DomainController       = $DC.Hostname
          AccountLockoutTime     = $UserInfo.AccountLockoutTime
          LastBadPasswordAttempt = ($UserInfo.LastBadPasswordAttempt).ToLocalTime()
        }          
      }
    }
    $LockedOutStats | Format-Table -Property Name, LockedOut, DomainController, BadPwdCount, AccountLockoutTime, LastBadPasswordAttempt -AutoSize

    #Get User Info
    Try
    {  
      Write-Verbose -Message "Querying event log on $($DC.HostName)"
      $LockedOutEvents = Get-WinEvent -ComputerName $DC.HostName -FilterHashtable @{
        LogName = 'Security'
        Id      = 4740
      } -ErrorAction Stop | Sort-Object -Property TimeCreated -Descending
    }
    Catch 
    {          
      Write-Warning -Message $_
      Continue
    }   
                                 
    Foreach($Event in $LockedOutEvents)
    {            
      If($Event | Where-Object -FilterScript {$_.Properties[2].value -match $UserInfo.SID.Value})
      {
        $Event | Select-Object -Property @(
          @{
            Label      = 'User'
            Expression = {$_.Properties[0].Value}
          }
          @{
            Label      = 'DomainController'
            Expression = {$_.MachineName}
          }
          @{
            Label      = 'EventId'
            Expression = {$_.Id}
          }
          @{
            Label      = 'LockedOutTimeStamp'
            Expression = {$_.TimeCreated}
          }
          @{
            Label      = 'Message'
            Expression = {$_.Message -split "`r" | Select-Object -First 1}
          }
          @{
            Label      = 'LockedOutLocation'
            Expression = {$_.Properties[1].Value}
          }
        )
      }
    }       
  }
}