$Array = (

 "*.aac", "*.ac3", "*.aifc", "*.aiff", "*.ape", "*.asf", "*.au", "*.avi", "*.avr", "*.dat", "*.divx", "*.dts", "*.dvd", 
 "*.flac", "*.fli", "*.flv", "*.iff", "*.ifo", "*.irca", "*.m1v", "*.m2v", "*.m4a", "*.mac", "*.mat", "*.mka", "*.mks", 
 "*.mkv", "*.mov", "*.mp2", "*.mp3", "*.mp4", "*.mpeg", "*.mpeg1", "*.mpeg2", "*.mpeg4", "*.mpg", "*.mpgv", "*.mpv", 
 "*.ogg", "*.ogm", "*.paf", "*.pvf", "*.qt", "*.ra", "*.rm", "*.rmvb", "*.sd2", "*.sds", "*.sw", "*.vob", "*.w64", 
 "*.wav", "*.wma", "*.wmv", "*.xi", "*.xvid", "*.m4v" )



Get-ChildItem "\\KOHI-MAC\Sean1\*" -Recurse -Include $Array | Where-Object {!$_.PSIsContainer} | Foreach-Object{

    $dest = Join-Path $_.DirectoryName $_.BaseName
    if(!(Test-Path -Path $dest -PathType Container))
    {
        $null = mkdir $dest
    }

    $_ | Move-Item -Destination $dest -Force
}