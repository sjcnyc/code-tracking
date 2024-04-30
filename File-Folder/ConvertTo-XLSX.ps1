#requires -Version 2
function ConvertTo-XLSX 
{
  <#
      .SYNOPSIS
      XLS files within a provided path are recursively enumerated and convert to XLSX files.
      .DESCRIPTION
      XLS files within a provided path are recursively enumerated and convert to XLSX files.
      The original XLS files remain intact, a new XLSX file will be created.
      .PARAMETER Path
      This parameter takes the input of the path where the XLS files are located.
      .PARAMETER Visible
      Using the parameter will show you how Excel does the work. Not using the parameter will enable Excel 
      to accomplish its tasks in the background.

      Note: Bu not using this parameter you will be able to convert some XLS files which have corruptions 
      in them, when using the parameter and therefor the Excel GUI will give you an error.
      .PARAMETER ToFolder
      This parameter enables you to provide a location where the file is saved. When this parameter is 
      not used, the file will be saved as an XLS file in the same location as where the 
      original XLS file is located.
      .EXAMPLE
      ConvertTo-XLSX -Path 'D:\Data\2012'
      .EXAMPLE
      ConvertTo-XLSX -Path 'D:\Data\2012' -Visible
      .EXAMPLE
      ConvertTo-XLSX -Path 'D:\Data\2012' -ToFolder 'D:\Data\2012XLSX'
      .EXAMPLE
      ConvertTo-XLSX -Path 'D:\Data\2012' -Visible -ToFolder 'D:\Data\2012XLSX'
  #>
  [cmdletbinding()]
  param (
    [parameter(mandatory = $true)][string]$Path,
    [parameter(mandatory = $false)][switch]$Visible,
    [parameter(mandatory = $false)][string]$ToFolder
  )
  begin {
    $xlFixedFormat = [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault
    $Excel = New-Object -ComObject excel.application
    if ($Visible -eq $true) 
    {
      $Excel.visible = $true
    }
    else 
    {
      $Excel.visible = $false
    }
    $filetype = '*xls'
  } process {
    if (Test-Path -Path $Path) 
    {
      Get-ChildItem -Path $Path -Include '*.xls' -Recurse | ForEach-Object -Process {
        if ($ToFolder -ne '') 
        {
          $FilePath = Join-Path -Path $ToFolder -ChildPath $_.BaseName
          $FilePath += '.xlsx'
        }
        else 
        {
          $FilePath = ($_.fullname).substring(0, ($_.FullName).lastindexOf('.'))
          $FilePath += '.xlsx'
        }
        $WorkBook = $Excel.workbooks.open($_.fullname)
        $WorkBook.saveas($FilePath, $xlFixedFormat)
        $WorkBook.close()
        $OldFolder = $Path.substring(0, $Path.lastIndexOf('\')) + '\old'
      }
    }
    else 
    {
      return 'No path provided or access has been denied.'
    }
  } end {
    $Excel.Quit()
    $Excel = $null
    [gc]::collect()
    [gc]::WaitForPendingFinalizers()
  }
}
