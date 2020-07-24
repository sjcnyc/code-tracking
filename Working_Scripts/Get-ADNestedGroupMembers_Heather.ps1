function Get-ADNestedGroupMembers {
param (
[Parameter(ValuefromPipeline=$true,mandatory=$true)][String] $GroupName,
[int] $nesting = -1,
[int]$circular = $null,
[switch]$indent
)
    function indent
    { 
    Param($list)
        foreach($line in $list)
        {
        $space = $null

            for ($i=0;$i -lt $line.nesting;$i++)
            {
            $space += "    "
            }
            $line.name = "$space" + "$($line.name)"
        }
      return $List
    }

$modules = get-module | Select-Object -expand name
    if ($modules -contains "ActiveDirectory")
    {
        $table = $null
        $nestedmembers = $null
        $adgroupname = $null
        $nesting++
        $ADGroupname = get-adgroup $groupname -properties memberof,members
        $memberof = $adgroupname | Select-Object -expand memberof
        write-verbose "Checking group: $($adgroupname.name)"
        if ($adgroupname)
        {
            if ($circular)
            {
                $nestedMembers = Get-ADGroupMember -Identity $GroupName -recursive
                $circular = $null
            }
            else
            {
                $nestedMembers = Get-ADGroupMember -Identity $GroupName | Sort-Object objectclass -Descending
                if (!($nestedmembers))
                {
                    $unknown = $ADGroupname | Select-Object -expand members
                    if ($unknown)
                    {
                        $nestedmembers=@()
                        foreach ($member in $unknown)
                        {
                        $nestedmembers += get-adobject $member
                        }
                    }
                }
            }

            foreach ($nestedmember in $nestedmembers)
            {
                $Props = @{Type=$nestedmember.objectclass;Name=$nestedmember.name;DisplayName="";ParentGroup=$ADgroupname.name;Enabled="";Nesting=$nesting;DN=$nestedmember.distinguishedname;Comment=""}

                if ($nestedmember.objectclass -eq "user") 
                {
                    $nestedADMember = get-aduser $nestedmember -properties enabled,displayname
                    $table = new-object psobject -property $props 
                    $table.enabled = $nestedadmember.enabled
                    $table.name = $nestedadmember.samaccountname
                    $table.displayname = $nestedadmember.displayname
                    if ($indent)
                    { 
                    indent $table | Select-Object @{N="Name";E={"$($_.name)  ($($_.displayname))"}}
                    }
                    else
                    { 
                    $table | Select-Object type,name,displayname,parentgroup,nesting,enabled,dn,comment
                    }
                } 
                elseif ($nestedmember.objectclass -eq "group")
                {  
                    $table = new-object psobject -Property $props
                     
                    if ($memberof -contains $nestedmember.distinguishedname)
                    {
                        $table.comment ="Circular membership" 
                        $circular = 1
                    } 
                    if ($indent)
                    { 
                    indent $table | Select-Object name,comment | ForEach-Object{

						if ($_.comment -ne "")
						{
						[console]::foregroundcolor = "red"
						write-output "$($_.name) (Circular Membership)"
						[console]::ResetColor()
						}
						else
						{
						[console]::foregroundcolor = "yellow"
						write-output "$($_.name)"
						[console]::ResetColor()
						}
                    }
					}
                    else
                    {
                    $table | Select-Object type,name,displayname,parentgroup,nesting,enabled,dn,comment
                    }
                    if ($indent)
                    {
                       Get-ADNestedGroupMembers -GroupName $nestedmember.distinguishedName -nesting $nesting -circular $circular -indent
                    }
                    else
                    {
                       Get-ADNestedGroupMembers -GroupName $nestedmember.distinguishedName -nesting $nesting -circular $circular
                    }

               }
                else
                {

                    if ($nestedmember)
                    {
                        $table = new-object psobject -property $props
                        if ($indent)
                        {
    	                    indent $table | Select-Object name
                        }
                        else
                        {
                        $table | Select-Object type,name,displayname,parentgroup,nesting,enabled,dn,comment
                        }
                     }
                }

            }
         }
    }
    else {Write-Warning "Active Directory module is not loaded"}
}


$Groups = @"
USA-GBL IS&T Help Desk- All Share Access RCAWFP01
"@ -split [System.Environment]::NewLine

foreach ($Group in $Groups) {

$Group | Get-ADNestedGroupMembers | Export-Csv D:\Temp\ist.csv -NoTypeInformation

}
