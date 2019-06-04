#requires -Version 1 -Modules NTFSSecurity

$paths = @"
\\storage\columbia$
"@-split [environment]::NewLine

foreach($path in $paths)
{
  Add-NTFSAccess -Account 'BMG\USA-GBL ISI Columbia RW' -AccessRights 'ReadAndExecute' -Path $path -PassThru -ea 0
  Add-NTFSAccess -Account 'BMG\USA-GBL ISI Columbia RO' -AccessRights 'Read' -Path $path -PassThru -ea 0
  Add-NTFSAccess -Account 'BMG\USA-GBL ISI Columbia Admin' -AccessRights 'Modify' -Path $path -PassThru -ea 0
  Add-NTFSAccess -Account 'BMG\USA-GBL Member Server Administrators' -AccessRights 'FullControl' -Path $path -PassThru -ea 0
  Add-NTFSAccess -Account 'BUILTIN\Administrators' -AccessRights 'FullControl' -Path $path -PassThru -ea 0
}