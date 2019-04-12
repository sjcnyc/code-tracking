$DebugPreference = 'continue'
 
function Load-FileSystemHelper()
{
    $Code =
  @"
using System;
using System.Text;
using System.IO;
using System.Runtime.InteropServices;
using System.Globalization;
 
public class FileSystemHelper
{
  [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
  private static extern int GetShortPathName(
      [MarshalAs(UnmanagedType.LPTStr)] string path,
      [MarshalAs(UnmanagedType.LPTStr)] StringBuilder shortPath,
      int shortPathLength);
 
  [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
  [return: MarshalAs(UnmanagedType.U4)]
  private static extern int GetLongPathName(
      [MarshalAs(UnmanagedType.LPTStr)]
            string lpszShortPath,
      [MarshalAs(UnmanagedType.LPTStr)]
            StringBuilder lpszLongPath,
      [MarshalAs(UnmanagedType.U4)]
            int cchBuffer);
 
  public static string GetShortPathName(string path)
  {
    StringBuilder shortPath = new StringBuilder(500);
    if (0 == GetShortPathName(path, shortPath, shortPath.Capacity))
    {
      if (Marshal.GetLastWin32Error() == 2)
      {
        throw new Exception("File does not exist!");
      }
      else
      {
        throw new Exception("GetLastError returned: " + Marshal.GetLastWin32Error());
      }
    }
    return shortPath.ToString();
  }
 
 
  public static string GetLongPathName(string shortPath)
  {
    if (String.IsNullOrEmpty(shortPath))
    {
      return shortPath;
    }
 
    StringBuilder builder = new StringBuilder(255);
    int result = GetLongPathName(shortPath, builder, builder.Capacity);
    if (result > 0 && result < builder.Capacity)
    {
      return builder.ToString(0, result);
    }
    else
    {
      if (result > 0)
      {
        builder = new StringBuilder(result);
        result = GetLongPathName(shortPath, builder, builder.Capacity);
        return builder.ToString(0, result);
      }
      else
      {
        throw new FileNotFoundException(
        string.Format(
        CultureInfo.CurrentCulture,
        null,
        shortPath),
        shortPath);
      }
    }
  }
}
"@
     
    Add-Type -TypeDefinition $Code
}
 
 
function Get-DOSPathFromLongName
{
   param
   (
     [System.String]
     $Path
   )

    Load-FileSystemHelper
    $DOSPath = [FileSystemHelper]::GetShortPathName($Path)
    Write-Debug $DOSPath
    return $DOSPath
}
 
function Get-LongNameFromDOSPath
{
   param
   (
     [System.String]
     $Path
   )

    Load-FileSystemHelper
    $LongPath = [FileSystemHelper]::GetLongPathName($Path)
    Write-Debug $LongPath
    return $LongPath
}
 
$DOSPath = Get-DOSPathFromLongName -Path 'C:\Program Files (x86)\'
explorer.exe $DOSPath
$LongPath = Get-LongNameFromDOSPath -Path $DOSPath
explorer.exe $LongPath