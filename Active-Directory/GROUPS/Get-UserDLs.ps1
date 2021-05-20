function Get-UserDLs {
    param(
        [string]$username
    )

        Get-ADPrincipalGroupMembership -Identity $username -Server mnet.biz | Select-Object Name | Where-Object {$_.name -like '*GDL*'}

}