function Out-Notepad {
  param
  (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [Object]
    [AllowEmptyString()]
    $Object,

    [Int]
    $Width = 150
  )
 
  begin {
    $al = New-Object System.Collections.ArrayList
  }

  process {
    [void] $al.Add($Object)
  }
  end {
    $text = $al |
    Format-Table -AutoSize -Wrap |
    Out-String -Width $Width
 
    $process = Start-Process 'C:\Program Files\Notepad3\Notepad3.exe' -PassThru
    $notepad = $process.MainWindowHandle
    [void] $process.WaitForInputIdle()
 
    $sig = '
      [DllImport("user32.dll", EntryPoint = "FindWindowEx")]public static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);
      [DllImport("user32.dll")]public static extern int SendMessage(IntPtr hWnd, int uMsg, int wParam, string lParam);
    '

    $type = Add-Type -MemberDefinition $sig -Name APISendMessage2 -PassThru
    $hwnd = $notepad
    $WM_SETTEXT = '0x000C'
    $test1 = "this is a test"

    [IntPtr]$child = $type::FindWindowEx($hwnd, [IntPtr]::Zero, 'Edit', $null)
    [void]$type::SendMessage($child, $WM_SETTEXT, [IntPtr]::Zero, $text1)
  }
}

Get-Process | Out-Notepad