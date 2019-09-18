$DebugPreference = 'Continue'
$InformationPreference = 'Continue'
$VerbosePreference = 'Continue'

# Get O365 Groups using PnP
#Connect-PnPOnline -Url https://sonymusicentertainment-admin.sharepoint.com -UseWebLogin
#Connect-PnPOnline -Url https://sonymusicentertainment-admin.sharepoint.com -Scopes "Group.ReadWrite.All","User.Read.All","Directory.Read.All","Sites.Read.All" -UseWebLogin

# Get O365 Groups using Exchange Online
#Connect-ExchangeOnlineShell
#Disconnect-ExchangeOnlineShell

# Connect to Teams (use admin credentials)
#Connect-MicrosoftTeams


function Get-RecentGroups {

    Param(
        [int]$Days = 1
    )

    #Write-Verbose "Getting groups"
    $fromDate = (Get-Date).AddDays(-$Days).ToString('MM/dd/yyyy')
    $groups = Get-UnifiedGroup -Filter "WhenCreated -gt '$fromDate'" | select- @{N='GroupId'; E={$_.ExternalDirectoryObjectId}}, DisplayName, AccessType, WhenCreated


    foreach ($group in $groups) {

        $owners = Get-UnifiedGroupLinks -Identity $group.GroupId -LinkType Owners | select Name, @{N='Email'; E={$_.PrimarySmtpAddress}}, CountryOrRegion, City, Department
        $ownerCount = ($owners | measure).Count

        $members = Get-UnifiedGroupLinks -Identity $group.GroupId -LinkType Members | select Name, @{N='Email'; E={$_.PrimarySmtpAddress}}, CountryOrRegion, City, Department
        $memberCount = ($members | measure).Count

        #Write-Debug "Adding $ownerCount owners, $memberCount members to Group $($group.GroupId)"

        $group | Add-Member -MemberType NoteProperty -Name Owners -Value $owners.Email -Force
        $group | Add-Member -MemberType NoteProperty -Name OwnerCount -Value $ownerCount -Force

        $group | Add-Member -MemberType NoteProperty -Name Members -Value $members.Email -Force
        $group | Add-Member -MemberType NoteProperty -Name MemberCount -Value $memberCount -Force

        $owningCountry = $owners.CountryOrRegion | select -First 1
        $group | Add-Member -MemberType NoteProperty -Name Country -Value $owningCountry -Force
    }

    $groups
}


function Get-TeamStats {

    Param(
        [Parameter(Mandatory = $true)]
        [string]$Identity
    )

    <#
    # Check whether Teams is enabled for the group
    try {
        $channels = Get-TeamChannel -GroupId $_.GroupId
        $teamsEnabled = $true
    }
    catch {
        $errorCode = $_.Exception.ErrorCode
        Switch ($errorCode) {
            "404" {
                $teamsEnabled = $false
                break;
            }
            "403" {
                $teamsEnabled = $true
                break;
            }
            default {
                Write-Error ("Unknown ErrorCode trying to Get-TeamChannel")
                $teamEnabled = $false
            }
        }
    }
    #>

    $teamsChatData = Get-MailboxFolderStatistics -Identity $Identity -IncludeOldestAndNewestItems -FolderScope ConversationHistory
    
    if ($teamsChatData.ItemsInFolder[1] -ne 0) {
        $lastItemAddedtoTeams = $teamsChatData.NewestItemReceivedDate[1]
        $numberofChats = $teamsChatData.ItemsInFolder[1]
    }

    [pscustomobject]@{
        'LastChat' = $lastItemAddedtoTeams
        'NumberOfChats' = $numberofChats
    }
}

<#
# Test connection
Try {
    $orgName = (Get-OrganizationConfig).Name
}
Catch {
    Write-Error "Your PowerShell session is not connected to Exchange Online."
    Write-Error "Please connect to Exchange Online using an administrative account and retry."
    Break
}


# Save to JSON file
Write-Verbose "Save group data to file"
Get-RecentGroups -Days 30 | ConvertTo-Json | Set-Content "O365_Groups.json"
#>

$groups = (Get-Content ".\O365_Groups.json" | ConvertFrom-Json)


# Get incomplete list items from SP Governance Site (use admin credentials or appid/secret)
#Connect-PnPOnline -Url https://sonymusicentertainment.sharepoint.com/sites/O365Governance -UseWebLogin

$listName = 'Group Registry'

$listItems = (Get-PnPListItem -List $listName).FieldValues

# No list item found for the group
$groups | ? {$_.GroupId -notin $listItems.GroupId} | % {

    Write-Information "Creating list item for $($_.DisplayName)"

    # Create new list item
    $itemId = (Add-PnPListItem -List "Groups" -Values @{
        Title = $_.DisplayName
        GroupId = $_.GroupId
        Country = $_.Country
        GroupOwners = [string[]]$_.Owners
        GroupMembers = [string[]]$_.Members
        GroupMembersCount = $_.MemberCount
        GroupCreatedDate = $_.WhenCreated
        AccessType = $_.AccessType
        #TeamsEnabled = $teamsEnabled
        GroupStatus = 'Active'
        SubmissionDueDate = (Get-Date).AddDays(2)}).ID

    Write-Debug "Item created, Id: $itemId"

    # Set contribute permissions for owners
    foreach ($owner in $_.Owners) {
        Write-Debug "Setting contribute permission for owner: $($owner)"
        Set-PnPListItemPermission -List $listName -Identity $itemId -User $owner -AddRole 'Contribute'
    }

    # Send email to group owners
    #Send-PnPMail -To $owners
}

# Process list items
$listItems | ? {$_.Classification -ne $null -and $_.RegistrationComplete -eq $false -and $_.GroupStatus -eq 'Active'} | % {

    if ($_.Classification -eq 'Secret') {
        # Handle Secret
    }
    else {
        Write-Information "Processing list item ID: $($_.ID), Title: $($_.Title)"

        Set-PnPListItem -List $listName -Identity $_.ID -Values @{'RegistrationComplete' = $true}

        # Set item to read only 
        foreach ($owner in $_.GroupOwners) {
            Write-Debug "Setting read-only permission for owner: $($owner.Email)"
            Set-PnPListItemPermission -List $listName -Identity $_.ID -User $owner.Email -RemoveRole 'Contribute'
            Set-PnPListItemPermission -List $listName -Identity $_.ID -User $owner.Email -AddRole 'Read'
        }

        # Send email to group owners
        #Send-PnPMail -To $owners
    }
}


# Process overdue items
$listItems | ? {$_.Classification -eq $null -and $_.RegistrationComplete -eq $false -and $_.GroupStatus -eq 'Active' -and 
    $_.SubmissionDueDate -ne $null -and $_.SubmissionDueDate -lt (Get-Date)} | % {

    Write-Information "Disabling group: $($_.Title)"

    # Update owners and members in SP list#
    $owners = (Get-PnPUnifiedGroupOwners -Identity $_.GroupId).UserPrincipalName
    $members = (Get-PnPUnifiedGroupMembers -Identity $_.GroupId).UserPrincipalName

    Set-PnPListItem -List $listName -Identity $_.ID -Values @{
        GroupOwners = $owners
        GroupMembers = $members
        GroupStatus = 'Disabled'}

    # Remove owners and members (to disable group)
    #Set-PnPUnifiedGroup -Identity $_.GroupID -Owners $null -Members $null

    # Send email to owners
    #Send-PnPMail -to $owners
}