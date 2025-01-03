[CmdletBinding(DefaultParameterSetName='InputObject', SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='https://go.microsoft.com/fwlink/?LinkID=113385')]
param(
    [switch]
    ${Force},

    [Parameter(ParameterSetName='Default', Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('ServiceName')]
    [string[]]
    ${Name},

    [Parameter(ParameterSetName='InputObject', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [System.ServiceProcess.ServiceController[]]
    ${InputObject},

    [switch]
    ${PassThru},

    [Parameter(ParameterSetName='DisplayName', Mandatory=$true)]
    [string[]]
    ${DisplayName},

    [ValidateNotNullOrEmpty()]
    [string[]]
    ${Include},

    [ValidateNotNullOrEmpty()]
    [string[]]
    ${Exclude})

begin
{
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Restart-Service', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } catch {
        throw
    }
}

process
{
    try {
        $steppablePipeline.Process($_)
    } catch {
        throw
    }
}

end
{
    try {
        $steppablePipeline.End()
    } catch {
        throw
    }
}
<#

.ForwardHelpTargetName Microsoft.PowerShell.Management\Restart-Service
.ForwardHelpCategory Cmdlet

#>

