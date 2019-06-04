function Get-ComputerSystem {
    
    [CmdletBinding(DefaultParameterSetName='query', RemotingCapability='OwnedByCommand')]
    param(
        
    [Parameter(ParameterSetName='list')]
    [switch]
    ${Recurse},

    [Parameter(ParameterSetName='query', Position=1)]
    [string[]]
    ${Property},

    [Parameter(ParameterSetName='query')]
    [string]
    ${Filter},

    [switch]
    ${Amended},

    [Parameter(ParameterSetName='WQLQuery')]
    [Parameter(ParameterSetName='query')]
    [switch]
    ${DirectRead},

    [Parameter(ParameterSetName='list')]
    [switch]
    ${List},

    [switch]
    ${AsJob},

    [Parameter(ParameterSetName='path')]
    [Parameter(ParameterSetName='list')]
    [Parameter(ParameterSetName='class')]
    [Parameter(ParameterSetName='WQLQuery')]
    [Parameter(ParameterSetName='query')]
    [System.Management.ImpersonationLevel]
    ${Impersonation},

    [Parameter(ParameterSetName='class')]
    [Parameter(ParameterSetName='list')]
    [Parameter(ParameterSetName='query')]
    [Parameter(ParameterSetName='path')]
    [Parameter(ParameterSetName='WQLQuery')]
    [System.Management.AuthenticationLevel]
    ${Authentication},

    [Parameter(ParameterSetName='path')]
    [Parameter(ParameterSetName='query')]
    [Parameter(ParameterSetName='class')]
    [Parameter(ParameterSetName='WQLQuery')]
    [Parameter(ParameterSetName='list')]
    [string]
    ${Locale},

    [Parameter(ParameterSetName='path')]
    [Parameter(ParameterSetName='WQLQuery')]
    [Parameter(ParameterSetName='query')]
    [Parameter(ParameterSetName='class')]
    [Parameter(ParameterSetName='list')]
    [switch]
    ${EnableAllPrivileges},

    [Parameter(ParameterSetName='WQLQuery')]
    [Parameter(ParameterSetName='list')]
    [Parameter(ParameterSetName='path')]
    [Parameter(ParameterSetName='class')]
    [Parameter(ParameterSetName='query')]
    [string]
    ${Authority},

    [Parameter(ParameterSetName='WQLQuery')]
    [Parameter(ParameterSetName='path')]
    [Parameter(ParameterSetName='query')]
    [Parameter(ParameterSetName='class')]
    [Parameter(ParameterSetName='list')]
    [pscredential]
    ${Credential},

    [int]
    ${ThrottleLimit},

    [Parameter(ParameterSetName='path')]
    [Parameter(ParameterSetName='query')]
    [Parameter(ParameterSetName='list')]
    [Parameter(ParameterSetName='class')]
    [Parameter(ParameterSetName='WQLQuery')]
    [Alias('Cn')]
    [ValidateNotNullOrEmpty()]
    [string[]]
    ${ComputerName}
    )
    
    begin {
        
    }
    process {
         
        $getWmiObjectParameters = $psBoundParameters + @{ 
            Query='Select * From Win32_ComputerSystem' 

        } 

       # $Query = Get-WmiObject @GetWmiObjectParameters 
        $query = Get-CimInstance @GetWmiObjectParameters
        New-Object PSObject -Property @{
            'Domain'= $Query.domain
            'Manufacturer'=$Query.manufacturer
            'Model'=$Query.model
            'Name'=$Query.name
           # 'SerialNumber'=Get-WmiObject win32_bios -ComputerName $ComputerName | Select-Object -ExpandProperty serialnumber
            }
    
    }
    end {
        
    }
}


$computers = Get-QADComputer -SearchRoot 'bmg.bagint.com/usa' -OSName 'Windows*Server*' | Select-Object name

foreach ($comp in $computers) {



Get-ComputerSystem -ComputerName $comp

}