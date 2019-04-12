Function Get-FilesOlderThan { 
    [CmdletBinding()] 
    [OutputType([Object])]    
    param ( 
        [parameter(ValueFromPipeline=$true)] 
        [string[]] $Path = (Get-Location), 
        [parameter()] 
        [string[]] $Filter, 
        [parameter(Mandatory=$true)] 
        [ValidateSet('Seconds','Minutes','Hours','Days','Months','Years')] 
        [string] $PeriodName, 
        [parameter(Mandatory=$true)] 
        [int] $PeriodValue, 
        [parameter()] 
        [switch] $Recurse = $false 
    ) 
     
    process { 
         
        #If one of more of the paths specified does not exist generate an error   
        if ($(test-path $path) -eq $false) { 
            write-error "Cannot find the path: $path because it does not exist" 
        } 
         
        Else { 
         
            <#   
            If the recurse switch is not passed get all files in the specified directories older than the period specified, if no directory is specified then 
            the current working directory will be used. 
            #> 
            If ($recurse -eq $false) { 
         
                Get-ChildItem -Path $(Join-Path -Path $Path -ChildPath \*) -Include $Filter | 
                Where-Object { $_.LastWriteTime -lt $(get-date).('Add' + $PeriodName).Invoke(-$periodvalue) -and $_.psiscontainer -eq $false } | ` 
                #Loop through the results and create a hashtable containing the properties to be added to a custom object 
                ForEach-Object { 
                    $properties = @{  
                        Path = $_.Directory  
                        Name = $_.Name  
                        DateModified = $_.LastWriteTime } 
                    #Create and output the custom object      
                    New-Object PSObject -Property $properties | Select-Object Path,Name,DateModified  
                }                 
                   
            } #Close if clause on Recurse conditional 
         
            <#   
              If the recurse switch is passed get all files in the specified directories and all subfolders that are older than the period specified, if no directory 
              is specified then the current working directory will be used. 
            #>    
            Else { 
             
                Get-ChildItem  -Path $(Join-Path -Path $Path -ChildPath \*) -Include $Filter -recurse | 
                Where-Object { $_.LastWriteTime -lt $(get-date).('Add' + $PeriodName).Invoke(-$periodvalue) -and $_.psiscontainer -eq $false } | ` 
                #Loop through the results and create a hashtable containing the properties to be added to a custom object 
                ForEach-Object { 
                    $properties = @{  
                        Path = $_.Directory  
                        Name = $_.Name  
                        DateModified = $_.LastWriteTime } 
                    #Create and output the custom object      
                    New-Object PSObject -Property $properties | Select-Object Path,Name,DateModified  
                } 
 
            } #Close Else clause on recurse conditional        
        } #Close Else clause on Test-Path conditional 
     
    } #End Process block 
} #End Fuction