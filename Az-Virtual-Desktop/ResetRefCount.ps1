<#	
	.NOTES
	===========================================================================
	 Created on:   	5/5/2022 7:00 PM
	 Created by:   	sconnea
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


if (($args.Count -gt 0) -and (
		($args[0].ToLower() -eq "/?") -or
		($args[0].ToLower() -eq "/help") -or
		($args[0].ToLower() -eq "-h") -or
		($args[0].ToLower() -eq "--help") -or
		($args[0].ToLower() -eq "-help")))
{
	Clear-Host
	Write-Host("USAGE:")
	Write-Host(".\ResetRefCount.exe")
	Write-Host("Enter a users sAMAccountName to reset the RefCount")
}
else
{
	Clear-Host
	Write-Host "#################################################################" -ForegroundColor Cyan
	Write-Host "#         Reset RefCount for AVD user profiles                  #" -ForegroundColor Cyan
	Write-Host "#          Created By: Sean Connealy -- x4807                   #" -ForegroundColor Cyan
	Write-Host "#################################################################" -ForegroundColor Cyan
	Write-Host ""
	Write-Host ""
	
	$UserName = Read-Host -Prompt "Enter user sAMAccountName"
	$ObjectUser = New-Object System.Security.Principal.NTAccount("me.sonymusic.com", $UserName)
	
	Try
	{
		$strSid = $ObjectUser.Translate([System.Security.Principal.SecurityIdentifier])
		
		# Set variables to indicate value and key to set
		$RegSplat = @{
			Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileService\References\$($strSid.Value)"
			Name = "RefCount"
			Value = ([byte[]](0x00, 0x00, 0x00, 0x00))
			PropertyType = 'BINARY'
			Force = $true
		}
		# Create the key if it does not exist
		If (-NOT (Test-Path $RegSplat.Path))
		{
			Write-Output "$($strSid.Value) does not exist"
		}
		else
		{
			# Now set the value
			New-ItemProperty @RegSplat | Out-Null
			Write-Host "Reset RefCount to zero" -ForegroundColor Green
		}
	}
	catch
	{
		Write-Host "$($UserName) does not exist in Active Directory" -foregroundcolor red
	}
	
	Write-Host -NoNewLine 'Press any key to continue...';
	$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}



