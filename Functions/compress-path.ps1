# Illustrates how to wrap low-level API functions like PathCompactPathEx() to shorten paths,
# and contains a use-case for a better prompt that only shows the relevant parts of the current
# path location to save screen real-estate.


function Compress-Path($Path, $Length=20) {

$sig = @'
[DllImport("shlwapi.dll", CharSet = CharSet.Auto, SetLastError = true)]
public static extern bool PathCompactPathEx(
System.Text.StringBuilder pszOut, string pszSrc, Int32 cchMax,
Int32 dwFlags);
'@

    Add-Type -MemberDefinition $sig -name StringFunctions -namespace Win32


    $sb = New-Object System.Text.StringBuilder(260)
    if ([Win32.StringFunctions]::PathCompactPathEx($sb , $Path , $Length+1, 0)) {
      $sb.ToString()
    } else {
      Throw "Unable to compact path"
    }
}