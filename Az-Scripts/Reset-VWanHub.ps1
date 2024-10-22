function Reset-VWanHub {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName
    )

    # Define parameters for retrieving the existing Virtual Hub
    $getAzVirtualHubSplat = @{
        ResourceGroupName = $ResourceGroupName
        Name              = $Name
    }

    # Get the existing Virtual Hub
    $existingHub = Get-AzVirtualHub @getAzVirtualHubSplat

    # Define parameters for adding a new route to the Virtual Hub
    $addAzVirtualHubRouteSplat = @{
        DestinationType = "CIDR"
        Destination     = @("10.4.0.0/16", "10.5.0.0/16")  # Destination CIDR blocks
        NextHopType     = "IPAddress"
        NextHop         = @("10.0.0.68")  # Next hop IP address
    }

    # Add the new route to the Virtual Hub
    $route1 = Add-AzVirtualHubRoute @addAzVirtualHubRouteSplat

    # Define parameters for creating a new route table
    $addAzVirtualHubRouteTableSplat = @{
        Route      = @($route1)  # Use the newly created route
        Connection = @("All_Vnets")  # Apply to all connected VNets
        Name       = "routeTable1"
    }

    # Create the new route table
    $routeTable1 = Add-AzVirtualHubRouteTable @addAzVirtualHubRouteTableSplat

    # Update the Virtual Hub with the new route table
    Set-AzVirtualHub -VirtualHub $existingHub -RouteTable @($routeTable1)
}
