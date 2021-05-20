class ValidatePathExistsAttribute : System.Management.Automation.ValidateArgumentsAttribute {
  # the value to be checked surfaces in $path and must be of type [object]
  [void]Validate([object]$path, [System.Management.Automation.EngineIntrinsics]$engineIntrinsics) {
    # if anything is wrong with the value, throw an exception
    if ([string]::IsNullOrWhiteSpace($path)) {
      Throw [System.ArgumentNullException]::new()
    }
    if (-not (Test-Path -Path $path)) {
      Throw [System.IO.FileNotFoundException]::new()
    }

    # if NO exception was thrown, the value is accepted
  }
}
#endregion


[ValidatePathExists()][string]$Path = "c:\windows"
$Path = "c:\test123"