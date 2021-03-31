function Install-ModuleToDirectory {
  [CmdletBinding()]
  [OutputType('System.Management.Automation.PSModuleInfo')]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    $Name,

    [Parameter(Mandatory = $true)]
    [ValidateScript( { Test-Path $_ })]
    [ValidateNotNullOrEmpty()]
    $Destination
  )

  # Is the module already installed?
  if (-not (Test-Path (Join-Path $Destination $Name))) {
    # Install the module to the custom destination.
    Find-Module -Name $Name -Repository 'PSGallery' | Save-Module -Path $Destination
  }

  # Import the module from the custom directory.
  Import-Module -FullyQualifiedName (Join-Path $Destination $Name)

  return (Get-Module)
}

Install-ModuleToDirectory -Name 'XXX' -Destination 'E:\Modules'