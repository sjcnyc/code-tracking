function Add-GroupMember {
  [CmdletBinding(
    DefaultParameterSetName = 'Id',
    SupportsShouldProcess = $true
  )]
  param(
    [Parameter(Mandatory = $true,
      ParameterSetName = 'Name')]
    [string]
    $GroupName,

    [Parameter(Mandatory = $true,
      ParameterSetName = 'Id')]
    [string]
    $GroupId,

    [Parameter(Mandatory = $true)]
    [string]
    $UserName
  )

  switch ($PSCmdlet.ParameterSetName) {
    'Name' {
      if ($PSCmdlet.ShouldProcess("Name", "Write-Host")) {
        Write-Host 'You used the Name parameter set.'
        break
      }
    }
    'Id' {
      if ($PSCmdlet.ShouldProcess("ID", "Write-Host")) {
        Write-Host 'You used the Id parameter set.'
        break
      }
    }
  }
}