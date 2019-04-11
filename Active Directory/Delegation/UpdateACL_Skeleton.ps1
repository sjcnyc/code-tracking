######################################################################################################################
## Program      - updateACL_Skeleton.ps1
## Author       - Paul Bergson
## Date Written - November 12, 2013
## Description  - Skeleton of calls to ease the ability to delegate permissions to Active Directory OU's
##
##    Parameters needed
##      $group    = Group name to be assigned the new delegation
##      $LDAPPath = The OU path to have the new ACE applied


import-module activeDirectory
Clear-Host


         ### Extended rights and Associated GUIDS   ----->   SchemaIDGUID - Unique global ID value of the attribute
         ## http://technet.microsoft.com/en-us/library/ee331014(v=EXCHG.80).aspx   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
         ##

         ## SchemaIdGUID      ## http://msdn.microsoft.com/en-us/library/windows/desktop/ms680938(v=vs.85).aspx
         $guidNull                = new-object Guid 00000000-0000-0000-0000-000000000000
         $guidComputerObject      = new-object Guid bf967a86-0de6-11d0-a285-00aa003049e2  ## http://msdn.microsoft.com/en-us/library/windows/desktop/ms680987(v=vs.85).aspx
         $guidGroupObject         = new-object Guid bf967a9c-0de6-11d0-a285-00aa003049e2  ## http://msdn.microsoft.com/en-us/library/windows/desktop/ms682251(v=vs.85).aspx
         $guidOUObject            = new-object Guid bf967aa5-0de6-11d0-a285-00aa003049e2  ## http://msdn.microsoft.com/en-us/library/windows/desktop/ms682251(v=vs.85).aspx
         $guidSPNObject           = new-object Guid f3a64788-5306-11d1-a9c5-0000f80367c1  ## http://msdn.microsoft.com/en-us/library/windows/desktop/ms679785(v=vs.85).aspx
         $guidUserObject          = new-object Guid bf967aba-0de6-11d0-a285-00aa003049e2  ## http://msdn.microsoft.com/en-us/library/windows/desktop/ms683980(v=vs.85).aspx
         $guidPrinterObject       = new-object Guid bf967aa8-0de6-11d0-a285-00aa003049e2  ## Defined from script dump
         $guidGPOContainerObject  = new-object Guid f30e3bc2-9ff0-11d1-b603-0000f80367c1  ## Defined from script dump


         ## PropertySet GUID's
         $guidDomainLockOut       = new-object Guid C7407360-20BF-11D0-A768-00AA006E0529  ## http://msdn.microsoft.com/en-us/library/cc223204.aspx
         $guidGeneralInformation  = new-object Guid 59BA2F42-79A2-11D0-9020-00C04FC2D3CF  ## http://msdn.microsoft.com/en-us/library/cc223204.aspx
         $guidAccountRestrictions = new-object Guid 4C164200-20C0-11D0-A768-00AA006E0529  ## http://msdn.microsoft.com/en-us/library/cc223204.aspx
         $guidLogonInformation    = new-object Guid 5F202010-79A5-11D0-9020-00C04FC2D4CF  ## http://msdn.microsoft.com/en-us/library/cc223204.aspx
         $guidGroupMembership     = new-object Guid bc0ac240-79a9-11d0-9020-00c04fc2d4cf  ## http://msdn.microsoft.com/en-us/library/cc223204.aspx
         $guidPhoneMail           = new-object Guid E45795B2-9455-11D1-AEBD-0000F80367C1  ## http://msdn.microsoft.com/en-us/library/cc223204.aspx
         $guidPersonalInformation = new-object Guid 77B5B886-944A-11d1-AEBD-0000F80367C1  ## http://msdn.microsoft.com/en-us/library/cc223204.aspx
         $guidWebInformation      = new-object Guid E45795B3-9455-11D1-AEBD-0000F80367C1  ## http://msdn.microsoft.com/en-us/library/cc223204.aspx
         $guidPublicInformation   = new-object Guid e48d0154-bcf8-11d1-8702-00c04fb96050  ## http://msdn.microsoft.com/en-us/library/cc223204.aspx
         $guidRemoteAccess        = new-object Guid 037088F8-0AE1-11D2-B422-00A0C968F939  ## http://msdn.microsoft.com/en-us/library/cc223204.aspx
         $guidOtherDomain         = new-object Guid B8119FD0-04F6-4762-AB7A-4986C76B3F9A  ## http://msdn.microsoft.com/en-us/library/cc223204.aspx
         $guidDNSHostName         = new-object Guid 72E39547-7B18-11D1-ADEF-00C04FD8D5CD  ## http://msdn.microsoft.com/en-us/library/cc223204.aspx
         $guidTSGateWayAccess     = new-object Guid FFA6F046-CA4B-4FEB-B40D-04DFEE722543  ## http://msdn.microsoft.com/en-us/library/cc223204.aspx  ## Server 2008+
         $guidPrivateInformation  = new-object Guid 91E647DE-D96F-4B70-9557-D63FF4F3CCD8  ## http://msdn.microsoft.com/en-us/library/cc223204.aspx  ## Server 2008+
         $guidTSLicenseServer     = new-object Guid 5805BC62-BDC9-4428-A5E2-856A0F4C185E  ## http://msdn.microsoft.com/en-us/library/cc223204.aspx  ## Server 2008+
         $guidResetPassword       = new-object Guid 00299570-246d-11d0-a768-00aa006e0529  ## http://msdn.microsoft.com/en-us/library/windows/desktop/aa374928(v=vs.85).aspx
         $guidChangePassword      = new-object Guid ab721a53-1e2f-11d0-9819-00aa0040529b  ## http://msdn.microsoft.com/en-us/library/windows/desktop/aa374928(v=vs.85).aspx
         $guidPwdLastSet          = new-object Guid bf967a0a-0de6-11d0-a285-00aa003049e2  ## http://msdn.microsoft.com/en-us/library/cc220785
         $guidUserAccountControl  = new-object Guid bf967a68-0de6-11d0-a285-00aa003049e2  ## Defined from script dump

         ## Well known container GUIDs
##        $guid_USERS_CONTAINER               = new-object Guid a9d1ca15768811d1aded00c04fd8d5cd
##        $guid_COMPUTRS_CONTAINER            = new-object Guid aa312825768811d1aded00c04fd8d5cd
##        $guid_SYSTEMS_CONTAINER             = new-object Guid ab1d30f3768811d1aded00c04fd8d5cd
##        $guid_DOMAIN_CONTROLLERS_CONTAINER  = new-object Guid a361b2ffffd211d1aa4b00c04fd7d83a
##        $guid_INFRASTRUCTURE_CONTAINER      = new-object Guid 2fbac1870ade11d297c400c04fd8d5cd
##        $guid_DELETED_OBJECTS_CONTAINER     = new-object Guid 18e2ea80684f11d2b9aa00c04f79f805
##        $guid_LOSTANDFOUND_CONTAINER        = new-object Guid ab8153b7768811d1aded00c04fd8d5cd


##################################################
## Access Control Entry possible values         ##        >>>>>>>      Parm2      <<<<<<<<
##   These can be combined seperated by a comma ##
##################################################
##   CreateChild
##   DeleteChild
##   ListChildren
##   Self
##   ReadProperty
##   WriteProperty
##   DeleteTree
##   ListObject
##   ExtendedRight
##   Delete
##   ReadControl
##   GenericExecute
##   GenericWrite
##   GenericRead
##   WriteDacl
##   WriteOwner
##   GenericAll
##   Synchronize
##   AccessSystemSecurity
##
##
#########################################################
## On what objects should the ACL's be applied against ##        >>>>>>>      Parm5      <<<<<<<<
#########################################################
##   None
##   All
##   Descendents
##   SelfAndChildren
##   Children
##
##
## The documentation for this is not easy to discover and what I have uncovered in from other sites that have run into similar situations
## What I have discovered is if a specific permission can't be easily determined then I would go to the object I want to apply and grant/delegate the ACE
## Then I would run a Powershell script I have uploaded to Microsoft's script center that articulates all the ACE's and find the one I am interested in
## a complete list of ACE's is provided and find the one that needs to be scripted and all GUID and permissions should all be listed
## from this a new set of paramters can be created.  The indented <-- shown below highlight the values that can be obtained by dumping the ACE's
##
## My Powershell script to dump ACE's on an OU       http://gallery.technet.microsoft.com/scriptcenter/DUMP-ACLs-From-an-OU-8e2da85c
##
##############################################
## Example listing from the ACE Dump Script ##
##############################################
## ACL number -  8                                             <-- 8th ACE on the object dumped
## PBBERGS\SiteDelegatedAdmin                                  <-- domain\group name
## Access Control -  Allow                                     <-- permission granted
## Rights -  CreateChild, DeleteChild                          <-- rights granted
## Identity -  PBBERGS\trialGroup                              <-- security principal
## Inheritance Action -  None                                  <-- Inherit attribute
## Inhertiance Object Type -  None                             <-- inherit attribute
## Inheritance GUID -  00000000-0000-0000-0000-000000000000    <-- schemaIDGUID (Object schemaIDGUID - When property schemaIDGUID IS used, otherwise ALL zeroes)
## ACL Inheritance ? -  False                                  <-- inherit attribute
## Object Flags -  ObjectAceTypePresent                        <-- How ACE is defined  http://msdn.microsoft.com/en-us/library/vstudio/system.security.accesscontrol.objectaceflags(v=vs.100).aspx
## Object Type -  bf967a9c-0de6-11d0-a285-00aa003049e2         <-- SchemaIDGUID (Object schemaIDGUID- When property schemaIDGUID NOT used, otherwise property schemaIDGUID)
## Propogation Flags -  None                                   <-- Specifies how Access Control Entries (ACEs) are propagated to child objects. Significant only if inheritance flags are present.
##
##
######################################################
## Base settings for Object Class (Object tab)
###########################################################################################################################
## To manage the ACE's on System.DirectoryServices.ActiveDirectoryAccessRule
##       The ActiveDirectoryAccessRule class is used to represent an access control entry (ACE) in the Discretionary Access Control List (DACL) of AD Domain Services object
##
## OBJECT Specific
##  First thing to do is a new object needs to be defined for the new ACE for the Object, in the definitions below $ace or $acex (For multiple ace's) is used
##      Example $ace = new-object System.DirectoryServices.ActiveDirectoryAccessRule parm1, parm2, parm3, parm4, parm5
##
##          parm1 = SID of the specific security principal that will be granted the new ACE
##          parm2 = Quoted set of granted rights for the ACE, there can be more than one right granted the set must be comman seperated and quoted See above for list of settings
##          parm3 = Permission "Allow" or "Deny"
##          parm4 = Class schemaIdGUID - Many of the common used are defined above                              (Optional - It acts differently for objects types suggest always populate)
##          parm5 = How should this ACE be applied?  All objects, children, etc...  See above for options       (optional - If not defined then "This Object Only")
##
#############################################################################################################################
##
## Base setting for PROPERTY Specific attributes of the object (Property tab)
##      Example $ace = new-object System.DirectoryServices.ActiveDirectoryAccessRule parm1, parm2, parm3, parm4, parm5
##
##          parm1 = SID of the specific security principal that will be granted the new ACE
##          parm2 = Quoted set of granted rights for the ACE, there can be more than one right granted the set must be comman seperated and quoted See above for list of settings
##          parm3 = Permission "Allow" or "Deny"
##          parm4 = How should this ACE be applied?  All objects, children, etc...  See above for options
##          parm5 = Property schemaIDGUID
##
#############################################################################################################################


$erroractionpreference = "Stop"

$Group       = "trialGroup"         # Group Security Principal to be granted access.
$ldapPath    = ""                   ##       <---- If not defined ask at the console
If ($ldapPath -eq ""){$LDAPPath = read-Host "Please enter the OU path"}

$groupObject = Get-ADGroup $Group
$groupSID    = new-object System.Security.Principal.SecurityIdentifier $groupObject.SID


if ([adsi]::Exists("LDAP://" + $LDAPPath))
   {
         # Link to the OU Object
         $adObject    = [ADSI]("LDAP://" + $LDAPPath)

         ############################################
         ## Grant Full Control                     ##
         ## This object and all descendent objects ##
         ############################################
#         $ace = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"GenericAll","Allow",$guidNull,"ALL"
#         $adObject.ObjectSecurity.AddAccessRule($ace)
#         $adObject.CommitChanges()

         ############################################
         ## Grant Read and Write All properties    ##
         ## This object and all descendent objects ##
         ############################################
#         $ace = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"ReadProperty, WriteProperty","Allow",$guidNull,"ALL"
#         $adObject.ObjectSecurity.AddAccessRule($ace)
#         $adObject.CommitChanges()

         ############################################
         ## Grant List Contents                    ##
         ## This object                            ##
         ############################################
#         $ace = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"ListChildren","Allow"
#         $adObject.ObjectSecurity.AddAccessRule($ace)
#         $adObject.CommitChanges()

         #######################################################################
         ## Grant Extended Rights, includes Group Policy planning and logging ##
         ##  This object and all descendent objects                           ##
         #######################################################################
#         $ace = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"ExtendedRight","Allow",$guidNull,"ALL"
#         $adObject.ObjectSecurity.AddAccessRule($ace)
#         $adObject.CommitChanges()

         #############################################
         ## Create and Delete GPO objects           ##
         ## All descendent objects                  ##
         #############################################
         ## Grant creation of new GPO objects
#         $ace1  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"CreateChild,DeleteChild","Allow",$guidGPOContainerObject
         ## Grant the ability to manage all descendents
#         $ace2  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"GenericAll","Allow","Descendents",$guidGPOContainerObject
#         $adObject.ObjectSecurity.AddAccessRule($ace1)
#         $adObject.ObjectSecurity.AddAccessRule($ace2)
#         $adObject.CommitChanges()

         #############################################
         ## Grant Read Only                         ##
         ## This object and all descendent objects  ##
         #############################################
#         $ace = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"GenericRead","Allow",$guidNull,"ALL"
#         $adObject.ObjectSecurity.AddAccessRule($ace)
#         $adObject.CommitChanges()

         #############################################
         ## Create and Delete User objects          ##
         ## All descendent objects                  ##
         #############################################
         ## Grant creation of new user objects
#         $ace1  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"CreateChild,DeleteChild","Allow",$guidUserObject
         ## Grant the ability to manage all descendents
#         $ace2  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"GenericAll","Allow","Descendents",$guidUserObject
#         $adObject.ObjectSecurity.AddAccessRule($ace1)
#         $adObject.ObjectSecurity.AddAccessRule($ace2)
#         $adObject.CommitChanges()

         #############################################
         ## Create and Delete Printer objects       ##
         ## All descendent objects                  ##
         #############################################
         ## Grant creation of new Printer objects
#         $ace1  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"CreateChild,DeleteChild","Allow",$guidPrinterObject
         ## Grant the ability to manage all descendents
#         $ace2  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"GenericAll","Allow","Descendents",$guidPrinterObject
#         $adObject.ObjectSecurity.AddAccessRule($ace1)
#         $adObject.ObjectSecurity.AddAccessRule($ace2)
#         $adObject.CommitChanges()

         #############################################
         ## Create and Delete Computer objects      ##
         ## All descendent objects                  ##
         #############################################
         ## Grant creation of new computer objects
#         $ace1  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"CreateChild,DeleteChild","Allow",$guidComputerObject
         ## Grant the ability to manage all descendents
#         $ace2  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"GenericAll","Allow","Descendents",$guidComputerObject
#         $adObject.ObjectSecurity.AddAccessRule($ace1)
#         $adObject.ObjectSecurity.AddAccessRule($ace2)
#         $adObject.CommitChanges()

         #############################################
         ## Create Computer objects only            ##
         ##                                         ##
         #############################################
         ## Grant creation of new computer objects
#         $ace1  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"CreateChild","Allow",$guidComputerObject,"SELFANDCHILDREN"
#            Allow read and write of account restrictions
#         $ace2  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"ReadProperty,WriteProperty","Allow",$guidAccountRestrictions,"Descendents",$guidComputerObject
#            Allow validate right to service principal name
#         $ace3  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"Self","Allow",$guidSPNObject,"Descendents",$guidComputerObject
#            Allow validate right to host DNS name
#         $ace4  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"Self","Allow",$guidDNSHostName,"Descendents",$guidComputerObject
#            Allow reset password on descendents
#         $ace5  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"ExtendedRight","Allow",$guidResetPassword,"Descendents",$guidComputerObject
#         $adObject.ObjectSecurity.AddAccessRule($ace1)
#         $adObject.ObjectSecurity.AddAccessRule($ace2)
#         $adObject.ObjectSecurity.AddAccessRule($ace3)
#         $adObject.ObjectSecurity.AddAccessRule($ace4)
#         $adObject.ObjectSecurity.AddAccessRule($ace5)
#         $adObject.CommitChanges()

         #############################################
         ## Create and Delete OU objects            ##
         ## All descendent objects                  ##
         #############################################
         ## Grant creation of new OU objects
#         $ace1  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"CreateChild,DeleteChild","Allow",$guidOUObject
         ## Grant the ability to manage all descendents
#         $ace2  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"GenericAll","Allow","Descendents",$guidOUObject
#         $adObject.ObjectSecurity.AddAccessRule($ace1)
#         $adObject.ObjectSecurity.AddAccessRule($ace2)
#         $adObject.CommitChanges()

         #############################################
         ## Create and Delete Group objects         ##
         ## All descendent objects                  ##
         #############################################
         ## Grant creation of new group objects
#         $ace1  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"CreateChild,DeleteChild","Allow",$guidGroupObject
         ## Grant the ability to manage all descendents
#         $ace2  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"GenericAll","Allow","Descendents",$guidGroupObject
#         $adObject.ObjectSecurity.AddAccessRule($ace1)
#         $adObject.ObjectSecurity.AddAccessRule($ace2)
#         $adObject.CommitChanges()

         #############################################
         ## Manage Group Membership                 ##
         ## All descendent objects                  ##
         #############################################
         ## Grant creation of new user objects
         ## Grant the ability to manage all descendents
#         $ace1  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"GenericAll","Allow","Descendents",$guidGroupObject
#         $adObject.ObjectSecurity.AddAccessRule($ace1)
#         $adObject.CommitChanges()

         ########################################################################################
         ## Grant the extended right to to reset user passwords and force change at next logon ##
         ## All descendent objects                                                             ##
         ########################################################################################
         ## Grant the ability to manage SPN's on all descendent users
#         $ace1 = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"ExtendedRight","Allow",$guidResetPassword,"Descendents",$guidUserObject
         ## Grant the ability to force change password on next logon on all descendent users
#         $ace2 = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"ReadProperty,WriteProperty","Allow",$guidPwdLastSet,"Descendents",$guidUserObject
#         $adObject.ObjectSecurity.AddAccessRule($ace1)
#         $adObject.ObjectSecurity.AddAccessRule($ace2)
#         $adObject.CommitChanges()

         #############################################
         ## Delegate Create and User management     ## (Delete Not Allowed!)
         ## All descendent objects                  ##
         #############################################
         ## Grant creation of new user objects
#         $ace1  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"CreateChild","Allow",$guidUserObject,"ALL"
         ## Allow management of the users password
#         $ace2  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"ExtendedRight","Allow",$guidResetPassword,"Descendents",$guidUserObject
         ## Allow management of the users userAccountControl
#         $ace3  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"ReadProperty, WriteProperty","Allow",$guidUserAccountControl,"Descendents",$guidUserObject
         ## Allow management of the users passwordlast set
#         $ace4  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"ReadProperty, WriteProperty","Allow",$guidPwdLastSet,"Descendents",$guidUserObject
#         $adObject.ObjectSecurity.AddAccessRule($ace1)
#         $adObject.ObjectSecurity.AddAccessRule($ace2)
#         $adObject.ObjectSecurity.AddAccessRule($ace3)
#         $adObject.ObjectSecurity.AddAccessRule($ace4)
#         $adObject.CommitChanges()

         ################################################################
         ## Grant users the  right to manage SPN's on service accounts ##
         ## All descendent objects                                     ##
         ################################################################
         ## Grant the ability to manage SPN's on all descendent users
#         $ace  = new-object System.DirectoryServices.ActiveDirectoryAccessRule $groupSID,"ReadProperty,WriteProperty","Allow",$guidSPNObject,"Descendents",$guidUserObject
#         $adObject.ObjectSecurity.AddAccessRule($ace)
#         $adObject.CommitChanges()

   }
Else
   {
    Write-Host "$ldapPath <------ Doesn't exist"
    }