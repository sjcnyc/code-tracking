
Function Get-FolderSize {
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
         Size = Convert-Size($size)
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


 Function Convert-Size {
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('Length')]
        [int64]$Size
    )
    Begin {
        If (-Not $ConvertSize) {
            Write-Verbose ('Creating signature from Win32API')
            $Signature =  @"
                 [DllImport("Shlwapi.dll", CharSet = CharSet.Auto)]
                 public static extern long StrFormatByteSize( long fileSize, System.Text.StringBuilder buffer, int bufferSize );
"@
            $Global:ConvertSize = Add-Type -Name SizeConverter -MemberDefinition $Signature -PassThru
        }
        Write-Verbose ('Building buffer for string')
        $stringBuilder = New-Object Text.StringBuilder 1024
    }
    Process {
        Write-Verbose ('Converting {0} to upper most size' -f $Size)
        $ConvertSize::StrFormatByteSize( $Size, $stringBuilder, $stringBuilder.Capacity ) | Out-Null
        $stringBuilder.ToString()
    }
}