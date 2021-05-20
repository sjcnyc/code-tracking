$excluded = @('.DS_Store', 'Thumbs.db', '.musicapps-project-folder', '.dummy', '.empty', '.parent ')

$HSfiles = Get-ChildItem2 -Recurse -Path '\\storage\columbia$\201X Dropbox' -File -ErrorAction Continue |
 
 Where-Object { $_.Attributes -match 'Hidden'} 
 
$files = $HSfiles | Where-Object { $_.Name -ne '.DS_Store' -and $_.Name -ne '.dummy' -and $_.Name -ne 'Thumbs.db' -and $_.name -ne '.parent' -and $_.Name -ne '.musicapps-project-folder'}
 
foreach ( $Object in $files ) { 
     
    $object.FullName 
    $Object.Attributes = 'Normal'      
     
}