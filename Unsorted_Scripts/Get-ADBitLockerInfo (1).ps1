

<#
.Synopsis
 Generates a CSV file with all BitLocker Information in your Active Directory with computer names and BitLocker Recovery Keys.
 Recommendation is to run this script as a schedule task in weekly basis to have backup of your BitLocker Recovery keys in case you are backing up your BitLocker information in AD.


.Description
 Generates a CSV file with all BitLocker Information in your Active Directory with computer names and BitLocker Recovery Keys.
 Recommendation is to run this script as a schedule task in weekly basis to have backup of your BitLocker Recovery keys in case you are backing up your BitLocker information in AD.

 Requirement of the script:
    - Import Active Directory PowerShell Module
    - Install and import "Quest Active Directory PowerShell Extensions"  http://www.quest.com/powershell/activeroles-server.aspx



.PARAMETER OU
Optional Parameter to narrow the scope of the script.


.PARAMETER filepath
Required Parameter. Example is C:\ScriptsFolder


.EXAMPLE

 Collect information from the whole directory and save the output CSV file to C:\Scripts

.\Get-ADBitLockerInfo.ps1 $filepath C:\scripts



.EXAMPLE

 Collect information from the whole directory and save the output CSV file current directory

.\Get-ADBitLockerInfo.ps1 $filepath .\



.EXAMPLE

 Collect information from computers under a certain AD Organizational Unit (OU), and save the output CSV file to C:\Scripts

.\Get-ADBitLockerInfo.ps1 $filepath C:\scripts -OrganizationalUnit "OU=LON,DC=CONTOSO,DC=COM"





.Notes
Script Name     : Get-ADBitLockerInfo
Description     : Export BitLcoker Recovery Key from AD to CSV
Last Updated    : May, 5 2014
Version         : 3.0
Author          : Ammar Hasayen (@ammarhasayen)


.Link
http://ammarhasayen.com

#>

[cmdletbinding()]

    Param(

    [Parameter(Mandatory=$false, HelpMessage="Enter OU, example: ou=sales,dc=contoso,dc=com", ValueFromPipelineByPropertyName=$true)]    
    [string]$OU,
     [Parameter(Mandatory=$true, HelpMessage="Enter path for csv file, example: c:\ ", ValueFromPipelineByPropertyName=$false)]    
    [string]$filepath
    )


    Begin {

            Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"  

            Write-verbose -Message ($PSBoundParameters | out-string)

             

            #region internal functions
                
                
                function Get-CorpSnapin {

                        param($name)

                         $Mysnapin = Get-PSSnapin | where{$_.name -like $name}

                         if (-not($Mysnapin)) {

                                    $var = $ErrorActionPreference

                                    $ErrorActionPreference = "Stop"

                                    try {
                                        Add-PSSnapin $name
                                        Write-Verbose -Message "Snapin added "
                                        write-output $true

                                    }catch {                
                                        Write-Verbose -Message "Snapin error importing "

                                        write-output $false
                                    }finally {

                                        $ErrorActionPreference = $var
                                    }

                         } else {

                            Write-Verbose -Message "Snapin already loaded "
                            write-output $true  
                         }                                         



                } #  function Get-CorpSnapin 
                
                
                function _screenheadings {

                        Cls
                        write-host 
                        write-host 
                        write-host 
                        write-host "--------------------------" 
                        write-host "Script Info" -foreground Green
                        write-host "--------------------------"
                        write-host
                        write-host " Script Name : Backup BitLocker AD Information to CSV (Get-ADBitLockerInfo)"  -ForegroundColor White
                        write-host " Author      : Ammar Hasayen @ammarhasayen" -ForegroundColor White                       
                        write-host " Version     : 3.0"   -ForegroundColor White
                        write-host
                        write-host "--------------------------" 
                        write-host "Script Release Notes" -foreground Green
                        write-host "--------------------------"
                        write-host
                        write-host "-Account Requirements" -ForegroundColor Yellow 
                        write-host "   1. Active Directory Module should be available on this machine"
                        write-host "   2. Install and import Quest Active Directory PowerShell Extensions"  
                        write-host "          http://www.quest.com/powershell/activeroles-server.aspx " 
                        write-host
                        write-host "-ALWAYS CHECK FOR NEWER VERSION @" -NoNewline
                        Write-Host " http://ammarhasayen.com"  -ForegroundColor Red
                        write-host  
                        write-host "--------------------------" 
                        write-host "Script Start" -foreground Green
                        write-host "--------------------------"
                        Write-Host
            
                } # function _screenheadings                
                
                function get-timestamp {

                   get-date -format 'yyyy-MM-dd HH:mm:ss'

                 } # function get-timestamp

                function Get-CorpModule {

                            <#.Synopsis
                            Imports a module if not imported.

                            .DESCRIPTION
                            Imports a module if not imported.



                            Versioning:
                                - Version 1.0 written 24  November 2013 : First version
    



                            .PARAMETER Name
                            string representing module name

                            .EXAMPLE
                            PS C:\> Get-CorpModule  -name ActiveDirectory


                            .Notes
                            Last Updated             : Nov 24, 2013
                            Version                  : 1.0 
                            Author                   : Ammar Hasayen (Twitter @ammarhasayen)
                            Email                    : me@ammarhasayen.com
                            based on                 : 

                            .Link
                            http://ammarhasayen.com


                            .INPUTS
                            string

                            .OUTPUTS
                            CIMInstance


                            #>

                                [cmdletbinding()]
    


                                Param(

                                    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true,ValueFromPipeline = $true)]
                                    [string]$name
    
                                )

                                Begin {
            

                                        # Function Get-CorpModule BEGIN Section

                                        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"  

                                        Write-verbose -Message ($PSBoundParameters | out-string)



                                } # Function Get-CorpModule BEGIN Section



                                Process {

                                        # Function Get-CorpModule PROCESS Section

                                        if (-not(Get-Module -name $name)) {

                                            if (Get-Module -ListAvailable | Where-Object { $_.name -eq $name }) { 
                 
                                                Import-Module -Name $name 

                                                Write-Verbose -Message "module finished importing "

                                                write-output $true 

                                             } #end if module available then import 

                                            else { # module not available 

                                                Write-Verbose -Message "module not available "

                                                write-output $false 

                                            } # module not available 


                                        } # end if not module 

                                        else { # module already loaded 

                                            Write-Verbose -Message "module already loaded "

                                            write-output $true 
                                        } 



                                } # Function Get-CorpModule PROCESS Section


                                End {
                                        # Function END Section
            
                                         Write-Verbose -Message "Function Get-CorpModule  Ends"
         
                         
           

                                } # Function Get-CorpModule END Section


                            } # Function Get-CorpModule 

                function Write-CorpError {
            
                                [cmdletbinding()]

                                param(
                                    [parameter(Position=0,Mandatory=$true,ValueFromPipeline=$false,HelpMessage='Error Variable')]$myError,	
	                                [parameter(Position=1,Mandatory=$false,ValueFromPipeline=$false,HelpMessage='Additional Info')][string]$Info,
                                    [parameter(Position=2,Mandatory=$false,ValueFromPipeline=$false,HelpMessage='Log file full path')][string]$mypath,
	                                [switch]$ViewOnly

                                    )

                                    Begin {
       
                                        function get-timestamp {

                                            get-date -format 'yyyy-MM-dd HH:mm:ss'
                                        } 

                                    } #Begin

                                    Process {

                                        if (!$mypath) {

                                            $mypath = " "
                                        }

                                        if($myError.InvocationInfo.Line) {

                                        $ErrorLine = ($myError.InvocationInfo.Line.Trim())

                                        } else {

                                        $ErrorLine = " "
                                        }

                                        if($ViewOnly) {

Write-warning @"                          
$(get-timestamp): $('-' * 40)
$(get-timestamp):   Error Report
$(get-timestamp): $('-' * 20)
$(get-timestamp):
$(get-timestamp): Error in $($myError.InvocationInfo.ScriptName).
$(get-timestamp):
$(get-timestamp): $('-' * 20)       
$(get-timestamp):
$(get-timestamp): Line Number: $($myError.InvocationInfo.ScriptLineNumber)
$(get-timestamp): Offset : $($myError.InvocationInfo.OffsetLine)
$(get-timestamp): Command: $($myError.invocationInfo.MyCommand)
$(get-timestamp): Line: $ErrorLine
$(get-timestamp): Error Details: $($myError)
$(get-timestamp): Error Details: $($myError.InvocationInfo)
"@

                                            if($Info) {
                                                Write-Warning -Message "More Custom Info: $info"
                                            }

                                            if ($myError.Exception.InnerException) {

                                                Write-Warning -Message "Error Inner Exception: $($myError.Exception.InnerException.Message)"
                                            }

                                            Write-warning -Message " $('-' * 40)"

                                         } #if($ViewOnly) 

                                         else {
                                         # if not view only 
        
                                            Log-Write -LogFullPath $mypath -LineValue "$(get-timestamp)"
                                            Log-Write -LogFullPath $mypath -LineValue "$(get-timestamp)"
                                            Log-Write -LogFullPath $mypath -LineValue "$(get-timestamp): $('-' * 60)"
                                            Log-Write -LogFullPath $mypath -LineValue "$(get-timestamp):  Error Report"        
                                            Log-Write -LogFullPath $mypath -LineValue "$(get-timestamp):"
                                            Log-Write -LogFullPath $mypath -LineValue "$(get-timestamp): Error in $($myError.InvocationInfo.ScriptName)."        
                                            Log-Write -LogFullPath $mypath -LineValue "$(get-timestamp):"
                                            Log-Write -LogFullPath $mypath -LineValue "$(get-timestamp): Line Number: $($myError.InvocationInfo.ScriptLineNumber)"
                                            Log-Write -LogFullPath $mypath -LineValue "$(get-timestamp): Offset : $($myError.InvocationInfo.OffsetLine)"
                                            Log-Write -LogFullPath $mypath -LineValue "$(get-timestamp): Command: $($myError.invocationInfo.MyCommand)"
                                            Log-Write -LogFullPath $mypath -LineValue "$(get-timestamp): Line: $ErrorLine"
                                            Log-Write -LogFullPath $mypath -LineValue "$(get-timestamp): Error Details: $($myError)"
                                            Log-Write -LogFullPath $mypath -LineValue "$(get-timestamp): Error Details: $($myError.InvocationInfo)"
                                            if($Info) {
                                                Log-Write -LogFullPath $mypath -LineValue  "$(get-timestamp): More Custom Info: $info"
                                            }

                                            if ($myError.Exception.InnerException) {

                                                Log-Write -LogFullPath $mypath -LineValue  "$(get-timestamp) :Error Inner Exception: $($myError.Exception.InnerException.Message)"
            
                                            }    

                                         }# if not view only

                                   } # End Process

                            } # function Write-CorpError


            #endregion internal functions


            _screenheadings
            #region CV File

                Write-Host "Checking File Path....."
                Write-Host ""

                 $var = $ErrorActionPreference
                 $ErrorActionPreference = "Stop"

                 try{
                    $filepath = Convert-Path $filepath -ErrorAction Stop
                }catch {
                    Write-Warning -Message " Sorry, please check the sript path name again"
                    Write-Warning -Message ""
                    Write-Warning -Message ""
                    Write-CorpError -myError $_ -ViewOnly -Info " Sorry, please check the sript path name again"
                    Exit
                    throw "Sorry, please check the sript path name again "
                }finally{
                    $ErrorActionPreference = $var
                }


                $fileName = "BitLocker_$(Get-Date -f 'yyyy-MM-dd').csv"

                $csv = Join-Path $filepath $fileName

            #endregion         


             
            #region Import AD Module

                Write-Host "Checking Active Directory PowerShell Module...."
                Write-Host ""

                If( !(Get-CorpModule ActiveDirectory) ) {

                    Write-Warning -Message " OPS, please make sure you have the ActiveDirectory PowerShell Module available on this machine"                    
                    Write-Warning -Message " Exiting the script...."
                    Write-Warning -Message ""
                    Exit
                    Throw " Hi, please make sure you have the ActiveDirectory PowerShell Module available on this machine"


                }


            #endregion Import AD Module


            #region import Quest AD PowerShell Snapin
                    
                    Write-Host "Checking Quest PowerShell AD SnapIn...."
                    Write-Host ""
                    
                    if(-not (Get-CorpSnapin -name "Quest.ActiveRoles.ADManagement")) {
                        Write-Warning " OPS, please make sure you have the Quest PowerShell Snaping is installed on this machine"
                        Write-Warning " Exiting the script...."
                        Write-Warning -Message ""
                        Exit
                        Throw " OPS, please make sure you have the Quest PowerShell Snaping is installed on this machine"                  
                    
                    
                    }

                

            #endregion


            #region variables

             
                $export  = @()

            #endregion variables


    } #Begin Block

    Process {
              
              Write-Host " Getting BitLocker Info"

             if ($PSBoundParameters.ContainsKey("OU")){
                    
                    $var= $ErrorActionPreference
                    $ErrorActionPreference = "Stop"

                        try{
                            $objects =@(Get-QADObject -LdapFilter '(objectcategory=msFVE-RecoveryInformation)' -OrganizationalUnit $OU -SizeLimit 0 -IncludedProperties cn,name,type,msFVE-RecoveryGuid,msFVE-RecoveryPassword,ParentContainer,instanceType,objectCategory,objectClass)
                        }catch{
                            write-host
                            write-host 
                            Write-Host " OPS !!! Your OU Filter seems wrong... Try again, Example is : ""OU=Workstaions,OU=NYC,DC=Contoso,DC=COM""" -foreground Red
                            write-host 
                            write-host
                            Exit
                            Throw " Ops, make sure that your OU Filter is working fine : Get-QADObject -LdapFilter '(objectcategory=msFVE-RecoveryInformation)' -organizationlUnit $OU"
                        }finally{
                            $ErrorActionPreference = $var
                        }
             }

             else {
                    $objects = @(Get-QADObject -LdapFilter '(objectcategory=msFVE-RecoveryInformation)' -SizeLimit 0 -IncludedProperties cn,name,type,msFVE-RecoveryGuid,msFVE-RecoveryPassword,ParentContainer,instanceType,objectCategory,objectClass)

             }



             Write-Host " Number of BitLocker items detected is $($objects.count)" -foreground Yellow

             If ( -not($objects.count)) {

                write-host 
                write-host 
                Write-Host " OPS !!! No BitLocker Information is available in AD.. Check again" -foreground Red
                write-host 
                write-host 
                write-host 
                write-host "--------------------------" 
                write-host "Script Ends" -foreground Green
                write-host "--------------------------"  
                Exit
             }

             else {

                     foreach ($object in $objects) {
                
                         #Getting computer name from the Object Parent Computer
                        $computer_name = (Split-Path -Path $object.ParentContainer -Leaf)
                        
                        $RecoveryPass = "msFVE-RecoveryPassword"
                        $RecoveryGuid = "msFVE-RecoveryGuid"   

                        $info = New-Object -TypeName psobject 
                        $info | Add-Member -MemberType NoteProperty -Name Child_Object -Value $object.Name 
                        $info | Add-Member -MemberType NoteProperty -Name Computer_Name -Value $computer_Name
                        $info | Add-Member -MemberType NoteProperty -Name RecoveryGUID -Value $object.$RecoveryGuid 
                        $info | Add-Member -MemberType NoteProperty -Name RecoveryPassword -Value $object.$Recoverypass
                        $info | Add-Member -MemberType NoteProperty -Name cn -Value $object.cn
                        $info | Add-Member -MemberType NoteProperty -Name ObjectCategory -Value $object.objectCategory
                        $info | Add-Member -MemberType NoteProperty -Name ObjectClass -Value $object.objectClass

                        $export+=$info

                     } #foreach


                     #region generate output

                        $var= $ErrorActionPreference
                        $ErrorActionPreference = "Stop"
                         try{
                            $export | export-csv -NoTypeInformation -Path $csv
                            
                         }catch{
                             write-warning "Ops.. cannot export the output CSV to $csv.."
                             Write-warning " EXiting script..."
                             Write-Warning -Message ""
                             Write-Warning -Message ""
                             Write-CorpError -myError $_ -ViewOnly
                             exit
                             throw "Ops.. cannot export the output CSV to $csv.."
                         }finally{
                            $ErrorActionPreference = $var
                         }
                     #endregion generate output

             } #else


           

    } #Process Block

    End {
                        write-host 
                        write-host 
                        Write-Host " Success !!! CSV File is exported to $csv" -foreground Cyan
                        write-host 
                        write-host 
                        write-host 
                        write-host "--------------------------" 
                        write-host "Script Ends" -foreground Green
                        write-host "--------------------------"   


    } #End Block


