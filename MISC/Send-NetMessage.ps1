Function Send-NetMessage{ 
Param( 
    [Parameter(Mandatory=$True)] 
    [String]$Message,      
    [String]$Session='*',      
    [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
    [Alias('Name')] 
    [String[]]$Computername=$env:computername,      
    [Int]$Seconds='5', 
    [Switch]$VerboseMsg, 
    [Switch]$Wait 
    ) 
     
Begin 
    { 
    Write-Verbose "Sending the following message to computers with a $Seconds second delay: $Message" 
    } 
     
Process 
    { 
    ForEach ($Computer in $ComputerName) 
        { 
        Write-Verbose "Processing $Computer" 
        $cmd = "msg.exe $Session /Time:$($Seconds)" 
        if ($Computername){$cmd += " /SERVER:$($Computer)"} 
        if ($VerboseMsg){$cmd += ' /V'} 
        if ($Wait){$cmd += ' /W'} 
        $cmd += " $($Message)" 
 
        Invoke-Expression $cmd 
        } 
    } 
End 
    { 
    Write-Verbose 'Message sent.' 
    } 
}