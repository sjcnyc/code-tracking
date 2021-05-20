function Export-Filename {
  Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$FileName,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$ExportLocation
  )
  $date = (Get-Date).tostring('MM.dd')
  $generatefilename = $date + '_' + $filename + '.csv'

  $ExportItem = $ExportLocation.Substring($ExportLocation.Length - 1) -eq '\' ?
  "$ExportLocation$generatefilename" : "$ExportLocation\$generatefilename"
  return $ExportItem
}


Export-Filename -FileName test001 -ExportLocation C:\temp