#requires -Version 3.0
$TvShowDir = "$env:HOMEDRIVE\Path\To\Episodes"
$MovieDir = '\\File.Server\Path\To\Movies'
$TvShowSize = 1GB
$MovieSize = 2GB
$FileFormat =@('mp4','mkv')

$ConversionCompleted = '.\ConversionsCompleted.csv'
if(Test-Path -Path ($ConversionCompleted)){$ConversionCompleted = Resolve-Path -Path $ConversionCompleted}

$LogFileDir = '.\Logs'
if(Test-Path -Path ($LogFileDir)){$LogFileDir = Resolve-Path -Path $LogFileDir}

$HandBreakDir = "$env:ProgramW6432\Handbrake"

If(-not(Test-Path -Path $ConversionCompleted)){
  $headers = 'File Name', 'Completed Date'
  $psObject = New-Object -TypeName psobject
  foreach($header in $headers)
  {Add-Member -InputObject $psObject -MemberType noteproperty -Name $header -Value ''}
  $psObject | Export-Csv -Path $ConversionCompleted -NoTypeInformation
  $ConversionCompleted = Resolve-Path -Path $ConversionCompleted
}

if(-not(Test-Path -Path ($LogFileDir))){
  $null = New-Item -ItemType Directory -Force -Path $LogFileDir
  $LogFileDir = Resolve-Path -Path $LogFileDir
}

if(-not(Test-Path -Path ("$HandBreakDir\HandBrakeCLI.exe"))){
  Write-Verbose -Message "HandBrakeCLI.exe not found in $HandBreakDir Please make sure that HandBreak is installed.  Quitting"
  Read-Host -Prompt 'Press Enter to exit...'
  exit
}

if(-not(Test-Path -Path ("$MovieDir"))){
  Write-Verbose -Message "Movie directory: $MovieDir not found.  Please make sure the path is correct.  Quitting"
  Read-Host -Prompt 'Press Enter to exit...'
  exit
}

if(-not(Test-Path -Path ("$TvShowDir"))){
  Write-Verbose -Message "Tv Show directory: $TvShowDir not found.  Please make sure the path is correct.  Quitting"
  Read-Host -Prompt 'Press Enter to exit...'
  exit
}

$CompletedTable = Import-Csv -Path $ConversionCompleted
$HashTable = @{}
foreach($file in $CompletedTable){$HashTable[$file.'File Name'] = $file.'Completed Date'}

Write-Verbose -Message "Finding Movie files over $($MovieSize/1GB)GB in $MovieDir and Episodes over $($TvShowSize/1GB)GB in $TvShowDir be patient..."

# Find all files larger than 2GB
$LargeTvFiles = Get-ChildItem -Path $TvShowDir -Recurse | 
Where-Object -FilterScript {$_.length -gt $TvShowSize}  |
Select-Object -Property FullName, Directory, BaseName, Length
$LargeMovieFiles = Get-ChildItem -Path $MovieDir -Recurse |
Where-Object -FilterScript {$_.length -gt $MovieSize}  |
Select-Object -Property FullName, Directory, BaseName, Length

# Merge the files from both locations into one array and sort largest to smallest (So we start by converting the largest file first)
$AllLargeFiles = $LargeTvFiles + $LargeMovieFiles | Sort-Object -Property length -Descending

# Run through a loop for each file in our array, converting it to a .$FileFormat file
foreach($file in $AllLargeFiles){
  $InputFile = $file.FullName
  $OutputFile = "$($file.Directory)\$($file.BaseName)-NEW.$FileFormat"
  $EpisodeName = $file.BaseName
  $FinalName = "$($file.Directory)\$($file.BaseName).$FileFormat"
  if(-not($HashTable.ContainsKey("$FinalName"))){
    Start-Job -ScriptBlock {
      Start-Sleep -Seconds 10
      $p = Get-Process -Name HandBrakeCLI
      $p.PriorityClass = [Diagnostics.ProcessPriorityClass]::BelowNormal
    } 
    $StartingFileSize = $file.Length/1GB
    Write-Verbose -Message "Starting conversion on $InputFile it is $([math]::Round($StartingFileSize,2))GB in size before conversion"
    Set-Location -Path $HandBreakDir

    .\HandBrakeCLI.exe -i "$InputFile" -t 1 --angle 1 -o "$OutputFile" -f $FileFormat -w 1862 -l 1066 --crop 0:0:0:58 --modulus 2 -e x265 -q 23 --cfr -a 1 -E copy:* -6 dpl2 -R 48 -B 64 -D 0 --gain 0 --audio-fallback ac3 -m --encoder-preset=veryfast --verbose=1 2> "$LogFileDir\$EpisodeName.txt"

    if( Test-Path -Path $OutputFile ){
      Remove-Item -Path $InputFile -Force
      Rename-Item -Path $OutputFile -NewName $FinalName
      Write-Verbose -Message "Finished converting $FinalName"
      $EndingFile = Get-Item -Path $FinalName | Select-Object -ExpandProperty Length
      $EndingFileSize = $EndingFile.Length/1GB
      Write-Verbose -Message "Ending file size is $([math]::Round($EndingFileSize,2))GB so, space saved is $([math]::Round($StartingFileSize-$EndingFileSize,2))GB"

      $csvFileName = "$FinalName"
      $csvCompletedDate = Get-Date -UFormat '%x - %I:%M %p'
      $hash = @{
        'File Name'    = $csvFileName
        'Completed Date' = $csvCompletedDate
      }
      $newRow = New-Object -TypeName PsObject -Property $hash
      Export-Csv -Path $ConversionCompleted -InputObject $newRow -Append -Force
    }
    elseif (-not(Test-Path -Path $OutputFile)){Write-Verbose -Message "Failed to convert $InputFile"}
  }
  elseif($HashTable.ContainsKey("$FinalName")){Write-Verbose -Message "Skipping $InputFile because it was already converted."}
  Clear-Variable -Name InputFile, OutputFile, EpisodeName, FinalName, AllLargeFiles, TvShowDir, MovieDir, LargeMovieFiles, LargeTvFiles, File, EndingFile, EndingFileSize, TvShowSize, MovieSize -ErrorAction SilentlyContinue
}