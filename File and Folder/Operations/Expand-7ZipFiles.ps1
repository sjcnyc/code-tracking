function Expand-7ZipFiles {

    param (
        [string]$SourcePath,
        [string]$targetPath
    )

    foreach ($path in $targetPath) {
    
        Expand-7Zip -ArchiveFileName $path.FullName -TargetPath $targetPath
    }
}