$Computer_Name = "<HOSTNAME>"
# Enable WinRM
C:\SysInternals\PsExec.exe -s -nobanner \\$Computer_Name /accepteula cmd /c "c:\windows\system32\winrm.cmd quickconfig -quiet" | Out-Null

# Disable the Admin Req.
icm -ComputerName $Computer_Name { Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name RestrictDriverInstallationToAdministrators -Value 0 }
# I'm not yet sure if a reboot is required at this point, or if the drivers can just be installed now.

# Set the value back to what MS recommends.
icm -ComputerName $Computer_Name { Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name RestrictDriverInstallationToAdministrators -Value 1 }

# Quality Check, of the RegKey value.
icm -ComputerName $Computer_Name { Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name RestrictDriverInstallationToAdministrators }