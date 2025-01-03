﻿#requires -Version 3
# ==============================================================================================
# 
# Microsoft PowerShell Source File -- Created with SAPIEN Technologies PrimalScript 2007
# 
# NAME: Server/Workstation Inventory (CompInv_v2.ps1)
# 
# AUTHOR: Jesse Hamrick
# DATE  : 2/25/2009
# Web	: www.PowerShellPro.com
# COMMENT: Script Inventories Computers and sends results to an excel file.
# 
# ==============================================================================================

# ==============================================================================================
# Functions Section
# ==============================================================================================
# Function Name 'Get-WMILookup' - Gathers info using WMI and places results in Excel
# ==============================================================================================
Function Get-WMILookup 
{
  foreach ($StrComputer in $colComputers)
  {
    $GenItems1 = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $StrComputer
    $GenItems2 = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $StrComputer
    $SysItems1 = Get-WmiObject -Class Win32_BIOS -ComputerName $StrComputer
    $SysItems2 = Get-WmiObject -Class Win32_TimeZone -ComputerName $StrComputer
    $SysItems3 = Get-WmiObject -Class Win32_WmiSetting -ComputerName $StrComputer
    $ProcItems1 = Get-WmiObject -Class Win32_Processor -ComputerName $StrComputer
    $MemItems1 = Get-WmiObject -Class Win32_PhysicalMemory -ComputerName $StrComputer
    $memItems2 = Get-WmiObject -Class Win32_PhysicalMemoryArray -ComputerName $StrComputer
    $DiskItems = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $StrComputer
    $NetItems = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $StrComputer |`
    Where-Object -FilterScript {
      $_.IPEnabled -eq 'True'
    }
		
				
    # Populate General Sheet(1) with information
    foreach ($objItem in $GenItems1)
    {
      $Sheet1.Cells.Item($intRow, 1) = $StrComputer
      Switch($objItem.DomainRole)
      {
        0
        {
          $Sheet1.Cells.Item($intRow, 2) = 'Stand Alone Workstation'
        }
        1
        {
          $Sheet1.Cells.Item($intRow, 2) = 'Member Workstation'
        }
        2
        {
          $Sheet1.Cells.Item($intRow, 2) = 'Stand Alone Server'
        }
        3
        {
          $Sheet1.Cells.Item($intRow, 2) = 'Member Server'
        }
        4
        {
          $Sheet1.Cells.Item($intRow, 2) = 'Back-up Domain Controller'
        }
        5
        {
          $Sheet1.Cells.Item($intRow, 2) = 'Primary Domain Controller'
        }
        default
        {
          'Undetermined'
        }
      }
      $Sheet1.Cells.Item($intRow, 3) = $objItem.Manufacturer
      $Sheet1.Cells.Item($intRow, 4) = $objItem.Model
      $Sheet1.Cells.Item($intRow, 5) = $objItem.SystemType
      $Sheet1.Cells.Item($intRow, 6) = $objItem.NumberOfProcessors
      $Sheet1.Cells.Item($intRow, 7) = $objItem.TotalPhysicalMemory / 1024 / 1024
    }
    foreach ($objItem in $GenItems2)
    {
      $Sheet1.Cells.Item($intRow, 8) = $objItem.Caption
      $Sheet1.Cells.Item($intRow, 9) = $objItem.csdversion
    }
			
    #Populate Systems Sheet
    foreach ($objItem in $SysItems1)
    {
      $Sheet2.Cells.Item($intRow, 1) = $StrComputer
      $Sheet2.Cells.Item($intRow, 2) = $objItem.Name
      $Sheet2.Cells.Item($intRow, 3) = $objItem.SMBIOSbiosVersion
      $Sheet2.Cells.Item($intRow, 4) = $objItem.SerialNumber
    }
    foreach ($objItem in $SysItems2)
    {
      $Sheet2.Cells.Item($intRow, 5) = $objItem.Caption
    }
    foreach ($objItem in $SysItems3)
    {
      $Sheet2.Cells.Item($intRow, 6) = $objItem.BuildVersion
    }
				
    #Populate Processor Sheet		
    foreach ($objItem in $ProcItems1)
    {
      $Sheet3.Cells.Item($intRowCPU, 1) = $StrComputer
      $Sheet3.Cells.Item($intRowCPU, 2) = $objItem.DeviceID+' '+$objItem.Name
      $Sheet3.Cells.Item($intRowCPU, 3) = $objItem.Description
      $Sheet3.Cells.Item($intRowCPU, 4) = $objItem.family
      $Sheet3.Cells.Item($intRowCPU, 5) = $objItem.currentClockSpeed
      $Sheet3.Cells.Item($intRowCPU, 6) = $objItem.l2cacheSize
      $Sheet3.Cells.Item($intRowCPU, 7) = $objItem.UpgradeMethod
      $Sheet3.Cells.Item($intRowCPU, 8) = $objItem.SocketDesignation
      $intRowCPU = $intRowCPU + 1
    }
				
    #Populate Memory Sheet
    $bankcounter = 1
    foreach ($objItem in $memItems2)
    {
      $MemSlots = $objItem.MemoryDevices +1
			
      foreach ($objItem in $MemItems1)
      {
        $Sheet4.Cells.Item($intRowMem, 1) = $StrComputer
        $Sheet4.Cells.Item($intRowMem, 2) = 'Bank ' +$bankcounter
        if($objItem.BankLabel -eq '')
        {
          $Sheet4.Cells.Item($intRowMem, 3) = $objItem.DeviceLocator
        }
        Else
        {
          $Sheet4.Cells.Item($intRowMem, 3) = $objItem.BankLabel
        }
        $Sheet4.Cells.Item($intRowMem, 4) = $objItem.Capacity/1024/1024
        $Sheet4.Cells.Item($intRowMem, 5) = $objItem.FormFactor
        $Sheet4.Cells.Item($intRowMem, 6) = $objItem.TypeDetail
        $intRowMem = $intRowMem + 1
        $bankcounter = $bankcounter + 1
      }
      while($bankcounter -lt $MemSlots)	
      {
        $Sheet4.Cells.Item($intRowMem, 1) = $StrComputer
        $Sheet4.Cells.Item($intRowMem, 2) = 'Bank ' +$bankcounter
        $Sheet4.Cells.Item($intRowMem, 3) = 'is Empty'
        $Sheet4.Cells.Item($intRowMem, 4) = ''
        $Sheet4.Cells.Item($intRowMem, 5) = ''
        $Sheet4.Cells.Item($intRowMem, 6) = ''
        $intRowMem = $intRowMem + 1
        $bankcounter = $bankcounter + 1
      }
    }
			
			
    #Populate Disk Sheet
    foreach ($objItem in $DiskItems)
    {
      $Sheet5.Cells.Item($intRowDisk, 1) = $StrComputer
      Switch($objItem.DriveType)
      {
        2
        {
          $Sheet5.Cells.Item($intRowDisk, 2) = 'Floppy'
        }
        3
        {
          $Sheet5.Cells.Item($intRowDisk, 2) = 'Fixed Disk'
        }
        5
        {
          $Sheet5.Cells.Item($intRowDisk, 2) = 'Removable Media'
        }
        default
        {
          'Undetermined'
        }
      }
      $Sheet5.Cells.Item($intRowDisk, 3) = $objItem.DeviceID
      $Sheet5.Cells.Item($intRowDisk, 4) = $objItem.Size/1024/1024
      $Sheet5.Cells.Item($intRowDisk, 5) = $objItem.FreeSpace/1024/1024
      $intRowDisk = $intRowDisk + 1
    }
		
    #Populate Network Sheet
    foreach ($objItem in $NetItems)
    {
      $Sheet6.Cells.Item($intRowNet, 1) = $StrComputer
      $Sheet6.Cells.Item($intRowNet, 2) = $objItem.Caption+' (enabled)'
      $Sheet6.Cells.Item($intRowNet, 3) = $objItem.DHCPEnabled
      $Sheet6.Cells.Item($intRowNet, 4) = $objItem.IPAddress
      $Sheet6.Cells.Item($intRowNet, 5) = $objItem.IPSubnet
      $Sheet6.Cells.Item($intRowNet, 6) = $objItem.DefaultIPGateway
      $Sheet6.Cells.Item($intRowNet, 7) = $objItem.DNSServerSearchOrder
      $Sheet6.Cells.Item($intRowNet, 8) = $objItem.FullDNSRegistrationEnabled
      $Sheet6.Cells.Item($intRowNet, 9) = $objItem.WINSPrimaryServer
      $Sheet6.Cells.Item($intRowNet, 10) = $objItem.WINSSecondaryServer
      $Sheet6.Cells.Item($intRowNet, 11) = $objItem.WINSEnableLMHostsLookup
      $intRowNet = $intRowNet + 1
    }
		
    $intRow = $intRow + 1
    $intRowCPU = $intRowCPU + 1
    $intRowMem = $intRowMem + 1
    $intRowDisk = $intRowDisk + 1
    $intRowNet = $intRowNet + 1
  }
}

# ==============================================================================================
# Function Name 'Get-WMILookupCred'-Uses Alternative Credential-Gathers info using WMI.
# ==============================================================================================
Function Get-WMILookupCred 
{
  foreach ($StrComputer in $colComputers)
  {
    $GenItems1 = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $StrComputer -Credential $cred
    $GenItems2 = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $StrComputer -Credential $cred
    $SysItems1 = Get-WmiObject -Class Win32_BIOS -ComputerName $StrComputer -Credential $cred
    $SysItems2 = Get-WmiObject -Class Win32_TimeZone -ComputerName $StrComputer -Credential $cred
    $SysItems3 = Get-WmiObject -Class Win32_WmiSetting -ComputerName $StrComputer -Credential $cred
    $ProcItems1 = Get-WmiObject -Class Win32_Processor -ComputerName $StrComputer -Credential $cred
    $MemItems1 = Get-WmiObject -Class Win32_PhysicalMemory -ComputerName $StrComputer -Credential $cred
    $memItems2 = Get-WmiObject -Class Win32_PhysicalMemoryArray -ComputerName $StrComputer -Credential $cred
    $DiskItems = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $StrComputer -Credential $cred
    $NetItems = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $StrComputer -Credential $cred |`
    Where-Object -FilterScript {
      $_.IPEnabled -eq 'True'
    }
		
				
    # Populate General Sheet(1) with information
    foreach ($objItem in $GenItems1)
    {
      $Sheet1.Cells.Item($intRow, 1) = $StrComputer
      Switch($objItem.DomainRole)
      {
        0
        {
          $Sheet1.Cells.Item($intRow, 2) = 'Stand Alone Workstation'
        }
        1
        {
          $Sheet1.Cells.Item($intRow, 2) = 'Member Workstation'
        }
        2
        {
          $Sheet1.Cells.Item($intRow, 2) = 'Stand Alone Server'
        }
        3
        {
          $Sheet1.Cells.Item($intRow, 2) = 'Member Server'
        }
        4
        {
          $Sheet1.Cells.Item($intRow, 2) = 'Back-up Domain Controller'
        }
        5
        {
          $Sheet1.Cells.Item($intRow, 2) = 'Primary Domain Controller'
        }
        default
        {
          'Undetermined'
        }
      }
      $Sheet1.Cells.Item($intRow, 3) = $objItem.Manufacturer
      $Sheet1.Cells.Item($intRow, 4) = $objItem.Model
      $Sheet1.Cells.Item($intRow, 5) = $objItem.SystemType
      $Sheet1.Cells.Item($intRow, 6) = $objItem.NumberOfProcessors
      $Sheet1.Cells.Item($intRow, 7) = $objItem.TotalPhysicalMemory / 1024 / 1024
    }
    foreach ($objItem in $GenItems2)
    {
      $Sheet1.Cells.Item($intRow, 8) = $objItem.Caption
      $Sheet1.Cells.Item($intRow, 9) = $objItem.csdversion
    }
			
    #Populate Systems Sheet
    foreach ($objItem in $SysItems1)
    {
      $Sheet2.Cells.Item($intRow, 1) = $StrComputer
      $Sheet2.Cells.Item($intRow, 2) = $objItem.Name
      $Sheet2.Cells.Item($intRow, 3) = $objItem.SMBIOSbiosVersion
      $Sheet2.Cells.Item($intRow, 4) = $objItem.SerialNumber
    }
    foreach ($objItem in $SysItems2)
    {
      $Sheet2.Cells.Item($intRow, 5) = $objItem.Caption
    }
    foreach ($objItem in $SysItems3)
    {
      $Sheet2.Cells.Item($intRow, 6) = $objItem.BuildVersion
    }
				
    #Populate Processor Sheet		
    foreach ($objItem in $ProcItems1)
    {
      $Sheet3.Cells.Item($intRowCPU, 1) = $StrComputer
      $Sheet3.Cells.Item($intRowCPU, 2) = $objItem.DeviceID+' '+$objItem.Name
      $Sheet3.Cells.Item($intRowCPU, 3) = $objItem.Description
      $Sheet3.Cells.Item($intRowCPU, 4) = $objItem.family
      $Sheet3.Cells.Item($intRowCPU, 5) = $objItem.currentClockSpeed
      $Sheet3.Cells.Item($intRowCPU, 6) = $objItem.l2cacheSize
      $Sheet3.Cells.Item($intRowCPU, 7) = $objItem.UpgradeMethod
      $Sheet3.Cells.Item($intRowCPU, 8) = $objItem.SocketDesignation
      $intRowCPU = $intRowCPU + 1
    }
				
    #Populate Memory Sheet
    $bankcounter = 1
    foreach ($objItem in $memItems2)
    {
      $MemSlots = $objItem.MemoryDevices +1
			
      foreach ($objItem in $MemItems1)
      {
        $Sheet4.Cells.Item($intRowMem, 1) = $StrComputer
        $Sheet4.Cells.Item($intRowMem, 2) = 'Bank ' +$bankcounter
        if($objItem.BankLabel -eq '')
        {
          $Sheet4.Cells.Item($intRowMem, 3) = $objItem.DeviceLocator
        }
        Else
        {
          $Sheet4.Cells.Item($intRowMem, 3) = $objItem.BankLabel
        }
        $Sheet4.Cells.Item($intRowMem, 4) = $objItem.Capacity/1024/1024
        $Sheet4.Cells.Item($intRowMem, 5) = $objItem.FormFactor
        $Sheet4.Cells.Item($intRowMem, 6) = $objItem.TypeDetail
        $intRowMem = $intRowMem + 1
        $bankcounter = $bankcounter + 1
      }
      while($bankcounter -lt $MemSlots)	
      {
        $Sheet4.Cells.Item($intRowMem, 1) = $StrComputer
        $Sheet4.Cells.Item($intRowMem, 2) = 'Bank ' +$bankcounter
        $Sheet4.Cells.Item($intRowMem, 3) = 'is Empty'
        $Sheet4.Cells.Item($intRowMem, 4) = ''
        $Sheet4.Cells.Item($intRowMem, 5) = ''
        $Sheet4.Cells.Item($intRowMem, 6) = ''
        $intRowMem = $intRowMem + 1
        $bankcounter = $bankcounter + 1
      }
    }
			
			
    #Populate Disk Sheet
    foreach ($objItem in $DiskItems)
    {
      $Sheet5.Cells.Item($intRowDisk, 1) = $StrComputer
      Switch($objItem.DriveType)
      {
        2
        {
          $Sheet5.Cells.Item($intRowDisk, 2) = 'Floppy'
        }
        3
        {
          $Sheet5.Cells.Item($intRowDisk, 2) = 'Fixed Disk'
        }
        5
        {
          $Sheet5.Cells.Item($intRowDisk, 2) = 'Removable Media'
        }
        default
        {
          'Undetermined'
        }
      }
      $Sheet5.Cells.Item($intRowDisk, 3) = $objItem.DeviceID
      $Sheet5.Cells.Item($intRowDisk, 4) = $objItem.Size/1024/1024
      $Sheet5.Cells.Item($intRowDisk, 5) = $objItem.FreeSpace/1024/1024
      $intRowDisk = $intRowDisk + 1
    }
		
    #Populate Network Sheet
    foreach ($objItem in $NetItems)
    {
      $Sheet6.Cells.Item($intRowNet, 1) = $StrComputer
      $Sheet6.Cells.Item($intRowNet, 2) = $objItem.Caption+' (enabled)'
      $Sheet6.Cells.Item($intRowNet, 3) = $objItem.DHCPEnabled
      $Sheet6.Cells.Item($intRowNet, 4) = $objItem.IPAddress
      $Sheet6.Cells.Item($intRowNet, 5) = $objItem.IPSubnet
      $Sheet6.Cells.Item($intRowNet, 6) = $objItem.DefaultIPGateway
      $Sheet6.Cells.Item($intRowNet, 7) = $objItem.DNSServerSearchOrder
      $Sheet6.Cells.Item($intRowNet, 8) = $objItem.FullDNSRegistrationEnabled
      $Sheet6.Cells.Item($intRowNet, 9) = $objItem.WINSPrimaryServer
      $Sheet6.Cells.Item($intRowNet, 10) = $objItem.WINSSecondaryServer
      $Sheet6.Cells.Item($intRowNet, 11) = $objItem.WINSEnableLMHostsLookup
      $intRowNet = $intRowNet + 1
    }
		
    $intRow = $intRow + 1
    $intRowCPU = $intRowCPU + 1
    $intRowMem = $intRowMem + 1
    $intRowDisk = $intRowDisk + 1
    $intRowNet = $intRowNet + 1
  }
}

# =============================================================================================
# Function Name 'ListComputers' - Enumerates ALL computer objects in AD
# ==============================================================================================
Function Get-ListComputers 
{
  $strCategory = 'computer'

  $objDomain = New-Object -TypeName System.DirectoryServices.DirectoryEntry

  $objSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
  $objSearcher.SearchRoot = $objDomain
  $objSearcher.Filter = ("(objectCategory=$strCategory)")

  $colProplist = 'name'
  foreach ($i in $colProplist)
  {
    $objSearcher.PropertiesToLoad.Add($i)
  }

  $colResults = $objSearcher.FindAll()

  foreach ($objResult in $colResults)
  {
    $objComputer = $objResult.Properties
    $objComputer.name
  }
}

# ==============================================================================================
# Function Name 'Get-ListServers' - Enumerates ALL Servers objects in AD
# ==============================================================================================
Function Get-ListServers 
{
  $strCategory = 'computer'
  $strOS = 'Windows*Server*'

  $objDomain = New-Object -TypeName System.DirectoryServices.DirectoryEntry

  $objSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
  $objSearcher.SearchRoot = $objDomain
  $objSearcher.Filter = ("(&(objectCategory=$strCategory)(OperatingSystem=$strOS))")

  $colProplist = 'name'
  foreach ($i in $colProplist)
  {
    $objSearcher.PropertiesToLoad.Add($i)
  }

  $colResults = $objSearcher.FindAll()

  foreach ($objResult in $colResults)
  {
    $objComputer = $objResult.Properties
    $objComputer.name
  }
}

# ========================================================================
# Function Name 'Get-ListTextFile' - Enumerates Computer Names in a text file
# Create a text file and enter the names of each computer. One computer
# name per line. Supply the path to the text file when prompted.
# ========================================================================
Function Get-ListTextFile 
{
  $strText = Read-Host -Prompt 'Enter the path for the text file'
  $colComputers = Get-Content $strText
}

# ========================================================================
# Function Name 'SingleEntry' - Enumerates Computer from user input
# ========================================================================
Function Get-ManualEntry 
{
  $colComputers = Read-Host -Prompt 'Enter Computer Name or IP'
}

# ==============================================================================================
# Script Body
# ==============================================================================================
$erroractionpreference = 'SilentlyContinue'


#Gather info from user.
Write-Host -Object '********************************' 	-ForegroundColor Green
Write-Host -Object 'Computer Inventory Script' 			-ForegroundColor Green
Write-Host -Object 'By: Jesse Hamrick' 					-ForegroundColor Green
Write-Host -Object 'Created: 04/15/2009' 				-ForegroundColor Green
Write-Host -Object 'Contact: www.PowerShellPro.com' 	-ForegroundColor Green
Write-Host -Object '********************************' 	-ForegroundColor Green
Write-Host -Object ' '
Write-Host -Object 'Admin rights are required to enumerate information.' 	-ForegroundColor Green
Write-Host -Object 'Would you like to use an alternative credential?'		-ForegroundColor Green
$credResponse = Read-Host -Prompt '[Y] Yes, [N] No'
If($credResponse -eq 'y')
{
  $cred = Get-Credential -UserName DOMAIN\USER
}
Write-Host -Object ' '
Write-Host -Object 'Which computer resources would you like in the report?'	-ForegroundColor Green
$strResponse = Read-Host -Prompt '[1] All Domain Computers, [2] All Domain Servers, [3] Computer names from a File, [4] Choose a Computer manually'
If($strResponse -eq '1')
{
  $colComputers = Get-ListComputers | Sort-Object
}
elseif($strResponse -eq '2')
{
  $colComputers = Get-ListServers | Sort-Object
}
elseif($strResponse -eq '3')
{
  . Get-ListTextFile
}
elseif($strResponse -eq '4')
{
  . Get-ManualEntry
}
else
{
  Write-Host -Object "You did not supply a correct response, `
  Please run script again." -ForegroundColor Red
}				
Write-Progress -Activity 'Getting Inventory' -Status 'Running...' -Id 1

#New Excel Application
$Excel = New-Object -ComObject Excel.Application
$Excel.visible = $True

# Create 6 worksheets
$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Add()
$Sheet = $Excel.Worksheets.Add()
$Sheet = $Excel.Worksheets.Add()

# Assign each worksheet to a variable and
# name the worksheet.
$Sheet1 = $Excel.Worksheets.Item(1)
$Sheet2 = $Excel.WorkSheets.Item(2)
$Sheet3 = $Excel.WorkSheets.Item(3)
$Sheet4 = $Excel.WorkSheets.Item(4)
$Sheet5 = $Excel.WorkSheets.Item(5)
$Sheet6 = $Excel.WorkSheets.Item(6)
$Sheet1.Name = 'General'
$Sheet2.Name = 'System'
$Sheet3.Name = 'Processor'
$Sheet4.Name = 'Memory'
$Sheet5.Name = 'Disk'
$Sheet6.Name = 'Network'

#Create Heading for General Sheet
$Sheet1.Cells.Item(1,1) = 'Device_Name'
$Sheet1.Cells.Item(1,2) = 'Role'
$Sheet1.Cells.Item(1,3) = 'HW_Make'
$Sheet1.Cells.Item(1,4) = 'HW_Model'
$Sheet1.Cells.Item(1,5) = 'HW_Type'
$Sheet1.Cells.Item(1,6) = 'CPU_Count'
$Sheet1.Cells.Item(1,7) = 'Memory_MB'
$Sheet1.Cells.Item(1,8) = 'Operating_System'
$Sheet1.Cells.Item(1,9) = 'SP_Level'

#Create Heading for System Sheet
$Sheet2.Cells.Item(1,1) = 'Device_Name'
$Sheet2.Cells.Item(1,2) = 'BIOS_Name'
$Sheet2.Cells.Item(1,3) = 'BIOS_Version'
$Sheet2.Cells.Item(1,4) = 'HW_Serial_#'
$Sheet2.Cells.Item(1,5) = 'Time_Zone'
$Sheet2.Cells.Item(1,6) = 'WMI_Version'

#Create Heading for Processor Sheet
$Sheet3.Cells.Item(1,1) = 'Device_Name'
$Sheet3.Cells.Item(1,2) = 'Processor(s)'
$Sheet3.Cells.Item(1,3) = 'Type'
$Sheet3.Cells.Item(1,4) = 'Family'
$Sheet3.Cells.Item(1,5) = 'Speed_MHz'
$Sheet3.Cells.Item(1,6) = 'Cache_Size_MB'
$Sheet3.Cells.Item(1,7) = 'Interface'
$Sheet3.Cells.Item(1,8) = '#_of_Sockets'

#Create Heading for Memory Sheet
$Sheet4.Cells.Item(1,1) = 'Device_Name'
$Sheet4.Cells.Item(1,2) = 'Bank_#'
$Sheet4.Cells.Item(1,3) = 'Label'
$Sheet4.Cells.Item(1,4) = 'Capacity_MB'
$Sheet4.Cells.Item(1,5) = 'Form'
$Sheet4.Cells.Item(1,6) = 'Type'

#Create Heading for Disk Sheet
$Sheet5.Cells.Item(1,1) = 'Device_Name'
$Sheet5.Cells.Item(1,2) = 'Disk_Type'
$Sheet5.Cells.Item(1,3) = 'Drive_Letter'
$Sheet5.Cells.Item(1,4) = 'Capacity_MB'
$Sheet5.Cells.Item(1,5) = 'Free_Space_MB'

#Create Heading for Network Sheet
$Sheet6.Cells.Item(1,1) = 'Device_Name'
$Sheet6.Cells.Item(1,2) = 'Network_Card'
$Sheet6.Cells.Item(1,3) = 'DHCP_Enabled'
$Sheet6.Cells.Item(1,4) = 'IP_Address'
$Sheet6.Cells.Item(1,5) = 'Subnet_Mask'
$Sheet6.Cells.Item(1,6) = 'Default_Gateway'
$Sheet6.Cells.Item(1,7) = 'DNS_Servers'
$Sheet6.Cells.Item(1,8) = 'DNS_Reg'
$Sheet6.Cells.Item(1,9) = 'Primary_WINS'
$Sheet6.Cells.Item(1,10) = 'Secondary_WINS'
$Sheet6.Cells.Item(1,11) = 'WINS_Lookup'

$colSheets = ($Sheet1, $Sheet2, $Sheet3, $Sheet4, $Sheet5, $Sheet6)
foreach ($colorItem in $colSheets)
{
  $intRow = 2
  $intRowCPU = 2
  $intRowMem = 2
  $intRowDisk = 2
  $intRowNet = 2
  $WorkBook = $colorItem.UsedRange
  $WorkBook.Interior.ColorIndex = 20
  $WorkBook.Font.ColorIndex = 11
  $WorkBook.Font.Bold = $True
}

If($credResponse -eq 'y')
{
  Get-WMILookupCred
}
Else
{
  Get-WMILookup
}

#Auto Fit all sheets in the Workbook
foreach ($colorItem in $colSheets)
{
  $WorkBook = $colorItem.UsedRange															
  $WorkBook.EntireColumn.AutoFit()
  Clear-Host
}
Write-Host -Object '*******************************' -ForegroundColor Green
Write-Host -Object 'The Report has been completed.'  -ForegroundColor Green
Write-Host -Object '*******************************' -ForegroundColor Green
# ========================================================================
# END of Script
# ========================================================================