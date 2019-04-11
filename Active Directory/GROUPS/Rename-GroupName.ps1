function Rename-GroupName {
    param (
        [string] $oldName,
        [string] $newName
    )

    Get-QADGroupMember -Identity $oldName -Type 'Group' -indirect |
    ForEach-Object { 
        Add-QADGroupMember -Identity $newName -member $_
    }
}

#Rename-GroupName -oldName 'USA-GBL isi-data-share f15 newtech' -newName 'USA-GBL ISI-Data-share janthony'