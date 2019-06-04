#------------------------------------------------------------------------------- 
# DELETEOLD.ps1          ::      Script to delete or list old files in a folder 
#------------------------------------------------------------------------------- 
#                        Written by Jaap Brasser 
#------------------------------------------------------------------------------- 
#                 *NOTE* :: -folderpath -fileage <x> and -logfile are required 
#                           parameters for DELETEOLD.ps1 to run 
# 
# 
#          -folderpath   :: The path that will be scanned for old files 
#          -fileage      :: Filter for age of file, entered in days. Use -1 for all 
# 
#:: 
#:: Logging options : 
#:: 
#          -logfile      :: Specifies the full path and filename of the logfile 
#                        :: only path is required when using in conjunction with -autolog 
#:: 
#:: Exclusions : 
#:: 
#          -exclude      :: Specifies a path or multiple paths in quotes seperated by 
#                        :: commas. Full paths are required, relative paths will not work 
#:: 
#:: Switches : 
#:: 
#          -listonly     :: Only lists, does not remove or modify files 
#          -verboselog   :: Logs all delete operations to log, default is failed only 
#          -autolog      :: Automatically generates filename at path specified in -logfile 
#          -createtime   :: Looks for file creation time rather than lastwritetime 
# 
#:: 
#:: Examples : 
#:: 
#          deleteold.ps1 -folderpath h:\scripts -fileage 100 -listonly -logfile h:\log.log 
#                        :: Searches through the h:\scripts folder and writes a logfile 
#                        :: containing files older than 100 days 
# 
#          deleteold.ps1 -folderpath h:\scripts -fileage 30 -logfile h:\log.log -verboselog 
#                        :: Searches through the h:\scripts folder and deletes files, 
#                        :: writes all operations, success and failed, to logfile 
# 
#          deleteold.ps1 -folderpath c:\docs -fileage 30 -logfile h:\log.log -exclude "c:\docs\finance\","c:\docs\hr\" 
#                        :: Searches through the c:\docs folder and deletes files, 
#                        :: exluding the finance and hr folders in c:\docs 
# 
#          deleteold.ps1 -help 
#                        :: Displays this screen 
# 
#          powershell.exe deleteold.ps1 -folderpath 'h:\adm_jaap' -fileage 10 -logfile c:\ltemp.log -verboselog 
#                        :: Launches the script from batchfile or command prompt, note 
#                        :: quotes '' used for the path 
 

# Defines the parameters used to run this script 

function delete-oldfiles {

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
 
function to_kmgt ($bytes) {
    foreach ($i in ("Bytes","KB","MB","GB","TB")) { if (($bytes -lt 1000) -or ($i -eq "TB")) `
        { $bytes = ($bytes).tostring("F0" + "1") 
    return $bytes + " $i"
    }
    else {$bytes /= 1KB}
  }
}

# This functions sets up variables used in this script 
function F_SetupVars {
    $script:dashes = ("-"*79) 
    $script:Startdate = get-date 
    $script:LastWrite = $Startdate.AddDays(-$fileage) 
    $script:starttime = $startdate.toshortdatestring()+", "+$startdate.tolongtimestring() 
    $script:switches = "`r`n`n`t-folderpath : $folderpath`r`n`t-fileage    : $fileage`r`n`t-logfile    : $logfile" 
    if ($exclude) { 
        $script:switches+= "`r`n`t-exclude    : " 
        for ($j=0;$j -lt $exclude.count;$j++) {$script:switches+= "";$script:switches+= $exclude[$j]} 
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
function F_Autolog ($logfile){ 
    # Gets date and reformats to be used in log filename 
    $tempdate = get-date 
    $tempdate = $tempdate.tostring("dd-MM-yyyy_HHmm.ss") 
    # Reformats $folderpath so it can be used in the log filename 
    $tempfolderpath = $folderpath -replace '\\','_' 
    $tempfolderpath = $tempfolderpath -replace ':','' 
    $tempfolderpath = $tempfolderpath -replace ' ','' 
    # Checks if the logfile is either pointing at a folder or a logfile and removes 
    # Any trailing backslashes 
    $testlogpath = Test-Path $logfile -pathtype container 
    if (-not $testlogpath) {$logfile = split-path $logfile -Erroraction SilentlyContinue} 
    if ($logfile.substring($logfile.length-1,1) -eq "\") {$logfile = $logfile.substring(0,$logfile.length-1)} 
    # Combines the date and the path scanned into the log filename 
    $logfile = "$logfile\Autolog_$tempfolderpath_$tempdate.log" 
} 
 

 
# Function which contains the loop in which files are deleted. If a file fails to be deleted 
# an error is logged and the error message is written to the log 
# $count is used to speed up the delete fileloop and will also be used for other large loops in the script 
function F_Deleteoldfiles { 
    $count = $filelist.count 
    for ($j=0;$j -lt $count;$j++) { 
        $tempfile = $filelist[$j].fullname 
        $tempsize = $filelist[$j].length 
        if(-not $listonly) {<#remove-item $tempfile -force -ErrorAction SilentlyContinue#>} 
        if (-not $?) { 
            $tempvar = $error[0].tostring() 
            "`tFAILED FILE`t`t$tempvar" >> $logfile 
            $script:filesfailed++ 
            $script:failedsize+=$tempsize 
        } 
            else { 
                if (-not $listonly) {$script:filesnumber++;$script:filessize+=$tempsize;if ($verboselog) {"`tDELETED FILE`t$tempfile" >> $logfile}} 
            } 
        if($listonly) {"`tLISTONLY`t$tempfile" >> $logfile 
            $script:filesnumber++ 
            $script:filessize+=$tempsize 
        } 
    } 
} 
 
# Checks whether folder is empty and uses temporary variables 
# Main loop goes through list of folders, only deleting the empty folders 
# The if(-not $tempfolder) is the verification whether the folder is empty 
function F_Checkforemptyfolder { 
    $folderlist = $folderlist | sort-object @{Expression={$_.fullname.length}; Ascending=$false} 
    $count = $folderlist.count 
    for ($j=0;$j -lt $count;$j++) { 
        $tempfolder = get-childitem $folderlist[$j].fullname -ErrorAction SilentlyContinue 
        if (-not $tempfolder) { 
        $tempname = $folderlist[$j].fullname 
        remove-item $tempname -force -recurse -ErrorAction SilentlyContinue 
            if(-not $?) { 
                $tempvar = $error[0].tostring() 
                "`tFAILED FOLDER`t$tempvar" >> $logfile 
                $script:foldersfailed++ 
            } 
                else { 
                    if ($verboselog) {"`tDELETED FOLDER`t$tempname" >> $logfile} 
                    $script:foldersnumber++ 
                } 
        } 
    } 
} 
 
# Writes footer to the logfile 
function F_Writefooterlog {
$results =@"

    $dashes 
     
    Files               : $filesnumber 
    Filesize(MB)        : $filessize 
    Files Failed        : $filesfailed 
    Failedfile Size(MB) : $failedsize
    Folders             : $foldersnumber 
    Folders Failed      : $foldersfailed 
 
    Finished Time       : $enddate 
    Time Taken          : $timetaken 
     
    $dashes 
"@

$results >> $logfile    
     
} 
 
# Check if correct parameters are used 
if ($help) {F_help} 
if (-not $folderpath) {F_help} 
if (-not $fileage) {F_help} 
if (-not $logfile) {F_help} 
if ($autolog) {

    # Gets date and reformats to be used in log filename 
    $tempdate = get-date 
    $tempdate = $tempdate.tostring("dd-MM-yyyy") 
    # Reformats $folderpath so it can be used in the log filename 
    $tempfolderpath = $folderpath -replace '\\','_' 
    $tempfolderpath = $tempfolderpath -replace ':','' 
    $tempfolderpath = $tempfolderpath -replace ' ','' 
    # Checks if the logfile is either pointing at a folder or a logfile and removes 
    # Any trailing backslashes 
    $testlogpath = Test-Path $logfile -pathtype container 
    if (-not $testlogpath) {$logfile = split-path $logfile -Erroraction SilentlyContinue} 
    if ($logfile.substring($logfile.length-1,1) -eq "\") {$logfile = $logfile.substring(0,$logfile.length-1)} 
    # Combines the date and the path scanned into the log filename 
    $logfile = "$($logfile)\Moved_Folders-($($tempfolderpath))-$($tempdate).log" 
} 


 
# Sets up the variables 
F_SetupVars 
 
# Output text to console
$dashes 
write-host "  Home Drive File Age Report" 
$dashes 
write-host "`n   Started  :   $starttime`n   Folder   :`t$folderpath`n   Switches :`t$switches`n" 
if ($listonly){write-host "`t*** Running in Listonly mode, no files will be modified ***`n" -f cyan} 
$dashes

# Output to log header 
$results =@"

$dashes 
Home Drive File Age Report 
$dashes 
 
   Started  :   $starttime 
 
   Folder   :   $folderpath 
 
   Switches :   $switches 
 
$dashes 

"@
$results >> $logfile 
 
# Checks if all values in $exclude end with \, if not present it will add it 
# Reformats the $exclude so the -notmatch command works, all slashes are repeat twice 
# eg: c:\temp\ becomes c:\\temp\\ 
for ($j=0;$j -lt $exclude.count;$j++) { 
    if ($exclude[$j].substring($exclude[$j].length-1,1) -ne "\") {$exclude[$j] = $exclude[$j] + "\"} 
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
    for ($j=0;$j -lt $exclude.count;$j++) { 
        $filelist = $filelist | ? {$_.fullname -notmatch $exclude[$j]} 
        $exclude[$j] = $exclude[$j].substring(0,$exclude[$j].length-2) 
        $folderlist = $folderlist | ? {$_.fullname -notmatch $exclude[$j]} 
    } 
} 
 
# Counter for prompt output 
$allfilecount = $filelist.count 
 
# Clear original array containing files and folders and create array with list of older files 
# If the -createtime switch has been used the script looks for file creation time rather than 
# file modified/lastwrite time 
$fullarray = "" 
if ($createtime) { 
    $filelist = @($filelist | where {$_.CreationTime -le $LastWrite}) 
} 
else { 
    $filelist = @($filelist | where {$_.LastWriteTime -le $LastWrite}) 
} 
 
# Write totals to console 
write-host "     Files     : $($allfilecount)"
write-host "     Folders   : $($folderlist.count)"
write-host "     Old files : $($filelist.count)" 
 
# Execute main functions of script 
if (-not $listonly) {write-host "`n   Starting with removal of old files..."} 
    else {write-host "`n   Listing files..."} 
F_Deleteoldfiles 
if (-not $listonly) {write-host "   Finished deleting files"} 
    else {write-host "   Finished listing files"} 
if (-not $listonly) 
{ 
    write-host "   Check/remove empty folders started..." 
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
$console =@"
 
$dashes 
 
   Files               : $filesnumber 
   Filesize(MB)        : $filessize 
   Files Failed        : $filesfailed 
   Failedfile Size(MB) : $failedsize 
   Folders             : $foldersnumber 
   Folders Failed      : $foldersfailed
    
   Finished Time       : $enddate 
   Total Time          : $timetaken
    
$dashes 
"@
$console
 
# Write footer to logfile 
F_Writefooterlog 
 
# Clean up variables at end of script 
$filelist = "" 
$folderlist = ""

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

delete-oldfiles -folderpath C:\TEMP `
     -fileage 1 `
     -logfile "C:\Temp" -listonly -autolog `
     -exclude C:\temp\_ARCHIVE