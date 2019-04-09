function Export-FilrewallRules {
    Param(
        $Name = "Remote Desktop*", 
        $CSVFile = "c:\Temp\FirewallRules.csv", 
        [SWITCH]$JSON,
        [string]$servername
    )

    #Requires -Version 4.0
    function StringArrayToList($StringArray) {
        if ($StringArray) {
            $Result = ""
            Foreach ($Value In $StringArray) {
                if ($Result -ne "") { $Result += "," }
                $Result += $Value
            }
            return $Result
        }
        else {
            return ""
        }
    }

    $FirewallRules = Get-NetFirewallRule -DisplayName $Name -PolicyStore "ActiveStore"

    $FirewallRuleSet = @()
    ForEach ($Rule In $FirewallRules) {

        Write-Output "Processing rule `"$($Rule.DisplayName)`" ($($Rule.Name))"

        $AdressFilter        = $Rule | Get-NetFirewallAddressFilter
        $PortFilter          = $Rule | Get-NetFirewallPortFilter
        $ApplicationFilter   = $Rule | Get-NetFirewallApplicationFilter
        $ServiceFilter       = $Rule | Get-NetFirewallServiceFilter
        $InterfaceFilter     = $Rule | Get-NetFirewallInterfaceFilter
        $InterfaceTypeFilter = $Rule | Get-NetFirewallInterfaceTypeFilter
        $SecurityFilter      = $Rule | Get-NetFirewallSecurityFilter

        $HashProps = [PSCustomObject]@{
            ServerName          = $servername
            Name                = $Rule.Name
            DisplayName         = $Rule.DisplayName
            Description         = $Rule.Description
            Group               = $Rule.Group
            Enabled             = $Rule.Enabled
            Profile             = $Rule.Profile
            Platform            = StringArrayToList $Rule.Platform
            Direction           = $Rule.Direction
            Action              = $Rule.Action
            EdgeTraversalPolicy = $Rule.EdgeTraversalPolicy
            LooseSourceMapping  = $Rule.LooseSourceMapping
            LocalOnlyMapping    = $Rule.LocalOnlyMapping
            Owner               = $Rule.Owner
            LocalAddress        = StringArrayToList $AdressFilter.LocalAddress
            RemoteAddress       = StringArrayToList $AdressFilter.RemoteAddress
            Protocol            = $PortFilter.Protocol
            LocalPort           = StringArrayToList $PortFilter.LocalPort
            RemotePort          = StringArrayToList $PortFilter.RemotePort
            IcmpType            = StringArrayToList $PortFilter.IcmpType
            DynamicTarget       = $PortFilter.DynamicTarget
            Program             = $ApplicationFilter.Program -Replace "$($ENV:SystemRoot.Replace("\","\\"))\\", "%SystemRoot%\" -Replace "$(${ENV:ProgramFiles(x86)}.Replace("\","\\").Replace("(","\(").Replace(")","\)"))\\", "%ProgramFiles(x86)%\" -Replace "$($ENV:ProgramFiles.Replace("\","\\"))\\", "%ProgramFiles%\"
            Package             = $ApplicationFilter.Package
            Service             = $ServiceFilter.Service
            InterfaceAlias      = StringArrayToList $InterfaceFilter.InterfaceAlias
            InterfaceType       = $InterfaceTypeFilter.InterfaceType
            LocalUser           = $SecurityFilter.LocalUser
            RemoteUser          = $SecurityFilter.RemoteUser
            RemoteMachine       = $SecurityFilter.RemoteMachine
            Authentication      = $SecurityFilter.Authentication
            Encryption          = $SecurityFilter.Encryption
            OverrideBlockRules  = $SecurityFilter.OverrideBlockRules
        }
        $FirewallRuleSet += $HashProps
    }

    if (!$JSON) {
        $FirewallRuleSet | Export-csv $CSVFile -Append -NoTypeInformation
    }
    else {
        $FirewallRuleSet | ConvertTo-JSON | Set-Content $CSVFile
    }
}

<# @"
BUESMEWFP004
"@ -split [environment]::NewLine | ForEach-Object {
    Export-FilrewallRules -Name "Remote Desktop*" -servername $_
} #>