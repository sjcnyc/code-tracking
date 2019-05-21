Function Remove-InvalidFileNameChars {
  param(
    [Parameter(Mandatory=$true,
      Position=0,
      ValueFromPipeline=$true,
      ValueFromPipelineByPropertyName=$true)]
    [String]$Name
  )

 # $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
 # $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
  [System.IO.Path]::GetInvalidFileNameChars() | % {$Name = $Name.replace($_ ,'-')}
  return ($Name)
}

Remove-InvalidFileNameChars -Name '\\storage\rec_ba\Contracts & Summaries - RMG ARTISTS\RMG MUSIC GROUP ARTISTS'