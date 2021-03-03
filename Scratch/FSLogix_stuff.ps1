$connectTestResult = Test-NetConnection -ComputerName stfslogicxprofiles.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
  # Save the password so the drive will persist on reboot
  cmd.exe /C "cmdkey /add:`"stfslogicxprofiles.file.core.windows.net`" /user:`"Azure\stfslogicxprofiles`" /pass:`"UtUFwhwaRP/5zhGCeTgvQrZkf6buroQA5cMxxhvVL4AqPGVp3i8oFJRcAHJKCgaf/XWjnP/zWm9Vw2mdzbkS8A==`""
  # Mount the drive
  New-PSDrive -Name Z -PSProvider FileSystem -Root "\\stfslogicxprofiles.file.core.windows.net\fslogicxprofiles" -Persist
}
else {
  Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}