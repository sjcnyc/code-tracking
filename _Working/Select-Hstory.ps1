function Select-Hstory {
  [CmdletBinding(SupportsShouldProcess = $true,
    ConfirmImpact = 'Medium')]
  [Alias("ish")]
  Param(
    # How many things from history should be shown?
    [Parameter(Mandatory = 0, position = 0)][Int]$Count = 100   )

  foreach ($cmd in Get-History -Count:$count |Select-Object Id, CommandLIne, ExecutionStatus, StartExecutionTIme |Out-GridView -PassThru -Title "Select 1 or more commands to invoke" ) {
    if ($pscmdlet.ShouldProcess($cmd.commandline, "Invoke")) {
      Invoke-History -Id $cmd.Id 
    }
  }
}