function Manage-Service {
    <#
    .SYNOPSIS
    Manage a Windows Service

    .DESCRIPTION
    Stop, Start, Restart, or Suspend a Windows Service

    .PARAMETER Action
    Stop, Start, Restart, or Suspend

    .EXAMPLE
    Manage-Service -Action Stop -Service SomeService
    Stops SomeService Service

    .NOTES
    File Name  : Manage-Service
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0
    Date       : 8/24/2016

    .LINK
    This script posted to: http://www.github/sjcnyc
  #>

    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Stop', 'Start', 'Restart', 'Suspend')]
        $Action,
        $computerName
    )
    dynamicparam {
        # dynamically add a new parameter called -Service
        # with a ValidateSet that contains all currently
        # running services
        $Bucket = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary

        $AttributeList = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
        #$Values = Get-Service | Where-Object { $_.Status -eq 'Running' } | Select-Object -ExpandProperty DisplayName
        $Values = Get-Service -ComputerName $computerName | Select-Object -ExpandProperty Name
        $AttribValidateSet = New-Object System.Management.Automation.ValidateSetAttribute($Values)
        $AttributeList.Add($AttribValidateSet)
    
        $AttribParameter = New-Object System.Management.Automation.ParameterAttribute
        $AttribParameter.Mandatory = $true
        $AttributeList.Add($AttribParameter)
        $ParameterName = 'Service'
        $Parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($ParameterName, [String], $AttributeList)
        $Bucket.Add($ParameterName, $Parameter)
        $Bucket
    }
    end {
        # Important: Make sure dynamic parameters are
        # available. They only exist in $PSBoundParameters
        # and need to be manually transferred to a variable
        Foreach ($key in $PSBoundParameters.Keys) {
            if ($MyInvocation.MyCommand.Parameters.$key.isDynamic) {
                Set-Variable -Name $key -Value $PSBoundParameters.$key
            }
        }
    
        Switch ($Action) {
            'Stop' { Stop-Service -InputObject $Service -Force }
            'Start' { Start-Service -InputObject $Service  }
            'Restart' { Restart-Service -InputObject $Service -Force }
            'Suspend' { Suspend-Service -InputObject $Service  }
        }
    }
}


Manage-Service -computerName ny1 -Action Restart -Service Spooler