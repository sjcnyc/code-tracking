
$filename = 'test_scan2.csv'
$cfgOU = Get-QADObject -SearchScope OneLevel -SizeLimit 100 | Select-Object dn | Where-Object {$_ -ne 'OU=USA,DC=bmg,DC=bagint,DC=com'}
$cfgInterval = -30
$cfgOutpath = "c:\temp\$filename"
Function Get-PSTInfo
{
  Param( [string]$ComputerName = $(throw 'ComputerName required.') )
  $ReturnArray = @()
	
  if( (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) -eq $false )
  {
    Write-Verbose "Failed communicating with $ComputerName - ICMP Unreachable"
    return;
  }

  try
  {
    $PstFiles = Get-Wmiobject -namespace 'root\CIMV2' -computername $computerName -ErrorAction Stop -Query "SELECT * FROM CIM_DataFile WHERE Extension = 'pst' AND Drive = 'c:'"
  }
  Catch
  {
    Write-Verbose "Failed communicating with $ComputerName - Get-WMIObject failed"
    return;
  }
  foreach ($file in $PstFiles)
  { 
    if($File.FileName)
    { 
      $FileReturn = '' | Select-Object Computer,Owner,Path,FileSize,LastModified,LastAccessed,Version
      $filepath = $file.description 

      $Owner = 'Unknown';
      try
      {
        $query = "ASSOCIATORS OF {Win32_LogicalFileSecuritySetting=`'$filepath`'} WHERE AssocClass=Win32_LogicalFileOwner ResultRole=Owner" 
        $Owner = @(Get-Wmiobject -namespace 'root\CIMV2' -computername $computerName -Query $query) 
        $Owner = "$($Owner[0].ReferencedDomainName)\$($Owner[0].AccountName)" 
      }
      catch
      {
        Write-Verbose "Unable to determine the owner of a PST File on $ComputerName"
      }
			
      $FileReturn.Computer = $computerName
      $FileReturn.Path = $filepath 
      $FileReturn.FileSize = $file.FileSize/1KB 
      $FileReturn.Owner = $Owner
      $FileReturn.LastModified = [System.Management.ManagementDateTimeConverter]::ToDateTime($($file.LastModified))
      $FileReturn.LastAccessed = [System.Management.ManagementDateTimeConverter]::ToDateTime($($file.LastAccessed))

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


Function Get-AdObjects
{
  Param(
    [string]$Path = $(throw 'Path required.'),
    [string]$desiredObjectClass = $(throw 'DesiredObjectClass required.')
    )
  $ReturnArray = $null

  $objADSI = [ADSI]$Path

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
      $RecurseItems = $null
      $RecurseItems += Get-AdObjects "LDAP://$($thisItem.distinguishedName.ToString())" $desiredObjectClass
      if( $RecurseItems.Count -gt 0 )
      {
        $ReturnArray += $RecurseItems
      }
    }
  }

  if( $ReturnArray.Count -gt 0)
  {
    return $ReturnArray;
  }
}

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
      continue
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
    continue
  }
}

$OutArray = @()

foreach ($dn in $cfgOU.dn) {

  $Computers = Get-AdObjects "LDAP://$dn" 'computer'
  $Computers = Get-ObjectsLoggedIntoSince $Computers $cfgInterval


  if( $Computers.Count -gt 0 )
  {
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
  }
  }


$OutArray | Export-Csv "$cfgOutpath" -NoClobber -NoTypeInformation -Append