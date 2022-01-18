

[cmdletbinding(DefaultParameterSetName = 'computer')]
[OutputType('none', 'object')]
Param(
  [parameter(Position = 0, ValueFromPipeline, ParameterSetName = 'computer')]
  [ValidateNotNullOrEmpty()]
  [string]$Computername = $env:COMPUTERNAME,

  [parameter(ValueFromPipeline, ParameterSetName = 'session')]
  [ValidateNotNullOrEmpty()]
  [Microsoft.Management.Infrastructure.CimSession]$CimSession,

  [Parameter(HelpMessage = 'Enter a title to use for the GridView')]
  [ValidateNotNullOrEmpty()]
  [string]$Title = 'Drive Report',

  [Parameter(HelpMessage = 'pass results to the pipeline in addition to the grid view')]
  [switch]$Passthru
)

DynamicParam {
  # Offer to use Out-ConsoleGridView if installed in PowerShell 7
  If (Get-Command -Name Out-ConsoleGridview -ErrorAction SilentlyContinue) {

    $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary

    # Defining parameter attributes
    $attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
    $attributes = New-Object System.Management.Automation.ParameterAttribute
    $attributes.ParameterSetName = '__AllParameterSets'
    $attributes.HelpMessage = 'Use the Out-ConsoleGridView command in PowerShell 7'
    $attributeCollection.Add($attributes)

    # Adding a parameter alias
    $dynalias = New-Object System.Management.Automation.AliasAttribute -ArgumentList 'ocgv'
    $attributeCollection.Add($dynalias)

    # Defining the runtime parameter
    $dynParam1 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter('ConsoleGridView', [Switch], $attributeCollection)
    $paramDictionary.Add('ConsoleGridView', $dynParam1)

    return $paramDictionary
  } # end if
} #end DynamicParam

Begin {
  Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
  Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Collecting drive information...please wait"

  #initialize a list to hold the results
  $results = [System.Collections.Generic.list[object]]::new()

  #hashtable of Get-CimInstance parameters for splatting
  $splat = @{
    Classname   = 'win32_logicaldisk'
    Filter      = 'drivetype=3'
    ErrorAction = 'Stop'
    Property    = 'SystemName', 'DeviceID', 'Size', 'Freespace'
  }

} #begin

Process {
  If ($pscmdlet.ParameterSetName -eq 'computer') {
    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting data from computer $($computername.toUpper())"
    $splat['Computername'] = $Computername
    $remote = $Computername.ToUpper()
  }
  else {
    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting data from cimsession $($cimsession.computername.toUpper())"
    $splat['CimSession'] = $cimSession
    $remote = $cimSession.computername.toUpper()
  }

  Try {
    Get-CimInstance @splat | Select-Object -Property @{Name = 'Computername'; Expression = { $_.Systemname } },
    @{Name = 'Drive'; Expression = { $_.DeviceID } },
    @{Name = 'SizeGB'; Expression = { [int]($_.Size / 1GB) } },
    @{Name = 'FreeGB'; Expression = { [int]($_.Freespace / 1GB) } },
    @{Name = 'UsedGB'; Expression = { [math]::round(($_.size - $_.Freespace) / 1GB, 2) } },
    @{Name = 'Free%'; Expression = { [math]::round(($_.Freespace / $_.Size) * 100, 2) } },
    @{Name = 'FreeGraph'; Expression = {
        [int]$per = (($_.Freespace / $_.Size) * 100 / 2)
        '|' * $per }
    } | ForEach-Object { $results.Add($_) }
  } #try
  Catch {
    Write-Warning "Failed to get drive data from $remote. $($_.exception.message)"
  }

} #process

End {
  #send the results to Out-Gridview
  Write-Verbose "[$((Get-Date).TimeofDay) END    ] Found $($results.count) total items"
  if ($results.count -gt 1) {
    if ($PSBoundParameters.ContainsKey('ConsoleGridView')) {
      $Results | Sort-Object -Property Computername | Out-ConsoleGridView -Title $Title
    }
    else {
      $Results | Sort-Object -Property Computername | Out-GridView -Title $Title
    }
    if ($Passthru) {
      $Results
    }
  }
  else {
    Write-Warning 'No drive data found to report.'
  }
  Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

} #end
