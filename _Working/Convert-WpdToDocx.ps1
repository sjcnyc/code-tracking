Add-Type -Path D:\Temp\Microsoft.Office.Interop.Word.dll

function Convert-WPDtoDocx {
  param(
    [string]
    $wpdPath
    )
  $srcfiles = Get-ChildItem $wpdPath -Filter "*.wpd"
  $word = New-Object -ComObject word.application
  $word.Visible = $False

  foreach ($doc in $srcfiles) {
    Write-Host "Processing :" $doc.fullname
    [object]$newfile = Join-Path -Path $doc.DirectoryName -ChildPath $($doc.BaseName + ".docx")
    #$newfile = Join-Path -Path $doc.DirectoryName -ChildPath $doc.name
    $opendoc = $word.documents.open($doc.FullName)
    $opendoc.saveas($newfile.value, [Microsoft.Office.Interop.Word.WdSaveFormat]::wdFormatDocumentDefault)
    $opendoc.close()
    $doc = $null
  }

  $word.quit()
}


Convert-WPDtoDocx -wpdPath D:\Temp
