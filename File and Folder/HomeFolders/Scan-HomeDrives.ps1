function scan-oldFiles {
  
  param( 
    [string]$folderpath, 
    [string]$fileage, 
    [string]$logfile, 
    [string[]]$exclude, 
    [switch]$help, 
    [switch]$listonly, 
    [switch]$verboselog, 
    [switch]$autolog, 
    [switch]$createtime
    
  ) 
  
  #region Functions 
  function to_kmgt  {
    param
    (
      [System.Object]
      $bytes
    )
    
    foreach ($i in ('Bytes','KB','MB','GB','TB')) { if (($bytes -lt 1000) -or ($i -eq 'TB')) `
      { $bytes = ($bytes).tostring('F0' + '1') 
        return $bytes + " $i"
      }
      else {$bytes /= 1KB}
    }
  }
  
  # This function sets up variables used in this script 
  function F_SetupVars {
    $script:dashes = ('-'*79) 
    $script:Startdate = get-date 
    $script:LastWrite = $Startdate.AddDays(-$fileage) 
    $script:starttime = $startdate.toshortdatestring()+', '+$startdate.tolongtimestring() 
    $script:switches = "`r`n`n`t-folderpath : $folderpath`r`n`t-fileage    : $fileage day(s)`r`n`t-logfile    : $logfile" 
    if ($exclude) 
    { 
      $script:switches+= "`r`n`t-exclude    : " 
      for ($j=0;$j -lt $exclude.count;$j++) {$script:switches+= '';$script:switches+= $exclude[$j]} 
    } 
    if ($listonly) {$script:switches+="`r`n`t-listonly"} 
    if ($verboselog) {$script:switches+="`r`n`t-verboselog"} 
    if ($autolog) {$script:switches+="`r`n`t-autolog"} 
    [long]$script:filessize = 0 
    [long]$script:failedsize = 0 
    [int]$script:filesnumber = 0 
    [int]$script:filesfailed = 0 
    [int]$script:foldersnumber = 0 
    [int]$script:foldersfailed = 0 
  } 
  
  # Function that is triggered when the -autolog switch is active 
  function F_Autolog { 
    # Gets date and reformats to be used in log filename 
    $tempdate = get-date 
    $tempdate = $tempdate.tostring('dd-MM-yyyy_HHmm.ss') 
    # Reformats $folderpath so it can be used in the log filename 
    $tempfolderpath = $folderpath -replace '\\','_' 
    $tempfolderpath = $tempfolderpath -replace ':','' 
    $tempfolderpath = $tempfolderpath -replace ' ','' 
    # Checks if the logfile is either pointing at a folder or a logfile and removes 
    # Any trailing backslashes 
    $testlogpath = Test-Path $logfile -pathtype container 
    if (-not $testlogpath) {$logfile = split-path $logfile -Erroraction SilentlyContinue} 
    if ($logfile.substring($logfile.length-1,1) -eq '\') {$logfile = $logfile.substring(0,$logfile.length-1)} 
    # Combines the date and the path scanned into the log filename 
    $logfile = "$($logfile)\Moved_Folders-($($tempfolderpath))-$($tempdate).log" 
  } 
  
  <#
    # Dont think we will ever use this, but just in case.
    # Function which contains the loop in which files are deleted. If a file fails to be deleted 
    # an error is logged and the error message is written to the log 
    # $count is used to speed up the delete fileloop and will also be used for other large loops in the script 

    function F_Deleteoldfiles { 
    $count = $filelist.count 
    for ($j=0;$j -lt $count;$j++) 
    { 
        $tempfile = $filelist[$j].fullname 
        $tempsize = $filelist[$j].length 
        if(-not $listonly) 
        {
            #remove-item $tempfile -force -ErrorAction SilentlyContinue
        } 
        if (-not $?) 
        { 
            $tempvar = $error[0].tostring() 
            "`tFAILED FILE`t`t$tempvar" >> $logfile 
            $script:filesfailed++ 
            $script:failedsize+=$tempsize 
        } 
        else 
        { 
            if (-not $listonly) 
            {
                $script:filesnumber++;$script:filessize+=$tempsize;if ($verboselog) {"`tDELETED FILE`t$tempfile" >> $logfile}
            } 
        } 
        if($listonly) 
        {
            "`tLISTONLY`t$tempfile" >> $logfile 
            $script:filesnumber++ 
            $script:filessize+=$tempsize 
        } 
    } 
  } #> 
  
  function F_MoveoldFiles {
    $count = $filelist.count
    for ($j=0;$j -lt $count;$j++) 
    {
      $tempfile = $filelist[$j].fullname
      $tempsize = $filelist[$j].length
      if(-not $listonly) 
      {
        # build destination path 
        $dest = $tempfile -replace ([regex]::escape($folderpath)), $exclude
        
        # create parent dir if not there
        $parent = split-path $dest 
        if (!(test-path $parent ) )
        {
          [void] (new-item -Path (split-path $parent) -Name (split-path $parent -leaf) -ItemType directory)
        } 
        Move-Item $tempfile -destination $dest -force -ErrorAction SilentlyContinue 
        # }
      }
      if(-not $?) 
      {
        $tempvar = $error[0].ToString()
        $script:filesfailed++;$script:failedsize+=$tempsize;if ($verboselog){"`tFAILED TO MOVE FILE`t`t$tempvar" >> $logfile } 
      }
      else 
      {
        if (-not $listonly)
        {
          $script:filesnumber++;$script:filessize+=$tempsize;if ($verboselog) {"`tMOVE FILE`t$tempfile">> $logfile}
        }
      }
      if($listonly) 
      {
        $script:filesnumber++;$script:filessize+=$tempsize;if ($verboselog) {"`tLISTONLY`t$tempfile" >> $logfile}                    
      }     
    }
  }
  
  # Checks whether folder is empty and uses temporary variables 
  # Main loop goes through list of folders, only deleting the empty folders 
  # The if(-not $tempfolder) is the verification whether the folder is empty 
  function F_Checkforemptyfolder { 
    $folderlist = $folderlist | sort-object @{Expression={$_.fullname.length}; Ascending=$false} 
    $count = $folderlist.count 
    for ($j=0;$j -lt $count;$j++) 
    { 
      $tempfolder = get-childitem $folderlist[$j].fullname -ErrorAction SilentlyContinue 
      if (-not $tempfolder) 
      { 
        $tempname = $folderlist[$j].fullname 
        remove-item $tempname -force -recurse -ErrorAction SilentlyContinue 
        if(-not $?) { 
          $tempvar = $error[0].tostring() 
          "`tFAILED FOLDER`t$tempvar" >> $logfile 
          $script:foldersfailed++ 
        } 
        else 
        { 
          if ($verboselog) 
          {
            "`tDELETED FOLDER`t$tempname" >> $logfile
          } 
          $script:foldersnumber++ 
        } 
      } 
    } 
  } 
  
  # Writes footer to the logfile 
  function F_Writefooterlog {
    $results =
    @"

$($dashes)

   Total Files and Folders
   
      Files     : $('{0:N0}' -f $allfilecount)
      Folders   : $('{0:N0}' -f $folderlist.count)
      Old files : $('{0:N0}' -f $filelist.count) 
   
   Processed Files and Folders
    
      Files               : $('{0:N0}' -f $filesnumber)
      Filesize            : $($filessize) 
      Files Failed        : $('{0:N0}' -f $filesfailed) 
      Failedfile Size     : $($failedsize) 
      Folders             : $('{0:N0}' -f $foldersnumber) 
      Folders Failed      : $('{0:N0}' -f $foldersfailed)
       
      Finished Time       : $($enddate) 
      Total Time          : $($timetaken)
    
$($dashes) 
"@
    
    $results >> $logfile    
    
  } 
  #endregion Function 
  if ($autolog) {
    # Gets date and reformats to be used in log filename 
    $tempdate = get-date 
    $tempdate = $tempdate.tostring('dd-MM-yyyy') 
    # Reformats $folderpath so it can be used in the log filename 
    $tempfolderpath = $folderpath -replace '\\','_' 
    $tempfolderpath = $tempfolderpath -replace ':','' 
    $tempfolderpath = $tempfolderpath -replace ' ','' 
    # Checks if the logfile is either pointing at a folder or a logfile and removes 
    # Any trailing backslashes 
    $testlogpath = Test-Path $logfile -pathtype container 
    if (-not $testlogpath) {$logfile = split-path $logfile -Erroraction SilentlyContinue} 
    if ($logfile.substring($logfile.length-1,1) -eq '\') {$logfile = $logfile.substring(0,$logfile.length-1)} 
    # Combines the date and the path scanned into the log filename 
    $logfile = "$($logfile)\Moved_Folders-($($tempfolderpath))-$($tempdate).log" 
  }
  
  # Sets up the variables 
  F_SetupVars 
  
  #region output text to console 
  # Output text to console
  $dashes 
  write-host '  Share Drive: File Age Report' 
  $dashes 
  write-host "`n   Started  :   $starttime`n   Folder   :`t$folderpath`n   Switches :`t$switches`n" 
  if ($listonly)
  {write-host "`t*** Running in Listonly mode, no files will be modified ***`n" -f cyan} 
  $dashes
  #endregion
  
  #region output log to header
  # Output to log header 
  $results =
  @"

$dashes 
Share Drive: File Age Report 
$dashes 
 
   Started  :   $starttime 
 
   Folder   :   $folderpath 
 
   Switches :   $switches 
 
$dashes 

"@
  $results >> $logfile 
  #endregion
  
  # Checks if all values in $exclude end with \, if not present it will add it 
  # Reformats the $exclude so the -notmatch command works, all slashes are repeated twice 
  # eg: c:\temp\ becomes c:\\temp\\ 
  if (!(Test-Path $exclude)) {
    New-Item $exclude -ItemType directory
  }
  for ($j=0;$j -lt $exclude.count;$j++) { 
    if ($exclude[$j].substring($exclude[$j].length-1,1) -ne '\') {$exclude[$j] = $exclude[$j] + '\'} 
  } 
  $exclude = $exclude -replace '\\','\\' 
  
  # Define the properties to be selected for the array, if createtime switch is specified  
  # CreationTime is added to the list of properties, this is to conserve memory space 
  $SelectProperty = @{'Property'='Fullname','Length','PSIsContainer'} 
  if ($createtime) { 
    $SelectProperty.Property += 'CreationTime' 
  } 
  else { 
    $SelectProperty.Property += 'LastWriteTime' 
  } 
  
  # Get the complete list of files and save to array 
  write-host "`n   Retrieving list of files and folders from: $folderpath" 
  $checkerror = $error.count 
  $fullarray = @(get-childitem $folderpath -recurse -ErrorAction SilentlyContinue -force | select-object @SelectProperty)
  
  # Catches errors during read stage and writes to log, mostly catches permissions errors 
  $checkerror = $error.count - $checkerror 
  if ($checkerror -gt 0) { 
    for ($j=0;$j -lt $checkerror;$j++) { 
      $temperror = $error[$j].tostring() 
      "`tFAILED ACCESS`t$temperror" >> $logfile 
    } 
  } 
  
  # Split the complete list of items into two seperate lists $folderlist, $filelist 
  $folderlist = @($fullarray | Where-Object {$_.PSIsContainer -eq $True}) 
  $filelist   = @($fullarray | Where-Object {$_.PSIsContainer -eq $False}) 
  
  # If the exclusion parameter is included then this loop will run. This will clear out the  
  # excluded paths for both the filelist as well as the folderlist. After cleaning up filelist 
  # this loop removes trailing backslash for folder verification 
  if ($exclude) 
  { 
    for ($j=0;$j -lt $exclude.count;$j++) 
    { 
      $filelist = $filelist | Where-Object {$_.fullname -notmatch $exclude[$j]} 
      $exclude[$j] = $exclude[$j].substring(0,$exclude[$j].length-2) 
      $folderlist = $folderlist | Where-Object {$_.fullname -notmatch $exclude[$j]} 
    } 
  } 
  
  # Counter for prompt output 
  $allfilecount = $filelist.count
  
  # Clear original array containing files and folders and create array with list of older files 
  # If the -createtime switch has been used the script looks for file creation time rather than 
  # file modified/lastwrite time 
  $fullarray = '' 
  if ($createtime) { 
    $filelist = @($filelist | Where-Object {$_.CreationTime -le $LastWrite}) 
  } 
  else { 
    $filelist = @($filelist | Where-Object {$_.LastWriteTime -le $LastWrite}) 
  } 
  
  # Write totals to console 
  write-host "     Files     : $('{0:N0}' -f $allfilecount)"
  write-host "     Folders   : $('{0:N0}' -f $folderlist.count)"
  write-host "     Old files : $('{0:N0}' -f $filelist.count)" 
  
  # Execute main functions of script 
  if (-not $listonly) {write-host "`n   Starting with moving old files..."} 
  else {write-host "`n   Listing files..."} 
  #F_Deleteoldfiles 
  F_MoveOldFiles
  if (-not $listonly) {write-host '   Finished moving files'} 
  else {write-host '   Finished listing files'} 
  if (-not $listonly) 
  { 
    write-host '   Check/remove empty folders started...' 
    F_Checkforemptyfolder 
    write-host "   Empty folders deleted`n" 
  } 
  
  # Pre-format values for footer 
  $enddate = get-date 
  $timetaken = $enddate - $startdate 
  $timetaken = $timetaken.tostring() 
  $timetaken = $timetaken.substring(0,8)
  $filessize = to_kmgt($filessize) 
  [string]$filessize = $filessize.ToString() 
  $failedsize = to_kmgt($failedsize) 
  [string]$failedsize = $failedsize.ToString() 
  $enddate = "$($enddate.toshortdatestring()), $($enddate.tolongtimestring())"
  
  # Output results to console
  $console =
  @"
 
$($dashes) 

   Files               : $('{0:N0}' -f $filesnumber)
   Filesize            : $($filessize) 
   Files Failed        : $('{0:N0}' -f $filesfailed) 
   Failedfile Size     : $($failedsize) 
   Folders             : $('{0:N0}' -f $foldersnumber) 
   Folders Failed      : $('{0:N0}' -f $foldersfailed)
    
   Finished Time       : $($enddate) 
   Total Time          : $($timetaken)
    
$($dashes) 
"@
  $console
  
  # Write footer to logfile 
  F_Writefooterlog 
  
  # Clean up variables at end of script 
  $filelist = '' 
  $folderlist = ''
  
}

#$tempdate = get-date 
#$tempdate = $tempdate.tostring("dd-MM-yyyy")
#$drives = gci -Path 'y:\' -Directory

<#
  foreach($drive in $drives){

  delete-oldfiles -folderpath $drive.FullName `
     -fileage 1400 `
     -logfile "C:\Users\admsconnea\Desktop\logs\$drive$tempdate.log" -listonly

  }
#>


$datashares =
@"
DROYALTY
"@ -split [environment]::NewLine 


foreach( $dsh in $datashares) 
{
  scan-oldfiles `
     -folderpath \\storage\data$\$dsh `
     -fileage '1095' `
     -logfile 'C:\temp\droyalty\main\' `
     -autolog `
     -listonly `
     -exclude 'c:\temp'
     }


<#
  # create function(s) to overcome 266 char limit of .NET

  # Import AlphaFS .NET module - http://alphafs.codeplex.com/
  Import-Module C:\Path\To\AlphaFS\DLL\AlphaFS.dll

  # Variables
  $SourcePath = "C:\Temp"
  $DestPath = "C:\Test"

  # RecursePath function.
  Function RecursePath([string]$SourcePath, [string]$DestPath){

    # for each subdirectory in the current directory..       
    [Alphaleonis.Win32.Filesystem.Directory]::GetDirectories($SourcePath) | % {

        $ShortDirectory = $_
        $LongDirectory = [Alphaleonis.Win32.Filesystem.Path]::GetLongPath($ShortDirectory)

        # Create the directory on the destination path.
        [Alphaleonis.Win32.Filesystem.Directory]::CreateDirectory($LongDirectory.Replace($SourcePath, $DestPath))

        # For each file in the current directory..                                              
        [Alphaleonis.Win32.Filesystem.Directory]::GetFiles($ShortDirectory) | % {

            $ShortFile = $_
            $LongFile = [Alphaleonis.Win32.Filesystem.Path]::GetLongPath($ShortFile)

            # Copy the file to the destination path.                                                                       
            [Alphaleonis.Win32.Filesystem.File]::Copy($LongFile, $LongFile.Replace($SourcePath, $DestPath), $true)                             

        }

    # Loop.
    RecursePath $ShortDirectory $DestPath
    }
  }
#>