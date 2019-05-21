function Test-speed {
    $codetext = $Args -join ' '
    $codetext = $ExecutionContext.InvokeCommand.ExpandString($codetext)
    $code = [ScriptBlock]::Create($codetext)
    $timespan = Measure-Command $code
    "Code took {0:0.000} seconds to run" -f $timespan.TotalSeconds
}