Function Get-NtfsRights
{
   param
   (
     [System.Object]
     $name,

     [System.Object]
     $path,

     [System.Object]
     $comp
   )

	$path = [regex]::Escape($path)
	$share = "\\$comp\$name"
	$wmi = Get-WmiObject Win32_LogicalFileSecuritySetting -filter "path='$path'" -ComputerName $comp
	$wmi.GetSecurityDescriptor().Descriptor.DACL | Where-Object {$_.AccessMask -as [Security.AccessControl.FileSystemRights]} `
     |Select-Object `
				@{name='Principal';Expression={'{0}\{1}' -f $_.Trustee.Domain,$_.Trustee.name}},
				@{name='Rights';Expression={[Security.AccessControl.FileSystemRights] $_.AccessMask }},
				@{name='AceFlags';Expression={[Security.AccessControl.AceFlags] $_.AceFlags }},
				@{name='AceType';Expression={[Security.AccessControl.AceType] $_.AceType }},
				@{name='ShareName';Expression={$share}}
}


