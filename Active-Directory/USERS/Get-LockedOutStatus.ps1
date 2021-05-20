﻿<#
  Author:   Matt Schmitt
  Date:     12/4/12 
  Version:  2.0 
  From:     USA 
  Email:    ithink2020@gmail.com 
  Website:  http://about.me/schmittmatt
  Twitter:  @MatthewASchmitt
  
  Description
  A script checking for Locked Account, checking where a user is locked out, unlocking the user's account and for resetting a user's password.  
  
  UPDATED 12/4/12
    Cleaned up Checking LockedOut Status code - replaced with foreach statement that looks at $Servers array
    Cleaned up Unlock code - replaced with foreach statement that looks at $Servers array
    Cleaned up Get pwdlastset date - rewrote to use the method I was using for other lookups for AD properties.

#>


Import-Module ActiveDirectory
Clear-Host
#Assing Domain Controllers to $servers Array
$servers = Get-QADComputer -ComputerRole DomainController |Select-Object -ExpandProperty DnsName

#Counts how many locked account there are on the local DC and sets it to $count
$count = Search-ADAccount –LockedOut | Where-Object { $_.Name -ne 'Administrator' -and $_.Name -ne 'Guest' } | Measure-Object | Select-Object -expand Count

#If there are locked accounts (other than Administrator and Guest), then this will display who is locked out.
If ( $count -gt 0 ) {

    Write-Host 'Current Locked Out Accounts on LOCAL Domain Controller:'
    Get-QADUser -Locked | Where-Object { 
        $_.Name -ne 'Administrator' -and $_.Name -ne 'Guest' } | 
            Select-Object Name, `
                @{Expression={$_.SamAccountName};Label='Username'}, `
                @{Expression={$_.physicalDeliveryOfficeName};Label='Office Location'}, `
                @{Expression={$_.TelephoneNumber};Label='Phone Number'}, `
                @{Expression={$_.LastLogonDate};Label='Last Logon Date'}  | Format-Table -AutoSize
}else{
    Write-Host 'There are no locked out accounts on LOCAL Domain Controller.'
}

Write-Host ''

#Asks for the username
$user = Read-Host 'Enter username of the employee you would like to check or [ Ctrl+c ] to exit'

Clear-Host 

Write-Host ''
Write-Host ''

$Name = (Get-ADUser -Filter {samAccountName -eq $user } -Properties * | Select-Object -expand DisplayName)
$phone = (Get-ADUser -Filter {samAccountName -eq $user } -Properties * | Select-Object -expand telephoneNumber)

Write-Host "$Name's phone number is:  $phone"

Write-Host ''
Write-Host ''


[datetime]$today = (get-date)

#Get pwdlastset date from AD and set it to $passdate
$passdate2 = [datetime]::fromfiletime((Get-ADUser -Filter {samAccountName -eq $user } -Properties * | Select-Object -expand pwdlastset))

#Write-Host "passdate2: $passdate2"

$PwdAge = ($today - $passdate2).Days

If ($PwdAge -gt 90){
    Write-Host "Password for $user is EXPIRED!"
    Write-Host "Password for $user is  $PwdAge days old."
}else{
    Write-Host "Password for $user is $PwdAge days old."
}

Write-Host ''
Write-Host ''
Write-Host 'Checking LockedOut Status on U.S. Domain Controllers:'

#Get Lockedout status and set it to $Lock
foreach ($object in $servers) {

    switch (Get-ADUser -server $object -Filter {samAccountName -eq $user } -Properties * | Select-Object -expand lockedout) { 
    
        'False' {"$object `t `t Not Locked"} 
        
        'True' {"$object `t `t LOCKED"}
   
    }
}


Write-Host ''
Write-Host ''


[int]$y = 0


$option = Read-Host  "Would you like to (1) Unlock user, (2) Reset user's password, (3) Unlock and reset user's password or (4) Exit?"

Clear-Host

While ($y -eq 0) {
    
    switch ($option)
    {
        '1' { 


                foreach ($object in $servers) {
                    
                    Write-Host "Unlocking account on $object"
                    Unlock-ADAccount -Identity $user -server $object

                }         
                                
                
                
                #Get Lockedout status and set it to $Lock
                $Lock = (Get-ADUser -Filter {samAccountName -eq $user } -Properties * | Select-Object -expand lockedout)

                Write-Host ''

                #Depending on Status, tell user if the account is locked or not.
                switch ($Lock)
                {
                    'False' { Write-Host "$user is unlocked." }
                    'True' { Write-Host "$user is LOCKED Out." }
                }                
                
            
                Write-Host ''
                Write-Host 'Press any key to Exit.'
                
                $y += 5
                
                $x = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
                
            
            }
        '2' { 
                
                $newpass = (Read-Host -AsSecureString "Enter user's New Password")
                
                
                Write-Host ''
                Write-Host 'Resetting Password on Local DC'
                Write-Host ''
                Set-ADAccountPassword -Identity $user -NewPassword $newpass
                
                Write-Host ''
                Write-Host 'Resetting Password on CORPDC01'
                Write-Host ''
                Set-ADAccountPassword -Server CORPDC01.intranet.theknot.com -Identity $user -NewPassword $newpass
                             
                           
                Write-Host ''
                Write-Host 'Press any key to Exit.'
                $x = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
                
                $y += 5
    
            }
        '3' {
    
                $newpass = (Read-Host -AsSecureString "Enter user's New Password")
                
                Write-Host ''
                Write-Host 'Resetting Password on Local DC...'
                Write-Host ''
                Set-ADAccountPassword -Identity $user -NewPassword $newpass
                
                Write-Host ''
                Write-Host 'Resetting Password on CORPDC01 - for faster replication...'
                Write-Host ''
                Set-ADAccountPassword -Server CORPDC01.intranet.theknot.com -Identity $user -NewPassword $newpass
                
                Write-Host ''
                Write-Host "Password for $user has been reset."
                Write-Host ''
                
                
                
                foreach ($object in $servers) {
                    
                    Write-Host "Unlocking account on $object"
                    Unlock-ADAccount -Identity $user -server $object

                }                

                
                #Get Lockedout status and set it to $Lock
                $Lock = (Get-ADUser -Filter {samAccountName -eq $user } -Properties * | Select-Object -expand lockedout)

                Write-Host ''

                #Depending on Status, tell user if the account is locked or not.
                switch ($Lock)
                {
                    'False' { Write-Host "$user is unlocked." }
                    'True' { Write-Host "$user is LOCKED Out." }
                }                
                
            
                Write-Host ''
                Write-Host 'Press any key to Exit.'

                
                $y += 5
                
                $x = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    
            }
        
        '4' {
    
                #exit code
                $y += 5
    
            }
            
        default {
                
                Write-Host 'You have entered and incorrect number.'
                Write-Host ''
                $option = Read-Host  "Would you like to (1) Unlock user, (2) Reset user's password, (3) Unlock and reset user's password or (4) Exit?"
        
            }
    }
}