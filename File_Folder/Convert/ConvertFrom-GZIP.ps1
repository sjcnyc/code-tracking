#requires -Version 2
Function ConvertFrom-Gzip
{
  <#
      .SYNOPSIS
      This function will decompress the contents of a GZip file and output it to the pipeline.  Each line in the converted file is
      output as distinct object.

      .DESCRIPTION
      Using the System.IO.GZipstream class this function will decompress a GZip file and send the contents into
      the pipeline.  The output is one System.String object per line.  It supports the various types of encoding
      provided by the System.text.encoding class.

      .EXAMPLE
      ConvertFrom-Gzip -path c:\test.gz

      .EXAMPLE
      get-childitem c:\archive -recure -filter *.gz | convertfrom-Gzip -encoding unicode | select-string -pattern "Routing failed" -simplematch

      .EXAMPLE
      get-item c:\file.txt.gz | convertfrom-Gzip | out-string | out-file c:\file.txt

  #>
  [CmdletBinding()]
  Param
  (
    [Parameter(
    Mandatory = $true,
    ValueFromPipeline = $true,
    ValueFromPipelineByPropertyName = $true,
    ParameterSetName = 'Default')]
    [Alias('Fullname')]
    # [ValidateScript({$_.endswith('.gz*')})]
    [String]$Path,
    [Parameter(Mandatory = $false,
    ParameterSetName = 'Default')]
    [ValidateSet('ASCII','Unicode','BigEndianUnicode','Default','UTF32','UTF7','UTF8')]
    [String]$Encoding = 'ASCII'
  )
  Begin
  {
    Set-StrictMode -Version Latest
    $enc = [System.Text.Encoding]::$Encoding
  }
  Process
  {
    if (-not ([system.io.path]::IsPathRooted($Path)))
    {
      Try 
      {
        $Path = (Resolve-Path -Path $Path -ErrorAction Stop).Path
      }
      catch 
      {
        throw 'Failed to resolve path'
      }
    }
    $file = New-Object -TypeName System.IO.FileStream -ArgumentList $Path, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
    $stream = New-Object -TypeName System.IO.MemoryStream
    $GZipStream = New-Object -TypeName System.IO.Compression.GZipStream -ArgumentList $file, ([System.IO.Compression.CompressionMode]::Decompress)
    $buffer = New-Object -TypeName byte[] -ArgumentList (1024)
    $count = 0
    do
    {
      $count = $GZipStream.Read($buffer, 0, 1024)
      if ($count -gt 0)
      {
        $stream.Write($buffer, 0, $count)
      }
    }
    While ($count -gt 0)
    $array = $stream.ToArray()
    $GZipStream.Close()
    $stream.Close()
    $file.Close()
    $enc.GetString($array).Split("`n")
  }
  End {}
}
