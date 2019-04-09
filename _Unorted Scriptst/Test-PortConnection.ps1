Function Test-PortConnection {
    [CmdletBinding()]
              
    # Parameters used in this function
    Param
    (
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "Provide destination source", ValueFromPipeline = $true)] 
        $Destination,
 
        [Parameter(Position = 1, Mandatory = $False, HelpMessage = "Provide port numbers", ValueFromPipeline = $true)] 
        $Ports = "80"
    ) 
      
    $ErrorActionPreference = "SilentlyContinue"
    $Results = @()
 
    ForEach ($D in $Destination) {
        # Create a custom object 
        $Object = New-Object PSCustomObject
        $Object | Add-Member -MemberType NoteProperty -Name "Destination" -Value $D
 
 
        Write-Verbose "Checking $D" -ForegroundColor Yellow
        ForEach ($P in $Ports) {
            $Result = (Test-NetConnection -Port $p -ComputerName $D ).PingSucceeded  
          
            If (!$Result) {
                $Status = "Failure"
            }
            Else {
                $Status = "Success"
            }
 
            $Object | Add-Member Noteproperty "$("Port " + "$p")" -Value "$($status)"
        }
 
        $Results += $Object
 
        <# or easier way true/false value
        ForEach ($P in $Ports)
        {
            $Result = $null
            $Result = Test-NetConnection -Port $p -ComputerName $D  
            $Object | Add-Member Noteproperty "$("Port " + "$p")" -Value "$($Result)" 
        }
 
        $Results += $Object
#>
    }
 
    # Final results displayed in new pop-up window
    If ($Results) {
        $Results
    }
}