#
#  Create WVD hostpool and VM
#
#
#   Changelog
#
#   0.01 - 04-04-2021 - Initial release
#



### Define variables

# Define tenant to connect to
$Tenant = '01234567-0123-0123-0123-01234567890' 
# Define subsrciption ID
$SubscriptionId = "01234567-0123-0123-0123-01234567889a" 
# Define the resourcegroupname
$resourcegroupname = "ResourceGroupWVD"

# Define the Tags to set on the resources
$Tags = @{"Cost" = "WoofArfWoof" }

# Define the hostpool name
$hostpoolname = "hp-woofarfwoof-test1"
# Define the Workspace name
$WorkspaceName = "ws-woofarfwoof-test1"
# Define the Hostpool (type can be "Pooled" or "Personal")
$HostPoolType = "Personal"
# Define the load balancer type (can be "BreadthFirst", "DepthFirst" or "Persistent" (use persistent for personal pool))
$LoadBalancerType = "Persistent"
# Define geographical location for the hostpool
$HostPoolLocation = "westeurope"
# Define desktop app group name
$DesktopAppGroupName = $hostpoolname + "-DAG"
# Define the groups to add to the DesktopAppGroupName
$ADGroupsToAdd = @( "MyDogIsAGoodBoy" )

# WVD VM hostname prefix (e.g: the name "wvdwe-t1" with 2 hosts will produce 2 hosts with the names wvdwe-t1-1 and wvdwe-t1-2 (if there are no existing hosts))
$VMPrefix = "wvd-waw"
# Set the number of hosts to create
$VMPoolSize = 10
# Select image to deploy
$VMImage = "20h2-evd" # W10 Multisession image
# Define geographical location for the VM's
$VMLocation = "westeurope"
# Define the VM size
$VMSize = "Standard_D4s_v4"
# Set WVD VM Local admin account
$VMLocalAdminUser = "WVDLocalAdmin"
# Set WVD VM Local admin password
$VMLocalAdminPassword = "W00f@rfW00f01!" # You did not see this. I did not just type a password in the code!

# Define the network to attach
$VMVirtualNetwork = "vnet-woofarfwoof"
# Define the network subnet
$VMVirtualNetworkSubnet = "snet-woofarfwoof"

# Define domain to join
$DomainToJoin = "woofarfwoof.com"
# Define OU to join
$OuTOJoin = "OU=Computers,DC=woofarfwoof,DC=com"
# Define Domain Join account
$DomainJoinAccount = "domainjoin@woofarfwoof.com"
# Define Domain Join account password
$DomainJoinAccountPassword = "W00f@rfW00f01!" # This is not a password... No, really. There is no password in this code... 

# Post deploy script name. This is the script that is started after the VM is deployed
$PostDeployScriptName = "WVDVMPostDeploy.ps1"
# Post deploy script storage account name
$PostDeployStorageAccountName = "Woofarfwoofstorage"
# Post deploy script containername in the storage account
$PostDeployContainerName = "woofarfwoofcontainer"

# Get the current directory (yes, I should use $PSScriptroot, but it is not working when I use F8)
$CurDir = (Get-Location).path
# Define a log file (logs common events)
$LogFile = "$Curdir\CreateWVDHostpoolLog.log"
# Define a Debug log file (logs EVERYTING)
$DebugLogFile = "$Curdir\CreateWVDHostpoolDebugLog.log"



# Define modules and module versions tested for use with this script
$PSModules = @(

  [pscustomobject]@{  
    Name    = "Az.Accounts"
    Version = "2.2.6"
  }

  [pscustomobject]@{  
    Name    = "Az.DesktopVirtualization"
    Version = "2.1.1"
  }

  [pscustomobject]@{  
    Name    = "Az.Resources"
    Version = "3.3.0"
  }

  [pscustomobject]@{  
    Name    = "Az.Compute"
    Version = "4.10.0"
  }

  [pscustomobject]@{  
    Name    = "Az.Network"
    Version = "4.6.0"
  }

)



Function Set-PSModuleVersion {
  <#
    .SYNOPSIS
    Check powershell module installstate / version
    .DESCRIPTION
    Check if a powershell module is installed and has a minimal version
    .PARAMETER ModuleName
    Name of the module to check (mandatory)
    .PARAMETER Version
    Version that the module has to be (mandatory)
    .OUTPUTS
    True or false for error checking
    .EXAMPLE
    # Force install / load of AZ.Account module with version 2.4.5: 
    Set-PSModuleVersion -modulename AZ.Accounts -Version 2.4.5
    # Force install / load of AZ.Account module with version 2.4.5 and do some handling around it:
    If ( Set-PSModuleVersion AZ.Accounts 2.4.5 ) { Write-output "AZ.Account is (updated/downgraded to) version 2.4.5" } ELSE { Updating/downgrading/loading/installing of module AZ.Accounts has failed }
    #>

  [CmdletBinding()]

  Param ( 

    # Define the module name to check (and make the parameter mandatory)
    [Parameter(Mandatory = $true)]
    [string]$ModuleName, 
        
    # Define the module minimal version to check (and make the parameter mandatory)
    [Parameter(Mandatory = $true)]
    [System.Version]$Version

  )



  # Remove all modules with untested/unwanted version
  ForEach ( $ModuleToRemove in (Get-Module | Where-Object { $_.Name -eq $ModuleName -and (-not ($_.Version -eq $Version)) } ) ) {

    Remove-Module $ModuleToRemove -Force

  }



  # Check if the module is already loaded with correct version
  $FoundModule = Get-Module | Where-Object { $_.Name -eq $ModuleName -and $_.Version -eq $Version }

  If ( $FoundModule ) { 

    Return $true

  } 
  ELSE {

    # Get the available modules in a Global variable (so we do not have to fill the var for every run)
    If ( -not ( $InstalledPSModules ) ) {

      $Global:InstalledPSModules = Get-Module -ListAvailable

    }

    # Check if the module with the correct version is somewhere on the system and import it
    If ( $InstalledPSModules | Where-Object { $_.Name -eq $ModuleName -and $_.Version -eq $Version } ) {

      $Correctmodule = $InstalledPSModules | Where-Object { $_.Name -eq $ModuleName -and $_.Version -eq $Version } 
      Import-Module $Correctmodule -Force

      Return $true

    } 
    Else {
      # Try to download and import the module with the correct version

      Install-Module -Name $ModuleName -RequiredVersion $Version -Force -AllowPrerelease -ErrorAction SilentlyContinue

      # Update the global powershell module list
      $Global:InstalledPSModules = Get-Module -ListAvailable

      # ReCheck if the module with the correct version is available and import the module
      $Correctmodule = $InstalledPSModules | Where-Object { $_.Name -eq $ModuleName -and $_.Version -eq $Version } 
      Import-Module $Correctmodule -Force

      # Check if the module is now loaded 
      If ( Get-Module | Where-Object { $_.Name -eq $ModuleName -and $_.Version -eq $Version } ) {

        Return $true

      }
      ELSE {

        Return $false

      }

    }

  }

} # End of Set-PSModuleVersion Function 



# Check if the package manager is at least version 1.4.6 (and upgrade if not)
[System.Version]$ModernPackageManagerMinimumVersion = "1.4.6"
If ( -not ( Get-Module -ListAvailable | Where-Object { $_.Name -eq "Packagemanagement" -and $_.version -ge $ModernPackageManagerMinimumVersion } ) ) {

  Try { 

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Install-Module -Name PackageManagement -Force -MinimumVersion $ModernPackageManagerMinimumVersion -Scope CurrentUser -AllowClobber -Repository PSGallery -ErrorAction Stop
    
  }
  Catch {

    Write-Host "Unable to update PackageManagement module."
    Break
        
  }
    
}



# Force load of (tested versions of) Powershell modules
ForEach ( $PSModule in $PSModules ) {

  Try { 

    Write-Host "Checking module $($PSModule.Name) with version $($PSModule.Version)..."
    Set-PSModuleVersion -ModuleName $PSModule.Name -Version $PSModule.Version | Out-Null

  } 
  Catch { 

    Write-Host "Unable get module $($PSModule.Name) with version $($PSModule.Version)."
    Write-Host $_.Exception.message
    Break

  }

}



## Connect to tenant and select subscription

# Login with an Azure AD credential 
Connect-AzAccount -Tenant $Tenant | Out-Null
Select-AzSubscription $SubscriptionId | Out-Null



## Generate VM's names

Write-Host "Generating VM Names..."

# Check if there are already hosts with the prefix (and store the "index" numbers of existing hosts)
$ExistingVMList = @()
Foreach ( $ExistingVM in (Get-AZVM).name ) {

  If ( $ExistingVM.startswith("$VMPrefix") ) { 

    [int]$Index = $ExistingVM.Replace("$VMPrefix-", "")
    $ExistingVMList += $Index
    
  }

}

# Check what the highest number in the VM index list is, if nothing is found set the first number to 1, else continue numbering upward of highest number found.
If ( $ExistingVMList ) { 

  $VMPoolSizeMin = ($ExistingVMList | Measure-Object -Maximum).Maximum
  # Increment the highest number found by 1
  $VMPoolSizeMin++

}
Else {

  $VMPoolSizeMin = 1

}

# Generate host names for VM's to be created
$VMHostNameList = @()
$VMPoolSizeMin..($VMPoolSize + ($VMPoolSizeMin - 1)) | ForEach-Object { 
    
  $VMHostNameList += $VMPrefix + - $_

}



## Create host pool, workspace, dektop app group, register desktop app group to workspace, assign users/group(s)

# Create the host pool, workspace and desktop app group. Additionally, it will register the desktop app group to the workspace (you can either create a workspace with this cmdlet or use an existing workspace).
New-AzWvdHostPool -ResourceGroupName $resourcegroupname -Name $hostpoolname -WorkspaceName $workspacename -HostPoolType $HostPoolType -LoadBalancerType $LoadBalancerType -Location $HostPoolLocation -DesktopAppGroupName $DesktopAppGroupName -PreferredAppGroupType Desktop -Erroraction Stop

# Update tags for resources
$Resources = @( $WorkspaceName, $hostpoolname, $DesktopAppGroupName )
foreach ($resource in $Resources) {

  Get-AzResource -Name $resource -ResourceGroupName $resourcegroupname | New-AzTag -Tag $Tags | Out-Null
        
}



# create a registration token to authorize a session host to join the host pool and save it to a new file on your local computer. You can specify how long the registration token is valid by using the -ExpirationHours parameter.
New-AzWvdRegistrationInfo -ResourceGroupName $resourcegroupname -HostPoolName $hostpoolname -ExpirationTime $((Get-Date).ToUniversalTime().AddHours(4).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ')) | Out-Null



# Store the registration token to a variable, which you will use To register the virtual machines to the Windows Virtual Desktop host pool.
$WVDRegistrationToken = Get-AzWvdRegistrationInfo -ResourceGroupName $resourcegroupname -HostPoolName $hostpoolname



# Add user groups to the default desktop app group for the host pool
If ( $ADGroupsToAdd ) {

  foreach ( $ADGroup in $ADGroupsToAdd ) {

    $AZADGroup = Get-AzADGroup -DisplayName $ADGroup
    $Resourcename = $Hostpoolname + "-DAG"

    New-AzRoleAssignment -ObjectId $AZADGroup.id -RoleDefinitionName "Desktop Virtualization User" -ResourceName $Resourcename -ResourceGroupName $resourcegroupname -ResourceType 'Microsoft.DesktopVirtualization/applicationGroups' -ErrorAction Stop
    
  }

}



# Get networksettings (for creating the NIC)
$VMVirtualNetworkObject = Get-AzVirtualNetwork -Name $VMVirtualNetwork -ResourceGroupName $resourcegroupname
$VMVirtualNetworkSubnetObject = Get-AzVirtualNetworkSubnetConfig -name $VMVirtualNetworkSubnet -VirtualNetwork $VMVirtualNetworkObject
$VMVirtualNetworkSubnetObjectID = $VMVirtualNetworkSubnetObject.id


# Build a single string from the values to pass as argument to the VM install script (command delimiter is ASCII character 254 and line delimiter is char 255)
$String = 'OuTOJoin' + "$([char]254)" + $OuTOJoin + "$([char]255)"
$String = $String + 'DomainToJoin' + "$([char]254)" + $DomainToJoin + "$([char]255)"
$string = $String + 'Registrationtoken' + "$([char]254)" + $WVDRegistrationToken.Token + "$([char]255)"
$string = $String + 'DomainJoinAccount' + "$([char]254)" + $DomainJoinAccount + "$([char]255)"
$string = $String + 'DomainJoinAccountPassword' + "$([char]254)" + $DomainJoinAccountPassword + "$([char]255)"

# Encode the argument to pass, to an UTF8 encoded string (to avoid breaks with "strange" characters)
$ArgumentToPass = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String))



# Define the CreateVM script block (that actually creates the VM)
# note: when using variables from outside the block we use $using:variable
$CreateVM = {

  param(

    [Parameter(Position = 1)]
    [string]$VMHostname

  )

  # Define the NIC name based on the VMHostname
  $VMNICName = $VMHostname + "-nic"

  # Create NICs
  $NIC = New-AzNetworkInterface -Name $VMNICName -ResourceGroupName $Using:ResourceGroupName -Location $Using:VMLocation -SubnetId $Using:VMVirtualNetworkSubnetObjectID -Force
  Get-AzResource -Name $VMNICName -ResourceGroupName $Using:resourcegroupname | New-AzTag -Tag $Using:Tags | Out-Null

  # Create credential object for local admin
  $VMLocalAdminSecurePassword = ConvertTo-SecureString $Using:VMLocalAdminPassword -AsPlainText -Force
  $Credential = New-Object System.Management.Automation.PSCredential ($Using:VMLocalAdminUser, $VMLocalAdminSecurePassword);

  # Configure virtual machine
  $VirtualMachine = New-AzVMConfig -VMName $VMHostname -VMSize $Using:VMSize
  $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMHostname -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
  $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
  $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName "MicrosoftWindowsDesktop" -Offer "Windows-10" -Skus $using:VMImage -Version "latest"
    
  # Create virtual machine
  New-AzVM -ResourceGroupName $Using:ResourceGroupName -Location $Using:VMLocation -VM $VirtualMachine -Verbose | Out-Null
  Get-AzResource -Name $VMHostname -ResourceGroupName $Using:ResourceGroupName | New-AzTag -Tag $Using:Tags | Out-Null

  # Content will land in "C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\x.xx.x\Downloads\x
  Set-AzVMCustomScriptExtension `
    -Name "WVDVMPostdeployactions" `
    -Location $Using:VMLocation `
    -ResourceGroupName $Using:resourcegroupname `
    -VMName $VMHostname `
    -ContainerName $Using:PostDeployContainerName `
    -StorageAccountName $Using:PostDeployStorageAccountName `
    -FileName $Using:PostDeployScriptName `
    -Run $Using:PostDeployScriptName `
    -Argument $Using:ArgumentToPass `
    -ErrorAction Stop | Out-Null


  # Read the status of the custom script extension
  $Status = Get-AzVMDiagnosticsExtension -ResourceGroupName $using:resourcegroupname -VMName $VMHostname -Name WVDVMPostdeployactions -status
  If ( $Status.ProvisioningState -eq "Failed") {
    Write-Host "Failed" -ForegroundColor Red
  }
  # Display the output of the custom script extension
  $Status.SubStatuses.message 

  # remove the custom script extension (and with that, the local files on cached on the VM)
  Get-AzVMCustomScriptExtension -ResourceGroupName $using:resourcegroupname -VMName $VMHostname -Name "WVDVMPostdeployactions" | Remove-AzVMCustomScriptExtension -force

  # Restart the VM to complete installation
  Restart-azvm -ResourceGroupName $Using:resourcegroupname -name $VMHostname | Out-Null

}



# Clear the job list var (just in case)
$Joblist = $null

# Loopt through the list of VMhostnames to create
Foreach ( $VMHostname in $VMHostNameList ) {

  # Create/update a list of names of jobs (started by this script) for easy deletion afterwards
  $Jobname = "CreateVM " + $VMHostname + " JobID:" + (Get-Random)
  If ( -not ($Joblist) ) { 

    $Joblist = @($Jobname) 

  }
  Else { 

    $JobList = @(
    
      $Joblist
      $Jobname
    
    )

  }
    
  # Execute the job(s)
  $JobCreate = Start-Job -Name $Jobname -ScriptBlock $CreateVM -ArgumentList $VMHostname

}



### Wait for all jobs to complete

# Get the number of jobs created
$JobsRunning = ( $Joblist | Measure-Object ).count

# Define all possible complete states that a job can be in (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-job?view=powershell-7.1)
$StateComplete = @( "Completed", "Failed", "Stopped", "Blocked", "Suspended", "Disconnected" )
# $StateNotComplete = @( "NotStarted", "Running", "Suspending", "Stopping" )

# Overwrite existing measuring vars
$JobsDone = $null
$Jobsfound = $null

# Start a while loop to check if all jobs have finished
While ( $JobsDone -ne "YES" ) {

  $Jobsfound = $JobsRunning
  ForEach ( $Jobname in $Joblist ) {

    If ( $StateComplete -contains (Get-Job -Name $Jobname).state ) { 
            
      $Jobsfound--
        
    }

  }

  # Break the loop if all jobs have reached the status set in $StateComplete
  If ( $Jobsfound -eq 0 ) {

    $JobsDone = "YES"

  }

  Start-Sleep 5

}



# Remove jobs
Foreach ( $Job in $Joblist ) { 

  Get-Job -Name $Job | Remove-Job

}


Write-Host "done"