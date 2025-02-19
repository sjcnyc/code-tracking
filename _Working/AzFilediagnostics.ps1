################################
#.SYNOPSIS
# AzFilediagnostics.ps1 is a sample script to help customer diagnose issues with mounting AZURE File Share on Windows machines.  Output will be redirected to both console and file AzFileDiag-<timestamp>.txt in the script folder
#
#.DESCRIPTION
# This tool aims to help customer to validate the client running environment, detect the incompatible client configuration which could cause access failure for Azure files, and give prescriptive guidance on self-fix, collect the diagnostics trace etc.  
# 
#.PARAMETER UNCPath
# Specify Azure File share UNC path like \\storageaccount.file.core.windows.net\sharename. Storage Path must confirm to the naming convention in https://docs.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-shares--directories--files--and-metadata
# 
#.PARAMETER StorageAccountName
# Specify Storage Account Name, which must confirm to Naming Convention in https://docs.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-shares--directories--files--and-metadata
#
#.PARAMETER FileShareName
# Specify the file share name, which must confirm to Naming Convention in https://docs.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-shares--directories--files--and-metadata
#
#.PARAMETER Environmentname
# Specify the Azure environment. Valid values are: AzureCloud, AzureChinaCloud, AzureUSGovernment. The default is AzureCloud.
#
#.EXAMPLE
# Script can run without any parameter ( and will prompt user to input all required information). Alternatively, user can specify optional parameters for example. 
#   AzFilediagnostics.ps1 -UncPath <\\storageaccountname.file.core.windows.net\sharename>
# OR
#   AzFilediagnostics.ps1 -StorageAccountName <SA name> -FileShareName <share name> -Environmentname <AzureCloud> 
#.NOTES
#General notes
##############################

[CmdletBinding(DefaultParametersetName = 'None')] 
param(
  [Parameter(ParameterSetName = 'UNCParameterSet', Mandatory = $false)]
  [ValidatePattern('^\\\\[a-z0-9`]{3,24}(.file.core.windows.net|.file.core.chinacloudapi.cn|.file.core.cloudapi.de|.file.usgovcloudapi.net)\\([a-z0-9](?:[a-z0-9]|(\-(?!\-))){1,61}[a-z0-9])(\\[^\x00-\x1f`"\\/:|<>*?\uE000-\uF8FF]{1,255})*$')]
  $UNCPath = $null,
  [Parameter(ParameterSetName = 'StorageAccountParameterSet', Mandatory = $false)]
  [ValidatePattern('^[a-z0-9`]{3,24}$')]
  $StorageAccountName = $null,
  [Parameter(ParameterSetName = 'StorageAccountParameterSet', Mandatory = $true)]
  [ValidatePattern('^[a-z0-9](?:[a-z0-9]|(\-(?!\-))){1,61}[a-z0-9]$')]
  $FileShareName = $null,
  [Parameter(ParameterSetName = 'StorageAccountParameterSet', Mandatory = $true)]
  [ValidateSet('AzureCloud', 'AzureChinaCloud', 'AzureGermanCloud', 'AzureUSGovernment')]
  $Environmentname = 'AzureCloud'
)


###############################
#.SYNOPSIS
#Write-log prints out the message based on the level and save the output to log file as well. 
#
#.DESCRIPTION
#Long description
#
#.PARAMETER level
# specifies the log level, currently support info/error/success/verbose.
#
#.PARAMETER logMessage
# The message to be printed out. 
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
function Write-Log {
  param(
    [string]$level,
    [string]$logMessage  
  )

  switch ($level) {
    "info" { 
      Write-Host $logMessage -ForegroundColor White
    }
    "success" {
      Write-Host $logMessage -ForegroundColor Green
    }
    "error" {
      Write-Host $logMessage -ForegroundColor Red
    }
    "warning" {
      Write-Host $logMessage -ForegroundColor Yellow
    }
    "verbose" {
      Write-Verbose -Message $logMessage
            
    }
        
  }
        
  $logmessage | Out-File -FilePath $script:logfilepath -Append 
}


##############################
#.SYNOPSIS
#
# Prompt user to select admin mode. few checks require admin mode.  
#
#.DESCRIPTION
#Long description
#
#.PARAMETER arglist
# It is the script argument list which will be used when spinning up a new admin powershell session. 
#
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
function PromptAdminMode ($arglist) {
    
  $adminmode = $false

  # Get the ID and security principal of the current user account
  $WindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
  $WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($WindowsID)
 
  # Get the security principal for the Administrator role
  $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
 
  # Check to see if we are currently running "as Administrator"
  if ($WindowsPrincipal.IsInRole($adminRole)) {
    # We are running "as Administrator" - so change the title and background color to indicate this
    Write-Log -Level success "[OK]: Script runs with elevated right" 
    $adminmode = $true

    return $adminmode
  }
  else {

    #prompt user to select admin mode or not. 
    
    $title = "Switch to Admin mode"
    $message = "Some diagnostic tracing require elevated right, would you like to run elevated powershell session?"

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
      "Switch to Admin mode."

    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
      "Go on validation without admin mode."

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

    switch ($result) {
      0 {
        "You selected Yes."
        # Start the new process

        Start-Process powershell -WorkingDirectory $Script:LogDirectory -Verb runAs -ArgumentList $arglist

        # Exit from the current unelevated process
        exit;
      }
      1 {
        "You selected No."
        Write-Log -Level warning "`n[WARNING]: Script continues to run without elevated right, some diagnostics tracing may not be turned on"
        $adminmode = $false
        return $adminmode
      }
    }

  }
}

##############################
#.SYNOPSIS
# return the OS version. 
#
#.DESCRIPTION
# [System.Environment]::OSVersion.Version has a known issue on windows 8.1 which will report incorrect OS version. So use WMI first and fall back to [System.Environment] type in case WMI was corrupted.
#
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
function ValidateClientOS {
    
  $OSEnv = $null
  Try {   
    [System.Version]$ver = (gcim Win32_OperatingSystem).Version
    $OSEnv = New-Object PSCustomObject
    $OSEnv | Add-Member -MemberType NoteProperty -Name Version -Value $ver
  }
  catch {
    Write-Log -Level verbose "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)" 
    Write-Log -Level verbose "Cannot get the client OS info from WMI, trying with system vairable" 
    $ver = [System.Environment]::OSVersion.Version
    $OSEnv = New-Object PSCustomObject
    $OSEnv | Add-Member -MemberType NoteProperty -Name Version -Value $ver
  }

     
  if ($OSEnv -eq $null) {
    $Script:ValidationPass = $false
  } 
  else {
    Write-Log -Level success "[OK]: Running script on host with OS version $($OSEnv.version)"  
  }

  return $OSEnv

}

##############################
#.SYNOPSIS
#    Get SMB version
#      It depends on if it is Admin session. 
#           non-admin session, get the SMB version by checking OS version and driver state. 
#           admin session, run Get-SmbConnection to get the SMB version. 
#      returns client SMB version. 
#.DESCRIPTION
#Long description
#
#.PARAMETER adminmode
# specify if it is admin session or not. 
#
#.PARAMETER OSEnv
# it has the OS version etc. 
#
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
function ValidateSMBver($adminmode, $OSEnv) {
  ##Check SMB driver running state first.
  if ( ((Get-Service -Name mrxsmb20).Status -eq "running") -and ((Get-Service -Name mrxsmb).Status -eq "running") ) {
    if ($adminmode -eq $true) {
      try {
        Get-ChildItem \\localhost\C$ | Out-Null
        $smbconn = Get-SmbConnection -ServerName localhost
        Write-Log -Level success "`n[OK]: Client SMB version is $($smbconn.Dialect)"  
        return $smbconn[0].Dialect
      }
      catch {
        Write-Log -Level verbose "Get-SmbConnection fails, Determine the SMB version based on OS version only"

        if ( ($OSEnv -ne $null) -and ([System.Version]$OSEnv.version -ge [System.Version]"6.2.0.0") ) {
          Write-Log -Level success"`n[OK]: Client SMB version is 3.0+"  
          return "3.0"                        
        }
        elseif ( ($OSEnv -ne $null) -and ([System.Version]$OSEnv.version -ge [System.Version]"6.0.0.0") ) {
          Write-Log -Level success "`n[OK]: Client SMB version is 2.0+"  
          return "2.0" 
            
        } 
        else {
          WWrite-Log -level error "`n[ERROR]: Client SMB version is below 2.0" 
          $Script:ValidationPass = $false
          return $null
        }
      }
    }
    else {

      if ( ($OSEnv -ne $null) -and ([System.Version]$OSEnv.version -ge [System.Version]"6.2.0.0") ) {
        Write-Log -Level success "`n[OK]: Client SMB version is 3.0+"  
        return "3.0"                        
      }
      elseif ( ($OSEnv -ne $null) -and ([System.Version]$OSEnv.version -ge [System.Version]"6.0.0.0") ) {
        Write-Log -Level success "`n[OK]: Client SMB version is 2.0+"  
        return "2.0" 
            
      } 
      else {
        Write-Log -Level error "`n[ERROR]: SMB version is below 2.0" 
        $Script:ValidationPass = $false
        return $null
      }
    
    }
  }
  else {
    Write-Log -Level error "`n[ERROR]: either mrxsmb.sys or mrxsmb20.sys is not running, it will break the SMB access" 
    $Script:ValidationPass = $false
    return $null
  }
    
}

##############################
#.SYNOPSIS
# Validate if KB3114025 is installed on the client computer. 
#
#.DESCRIPTION
# It will first check if the patch is installed and then verify if the required registry key is set. if either fails, it will prompt user it may cause the performance issue and suggest installing the patch.
#
#.PARAMETER OSEnv
# It has the OS version etc. 
#
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
function ValidateKB3114025 ($OSEnv) {

  $OSroot = [System.Environment]::ExpandEnvironmentVariables("%SystemRoot%")
  $mrx20ver = [System.Version](([System.Diagnostics.FileVersionInfo]::GetVersionInfo("$($OSroot)\system32\drivers\Mrxsmb20.sys").FileVersion).split('('))[0]
  $mrxver = [System.Version](([System.Diagnostics.FileVersionInfo]::GetVersionInfo("$($OSroot)\system32\drivers\Mrxsmb.sys").FileVersion).split('('))[0]

  if (($mrx20ver -ge [System.Version]"6.3.9600.18123") -and ($mrxver -ge [System.Version]"6.3.9600.18123")) {

    Write-Log -Level info "`nDriver file version is newer than KB3114025 and checking if the required registry key is present"

    $RegKeyPath = "HKLM:SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters\Policies"
    $valueName = "{96c345ef-3cac-477b-8fcd-bea1a564241c}"
    $result = Get-ItemProperty -Path $RegKeyPath -Name $valueName -ErrorAction SilentlyContinue
    

    if ($result -ne $null) {
      if ( $result.$valueName -eq 1 ) {
        Write-Log -Level success "`n[OK]: Client OS is $($OSEnv.version), Driver/Registry for KB3114025 are all configured properly" 
      }
      else {
        Write-Log -Level warning "`n[WARNING]: Required registry key is not present, it may cause slow performance accessing Azure File service. refer to https://support.microsoft.com/en-us/help/3114025 for more information"
      }
    }
    else {
      Write-Log -Level warning "`n[WARNING]: Required registry key is not present, it may cause slow performance accessing Azure File service. refer to https://support.microsoft.com/en-us/help/3114025 for more information" 
    }
  }
  else {
    Write-Log -Level warning "`n[WARNING]:  KB3114025 IS NOT istalled and it may cause slow performance accessing Azure File service. refer to https://support.microsoft.com/en-us/help/3114025 for more info" 
  }


}


##############################
#.SYNOPSIS
# Validate the LmCompatibilityLevel. 
#
#.DESCRIPTION
# Currently just check the registry key and its value. if it is set to value other than 3, prompt user to change it to expected value. 
#
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
function ValidateLmCompatibilityLevel {

  $RegKeyPath = "HKLM:SYSTEM\CurrentControlSet\Control\Lsa"
  $valueName = "LmCompatibilityLevel"

  $Result = Get-ItemProperty -Path $RegKeyPath  -Name $valueName -ErrorAction SilentlyContinue

  if ($Result -eq $null) {
    Write-Log -Level success "`n[OK]: HKLM:SYSTEM\CurrentControlSet\Control\Lsa|LmCompatibilityLevel IS NOT set, by default it should be 3 (or greater)" 

  }
  else {

    if ( $result.LmCompatibilityLevel -ge 3 ) {
      Write-Log -Level success "`n[OK]: HKLM:SYSTEM\CurrentControlSet\Control\Lsa|LmCompatibilityLevel is set to default value 3 (or greater)" 
    }
    else {
      Write-Log -Level error "`n[ERROR]: HKLM:SYSTEM\CurrentControlSet\Control\Lsa|LmCompatibilityLevel IS NOT set to default value 3 (or greater) and current value is $($result.LmCompatibilityLevel), it will cause mouting share to fail." 
      $Script:ValidationPass = $false
    }

  }




    
}

##############################
#.SYNOPSIS
# Collect the UNC path or Storage account name/File share name/Cloud. 
#
#.DESCRIPTION
# It will take the user input and do small sanity check over the storage account name/file share name etc. Return the full UNC path. 
#
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
function GetFileSharePath {
  $title = $null
  $message = "`nNo file share path is provided yet, please Type U or S to proceed"
  $option1 = New-Object System.Management.Automation.Host.ChoiceDescription "&UNCPath", "UNC Path"
  $option2 = New-Object System.Management.Automation.Host.ChoiceDescription "&StorageAccount", "Storage Account name"
  $options = [System.Management.Automation.Host.ChoiceDescription[]]($option1 , $option2)
  $result = $host.ui.PromptForChoice($title, $message, $options, 1) 
  switch ($result) {
    0 { 
      while ($true) {
        $FileSharePath = Read-Host -Prompt "`nPlease now type UNC Path like \\storageaccount.file.core.windows.net\sharename"
        ###Validate the UNC path format.
        if ($FileSharePath -notmatch $Script:UNCPathValidationPattern ) {
          Write-Log -Level warning "[WARNING]: UNC path format should be like \\storageaccount.file.core.windows.net\sharename" 
        }
        else {
          break
        }
      }

    }
    1 {
      do {
        $StorageAccountName = Read-Host -Prompt "`nPlease now type Storage Account Name"
      }while ($StorageAccountName -notmatch $Script:StorageAccountNameValidationPattern)

      do {
        $FileShareName = Read-Host -Prompt "`nPlease now type File Share Name"
      }while ($FileShareName -notmatch $Script:ShareNameValidationPattern)
        
            
      $message = "`nPlease choose cloud environment, default is AzureCloud"
      $options = [System.Management.Automation.Host.ChoiceDescription[]]("&AzureCloud", "Azure&ChinaCloud", "Azure&GermanCloud", "Azure&USGovernment")
      $result = $host.ui.PromptForChoice($title, $message, $options, 0) 
      switch ($result) {
        0 { $surffix = ".file.core.windows.net" }
        1 { $surffix = ".file.core.chinacloudapi.cn" }
        2 { $surffix = ".file.core.cloudapi.de" }
        3 { $surffix = ".file.usgovcloudapi.net" }
        Default { $surffix = ".file.core.windows.net" }
      }
      $FileSharePath = "\\" + $StorageAccountName + $surffix + "\" + $FileShareName               
    }
  }
  #Write-Host "FileShare path is " $FileSharePath 
  return $FileSharePath
}

##############################
#.SYNOPSIS
# Probe the port 445 availability on storage account IP.  
#
#.DESCRIPTION
# Do TCP connection to port 445 on storage account IP. if it fails, retry for maximum 3 times and print out the native socket error. if it related to windows firewall, detect the offending WFP rule. 
#
#.PARAMETER DestIP
# Storage Account IP. Currently it only supports IPV4 address. 
#
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
function ValidateTCPPort($DestIP) {
    
  $iters = 3
  $DestPort = 445
  $TCPTimeout = 2000
  $lastsocketExeption = $null    
  $FirewalCheck = $false
  $PortAlive = $true

  For ($i = 0; $i -lt $iters; $i++) {
    $tcpClient = New-Object System.Net.Sockets.TcpClient

    $AsyncResult = $tcpClient.BeginConnect($DestIP , $DestPort , $null, $null)
    $Wait = $AsyncResult.AsyncWaitHandle.WaitOne($TCPTimeout) 
    Try {

      If ($Wait) {
         

        if ($tcpClient.Connected -eq $false) {
                
          $PortAlive = $false
          $tcpClient.EndConnect($AsyncResult)
                  
        }
        else {
                
          $message = "`n[OK]: Connection attempt succeeds -  Port is open"
          Write-Log -Level success $message 
          $PortAlive = $true
          $tcpClient.EndConnect($AsyncResult)
          break
                
        }
            
      }
      else {
        try {
          $timeoutexception = New-Object System.TimeoutException
          throw $timeoutexception
        }
        catch {
          $oldE = $_.Exception
          $newE = New-Object -TypeName System.InvalidOperationException('Timeout error occured', $oldE)
          Throw $newE  
        }

      }
    }
    Catch {
      Write-Log -Level error "`n[ERROR]: Connection attempt fails with iteration($i + 1) of $iters  with the error --- $($_.Exception.InnerException.Message)" 
      $lastsocketExeption = $_

      Write-Log -Level verbose "[ERROR]: Connectoin Failure with error $($_.Exception.InnerException.HResult)" 
      $PortAlive = $false

    }
    Finally {
              
      $tcpClient.Close()   
    } 
    Start-Sleep(1)
  }

  if (($PortAlive -eq $false ) -and ($lastsocketExeption -ne $null)) {
    Write-Log -Level error  "`n[ERROR]: Last connection exception is:" 
    Write-Log -Level error "       ---$($lastsocketExeption.Exception.InnerException.Message)" 
    #Exception.HResult.ToString("X") 
    if ($lastsocketExeption.Exception.Message -match "An attempt was made to access a socket in a way forbidden by its access permissions") {
      $FirewalCheck = $true
    }  
  }

  if ( $FirewalCheck) {
    Start-Sleep(1)
    $PortAlive = $false
    try { 
           

      if ($script:psver -lt [System.Version]"4.0") { 
        $Process = Start-Process "$($env:windir)\System32\netsh.exe" -ArgumentList "wfp show netevents file=$Script:LogDirectory\WFPEVENTS.xml  remoteport=445 remoteaddr=$destIp timewindow=60" -Wait -PassThru
      }
      else {
        $Process = Start-Process "$($env:windir)\System32\netsh.exe" -ArgumentList "wfp show netevents file=$Script:LogDirectory\WFPEVENTS.xml  remoteport=445 remoteaddr=$destIp timewindow=60" -Wait -NoNewWindow -PassThru
      }
                  
      if (($Process.ExitCode -lt 0 ) -or ($Process.ExitCode -gt 3010 ) ) { 
        throw "Failed to dump WFP events. Netsh exited with an exit code [$($Process.ExitCode)]" 
      }
      else { 
        Write-Log -Level verbose  "[OK]: dump WFP events" 

      } 
            
      if ($script:psver -lt [System.Version]"4.0") { 
        $Process = Start-Process "$($env:windir)\System32\netsh.exe" -ArgumentList "wfp show filters file=$Script:LogDirectory\WFPFILTERS.xml" -Wait -PassThru
      }
      else {
        $Process = Start-Process "$($env:windir)\System32\netsh.exe" -ArgumentList "wfp show filters file=$Script:LogDirectory\WFPFILTERS.xml" -Wait -NoNewWindow -PassThru
      }


      if (($Process.ExitCode -lt 0 ) -or ($Process.ExitCode -gt 3010 ) ) { 
        throw "Failed to dump WFP filters. Netsh exited with an exit code [$($Process.ExitCode)]" 
      }
      else { 
        Write-Log -Level verbose "[OK]: dump WFP filers" 
      } 
    }
    catch { 
      Write-Log -Level verbose   "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
      Write-Log -Level warning  "`n[WARNING]: Cannot validate local WFP settings" 
      $Script:ValidationPass = $false
      return 

    }

    try {
      [xml]$wfpevents = Get-Content "$Script:LogDirectory\WFPEVENTS.xml"
      [xml]$wfpfilters = Get-Content "$Script:LogDirectory\WFPFILTERS.xml"

      if ($wfpevents.HasChildNodes) {
        $wfpevent = $wfpevents.SelectSingleNode("netEvents/item[type=`"FWPM_NET_EVENT_TYPE_CLASSIFY_DROP`"]")

        if ($wfpevent -ne $null) {
          $filterid = $wfpevent.classifyDrop.filterId
                      
        }

        if ($wfpfilters.HasChildNodes -and ($filterid -ne $null)) {
                
          $xpathstr = "wfpdiag/filters/item[filterId=`"$filterid`"]"
          $wfpfilter = $wfpfilters.SelectsingleNode($xpathstr)

          $wfproviderkey = $wfpfilter.providerkey
          $xpathstr = "wfpdiag/providers/item[providerKey=`"$wfproviderkey`"]"
    
          $wfpprovider = $wfpfilters.SelectsingleNode($xpathstr)
          $wfpfilter
          Write-Log -Level error "`n[ERROR]: Connection was dropped by:" 
          Write-Log -Level error "       ---WFP Rule Name:  {$($wfpfilter.displaydata.name)}" 
          Write-Log -Level error "       ---WFP Provider Name: {" $wfpprovider.displayData.name "}-{" $wfpprovider.displayData.description  "}" 
          Write-Log -Level error "`n[ERROR]: Please open wf.msc to remove the blocking rule if provider is windows firewall" 
        }
      }
    }
    catch {
      Write-Log -Level verbose  "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
      Write-Log -Level warning "`n[WARNING]: Cannot validate local WFP settings" 
    }

  }
    
  if ($PortAlive -eq $false) {
    $Script:ValidationPass = $false
  }

}



###If the Vmbus driver is running, the script does a platform invoke to call Win32 function DhcpRequestParams to query the DHCP server for option 245. Since Azure VMs must be configured for dynamic IP addresses, and option 245 is specific to Microsoft Azure, this confirms the VM is running in Microsoft Azure.
$source = @" 
using System; 
using System.Collections.Generic; 
using System.Text; 
using System.Runtime.InteropServices; 
using System.ComponentModel; 
using System.Net.NetworkInformation; 
 
namespace Microsoft.WindowsAzure.Internal 
{ 
    /// <summary> 
    /// A simple DHCP client. 
    /// </summary> 
    public class DhcpClient : IDisposable 
    { 
        public DhcpClient() 
        { 
            uint version; 
            int err = NativeMethods.DhcpCApiInitialize(out version); 
            if (err != 0) 
                throw new Win32Exception(err); 
        } 
 
        public void Dispose() 
        { 
            NativeMethods.DhcpCApiCleanup(); 
        } 
 
        /// <summary> 
        /// Gets the available interfaces that are enabled for DHCP. 
        /// </summary> 
        /// <remarks> 
        /// The operational status of the interface is not assessed. 
        /// </remarks> 
        /// <returns></returns> 
        public static IEnumerable<NetworkInterface> GetDhcpInterfaces() 
        { 
            foreach (NetworkInterface nic in NetworkInterface.GetAllNetworkInterfaces()) 
            { 
                if (nic.NetworkInterfaceType != NetworkInterfaceType.Ethernet) continue; 
                if (!nic.Supports(NetworkInterfaceComponent.IPv4)) continue; 
                IPInterfaceProperties props = nic.GetIPProperties(); 
                if (props == null) continue; 
                IPv4InterfaceProperties v4props = props.GetIPv4Properties(); 
                if (v4props == null) continue; 
                if (!v4props.IsDhcpEnabled) continue; 
 
                yield return nic; 
            } 
        } 
 
        /// <summary> 
        /// Requests DHCP parameter data. 
        /// </summary> 
        /// <remarks> 
        /// Windows serves the data from a cache when possible.   
        /// With persistent requests, the option is obtained during boot-time DHCP negotiation. 
        /// </remarks> 
        /// <param name="optionId">the option to obtain.</param> 
        /// <param name="isVendorSpecific">indicates whether the option is vendor-specific.</param> 
        /// <param name="persistent">indicates whether the request should be persistent.</param> 
        /// <returns></returns> 
        public byte[] DhcpRequestParams(string adapterName, uint optionId) 
        { 
            uint bufferSize = 1024; 
        Retry: 
            IntPtr buffer = Marshal.AllocHGlobal((int)bufferSize); 
            try 
            { 
                NativeMethods.DHCPCAPI_PARAMS_ARRAY sendParams = new NativeMethods.DHCPCAPI_PARAMS_ARRAY(); 
                sendParams.nParams = 0; 
                sendParams.Params = IntPtr.Zero; 
 
                NativeMethods.DHCPCAPI_PARAMS recv = new NativeMethods.DHCPCAPI_PARAMS(); 
                recv.Flags = 0x0; 
                recv.OptionId = optionId; 
                recv.IsVendor = false; 
                recv.Data = IntPtr.Zero; 
                recv.nBytesData = 0; 
 
                IntPtr recdParamsPtr = Marshal.AllocHGlobal(Marshal.SizeOf(recv)); 
                try 
                { 
                    Marshal.StructureToPtr(recv, recdParamsPtr, false); 
 
                    NativeMethods.DHCPCAPI_PARAMS_ARRAY recdParams = new NativeMethods.DHCPCAPI_PARAMS_ARRAY(); 
                    recdParams.nParams = 1; 
                    recdParams.Params = recdParamsPtr; 
 
                    NativeMethods.DhcpRequestFlags flags = NativeMethods.DhcpRequestFlags.DHCPCAPI_REQUEST_SYNCHRONOUS; 
 
                    int err = NativeMethods.DhcpRequestParams( 
                        flags, 
                        IntPtr.Zero, 
                        adapterName, 
                        IntPtr.Zero, 
                        sendParams, 
                        recdParams, 
                        buffer, 
                        ref bufferSize, 
                        null); 
 
                    if (err == NativeMethods.ERROR_MORE_DATA) 
                    { 
                        bufferSize *= 2; 
                        goto Retry; 
                    } 
 
                    if (err != 0) 
                        throw new Win32Exception(err); 
 
                    recv = (NativeMethods.DHCPCAPI_PARAMS)  
                        Marshal.PtrToStructure(recdParamsPtr, typeof(NativeMethods.DHCPCAPI_PARAMS)); 
 
                    if (recv.Data == IntPtr.Zero) 
                        return null; 
 
                    byte[] data = new byte[recv.nBytesData]; 
                    Marshal.Copy(recv.Data, data, 0, (int)recv.nBytesData); 
                    return data; 
                } 
                finally 
                { 
                    Marshal.FreeHGlobal(recdParamsPtr); 
                } 
            } 
            finally 
            { 
                Marshal.FreeHGlobal(buffer); 
            } 
        } 
 
        ///// <summary> 
        ///// Unregisters a persistent request. 
        ///// </summary> 
        //public void DhcpUndoRequestParams() 
        //{ 
        //    int err = NativeMethods.DhcpUndoRequestParams(0, IntPtr.Zero, null, this.ApplicationID); 
        //    if (err != 0) 
        //        throw new Win32Exception(err); 
        //} 
 
        #region Native Methods 
    } 
 
    internal static partial class NativeMethods 
    { 
        public const uint ERROR_MORE_DATA = 124; 
 
        [DllImport("dhcpcsvc.dll", EntryPoint = "DhcpRequestParams", CharSet = CharSet.Unicode, SetLastError = false)] 
        public static extern int DhcpRequestParams( 
            DhcpRequestFlags Flags, 
            IntPtr Reserved, 
            string AdapterName, 
            IntPtr ClassId, 
            DHCPCAPI_PARAMS_ARRAY SendParams, 
            DHCPCAPI_PARAMS_ARRAY RecdParams, 
            IntPtr Buffer, 
            ref UInt32 pSize, 
            string RequestIdStr 
            ); 
 
        [DllImport("dhcpcsvc.dll", EntryPoint = "DhcpUndoRequestParams", CharSet = CharSet.Unicode, SetLastError = false)] 
        public static extern int DhcpUndoRequestParams( 
            uint Flags, 
            IntPtr Reserved, 
            string AdapterName, 
            string RequestIdStr); 
 
        [DllImport("dhcpcsvc.dll", EntryPoint = "DhcpCApiInitialize", CharSet = CharSet.Unicode, SetLastError = false)] 
        public static extern int DhcpCApiInitialize(out uint Version); 
 
        [DllImport("dhcpcsvc.dll", EntryPoint = "DhcpCApiCleanup", CharSet = CharSet.Unicode, SetLastError = false)] 
        public static extern int DhcpCApiCleanup(); 
 
        [Flags] 
        public enum DhcpRequestFlags : uint 
        { 
            DHCPCAPI_REQUEST_PERSISTENT = 0x01, 
            DHCPCAPI_REQUEST_SYNCHRONOUS = 0x02, 
            DHCPCAPI_REQUEST_ASYNCHRONOUS = 0x04, 
            DHCPCAPI_REQUEST_CANCEL = 0x08, 
            DHCPCAPI_REQUEST_MASK = 0x0F 
        } 
 
        [StructLayout(LayoutKind.Sequential)] 
        public struct DHCPCAPI_PARAMS_ARRAY 
        { 
            public UInt32 nParams; 
            public IntPtr Params; 
        } 
 
        [StructLayout(LayoutKind.Sequential)] 
        public struct DHCPCAPI_PARAMS 
        { 
            public UInt32 Flags; 
            public UInt32 OptionId; 
            [MarshalAs(UnmanagedType.Bool)]  
            public bool IsVendor; 
            public IntPtr Data; 
            public UInt32 nBytesData; 
        } 
        #endregion 
    } 
} 
"@ 


#Utility function to check IP range. 
function checkSubnet ([string]$cidr, [string]$ip) {
  
  $network, [int]$subnetlen = $cidr.Split('/')

  $mskarray = ([Net.IPAddress]([convert]::ToInt64(("1" * $subnetlen + "0" * (32 - $subnetlen)), 2))).GetAddressBytes()
  $ipAddressBytes = ([Net.IPAddress]::Parse($ip)).GetAddressBytes()

  $IPNetworkAddress = @()

  for ($i = 0; $i -le 3; $i++) {
    $IPNetworkAddress += $ipAddressBytes[$i] -band $mskarray[3 - $i]
  }

  $IPNetworkAddressString = $IPNetworkAddress -Join "."

  return ($IPNetworkAddressString -eq $network)
}




###Use the sample script from https://gallery.technet.microsoft.com/scriptcenter/Detect-Windows-Azure-aed06d51 to detect the Azure VM. 
Function Confirm-AzureVM {

  Add-Type -TypeDefinition $source  
  $detected = $False 
 
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Serviceprocess') 
 
  $vmbus = [System.ServiceProcess.ServiceController]::GetDevices() | Where-Object { $_.Name -eq 'vmbus' } 
 
  If ($vmbus.Status -eq 'Running') { 
    $client = New-Object Microsoft.WindowsAzure.Internal.DhcpClient 
    try { 
      [Microsoft.WindowsAzure.Internal.DhcpClient]::GetDhcpInterfaces() | ForEach-Object {  
        $val = $client.DhcpRequestParams($_.Id, 245) 
        if ($val -And $val.Length -eq 4) { 
          $detected = $True 
          return $detected
        } 
      } 
    }
    finally { 
      $client.Dispose() 
    }     
  } 
  return $detected
    
} 

##############################
#.SYNOPSIS
# Get the client IP region
#
#.DESCRIPTION
# Get the public Azure IP range and determine the region for the specified IP address. 
#
#.PARAMETER IPaddress
# IP address to determine the region. 
#
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
function GetIPRegion ($IPaddress) {

  #download the public IP range from MS site. 
  If ((Test-Path $Script:LogDirectory"\publicips.xml") -eq $false) {
        
    $stream = (New-Object System.Net.WebClient).DownloadString("https://www.microsoft.com/en-us/download/confirmation.aspx?id=41653")
    $stream -match "(https:\/\/download.microsoft.com\/download.*?\.xml)"
    (New-Object System.Net.WebClient).DownloadString([string]$matches[0]) | Out-File $Script:LogDirectory"\publicips.xml"

    ##PS2.0 does not support Invoke-WebRequest 
    #$FirstPage = Invoke-WebRequest -Uri https://www.microsoft.com/en-us/download/confirmation.aspx?id=41653 -Method Get -UseBasicParsing
    # Invoke-WebRequest -Uri ($FirstPage.Links | where {$_.outerhtml -like "*Click here*"}).href[0] -OutFile $Script:LogDirectory"\publicips.xml"
    #$msg = "Download " + ($FirstPage.Links | where {$_.outerhtml -like "*Click here*"}).href[0]
    #Write-Host $msg 
  }
  $inRegion = $null
  [xml]$PublicIPXML = Get-Content $Script:LogDirectory"\publicips.xml"
  $Regions = $PublicIPXML.AzurePublicIpAddresses.Region

  #check if ip belongs to azure public 
  foreach ($region in $Regions ) {     
 
    foreach ($range in $region.iprange) {
      if ((checkSubnet $range.subnet $IPaddress) -eq $true) {
        $inRegion = $region.name
        break
      }

    }
    if ($inRegion -ne $null) { break }  
  }

  if ($inRegion -ne $null) {
    Write-Log -Level verbose "[OK]: IP $IPaddress region is $inRegion"
  }
  else
  { Write-Log -Level warning "`n[WARNING]: IP $IPaddress region cannot be detected from Azure Public IP range" }

  return $inRegion
    
}


##############################
#.SYNOPSIS
# Get the public IP of client. 
#
#.DESCRIPTION
# Call into  internet IP location service to determine the public IP of client. 
#
#.PARAMETER 
#  
#
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
Function GetClientPIP {
    
  $clientIP = $null
  try {
    #Call internet service to get the public IP of the VM.
    $result = (New-Object System.Net.WebClient).DownloadString("http://ipv4bot.whatismyipaddress.com")
    #$result = (Invoke-WebRequest ipv4bot.whatismyipaddress.com).Content 
    $ClientIP = $result.trim()

    if ($ClientIP -eq $null) {
      $result = (New-Object System.Net.WebClient).DownloadString("http://ifconfig.me/ip")
      #$result = (Invoke-WebRequest ifconfig.me/ip).Content    
      $ClientIP = $result.trim()
    }
  }
  catch {
    Write-Log -Level verbose "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)" 
    $clientIP = $null
  }
          
  return $clientIP
    
}

##############################
#.SYNOPSIS
# Validate the client IP region if it is Azure VM and SMB version < 3.0.
#
#.DESCRIPTION
#Long description
#
#.PARAMETER StorageIP
# Storage account IP. 
#
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
Function ValidateClientRegion($StorageIP) {
    
  $ClientIP = $null
  $StorageRegion = $null
  $result = $false
  $ClientRegion = $null

  $StorageRegion = GetIPRegion $storageIP

  if ($StorageRegion -eq $null) {
    Write-Log -Level warning "`n[WARNING]: Cannot determine the region of Storage Account on this client, please make sure you mount share from Azure VM in the same region as Storage Account, please refer to https://aka.ms/azfilediagnostics for more information" 
    return
  }
  else { Write-Log -Level success "`n[OK]: Storage Account  region is $($StorageRegion)" }

  #First check if it is Azure VM
  try {
    $result = Confirm-AzureVM
  }
  catch {
    ####PS2.0 has some issue with calling add-type. workaround is to use client public IP.
    $clientIp = GetClientPIP 

    if ($ClientIP -ne $null) {
      $ClientRegion = GetIPRegion $ClientIP

      if ($ClientRegion -ne $null) {

        $result = $true
      }
    }
  }


  if ($result -eq $true) {

    Write-Log -Level success "`n[OK]: Script is running on a Azure VM, continue checking client IP region" 
            
    if ($clientIP -eq $null) {
      $clientIp = GetClientPIP
    }

    if ($ClientIP -eq $null) {

      Write-Log -Level warning "`n[WARNING]: Cannot determine client Public IP. SMB 2.1 does not support encryption, Please make sure Azure VM is in the same region as storage account" 
      return
                
    }
    Write-Log -Level success "`n[OK]: Azure VM Public IP address is $ClientIP" 
            

    if ($ClientRegion -eq $null) {
      $ClientRegion = GetIPRegion $ClientIP
    }

    if ($ClientRegion -eq $null) {
      Write-Log -Level warning  "`n[WARNING]: Cannot determine Azure VM region, SMB 2.1 does not support encryption, Please make sure Azure VM is in the same region as storage account"  
      return
    }

    Write-Log -Level success "`n[OK]: Azure VM region is $ClientRegion" 
 
    if ($StorageRegion -ne $ClientRegion) {
      Write-Log -Level error "`n[ERROR]: Azure VM region mismatches with Storage Account Region. SMB 2.1 does not support encryption, Please make sure Azure VM is in the same region as storage account. " 
      $Script:ValidationPass = $false
    }
    else {
      Write-Log -Level success  "`n[OK]: Azure VM region matches up with Storage Account region" 
      Write-Log -Level warning "`n[WARNING]: Please also make sure -Secure transfer required- option (Login to Azure Portal, Navigate to Storage Account and configuration blade) is Disabled when mounting share from client supporting SMB2 Version only. more information, please refer to https://docs.microsoft.com/en-us/azure/storage/storage-require-secure-transfer"
    }
            
  }
  else {
    Write-Log -Level error "`n[ERROR]: Client does not appear to be a Azure VM in the same region as Storage Account. Please either upgrade to client supporting SMB3 or try from Azure VM, please refer to https://aka.ms/azfilediagnostics for more information" 
    $Script:ValidationPass = $false
  }
} 


##############################
#.SYNOPSIS
# Start packet tracing + SMB redirector tracing. it requires elevated rights. 
#
#.DESCRIPTION
#Long description
#
#.PARAMETER TraceFilePath
#Parameter description
#
#.PARAMETER ipaddr
#Parameter description
#
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
function Start-PacketTrace { 
  param 
  (         
    [string]$TraceFilePath, 
    [string]$ipaddr
  ) 
  try { 

    $OutErrorFile = "$Script:LogDirectory\netsh-err.txt" 
    $OutStdFile = "$Script:LogDirectory\netsh-std.txt" 

    if ($script:psver -lt [System.Version]"4.0") { 
      $Process = Start-Process "$($env:windir)\System32\netsh.exe" -ArgumentList "trace start provider={20C46239-D059-4214-A11E-7D6769CBE020} capture=yes overwrite=yes report=no tracefile=$TraceFilePath Ethernet.Type=IPv4 IPv4.Address=$ipaddr" -Wait -PassThru -RedirectStandardError $OutErrorFile -RedirectStandardOutput $OutStdFile
        
    }        
    else {
      $Process = Start-Process "$($env:windir)\System32\netsh.exe" -ArgumentList "trace start provider={20C46239-D059-4214-A11E-7D6769CBE020} capture=yes overwrite=yes report=no tracefile=$TraceFilePath Ethernet.Type=IPv4 IPv4.Address=$ipaddr" -Wait -NoNewWindow  -PassThru -RedirectStandardError $OutErrorFile -RedirectStandardOutput $OutStdFile
        
    }
        
    if (($Process.ExitCode -lt 0 ) -or ($Process.ExitCode -gt 3010 ) ) { 
      throw "Failed to start the packet trace. Netsh exited with an exit code [$($Process.ExitCode)]" 
    }
    else { 
      Write-Log -Level info "`nSuccessfully start netsh packet capture. Capturing all activities to [$($TraceFilePath)]" 
    } 
  }
  catch { 
    Write-Log -Level verbose  "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)" 
  } 
    
} 

function Stop-PacketTrace { 
  try { 
    Write-Log -Level info "`nStopping Netsh trace, Please be patient as NetSH retrieves the packet captures..."

    $OutErrorFile = "$Script:LogDirectory\netsh-err.txt" 
    $OutStdFile = "$Script:LogDirectory\netsh-std.txt" 

    if ($script:psver -lt [System.Version]"4.0") { 
      $Process = Start-Process "$($env:windir)\System32\netsh.exe" -ArgumentList "trace stop" -Wait -PassThru -RedirectStandardError $OutErrorFile -RedirectStandardOutput $OutStdFile
    }        
    else {
      $Process = Start-Process "$($env:windir)\System32\netsh.exe" -ArgumentList "trace stop" -Wait -NoNewWindow  -PassThru -RedirectStandardError $OutErrorFile -RedirectStandardOutput $OutStdFile
                    

    }

        

    if ((Get-Content  $OutErrorFile) -eq 'There is no trace session currently in progress.') { 
      Write-Verbose -Message 'There are no trace sessions currently in progress' 
    }
    elseif (($Process.ExitCode -lt 0 ) -or ($Process.ExitCode -gt 3010 ) ) { 
      throw "Cannot stop netsh tracing. Netsh exited with an exit code [$($Process.ExitCode)]" 
    }
    else { 
      Write-Log -Level info  "`nSuccessfully stop netsh packet capture"
    } 
  }
  catch { 
    Write-Log -Level verbose  "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)" 
  } 
} 


##############################
#.SYNOPSIS
# Map drive on behalf of user. 
#
#.DESCRIPTION
# It will check if there is any existing mapped drive for the requested UNC path. if yes, bails out and prompt user. 
# Prompt user to choose Diagnostic/Persistent options when mapping drive. 
#.PARAMETER FileSharePath
# Full UNC path like \\storageacount.file.core.windows.net\filesharename. 
#
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
function MapDrive ($FileSharePath) {
  ### Win32_MappedLogicalDisk had an issue that did not return the UNC path. but it appears to be fixed on OS now. 
  $Drives = Get-WmiObject -Class Win32_MappedLogicalDisk

  if ($drives -ne $null) {
    foreach ($drive in $drives) {
      if ($drive.ProviderName -eq $filesharepath) {
        Write-Log -Level warning "`n[WARNING]: there is already an existing mapped drive to $filesharepath in admin session. if you cannot see the mapped drive in non-admin sessoin, please refer to https://technet.microsoft.com/library/ee844140.aspx on how to fix it"
        return 
      }
    }
  }

  if ($FileSharePath -ne $null) {

    $option = [System.StringSplitOptions]::RemoveEmptyEntries
    $StorageAccountName = ($FileSharePath.split("\", $option))[0]
    $username = "Azure\$(($StorageAccountName.split('.'))[0])"

    <#there is an issue with -AsSecureString because it will exit with "xF"    
        [System.Security.SecureString]$SAccountkey = Read-Host "Please type Storage Account Access Key" 
        [String]$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SAccountkey))
        #>
        

    $password = Read-Host "`nPlease type Storage Account Access Key" 

    do {
 
      $drivename = Read-Host -Prompt "`nPlease type drive letter like Z: or *"
    }while ($drivename -notmatch "^(\*|[a-zA-Z]:)$") 
        
    $Persist = $false
    $title = $null
    $message = "`nDo you want to make persistent mapped drive?" 
    $option1 = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "persistent drive"
    $option2 = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No persisten drive"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($option1 , $option2)
    $result = $host.ui.PromptForChoice($title, $message, $options, 1) 

    switch ($result) {
      0 { $Persist = $true }
      1 { $Persist = $false }
    }

    if ($Script:adminmode) {
      $Diagnostic = $false
      $title = $null
      $message = "`nDo you want to turn on diagnostics SMB/Packet trace?" 
      $option1 = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Turn on tracing"
      $option2 = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No tracing"
      $options = [System.Management.Automation.Host.ChoiceDescription[]]($option1 , $option2)
      $result = $host.ui.PromptForChoice($title, $message, $options, 1) 

      switch ($result) {
        0 { $Diagnostic = $true }
        1 { $Diagnostic = $false }
      }
    }

    #Write-Log -level info "`n======Start mapping drive $drivename to $filesharepath with user name $username" 

    if (($Diagnostic -eq $true) -and ($Script:adminmode -eq $true)) {

      Start-PacketTrace $Script:LogDirectory\packet.etl $destIP
    }
        
    $OutErrorFile = "$Script:LogDirectory\netuse-err.txt" 
    $OutStdFile = "$Script:LogDirectory\netuse-std.txt"

    Try {
      if ($Persist -eq $true) {
        Write-Log -Level info "`n====Running command, Net use $drivename $FileSharePath /User:$username ******************* /PERSISTENT:YES" 
        if ($script:psver -lt [System.Version]"4.0") { 
          $Process = Start-Process "$($env:windir)\System32\net.exe" -ArgumentList " use $drivename $FileSharePath /User:$username $password /PERSISTENT:YES" -Wait -PassThru -RedirectStandardError $OutErrorFile -RedirectStandardOutput $OutStdFile
        }
        else {
          $Process = Start-Process "$($env:windir)\System32\net.exe" -ArgumentList " use $drivename $FileSharePath /User:$username $password /PERSISTENT:YES" -Wait -NoNewWindow  -PassThru -RedirectStandardError $OutErrorFile -RedirectStandardOutput $OutStdFile
        }
            
      }
      else {
        Write-Log -Level info "`n====Running command, Net use $drivename $FileSharePath /User:$username ******************* "

        if ($script:psver -lt [System.Version]"4.0") { 
          $Process = Start-Process "$($env:windir)\System32\net.exe" -ArgumentList " use $drivename $FileSharePath /User:$username $password" -Wait -PassThru -RedirectStandardError $OutErrorFile -RedirectStandardOutput $OutStdFile
        }
        else {
          $Process = Start-Process "$($env:windir)\System32\net.exe" -ArgumentList " use $drivename $FileSharePath /User:$username $password" -Wait -NoNewWindow -PassThru -RedirectStandardError $OutErrorFile -RedirectStandardOutput $OutStdFile
        }
      }
            
    }
    catch {
      Write-Log -Level information "process exit code is $($Process.ExitCode)"
    }
        
    
    if (($Process.ExitCode -eq 0) -or ($Process.ExitCode -eq 1)) {
  
      $Drives = Get-WmiObject -Class Win32_MappedLogicalDisk
      if ($drives -ne $null) {
        foreach ($drive in $drives) {
          if ($drive.ProviderName -eq $filesharepath) {
            Write-Log -Level success "Drive $drive.name is mapped to $drive.ProviderName"
          }
        }
      }

      Write-Log -Level success "`n[OK]: Validation is done and Mapped drive is created successfully" 
      if ($Script:adminmode -eq $true) {
        Write-Log -Level warning "`n[WARNING]: Map drive in admin session successfuly.If you cannot see the mapped drive in File Explorer, you can follow steps in https://technet.microsoft.com/library/ee844140.aspx to configure the EnableLinkedConnections registry value."
      }
 
       
    }
    else {
      $errormsg = "`n[ERROR]: Map drive failed and Net use returns the error: " + (Get-Content  $OutErrorFile)
      Write-Log -Level error $errormsg 
       
      if ( ($errormsg -match "Access is Denied") -and ([System.Version]$Script:smbver -lt [System.Version]"3.0") ) {
        Write-Log -Level error "`n[ERROR]: Net use returns with Access Denied error, please go to Azure Portal, navigate to STorage Account -> Configuration -> Secure Transfer Required, ensure it is set to Disabled" 
      }

      if ( ($errormsg -match "Not enough quota is available to process this command" ) -and ([System.Version]$Script:smbver -lt [System.Version]"3.0") ) {
        Write-Log -Level error "`n[ERROR]: Net use returns with quota error, please reduce the number of concurrent open handles by closing some handles, and then retry" 
      }

      ### if System error 5 happen, we should hint Customer
      $title = $null
      $message = "`nDid mount fail with error: System error 5 has occurred? " 
      $option1 = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "System error 5 has occurred"
      $option2 = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "System error 5 has NOT occurred"
      $options = [System.Management.Automation.Host.ChoiceDescription[]]($option1 , $option2)
      $result = $host.ui.PromptForChoice($title, $message, $options, 0)
			
      switch ($result) {
        0 {
          if ( ([System.Version]$Script:smbver -lt [System.Version]"3.0") ) {
            ### For SMB2.1 client
            Write-Log -Level success "The Azure file share failed to mount because SMB encryption is required and the client does not support encryption or the virtual network and firewall feature is enabled on the storage account and is blocking access. To resolve this issue, follow the steps in the Azure Files troubleshooting guide: https://docs.microsoft.com/azure/storage/files/storage-troubleshoot-windows-file-connection-problems#error-5-when-you-mount-an-azure-file-share"
          }
          else {
            ### For SMB3.0 client
            Write-Log -Level success "The Azure file share failed to mount because the virtual network and firewall feature is enabled on the storage account and is blocking access. To resolve this issue, follow the steps in the Azure Files troubleshooting guide: https://docs.microsoft.com/azure/storage/files/storage-troubleshoot-windows-file-connection-problems#cause-2-virtual-network-or-firewall-rules-are-enabled-on-the-storage-account"
          }
        }
        1 {
          break
        }
      }
      ### end of System error 5 hint

      Write-Log -Level error "`n[ERROR]: you can send the script output file in the script folder along with the dianose trace (if turned on) to microsoft support for further investigation"

    }

    if (($Diagnostic -eq $true) -and ($Script:adminmode -eq $true)) {
      Stop-PacketTrace
    }
    Write-Log -Level warning "========================================[END]============================================"
  }
}






###################################################################################################################################################################################################
###################################################################################################################################################################################################


#$ErrorActionPreference = 'SilentlyContinue'

$CurrentTime = Get-Date -Format "MM-dd-yyyy_HH-mm-ss"
$Script:LogDirectory = Split-Path $MyInvocation.MyCommand.Path -Parent
$Script:logfilepath = "$Script:LogDirectory\\AzFileDiag-$($CurrentTime).txt"

$Script:StorageAccountNameValidationPattern = "^[a-z0-9`]{3,24}$"
$Script:ShareNameValidationPattern = "^[a-z0-9](?:[a-z0-9]|(\-(?!\-))){1,61}[a-z0-9]$"
$Script:UNCPathValidationPattern = "^\\\\[a-z0-9`]{3,24}(.file.core.windows.net|.file.core.chinacloudapi.cn|.file.core.cloudapi.de|.file.usgovcloudapi.net)\\([a-z0-9](?:[a-z0-9]|(\-(?!\-))){1,61}[a-z0-9])(\\[^\x00-\x1f`"\\/:|<>*?\uE000-\uF8FF]{1,255})*$"

#set default validtion pass value. 
$Script:ValidationPass = $true

$script:adminmode = $null
$Script:OSEnv = $null


Write-Log -Level warning "========================================[BEGINNING]============================================"
Write-Log -Level warning "Starting to validate the client environment at $($CurrentTime)"
Write-Log -Level warning "Output messages will be logged into AzFilediag-<Timestamp>.txt under the script folder as well." 

$Script:psver = [System.Version]$PSVersionTable.PSVersion
Write-Log -Level success "`n[OK]: Current PowerShell version is $($psver.ToString())"


###Detect Admin mode.
Write-Log -Level info "`n======Validate if it is Admin session, some of the validation steps require elevated rights"
[string[]]$argList = @('-NoProfile', '-NoExit', '-File', $MyInvocation.MyCommand.Path)
$argList += $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { "-$($_.Key)", "$($_.Value)" }
$argList += $MyInvocation.UnboundArguments
$script:adminmode = PromptAdminMode  $argList

###Detect Client OS version.
Write-Log -Level info "`n======Validate Client OS Version"
$Script:OSEnv = ValidateClientOS
if ($Script:ValidationPass -eq $false) {
  Write-Log -Level error "`n[Error]: Cannot get the client operating system version, exit the validation"  
  Write-Log -Level warning "==========================================[END]==============================================="
  exit
}

###Detect SMB client version.
Write-Log -Level info "`n======Validate SMB Version Client supports"
$Script:smbver = ValidateSMBver $Script:adminmode $Script:OSEnv
if ($Script:ValidationPass -eq $false) {
  Write-Log -Level error "`n[Error]: SMB client version validation fails, please refer to SMB version requirement in https://docs.microsoft.com/en-us/azure/storage/storage-dotnet-how-to-use-files#mount-the-file-share."  
  Write-Log -Level warning "==========================================[END]==============================================="
  exit
}

###only check KB3114025 if OS is windows 8.1/2012 R2. 
if ( ($Script:OSEnv -ne $null) -and ([System.Version]$Script:OSEnv.version -eq [System.Version]"6.3.9600")) {
  Write-Log -Level info "`n======Validate KB3114025 installation state for windows 8.1 or windows 2012 R2"
  ValidateKB3114025 $Script:OSEnv
}


###validate LmCompatibilityLevel
Write-Log -Level info "`n======Validate LmCompatibilityLevel setting on client"
ValidateLmCompatibilityLevel($Script:OSEnv)
if ($Script:ValidationPass -eq $false) {
  Write-Log -Level error "`n[Error]: LmCompatibilityLevel validation fails, System error 53 or system error 87 can occur if NTLMv1 communication is enabled on the client. Azure File storage supports only NTLMv2 authentication. LmCompatibilityLevel should be set to 3"  
  Write-Log -Level warning "==========================================[END]==============================================="
  exit
}


###get the file share path based on the script input. 
Write-Log -Level info "`n======Validate Azure Storage File Share Path Naming"
if (($UNCPath -eq $null) -and ($StorageAccountName -eq $null) ) {
  $FileSharePath = GetFileSharePath
}
elseif (($StorageAccountName -ne $null) -and ($fileshareName -ne $null) -and ($Environmentname -ne $null)) {
  $Environmentname = $Environmentname.ToLower()

  switch ($Environmentname) {
    "azurecloud" { $surffix = ".file.core.windows.net" }
    "azurechinacloud" { $surffix = ".file.core.chinacloudapi.cn" }
    "azuregermancloud" { $surffix = ".file.core.cloudapi.de" }
    "azureusgovernment" { $surffix = ".file.usgovcloudapi.net" }
    Default { $surffix = ".file.core.windows.net" }
 
  }
  $FileSharePath = "\\" + $StorageAccountName + $surffix + "\" + $FileShareName    
}
else {
  $FileSharePath = $UNCPath
}
Write-Log -Level success "[OK]: Azure File Share path is $FileSharePath " 

###Validate the name-ip mapping
Write-Log -Level info "`n======Validate Storage Account Name resolution"
$option = [System.StringSplitOptions]::RemoveEmptyEntries
$DestHost = ($FileSharePath.split("\", $option))[0]
try {
  #resolve the name to IPv4 address only for now, IPV6 may be added in future.    
  $result = [System.Net.Dns]::GetHostEntry($DestHost).AddressList | Where-Object { $_.AddressFamily -eq 'InterNetwork' }

  Write-Log -Level success "`n[OK]: Storage Account Name $DestHost is resolved to $($result.IPAddressToString)" 
  $destIP = $result.IPAddressToString
}
catch {
  Write-Log -Level verbose "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)" 
  $Script:ValidationPass = $false
}
if ($Script:ValidationPass -eq $false) {
  Write-Log -Level error "`n[ERROR]: Storage Account Name $DestHost cannot be resolved. Please make sure client DNS server is set properly"  
  Write-Log -Level warning "==========================================[END]==============================================="
  exit
}

###SMB2.0x case, client need to be located in the same region as the storage account and it is supposed to be Azure VM.
if ( ([System.Version]$Script:smbver -ge [System.Version]"2.0") -and ([System.Version]$Script:smbver -lt [System.Version]"3.0")) {
  Write-Log -Level info "`n======Validate Client IP region as SMB version lower than 3.0"
  ValidateClientRegion($destIP)
  if ($Script:ValidationPass -eq $false) {
    Write-Log -Level error "`n[ERROR]: Client region Validation fails. For security reasons, connections to Azure file shares are blocked if the communication channel is not encrypted and if the connection attempt is not made from the same datacenter where the Azure file shares reside. "  
    Write-Log -Level warning "==========================================[END]==============================================="
    exit
  }
}

###port reachability test.
Write-Log -Level info "`n======Validate port 445 reachability over Storage Account IP $destIP"
ValidateTCPPort $destIP
if ($Script:ValidationPass -eq $false) {
  Write-Log -Level error "`n[ERROR]: Port 445 is not reachable from this client, Exit the validation and please verify the network" 
  Write-Log -Level warning "==========================================[END]==============================================="
  exit
}


###start mapping the drive. 
if ($Script:ValidationPass -eq $true) {

  Write-Log -Level success "`n[OK]: Validation steps do not return any errors" 

  $title = $null
  $message = "`nDo you want to go ahead to map the drive with file share path $FileSharePath" 
  $option1 = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Map Drive"
  $option2 = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Skip map drive"
  $options = [System.Management.Automation.Host.ChoiceDescription[]]($option1 , $option2)
  $result = $host.ui.PromptForChoice($title, $message, $options, 0) 
    
  switch ($result) {
    0 { 
      MapDrive $FileSharePath
    }
    1 {
      Write-Log -Level warning "`nValidation is done, please map the drive manually" 
      Write-Log -Level warning "==========================================[END]==============================================="


    }
        
  }
    
}
else {

  Write-Log -Level warning "`nValidation fails, please review the script output for more detail" 
  Write-Log -Level warning "==========================================[END]==============================================="

}