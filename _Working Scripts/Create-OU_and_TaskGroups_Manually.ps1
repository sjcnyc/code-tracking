# For group creation:
# Grab global variable from module with desired suffixes
# Create a prefix variable for the group name
$gpre = "T0_STG_NA_USA_FRK_L_"
# Loop through suffixes, creating a variable with the full group name, and use the New-ADGroup command to create the groups
Foreach ($s in $suffixes){
    $gname = "$($gpre)$($s)";
    New-ADGroup -Path "OU=Tasks,OU=Groups,OU=GBL,OU=USA,OU=NA,OU=ADM,OU=Tier-1,DC=me,DC=sonymusic,DC=com" -name $gname -groupscope DomainLocal -GroupCategory Security
}
# The above will need to be completed for each tier (0,1,2), focus (ADM,SRV,STD,STG), and object type (Users,Workstations,Groups,Servers) – whole thing could be done with a single set of embedded loops
# Note: With Servers, this will result in two DomainLocal groups for SrvAdmin and SrvRDU being created in the above container. These need to be changed to Global scope, renamed to change the "_L_" to "_G_", and moved to the SrvAccess container instead # of Tasks

#For permissions delegation:
# Grab global variable from module with desired suffixes
# Create a prefix group variable for the regional and location specific group name variations
$gpre = @("T0_STG_NA_USA_FRK_L_","T0_STG_NA_L_")
# Loop through the suffixes, with a sub-loop for the prefixes, to apply the permissions, updating the target OU to match the object type
Foreach ($s in $suffixes){
    foreach ($g in $gpre) {
        $gname = "$($g)$($s)";
        Set-MEOrgAcl -TargetOU "OU=Users,OU=FRK,OU=USA,OU=NA,OU=ADM,OU=Tier-1,DC=me,DC=sonymusic,DC=com" -ADGroup $gname
    }
}
# Note: When setting permissions for workstations, or servers, you will get a few errors relating to inability to find groups. This is due to some groups not being pushed at the region level, in the case of the SrvAdmin and SrvRDU groups, no permissions # definitions. These can be ignored provided you don’t see more than one or two.

<#
 For Group Policies (Not automated via tool set):
 Note: Only required for new Server containers, but must be done in all three Tiers
 Use GPMC to create and link a new GPO to the target OU, with applicable naming standard
 Target - OU=FRK,OU=USA,OU=NA,OU=SRV,OU=Tier-1,DC=me,DC=sonymusic,DC=com
 GPO Name – T1_SRV_NA_USA_FRK_Server
 Use the Delegation tab to add a new permission
 Group – T1_GBL_L_FullControl_GPO_Objects
 Permission – Edit settings,delete,modify security (full control)
 Edit policy, navigate to Computer Configuration\Policies\Windows Settings\Security Settings\Restricted Groups
 Add region, country, and site group definitions for each of the applicable SrvAdmin groups to Administrators
 Add region, country, and site group definitions for each of the applicable SrvRDU groups to Remote Desktop Users

 That’s all the steps for manual provisioning of a new site.
#>

#While I was at it, I also went ahead and completed the pieces for the SCCMDP deployment, which includes some corrections to what was deployed for testing. I used PowerShell for what I could as follows:

# OU Creation
Set-Location "AD:\dc=me,dc=sonymusic,dc=com"
Set-Location OU=Tier-1
Get-ChildItem -recurse | Where-Object {$_.objectclass -like "organizationalunit" -and $_.name -like "Workstations"} |ForEach-Object {
    New-ADOrganizationalUnit -Name SCCMDP -path $_.distinguishedname
}

# Group Creation
$regions = @("AP","EU","LA","NA")
Foreach ($r in $regions){
    $path = "OU=$($r),OU=SrvAccess,OU=Groups,OU=GBL,OU=USA,OU=NA,OU=ADM,OU=Tier-1,DC=me,DC=sonymusic,DC=com";
    $gname = @("T1_STD_$($r)_SCCMDP_G_SrvAdmin", " T1_STD_$($r)_SCCMDP_G_SrvRDU");
    foreach ($g in $gname) {
        New-ADGroup -path $r -name $g -groupscope Global -groupcategory Security
    }
}

#A group policy already existed, so I renamed it to T1_STD_SCCMDP_Computer. I updated the policy to have the Restricted Groups settings using the above groups, but only at the region level, as local sites are not anticipated to require admin access at #this time based on my discussions with Mani. I removed the Policy Preferences setting assigning a Tier 2 group to the local admins group, as this is a Tier violation, but I went ahead and added the computer account USCULPWSCM01 (the only member of the #other group) to each of the regional groups created above. At some point, that server will need to be rebooted for the change to take effect. Finally, I used the below PowerShell to attach the GPO to all of the SCCMDP OUs:

Get-ChildItem -recurse | Where-Object{$_.objectclass -like "organizationalUnit" -and $_.name -like "SCCMDP"} | ForEach-Object {
    New-GPLink ((get-gpo -name "T1_STD_SCCMDP_Computer" -domain "me.sonymusic.com").id).guid -target $_.distinguishedname -linkenabled Yes -domain "me.sonymusic.com"
}