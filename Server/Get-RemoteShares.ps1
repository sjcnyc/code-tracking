function Get-RemoteShares {
  param (
       [Parameter(Mandatory=$True)] [string]$servername,
       [Parameter(Mandatory=$False)] [string]$export
  )
  $shareColl = @()#Makes an array, or a collection to hold all the object of the same fields.
  $Shares = Get-WmiObject -ComputerName $servername -Class Win32_Share -filter "Type=0 AND name like '%$'" 
  foreach ($share in $shares)
  {
    $shareObject = New-Object PSObject #An object, created and destroyed for each share.
    Add-Member -inputObject $shareObject -memberType NoteProperty -name 'ServerName' -Value $servername
    Add-Member -inputObject $shareObject -memberType NoteProperty -name 'ShareName' -Value $share.Name
    Add-Member -inputObject $shareObject -memberType NoteProperty -name 'SharePath' -Value $share.Path
    Add-Member -inputObject $shareObject -memberType NoteProperty -name 'Description' -Value $share.Description
    $shareObject #Output to the screen for a visual feedback.
    $shareColl += $shareObject #Copy the contents of the object into the Array (Collection)
    #$shareObject = $null #Delete the shareObject.
  }
  if ($export)
  {
    $shareColl | Export-Csv -path "$export\$($servername)_Shares_$((Get-Date).ToString('MM-dd-yyyy')).csv" -NoTypeInformation
  }
}