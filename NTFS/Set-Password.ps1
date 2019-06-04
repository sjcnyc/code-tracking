Function Set-Password {
    #requires -version 2.0 
 
    <# 
.Synopsis 
    Allows the changing of the local account password on a local or remote machine. 
.Description 
    Allows the changing of the local account password on a local or remote machine. 
.Parameter computer 
    Computer that the password will be changed on.  Supports a single computer or collection of computers and can be processed  
    through the pipeline. 
.Parameter user 
    Account that will have the password changed.     
.Example 
    Set-Password -computer 'server' -user 'Administrator' 
     
    User will be prompted to type in the password for Administrator prior to being changed on 'server'   
.Example 
    Set-Password -computer @('server','server2') -user 'Administrator' 
     
    User will be prompted to type in the password for Administrator prior to being changed on 'server' and 'server2' 
.Example 
    @('server','server2') | Set-Password -user 'Administrator' 
     
    User will be prompted to type in the password for Administrator prior to being changed on 'server' and 'server2'    
.Example 
    Set-Password -computer (Get-Content hosts.txt) -user 'Administrator' 
     
    User will be prompted to type in the password for Administrator prior to being changed on 'server' and 'server2'        
         
.Inputs 
    None 
.Outputs 
    None 
.Link 
   http://boeprox.wordpress.com 
 
.Notes 
 NAME:      Set-Password 
 VERSION:   1.0 
 AUTHOR:    Boe Prox 
 Date:      26 August 2010 
 
#> 
 
    [CmdletBinding( 
        SupportsShouldProcess = $True, 
        ConfirmImpact = 'low', 
        DefaultParameterSetName = 'server' 
    )] 
    Param (     
        [Parameter( 
            ValueFromPipeline = $True, 
            Position = 0, 
            Mandatory = $True, 
            HelpMessage = "List of servers")] 
        [ValidateNotNullOrEmpty()] 
        [array]$computer, 
        [Parameter( 
            ValueFromPipeline = $False, 
            Position = 1, 
            Mandatory = $True, 
            HelpMessage = "Account to change password")] 
        [ValidateNotNullOrEmpty()] 
        [string]$user     
    ) 
    Begin { 
        Write-Verbose "Building container for report" 
        $arrlist = @() 
        Write-Verbose "Prompting for password" 
        $password = Read-Host "Type password -- VERIFY BEFORE CLICKING RETURN!!!" 
        Write-Verbose "Checking for existence of error log and clearing contents" 
        $errorlog = "passwordchangeerrors.txt" 
        If ([system.io.file]::exists($errorlog)) { 
            Clear-content $errorlog 
        } 
    } 
    Process { 
        #Iterate through computer list 
        ForEach ($c in $computer) { 
            $temp = New-Object PSobject 
            Try { 
                Write-Verbose "Testing Connection to $($c)" 
                Test-Connection -comp $c -count 1 -ea stop | out-null 
                #Verify account exists before attempting password change 
                Write-Verbose "Verifying that $($user) exists on $($computer)" 
                $colusers = ([ADSI]("WinNT://$c,computer")).children | ? {$_.psbase.schemaClassName -eq "User"} | Select -expand Name 
                If ($colusers -contains $user) { 
                    Write-Host -foregroundcolor Green "Changing password on $c..." 
                    $ErrorActionPreference = 'stop' 
                    Try { 
                        #Make connection to remote/local computer and user account 
                        $account = [adsi]("WinNT://" + $c + "/$user, user") 
                        #Change password on user account 
                        If ($pscmdlet.ShouldProcess($($user))) { 
                            $account.psbase.invoke("SetPassword", $password) 
                            $account.psbase.CommitChanges() 
                        } 
                        Write-Verbose "Adding information to report"     
                        $temp | Add-Member NoteProperty TimeStamp "$(get-date)"                    
                        $temp | Add-Member NoteProperty Server $c 
                        $temp | Add-Member NoteProperty Account $user 
                        $temp | Add-Member NoteProperty Status "Password Changed"     
                        $temp | Add-Member NoteProperty Notes "" 
                    } 
                    Catch { 
                        $errorflag = $True 
                        Write-Verbose "Writing errors to $($errorlog)" 
                        "$(get-date) :: Server:$($c) :: $($error[0].exception)" | Out-File -append $errorlog  
                        Write-Verbose "Adding information to report"          
                        $temp | Add-Member NoteProperty TimeStamp "$(get-date)"  
                        $temp | Add-Member NoteProperty Server $c 
                        $temp | Add-Member NoteProperty Account $user 
                        $temp | Add-Member NoteProperty Status "Error Changing Password" 
                        $temp | Add-Member NoteProperty Notes $error[0]                 
                    } 
                } 
                Else { 
                    $errorflag = $True 
                    Write-Verbose "Writing errors to $($errorlog)" 
                    "$(get-date) :: Server:$($c) :: $($user) does not exist!)" | Out-File -append  $errorlog 
                    Write-Verbose "Adding information to report"                    
                    $temp | Add-Member NoteProperty TimeStamp "$(get-date)"  
                    $temp | Add-Member NoteProperty Server $c 
                    $temp | Add-Member NoteProperty Account $user 
                    $temp | Add-Member NoteProperty Status "Unable to change password" 
                    $temp | Add-Member NoteProperty Notes  "Username does not exist"              
                }                                     
            } 
            Catch { 
                $errorflag = $True 
                Write-Verbose "Writing errors to $($errorlog)" 
                "$(get-date) :: Server:$($c) :: $($error[0].exception)" | Out-File -append  $errorlog 
                Write-Verbose "Adding information to report"            
                $temp | Add-Member NoteProperty TimeStamp "$(get-date)"             
                $temp | Add-Member NoteProperty Server $c 
                $temp | Add-Member NoteProperty Account $user 
                $temp | Add-Member NoteProperty Status "Error Connecting to computer" 
                $temp | Add-Member NoteProperty Notes $error[0] 
            }   
            Finally { 
                #Merge temp report with main report 
                Write-Verbose "Merging report" 
                $arrlist += $temp 
            }     
        } 
    } 
    End {   
        #Generate report to screen 
        Write-Verbose "Generating report"           
        $arrlist 
        If ($errorflag) { 
            Write-Host -fore Yellow "Errors were reported during run, please look at $($pwd)\$($errorlog) for more details." 
        } 
        Write-Verbose "Removing password from variable `$password"     
        $password = $Null         
    } 
}