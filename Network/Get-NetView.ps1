function Get-NetView  {
  param
  (
    [System.Array]
    $servers
  )
  
  foreach ($server in $servers) 
  {
    
    $nv=net.exe view $server 2> $null 
    
    $nv[7..$nv.length] | 
    ForEach-Object  {
      $nv = $_ | Select-Object -Property  shareName , Type, IPAddress
      $nv.ShareName, $nv.type,$nv.IPAddress,$null=($_ -split '\s{2,}')
      if ([bool]($nv.IPAddress -as [ipaddress])) 
      { 
        $nv | Sort-Object sharename 
      }
    } | 
    
    Format-Table -AutoSize 
  }
  
}


get-NetView -servers \\usnycvwprt002