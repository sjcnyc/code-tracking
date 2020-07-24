
#requires -version 3.0
 
Function Get-FolderSize {
 
<#
.Synopsis
Get a top level folder size report
.Description
This command will analyze the top level folders in a given root. It will write
a custom object to the pipeline that shows the number of files in each folder,
the total size in bytes and folder attributes. The output will also include 
files in the root of the specified path.
 
Sample output:
Name       : DesktopTileResources
Fullname   : C:\windows\DesktopTileResources
Size       : 21094
Count      : 17
Attributes : ReadOnly, Directory
 
Use the -Force parameter to include hidden directories.
.Example
PS C:\> get-foldersize c:\work | format-table -auto
 
Path               Name             Size Count Attributes
----               ----             ---- ----- ----------
C:\work            work        252083656   223  Directory
C:\work\atomic     atomic         622445     6  Directory
C:\work\fooby      fooby              18     1  Directory
C:\work\images     images        1470091   118  Directory
C:\work\resources  resources     8542561   143  Directory
C:\work\shell      shell          225161     4  Directory
C:\work\test       test         17198758     4  Directory
C:\work\Test Rig 2 Test Rig 2    4194304     1  Directory
C:\work\test2      test2              40     2  Directory
C:\work\Ubuntu12   Ubuntu12   7656701952     2  Directory
C:\work\widgets    widgets        162703    49  Directory
 
.Example
PS C:\> get-foldersize c:\users\jeff\ -force | out-gridview -title Jeff
.Notes
Last Updated: May 8, 2013
Version     : 0.9
 
  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************
.Link
http://jdhitsolutions.com/blog/2013/05/getting-top-level-folder-report-in-powershell
.Inputs
None
.Outputs
Custom object
#>
 
[cmdletbinding()]
Param(
[Parameter(Position=0)]
[ValidateScript({Test-Path $_})]
[string]$Path='.',
[switch]$Force
)
 
Write-Verbose "Starting $($myinvocation.MyCommand)"
Write-Verbose "Analyzing $path"
 
#define a hashtable of parameters to splat to Get-ChildItem
$dirParams = @{
Path = $Path
ErrorAction = 'Stop'
ErrorVariable = 'myErr'
Directory = $True
}
 
if ($hidden) {
    $dirParams.Add('Force',$True)
}
$activity = $myinvocation.MyCommand
 
Write-Progress -Activity $activity -Status 'Getting top level folders' -CurrentOperation $Path
 
$folders = Get-ChildItem @dirParams
 
#process each folder
$folders | 
foreach -begin {
     Write-Verbose $Path
     #initialize some total counters
     $totalFiles = 0
     $totalSize = 0
     #initialize a counter for progress bar
     $i=0
 
     Try {     
        #measure files in $Path root
        Write-Progress -Activity $activity -Status $Path -CurrentOperation 'Measuring root folder' -PercentComplete 0
        #modify dirParams hashtable
        $dirParams.Remove('Directory')
        $dirParams.Add('File',$True)
        $stats = Get-ChildItem @dirParams | Measure-Object -Property length -sum
     }
     Catch {
        $msg = "Error: $($myErr[0].ErrorRecord.CategoryInfo.Category) $($myErr[0].ErrorRecord.CategoryInfo.TargetName)"
        Write-Warning $msg
     }
     #increment the grand totals
     $totalFiles+= $stats.Count
     $totalSize+= $stats.sum
 
     if ($stats.count -eq 0) {
        #set size to 0 if the top level folder is empty
        $size = 0
     }
     else {
        $size=$stats.sum
     }
 
     $root = Get-Item -Path $path
     #define properties for the custom object
     $hash = [ordered]@{
         Path = $root.FullName
         Name = $root.Name
         Size = $size
         Count = $stats.count
         Attributes = (Get-Item $path).Attributes
         }
     #write the object for the folder root
     New-Object -TypeName PSobject -Property $hash
 
    } -process { 
     Try {
        Write-Verbose $_.fullname
        $i++
        [int]$percomplete = ($i/$folders.count)*100
        Write-Progress -Activity $activity -Status $_.fullname -CurrentOperation 'Measuring folder' -PercentComplete $percomplete
 
        #get directory information for top level folders
        $dirParams.Path = $_.Fullname
        $stats = Get-ChildItem @dirParams -Recurse | Measure-Object -Property length -sum
     }
     Catch {
        $msg = "Error: $($myErr[0].ErrorRecord.CategoryInfo.Category) $($myErr[0].ErrorRecord.CategoryInfo.TargetName)"
        Write-Warning $msg
     }
     #increment the grand totals
     $totalFiles+= $stats.Count
     $totalSize+= $stats.sum
 
     if ($stats.count -eq 0) {
        #set size to 0 if the top level folder is empty
       $size = 0
     }
     else {
        $size=$stats.sum
     }
     #define properties for the custom object
     $hash = [ordered]@{
         Path = $_.FullName
         Name = $_.Name
         Size = $size
         Count = $stats.count
         Attributes = $_.Attributes
        }
     #write the object for each top level folder
     New-Object -TypeName PSobject -Property $hash
 } -end {
    Write-Progress -Activity $activity -Status 'Finished' -Completed
    Write-Verbose "Total number of files for $path = $totalfiles"
    Write-Verbose "Total file size in bytes for $path = $totalsize"
 }
 
 Write-Verbose "Ending $($myinvocation.MyCommand)"
 } #end Get-FolderSize