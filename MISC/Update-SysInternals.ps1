Workflow Update-SysInternals {
[cmdletbinding()]
Param(
[Parameter(Position = 0,Mandatory,HelpMessage = 'Enter a folder path')]
[Alias('Path')]
[string]$Destination,
[switch]$Passthru
)

Sequence {
    #Validate path
    Write-Verbose -Message "Validating destination path $Destination"  
   
    if (Test-Path -Path $Destination -DisplayName 'Testing Path') {

        Write-Verbose -Message "Destination $Destination already exists"
        
    } #if test-path
    else {
       
       #Create the folder
        Try {
            Write-Verbose -message "Creating $Destination"
            New-Item -Path $Destination -ItemType Directory -ErrorAction Stop -PSProgressMessage "Creating $Destination"
        }
        Catch {
            Write-Warning -Message "Failed to create $Destination. $($_.Exception.message)"
            #Can't create the folder so bail out
            Return
        }

    } #else
}

Sequence {
    #Verify there is webclient service installed
    Write-Verbose -Message 'Verifying WebClient service is available'
    Try {
        $test = Get-Service -Name Webclient -ErrorAction Stop -PSProgressMessage 'Getting Webclient service'
    }
    Catch {
        Write-Warning 'Could not find the WebClient service. Aborting.'
        #Bail out
        Return
    }

}

Sequence {
    #start the WebClient service if it is not running
    Write-Verbose -message 'Checking status of WebClient service'
    if ((Get-Service -name WebClient).Status -eq 'Stopped') {
         Write-Verbose -message 'Starting WebClient'
         Try {
            Start-Service -name WebClient -ErrorAction Stop -PSProgressMessage 'Starting WebClient'
            $workflow:Stopped = $True
         }
         Catch {
            Write-Warning "Failed to start WebClient service. $($_.exception.message)"
            #can't start service so bail out
            Return
         }
    }
    else {
        <#
         Define a variable to indicate service was already running
         so that we don't stop it. Making an assumption that the
         service is already running for a reason.
        #>
        Write-Verbose -Message 'Service is already running'
        $Workflow:Stopped = $False
    }

    Write-Verbose -Message (Get-Service -Name WebClient | Out-String)
   
}

Sequence {

    #get current files in destination
    Write-Verbose -message "Getting current listing of files from $Destination"
    $current = Get-Childitem -Path $Destination -File -DisplayName 'Getting current files'
    
    Write-Verbose -message 'Creating a list of online files'

    #dowload list of files
    $webfiles = Get-ChildItem -Path '\\live.sysinternals.com\tools' -file -DisplayName 'Getting online files' -PSProgressMessage '...this might take a little time'
    
    if (-NOT $webfiles) {
        Write-Warning 'No webfiles found'
        #if no online files found something went wrong so bail out.
        RETURN
    }
       
    Write-Verbose -Message "Found $($webfiles.count) online files"   

    #download files in parallel groups of 8
    Write-Verbose -message "Updating Sysinternals tools from \\live.sysinternals.com\tools to $destination"

    foreach -parallel -throttle 8 ($file in $current) {
        #get the web version
        Write-Verbose -Message "Testing $($file.Name)"
        
        $online = $($webfiles).Where({$_.name -eq $file.name})
        
        if ($online.LastWriteTime.date -gt $file.lastWriteTime.date) {
            Write-Verbose -Message "Copying $($online.fullname)"
            Copy-Item -Path $online.fullname -Destination $Destination -PassThru:$Passthru -DisplayName 'Downloading files' -PSProgressMessage $online.fullname
        }

    } #foreach

    Write-Verbose -message "Testing for online files not in $destination"

    #test for files online but not in the destination and copy them
    #compare to current list and get a list of file names that are missing
    $names = Compare-Object -ReferenceObject $webfiles -DifferenceObject $current -Property Name -DisplayName 'Comparing files' | 
    Select-object -ExpandProperty Name
    foreach -parallel -throttle 8 ($file in $names) {
        Get-Item -path "\\live.sysinternals.com\tools\$file" -DisplayName 'Downloading missing files' -PSProgressMessage $file | 
        Copy-Item -Destination $Destination -PassThru:$Passthru 
    }
    
    if ( $workflow:Stopped ) {
        Write-Verbose -message 'Stopping web client'
        Stop-Service -name WebClient -PSProgressMessage 'Stopping WebClient'
            $workflow:Stopped = $True
    }

    Write-Verbose 'Sysinternals Update Complete'
} 

} #end workflow