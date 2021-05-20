Function Get-LHSGpLink 
{
<# 
.SYNOPSIS 
    List Group Policy Link Objects for named GPO or for a given OU/Domain DistinguishedName

.DESCRIPTION
    List Group Policy Link Objects for named GPO or for a given OU/Domain DistinguishedName

    We can use the output and pipe it to the Microsoft GroupPolicy cmdlets
    Set-GPLink, Remove-GPLink

    Requires Microsoft Modules ActiveDirectory,GroupPolicy

.PARAMETER GpoName
    GPO DisplayName you want to list linked ADObjects.
    You cannot use -GpoName in combination with Parameter -Target

.PARAMETER Target
    The ADObject DistinguishedName like "OU=Users,DC=contoso,DC=com" you
    want to list GPOs linked to it.
    You cannot use -Target in combination with Parameter -GPOName

.EXAMPLE
    PS C:\> Get-LHSGpLink -GpoName GP_Audit

    GpoId       : 807cef71-5ef5-4db6-a7ac-61eb90339e5d
    DisplayName : GP_Audit
    Enabled     : False
    Enforced    : True
    Target      : OU=FI,OU=Users,DC=contoso,DC=com
    Order       : 3

    GpoId       : 807cef71-5ef5-4db6-a7ac-61eb90339e5d
    DisplayName : GP_Audit
    Enabled     : False
    Enforced    : True
    Target      : OU=MK,OU=Users,DC=contoso,DC=com
    Order       : 8
    (..)

    Returns Group Policy Link Objects for GPO named GP_Audit

.EXAMPLE
    PS C:\> Get-LHSGpLink -Target "OU=Servers,DC=contoso,DC=com" 

    GpoId       : a1aa4a37-d3c1-46e0-8965-787fc6c8034d
    DisplayName : GPO_W_IE11
    Enabled     : True
    Enforced    : True
    Target      : OU=Servers,DC=contoso,DC=com
    Order       : 8

    GpoId       : 807cef71-5ef5-4db6-a7ac-61eb90339e5d
    DisplayName : GPO_U_IE11
    Enabled     : False
    Enforced    : True
    Target      : OU=Servers,DC=contoso,DC=com
    Order       : 9
    (..)

    To list all Group Policy Link Objects for the given OU

.EXAMPLE
    To disable all Group Policy Link Objects linked to a given OU

    Get-LHSGpLink -Target "OU=Servers,DC=contoso,DC=com" | Set-GPLink -LinkEnabled No

    GpoId       : a1aa4a37-d3c1-46e0-8965-787fc6c8034d
    DisplayName : GPO_W_IE11
    Enabled     : False
    Enforced    : True
    Target      : OU=Servers,DC=contoso,DC=com
    Order       : 8

    GpoId       : 807cef71-5ef5-4db6-a7ac-61eb90339e5d
    DisplayName : GPO_U_IE11
    Enabled     : False
    Enforced    : True
    Target      : OU=Servers,DC=contoso,DC=com
    Order       : 9
    (..)

.EXAMPLE
    To disable all Group Policy Link Objects for GPO named GPO7_Test

    Get-LHSGpLink -GpoName GPO7_Test | Set-GPLink -LinkEnabled No

    GpoId       : a91487d6-bf76-49ef-8118-6351de12879c
    DisplayName : GPO7_TEST
    Enabled     : False
    Enforced    : False
    Target      : OU=Servers,DC=contoso,DC=com
    Order       : 6

    GpoId       : a91487d6-bf76-49ef-8118-6351de12879c
    DisplayName : GPO7_TEST
    Enabled     : False
    Enforced    : False
    Target      : OU=Computers,DC=contoso,DC=com
    Order       : 2

.EXAMPLE
    Get-ADOrganizationalUnit -Filter * | ForEach-Object {Get-LHSGpLink -Target $_.DistinguishedName}

    To return Group Policy Link Objects from all OUs in the current domain.

.EXAMPLE
    # To Backup all Group Policy Link Objects for all GPOs in the current Domain
    $Path = 'c:\Backup\All_GPLinks.CSV'
    Get-GPO -All | ForEach-Object {Get-LHSGpLink -GpoName $_.DisplayName} | 
    Export-Csv -Path $Path -NoTypeInformation -UseCulture 

    You can modify the CSV file and remove all GpLink Objects except the ones you want to restore.


    # To Restore all Group Policy Link Objects listed in the CSV file
    Import-Csv -Path $Path | ForEach-Object {
        New-GPLink -Name $_.DisplayName -Target $_.Target -Order $_.Order -Enforced $_.Enforced -LinkEnabled $_.LinkEnabled
    }


.INPUTS
    None

.OUTPUTS
    TypeName: Microsoft.GroupPolicy.GpoLink

.Notes
    Microsoft´s GroupPolicy Module in PS V2 has many cmdlets for working with GPOs.
    But where is the Get-GPLink? It does not exist. 
    Well at least it is not included as one of Microsoft’s cmdlets. 
    This was a reason for creating an advanced Function.

    ToDO:
    adding Parameter for Domain and Credential, currently it works only for current Domain.
    adding the ability to get Group Policy Link Objects linked to sites. 

    NAME: Get-LHSGpLink.ps1 
    AUTHOR: Pasquale Lantella
    LASTEDIT: 30.09.2015
    KEYWORDS: Get-GPLink, gplink

.Link 
    Get-GPInheritance 

#Requires -Version 2.0 
#> 

[cmdletbinding(DefaultParameterSetName = 'GPO')]  

[OutputType('Microsoft.GroupPolicy.GpoLink')]

Param(

    [Parameter(ParameterSetName='GPO',Position=0,Mandatory=$True,ValueFromPipeline=$False)]
 [string]$GpoName,

    [Parameter(ParameterSetName='Target',Position=0,Mandatory=$True,ValueFromPipeline=$False)]
 [string]$Target

   )

BEGIN {
 ${CmdletName} = $Pscmdlet.MyInvocation.MyCommand.Name

  
    Try {
        IF ((Get-Module GroupPolicy) -eq $Null) {Import-Module GroupPolicy}
        IF ((Get-Module ActiveDirectory) -eq $Null) {Import-Module ActiveDirectory}
    }
    Catch {
        Write-Warning "Must have the Active Directory and Group Policy cmdlets installed."
        Write-Warning "Cannot load Modules, RSAT installed?"
        Break
    }

    $domobj = Get-ADDomain
    $dom = $domobj.dnsroot
    $domdn = $domobj.distinguishedname
} # end BEGIN

PROCESS {
    IF ($PSCmdlet.ParameterSetName -eq "GPO") 
    {
        Write-Verbose "The GPO:$GpoName is linked to the following ADObjects"
        Try 
        {
            $myGPO = Get-GPO -Name $GpoName -ErrorAction Stop
            $myGPOID = "*" + $myGPO.Id + "*"

            Write-Debug "`$myGPOID contains $myGPOID"
            $Filter = {((objectCategory -eq "organizationalunit") -or (distinguishedname -eq $domdn)) -and (gplink -like $myGPOID)}
            $ADObjects = Get-ADObject –Filter $Filter -searchbase $domdn -searchscope subtree -ErrorAction Stop -property gplink,distinguishedname,gpoptions

            $Filter = {((objectCategory -eq "organizationalunit") -or (distinguishedname -eq $domdn)) -and (gplink -like $myGPOID)}
            $ADObjects = Get-ADObject –Filter $Filter -searchbase $domdn -searchscope subtree -ErrorAction Stop -property gplink,distinguishedname,gpoptions

            $OutputObject = @()
            Foreach ($object in $ADObjects) 
            {
                $GPLink = (Get-GPInheritance -Target $object.DistinguishedName -ErrorAction stop).gpolinks | 
                    Where-Object {$_.DisplayName -like $GpoName} | Sort-Object DisplayName
                $OutputObject += $GPLink
            } 

            Write-Output $OutputObject
        } 
        Catch 
        {
            Write-Error "$_"
        }                 

    } # end ($PSCmdlet.ParameterSetName -eq "GPO")

    IF ($PSCmdlet.ParameterSetName -eq "Target") 
    {
        Write-Verbose "list all linked GPO to a given OU or Domain"

        Try 
        {
            $GPOLinks = (Get-GPInheritance -Target $Target -ErrorAction stop).gpolinks 
            Write-Output $GPOLinks    
        } 
        Catch 
        {
            Write-Error "$_"
        }
    } # end IF ($PSCmdlet.ParameterSetName -eq "Set2")       

} # end PROCESS

END { Write-Verbose "Function Get-LHSGpLink finished." }    

} # end Function Get-LHSGpLink 
