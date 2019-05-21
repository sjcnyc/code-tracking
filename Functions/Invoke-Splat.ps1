Function Invoke-Splat {
    <#
    .Synopsis
        Splats a hashtable on a function in a safer way than the built-in
        mechanism.
    .Example
        Invoke-Splat Get-XYZ $PSBoundParameters
    #>
    param(
        [Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)]
        [string]
        $FunctionName,
        [Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=1)]
        [System.Collections.Hashtable]
        $Parameters
    )
 
    $h = @{}
    ForEach ($key in (Get-Command $FunctionName).Parameters.Keys) {
        if ($Parameters.$key) {
            $h.$key = $Parameters.$key
        }
    }
    if ($h.Count -eq 0) {
        $FunctionName | Invoke-Expression
    }
    else {
        "$FunctionName @h" | Invoke-Expression
    }
}


<#
$myArgs = @{
    Name = "*Tomcat*"
    ComputerName = "somebox.around.here"
    DependentServices = $true
}
 
Invoke-Splat Get-Service $myArgs
Invoke-Splat Get-Process $myArgs
#>

<#
or mixing with @ operator
some-function @myArgs
#>