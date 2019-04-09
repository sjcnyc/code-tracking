Function Set-OutGridViewWindowSize {
  [OutputType('System.Automation.WindowInfo')]
  [cmdletbinding()]
  Param (
    [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $True)]
    $ProcessName,

    [parameter(Mandatory = $true)]
    [string]$WindowTitle,

    [int]$X,

    [int]$Y,

    [int]$Width,

    [int]$Height
  )

  Begin {
    Try {
      [void][Window]
    }
    Catch {

      Add-Type @"
              using System;
              using System.Runtime.InteropServices;
              public class Window {
                [DllImport("user32.dll")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
                [DllImport("user32.dll")]
                public extern static bool MoveWindow(IntPtr handle, int x, int y, int width, int height, bool redraw);
              }

              public struct RECT
              {
                public int Left;        // x position of upper-left corner
                public int Top;         // y position of upper-left corner
                public int Right;       // x position of lower-right corner
                public int Bottom;      // y position of lower-right corner
              }
"@
    }
  }

  Process {
    $Rectangle = New-Object RECT
    $Handle = (Get-Process -Name $ProcessName | ? MainWindowTitle -eq $WindowTitle).MainWindowHandle

    if ($Handle) {
      $Return = [Window]::GetWindowRect($Handle, [ref]$Rectangle)

      If ($Return) {
        $Return = [Window]::MoveWindow($Handle, $x, $y, $Width, $Height, $True)
      }
    }
  }
}

$null = Get-Process | Out-GridView -Title "My Processes"

Set-OutGridViewWindowSize -ProcessName powershell -WindowTitle "My Processes" -Width 500 -Height 500