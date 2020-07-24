function Get-ADGroupMembers {
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string[]]$group = 'Domain Admins',

        [bool]$Recurse = $true
    )

    Begin {
        #Add the .net type
        $type = 'System.DirectoryServices.AccountManagement'
        Try {
            Add-Type -AssemblyName $type -ErrorAction Stop
        }
        Catch {
            Throw "Could not load $type`: Confirm .NET 3.5 or later is installed"
            Break
        }
        $ct = [System.DirectoryServices.AccountManagement.ContextType]::Domain
    }
    Process {
        #List group members
        foreach ($GroupName in $group) {
            Try {
                $grp = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($ct, $GroupName)

                #display results or warn if no results
                if ($grp) {
                    $grp.GetMembers($Recurse)
                }
                else {
                    Write-Warning "Could not find group '$GroupName'"
                }
            }
            Catch {
                Write-Error "Could not obtain members for $GroupName`: $_"
                Continue
            }
        }
    }
    End {
        #cleanup
        $ct = $grp = $null
    }
}

function Get-SDADuser {
    [cmdletbinding()]
    [Parameter(Position = 0, ValueFromPipeline = $true)]
    Param(
        [string[]]$user
    )

    Begin {
        $type = 'System.DirectoryServices.AccountManagement'
        Try {
            Add-Type -AssemblyName $type -ErrorAction Stop
        }
        catch {
            Throw "Could not load $type`: Confirm .NET 3.5 or later is installed"
            Break
        }
        $ct = [System.DirectoryServices.AccountManagement.ContextType]::Domain
    }
    Process {
        $usr = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($ct, $user)
        if ($usr) {
            $usr
        }
        else {
            write-warning "oops"
        }
    }
}