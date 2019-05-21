function Convert-UNCtoLocalPath()
{
  param([string]$UNC)
  if($unc -eq $null){return 'Error: UNC must be entered'}
  if($unc -notmatch '\$'){return "Error: Only works with paths containing <DriveLetter>$"}
  #Trims the path down to character before $ - end of string.  It then replaces the $ with :
  $Path = $UNC.substring(($UNC.indexof('$')-1),(($unc.length -($unc.IndexOf('$'))))).Replace('$',':')#wizardry
return $path
}