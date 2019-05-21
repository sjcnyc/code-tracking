function to_kmgt {
  param (
    [System.Object] $bytes
  )

  foreach ($i in ('Bytes', 'KB', 'MB', 'GB', 'TB')) {
    if (($bytes -lt 1000) -or ($i -eq 'TB')) {
      $bytes = ($bytes).tostring('F0' + '1')
      return $bytes + " $i"
    }
    else {$bytes /= 1KB}
  }
}