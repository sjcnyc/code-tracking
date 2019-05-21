function Format-TimeAgo {
    [CmdletBinding(DefaultParameterSetName = 'TimeSpan',
        PositionalBinding = $false,
        ConfirmImpact = 'Low')]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0,
            ParameterSetName = 'DateTime')]
        [DateTime]
        $Date
    )
    Process {
        $TimeSpan = New-TimeSpan -Start $Date -End (Get-Date)

        if ( $TimeSpan.TotalMilliseconds -lt (New-TimeSpan -Minutes 1).TotalMilliseconds ) {
            $Unit = [Math]::Abs([Math]::Round($TimeSpan.TotalMilliseconds / 1000))
            $String = ' second[s] ago'
        }
        elseif ( $TimeSpan.TotalMilliseconds -lt (New-TimeSpan -Hours 1).TotalMilliseconds ) {
            $Unit = [Math]::Round($TimeSpan.TotalMilliseconds / (New-TimeSpan -Minutes 1).TotalMilliseconds)
            $String = ' minute[s] ago'
        }
        elseif ( $TimeSpan.TotalMilliseconds -lt (New-TimeSpan -Days 1).TotalMilliseconds ) {
            $Unit = [Math]::Round($TimeSpan.TotalMilliseconds / (New-TimeSpan -Hours 1).TotalMilliseconds)
            $String = ' hour[s] ago'
        }
        elseif ( $TimeSpan.TotalMilliseconds -lt (New-TimeSpan -Days 7).TotalMilliseconds ) {
            $Unit = [Math]::Round($TimeSpan.TotalMilliseconds / (New-TimeSpan -Days 1).TotalMilliseconds)
            $String = ' day[s] ago'
        }
        elseif ( $TimeSpan.TotalMilliseconds -lt (New-TimeSpan -Days 30).TotalMilliseconds ) {
            $Unit = [Math]::Round($TimeSpan.TotalMilliseconds / (New-TimeSpan -Days 7).TotalMilliseconds)
            $String = ' week[s] ago'
        }
        elseif ( $TimeSpan.TotalMilliseconds -lt (New-TimeSpan -Days 365).TotalMilliseconds ) {
            $Unit = [Math]::Round($TimeSpan.TotalMilliseconds / (New-TimeSpan -Days 30).TotalMilliseconds)
            $String = ' month[s] ago'
        }
        else {
            $Unit = [Math]::Round($TimeSpan.TotalMilliseconds / (New-TimeSpan -Days 365).TotalMilliseconds)
            $String = ' year[s] ago'
        }

        if ( $Unit -eq 1 ) {
            $String = $String.Replace('[s]', '')
        }
        else {
            $String = $String.Replace('[s]', 's')
        }

        return ( $Unit.ToString() + $String )
    }
}