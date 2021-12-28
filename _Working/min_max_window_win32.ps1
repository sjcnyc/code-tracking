$sig = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
Add-Type -MemberDefinition $sig -Name NativeMethods -Namespace Win32
#Stop-Process -Name Notepad -ea 0; Notepad.exe
$hwnd = @(Get-Process WindowsTerminal)[0].MainWindowHandle
# Minimize window
[Win32.NativeMethods]::ShowWindowAsync($hwnd, 2)
# Restore window
[Win32.NativeMethods]::ShowWindowAsync($hwnd, 4)
#Stop-Process -Name N