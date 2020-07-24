#
# PST Scanning Utility (WMI)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~
# Retrieves a list of computers (recursively) from an OU in Active
# Directory then uses WMI to search for PST files on the remote 'C:'
# drive, saving the results to CSV format with location, size and owner
# details.
#
# The advantage to performing a search is that PST files in non-default
# locations will be found, enumerating the registry only shows files in
# use by Outlook.
#
# This script doesn't make use of threading (Jobs) due to hangs/locks
# experienced when they were implemented.
#
# Changelog
# ~~~~~~~~~
# 2012.03.28	Dave Hope		Initial version.
# 2012.04.24	Dave Hope		Added PST file version information.
# 2012.04.26	Dave Hope		Added try/catch around file owner check.
#
# ======================================================================
# SETTINGS
# ======================================================================
$cfgOU = 'LDAP://OU=Windows 2008,OU=SRV,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com'
$cfgInterval = -30
$cfgOutpath = 'c:\temp\WMINAS.CSV'

# ======================================================================
# STOP CHANGING HERE.
# ======================================================================

#
# Scans the specified hostname for PST files, returning an array of data
# must of this is inline due to the nature of job functionality in PS.
# ======================================================================
Function Get-PSTInfo
{
	Param( [string]$ComputerName = $(throw 'ComputerName required.') )
	$ReturnArray = @()
	
	# Test connection first rather than relying on the slow
	# Get-WMiObject call to fail.
	if( (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) -eq $false )
	{
#		Write-Host "Failed communicating with $ComputerName - ICMP Unreachable"
		return;
	}

	# Connect and execute query.
	try
	{
		#Path,FileSize,LastModified,LastAccessed,Extension,Drive
		$PstFiles = Get-Wmiobject `
                  -namespace 'root\CIMV2' `
                  -computername $computerName `
                  -ErrorAction Stop `
                  -Query "SELECT * FROM CIM_DataFile WHERE Extension = 'pst'" # AND Drive = 'c:'"
	}
	Catch
	{
#		Write-Host "Failed communicating with $ComputerName - Get-WMIObject failed"
		return;
	}
	# Iterate over the found PST files.
	foreach ($file in $PstFiles)
	{ 
		if($File.FileName)
		{ 
			$FileReturn = '' | Select-Object Computer,Owner,Path,FileSize,LastModified,LastAccessed,Version
			$filepath = $file.description 
						
			#
			# Try and find the owner of the file.
			$Owner = 'Unknown';
			try
			{
				$query = "ASSOCIATORS OF {Win32_LogicalFileSecuritySetting=`'$filepath`'} WHERE AssocClass=Win32_LogicalFileOwner ResultRole=Owner" 
				$Owner = @(Get-Wmiobject -namespace 'root\CIMV2' -computername $computerName -Query $query) 
				$Owner = "$($Owner[0].ReferencedDomainName)\$($Owner[0].AccountName)" 
			}
			catch
			{
#				Write-Host "Unable to determine the owner of a PST File on $ComputerName"
			}
			
			$FileReturn.Computer = $computerName
			$FileReturn.Path = $filepath 
			$FileReturn.FileSize = $file.FileSize/1KB 
			$FileReturn.Owner = $Owner
			$FileReturn.LastModified = [System.Management.ManagementDateTimeConverter]::ToDateTime($($file.LastModified))
			$FileReturn.LastAccessed = [System.Management.ManagementDateTimeConverter]::ToDateTime($($file.LastAccessed))

			#
			# Here, we're examining part of the PST file header.
			# We only need wVer (2bytes), so we seek to that position in
			# the file.
			$tmpPath = $filepath  -Replace 'C:\\', "\\$ComputerName\c$\"
			[system.io.stream]$fileStream = [system.io.File]::Open( (Get-Item $tmpPath) , 'Open' , 'Read' , 'ReadWrite' )
			try
			{
				[byte[]]$fileBytes = New-Object byte[] 11 # Length we need.
				[void]$fileStream.Read( $fileBytes, 0, 11);
				if ($fileBytes[10] -eq 23 )
				{
					$FileReturn.Version = '2003';
				}
				elseif ( ($fileBytes[10] -eq 14) -or ($fileBytes[10] -eq 15) )
				{
					$FileReturn.Version = '1997';
				}
				else
				{
					$FileReturn.Version = 'Unknown';
				}
			}
			catch
			{
				$FileReturn.Version = 'Error';
			}
			$fileStream.Close();

			$ReturnArray += $FileReturn
		} 
	}
	return $ReturnArray;
}


#
# Gets a list of object names from AD recursively
# ======================================================================
Function Get-AdObjects
{
	Param(
		[string]$Path = $(throw 'Path required.'),
		[string]$desiredObjectClass = $(throw 'DesiredObjectClass required.')
		)
	$ReturnArray = $null

	# Bind to AD using the provided path.
	$objADSI = [ADSI]$Path

	# Iterate over each object and add its name to the array.
	foreach( $obj in $objADSI.Children )
	{
		$thisItem = $obj | Select-Object objectClass,distinguishedName,name
		if (
			$thisItem.objectClass.Count -gt 0 -And
			$thisItem.objectClass.Contains( $desiredObjectClass)
			)
		{
			$ReturnArray += $thisItem.distinguishedName
		}
		elseif(
			$thisItem.objectClass.Count -gt 0 -And
			$thisItem.objectClass.Contains('organizationalUnit')
			)
		{
			# Init to null rather than @() so we dont add empty
			# values.
			$RecurseItems = $null
			$RecurseItems += Get-AdObjects "LDAP://$($thisItem.distinguishedName.ToString())" $desiredObjectClass
			if( $RecurseItems.Count -gt 0 )
			{
				$ReturnArray += $RecurseItems
			}
		}
	}

	# Make sure we have items to return, otherwise we'll push
	# empty items to the array.
	if( $ReturnArray.Count -gt 0)
	{
		return $ReturnArray;
	}
}


#
# Converts a COMObect to a LargeInteger
# ======================================================================
function Convert-IADSLargeInteger
{
   param
   (
     [Object]
     $LargeInteger
   )

	$type = $LargeInteger.GetType()  
	$highPart = $type.InvokeMember('HighPart','GetProperty',$null,$LargeInteger,$null)  
	$lowPart = $type.InvokeMember('LowPart','GetProperty',$null,$LargeInteger,$null)  
	$bytes = [System.BitConverter]::GetBytes($highPart)  
	$tmp = New-Object System.Byte[] 8  
	[Array]::Copy($bytes,0,$tmp,4,4)  
	$highPart = [System.BitConverter]::ToInt64($tmp,0)  
	$bytes = [System.BitConverter]::GetBytes($lowPart)  
	$lowPart = [System.BitConverter]::ToUInt32($bytes,0)  
	$lowPart + $highPart  
} 

#
# Evaluate the lastLogonTimestamp attribute for accounts and pull ones 
# from the last 30 days only.
# ======================================================================
Function Get-ObjectsLoggedIntoSince
{
	Param(
		[Array] $Computers = $(throw 'Computers required'),
		[int] $LoginDays = $(throw 'LoginDays required')
		)

	$earliestAllowedLogon = [DateTime]::Today.AddDays($LoginDays)

	foreach( $Computer in $Computers )
	{
		$objADSI = [ADSI]"LDAP://$Computer"
		if( $objADSI.Properties.Contains('lastLogonTimeStamp') -eq $false )
		{
			continue;
		}

		$lastLogon = [DateTime]::FromFileTime(
			[Int64]::Parse(
				$(Convert-IADSLargeInteger $objADSI.lastlogontimestamp.value)
				)
			)
		if( [DateTime]::Compare( $earliestAllowedLogon , $lastLogon) -eq -1 )
		{
			$objADSI.name
		}
		continue;
	}
}

#
# Get computer accounts from Active Directory.
$OutArray = @()
$Computers = Get-AdObjects "$cfgOU" 'computer'
$Computers = Get-ObjectsLoggedIntoSince $Computers $cfgInterval

#
# If we have no computers to check, just exit.
if( $Computers.Count -le 0 )
{
	return;
}

#
# Create all the jobs.
$statTotal = $computers.count
$statComplete = 0
ForEach ($Computer in $Computers)
{
	Write-Progress -Activity 'Locating PST files' -Status 'Waiting for a scan to finish before starting another' -CurrentOperation "Total: $statTotal , Complete: $statComplete" -PercentComplete ($statComplete/$statTotal * 100)
	$RetVal = Get-PSTInfo $Computer
	if( $RetVal -ne $null)
	{
		$OutArray += $retVal
	}
	$statComplete++
}

$OutArray #| Export-Csv "$cfgOutpath" -NoClobber -NoTypeInformation