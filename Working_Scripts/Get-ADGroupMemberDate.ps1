Function Get-ADGroupMemberDate {
    [OutputType('ActiveDirectory.Group.Info')]
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $True)]
        [Alias('DistinguishedName')]
        [string]$Group,
        [parameter()]
        [string]$DomainController = ($env:LOGONSERVER -replace '\\\\')
    )
    Begin {
        #RegEx pattern for output
        [regex]$pattern = '^(?<State>\w+)\s+member(?:\s(?<DateTime>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})\s+(?:.*\\)?(?<DC>\w+|(?:(?:\w{8}-(?:\w{4}-){3}\w{12})))\s+(?:\d+)\s+(?:\d+)\s+(?<Modified>\d+))?'
    }
    Process {
        If ($Group -notmatch '^CN=.*') {
            Write-Verbose "Attempting to get distinguished name of $Group"

            Try {
                $distinguishedName = ([adsisearcher]"name=$group").Findone().Properties['distinguishedname'][0]
                If (-Not $distinguishedName) {Throw 'Fail!'}
            }
            Catch {
                Write-Warning "Unable to locate $group"
                Break
            }
        }
        Else {$distinguishedName = $Group}

        Write-Verbose "Distinguished Name is $distinguishedName"
        $data = (repadmin /showobjmeta $DomainController $distinguishedName | Select-String '^\w+\s+member' -Context 2)

        ForEach ($rep in $data) {
            If ($rep.line -match $pattern) {
                $object = New-Object PSObject -Property @{
                    Username         = [regex]::Matches($rep.context.postcontext, 'CN=(?<Username>.*?),.*') | ForEach-Object {$_.Groups['Username'].Value}
                    LastModified     = If ($matches.DateTime) {[datetime]$matches.DateTime} Else {$Null}
                    DomainController = $matches.dc
                    Group            = $distinguishedName
                    State            = $matches.state
                    ModifiedCount    = $matches.modified
                }

                $object.pstypenames.insert(0, 'ActiveDirectory.Group.Info')
                $object
            }
        }
    }
}