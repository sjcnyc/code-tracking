﻿################################################################################################
# ADACLScan.ps1
# 
# AUTHOR: Robin Granberg (robin.granberg@microsoft.com)
#
# THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 
# FITNESS FOR A PARTICULAR PURPOSE.
#
# This sample is not supported under any Microsoft standard support program or service. 
# The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
# implied warranties including, without limitation, any implied warranties of merchantability
# or of fitness for a particular purpose. The entire risk arising out of the use or performance
# of the sample and documentation remains with you. In no event shall Microsoft, its authors,
# or anyone else involved in the creation, production, or delivery of the script be liable for 
# any damages whatsoever (including, without limitation, damages for loss of business profits, 
# business interruption, loss of business information, or other pecuniary loss) arising out of 
# the use of or inability to use the sample or documentation, even if Microsoft has been advised 
# of the possibility of such damages.
################################################################################################
<#-------------------------------------------------------------------------------
!! Version 4.5.0
19 June, 2016

*SHA256:* 

*New Features*
** Added Exchange Schema Version check for Exchange Server 2016 CU1.*(Credit to Kirill Nikolaev, Kaspersky Lab)*

*Fixed issues*
** Heavily improved code for “Skip Default Permissions”. Removed possible memory problem while scanning many objects.
** Improved code for “Skip Protected Permissions”. One ACE was missing.
** Null-valued array error while composing the list of domains. *(Credit to Kirill Nikolaev, Kaspersky Lab)*
** Null-valued array error when closing domain picker window w/o actually selecting one. *(Credit to Kirill Nikolaev, Kaspersky Lab)*
** Updated LDAP filters for getting trusted domains.*(Credit to Kirill Nikolaev, Kaspersky Lab)*
** Fixed issues with use of credentials over trusts.
** Fixed issues with TokenGroups over trust lookup.
** Removed unused variables.
** Replaced aliases like %,?,Select, foreach and Sort.
** Put $null to the left in comparison strings.

----
!! Version 4.4.0
16 June, 2016

*SHA256:* 2803906C909BB7DE7024FEE981BCE6D927A0826215051AEDD088D61C10F9AB97

*Fixed issues*
** Errors when scanning objects you don't have read access on.
** Comparing with template containing forest root failed when connected to child domain.
** Templates are updated with a more accurate DN.
** Errors when translating NT Identity fixed.

----
!! Version 4.3.0
2 May, 2016

*SHA256:* 3473DDB452DE7640FAB03CAD3E8AAF6A527BDD6A7A311909CFEF9DE0B4B78333

*New Features*
** You can exclude multiple paths, just for each object, select and right click to choose Exclude.

*Fixed issues*
** Unresolved security principals was shown as empty instead of SID.
** Searching for SID's included built-in groups that did not translate before compare.

----
!! Version 4.2.0
14 April, 2016

*SHA256:* F340F6B56F11F879ED8A4C0DDA751FFF9538EE5105B2C0F39C79BED218E985E2:* 

*Fixed issues*
** The validated write was express as only "Self" in the report.
** The validated write was never enumerated from the list of ControlAccessRights.

----
!! Version 4.1.0
12 April, 2016

*SHA256:* BE7ECB91AA0F819A1796739B0491CA4691DCBE718410CA8A7F9358B600754B2A

*Fixed issues*
** Comparing builtin groups differ from running on DC and domain member.
** Connecting to custom DC did not collected forest info.

----
!! Version 4.0.0
11 April, 2016

*SHA256:* C72CD69C0E15C1A9A276485FD5073F958B26B1A777928740C67B7E347F38938B

*New Features*
** Faster compare of Access Control Lists using USN from replication metadata.
** Primary directory service API changed to System.DirectoryServices.Protocols (S.DS.P).
** Connect to custom directory server and port like mounted backup or snapshot of NTDS.dit.
** Support for scanning AD LDS Instances.
** Name translation of AD LDS Identity references in security descriptor.
** Option to connect using credentials.
** Export defaultSecurityDescriptor.
** Compare DefaultSecurityDescriptor.
** Download OS specific csv templates for DefaultSecuritydescriptor.
** Connection Information tab provides information about the current connection.
** Resizable Window

*Fixed issues*
** Change the column name in the header from "OU" to "Object".
** Display forest information like FFL,DFL,Schema Version, Exchange and Lync Schema version did not work due to wrong formatting of attributes.
** Solved problem with returning schema version information about Exchange and Lync.
** Minor improvements in the GUI. 

----
!! Version 3.2.0
7 September, 2015

*SHA1:* 61CB4D160B4003FDF51FFACDB777FF0DC28D83D1

*New Features*
** Report single or all classSchema objects default security descriptor.
** Option to select between DACL or SDDL output of default security descriptors.
** Displays forest information like FFL,DFL,Schema Version, Exchange and Lync Schema version.
----
!! Version 3.1.0
2 September, 2015

*SHA1:* EBBB7083BE00108B14B661016A0D049EFF092971

*New Features*
** Option to show objectClass of objects reported
** Option skip ACE's for "Protect object from accidental deletion"
** Error control on .Net Framework CLRVersion
----
!! Version 3.0.1
10 July, 2015


*Fixed issues*
** Reporting on modified default security descriptors in Schema did not work in Windows 10 or Windows Server Technical Preview 2.
----
!! Version 3.0
9 July, 2015

*New Features*
** You can take a CSV file from one domain and use it for another. With replacing the old DN with the current domains you can resuse reports between domains. You can also replace the (Short domain name)Netbios name security principals.
** Reporting on modified default security descriptors in Schema.
** Verifying the format of the CSV files used in convert and compare functions.
** When comparing with CSV file Nodes missing in AD will be reported as "Node does not exist in AD"
** The progress bar can be disabled to gain speed in creating reports.
** If the fist node in the CSV file used for comparing can't be connected the scan will stop.

*Fixed issues*
** Only the first node in the CSV file was used in the comparison the rest was skipped.
** If a node in the CSV file did not exist in AD, the comparison failed.  
----
!! Version 2.2.2
7 July, 2015

*Fixed issues*
** If you run AD ACL Scanner in Windows 10 or Windows Server Technical Preview 2 you would always get mismatch during comparing. Problem fixed with if statement on System.Enum in PowerShell 5. 
----
!! Version 2.2.1
6 July, 2015

*New Features*
** Number of excluded objects reported in Log.

*Fixed issues*
** Broken scan! Everything are excluded when searching Onelevel or Subtree.
----
!! Version 2.2.0
4 July, 2015

*New Features*
** Refresh Nodes by right-click container object. 
** Exclude of objects from report by matching string to distinguishedName
----
!! Version 2.1.2
2 July, 2015

*Fixed issues*
** Every scan required SeSecurityPrivilege (Manage auditing and security log) due to modifications of the SecurityMasks. Now this is done only once you explicitly scan SACL's. 
----
!! Version 2.1.1
12 June, 2015

*Fixed issues*
** If you ran AD ACL Scanner in Windows 10 or Windows Server Technical Preview 2 you would get an error. Problem fixed with if statement on System.Enum in PowerShell 5. 
----
!! Version 2.1.0
21 May, 2015

*New Features*
** Changed format on CSV output file. New format according to regular CSV type.
** Removed dependency on Active Directory PowerShell module for reporting on SACL's.
** Rename html report headers, Rights are called Access and if SACL's is used it's called Audit.
** HTLM reports contain headers
** Summary of criticality for all report types
** Support statement included

*Fixed issues*
** Owner permissions are changed to the more accurate :Read permissions, Modify permissions.
** Error when running PS 2.0 "ProgressBarWindow".
** Correct name of SPN report file.
** Criticality coloring of "Info"-level fixed.
** Added error control for enumerating objects.
----
!! Version 2.0.3
29 October, 2014

*Fixed issues*
** PS 2.0 "Where-Object : Cannot bind argument to 'FilterScript' because it is null":5369.
----
!! Version 2.0.2
28 October, 2014

*New Features*
** Scan for SACL's
** Option to skip Splash through new parameter "NoSplash"
** Option to show help text through new parameter "Help"
** Translation of object GUID in CSV file.

*Fixed issues*
** Require connection to domain before converting CSV to  HTML, otherwise object GUID translation will fail.
----
!! Version 2.0.1
15 October, 2014

*Fixed issues*
** issues related to connecting to ForestDnsZones and DomainDnsZones
----
!! Version 2.0
October, 2014

*New Features*
** New GUI
** Progress Bar
** Better browsing experience
** Better logging function
** Bug fixes
-------------------------------------------------------------------------------#> 
#Requires -Version 2.0
param(
[switch]$NoSplash,
[switch]$help)
$strScriptName = $($MyInvocation.MyCommand.Name)

if([threading.thread]::CurrentThread.ApartmentState.ToString() -eq 'MTA')               
{               
  write-host -ForegroundColor RED "RUN PowerShell.exe with -STA switch"              
  write-host -ForegroundColor RED "Example:"              
  write-host -ForegroundColor RED "    PowerShell -STA $PSCommandPath"    

  Write-Host "Press any key to continue ..."
  [VOID]$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
  
  Exit
}

function funHelp
{
Clear-Host
$helpText=@"
THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 
FITNESS FOR A PARTICULAR PURPOSE.

This sample is not supported under any Microsoft standard support program or service. 
The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
implied warranties including, without limitation, any implied warranties of merchantability
or of fitness for a particular purpose. The entire risk arising out of the use or performance
of the sample and documentation remains with you. In no event shall Microsoft, its authors,
or anyone else involved in the creation, production, or delivery of the script be liable for 
any damages whatsoever (including, without limitation, damages for loss of business profits, 
business interruption, loss of business information, or other pecuniary loss) arising out of 
the use of or inability to use the sample or documentation, even if Microsoft has been advised 

DESCRIPTION:
NAME: $strScriptName


SYSTEM REQUIREMENTS:

- Windows Powershell 2.0

- Connection to an Active Directory Domain



PARAMETERS:

-NoSplash        Skip start flash window.
-help            Prints the HelpFile (Optional)



SYNTAX:
 -------------------------- EXAMPLE 1 --------------------------
 

.\$strScriptName -NoSplash


 Description
 -----------
 Run the script without Splash window.


 -------------------------- EXAMPLE 2 --------------------------
 
.\$strScriptName -help

 Description
 -----------
 Displays the help topic for the script

 

"@
write-host $helpText
exit
}
if ($help){funHelp}
$global:ForestFLHashAD = @{
	0="Windows 2000 Server";
	1="Windows Server 2003/Interim";
	2="Windows Server 2003";
	3="Windows Server 2008";
	4="Windows Server 2008 R2";
	5="Windows Server 2012";
	6="Windows Server 2012 R2";
	7="Windows Server 2016"
}
$global:DomainFLHashAD = @{
	0="Windows 2000 Server";
	1="Windows Server 2003/Interim";
	2="Windows Server 2003";
	3="Windows Server 2008";
	4="Windows Server 2008 R2";
	5="Windows Server 2012";
	6="Windows Server 2012 R2";
	7="Windows Server 2016"
}
$global:SchemaHashAD = @{
	13="Windows 2000 Server";
	30="Windows Server 2003";
	31="Windows Server 2003 R2";
	44="Windows Server 2008";
	47="Windows Server 2008 R2";
	56="Windows Server 2012";
	69="Windows Server 2012 R2";
	72="Windows Server 2016 Technical Preview";
    81="Windows Server 2016 Technical Preview 2";
    82="Windows Server 2016 Technical Preview 3";
    85="Windows Server 2016 Technical Preview 4"
}
	
# List of Exchange Schema versions
$global:SchemaHashExchange = @{
	4397="Exchange Server 2000";
	4406="Exchange Server 2000 SP3";
	6870="Exchange Server 2003";
	6936="Exchange Server 2003 SP3";
	10628="Exchange Server 2007";
	10637="Exchange Server 2007";
	11116="Exchange Server 2007 SP1";
	14622="Exchange Server 2007 SP2 or Exchange Server 2010";
	14726="Exchange Server 2010 SP1";
	14732="Exchange Server 2010 SP2";
	14734="Exchange Server 2010 SP3";
	15137="Exchange Server 2013 RTM";
	15254="Exchange Server 2013 CU1";
	15281="Exchange Server 2013 CU2";
	15283="Exchange Server 2013 CU3";
	15292="Exchange Server 2013 SP1/CU4";
	15300="Exchange Server 2013 CU5";
	15303="Exchange Server 2013 CU6";
	15312="Exchange Server 2013 CU7";
    15317="Exchange Server 2016";
    15323="Exchange Server 2016 CU1";
}
	
# List of Lync Schema versions
$global:SchemaHashLync = @{
	1006="LCS 2005";
	1007="OCS 2007 R1";
	1008="OCS 2007 R2";
	1100="Lync Server 2010";
	1150="Lync Server 2013"
}
Function BuildSchemaDic
{

$global:dicSchemaIDGUIDs = @{"BF967ABA-0DE6-11D0-A285-00AA003049E2" ="user";`
"BF967A86-0DE6-11D0-A285-00AA003049E2" = "computer";`
"BF967A9C-0DE6-11D0-A285-00AA003049E2" = "group";`
"BF967ABB-0DE6-11D0-A285-00AA003049E2" = "volume";`
"F30E3BBE-9FF0-11D1-B603-0000F80367C1" = "gPLink";`
"F30E3BBF-9FF0-11D1-B603-0000F80367C1" = "gPOptions";`
"BF967AA8-0DE6-11D0-A285-00AA003049E2" = "printQueue";`
"4828CC14-1437-45BC-9B07-AD6F015E5F28" = "inetOrgPerson";`
"5CB41ED0-0E4C-11D0-A286-00AA003049E2" = "contact";`
"BF967AA5-0DE6-11D0-A285-00AA003049E2" = "organizationalUnit";`
"BF967A0A-0DE6-11D0-A285-00AA003049E2" = "pwdLastSet"}


$global:dicNameToSchemaIDGUIDs = @{"user"="BF967ABA-0DE6-11D0-A285-00AA003049E2";`
"computer" = "BF967A86-0DE6-11D0-A285-00AA003049E2";`
"group" = "BF967A9C-0DE6-11D0-A285-00AA003049E2";`
"volume" = "BF967ABB-0DE6-11D0-A285-00AA003049E2";`
"gPLink" = "F30E3BBE-9FF0-11D1-B603-0000F80367C1";`
"gPOptions" = "F30E3BBF-9FF0-11D1-B603-0000F80367C1";`
"printQueue" = "BF967AA8-0DE6-11D0-A285-00AA003049E2";`
"inetOrgPerson" = "4828CC14-1437-45BC-9B07-AD6F015E5F28";`
"contact" = "5CB41ED0-0E4C-11D0-A286-00AA003049E2";`
"organizationalUnit" = "BF967AA5-0DE6-11D0-A285-00AA003049E2";`
"pwdLastSet" = "BF967A0A-0DE6-11D0-A285-00AA003049E2"}
}

BuildSchemaDic

Add-Type -Assembly PresentationFramework

$global:syncHashSplash = [hashtable]::Synchronized(@{})
$newRunspaceSplash =[runspacefactory]::CreateRunspace()
$newRunspaceSplash.ApartmentState = "STA"
$newRunspaceSplash.ThreadOptions = "ReuseThread"          
$newRunspaceSplash.Open()
$newRunspaceSplash.SessionStateProxy.SetVariable("global:syncHashSplash",$global:syncHashSplash)          
$psCmdSplash = [PowerShell]::Create().AddScript({   
    
[xml]$xamlSplash = 
@"
<Window xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:system="clr-namespace:System;assembly=mscorlib"
        WindowStyle='None' AllowsTransparency='True'
   
        Topmost='True' Background="Transparent"  ShowInTaskbar='False'
         WindowStartupLocation='CenterScreen' >
    <Window.Resources>
        <system:String x:Key="Time">AD ACL &#10;Scanner</system:String>

    </Window.Resources>


    <Grid Height="200" Width="400" Background="White">
        <Border BorderBrush="Black" BorderThickness="1">
        <StackPanel VerticalAlignment="Center">

            <Label x:Name="lbl1"  Content="Active Directory&#10;AD ACL Scanner" FontWeight="Normal" Width="250" Height="110" FontSize="32"  HorizontalAlignment="Center" HorizontalContentAlignment="Center" VerticalContentAlignment="Bottom">
                <Label.Foreground>
                    <LinearGradientBrush>
                        <GradientStop Color="#CC1281DB"/>
                        <GradientStop Color="#FF6797BF" Offset="0.3"/>
                        <GradientStop Color="#FF6797BF" Offset="0.925"/>
                        <GradientStop Color="#FFD4DBE1" Offset="1"/>
                    </LinearGradientBrush>
                </Label.Foreground>
            </Label>
            <Label x:Name="lbl2" Content="THIS CODE-SAMPLE IS PROVIDED WITHOUT WARRANTY OF ANY KIND" Width="500" Height="80" FontSize="10" HorizontalAlignment="Center" HorizontalContentAlignment="Center" VerticalContentAlignment="Bottom">

            </Label>
        </StackPanel>
        </Border>
    </Grid>
</Window>
"@
 
    $reader=(New-Object System.Xml.XmlNodeReader $xamlSplash)
    $xamlSplash = $null
    Remove-Variable -Name xamlSplash
    $global:syncHashSplash.Window=[Windows.Markup.XamlReader]::Load( $reader )
    $global:syncHashSplash.Window.Show() | Out-Null
    $global:syncHashSplash.Error = $Error
    Start-Sleep -Seconds 2
    $global:syncHashSplash.Window.Dispatcher.Invoke([action]{$global:syncHashSplash.Window.Hide()},"Normal")
    
    $syncHashSplash = $null
    Remove-Variable -Name "syncHashSplash" -Scope Global
    $reader = $null
    Remove-Variable -Name "reader" -Scope Global
    $newRunspaceSplash = $null
    Remove-Variable -Name "newRunspaceSplash" -Scope Global
    $ADACLGui.Window.Activate()
})


if (($PSVersionTable.PSVersion -ne "2.0") -and (!$NoSplash))
{
    $psCmdSplash.Runspace = $newRunspaceSplash
    $syncHashSplash = $null
    Remove-Variable -Name "syncHashSplash" -Scope Global
    [void]$psCmdSplash.BeginInvoke()
   

}


$ADACLGui = [hashtable]::Synchronized(@{})

$global:myPID = $PID
$CurrentFSPath = split-path -parent $MyInvocation.MyCommand.Path
$strLastCacheGuidsDom = ""
$sd = ""


[xml]$xamlForm1 = @"
<Window x:Class="ADACLScanXAMLProj.MainWindow"

        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="AD ACL Scanner"  WindowStartupLocation="CenterScreen" SizeToContent="WidthAndHeight" ResizeMode="CanResizeWithGrip" WindowState="Normal" >
    <Window.Background>
        <LinearGradientBrush>
            <LinearGradientBrush.Transform>
                <ScaleTransform x:Name="Scaler" ScaleX="1" ScaleY="1"/>
            </LinearGradientBrush.Transform>
            <GradientStop Color="#CC064A82" Offset="1"/>
            <GradientStop Color="#FF6797BF" Offset="0.7"/>
            <GradientStop Color="#FF6797BF" Offset="0.3"/>
            <GradientStop Color="#FFD4DBE1" Offset="0"/>
        </LinearGradientBrush>
    </Window.Background>
    <Window.Resources>
        <XmlDataProvider x:Name="xmlprov" x:Key="DomainOUData"/>
        <DrawingImage x:Name="FolderImage" x:Key="FolderImage"  >
            <DrawingImage.Drawing>
                <DrawingGroup>
                    <GeometryDrawing Brush="#FF3D85F5">
                        <GeometryDrawing.Geometry>
                            <RectangleGeometry Rect="3,6,32,22" RadiusX="0" RadiusY="0" />
                        </GeometryDrawing.Geometry>
                    </GeometryDrawing>
                    <GeometryDrawing Brush="#FF3D81F5">
                        <GeometryDrawing.Geometry>
                            <RectangleGeometry Rect="18,3,13,5" RadiusX="2" RadiusY="2" />
                        </GeometryDrawing.Geometry>
                    </GeometryDrawing>
                </DrawingGroup>
            </DrawingImage.Drawing>
        </DrawingImage>
        <HierarchicalDataTemplate x:Key="NodeTemplate" ItemsSource="{Binding XPath=OU}">
            <StackPanel Orientation="Horizontal">
                <Image Width="16" Height="16" Stretch="Fill" Source="{Binding XPath=@Img}"/>
                <TextBlock Text="{Binding XPath=@Name}" Margin="2,0,0,0" />
            </StackPanel>
        </HierarchicalDataTemplate>
    </Window.Resources>
    <ScrollViewer HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Auto">
        <Grid HorizontalAlignment="Left" VerticalAlignment="Top" Height="850" Width="990">
        <StackPanel Orientation="Vertical" Margin="10,0,0,0">
            <StackPanel Orientation="Horizontal">
                <StackPanel Orientation="Vertical">
                    <TabControl x:Name="tabConnect" Background="AliceBlue"  HorizontalAlignment="Left" Height="250" Margin="0,10,0,0" VerticalAlignment="Top" Width="350">
                        <TabItem x:Name="tabNCSelect" Header="Connect" Width="85">
                            <StackPanel Orientation="Vertical" Margin="05,0">
                                <StackPanel Orientation="Horizontal">
                                    <RadioButton x:Name="rdbDSdef" Content="Domain" HorizontalAlignment="Left" Height="18" Margin="5,10,0,0" VerticalAlignment="Top" Width="65" IsChecked="True"/>
                                    <RadioButton x:Name="rdbDSConf" Content="Config" HorizontalAlignment="Left" Height="18" Margin="5,10,0,0" VerticalAlignment="Top" Width="61"/>
                                    <RadioButton x:Name="rdbDSSchm" Content="Schema" HorizontalAlignment="Left" Height="18" Margin="5,10,0,0" VerticalAlignment="Top" Width="65"/>
                                    <RadioButton x:Name="rdbCustomNC" Content="Custom" HorizontalAlignment="Left" Height="18" Margin="5,10,0,0" VerticalAlignment="Top" Width="65"/>
                                </StackPanel>
                                <StackPanel Orientation="Horizontal" Margin="05,05,0,0"  >
                                    <Label x:Name="lblServer" Content="Server:"  HorizontalAlignment="Left" Height="28" Margin="0,0,0,0" Width="45"/>
                                    <TextBox x:Name="txtBdoxDSServer" HorizontalAlignment="Left" Height="18"  Text="" Width="150" Margin="0,0,0.0,0" IsEnabled="False"/>
                                    <Label x:Name="lblPort" Content="Port:"  HorizontalAlignment="Left" Height="28" Margin="10,0,0,0" Width="35"/>
                                    <TextBox x:Name="txtBdoxDSServerPort" HorizontalAlignment="Left" Height="18"  Text="" Width="45" Margin="0,0,0.0,0" IsEnabled="False"/>
                                </StackPanel>
                                <StackPanel Orientation="Vertical" Margin="05,05,0,0"  >
                                    <StackPanel Orientation="Horizontal" Margin="0,0,0.0,0"  >
                                        <Label x:Name="lblDomain" Content="Naming Context:"  HorizontalAlignment="Left" Height="28" Margin="0,0,0,0" Width="110"/>
                                        <CheckBox x:Name="chkBoxCreds" Content="Credentials" HorizontalAlignment="Right" Margin="80,0,0,0" Height="18" />
                                    </StackPanel>

                                    <TextBox x:Name="txtBoxDomainConnect" HorizontalAlignment="Left" Height="18"  Text="rootDSE" Width="285" Margin="0,0,0.0,0" IsEnabled="False"/>
                                </StackPanel>
                                <StackPanel Orientation="Horizontal"  Margin="05,05,0,0"  >
                                    <Button x:Name="btnDSConnect" Content="Connect" HorizontalAlignment="Left" Height="23" Margin="0,2,0,0" VerticalAlignment="Top" Width="84"/>
                                    <Button x:Name="btnListDdomain" Content="List Domains" HorizontalAlignment="Left" Height="23" Margin="50,2,0,0" VerticalAlignment="Top" Width="95"/>
                                </StackPanel>

                                <GroupBox x:Name="gBoxBrowse" Grid.Column="0" Header="Browse Options" HorizontalAlignment="Left" Height="47" Margin="00,05,0,0" VerticalAlignment="Top" Width="290" BorderBrush="Black">
                                    <StackPanel Orientation="Vertical" Margin="0,0">
                                        <StackPanel Orientation="Horizontal">
                                            <RadioButton x:Name="rdbBrowseOU" Content="OU's" HorizontalAlignment="Left" Height="18" Margin="5,05,0,0" VerticalAlignment="Top" Width="61" IsChecked="True"/>
                                            <RadioButton x:Name="rdbBrowseAll" Content="All Objects" HorizontalAlignment="Left" Height="18" Margin="20,05,0,0" VerticalAlignment="Top" Width="80"/>
                                            <CheckBox x:Name="chkBoxShowDel" Content="Show Deleted" HorizontalAlignment="Right" Margin="10,05,0,0" Height="18" />
                                        </StackPanel>
                                    </StackPanel>
                                </GroupBox>
                            </StackPanel>
                        </TabItem>
                        <TabItem x:Name="tabForestInfo" Header="Forest Info" Width="85">
                            <StackPanel Orientation="Vertical" Margin="0,05" Width="345" HorizontalAlignment="Left">
                                <Button x:Name="btnGetForestInfo" Content="Get Forest Info" Margin="0,0,0,0" Width="280" Height="19" />
                                <StackPanel Orientation="Horizontal" Margin="0,05">
                                    <Label x:Name="lblFFL" Content="Forest Functional Level:" Width="150" Height="24"/>
                                    <TextBox x:Name="txtBoxFFL" Text=""  Width="170" Margin="05,0" Height="19" />
                                </StackPanel>
                                <StackPanel Orientation="Horizontal" Margin="0,01">
                                    <Label x:Name="lblDFL" Content="Domain Functional Level:" Width="150" Height="24"/>
                                        <TextBox x:Name="txtBoxDFL" Text="" Width="170" Margin="05,0" Height="19" />
                                </StackPanel>
                                <StackPanel Orientation="Horizontal" Margin="0,01">
                                    <Label x:Name="ldblADSchema" Content="AD Schema Version:" Width="150" Height="24"/>
                                        <TextBox x:Name="txtBoxADSchema" Text="" Width="170" Margin="05,0" Height="19" />
                                </StackPanel>
                                <StackPanel Orientation="Horizontal" Margin="0,01">
                                    <Label x:Name="lblExchSchema" Content="Exchange Schema Version:" Width="150" Height="24"/>
                                        <TextBox x:Name="txtBoxExSchema" Text="" Width="170" Margin="05,0" Height="19" />
                                </StackPanel>
                                <StackPanel Orientation="Horizontal" Margin="0,01">
                                    <Label x:Name="lblLyncSchema" Content="Lync Schema Version:" Width="150" Height="24" VerticalAlignment="Top"/>
                                        <TextBox x:Name="txtBoxLyncSchema" Text="" Width="170" Margin="05,0,0,0" Height="19" />
                                </StackPanel>
                                    <StackPanel Orientation="Horizontal" Margin="0,01">
                                        <Label x:Name="lblListObjectMode" Content="List Object Mode:" Width="150" Height="24" VerticalAlignment="Top"/>
                                        <TextBox x:Name="txtListObjectMode" Text="" Width="170" Margin="05,0,0,0" Height="19" />
                                    </StackPanel>
                                </StackPanel>
                        </TabItem>
                        <TabItem x:Name="tabConnectionInfo" Header="Connection Info" Width="100" Margin="0,0,0,0">
                            <StackPanel Orientation="Vertical" Margin="0,0" HorizontalAlignment="Left" Width="345">
                                 <Label x:Name="lblDC" Content="Domain Controller:" Width="175" Height="24" HorizontalAlignment="Left" />
                                <TextBox x:Name="txtDC" Text=""  Width="320" Margin="05,0" Height="19" HorizontalAlignment="Left"  />
                                <Label x:Name="lbldefaultnamingcontext" Content="Default Naming Context:" Width="175" Height="24" HorizontalAlignment="Left" />
                                    <TextBox x:Name="txtdefaultnamingcontext" Text="" Width="320" Margin="05,0" Height="19" HorizontalAlignment="Left" />
                                <Label x:Name="lblconfigurationnamingcontext" Content="Configuration Naming Context:" Width="175" Height="24" HorizontalAlignment="Left" />
                                    <TextBox x:Name="txtconfigurationnamingcontext" Text="" Width="320" Margin="05,0" Height="19" HorizontalAlignment="Left"  />
                                <Label x:Name="lblschemanamingcontext" Content="Schema Naming Context:" Width="175" Height="24" HorizontalAlignment="Left" />
                                    <TextBox x:Name="txtschemanamingcontext" Text="" Width="320" Margin="05,0" Height="19" HorizontalAlignment="Left"  />
                                <Label x:Name="lblrootdomainnamingcontext" Content="Root Domain Naming Context:" Width="175" Height="24" HorizontalAlignment="Left" />
                                    <TextBox x:Name="txtrootdomainnamingcontext" Text="" Width="320" Margin="05,0,0,0" Height="19" HorizontalAlignment="Left"  />
                            </StackPanel>
                        </TabItem>                        
                    </TabControl>
                    <GroupBox x:Name="gBoxSelectNodeTreeView" Grid.Column="0" Header="Nodes" HorizontalAlignment="Left" Height="355" Margin="0,0,0,0" VerticalAlignment="Top" Width="350" BorderBrush="Black">
                        <StackPanel Orientation="Vertical">
                            <TreeView x:Name="treeView1"  Height="330" Width="340"  Margin="0,5,0,5" HorizontalAlignment="Left"
                DataContext="{Binding Source={StaticResource DomainOUData}, XPath=/DomainRoot}"
                ItemTemplate="{StaticResource NodeTemplate}"
                ItemsSource="{Binding}">
                                <TreeView.ContextMenu>
                                    <ContextMenu x:Name="ContextMUpdateNode"  >
                                        <MenuItem Header="Refresh Childs">
                                            <MenuItem.Icon>
                                                <Image Width="15" Height="15" Source="{Binding XPath=@Icon}" />
                                            </MenuItem.Icon>
                                        </MenuItem>
                                        <MenuItem Header="Exclude Node">
                                            <MenuItem.Icon>
                                                <Image Width="15" Height="15" Source="{Binding XPath=@Icon2}" />
                                            </MenuItem.Icon>
                                        </MenuItem>
                                    </ContextMenu>

                                </TreeView.ContextMenu>
                            </TreeView>
                        </StackPanel>
                    </GroupBox>
                </StackPanel>
                <TabControl x:Name="tabConWiz" HorizontalAlignment="Left" Height="600" Margin="10,10,0,0" VerticalAlignment="Top" Width="612">
                    <TabItem x:Name="tabAdv" Header="Advanced" Height="22" VerticalAlignment="Top" >
                        <Grid Background="AliceBlue" HorizontalAlignment="Left" VerticalAlignment="Top" Height="570">
                                <StackPanel Orientation="Vertical">
                                <StackPanel Orientation="Horizontal">
                                <TabControl x:Name="tabScanTop" Background="AliceBlue"  HorizontalAlignment="Left" Height="530"  VerticalAlignment="Top" Width="300">
                                    <TabItem x:Name="tabScan" Header="Scan Options" Width="85">
                                        <Grid >
                                            <StackPanel Orientation="Vertical" Margin="0,0">
                                                <GroupBox x:Name="gBoxScanType" Header="Scan Type" HorizontalAlignment="Left" Height="51" Margin="2,1,0,0" VerticalAlignment="Top" Width="290">
                                                    <StackPanel Orientation="Vertical" Margin="0,0">
                                                        <StackPanel Orientation="Horizontal">
                                                            <RadioButton x:Name="rdbDACL" Content="DACL (Access)" HorizontalAlignment="Left" Height="18" Margin="5,10,0,0" VerticalAlignment="Top" Width="95" IsChecked="True"/>
                                                            <RadioButton x:Name="rdbSACL" Content="SACL (Audit)" HorizontalAlignment="Left" Height="18" Margin="20,10,0,0" VerticalAlignment="Top" Width="90"/>

                                                        </StackPanel>
                                                    </StackPanel>
                                                </GroupBox>
                                                <GroupBox x:Name="gBoxScanDepth" Header="Scan Depth" HorizontalAlignment="Left" Height="51" Margin="2,1,0,0" VerticalAlignment="Top" Width="290">
                                                    <StackPanel Orientation="Vertical" Margin="0,0">
                                                        <StackPanel Orientation="Horizontal">
                                                            <RadioButton x:Name="rdbBase" Content="Base" HorizontalAlignment="Left" Height="18" Margin="5,10,0,0" VerticalAlignment="Top" Width="61" IsChecked="True"/>
                                                            <RadioButton x:Name="rdbOneLevel" Content="One Level" HorizontalAlignment="Left" Height="18" Margin="20,10,0,0" VerticalAlignment="Top" Width="80"/>
                                                            <RadioButton x:Name="rdbSubtree" Content="Subtree" HorizontalAlignment="Left" Height="18" Margin="20,10,0,0" VerticalAlignment="Top" Width="80"/>
                                                        </StackPanel>
                                                    </StackPanel>
                                                </GroupBox>
                                                <GroupBox x:Name="gBoxRdbScan" Header="Objects to scan" HorizontalAlignment="Left" Height="51" Margin="2,0,0,0" VerticalAlignment="Top" Width="290">
                                                    <StackPanel Orientation="Vertical" Margin="0,0">
                                                        <StackPanel Orientation="Horizontal">
                                                            <RadioButton x:Name="rdbScanOU" Content="OUs" HorizontalAlignment="Left" Height="18" Margin="5,10,0,0" VerticalAlignment="Top" Width="61" IsChecked="True"/>
                                                            <RadioButton x:Name="rdbScanContainer" Content="Containers" HorizontalAlignment="Left" Height="18" Margin="5,10,0,0" VerticalAlignment="Top" Width="80"/>
                                                            <RadioButton x:Name="rdbScanAll" Content="All Objects" HorizontalAlignment="Left" Height="18" Margin="5,10,0,0" VerticalAlignment="Top" Width="80"/>
                                                        </StackPanel>
                                                    </StackPanel>
                                                </GroupBox>
                                                <GroupBox x:Name="gBoxReportOpt" Header="View in report" HorizontalAlignment="Left" Height="165" Margin="2,0,0,0" VerticalAlignment="Top" Width="290">
                                                    <StackPanel Orientation="Vertical" Margin="0,0">
                                                        <StackPanel Orientation="Horizontal">
                                                            <CheckBox x:Name="chkBoxGetOwner" Content="View Owner" HorizontalAlignment="Left" Height="18" Margin="5,05,0,0" VerticalAlignment="Top" Width="120"/>
                                                            <CheckBox x:Name="chkBoxACLSize" Content="DACL Size" HorizontalAlignment="Left" Height="18" Margin="30,05,0,0" VerticalAlignment="Top" Width="80"/>
                                                        </StackPanel>
                                                        <StackPanel Orientation="Horizontal" Margin="0,0,0.2,0" Height="35">
                                                            <CheckBox x:Name="chkInheritedPerm" Content="Inherited&#10;Permissions" HorizontalAlignment="Left" Height="30" Margin="5,05,0,0" VerticalAlignment="Top" Width="120"/>
                                                                <CheckBox x:Name="chkBoxGetOUProtected" Content="Inheritance&#10;Disabled" HorizontalAlignment="Left" Height="30" Margin="30,05,0,0" VerticalAlignment="Top" Width="120"/>
                                                        </StackPanel>
                                                        <StackPanel Orientation="Horizontal" Height="35" Margin="0,0,0.2,0">
                                                            <CheckBox x:Name="chkBoxDefaultPerm" Content="Skip Default&#10;Permissions" HorizontalAlignment="Left" Height="30" Margin="5,05,0,0" VerticalAlignment="Top" Width="120"/>
                                                            <CheckBox x:Name="chkBoxReplMeta" Content="SD Modified date" HorizontalAlignment="Left" Height="30" Margin="30,05,0,0" VerticalAlignment="Top" Width="120"/>

                                                        </StackPanel>
                                                        <StackPanel Orientation="Horizontal" Height="35" Margin="0,0,0.2,0">
                                                            <CheckBox x:Name="chkBoxSkipProtectedPerm" Content="Skip Protected&#10;Permissions" HorizontalAlignment="Left" Height="30" Margin="5,05,0,0" VerticalAlignment="Top" Width="120"/>
                                                            <CheckBox x:Name="chkBoxObjType" Content="ObjectClass" HorizontalAlignment="Left" Height="30" Margin="30,05,0,0" VerticalAlignment="Top" Width="90"/>
                                                        </StackPanel>
                                                    </StackPanel>
                                                </GroupBox>
                                                <GroupBox x:Name="gBoxRdbFile" Header="Output Options" HorizontalAlignment="Left" Height="158" Margin="2,0,0,0" VerticalAlignment="Top" Width="290">
                                                    <StackPanel Orientation="Vertical" Margin="0,0">
                                                        <StackPanel Orientation="Horizontal">
                                                            <RadioButton x:Name="rdbOnlyHTA" Content="HTML" HorizontalAlignment="Left" Height="18" Margin="5,05,0,0" VerticalAlignment="Top" Width="61" GroupName="rdbGroupOutput" IsChecked="True"/>
                                                            <RadioButton x:Name="rdbHTAandCSV" Content="HTML and CSV file" HorizontalAlignment="Left" Height="18" Margin="20,05,0,0" VerticalAlignment="Top" Width="155" GroupName="rdbGroupOutput"/>
                                                        </StackPanel>
                                                        <RadioButton x:Name="rdbOnlyCSV" Content="CSV file" HorizontalAlignment="Left" Height="18" Margin="5,02,0,0" VerticalAlignment="Top" Width="80" GroupName="rdbGroupOutput"/>
                                                        <CheckBox x:Name="chkBoxTranslateGUID" Content="Translate GUID's in CSV output" HorizontalAlignment="Left" Height="18" Margin="5,05,0,0" VerticalAlignment="Top" Width="200"/>
                                                        <Label x:Name="lblTempFolder" Content="CSV file destination" />
                                                        <TextBox x:Name="txtTempFolder" Margin="0,0,02,0"/>
                                                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" >
                                                            <Button x:Name="btnGetTemplateFolder" Content="Change Folder" Margin="5,05,0,0" />
                                                        </StackPanel>
                                                    </StackPanel>
                                                </GroupBox>
                                            </StackPanel>
                                        </Grid>
                                    </TabItem>
                                    <TabItem x:Name="tabOfflineScan" Header="Additional Options">
                                        <Grid>
                                            <StackPanel>
                                                <GroupBox x:Name="gBoxImportCSV" Header="CSV to HTML" HorizontalAlignment="Left" Height="136" Margin="2,1,0,0" VerticalAlignment="Top" Width="290">
                                                    <StackPanel Orientation="Vertical" Margin="0,0">
                                                        <Label x:Name="lblCSVImport" Content="This file will be converted HTML:" />
                                                        <TextBox x:Name="txtCSVImport"/>
                                                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                                                            <Button x:Name="btnGetCSVFile" Content="Select CSV" />
                                                        </StackPanel>
                                                        <CheckBox x:Name="chkBoxTranslateGUIDinCSV" Content="CSV file do not contain object GUIDs" HorizontalAlignment="Left" Height="18" Margin="5,10,0,0" VerticalAlignment="Top" Width="290"/>
                                                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                                                            <Button x:Name="btnCreateHTML" Content="Create HTML View" />
                                                        </StackPanel>
                                                    </StackPanel>
                                                </GroupBox>
                                                <GroupBox x:Name="gBoxCriticality" Header="Access Rights Criticality" HorizontalAlignment="Left" Height="150" Margin="2,0,0,0" VerticalAlignment="Top" Width="290">
                                                    <StackPanel Orientation="Vertical" Margin="0,0">
                                                        <CheckBox x:Name="chkBoxEffectiveRightsColor" Content="Show color coded criticality" HorizontalAlignment="Left" Margin="5,10,0,0" VerticalAlignment="Top" IsEnabled="True"/>
                                                        <Label x:Name="lblEffectiveRightsColor" Content="Use colors in report to identify criticality level of &#10;permissions.This might help you in implementing &#10;Least-Privilege Administrative Models" />
                                                        <Button x:Name="btnViewLegend" Content="View Color Legend" HorizontalAlignment="Left" Margin="5,0,0,0" IsEnabled="True" Width="110"/>
                                                    </StackPanel>
                                                </GroupBox>
                                                <GroupBox x:Name="gBoxProgress" Header="Progress Bar" HorizontalAlignment="Left" Height="75" Margin="2,0,0,0" VerticalAlignment="Top" Width="290">
                                                    <StackPanel Orientation="Vertical" Margin="0,0">
                                                        <CheckBox x:Name="chkBoxSkipProgressBar" Content="Use Progress Bar" HorizontalAlignment="Left" Margin="5,10,0,0" VerticalAlignment="Top" IsEnabled="True" IsChecked="True"/>
                                                        <Label x:Name="lblSkipProgressBar" Content="For speed you could disable the progress bar." />
                                                    </StackPanel>
                                                </GroupBox>
                                            </StackPanel>
                                        </Grid>
                                    </TabItem>
                                    <TabItem x:Name="tabOther" Header="Default SD">
                                        <Grid>
                                            <StackPanel>
                                                <StackPanel Orientation="Vertical" Margin="0,0,0,-40">
                                                    <GroupBox x:Name="gBoxdDefSecDesc" Header="Output Format" HorizontalAlignment="Left" Height="45" Margin="0,0,0,0" VerticalAlignment="Top" Width="290">
                                                        <StackPanel Orientation="Horizontal" Margin="0,0">
                                                            <RadioButton x:Name="rdbDefSD_Access" Content="DACL" HorizontalAlignment="Left" Height="18" Margin="5,05,0,0" VerticalAlignment="Top" Width="50" IsChecked="True"/>
                                                            <RadioButton x:Name="rdbDefSD_SDDL" Content="SDDL" HorizontalAlignment="Left" Height="18" Margin="10,05,0,0" VerticalAlignment="Top" Width="50"/>
                                                        </StackPanel>
                                                    </GroupBox>
                                                    <CheckBox x:Name="chkModifedDefSD" Content="Only modified defaultSecurityDescriptors" HorizontalAlignment="Left" Margin="5,10,0,0" VerticalAlignment="Top"/>
                                                    <Label x:Name="lblObjectDefSD" Content="Select objects to scan:" />
                                                    <StackPanel Orientation="Horizontal" Margin="0,0">
                                                        <ComboBox x:Name="combObjectDefSD" HorizontalAlignment="Left" Margin="05,05,00,00" VerticalAlignment="Top" Width="120" IsEnabled="True" SelectedValue="*"/>
                                                        <Button x:Name="btnScanDefSD" Content="Run Scan" HorizontalAlignment="Right" Width="90" Height="19" Margin="37,05,00,00" IsEnabled="True"/>
                                                    </StackPanel>
                                                    <StackPanel Orientation="Horizontal" Margin="0,0">
                                                        <Button x:Name="btnGetSchemaClass" Content="Load all classSchema" HorizontalAlignment="Left" Width="120" Height="19" Margin="05,05,00,00" IsEnabled="True"/>
                                                        <Button x:Name="btnExportDefSD" Content="Export to CSV" HorizontalAlignment="Right" Width="90" Height="19" Margin="37,05,00,00" IsEnabled="True"/>
                                                    </StackPanel>
                                  
                                                    <GroupBox x:Name="gBoxdDefSecDescCompare" Header="Compare" HorizontalAlignment="Left" Height="260" Margin="0,0,0,0" VerticalAlignment="Top" Width="290">
                                                        <StackPanel  Margin="0,0">
                                                       
                                                        <Label x:Name="lblCompareDefSDText" Content="You can compare the current state with  &#10;a previously created CSV file." />
                                                        <Label x:Name="lblCompareDefSDTemplate" Content="CSV Template File" />
                                                        <TextBox x:Name="txtCompareDefSDTemplate" Margin="2,0,0,0" Width="275" IsEnabled="True"/>
                                                        <Button x:Name="btnGetCompareDefSDInput" Content="Select Template" HorizontalAlignment="Right" Width="90" Height="19" Margin="162,05,00,00" IsEnabled="True"/>
                                                        <Button x:Name="btnCompDefSD" Content="Run Compare" HorizontalAlignment="Right" Width="90" Height="19" Margin="162,05,00,00" IsEnabled="True"/>
                                                                    <Label x:Name="lblDownloadCSVDefSD" Content="Download CSV templates for comparing with&#10;your defaultSecurityDescriptors:" Margin="05,20,00,00" />
                                                                    <Button x:Name="btnDownloadCSVDefSD" Content="Download CSV Templates" HorizontalAlignment="Left" Width="140" Height="19" Margin="05,05,00,00" IsEnabled="True"/>
                                                        </StackPanel>
                                                    </GroupBox>
                                                </StackPanel>
                                            </StackPanel>
                                        </Grid>
                                    </TabItem>
                                </TabControl>
                                <TabControl x:Name="tabFilterTop" Background="AliceBlue"  HorizontalAlignment="Left" Height="530" Margin="4,0,0,0" VerticalAlignment="Top" Width="300">
                                    <TabItem x:Name="tabCompare" Header="Compare">
                                        <Grid>
                                            <Grid.ColumnDefinitions>
                                                <ColumnDefinition Width="34*"/>
                                                <ColumnDefinition Width="261*"/>
                                            </Grid.ColumnDefinitions>
                                            <StackPanel Orientation="Vertical" Margin="0,0" HorizontalAlignment="Left" Grid.ColumnSpan="2">

                                                <CheckBox x:Name="chkBoxCompare" Content="Enable Compare" HorizontalAlignment="Left" Margin="5,10,0,0" VerticalAlignment="Top"/>
                                                <Label x:Name="lblCompareDescText" Content="You can compare the current state with  &#10;a previously created CSV file." />
                                                <Label x:Name="lblCompareTemplate" Content="CSV Template File" />
                                                <TextBox x:Name="txtCompareTemplate" Margin="2,0,0,0" Width="275" IsEnabled="False"/>
                                                <Button x:Name="btnGetCompareInput" Content="Select Template" HorizontalAlignment="Right" Height="19" Margin="65,00,00,00" IsEnabled="False"/>
                                                <StackPanel Orientation="Vertical">
                                                    <CheckBox x:Name="chkBoxTemplateNodes" Content="Use nodes from template." HorizontalAlignment="Left" Width="160" Margin="2,5,00,00" IsEnabled="False" />
                                                    <CheckBox x:Name="chkBoxScanUsingUSN" Content="Faster compare using USNs of the&#10;NTSecurityDescriptor. This requires that your &#10;template to contain USNs.Requires SD Modified&#10;date selected when creating the template." HorizontalAlignment="Left"  Width="280" Margin="2,5,00,00" IsEnabled="False" />                                                        
                                                </StackPanel>
                                                <Label x:Name="lblReplaceDN" Content="Replace DN in file with current domain DN.&#10;E.g. DC=contoso,DC=com&#10;Type the old DN to be replaced:" />
                                                <TextBox x:Name="txtReplaceDN" Margin="2,0,0,0" Width="250" IsEnabled="False"/>
                                                <Label x:Name="lblReplaceNetbios" Content="Replace principals prefixed domain name with&#10;current domain. E.g. CONTOSO&#10;Type the old NETBIOS name to be replaced:" />
                                                <TextBox x:Name="txtReplaceNetbios" Margin="2,0,0,0" Width="250" IsEnabled="False"/>
                                                        <Label x:Name="lblDownloadCSVDefACLs" Content="Download CSV templates for comparing with&#10;your environment:" Margin="05,20,00,00" />
                                                        <Button x:Name="btnDownloadCSVDefACLs" Content="Download CSV Templates" HorizontalAlignment="Left" Width="140" Height="19" Margin="05,05,00,00" IsEnabled="True"/>
                                                    </StackPanel>
                                        </Grid>
                                    </TabItem>
                                    <TabItem x:Name="tabFilter" Header="Filter">
                                        <Grid>
                                            <StackPanel Orientation="Vertical" Margin="0,0">
                                                <CheckBox x:Name="chkBoxFilter" Content="Enable Filter" HorizontalAlignment="Left" Margin="5,10,0,0" VerticalAlignment="Top"/>
                                                <Label x:Name="lblAccessCtrl" Content="Filter by Access Type:(example: Allow)" />
                                                <StackPanel Orientation="Horizontal" Margin="0,0">
                                                    <CheckBox x:Name="chkBoxType" Content="" HorizontalAlignment="Left" Margin="5,0,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                                                    <ComboBox x:Name="combAccessCtrl" HorizontalAlignment="Left" Margin="5,0,0,0" VerticalAlignment="Top" Width="120" IsEnabled="False"/>
                                                </StackPanel>
                                                <Label x:Name="lblFilterExpl" Content="Filter by Object:(example: user)" />
                                                <StackPanel Orientation="Horizontal" Margin="0,0">
                                                    <CheckBox x:Name="chkBoxObject" Content="" HorizontalAlignment="Left" Margin="5,0,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                                                    <ComboBox x:Name="combObjectFilter" HorizontalAlignment="Left" Margin="5,0,0,0" VerticalAlignment="Top" Width="120" IsEnabled="False"/>
                                                </StackPanel>
                                                <Label x:Name="lblGetObj" Content="The list box contains a few  number of standard &#10;objects. To load all objects from schema &#10;press Load." />
                                                <StackPanel  Orientation="Horizontal" Margin="0,0">

                                                    <Label x:Name="lblGetObjExtend" Content="This may take a while!" />
                                                    <Button x:Name="btnGetObjFullFilter" Content="Load" IsEnabled="False" Width="50" />
                                                </StackPanel>
                                                <Label x:Name="lblFilterTrusteeExpl" Content="Filter by Trustee:&#10;Examples:&#10;CONTOSO\User&#10;CONTOSO\JohnDoe*&#10;*Smith&#10;*Doe*" />
                                                <StackPanel Orientation="Horizontal" Margin="0,0">
                                                    <CheckBox x:Name="chkBoxTrustee" Content="" HorizontalAlignment="Left" Margin="5,0,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                                                    <TextBox x:Name="txtFilterTrustee" HorizontalAlignment="Left" Margin="5,0,0,0" VerticalAlignment="Top" Width="120" IsEnabled="False"/>
                                                </StackPanel>
                                            </StackPanel>
                                        </Grid>
                                    </TabItem>
                                    <TabItem x:Name="tabEffectiveR" Header="Effective Rights">
                                        <Grid >
                                            <StackPanel Orientation="Vertical" Margin="0,0">
                                                <CheckBox x:Name="chkBoxEffectiveRights" Content="Enable Effective Rights" HorizontalAlignment="Left" Margin="5,10,0,0" VerticalAlignment="Top"/>
                                                <Label x:Name="lblEffectiveDescText" Content="Effective Access allows you to view the effective &#10;permissions for a user, group, or device account." />
                                                <Label x:Name="lblEffectiveText" Content="Type the account name (samAccountName) for a &#10;user, group or computer" />
                                                <Label x:Name="lblSelectPrincipalDom" Content=":" />
                                                <TextBox x:Name="txtBoxSelectPrincipal" IsEnabled="False"  />
                                                <StackPanel  Orientation="Horizontal" Margin="0,0">
                                                    <Button x:Name="btnGetSPAccount" Content="Get Account" Margin="5,0,0,0" IsEnabled="False"/>
                                                    <Button x:Name="btnListLocations" Content="Locations..." Margin="50,0,0,0" IsEnabled="False"/>
                                                </StackPanel>
                                                <StackPanel  Orientation="Vertical" Margin="0,0"   >
                                                    <GroupBox x:Name="gBoxEffectiveSelUser" Header="Selected Security Principal:" HorizontalAlignment="Left" Height="50" Margin="2,2,0,0" VerticalAlignment="Top" Width="290">
                                                        <StackPanel Orientation="Vertical" Margin="0,0">
                                                            <Label x:Name="lblEffectiveSelUser" Content="" />
                                                        </StackPanel>
                                                    </GroupBox>
                                                    <Button x:Name="btnGETSPNReport" HorizontalAlignment="Left" Content="View Account" Margin="5,2,0,0" IsEnabled="False" Width="110"/>
                                                </StackPanel>
                                            </StackPanel>
                                        </Grid>
                                    </TabItem>

                                </TabControl>
                            </StackPanel>
                            <Button x:Name="btnScan" Content="Run Scan" HorizontalAlignment="Left" Height="19" Margin="500,10,0,0" VerticalAlignment="Top" Width="66"/>
                                    </StackPanel>
                        </Grid>
                    </TabItem>
                </TabControl>
            </StackPanel>
            <StackPanel >

                <Label x:Name="lblSelectedNode" Content="Selected Object:" HorizontalAlignment="Left" Height="26" Margin="0,0,0,0" VerticalAlignment="Top" Width="158"/>

                <StackPanel Orientation="Horizontal" >
                    <TextBox x:Name="txtBoxSelected" HorizontalAlignment="Left" Height="20" Margin="0,0,0,0" TextWrapping="NoWrap" VerticalAlignment="Top" Width="710"/>
                    <Button x:Name="btnExit" Content="Exit" HorizontalAlignment="Left" Margin="150,0,0,0" VerticalAlignment="Top" Width="75"/>
                </StackPanel>
                <Label x:Name="lblExcludeddNode" Content="Excluded Path (matching string in distinguishedName):" HorizontalAlignment="Left" Height="26" Margin="0,0,0,0" VerticalAlignment="Top" Width="300"/>
                <StackPanel Orientation="Horizontal">
                    <TextBox x:Name="txtBoxExcluded" HorizontalAlignment="Left" Height="20" Margin="0,0,0,0" TextWrapping="NoWrap" VerticalAlignment="Top" Width="710" />
                    <Button x:Name="btnClearExcludedBox" Content="Clear"  Height="21" Margin="10,0,0,0" IsEnabled="true" Width="100"/>
                </StackPanel>
                <Label x:Name="lblStatusBar" Content="Log:" HorizontalAlignment="Left" Height="26" Margin="0,0,0,0" VerticalAlignment="Top" Width="158"/>
                    <StackPanel Orientation="Horizontal" >
                <ListBox x:Name="TextBoxStatusMessage" DisplayMemberPath="Message" SelectionMode="Extended" HorizontalAlignment="Left" Height="100" Margin="0,0,0,0" VerticalAlignment="Top" Width="710" ScrollViewer.HorizontalScrollBarVisibility="Auto">
                    <ListBox.ItemContainerStyle>
                        <Style TargetType="{x:Type ListBoxItem}">
                            <Style.Triggers>
                                <DataTrigger Binding="{Binding Path=Type}" Value="Error">
                                    <Setter Property="ListBoxItem.Foreground" Value="Red" />
                                    <Setter Property="ListBoxItem.Background" Value="LightGray" />
                                </DataTrigger>
                                <DataTrigger Binding="{Binding Path=Type}" Value="Warning">
                                    <Setter Property="ListBoxItem.Foreground" Value="Yellow" />
                                    <Setter Property="ListBoxItem.Background" Value="Gray" />
                                </DataTrigger>
                                <DataTrigger Binding="{Binding Path=Type}" Value="Info">
                                    <Setter Property="ListBoxItem.Foreground" Value="Black" />
                                    <Setter Property="ListBoxItem.Background" Value="White" />
                                </DataTrigger>
                            </Style.Triggers>
                        </Style>
                    </ListBox.ItemContainerStyle>
                </ListBox>
                    <StackPanel Orientation="Horizontal" Margin="62,0,0,0">
                    <StackPanel Orientation="Vertical">
                        <Label x:Name="lblStyleVersion3" Content="L" HorizontalAlignment="Left" Height="38" Margin="0,0,0,0" VerticalAlignment="Top"  Width="40" Background="#FF00AEEF" FontFamily="Webdings" FontSize="36" VerticalContentAlignment="Center" HorizontalContentAlignment="Center" Padding="2,0,0,0"/>
                        <Label x:Name="lblStyleVersion4" Content="d" HorizontalAlignment="Left" Height="38" Margin="0,3,0,0" VerticalAlignment="Top"  Width="40" Background="#FFFF5300" FontFamily="Webdings" FontSize="36" VerticalContentAlignment="Center" HorizontalContentAlignment="Center" Padding="2,0,0,0" />
                    </StackPanel>
                    <StackPanel Orientation="Vertical" >
                        <Label x:Name="lblStyleVersion1" Content="AD ACL Scanner &#10;4.5.0" HorizontalAlignment="Left" Height="40" Margin="0,0,0,0" VerticalAlignment="Top" Width="159" Foreground="#FFF4F0F0" Background="#FF004080" FontWeight="Bold"/>
                        <Label x:Name="lblStyleVersion2" Content="written by &#10;robin.granberg@microsoft.com" HorizontalAlignment="Left" Height="40" Margin="0,0,0,0" VerticalAlignment="Top" Width="159" Foreground="#FFF4F0F0" Background="#FF004080" FontSize="10"/>
                        <Button x:Name="btnSupport" Height="23" Tag="Support Statement"  Margin="0,0,0,0" Foreground="#FFF6F6F6" HorizontalAlignment="Right">
                            <TextBlock TextDecorations="Underline" Text="{Binding Path=Tag, RelativeSource={RelativeSource Mode=FindAncestor, AncestorType={x:Type Button}}}" />
                            <Button.Template>
                                <ControlTemplate TargetType="{x:Type Button}">
                                    <ContentPresenter />
                                </ControlTemplate>
                            </Button.Template>
                        </Button>

                    </StackPanel>
                </StackPanel>
            </StackPanel>
        </StackPanel>
        </StackPanel>

    </Grid>
    </ScrollViewer>
</Window>

"@

$xamlForm1.Window.RemoveAttribute("x:Class")  

$reader=(New-Object System.Xml.XmlNodeReader  $xamlForm1)
$ADACLGui.Window=[Windows.Markup.XamlReader]::Load( $reader )


$tabAdv = $ADACLGui.Window.FindName("tabAdv")
$xmlprov_adp = $ADACLGui.Window.FindName("xmlprov")
$chkBoxTemplateNodes = $ADACLGui.Window.FindName("chkBoxTemplateNodes")
$chkBoxScanUsingUSN = $ADACLGui.Window.FindName("chkBoxScanUsingUSN")
$rdbDACL = $ADACLGui.Window.FindName("rdbDACL")
$rdbSACL = $ADACLGui.Window.FindName("rdbSACL")
$lblSelectPrincipalDom = $ADACLGui.Window.FindName("lblSelectPrincipalDom")
$lblEffectiveSelUser = $ADACLGui.Window.FindName("lblEffectiveSelUser")
$chkBoxEffectiveRights = $ADACLGui.Window.FindName("chkBoxEffectiveRights")
$chkBoxEffectiveRightsColor = $ADACLGui.Window.FindName("chkBoxEffectiveRightsColor")
$chkBoxSkipProgressBar = $ADACLGui.Window.FindName("chkBoxSkipProgressBar")
$chkBoxGetOUProtected = $ADACLGui.Window.FindName("chkBoxGetOUProtected")
$chkBoxGetOwner = $ADACLGui.Window.FindName("chkBoxGetOwner")
$chkBoxReplMeta = $ADACLGui.Window.FindName("chkBoxReplMeta")
$chkBoxACLSize = $ADACLGui.Window.FindName("chkBoxACLSize")
$chkBoxType = $ADACLGui.Window.FindName("chkBoxType")
$chkBoxObject = $ADACLGui.Window.FindName("chkBoxObject")
$chkBoxTrustee = $ADACLGui.Window.FindName("chkBoxTrustee")
$btnGETSPNReport = $ADACLGui.Window.FindName("btnGETSPNReport")
$btnGetSPAccount = $ADACLGui.Window.FindName("btnGetSPAccount")
$btnGetObjFullFilter = $ADACLGui.Window.FindName("btnGetObjFullFilter")
$btnViewLegend = $ADACLGui.Window.FindName("btnViewLegend")
$combObjectFilter = $ADACLGui.Window.FindName("combObjectFilter")
$combAccessCtrl = $ADACLGui.Window.FindName("combAccessCtrl")
$txtFilterTrustee = $ADACLGui.Window.FindName("txtFilterTrustee")
$chkBoxFilter = $ADACLGui.Window.FindName("chkBoxFilter")
$txtBoxSelectPrincipal = $ADACLGui.Window.FindName("txtBoxSelectPrincipal")
$txtTempFolder = $ADACLGui.Window.FindName("txtTempFolder")
$txtCompareTemplate = $ADACLGui.Window.FindName("txtCompareTemplate")
$TextBoxStatusMessage = $ADACLGui.Window.FindName("TextBoxStatusMessage")
$rdbCustomNC = $ADACLGui.Window.FindName("rdbCustomNC")
$rdbOneLevel = $ADACLGui.Window.FindName("rdbOneLevel")
$rdbSubtree = $ADACLGui.Window.FindName("rdbSubtree")
$rdbDSdef = $ADACLGui.Window.FindName("rdbDSdef")
$rdbDSConf = $ADACLGui.Window.FindName("rdbDSConf")
$rdbDSSchm = $ADACLGui.Window.FindName("rdbDSSchm")
$btnDSConnect = $ADACLGui.Window.FindName("btnDSConnect")
$btnListDdomain = $ADACLGui.Window.FindName("btnListDdomain")
$btnListLocations = $ADACLGui.Window.FindName("btnListLocations")
$txtCSVImport = $ADACLGui.Window.FindName("txtCSVImport")
$rdbBase = $ADACLGui.Window.FindName("rdbBase")
$chkInheritedPerm = $ADACLGui.Window.FindName("chkInheritedPerm")
$chkBoxDefaultPerm = $ADACLGui.Window.FindName("chkBoxDefaultPerm")
$rdbScanOU = $ADACLGui.Window.FindName("rdbScanOU")
$rdbScanContainer = $ADACLGui.Window.FindName("rdbScanContainer")
$rdbScanAll = $ADACLGui.Window.FindName("rdbScanAll")
$rdbHTAandCSV = $ADACLGui.Window.FindName("rdbHTAandCSV")
$rdbOnlyCSV = $ADACLGui.Window.FindName("rdbOnlyCSV")
$txtBoxSelected = $ADACLGui.Window.FindName("txtBoxSelected")
$txtBoxDomainConnect = $ADACLGui.Window.FindName("txtBoxDomainConnect")
$rdbBrowseAll = $ADACLGui.Window.FindName("rdbBrowseAll")
$btnScan = $ADACLGui.Window.FindName("btnScan")
$lblHeader = $ADACLGui.Window.FindName("lblHeader")
$treeView1 = $ADACLGui.Window.FindName("treeView1")
$chkBoxCompare = $ADACLGui.Window.FindName("chkBoxCompare")
$btnGetTemplateFolder = $ADACLGui.Window.FindName("btnGetTemplateFolder")
$btnGetCompareInput = $ADACLGui.Window.FindName("btnGetCompareInput")
$btnExit = $ADACLGui.Window.FindName("btnExit")
$btnGetCSVFile = $ADACLGui.Window.FindName("btnGetCSVFile")
$btnCreateHTML = $ADACLGui.Window.FindName("btnCreateHTML")
$chkBoxTranslateGUID = $ADACLGui.Window.FindName("chkBoxTranslateGUID")
$chkBoxTranslateGUIDinCSV = $ADACLGui.Window.FindName("chkBoxTranslateGUIDinCSV")
$btnSupport = $ADACLGui.Window.FindName("btnSupport")
$txtBoxExcluded = $ADACLGui.Window.FindName("txtBoxExcluded")
$btnClearExcludedBox = $ADACLGui.Window.FindName("btnClearExcludedBox")
$chkBoxSkipProtectedPerm = $ADACLGui.Window.FindName("chkBoxSkipProtectedPerm")
$txtReplaceDN = $ADACLGui.Window.FindName("txtReplaceDN")
$txtReplaceNetbios = $ADACLGui.Window.FindName("txtReplaceNetbios")
$chkBoxObjType = $ADACLGui.Window.FindName("chkBoxObjType")
$combObjectDefSD = $ADACLGui.Window.FindName("combObjectDefSD")
$btnScanDefSD = $ADACLGui.Window.FindName("btnScanDefSD")
$btnGetSchemaClass = $ADACLGui.Window.FindName("btnGetSchemaClass")
$rdbDefSD_SDDL = $ADACLGui.Window.FindName("rdbDefSD_SDDL")
$btnGetForestInfo = $ADACLGui.Window.FindName("btnGetForestInfo")
$txtBoxExSchema = $ADACLGui.Window.FindName("txtBoxExSchema")
$txtBoxLyncSchema = $ADACLGui.Window.FindName("txtBoxLyncSchema")
$txtBoxADSchema = $ADACLGui.Window.FindName("txtBoxADSchema")
$txtBoxDFL = $ADACLGui.Window.FindName("txtBoxDFL")
$txtBoxFFL = $ADACLGui.Window.FindName("txtBoxFFL")
$rdbDefSD_SDDL = $ADACLGui.Window.FindName("rdbDefSD_SDDL")
$txtBdoxDSServerPort = $ADACLGui.Window.FindName("txtBdoxDSServerPort")
$txtBdoxDSServer = $ADACLGui.Window.FindName("txtBdoxDSServer")
$chkBoxCreds = $ADACLGui.Window.FindName("chkBoxCreds")
$chkBoxShowDel = $ADACLGui.Window.FindName("chkBoxShowDel")
$btnGetCompareDefSDInput = $ADACLGui.Window.FindName("btnGetCompareDefSDInput")
$txtCompareTemplate = $ADACLGui.Window.FindName("txtCompareTemplate")
$txtCompareDefSDTemplate = $ADACLGui.Window.Findname("txtCompareDefSDTemplate")
$btnCompDefSD = $ADACLGui.Window.Findname("btnCompDefSD")
$btnExportDefSD = $ADACLGui.Window.Findname("btnExportDefSD")
$chkModifedDefSD = $ADACLGui.Window.Findname("chkModifedDefSD")
$txtDC = $ADACLGui.Window.Findname("txtDC")
$txtdefaultnamingcontext = $ADACLGui.Window.Findname("txtdefaultnamingcontext")
$txtconfigurationnamingcontext = $ADACLGui.Window.Findname("txtconfigurationnamingcontext")
$txtschemanamingcontext = $ADACLGui.Window.Findname("txtschemanamingcontext")
$txtrootdomainnamingcontext = $ADACLGui.Window.Findname("txtrootdomainnamingcontext")
$btnDownloadCSVDefSD = $ADACLGui.Window.Findname("btnDownloadCSVDefSD")
$txtListObjectMode = $ADACLGui.Window.Findname("txtListObjectMode")
$btnDownloadCSVDefACLs = $ADACLGui.Window.Findname("btnDownloadCSVDefACLs")


$txtTempFolder.Text = $CurrentFSPath
$global:bolConnected = $false
$global:strPinDomDC = ""
$global:strPrinDomAttr = ""
$global:strPrinDomDir = ""
$global:strPrinDomFlat = ""
$global:strPrincipalDN =""
 $global:strDomainPrinDNName = ""
$global:strEffectiveRightSP = ""
$global:strEffectiveRightAccount = ""
$global:strSPNobjectClass = ""
$global:tokens = New-Object System.Collections.ArrayList
$global:tokens.Clear()
$global:strDommainSelect = "rootDSE"
$global:bolTempValue_InhertiedChkBox = $false
$global:scopeLevel = "OneLevel"
[void]$combAccessCtrl.Items.Add("Allow")
[void]$combAccessCtrl.Items.Add("Deny")
[void]$combObjectDefSD.Items.Add("All Objects")
$combObjectDefSD.SelectedValue="All Objects"
$tabAdv.IsSelected= $true
###################
#TODO: Place custom script here


$code = @"using System;using System.Drawing;using System.Runtime.InteropServices;namespace System{	public class IconExtractor	{	 public static Icon Extract(string file, int number, bool largeIcon)	 {	  IntPtr large;	  IntPtr small;	  ExtractIconEx(file, number, out large, out small, 1);	  try	  {	   return Icon.FromHandle(largeIcon ? large : small);	  }	  catch	  {	   return null;	  }	 }	 [DllImport("Shell32.dll", EntryPoint = "ExtractIconExW", CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]	 private static extern int ExtractIconEx(string sFile, int iIndex, out IntPtr piLargeVersion, out IntPtr piSmallVersion, int amountIcons);	}}"@

Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing


$ADACLGui.Window.Add_Loaded({
    $Global:observableCollection = New-Object System.Collections.ObjectModel.ObservableCollection[System.Object]
    $TextBoxStatusMessage.ItemsSource = $Global:observableCollection
})

if ($PSVersionTable.PSVersion -gt "2.0") 
{
if($psversiontable.clrversion.Major -ge 4)
{
try
{
Add-Type @"

    public class DelegateCommand : System.Windows.Input.ICommand

    {

        private System.Action<object> _action;

        public DelegateCommand(System.Action<object> action)

        {

            _action = action;

        }



        public bool CanExecute(object parameter)

        {

            return true;

        }



        public event System.EventHandler CanExecuteChanged = delegate { };



        public void Execute(object parameter)

        {

            _action(parameter);

        }

    }

"@
}catch
{}
}
}



Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class SFW {
     [DllImport("user32.dll")]
     [return: MarshalAs(UnmanagedType.Bool)]
     public static extern bool SetForegroundWindow(IntPtr hWnd);
  }
"@

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null



$chkBoxShowDel.add_Checked({
$global:bolShowDeleted= $true
})

$chkBoxShowDel.add_UnChecked({
$global:bolShowDeleted= $false
})

$btnDownloadCSVDefACLs.add_Click({
function GenerateForm {

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
#endregion

#region Generated Form Objects'
$formDefaultDACL = New-Object System.Windows.Forms.Form
$btnExit = New-Object System.Windows.Forms.Button
$lblHeader = New-Object System.Windows.Forms.Label
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
## START 2012 R2 ##
$linklabelDownloadCSVFile2012R2 = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2012R2Domain = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2012R2Config = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2012R2Schema = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2012R2DomainDNS = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2012R2ForestDNS = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2012R2AllFiles = New-Object System.Windows.Forms.LinkLabel
## END 2012 R2
## START 2012 ##
$linklabelDownloadCSVFile2012 = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2012Domain = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2012Config = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2012Schema = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2012DomainDNS = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2012ForestDNS = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2012AllFiles = New-Object System.Windows.Forms.LinkLabel
## END 2012
## START 2008 R2 ##
$linklabelDownloadCSVFile2008R2 = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2008R2Domain = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2008R2Config = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2008R2Schema = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2008R2DomainDNS = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2008R2ForestDNS = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2008R2AllFiles = New-Object System.Windows.Forms.LinkLabel
## END 2008 R2
## START 2003 ##
$linklabelDownloadCSVFile2003 = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2003Domain = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2003Config = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2003Schema = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2003DomainDNS = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2003ForestDNS = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2003AllFiles = New-Object System.Windows.Forms.LinkLabel
## END 2003
## START 2000 SP4 ##
$linklabelDownloadCSVFile2000SP4 = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2000SP4Domain = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2000SP4Config = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2000SP4Schema = New-Object System.Windows.Forms.LinkLabel
$linklabelDownloadCSVFile2000SP4AllFiles = New-Object System.Windows.Forms.LinkLabel
## END 2000 SP4
$gBox2012R2 = New-Object System.Windows.Forms.GroupBox
$gBox2012 = New-Object System.Windows.Forms.GroupBox
$gBox2008R2 = New-Object System.Windows.Forms.GroupBox
$gBox2003 = New-Object System.Windows.Forms.GroupBox
$gBox2000SP4 = New-Object System.Windows.Forms.GroupBox

$btnExit_OnClick= 
{
#TODO: Place custom script here
$formDefaultDACL.close()
}

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
	$formDefaultDACL.WindowState = $InitialFormWindowState
}
## START 2012 R2
$linklabelDownloadCSVFile2012R2_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!118&authkey=!AEsPNFM4NNDs-NY&ithint=file%2ccsv")
}

$linklabelDownloadCSVFile2012R2Domain_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!117&authkey=!ACGO_auHv7nVuFA&ithint=file%2ccsv")
}

$linklabelDownloadCSVFile2012R2Config_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!120&authkey=!AAUMJ01QN18vWz0&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2012R2Schema_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!119&authkey=!ACZnOYr_JsYL_1A&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2012R2DomainDNS_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!115&authkey=!ABibK0uHLccRXXE&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2012R2ForestDNS_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!116&authkey=!AN76snGTmVRqYUg&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2012R2AllFiles_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!134&authkey=!AJ9zhCQSjhPCiA4&ithint=file%2czip")
}
## END 2012 R2
## START 2012
$linklabelDownloadCSVFile2012_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!132&authkey=!AA1HBqNDu3g07YA&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2012Domain_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!127&authkey=!AFOrTjNj77zbe5M&ithint=file%2ccsv")
}

$linklabelDownloadCSVFile2012Config_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!128&authkey=!AIoukl1--XMqH0o&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2012Schema_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!129&authkey=!APUXZph0_yhzXns&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2012DomainDNS_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!130&authkey=!ABuBOH9pXKlgUo0&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2012ForestDNS_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!131&authkey=!AHmopj2Fc9L7pS4&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2012AllFiles_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!133&authkey=!AJhM8XTSi_eboFs&ithint=file%2czip")
}
## END 2012
## START 2008 R2
$linklabelDownloadCSVFile2008R2_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!157&authkey=!APMwORrenMZF2Dw&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2008R2Domain_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!140&authkey=!ALgAYQdynKvUZLs&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2008R2Config_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!158&authkey=!ACm5uljC8HQGU00&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2008R2Schema_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!158&authkey=!ACm5uljC8HQGU00&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2008R2DomainDNS_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!136&authkey=!AD_CYsd2dEM7Pf8&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2008R2ForestDNS_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!137&authkey=!AKXfX52VtuirzFw&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2008R2AllFiles_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!159&authkey=!AE4AIrkTKhM-Xcg&ithint=file%2czip")
}
## END 2008 R2
## START 2003

$linklabelDownloadCSVFile2003_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!150&authkey=!AF98uOT5coGagCQ&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2003Domain_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!147&authkey=!AA5j_FLH3sfAk5Q&ithint=file%2ccsv")
}

$linklabelDownloadCSVFile2003Config_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!148&authkey=!AE1-jkVztfOqIJw&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2003Schema_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!145&authkey=!AFa88cyZdDJsYVk&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2003DomainDNS_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!146&authkey=!AJ6CtlNI0he9OgM&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2003ForestDNS_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!144&authkey=!AKoTCcfQnKHYpMc&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2003AllFiles_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!160&authkey=!AEiUpr6LOCkiQ94&ithint=file%2czip")
}
## END 2003

## START 2000 SP4

$linklabelDownloadCSVFile2000SP4_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!152&authkey=!AKO49fQePeRrCKY&ithint=file%2ccsv")
}

$linklabelDownloadCSVFile2000SP4Domain_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!155&authkey=!AFGHVo-wCZoWXYw&ithint=file%2ccsv")
}

$linklabelDownloadCSVFile2000SP4Config_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!156&authkey=!AEoB4RiacNQci4s&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2000SP4Schema_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!154&authkey=!AHy8rar_9lJ8KQo&ithint=file%2ccsv")
}

$linklabelDownloadCSVFile2000SP4AllFiles_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!153&authkey=!AKsmuhvoig_CKfs&ithint=file%2czip")
}
## END 2000

#----------------------------------------------
#region Generated Form Code
$formDefaultDACL.Text = "CSV Templates"
$formDefaultDACL.Name = "form1"
$formDefaultDACL.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 650
$System_Drawing_Size.Height = 550
$formDefaultDACL.ClientSize = $System_Drawing_Size
$formDefaultDACL.add_Load($FormEvent_Load)
$formDefaultDACL.Icon = [System.Drawing.SystemIcons]::Information
$formDefaultDACL.StartPosition = "CenterScreen"

$lblHeader.TabIndex = 7
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 380
$System_Drawing_Size.Height = 20
$lblHeader.Size = $System_Drawing_Size
$lblHeader.Text = "Download Links for DACL CSV templates:"
$lblHeader.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 6
$lblHeader.Location = $System_Drawing_Point
$lblHeader.DataBindings.DefaultDataSourceUpdateMode = 0
$lblHeader.Name = "lblHeader"

$formDefaultDACL.Controls.Add($lblHeader)

$btnExit.TabIndex = 1
$btnExit.Name = "btnExit"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 75
$System_Drawing_Size.Height = 23
$btnExit.Size = $System_Drawing_Size
$btnExit.UseVisualStyleBackColor = $True
$btnExit.Text = "Close"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 460
$System_Drawing_Point.Y = 415
$btnExit.Location = $System_Drawing_Point
$btnExit.DataBindings.DefaultDataSourceUpdateMode = 0
$btnExit.add_Click($btnExit_OnClick)

$formDefaultDACL.Controls.Add($btnExit)

## START Group Box 2012 R2 ##

$gBox2012R2.TabIndex = 0
$gBox2012R2.Name = "gBoxNCSelect"
$gBox2012R2.Text = "Windows Server 2012 R2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 210
$System_Drawing_Size.Height = 200
$gBox2012R2.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 40
$gBox2012R2.Location = $System_Drawing_Point
$gBox2012R2.DataBindings.DefaultDataSourceUpdateMode = 0

$formDefaultDACL.Controls.Add($gBox2012R2)

$linklabelDownloadCSVFile2012R2.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012R2.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 25
$linklabelDownloadCSVFile2012R2.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012R2.Name = "linklabelDownloadCSVFile2012R2"
$linklabelDownloadCSVFile2012R2.Text = "Each NC root combined"
$linklabelDownloadCSVFile2012R2.add_LinkClicked($linklabelDownloadCSVFile2012R2_LinkClicked)
$gBox2012R2.Controls.Add($linklabelDownloadCSVFile2012R2)

$linklabelDownloadCSVFile2012R2Domain.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012R2Domain.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 50
$linklabelDownloadCSVFile2012R2Domain.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012R2Domain.Name = "linklabelDownloadCSVFile2012R2Domain"
$linklabelDownloadCSVFile2012R2Domain.Text = "Domain NC"
$linklabelDownloadCSVFile2012R2Domain.add_LinkClicked($linklabelDownloadCSVFile2012R2Domain_LinkClicked)
$gBox2012R2.Controls.Add($linklabelDownloadCSVFile2012R2Domain)

$linklabelDownloadCSVFile2012R2Schema.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012R2Schema.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 75
$linklabelDownloadCSVFile2012R2Schema.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012R2Schema.Name = "linklabelDownloadCSVFile2012R2Schema"
$linklabelDownloadCSVFile2012R2Schema.Text = "Schema NC"
$linklabelDownloadCSVFile2012R2Schema.add_LinkClicked($linklabelDownloadCSVFile2012R2Schema_LinkClicked)
$gBox2012R2.Controls.Add($linklabelDownloadCSVFile2012R2Schema)

$linklabelDownloadCSVFile2012R2Config.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012R2Config.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 100
$linklabelDownloadCSVFile2012R2Config.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012R2Config.Name = "linklabelDownloadCSVFile2012R2Config"
$linklabelDownloadCSVFile2012R2Config.Text = "Configration NC"
$linklabelDownloadCSVFile2012R2Config.add_LinkClicked($linklabelDownloadCSVFile2012R2Config_LinkClicked)
$gBox2012R2.Controls.Add($linklabelDownloadCSVFile2012R2Config)

$linklabelDownloadCSVFile2012R2ForestDNS.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012R2ForestDNS.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 125
$linklabelDownloadCSVFile2012R2ForestDNS.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012R2ForestDNS.Name = "linklabelDownloadCSVFile2012R2ForestDNS"
$linklabelDownloadCSVFile2012R2ForestDNS.Text = "Forest DNS Zone NC"
$linklabelDownloadCSVFile2012R2ForestDNS.add_LinkClicked($linklabelDownloadCSVFile2012R2ForestDNS_LinkClicked)
$gBox2012R2.Controls.Add($linklabelDownloadCSVFile2012R2ForestDNS)

$linklabelDownloadCSVFile2012R2DomainDNS.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012R2DomainDNS.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 150
$linklabelDownloadCSVFile2012R2DomainDNS.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012R2DomainDNS.Name = "linklabelDownloadCSVFile2012R2DomainDNS"
$linklabelDownloadCSVFile2012R2DomainDNS.Text = "Domain DNS Zone NC"
$linklabelDownloadCSVFile2012R2DomainDNS.add_LinkClicked($linklabelDownloadCSVFile2012R2DomainDNS_LinkClicked)
$gBox2012R2.Controls.Add($linklabelDownloadCSVFile2012R2DomainDNS)

$linklabelDownloadCSVFile2012R2AllFiles.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012R2AllFiles.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 175
$linklabelDownloadCSVFile2012R2AllFiles.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012R2AllFiles.Name = "linklabelDownloadCSVFile2012R2AllFiles"
$linklabelDownloadCSVFile2012R2AllFiles.Text = "All Files Compressed"
$linklabelDownloadCSVFile2012R2AllFiles.add_LinkClicked($linklabelDownloadCSVFile2012R2AllFiles_LinkClicked)
$gBox2012R2.Controls.Add($linklabelDownloadCSVFile2012R2AllFiles)

### END Group Box 2012 R2 ##
## START Group Box 2012  ##

$gBox2012.TabIndex = 0
$gBox2012.Name = "gBox2012"
$gBox2012.Text = "Windows Server 2012"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 210
$System_Drawing_Size.Height = 200
$gBox2012.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 220
$System_Drawing_Point.Y = 40
$gBox2012.Location = $System_Drawing_Point
$gBox2012.DataBindings.DefaultDataSourceUpdateMode = 0

$formDefaultDACL.Controls.Add($gBox2012)

$linklabelDownloadCSVFile2012.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 25
$linklabelDownloadCSVFile2012.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012.Name = "linklabelDownloadCSVFile2012"
$linklabelDownloadCSVFile2012.Text = "Each NC root combined"
$linklabelDownloadCSVFile2012.add_LinkClicked($linklabelDownloadCSVFile2012_LinkClicked)
$gBox2012.Controls.Add($linklabelDownloadCSVFile2012)

$linklabelDownloadCSVFile2012Domain.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012Domain.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 50
$linklabelDownloadCSVFile2012Domain.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012Domain.Name = "linklabelDownloadCSVFile2012Domain"
$linklabelDownloadCSVFile2012Domain.Text = "Domain NC"
$linklabelDownloadCSVFile2012Domain.add_LinkClicked($linklabelDownloadCSVFile2012Domain_LinkClicked)
$gBox2012.Controls.Add($linklabelDownloadCSVFile2012Domain)

$linklabelDownloadCSVFile2012Schema.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012Schema.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 75
$linklabelDownloadCSVFile2012Schema.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012Schema.Name = "linklabelDownloadCSVFile2012Schema"
$linklabelDownloadCSVFile2012Schema.Text = "Schema NC"
$linklabelDownloadCSVFile2012Schema.add_LinkClicked($linklabelDownloadCSVFile2012Schema_LinkClicked)
$gBox2012.Controls.Add($linklabelDownloadCSVFile2012Schema)

$linklabelDownloadCSVFile2012Config.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012Config.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 100
$linklabelDownloadCSVFile2012Config.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012Config.Name = "linklabelDownloadCSVFile2012Config"
$linklabelDownloadCSVFile2012Config.Text = "Configration NC"
$linklabelDownloadCSVFile2012Config.add_LinkClicked($linklabelDownloadCSVFile2012Config_LinkClicked)
$gBox2012.Controls.Add($linklabelDownloadCSVFile2012Config)

$linklabelDownloadCSVFile2012ForestDNS.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012ForestDNS.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 125
$linklabelDownloadCSVFile2012ForestDNS.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012ForestDNS.Name = "linklabelDownloadCSVFile2012ForestDNS"
$linklabelDownloadCSVFile2012ForestDNS.Text = "Forest DNS Zone NC"
$linklabelDownloadCSVFile2012ForestDNS.add_LinkClicked($linklabelDownloadCSVFile2012ForestDNS_LinkClicked)
$gBox2012.Controls.Add($linklabelDownloadCSVFile2012ForestDNS)

$linklabelDownloadCSVFile2012DomainDNS.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012DomainDNS.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 150
$linklabelDownloadCSVFile2012DomainDNS.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012DomainDNS.Name = "linklabelDownloadCSVFile2012DomainDNS"
$linklabelDownloadCSVFile2012DomainDNS.Text = "Domain DNS Zone NC"
$linklabelDownloadCSVFile2012DomainDNS.add_LinkClicked($linklabelDownloadCSVFile2012DomainDNS_LinkClicked)
$gBox2012.Controls.Add($linklabelDownloadCSVFile2012DomainDNS)

$linklabelDownloadCSVFile2012AllFiles.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012AllFiles.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 175
$linklabelDownloadCSVFile2012AllFiles.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012AllFiles.Name = "linklabelDownloadCSVFile2012AllFiles"
$linklabelDownloadCSVFile2012AllFiles.Text = "All Files Compressed"
$linklabelDownloadCSVFile2012AllFiles.add_LinkClicked($linklabelDownloadCSVFile2012AllFiles_LinkClicked)
$gBox2012.Controls.Add($linklabelDownloadCSVFile2012AllFiles)

### END Group Box 2012 ##

## START Group Box 2008 R2  ##

$gBox2008R2.TabIndex = 0
$gBox2008R2.Name = "gBox2008R2"
$gBox2008R2.Text = "Windows Server 2008 R2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 210
$System_Drawing_Size.Height = 200
$gBox2008R2.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 435
$System_Drawing_Point.Y = 40
$gBox2008R2.Location = $System_Drawing_Point
$gBox2008R2.DataBindings.DefaultDataSourceUpdateMode = 0

$formDefaultDACL.Controls.Add($gBox2008R2)

$linklabelDownloadCSVFile2008R2.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2008R2.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 25
$linklabelDownloadCSVFile2008R2.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2008R2.Name = "linklabelDownloadCSVFile2008R2"
$linklabelDownloadCSVFile2008R2.Text = "Each NC root combined"
$linklabelDownloadCSVFile2008R2.add_LinkClicked($linklabelDownloadCSVFile2008R2_LinkClicked)
$gBox2008R2.Controls.Add($linklabelDownloadCSVFile2008R2)

$linklabelDownloadCSVFile2008R2Domain.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2008R2Domain.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 50
$linklabelDownloadCSVFile2008R2Domain.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2008R2Domain.Name = "linklabelDownloadCSVFile2008R2Domain"
$linklabelDownloadCSVFile2008R2Domain.Text = "Domain NC"
$linklabelDownloadCSVFile2008R2Domain.add_LinkClicked($linklabelDownloadCSVFile2008R2Domain_LinkClicked)
$gBox2008R2.Controls.Add($linklabelDownloadCSVFile2008R2Domain)

$linklabelDownloadCSVFile2008R2Schema.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2008R2Schema.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 75
$linklabelDownloadCSVFile2008R2Schema.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2008R2Schema.Name = "linklabelDownloadCSVFile2008R2Schema"
$linklabelDownloadCSVFile2008R2Schema.Text = "Schema NC"
$linklabelDownloadCSVFile2008R2Schema.add_LinkClicked($linklabelDownloadCSVFile2008R2Schema_LinkClicked)
$gBox2008R2.Controls.Add($linklabelDownloadCSVFile2008R2Schema)

$linklabelDownloadCSVFile2008R2Config.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2008R2Config.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 100
$linklabelDownloadCSVFile2008R2Config.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2008R2Config.Name = "linklabelDownloadCSVFile2008R2Config"
$linklabelDownloadCSVFile2008R2Config.Text = "Configration NC"
$linklabelDownloadCSVFile2008R2Config.add_LinkClicked($linklabelDownloadCSVFile2008R2Config_LinkClicked)
$gBox2008R2.Controls.Add($linklabelDownloadCSVFile2008R2Config)

$linklabelDownloadCSVFile2008R2ForestDNS.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2008R2ForestDNS.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 125
$linklabelDownloadCSVFile2008R2ForestDNS.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2008R2ForestDNS.Name = "linklabelDownloadCSVFile2008R2ForestDNS"
$linklabelDownloadCSVFile2008R2ForestDNS.Text = "Forest DNS Zone NC"
$linklabelDownloadCSVFile2008R2ForestDNS.add_LinkClicked($linklabelDownloadCSVFile2008R2ForestDNS_LinkClicked)
$gBox2008R2.Controls.Add($linklabelDownloadCSVFile2008R2ForestDNS)

$linklabelDownloadCSVFile2008R2DomainDNS.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2008R2DomainDNS.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 150
$linklabelDownloadCSVFile2008R2DomainDNS.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2008R2DomainDNS.Name = "linklabelDownloadCSVFile2008R2DomainDNS"
$linklabelDownloadCSVFile2008R2DomainDNS.Text = "Domain DNS Zone NC"
$linklabelDownloadCSVFile2008R2DomainDNS.add_LinkClicked($linklabelDownloadCSVFile2008R2DomainDNS_LinkClicked)
$gBox2008R2.Controls.Add($linklabelDownloadCSVFile2008R2DomainDNS)

$linklabelDownloadCSVFile2008R2AllFiles.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2008R2AllFiles.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 175
$linklabelDownloadCSVFile2008R2AllFiles.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2008R2AllFiles.Name = "linklabelDownloadCSVFile2008R2AllFiles"
$linklabelDownloadCSVFile2008R2AllFiles.Text = "All Files Compressed"
$linklabelDownloadCSVFile2008R2AllFiles.add_LinkClicked($linklabelDownloadCSVFile2008R2AllFiles_LinkClicked)
$gBox2008R2.Controls.Add($linklabelDownloadCSVFile2008R2AllFiles)

### END Group Box 2008 R2 ##

## START Group Box 2003  ##

$gBox2003.TabIndex = 0
$gBox2003.Name = "gBox2003"
$gBox2003.Text = "Windows Server 2003"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 210
$System_Drawing_Size.Height = 200
$gBox2003.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 240
$gBox2003.Location = $System_Drawing_Point
$gBox2003.DataBindings.DefaultDataSourceUpdateMode = 0

$formDefaultDACL.Controls.Add($gBox2003)

$linklabelDownloadCSVFile2003.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2003.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 25
$linklabelDownloadCSVFile2003.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2003.Name = "linklabelDownloadCSVFile2003"
$linklabelDownloadCSVFile2003.Text = "Each NC root combined"
$linklabelDownloadCSVFile2003.add_LinkClicked($linklabelDownloadCSVFile2003_LinkClicked)
$gBox2003.Controls.Add($linklabelDownloadCSVFile2003)

$linklabelDownloadCSVFile2003Domain.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2003Domain.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 50
$linklabelDownloadCSVFile2003Domain.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2003Domain.Name = "linklabelDownloadCSVFile2003Domain"
$linklabelDownloadCSVFile2003Domain.Text = "Domain NC"
$linklabelDownloadCSVFile2003Domain.add_LinkClicked($linklabelDownloadCSVFile2003Domain_LinkClicked)
$gBox2003.Controls.Add($linklabelDownloadCSVFile2003Domain)

$linklabelDownloadCSVFile2003Schema.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2003Schema.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 75
$linklabelDownloadCSVFile2003Schema.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2003Schema.Name = "linklabelDownloadCSVFile2003Schema"
$linklabelDownloadCSVFile2003Schema.Text = "Schema NC"
$linklabelDownloadCSVFile2003Schema.add_LinkClicked($linklabelDownloadCSVFile2003Schema_LinkClicked)
$gBox2003.Controls.Add($linklabelDownloadCSVFile2003Schema)

$linklabelDownloadCSVFile2003Config.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2003Config.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 100
$linklabelDownloadCSVFile2003Config.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2003Config.Name = "linklabelDownloadCSVFile2003Config"
$linklabelDownloadCSVFile2003Config.Text = "Configration NC"
$linklabelDownloadCSVFile2003Config.add_LinkClicked($linklabelDownloadCSVFile2003Config_LinkClicked)
$gBox2003.Controls.Add($linklabelDownloadCSVFile2003Config)

$linklabelDownloadCSVFile2003ForestDNS.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2003ForestDNS.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 125
$linklabelDownloadCSVFile2003ForestDNS.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2003ForestDNS.Name = "linklabelDownloadCSVFile2003ForestDNS"
$linklabelDownloadCSVFile2003ForestDNS.Text = "Forest DNS Zone NC"
$linklabelDownloadCSVFile2003ForestDNS.add_LinkClicked($linklabelDownloadCSVFile2003ForestDNS_LinkClicked)
$gBox2003.Controls.Add($linklabelDownloadCSVFile2003ForestDNS)

$linklabelDownloadCSVFile2003DomainDNS.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2003DomainDNS.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 150
$linklabelDownloadCSVFile2003DomainDNS.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2003DomainDNS.Name = "linklabelDownloadCSVFile2003DomainDNS"
$linklabelDownloadCSVFile2003DomainDNS.Text = "Domain DNS Zone NC"
$linklabelDownloadCSVFile2003DomainDNS.add_LinkClicked($linklabelDownloadCSVFile2003DomainDNS_LinkClicked)
$gBox2003.Controls.Add($linklabelDownloadCSVFile2003DomainDNS)

$linklabelDownloadCSVFile2003AllFiles.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2003AllFiles.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 175
$linklabelDownloadCSVFile2003AllFiles.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2003AllFiles.Name = "linklabelDownloadCSVFile2003AllFiles"
$linklabelDownloadCSVFile2003AllFiles.Text = "All Files Compressed"
$linklabelDownloadCSVFile2003AllFiles.add_LinkClicked($linklabelDownloadCSVFile2003AllFiles_LinkClicked)
$gBox2003.Controls.Add($linklabelDownloadCSVFile2003AllFiles)

### END Group Box 2003##

## START Group Box 2000 Sp4  ##

$gBox2000SP4.TabIndex = 0
$gBox2000SP4.Name = "gBox2000SP4"
$gBox2000SP4.Text = "Windows Server 2000 SP4"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 210
$System_Drawing_Size.Height = 200
$gBox2000SP4.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 220
$System_Drawing_Point.Y = 240
$gBox2000SP4.Location = $System_Drawing_Point
$gBox2000SP4.DataBindings.DefaultDataSourceUpdateMode = 0

$formDefaultDACL.Controls.Add($gBox2000SP4)

$linklabelDownloadCSVFile2000SP4.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2000SP4.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 25
$linklabelDownloadCSVFile2000SP4.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2000SP4.Name = "linklabelDownloadCSVFile2000SP4"
$linklabelDownloadCSVFile2000SP4.Text = "Each NC root combined"
$linklabelDownloadCSVFile2000SP4.add_LinkClicked($linklabelDownloadCSVFile2000SP4_LinkClicked)
$gBox2000SP4.Controls.Add($linklabelDownloadCSVFile2000SP4)

$linklabelDownloadCSVFile2000SP4Domain.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2000SP4Domain.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 50
$linklabelDownloadCSVFile2000SP4Domain.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2000SP4Domain.Name = "linklabelDownloadCSVFile2000SP4Domain"
$linklabelDownloadCSVFile2000SP4Domain.Text = "Domain NC"
$linklabelDownloadCSVFile2000SP4Domain.add_LinkClicked($linklabelDownloadCSVFile2000SP4Domain_LinkClicked)
$gBox2000SP4.Controls.Add($linklabelDownloadCSVFile2000SP4Domain)

$linklabelDownloadCSVFile2000SP4Schema.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2000SP4Schema.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 75
$linklabelDownloadCSVFile2000SP4Schema.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2000SP4Schema.Name = "linklabelDownloadCSVFile2000SP4Schema"
$linklabelDownloadCSVFile2000SP4Schema.Text = "Schema NC"
$linklabelDownloadCSVFile2000SP4Schema.add_LinkClicked($linklabelDownloadCSVFile2000SP4Schema_LinkClicked)
$gBox2000SP4.Controls.Add($linklabelDownloadCSVFile2000SP4Schema)

$linklabelDownloadCSVFile2000SP4Config.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2000SP4Config.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 100
$linklabelDownloadCSVFile2000SP4Config.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2000SP4Config.Name = "linklabelDownloadCSVFile2000SP4Config"
$linklabelDownloadCSVFile2000SP4Config.Text = "Configration NC"
$linklabelDownloadCSVFile2000SP4Config.add_LinkClicked($linklabelDownloadCSVFile2000SP4Config_LinkClicked)
$gBox2000SP4.Controls.Add($linklabelDownloadCSVFile2000SP4Config)

$linklabelDownloadCSVFile2000SP4AllFiles.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 150
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2000SP4AllFiles.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 125
$linklabelDownloadCSVFile2000SP4AllFiles.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2000SP4AllFiles.Name = "linklabelDownloadCSVFile2000SP4AllFiles"
$linklabelDownloadCSVFile2000SP4AllFiles.Text = "All Files Compressed"
$linklabelDownloadCSVFile2000SP4AllFiles.add_LinkClicked($linklabelDownloadCSVFile2000SP4AllFiles_LinkClicked)
$gBox2000SP4.Controls.Add($linklabelDownloadCSVFile2000SP4AllFiles)

### END Group Box 2000 SP 4##


#endregion Generated Form Code

#Save the initial state of the form
$formDefaultDACL.WindowState = $InitialFormWindowState
#Init the OnLoad event to correct the initial state of the form
$formDefaultDACL.add_Load($OnLoadForm_StateCorrection)
#Show the Form

$formDefaultDACL.Add_Shown({$formDefaultDACL.Activate()})

$formDefaultDACL.ShowDialog()| Out-Null

} #End Function
##Call the Function
GenerateForm


})

$btnDownloadCSVDefSD.add_Click({
function GenerateForm {

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
#endregion

#region Generated Form Objects'
$formDefaultSD = New-Object System.Windows.Forms.Form
$btnExit = New-Object System.Windows.Forms.Button
$lblHeader = New-Object System.Windows.Forms.Label
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
$linklabelDownloadCSVFile2012R2 = New-Object 'System.Windows.Forms.LinkLabel'
$linklabelDownloadCSVFile2012 = New-Object 'System.Windows.Forms.LinkLabel'
$linklabelDownloadCSVFile2008R2 = New-Object 'System.Windows.Forms.LinkLabel'
$linklabelDownloadCSVFile2003 = New-Object 'System.Windows.Forms.LinkLabel'
$linklabelDownloadCSVFile2000SP4 = New-Object 'System.Windows.Forms.LinkLabel'

$btnExit_OnClick= 
{
#TODO: Place custom script here
$formDefaultSD.close()
}

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
	$formDefaultSD.WindowState = $InitialFormWindowState
}

$linklabelDownloadCSVFile2012R2_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!108&authkey=!AH2bxltG5s-l3YY&ithint=file%2ccsv")
}
$linklabelDownloadCSVFile2012_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!111&authkey=!APeksydtWJ9B1Fc&ithint=file%2ccsv")
}

$linklabelDownloadCSVFile2008R2_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!110&authkey=!AKYYkARRfsC7IyM&ithint=file%2ccsv")
}

$linklabelDownloadCSVFile2003_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!109&authkey=!AKZcScjykAZr9sw&ithint=file%2ccsv")
}

$linklabelDownloadCSVFile2000SP4_LinkClicked=[System.Windows.Forms.LinkLabelLinkClickedEventHandler]{
[System.Diagnostics.Process]::Start("https://onedrive.live.com/download?resid=3FC56366F033BAA9!112&authkey=!ACo2xB2BHPYSkOE&ithint=file%2ccsv")
}

#----------------------------------------------
#region Generated Form Code
$formDefaultSD.Text = "CSV Templates"
$formDefaultSD.Name = "form1"
$formDefaultSD.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 370
$System_Drawing_Size.Height = 200
$formDefaultSD.ClientSize = $System_Drawing_Size
$formDefaultSD.add_Load($FormEvent_Load)
$formDefaultSD.Icon = [System.Drawing.SystemIcons]::Information
$formDefaultSD.StartPosition = "CenterScreen"


$btnExit.TabIndex = 1
$btnExit.Name = "btnExit"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 75
$System_Drawing_Size.Height = 23
$btnExit.Size = $System_Drawing_Size
$btnExit.UseVisualStyleBackColor = $True
$btnExit.Text = "Close"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 150
$System_Drawing_Point.Y = 170
$btnExit.Location = $System_Drawing_Point
$btnExit.DataBindings.DefaultDataSourceUpdateMode = 0
$btnExit.add_Click($btnExit_OnClick)

$formDefaultSD.Controls.Add($btnExit)

$btnExit.TabIndex = 2
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 300
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012R2.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 25
$linklabelDownloadCSVFile2012R2.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012R2.Name = "linklabelDownloadCSVFile2012R2"
$linklabelDownloadCSVFile2012R2.Text = "Windows Server 2012 R2"
$linklabelDownloadCSVFile2012R2.add_LinkClicked($linklabelDownloadCSVFile2012R2_LinkClicked)
$formDefaultSD.Controls.Add($linklabelDownloadCSVFile2012R2)

$btnExit.TabIndex = 3
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 300
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2012.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 50
$linklabelDownloadCSVFile2012.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2012.Name = "linklabelDownloadCSVFile2012"
$linklabelDownloadCSVFile2012.Text = "Windows Server 2012"
$linklabelDownloadCSVFile2012.add_LinkClicked($linklabelDownloadCSVFile2012_LinkClicked)
$formDefaultSD.Controls.Add($linklabelDownloadCSVFile2012)

$btnExit.TabIndex = 4
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 350
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2008R2.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 75
$linklabelDownloadCSVFile2008R2.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2008R2.Name = "linklabelDownloadCSVFile2008R2"
$linklabelDownloadCSVFile2008R2.Text = "Windows Server 2008 R2"
$linklabelDownloadCSVFile2008R2.add_LinkClicked($linklabelDownloadCSVFile2008R2_LinkClicked)
$formDefaultSD.Controls.Add($linklabelDownloadCSVFile2008R2)

$btnExit.TabIndex = 5
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 300
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2003.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 100
$linklabelDownloadCSVFile2003.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2003.Name = "linklabelDownloadCSVFile2003"
$linklabelDownloadCSVFile2003.Text = "Windows Server 2003"
$linklabelDownloadCSVFile2003.add_LinkClicked($linklabelDownloadCSVFile2003_LinkClicked)
$formDefaultSD.Controls.Add($linklabelDownloadCSVFile2003)

$btnExit.TabIndex = 6
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 300
$System_Drawing_Size.Height = 23
$linklabelDownloadCSVFile2000SP4.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 125
$linklabelDownloadCSVFile2000SP4.Location = $System_Drawing_Point
$linklabelDownloadCSVFile2000SP4.Name = "linklabelDownloadCSVFile2000SP4"
$linklabelDownloadCSVFile2000SP4.Text = "Windows Server 2000 SP4"
$linklabelDownloadCSVFile2000SP4.add_LinkClicked($linklabelDownloadCSVFile2000SP4_LinkClicked)
$formDefaultSD.Controls.Add($linklabelDownloadCSVFile2000SP4)

$lblHeader.TabIndex = 7
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 380
$System_Drawing_Size.Height = 20
$lblHeader.Size = $System_Drawing_Size
$lblHeader.Text = "Download Links for defaultSecuritydescriptor CSV templates:"
$lblHeader.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 5
$System_Drawing_Point.Y = 6
$lblHeader.Location = $System_Drawing_Point
$lblHeader.DataBindings.DefaultDataSourceUpdateMode = 0
$lblHeader.Name = "lblHeader"

$formDefaultSD.Controls.Add($lblHeader)

#endregion Generated Form Code

#Save the initial state of the form
$formDefaultSD.WindowState = $InitialFormWindowState
#Init the OnLoad event to correct the initial state of the form
$formDefaultSD.add_Load($OnLoadForm_StateCorrection)
#Show the Form

$formDefaultSD.Add_Shown({$formDefaultSD.Activate()})

$formDefaultSD.ShowDialog()| Out-Null

} #End Function
##Call the Function
GenerateForm


})

$btnGetForestInfo.add_Click({

    if ($global:bolConnected -eq $true)
    {
        Get-SchemaData $global:CREDS
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Information collected!" -strType "Info" -DateStamp ))
    }
        else
    {
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Connect to your naming context first!" -strType "Error" -DateStamp ))
    }  
})

$btnClearExcludedBox.add_Click({
$txtBoxExcluded.text = ""

})
$btnGetSchemaClass.add_Click(
{

    if ($global:bolConnected -eq $true)
    {
        

        $PageSize=100
        $TimeoutSeconds = 120

        $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
        $LDAPConnection.SessionOptions.ReferralChasing = "None"
        $request = New-Object System.directoryServices.Protocols.SearchRequest("$global:SchemaDN", "(objectClass=classSchema)", "Subtree")
        [System.DirectoryServices.Protocols.PageResultRequestControl]$pagedRqc = new-object System.DirectoryServices.Protocols.PageResultRequestControl($pageSize)
        $request.Controls.Add($pagedRqc) | Out-Null
        [void]$request.Attributes.Add("name")
        $response = $LDAPConnection.SendRequest($request)
        $arrSchemaObjects = New-Object System.Collections.ArrayList
        while ($true)
        {
            $response = $LdapConnection.SendRequest($request, (new-object System.Timespan(0,0,$TimeoutSeconds))) -as [System.DirectoryServices.Protocols.SearchResponse];
                
            #for paged search, the response for paged search result control - we will need a cookie from result later
            if($pageSize -gt 0) {
                [System.DirectoryServices.Protocols.PageResultResponseControl] $prrc=$null;
                if ($response.Controls.Length -gt 0)
                {
                    foreach ($ctrl in $response.Controls)
                    {
                        if ($ctrl -is [System.DirectoryServices.Protocols.PageResultResponseControl])
                        {
                            $prrc = $ctrl;
                            break;
                        }
                    }
                }
                if($null-eq $prrc) {
                    #server was unable to process paged search
                    throw "Find-LdapObject: Server failed to return paged response for request $SearchFilter"
                }
            }
            #now process the returned list of distinguishedNames and fetch required properties using ranged retrieval
            $colResults = $response.Entries
	        foreach ($objResult in $colResults)
	        {             
		        [void]$arrSchemaObjects.Add($objResult.attributes.name[0])


            }
            if($pageSize -gt 0) {
                if ($prrc.Cookie.Length -eq 0) {
                    #last page --> we're done
                    break;
                }
                #pass the search cookie back to server in next paged request
                $pagedRqc.Cookie = $prrc.Cookie;
            } else {
                #exit the processing for non-paged search
                break;
            }
        }#End While
        $arrSchemaObjects.Sort()
        foreach ($object in $arrSchemaObjects)
        {
            [void]$combObjectDefSD.Items.Add($object)
        }
        $global:observableCollection.Insert(0,(LogMessage -strMessage "All classSchema collected!" -strType "Info" -DateStamp ))
        $object = $null
        Remove-Variable object
        $arrSchemaObjects = $null
        Remove-Variable arrSchemaObjects
    }
        else
    {
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Connect to your naming context first!" -strType "Error" -DateStamp ))
    }  
})



$btnExportDefSD.add_Click(
{
    $global:bolProgressBar = $chkBoxSkipProgressBar.IsChecked
    if ($global:bolConnected -eq $true)
    {
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Scanning..." -strType "Info" -DateStamp ))
        $strFileCSV = $txtTempFolder.Text + "\" +$global:strDomainShortName + "_DefaultSecDescriptor" + $date + ".csv" 
        Write-DefaultSDCSV $strFileCSV
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Finished" -strType "Info" -DateStamp ))
    }
        else
    {
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Connect to your naming context first!" -strType "Error" -DateStamp ))
    }  

})

$btnCompDefSD.add_Click(
{
    $global:bolProgressBar = $chkBoxSkipProgressBar.IsChecked
    if ($global:bolConnected -eq $true)
    {
 
        if ($txtCompareDefSDTemplate.Text -eq "")
        {
            $global:observableCollection.Insert(0,(LogMessage -strMessage "No Template CSV file selected!" -strType "Error" -DateStamp ))
        }
        else
        {
            $global:bolProgressBar = $chkBoxSkipProgressBar.IsChecked
            $global:bolDefaultSDCSVLoaded = $false
            $strDefaultSDCompareFile = $txtCompareDefSDTemplate.Text
            &{#Try
                $global:bolDefaultSDCSVLoaded = $true
                $global:csvdefSDTemplate = import-Csv $strDefaultSDCompareFile 
            }
            Trap [SystemException]
            {
                $strCSVErr = $_.Exception.Message
                $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed to load CSV. $strCSVErr" -strType "Error" -DateStamp ))
                $global:bolDefaultSDCSVLoaded = $false
                continue
            }
            if($bolDefaultSDCSVLoaded)
            {
                if(TestCSVColumnsDefaultSD $global:csvdefSDTemplate)            
                {
                    $strSelectedItem = $combObjectDefSD.SelectedItem
                    if($strSelectedItem -eq "All Objects")
                    {
                        $strSelectedItem = "*"
                    }
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Scanning..." -strType "Info" -DateStamp ))
                    Get-DefaultSDCompare $strSelectedItem $strDefaultSDCompareFile
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Finished" -strType "Info" -DateStamp ))
                }
                else
                {
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "CSV file got wrong format! File:  $strDefaultSDCompareFile" -strType "Error" -DateStamp ))
                } #End if test column names exist 
            }
        }#end if txtCompareDefSDTemplate.Text is empty

    }
        else
    {
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Connect to your naming context first!" -strType "Error" -DateStamp ))
    } 
})

$btnScanDefSD.add_Click(
{
    $global:bolProgressBar = $chkBoxSkipProgressBar.IsChecked

    if ($global:bolConnected -eq $true)
    {
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Scanning..." -strType "Info" -DateStamp ))

        $strSelectedItem = $combObjectDefSD.SelectedItem
        if($strSelectedItem -eq "All Objects")
        {
            $strSelectedItem = "*"
        }
        Get-DefaultSD $strSelectedItem $chkModifedDefSD.IsChecked $rdbDefSD_SDDL.IsChecked
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Finished" -strType "Info" -DateStamp ))

    }
        else
    {
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Connect to your naming context first!" -strType "Error" -DateStamp ))
    }        
   


})
$btnGETSPNReport.add_Click(
{
        If(($global:strEffectiveRightSP -ne "") -and  ($global:tokens.count -gt 0))
    {
        
        $strFileSPNHTA = $env:temp + "\SPNHTML.hta" 
	    $strFileSPNHTM = $env:temp + "\"+"$global:strEffectiveRightAccount"+".htm" 
        CreateServicePrincipalReportHTA $global:strEffectiveRightSP $strFileSPNHTA $strFileSPNHTM $CurrentFSPath
        CreateSPNHTM $global:strEffectiveRightSP $strFileSPNHTM
        InitiateSPNHTM $strFileSPNHTA 
        $strColorTemp = 1
        WriteSPNHTM $global:strEffectiveRightSP $global:tokens $global:strSPNobjectClass $($global:tokens.count-1) $strColorTemp $strFileSPNHTA $strFileSPNHTM
        Invoke-Item $strFileSPNHTA 
    }
    else
    {
        $global:observableCollection.Insert(0,(LogMessage -strMessage "No service principal selected!" -strType "Error" -DateStamp ))

    }
})

$btnViewLegend.add_Click(
{
    
        $strFileLegendHTA = $env:temp + "\LegendHTML.hta"

        CreateColorLegenedReportHTA $strFileLegendHTA 
        Invoke-Item $strFileLegendHTA 

})

$btnGetSPAccount.add_Click(
{

    if ($global:bolConnected -eq $true)
    {

        If (!($txtBoxSelectPrincipal.Text -eq ""))
        {
            GetEffectiveRightSP $txtBoxSelectPrincipal.Text $global:strDomainPrinDNName
        }
        else
        {
            $global:observableCollection.Insert(0,(LogMessage -strMessage "Enter a principal name!" -strType "Error" -DateStamp ))
        }
    }
        else
    {
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Connect to your naming context first!" -strType "Error" -DateStamp ))
    }
})



$btnListDdomain.add_Click(
{

GenerateDomainPicker

$txtBoxDomainConnect.Text = $global:strDommainSelect

})

$btnListLocations.add_Click(
{

    if ($global:bolConnected -eq $true)
    {
        GenerateTrustedDomainPicker
    }
        else
    {
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Connect to your naming context first!" -strType "Error" -DateStamp ))
    }
})


$chkBoxScanUsingUSN.add_Click(
{
    If($chkBoxScanUsingUSN.IsChecked)
    {
        $global:bolTempValue_chkBoxReplMeta = $chkBoxReplMeta.IsChecked
        $chkBoxReplMeta.IsChecked = $true
        
    }
    else
    {
        if ($null -ne $global:bolTempValue_chkBoxReplMeta)
        {
         $chkBoxReplMeta.IsChecked = $global:bolTempValue_chkBoxReplMeta
        }
      
    }
})

$chkBoxCompare.add_Click(
{
    If($chkBoxCompare.IsChecked)
    {
        if ($null -ne $global:bolTempValue_InhertiedChkBox)
        {
        $chkInheritedPerm.IsChecked = $global:bolTempValue_InhertiedChkBox
        }
       
        if ($null -ne $global:bolTempValue_chkBoxGetOwner)
        {
        $chkBoxGetOwner.IsChecked = $global:bolTempValue_chkBoxGetOwner
        }

        $chkInheritedPerm.IsEnabled = $true
        $chkBoxGetOwner.IsEnabled = $true
        #Activate Compare Objects
        $txtCompareTemplate.IsEnabled = $true
        $chkBoxTemplateNodes.IsEnabled = $true
        $chkBoxScanUsingUSN.IsEnabled = $true
        $btnGetCompareInput.IsEnabled = $true
        $txtReplaceDN.IsEnabled = $true
        $txtReplaceNetbios.IsEnabled = $true

        #Deactivate Effective Rights and Filter objects
        $chkBoxFilter.IsChecked = $false
        $chkBoxEffectiveRights.IsChecked = $false
        $txtBoxSelectPrincipal.IsEnabled = $false
        $btnGetSPAccount.IsEnabled = $false
        $btnListLocations.IsEnabled = $false
        $btnGETSPNReport.IsEnabled = $false
        $chkBoxType.IsEnabled = $false
        $chkBoxObject.IsEnabled = $false
        $chkBoxTrustee.IsEnabled =  $false
        $chkBoxType.IsChecked = $false
        $chkBoxObject.IsChecked = $false
        $chkBoxTrustee.IsChecked =  $false
        $combObjectFilter.IsEnabled = $false
        $txtFilterTrustee.IsEnabled = $false
        $combAccessCtrl.IsEnabled = $false
        $btnGetObjFullFilter.IsEnabled = $false
        
    }
    else
    {
        #Deactivate Compare Objects
        $txtCompareTemplate.IsEnabled = $false
        $chkBoxTemplateNodes.IsEnabled = $false
        $chkBoxScanUsingUSN.IsEnabled = $false
        $btnGetCompareInput.IsEnabled = $false
        $txtReplaceDN.IsEnabled = $false
        $txtReplaceNetbios.IsEnabled = $false        
    }

})
$chkBoxEffectiveRights.add_Click(
{
    If($chkBoxEffectiveRights.IsChecked)
    {
    
        $global:bolTempValue_InhertiedChkBox = $chkInheritedPerm.IsChecked
        $global:bolTempValue_chkBoxGetOwner = $chkBoxGetOwner.IsChecked
        $chkBoxFilter.IsChecked = $false

        #Deactivate Compare Objects
        $chkBoxCompare.IsChecked = $false
        $txtCompareTemplate.IsEnabled = $false
        $chkBoxTemplateNodes.IsEnabled = $false
        $chkBoxScanUsingUSN.IsEnabled = $false
        $btnGetCompareInput.IsEnabled = $false
        $txtReplaceDN.IsEnabled = $false
        $txtReplaceNetbios.IsEnabled = $false        

        $txtBoxSelectPrincipal.IsEnabled = $true
        $btnGetSPAccount.IsEnabled = $true
        $btnListLocations.IsEnabled = $true
        $btnGETSPNReport.IsEnabled = $true
        $chkInheritedPerm.IsEnabled = $false
        $chkInheritedPerm.IsChecked = $true
        $chkBoxGetOwner.IsEnabled = $false
        $chkBoxGetOwner.IsChecked= $true
  
        $chkBoxType.IsEnabled = $false
        $chkBoxObject.IsEnabled = $false
        $chkBoxTrustee.IsEnabled =  $false
        $chkBoxType.IsChecked = $false
        $chkBoxObject.IsChecked = $false
        $chkBoxTrustee.IsChecked =  $false
        $combObjectFilter.IsEnabled = $false
        $txtFilterTrustee.IsEnabled = $false
        $combAccessCtrl.IsEnabled = $false
        $btnGetObjFullFilter.IsEnabled = $false
        
    }
    else
    {

     $txtBoxSelectPrincipal.IsEnabled = $false
     $btnGetSPAccount.IsEnabled = $false
     $btnListLocations.IsEnabled = $false
     $btnGETSPNReport.IsEnabled = $false
     $chkInheritedPerm.IsEnabled = $true
     $chkInheritedPerm.IsChecked = $global:bolTempValue_InhertiedChkBox
    $chkBoxGetOwner.IsEnabled = $true
    $chkBoxGetOwner.IsChecked = $global:bolTempValue_chkBoxGetOwner
    }

})


$chkBoxFilter.add_Click(
{


    If($chkBoxFilter.IsChecked -eq $true)
    {
        #Deactivate Compare Objects
        $chkBoxCompare.IsChecked = $false
        $txtCompareTemplate.IsEnabled = $false
        $chkBoxTemplateNodes.IsEnabled = $false
        $chkBoxScanUsingUSN.IsEnabled = $false
        $btnGetCompareInput.IsEnabled = $false
        $txtReplaceDN.IsEnabled = $false
        $txtReplaceNetbios.IsEnabled = $false  

        $chkBoxEffectiveRights.IsChecked = $false
        $chkBoxType.IsEnabled = $true
        $chkBoxObject.IsEnabled = $true
        $chkBoxTrustee.IsEnabled =  $true
        $combObjectFilter.IsEnabled = $true
        $txtFilterTrustee.IsEnabled = $true
        $combAccessCtrl.IsEnabled = $true
        $btnGetObjFullFilter.IsEnabled = $true
        $txtBoxSelectPrincipal.IsEnabled = $false
        $btnGetSPAccount.IsEnabled = $false
        $btnListLocations.IsEnabled = $false
        $btnGETSPNReport.IsEnabled = $false
        $chkInheritedPerm.IsEnabled = $true
        $chkInheritedPerm.IsChecked = $global:bolTempValue_InhertiedChkBox
        $chkBoxGetOwner.IsEnabled = $true
        if ($null -ne $global:bolTempValue_chkBoxGetOwner)
        {
            $chkBoxGetOwner.IsChecked = $global:bolTempValue_chkBoxGetOwner
        }
       
    }
    else
    {
        $chkBoxType.IsEnabled = $false
        $chkBoxObject.IsEnabled = $false
        $chkBoxTrustee.IsEnabled =  $false
        $chkBoxType.IsChecked = $false
        $chkBoxObject.IsChecked = $false
        $chkBoxTrustee.IsChecked =  $false
        $combObjectFilter.IsEnabled = $false
        $txtFilterTrustee.IsEnabled = $false
        $combAccessCtrl.IsEnabled = $false
        $btnGetObjFullFilter.IsEnabled = $false
}
})

$rdbDSSchm.add_Click(
{
    If($rdbCustomNC.IsChecked -eq $true)
    {
        $txtBoxDomainConnect.IsEnabled = $true
        $btnListDdomain.IsEnabled = $false
        if (($txtBoxDomainConnect.Text -eq "rootDSE") -or ($txtBoxDomainConnect.Text -eq "config") -or ($txtBoxDomainConnect.Text -eq "schema"))
        {
        $txtBoxDomainConnect.Text = ""
        }
    }
    else
    {
    $btnListDdomain.IsEnabled = $false
     If($rdbDSdef.IsChecked -eq $true)
    {
        $txtBoxDomainConnect.Text = $global:strDommainSelect
        $btnListDdomain.IsEnabled = $true
        $txtBdoxDSServerPort.IsEnabled = $false
        $txtBdoxDSServer.IsEnabled = $false

    }
     If($rdbDSConf.IsChecked -eq $true)
    {
        $txtBoxDomainConnect.Text = "config"
        $txtBdoxDSServerPort.IsEnabled = $false
        $txtBdoxDSServer.IsEnabled = $false
    

    }
     If($rdbDSSchm.IsChecked -eq $true)
    {
        $txtBoxDomainConnect.Text = "schema"
        $txtBdoxDSServerPort.IsEnabled = $false
        $txtBdoxDSServer.IsEnabled = $false

    }
    $txtBoxDomainConnect.IsEnabled = $false
    }



})

$rdbDSConf.add_Click(
{
    If($rdbCustomNC.IsChecked -eq $true)
    {
        $txtBoxDomainConnect.IsEnabled = $true
        $btnListDdomain.IsEnabled = $false
        if (($txtBoxDomainConnect.Text -eq "rootDSE") -or ($txtBoxDomainConnect.Text -eq "config") -or ($txtBoxDomainConnect.Text -eq "schema"))
        {
        $txtBoxDomainConnect.Text = ""
        }
    }
    else
    {
    $btnListDdomain.IsEnabled = $false
     If($rdbDSdef.IsChecked -eq $true)
    {
        $txtBoxDomainConnect.Text = $global:strDommainSelect
        $btnListDdomain.IsEnabled = $true
        $txtBdoxDSServerPort.IsEnabled = $false
        $txtBdoxDSServer.IsEnabled = $false

    }
     If($rdbDSConf.IsChecked -eq $true)
    {
        $txtBoxDomainConnect.Text = "config"
        $txtBdoxDSServerPort.IsEnabled = $false
        $txtBdoxDSServer.IsEnabled = $false
    

    }
     If($rdbDSSchm.IsChecked -eq $true)
    {
        $txtBoxDomainConnect.Text = "schema"
        $txtBdoxDSServerPort.IsEnabled = $false
        $txtBdoxDSServer.IsEnabled = $false


    }
    $txtBoxDomainConnect.IsEnabled = $false
    }



})



$rdbDSdef.add_Click(
{
    If($rdbCustomNC.IsChecked -eq $true)
    {
        $txtBoxDomainConnect.IsEnabled = $true
        $btnListDdomain.IsEnabled = $false
        if (($txtBoxDomainConnect.Text -eq "rootDSE") -or ($txtBoxDomainConnect.Text -eq "config") -or ($txtBoxDomainConnect.Text -eq "schema"))
        {
            $txtBoxDomainConnect.Text = ""
        }
    }
    else
    {
        $btnListDdomain.IsEnabled = $false
         If($rdbDSdef.IsChecked -eq $true)
        {
            $txtBdoxDSServerPort.IsEnabled = $false
            $txtBdoxDSServer.IsEnabled = $false
            $txtBoxDomainConnect.Text = $global:strDommainSelect
            $btnListDdomain.IsEnabled = $true


        }
         If($rdbDSConf.IsChecked -eq $true)
        {
            $txtBoxDomainConnect.Text = "config"
    

        }
         If($rdbDSSchm.IsChecked -eq $true)
        {
            $txtBoxDomainConnect.Text = "schema"


        }
        $txtBoxDomainConnect.IsEnabled = $false
    }



})


$rdbCustomNC.add_Click(
{
    If($rdbCustomNC.IsChecked -eq $true)
    {
        $txtBdoxDSServerPort.IsEnabled = $true
        $txtBdoxDSServer.IsEnabled = $true
        $txtBoxDomainConnect.IsEnabled = $true
        $btnListDdomain.IsEnabled = $false
        if (($txtBoxDomainConnect.Text -eq "rootDSE") -or ($txtBoxDomainConnect.Text -eq "config") -or ($txtBoxDomainConnect.Text -eq "schema"))
        {
        $txtBoxDomainConnect.Text = ""
        }
    }
    else
    {
    $btnListDdomain.IsEnabled = $false
     If($rdbDSdef.IsChecked -eq $true)
    {
        $txtBoxDomainConnect.Text = $global:strDommainSelect
        $btnListDdomain.IsEnabled = $true

    }
     If($rdbDSConf.IsChecked -eq $true)
    {
        $txtBoxDomainConnect.Text = "config"
    

    }
     If($rdbDSSchm.IsChecked -eq $true)
    {
        $txtBoxDomainConnect.Text = "schema"


    }
    $txtBoxDomainConnect.IsEnabled = $false
    }



})

$btnGetTemplateFolder.add_Click( 
{
  
$strFolderPath = Select-Folder   
$txtTempFolder.Text = $strFolderPath


})

$btnGetCompareDefSDInput.add_Click( 
{

$strFilePath = Select-File 

$txtCompareDefSDTemplate.Text = $strFilePath


})
$btnGetCompareInput.add_Click( 
{

$strFilePath = Select-File 
$txtCompareTemplate.Text = $strFilePath


})
$btnGetCSVFile.add_Click( 
{

$strFilePath = Select-File 

$txtCSVImport.Text = $strFilePath


})
$btnDSConnect.add_Click(
{
if($chkBoxCreds.IsChecked)
{

$global:CREDS = Get-Credential -Message "Type User Name and Password"
$ADACLGui.Window.Activate()

}
$global:bolRoot = $true

$NCSelect = $false
$global:DSType = ""
$global:strDC = ""
$global:strDomainDNName = ""
$global:ConfigDN = ""
$global:SchemaDN = ""
$global:ForestRootDomainDN = ""
$global:IS_GC = ""
$txtDC.text = ""
$txtdefaultnamingcontext.text = ""
$txtconfigurationnamingcontext.text = ""
$txtschemanamingcontext.text = ""
$txtrootdomainnamingcontext.text = ""

	If ($rdbDSdef.IsChecked)
	{

       if (!($txtBoxDomainConnect.Text -eq "rootDSE"))
        {
            if ($null -eq $global:TempDC)
            {
                $strNamingContextDN = $txtBoxDomainConnect.Text
                If(CheckDNExist $strNamingContextDN "")
                {
                $root = New-Object system.directoryservices.directoryEntry("LDAP://"+$strNamingContextDN)
                $global:strDomainDNName = $root.distinguishedName.tostring()
                $global:strDomainPrinDNName = $global:strDomainDNName
                $global:strDomainLongName = $global:strDomainDNName.Replace("DC=","")
                $global:strDomainLongName = $global:strDomainLongName.Replace(",",".")
                $Context = New-Object DirectoryServices.ActiveDirectory.DirectoryContext("Domain",$global:strDomainLongName )
                $ojbDomain = [DirectoryServices.ActiveDirectory.Domain]::GetDomain($Context)
                $global:strDC = $($ojbDomain.FindDomainController()).name
                $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
                $LDAPConnection.SessionOptions.ReferralChasing = "None"
                $request = New-Object System.directoryServices.Protocols.SearchRequest($null, "(objectClass=*)", "base")
                [void]$request.Attributes.Add("dnshostname")
                [void]$request.Attributes.Add("supportedcapabilities")
                [void]$request.Attributes.Add("namingcontexts")
                [void]$request.Attributes.Add("defaultnamingcontext")
                [void]$request.Attributes.Add("schemanamingcontext")
                [void]$request.Attributes.Add("configurationnamingcontext")
                [void]$request.Attributes.Add("rootdomainnamingcontext")
                [void]$request.Attributes.Add("isGlobalCatalogReady")
                                
                try
	            {
                    $response = $LDAPConnection.SendRequest($request)
                    $global:bolLDAPConnection = $true
	            }
	            catch
	            {
		            $global:bolLDAPConnection = $false
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! Domain does not exist or can not be connected" -strType "Error" -DateStamp ))
	            }
                if($global:bolLDAPConnection -eq $true)
                {
                    $global:ForestRootDomainDN = $response.Entries[0].attributes.rootdomainnamingcontext[0]
                    $global:SchemaDN = $response.Entries[0].attributes.schemanamingcontext[0]
                    $global:ConfigDN = $response.Entries[0].attributes.configurationnamingcontext[0]
                    $global:strDomainDNName = $response.Entries[0].attributes.defaultnamingcontext[0]
                    $global:IS_GC = $response.Entries[0].Attributes.isglobalcatalogready[0]
                }

                $global:DirContext = Get-DirContext $global:strDC $global:CREDS

                $global:strDomainShortName = GetDomainShortName $global:strDomainDNName $global:ConfigDN
                $global:strRootDomainShortName = GetDomainShortName $global:ForestRootDomainDN $global:ConfigDN
                $global:DSType = "AD DS"
                $global:bolADDSType = $true
                $lblSelectPrincipalDom.Content = $global:strDomainShortName+":"
                $NCSelect = $true
                $strNamingContextDN = $global:strDomainDNName
            }
               else
                {
                   $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! Domain does not exist or can not be connected" -strType "Error" -DateStamp ))
                   $global:bolConnected = $false
                }
            }
            else
            {
                $strNamingContextDN = $txtBoxDomainConnect.Text
                If(CheckDNExist $strNamingContextDN "$global:TempDC")
                {
                $Context = New-Object DirectoryServices.ActiveDirectory.DirectoryContext("Domain",$global:TempDC )
                $global:TempDC = $null
                $ojbDomain = [DirectoryServices.ActiveDirectory.Domain]::GetDomain($Context)
                $global:strDC = $($ojbDomain.FindDomainController()).name
                $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
                $LDAPConnection.SessionOptions.ReferralChasing = "None"
                $request = New-Object System.directoryServices.Protocols.SearchRequest($null, "(objectClass=*)", "base")
                [void]$request.Attributes.Add("dnshostname")
                [void]$request.Attributes.Add("supportedcapabilities")
                [void]$request.Attributes.Add("namingcontexts")
                [void]$request.Attributes.Add("defaultnamingcontext")
                [void]$request.Attributes.Add("schemanamingcontext")
                [void]$request.Attributes.Add("configurationnamingcontext")
                [void]$request.Attributes.Add("rootdomainnamingcontext")
                [void]$request.Attributes.Add("isGlobalCatalogReady")
                
                
                try
	            {
                    $response = $LDAPConnection.SendRequest($request)
                    $global:bolLDAPConnection = $true
	            }
	            catch
	            {
		            $global:bolLDAPConnection = $false
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! Domain does not exist or can not be connected" -strType "Error" -DateStamp ))
	            }
                if($global:bolLDAPConnection -eq $true)
                {
                    $global:ForestRootDomainDN = $response.Entries[0].attributes.rootdomainnamingcontext[0]
                    $global:SchemaDN = $response.Entries[0].attributes.schemanamingcontext[0]
                    $global:ConfigDN = $response.Entries[0].attributes.configurationnamingcontext[0]
                    $global:strDomainDNName = $response.Entries[0].attributes.defaultnamingcontext[0]
                    $global:IS_GC = $response.Entries[0].Attributes.isglobalcatalogready[0]
                }

                $global:DirContext = Get-DirContext $global:strDC $global:CREDS

                $global:strDomainShortName = GetDomainShortName $global:strDomainDNName $global:ConfigDN
                $global:strRootDomainShortName = GetDomainShortName $global:ForestRootDomainDN $global:ConfigDN
                $global:DSType = "AD DS"
                $global:bolADDSType = $true
                $lblSelectPrincipalDom.Content = $global:strDomainShortName+":"
                $NCSelect = $true
                $strNamingContextDN = $global:strDomainDNName
                }
               else
                {
                   $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! Domain does not exist or can not be connected" -strType "Error" -DateStamp ))
                   $global:bolConnected = $false
                }
            }
        }
        else
        {

            if ($global:bolRoot -eq $true)
            {
                $LDAPConnection = $null
                $request = $null
                $response = $null
                $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection("")
                $LDAPConnection.SessionOptions.ReferralChasing = "None"
                $request = New-Object System.directoryServices.Protocols.SearchRequest($null, "(objectClass=*)", "base")
                [void]$request.Attributes.Add("defaultnamingcontext")
                try
	            {
                    $response = $LDAPConnection.SendRequest($request)
                    $global:strDomainDNName = $response.Entries[0].Attributes.defaultnamingcontext[0]
                    $global:bolLDAPConnection = $true
	            }
	            catch
	            {
		            $global:bolLDAPConnection = $false
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! Domain does not exist or can not be connected" -strType "Error" -DateStamp ))
	            }

                if($global:bolLDAPConnection)
                {
                    $global:strDomainPrinDNName = $global:strDomainDNName
                    $global:strDomainLongName = $global:strDomainDNName.Replace("DC=","")
                    $global:strDomainLongName = $global:strDomainLongName.Replace(",",".")
                    $Context = New-Object DirectoryServices.ActiveDirectory.DirectoryContext("Domain",$global:strDomainLongName )
                    $ojbDomain = [DirectoryServices.ActiveDirectory.Domain]::GetDomain($Context)
                    $global:strDC = $($ojbDomain.FindDomainController()).name
                    $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
                    $LDAPConnection.SessionOptions.ReferralChasing = "None"
                    $request = New-Object System.directoryServices.Protocols.SearchRequest($null, "(objectClass=*)", "base")
                    [void]$request.Attributes.Add("dnshostname")
                    [void]$request.Attributes.Add("supportedcapabilities")
                    [void]$request.Attributes.Add("namingcontexts")
                    [void]$request.Attributes.Add("defaultnamingcontext")
                    [void]$request.Attributes.Add("schemanamingcontext")
                    [void]$request.Attributes.Add("configurationnamingcontext")
                    [void]$request.Attributes.Add("rootdomainnamingcontext")
                    [void]$request.Attributes.Add("isGlobalCatalogReady")
                    
                    try
    	            {
                        $response = $LDAPConnection.SendRequest($request)
                        $global:bolLDAPConnection = $true
    	            }
    	            catch
    	            {
    		            $global:bolLDAPConnection = $false
                        $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! Domain does not exist or can not be connected" -strType "Error" -DateStamp ))
    	            }
                    if($global:bolLDAPConnection -eq $true)
                    {
                        $global:ForestRootDomainDN = $response.Entries[0].attributes.rootdomainnamingcontext[0]
                        $global:SchemaDN = $response.Entries[0].attributes.schemanamingcontext[0]
                        $global:ConfigDN = $response.Entries[0].attributes.configurationnamingcontext[0]
                        $global:strDomainDNName = $response.Entries[0].attributes.defaultnamingcontext[0]
                        $global:IS_GC = $response.Entries[0].Attributes.isglobalcatalogready[0]
                    }

                    $global:DirContext = Get-DirContext $global:strDC $global:CREDS
                    $global:strDomainShortName = GetDomainShortName $global:strDomainDNName $global:ConfigDN
                    $global:strRootDomainShortName = GetDomainShortName $global:ForestRootDomainDN $global:ConfigDN
                    $global:DSType = "AD DS"
                    $global:bolADDSType = $true
                    $lblSelectPrincipalDom.Content = $global:strDomainShortName+":"
                    $NCSelect = $true
                    $strNamingContextDN = $global:strDomainDNName
                }
            }
        }
	}
    #Connect to Config Naming Context
	If ($rdbDSConf.IsChecked)
	{


        if ($global:bolRoot -eq $true)
        {
            $LDAPConnection = $null
            $request = $null
            $response = $null
            $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection("")
            $LDAPConnection.SessionOptions.ReferralChasing = "None"
            $request = New-Object System.directoryServices.Protocols.SearchRequest($null, "(objectClass=*)", "base")
            [void]$request.Attributes.Add("defaultnamingcontext")
            try
	        {
                $response = $LDAPConnection.SendRequest($request)
                $global:strDomainDNName = $response.Entries[0].attributes.defaultnamingcontext[0]
                $global:bolLDAPConnection = $true
	        }
	        catch
	        {
		        $global:bolLDAPConnection = $false
                $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! Domain does not exist or can not be connected" -strType "Error" -DateStamp ))
            }

            if($global:bolLDAPConnection)
            {
                $global:strDomainPrinDNName = $global:strDomainDNName
                $global:strDomainLongName = $global:strDomainDNName.Replace("DC=","")
                $global:strDomainLongName = $global:strDomainLongName.Replace(",",".")
                $Context = New-Object DirectoryServices.ActiveDirectory.DirectoryContext("Domain",$global:strDomainLongName )
                $ojbDomain = [DirectoryServices.ActiveDirectory.Domain]::GetDomain($Context)
                $global:strDC = $($ojbDomain.FindDomainController()).name
                $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
                $LDAPConnection.SessionOptions.ReferralChasing = "None"
                $request = New-Object System.directoryServices.Protocols.SearchRequest($null, "(objectClass=*)", "base")
                [void]$request.Attributes.Add("dnshostname")
                [void]$request.Attributes.Add("supportedcapabilities")
                [void]$request.Attributes.Add("namingcontexts")
                [void]$request.Attributes.Add("defaultnamingcontext")
                [void]$request.Attributes.Add("schemanamingcontext")
                [void]$request.Attributes.Add("configurationnamingcontext")
                [void]$request.Attributes.Add("rootdomainnamingcontext")
                [void]$request.Attributes.Add("isGlobalCatalogReady")

                try
    	        {
                    $response = $LDAPConnection.SendRequest($request)
                    $global:bolLDAPConnection = $true
    	        }
    	        catch
    	        {
    		        $global:bolLDAPConnection = $false
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! Domain does not exist or can not be connected" -strType "Error" -DateStamp ))
    	        }
                if($global:bolLDAPConnection -eq $true)
                {
                    $global:ForestRootDomainDN = $response.Entries[0].attributes.rootdomainnamingcontext[0]
                    $global:SchemaDN = $response.Entries[0].attributes.schemanamingcontext[0]
                    $global:ConfigDN = $response.Entries[0].attributes.configurationnamingcontext[0]
                    $global:strDomainDNName = $response.Entries[0].attributes.defaultnamingcontext[0]
                    $global:IS_GC = $response.Entries[0].Attributes.isglobalcatalogready[0]
                }

                $global:DirContext = Get-DirContext $global:strDC $global:CREDS
                $global:strDomainShortName = GetDomainShortName $global:strDomainDNName $global:ConfigDN
                $global:strRootDomainShortName = GetDomainShortName $global:ForestRootDomainDN $global:ConfigDN
                $global:DSType = "AD DS"
                $global:bolADDSType = $true
                $lblSelectPrincipalDom.Content = $global:strDomainShortName+":"
                $NCSelect = $true
                $strNamingContextDN = $global:ConfigDN
            }
        }
	}
    #Connect to Schema Naming Context
	If ($rdbDSSchm.IsChecked)
	{

        if ($global:bolRoot -eq $true)
        {
            $LDAPConnection = $null
            $request = $null
            $response = $null
            $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection("")
            $LDAPConnection.SessionOptions.ReferralChasing = "None"
            $request = New-Object System.directoryServices.Protocols.SearchRequest($null, "(objectClass=*)", "base")
            [void]$request.Attributes.Add("defaultnamingcontext")
            try
	        {
                $response = $LDAPConnection.SendRequest($request)
                $global:strDomainDNName = $response.Entries[0].Attributes.defaultnamingcontext[0]
                $global:bolLDAPConnection = $true
	        }
	        catch
	        {
		        $global:bolLDAPConnection = $false
                $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! Domain does not exist or can not be connected" -strType "Error" -DateStamp ))
            }

            if($global:bolLDAPConnection)
            {
                $global:strDomainPrinDNName = $global:strDomainDNName
                $global:strDomainLongName = $global:strDomainDNName.Replace("DC=","")
                $global:strDomainLongName = $global:strDomainLongName.Replace(",",".")
                $Context = New-Object DirectoryServices.ActiveDirectory.DirectoryContext("Domain",$global:strDomainLongName )
                $ojbDomain = [DirectoryServices.ActiveDirectory.Domain]::GetDomain($Context)
                $global:strDC = $($ojbDomain.FindDomainController()).name
                $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
                $LDAPConnection.SessionOptions.ReferralChasing = "None"
                $request = New-Object System.directoryServices.Protocols.SearchRequest($null, "(objectClass=*)", "base")
                [void]$request.Attributes.Add("dnshostname")
                [void]$request.Attributes.Add("supportedcapabilities")
                [void]$request.Attributes.Add("namingcontexts")
                [void]$request.Attributes.Add("defaultnamingcontext")
                [void]$request.Attributes.Add("schemanamingcontext")
                [void]$request.Attributes.Add("configurationnamingcontext")
                [void]$request.Attributes.Add("rootdomainnamingcontext")
                [void]$request.Attributes.Add("isGlobalCatalogReady")
                                    
                try
    	        {
                    $response = $LDAPConnection.SendRequest($request)
                    $global:bolLDAPConnection = $true
    	        }
    	        catch
    	        {
    		        $global:bolLDAPConnection = $false
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! Domain does not exist or can not be connected" -strType "Error" -DateStamp ))
    	        }
                if($global:bolLDAPConnection -eq $true)
                {
                    $global:ForestRootDomainDN = $response.Entries[0].attributes.rootdomainnamingcontext[0]
                    $global:SchemaDN = $response.Entries[0].attributes.schemanamingcontext[0]
                    $global:ConfigDN = $response.Entries[0].attributes.configurationnamingcontext[0]
                    $global:strDomainDNName = $response.Entries[0].attributes.defaultnamingcontext[0]
                    $global:IS_GC = $response.Entries[0].Attributes.isglobalcatalogready[0]
                }

                $global:DirContext = Get-DirContext $global:strDC $global:CREDS
                $global:strDomainShortName = GetDomainShortName $global:strDomainDNName $global:ConfigDN
                $global:strRootDomainShortName = GetDomainShortName $global:ForestRootDomainDN $global:ConfigDN
                $global:DSType = "AD DS"
                $global:bolADDSType = $true
                $lblSelectPrincipalDom.Content = $global:strDomainShortName+":"
                $NCSelect = $true
                $strNamingContextDN = $global:SchemaDN
            }
        }
	}
    #Connect to Custom Naming Context	
    If ($rdbCustomNC.IsChecked)
	{   
        if (($txtBoxDomainConnect.Text.Length -gt 0) -or ($txtBdoxDSServer.Text.Length -gt 0) -or ($txtBdoxDSServerPort.Text.Length -gt 0))
        {
                $strNamingContextDN = $txtBoxDomainConnect.Text
                if($txtBdoxDSServer.Text -eq "")
                {
                    if($txtBdoxDSServerPort.Text -eq "")
                    {                    
                        $global:strDC = ""
                    }
                    else
                    {
                        $global:strDC = "localhost:" +$txtBdoxDSServerPort.text
                    }
                }
                else
                {
                    $global:strDC = $txtBdoxDSServer.Text +":" +$txtBdoxDSServerPort.text
                    if($txtBdoxDSServerPort.Text -eq "")
                    {                    
                        $global:strDC = $txtBdoxDSServer.Text
                    }
                    else
                    {
                        $global:strDC = $txtBdoxDSServer.Text +":" +$txtBdoxDSServerPort.text     
                    }
                }
                    $global:bolLDAPConnection = $false
                    $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
                    $LDAPConnection.SessionOptions.ReferralChasing = "None"
                    $request = New-Object System.directoryServices.Protocols.SearchRequest("", "(objectClass=*)", "base")
                    if($global:bolShowDeleted)
                    {
                        [string] $LDAP_SERVER_SHOW_DELETED_OID = "1.2.840.113556.1.4.417"
                        [void]$request.Controls.Add((New-Object "System.DirectoryServices.Protocols.DirectoryControl" -ArgumentList "$LDAP_SERVER_SHOW_DELETED_OID",$null,$false,$true ))
                    }
                    [void]$request.Attributes.Add("dnshostname")
                    [void]$request.Attributes.Add("supportedcapabilities")
                    [void]$request.Attributes.Add("namingcontexts")
                    [void]$request.Attributes.Add("defaultnamingcontext")
                    [void]$request.Attributes.Add("schemanamingcontext")
                    [void]$request.Attributes.Add("configurationnamingcontext")
                    [void]$request.Attributes.Add("rootdomainnamingcontext")
                    [void]$request.Attributes.Add("isGlobalCatalogReady")                        
    
	                try
	                {
                        $response = $LDAPConnection.SendRequest($request)
                        $global:bolLDAPConnection = $true

	                }
	                catch
	                {
		                $global:bolLDAPConnection = $false
                        $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! Domain does not exist or can not be connected" -strType "Error" -DateStamp ))
	                }
                    if($global:bolLDAPConnection -eq $true)
                    {
                        $strPrimaryCapability= $response.Entries[0].attributes.supportedcapabilities[0]
                        Switch ($strPrimaryCapability)
                        {
                            "1.2.840.113556.1.4.1851"
                            {
                                $global:DSType = "AD LDS"
                                $global:bolADDSType = $false
                                $global:strDomainDNName = $response.Entries[0].Attributes.namingcontexts[-1]
                                $global:SchemaDN = $response.Entries[0].Attributes.schemanamingcontext[0]
                                $global:ConfigDN = $response.Entries[0].Attributes.configurationnamingcontext[0]
                                if($txtBdoxDSServerPort.Text -eq "")
                                {                    
                                    $global:strDC = $response.Entries[0].Attributes.dnshostname[0]
                                }
                                else
                                {
                                    $global:strDC = $response.Entries[0].Attributes.dnshostname[0] +":" +$txtBdoxDSServerPort.text     
                                }

                            }
                            "1.2.840.113556.1.4.800"
                            {
                                $global:DSType = "AD DS"
                                $global:bolADDSType = $true
                                $global:ForestRootDomainDN = $response.Entries[0].Attributes.rootdomainnamingcontext[0]
                                $global:strDomainDNName = $response.Entries[0].Attributes.defaultnamingcontext[0]
                                $global:SchemaDN = $response.Entries[0].Attributes.schemanamingcontext[0]
                                $global:ConfigDN = $response.Entries[0].Attributes.configurationnamingcontext[0]
                                $global:IS_GC = $response.Entries[0].Attributes.isglobalcatalogready[0]

                                if($txtBdoxDSServerPort.Text -eq "")
                                {                    
                                    $global:strDC = $response.Entries[0].Attributes.dnshostname[0]
                                }
                                else
                                {
                                    $global:strDC = $response.Entries[0].Attributes.dnshostname[0] +":" +$txtBdoxDSServerPort.text     
                                }
                                $global:strDomainPrinDNName = $global:strDomainDNName
                                $global:strDomainShortName = GetDomainShortName $global:strDomainDNName $global:ConfigDN
                                $global:strRootDomainShortName = GetDomainShortName $global:ForestRootDomainDN $global:ConfigDN
                                $lblSelectPrincipalDom.Content = $global:strDomainShortName+":"
                            }
                            default
                            {
                                $global:ForestRootDomainDN = $response.Entries[0].Attributes.rootdomainnamingcontext[0]
                                $global:strDomainDNName = $response.Entries[0].Attributes.defaultnamingcontext[0]
                                $global:SchemaDN = $response.Entries[0].Attributes.schemanamingcontext[0]
                                $global:ConfigDN = $response.Entries[0].Attributes.configurationnamingcontext[0]
                                $global:IS_GC = $response.Entries[0].Attributes.isglobalcatalogready[0]

                                 if($txtBdoxDSServerPort.Text -eq "")
                                {                    
                                    $global:strDC = $response.Entries[0].Attributes.dnshostname[0]
                                }
                                else
                                {
                                    $global:strDC = $response.Entries[0].Attributes.dnshostname[0] +":" +$txtBdoxDSServerPort.text     
                                }
                            }
                        }  
                        if($strNamingContextDN -eq "")
                        {
                            $strNamingContextDN = $global:strDomainDNName
                        }
                        If(CheckDNExist $strNamingContextDN $global:strDC)
                        {

                            $NCSelect = $true
                            $global:strDomainDNName = $strNamingContextDN
                            $NCSelect = $true

                        }
                        else
                        {
                            $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! Domain does not exist or can not be connected" -strType "Error" -DateStamp ))
                            $global:bolConnected = $false
                        }
   
                    }#bolLDAPConnection
                


            
        }
        else
        {
            $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! No naming context or server specified!" -strType "Error" -DateStamp ))
            $global:bolConnected = $false  
        }
	}  
    If ($NCSelect -eq $true)  
    {
	    If (!($strLastCacheGuidsDom -eq $global:strDomainDNName))
	    {
	        $global:dicRightsGuids = @{"Seed" = "xxx"}
	        CacheRightsGuids 
	        $strLastCacheGuidsDom = $global:strDomainDNName
        
        
	    }
        #Check Directory Service type
        $global:DSType = ""
        $global:bolADDSType = $false
        $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
        $LDAPConnection.SessionOptions.ReferralChasing = "None"
        $request = New-Object System.directoryServices.Protocols.SearchRequest("", "(objectClass=*)", "base")
        $response = $LDAPConnection.SendRequest($request)
        $strPrimaryCapability= $response.Entries[0].attributes.supportedcapabilities[0]
        Switch ($strPrimaryCapability)
        {
            "1.2.840.113556.1.4.1851"
            {
                $global:DSType = "AD LDS"
            }
            "1.2.840.113556.1.4.800"
            {
                $global:DSType = "AD DS"
                $global:bolADDSType = $true
            }
            default
            {
                $global:DSType = "Unknown"
            }
        }    
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Connected to directory service  $global:DSType" -strType "Info" -DateStamp ))
        #Plaing with AD LDS Locally
        $global:TreeViewRootPath = $strNamingContextDN

        $xml = Get-XMLDomainOUTree $global:TreeViewRootPath
            # Change XML Document, XPath and Refresh
        $xmlprov_adp.Document = $xml
        $xmlProv_adp.XPath = "/DomainRoot"
        $xmlProv_adp.Refresh()

        $global:bolConnected = $true

        If (!(Test-Path ($env:temp + "\OU.png")))
        {
        (([System.IconExtractor]::Extract("mmcndmgr.dll", 0, $true)).ToBitMap()).Save($env:temp + "\OU.png")
        }
        If (!(Test-Path ($env:temp + "\Expand.png")))
        {
        (([System.IconExtractor]::Extract("mmcndmgr.dll", 6, $true)).ToBitMap()).Save($env:temp + "\Expand.png")
        }
        If (!(Test-Path ($env:temp + "\User.png")))
        {
        (([System.IconExtractor]::Extract("mmcndmgr.dll", 58, $true)).ToBitMap()).Save($env:temp + "\User.png")
        }
        If (!(Test-Path ($env:temp + "\Group.png")))
        {
        (([System.IconExtractor]::Extract("mmcndmgr.dll", 59, $true)).ToBitMap()).Save($env:temp + "\Group.png")
        }
        If (!(Test-Path ($env:temp + "\Computer.png")))
        {
        (([System.IconExtractor]::Extract("mmcndmgr.dll", 60, $true)).ToBitMap()).Save($env:temp + "\Computer.png")
        }
        If (!(Test-Path ($env:temp + "\Container.png")))
        {
        (([System.IconExtractor]::Extract("mmcndmgr.dll", 66, $true)).ToBitMap()).Save($env:temp + "\Container.png")
        }
        If (!(Test-Path ($env:temp + "\DomainDNS.png")))
        {
        (([System.IconExtractor]::Extract("mmcndmgr.dll", 95, $true)).ToBitMap()).Save($env:temp + "\DomainDNS.png")
        }
        If (!(Test-Path ($env:temp + "\Other.png")))
        {
        (([System.IconExtractor]::Extract("mmcndmgr.dll", 126, $true)).ToBitMap()).Save($env:temp + "\Other.png")    
        }
        If (!(Test-Path ($env:temp + "\refresh.png")))
        {
        (([System.IconExtractor]::Extract("mmcndmgr.dll", 46, $true)).ToBitMap()).Save($env:temp + "\refresh.png")
        }
        If (!(Test-Path ($env:temp + "\refresh2.png")))
        {
        (([System.IconExtractor]::Extract("shell32.dll", 238, $true)).ToBitMap()).Save($env:temp + "\refresh2.png")
        }
        If (!(Test-Path ($env:temp + "\exclude.png")))
        {
        (([System.IconExtractor]::Extract("shell32.dll", 234, $true)).ToBitMap()).Save($env:temp + "\exclude.png")
        }
        #Test PS Version DeleteCommand requries PS 3.0 and above
        if ($PSVersionTable.PSVersion -gt "2.0") 
        {
            if($psversiontable.clrversion.Major -ge 4)
            {    
                $TreeView1.ContextMenu.Items[0].Command = New-Object DelegateCommand( { Add-RefreshChild } )
                $TreeView1.ContextMenu.Items[1].Command = New-Object DelegateCommand( { Add-ExcludeChild } )
            }    
            else
            {

                $global:observableCollection.Insert(0,(LogMessage -strMessage "(common language runtime) CLRVersion = $($psversiontable.clrversion.Major)" -strType "Warning" -DateStamp ))
                $global:observableCollection.Insert(0,(LogMessage -strMessage "Some GUI functions requrie .NET Framework run-time environment (common language runtime) 4.0!" -strType "Warning" -DateStamp ))
                if((Get-HighestNetFrameWorkVer) -ge 4.0)
                {
                $global:observableCollection.Insert(0,(LogMessage -strMessage "Installed .NET Framework version = $(Get-HighestNetFrameWorkVer)" -strType "Info" -DateStamp ))
                }
            }
        }
        else 
        {
            $global:observableCollection.Insert(0,(LogMessage -strMessage "(common language runtime) CLRVersion = $($psversiontable.clrversion.Major)" -strType "Warning" -DateStamp ))
            $global:observableCollection.Insert(0,(LogMessage -strMessage "Some GUI functions requrie PowerShell 3.0 and .NET Framework run-time environment (common language runtime) 4.0!" -strType "Warning" -DateStamp ))
            if((Get-HighestNetFrameWorkVer) -ge 4.0)
            {
            $global:observableCollection.Insert(0,(LogMessage -strMessage "Installed .NET Framework version = $(Get-HighestNetFrameWorkVer)" -strType "Info" -DateStamp ))
            }
        }
        #Update Connection Info
        $txtDC.text = $global:strDC
        $txtdefaultnamingcontext.text = $global:strDomainDNName
        $txtconfigurationnamingcontext.text = $global:ConfigDN
        $txtschemanamingcontext.text = $global:SchemaDN
        $txtrootdomainnamingcontext.text = $global:ForestRootDomainDN

    }#End If NCSelect
    
#Get Forest Root Domain ObjectSID
if ($global:DSType -eq "AD DS")
{
 

                $global:strForestDomainLongName = $global:ForestRootDomainDN.Replace("DC=","")
                $global:strForestDomainLongName = $global:strForestDomainLongName.Replace(",",".")
                if($global:CREDS.UserName)
                {
                    $Context = New-Object DirectoryServices.ActiveDirectory.DirectoryContext("Domain",$global:strForestDomainLongName,$global:CREDS.UserName,$global:CREDS.GetNetworkCredential().Password) 
                }
                else
                {
                    $Context = New-Object DirectoryServices.ActiveDirectory.DirectoryContext("Domain",$global:strForestDomainLongName) 
                }
                $ojbDomain = [DirectoryServices.ActiveDirectory.Domain]::GetDomain($Context)
                $global:strForestDC = $($ojbDomain.FindDomainController()).name
                $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strForestDC, $global:CREDS)
                $LDAPConnection.SessionOptions.ReferralChasing = "None"
                $request = New-Object System.directoryServices.Protocols.SearchRequest($global:ForestRootDomainDN, "(objectClass=*)", "base")
                [void]$request.Attributes.Add("objectsid")
                
                try
	            {
                    $response = $LDAPConnection.SendRequest($request)
                    $global:bolLDAPConnection = $true
	            }
	            catch
	            {
		            $global:bolLDAPConnection = $false
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! Domain does not exist or can not be connected" -strType "Error" -DateStamp ))
	            }
                if($global:bolLDAPConnection -eq $true)
                {
                    $global:ForestRootDomainSID = GetSidStringFromSidByte $response.Entries[0].attributes.objectsid[0]

                }
}

})

$chkBoxCreds.add_UnChecked({
$global:CREDS = $null
})

$btnScan.add_Click( 
{

    If($chkBoxCompare.IsChecked)
    {
        RunCompare
    }
    else
    {
        RunScan
    }



})

$btnCreateHTML.add_Click(
{
if ($txtCSVImport.Text -eq "")
{
    $global:observableCollection.Insert(0,(LogMessage -strMessage "No Template CSV file selected!" -strType "Error" -DateStamp ))
}
else
{
    #if ($global:bolConnected -eq $true)
    #{
        ConvertCSVtoHTM $txtCSVImport.Text $chkBoxTranslateGUIDinCSV.isChecked
    #}
    #else
    #{
    #$global:observableCollection.Insert(0,(LogMessage -strMessage "You need to connect to a directory first!" -strType "Error" -DateStamp ))
    #}
}

})

$btnSupport.add_Click(
{
GenerateSupportStatement
})

$btnExit.add_Click( 
{
#TODO: Place custom script here

#$ErrorActionPreference = "SilentlyContinue"
$bolConnected= $null
$bolTempValue_InhertiedChkBox= $null
$dicDCSpecialSids= $null
$dicNameToSchemaIDGUIDs= $null
$dicRightsGuids= $null
$dicSchemaIDGUIDs= $null
$dicSidToName= $null
$dicWellKnownSids= $null
$myPID= $null
$observableCollection= $null
$scopeLevel= $null
$strDomainPrinDNName= $null
$strDommainSelect= $null
$strEffectiveRightAccount= $null
$strEffectiveRightSP= $null
$strPinDomDC= $null
$strPrincipalDN= $null
$strPrinDomAttr= $null
$strPrinDomDir= $null
$strPrinDomFlat= $null
$strSPNobjectClass= $null
$tokens= $null
$strDC = $null
$strDomainDNName = $null
$strDomainLongName = $null
$strDomainShortName = $null
$strOwner = $null
remove-variable -name "bolConnected" -Scope Global
remove-variable -name "bolTempValue_InhertiedChkBox" -Scope Global
remove-variable -name "dicDCSpecialSids" -Scope Global
remove-variable -name "dicNameToSchemaIDGUIDs" -Scope Global
remove-variable -name "dicRightsGuids" -Scope Global
remove-variable -name "dicSchemaIDGUIDs" -Scope Global
remove-variable -name "dicSidToName" -Scope Global
remove-variable -name "dicWellKnownSids" -Scope Global
remove-variable -name "myPID" -Scope Global
remove-variable -name "observableCollection" -Scope Global
remove-variable -name "scopeLevel" -Scope Global
remove-variable -name "strDomainPrinDNName" -Scope Global
remove-variable -name "strDommainSelect" -Scope Global
remove-variable -name "strEffectiveRightAccount" -Scope Global
remove-variable -name "strEffectiveRightSP" -Scope Global
remove-variable -name "strPinDomDC" -Scope Global
remove-variable -name "strPrincipalDN" -Scope Global
remove-variable -name "strPrinDomAttr" -Scope Global
remove-variable -name "strPrinDomDir" -Scope Global
remove-variable -name "strPrinDomFlat" -Scope Global
remove-variable -name "strSPNobjectClass" -Scope Global
remove-variable -name "tokens" -Scope Global


$ErrorActionPreference = "SilentlyContinue"
    &{#Try        $xmlDoc = $null        remove-variable -name "xmlDoc" -Scope Global
    }
    Trap [SystemException]
    {

     SilentlyContinue
    }

$ErrorActionPreference = "Continue"

$ADACLGui.Window.close()

})


$btnGetObjFullFilter.add_Click( 
{
    if ($global:bolConnected -eq $true)
    {
        GetSchemaObjectGUID  -Domain $global:strDomainDNName
        $global:observableCollection.Insert(0,(LogMessage -strMessage "All schema objects and attributes listed!" -strType "Info" -DateStamp ))
    }
    else
    {
    $global:observableCollection.Insert(0,(LogMessage -strMessage "Connect to your naming context first!" -strType "Error" -DateStamp ))
    }
})



foreach ($ldapDisplayName in $global:dicSchemaIDGUIDs.values)
{


   [void]$combObjectFilter.Items.Add($ldapDisplayName)
   
}

$treeView1.add_SelectedItemChanged({

$txtBoxSelected.Text = (Get-XMLPath -xmlElement ($this.SelectedItem))


if ($this.SelectedItem.Tag -eq "NotEnumerated") 
{ 

    $xmlNode = $global:xmlDoc
     
    $NodeDNPath = $($this.SelectedItem.ParentNode.Text.toString())
    [void]$this.SelectedItem.ParentNode.removeChild($this.SelectedItem);
    $Mynodes = $xmlNode.SelectNodes("//OU[@Text='$NodeDNPath']")

    $treeNodePath = $NodeDNPath.Replace("/", "\/")
       
    # Initialize and Build Domain OU Tree 
    ProcessOUTree -node $($Mynodes) -ADSObject $treeNodePath #-nodeCount 0 
    # Set tag to show this node is already enumerated 
    $this.SelectedItem.Tag  = "Enumerated" 
	
}


})


<######################################################################

    Functions to Build Domains OU Tree XML Document

######################################################################>
#region 
function RunCompare
{
If ($txtBoxSelected.Text -or $chkBoxTemplateNodes.IsChecked )
{
    #If the DC string is changed during the compre ti will be restored to it's orgi value 
    $global:ResetDCvalue = ""
    $global:ResetDCvalue = $global:strDC

    $allSubOU = New-Object System.Collections.ArrayList
    $allSubOU.Clear()
    if ($txtCompareTemplate.Text -eq "")
    {
    	$global:observableCollection.Insert(0,(LogMessage -strMessage "No Template CSV file selected!" -strType "Error" -DateStamp ))
    }
    else
    {
            if ($(Test-Path $txtCompareTemplate.Text) -eq $true)
            {
            if (($chkBoxEffectiveRights.isChecked -eq $true) -or ($chkBoxFilter.isChecked -eq $true))
            {
                if ($chkBoxEffectiveRights.isChecked)
                {
    	            $global:observableCollection.Insert(0,(LogMessage -strMessage "Can't compare while Effective Rights enabled!" -strType "Error" -DateStamp ))
                }
                if ($chkBoxFilter.isChecked)
                {
    	            $global:observableCollection.Insert(0,(LogMessage -strMessage "Can't compare while Filter  enabled!" -strType "Error" -DateStamp ))
                }
            }
            else
            {
                $global:bolCSVLoaded = $false
                $strCompareFile = $txtCompareTemplate.Text
                &{#Try
                    $global:bolCSVLoaded = $true
                    $global:csvHistACLs = import-Csv $strCompareFile 
                }
                Trap [SystemException]
                {
                    $strCSVErr = $_.Exception.Message
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed to load CSV. $strCSVErr" -strType "Error" -DateStamp ))
                    $global:bolCSVLoaded = $false
                    continue
                }   
               #Verify that a successful CSV import is performed before continue            
               if($global:bolCSVLoaded)
               {
                    #Test CSV file format
                   if(TestCSVColumns $global:csvHistACLs)
                                                                                                                                                                                                                                                                                                       {
                                       
	               $global:observableCollection.Insert(0,(LogMessage -strMessage "Scanning..." -strType "Info" -DateStamp ))
	               $BolSkipDefPerm = $chkBoxDefaultPerm.IsChecked
                   $BolSkipProtectedPerm =  $chkBoxSkipProtectedPerm.IsChecked
                   $global:bolProgressBar = $chkBoxSkipProgressBar.IsChecked
	               if ($chkBoxTemplateNodes.IsChecked -eq $false)
                    {
                        $sADobjectName = $txtBoxSelected.Text.ToString().Replace("/", "\/")
                        $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC,$global:CREDS)
                        $LDAPConnection.SessionOptions.ReferralChasing = "None"
                        $request = New-Object System.directoryServices.Protocols.SearchRequest
                        if($global:bolShowDeleted)
                        {
                            [string] $LDAP_SERVER_SHOW_DELETED_OID = "1.2.840.113556.1.4.417"
                            [void]$request.Controls.Add((New-Object "System.DirectoryServices.Protocols.DirectoryControl" -ArgumentList "$LDAP_SERVER_SHOW_DELETED_OID",$null,$false,$true ))
                        }
                        $request.DistinguishedName = $sADobjectName
                        $request.Filter = "(name=*)"
                        $request.Scope = "Base"
                        [void]$request.Attributes.Add("name")
                        [void]$request.Attributes.Add("distinguishedname")
                        $response = $LDAPConnection.SendRequest($request)
                        $ADobject = $response.Entries[0]
                        if($null -ne $ADobject.Attributes.name)
                        {
                            $strNode = fixfilename $ADobject.attributes.name[0]
                        }
                        else
                        {
                                $global:observableCollection.Insert(0,(LogMessage -strMessage "Could not read object $($txtBoxSelected.Text.ToString()). Enough permissions?" -strType "Error" -DateStamp ))
                        }
                       
                    }
                    else
                    {
                        #Set the bolean to true so connection will be performed unless an error occur
                        $bolContinue = $true

                        $strOUcol = $global:csvHistACLs[0].OU

                        if($strOUcol.Contains("<DOMAIN-DN>") -gt 0)
                        {
		                    $strOUcol = ($strOUcol -Replace "<DOMAIN-DN>",$global:strDomainDNName)

                        }

                        if($strOUcol.Contains("<ROOT-DN>") -gt 0)
                        {
		                    $strOUcol = ($strOUcol -Replace "<ROOT-DN>",$global:ForestRootDomainDN)

                            if($global:strDomainDNName -ne $global:ForestRootDomainDN)
                            {
                                if($global:IS_GC -eq "TRUE")
                                {
                                    $MsgBox = [System.Windows.Forms.MessageBox]::Show("You are not connected to the forest root domain: $global:ForestRootDomainDN.`n`nYour DC is a Global Catalog.`nDo you want to use Global Catalog and  continue?",”Information”,3,"Warning")
                                    if($MsgBox -eq "Yes")
                                    {
                                        if($global:strDC.contains(":"))
                                        {
                                            $global:strDC = $global:strDC.split(":")[0] + ":3268"
                                        }
                                        else
                                        {
                                            $global:strDC = $global:strDC + ":3268"
                                        }
                                       
                                    }
                                    else
                                    {
                                        $bolContinue = $false
                                    }

                                }
                                else
                                {
                                    $MsgBox = [System.Windows.Forms.MessageBox]::Show("You are not connected to the forest root domain: $global:ForestRootDomainDN.",”Information”,0,"Warning")
                                    $bolContinue = $false
                                }
                            }

                        }
                        

                        if($txtReplaceDN.text.Length -gt 0)
                        {
		                    $strOUcol = ($strOUcol -Replace $txtReplaceDN.text,$global:strDomainDNName)

                        }
                        $sADobjectName = $strOUcol
                        #Verify if the connection can be done
                        if($bolContinue)
                        {
                            $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC,$global:CREDS)
                            $LDAPConnection.SessionOptions.ReferralChasing = "None"
                            $request = New-Object System.directoryServices.Protocols.SearchRequest
                            if($global:bolShowDeleted)
                            {
                                [string] $LDAP_SERVER_SHOW_DELETED_OID = "1.2.840.113556.1.4.417"
                                [void]$request.Controls.Add((New-Object "System.DirectoryServices.Protocols.DirectoryControl" -ArgumentList "$LDAP_SERVER_SHOW_DELETED_OID",$null,$false,$true ))
                            }
                            $request.DistinguishedName = $sADobjectName
                            $request.Filter = "(name=*)"
                            $request.Scope = "Base"
                            [void]$request.Attributes.Add("name")
                            [void]$request.Attributes.Add("distinguishedname")
                   
                            $response = $LDAPConnection.SendRequest($request)

                            $ADobject = $response.Entries[0]
                            $strNode = fixfilename $ADobject.attributes.name[0]
                        }
                        else
                        {
                            #Set the node to empty , no connection will be done
                            $strNode = ""
                        }
                    }
                    #if not is empty continue
                   if($strNode -ne "")
                   {
	                   $strFileHTA = $env:temp + "\ACLHTML.hta" 
	                   $strFileHTM = $env:temp + "\"+"$global:strDomainShortName-$strNode"+".htm" 
	                   CreateHTM "$global:strDomainShortName-$strNode" $strFileHTM					
                       CreateHTA "$global:strDomainShortName-$strNode" $strFileHTA $strFileHTM $CurrentFSPath

           
	                   InitiateHTM $strFileHTA $strNode $txtBoxSelected.Text.ToString() $chkBoxReplMeta.IsChecked $chkBoxACLsize.IsChecked $chkBoxGetOUProtected.IsChecked $chkBoxEffectiveRightsColor.IsChecked $true $BolSkipDefPerm $BolSkipProtectedPerm $strCompareFile $chkBoxFilter.isChecked $chkBoxEffectiveRights.isChecked $chkBoxObjType.isChecked
	                   InitiateHTM $strFileHTM $strNode $txtBoxSelected.Text.ToString() $chkBoxReplMeta.IsChecked $chkBoxACLsize.IsChecked $chkBoxGetOUProtected.IsChecked $chkBoxEffectiveRightsColor.IsChecked $true $BolSkipDefPerm $BolSkipProtectedPerm $strCompareFile $chkBoxFilter.isChecked $chkBoxEffectiveRights.isChecked $chkBoxObjType.isChecked
			           $bolTranslateGUIDStoObject = $false
	                   If (($txtBoxSelected.Text.ToString().Length -gt 0) -or (($chkBoxTemplateNodes.IsChecked -eq $true))){
                            If ($rdbBase.IsChecked -eq $False)
		                    {

                                If ($rdbSubtree.IsChecked -eq $true)
		                        {
                                    if ($chkBoxTemplateNodes.IsChecked -eq $false)
                                    {
			                            $allSubOU = GetAllChildNodes $txtBoxSelected.Text $true
                                    }
                                    Get-PermCompare $allSubOU $BolSkipDefPerm $BolSkipProtectedPerm $chkBoxReplMeta.IsChecked $chkBoxGetOwner.IsChecked $chkBoxGetOUProtected.IsChecked $chkBoxACLsize.IsChecked $bolTranslateGUIDStoObject
                                }
                                else
                                {
			                        if ($chkBoxTemplateNodes.IsChecked -eq $false)
                                    {
                                    $allSubOU = GetAllChildNodes $txtBoxSelected.Text $false
                                    }
                                    Get-PermCompare $allSubOU $BolSkipDefPerm $BolSkipProtectedPerm $chkBoxReplMeta.IsChecked $chkBoxGetOwner.IsChecked $chkBoxGetOUProtected.IsChecked $chkBoxACLsize.IsChecked $bolTranslateGUIDStoObject
                                }	    
                            }
		                  else
		                  {
                            if ($chkBoxTemplateNodes.IsChecked -eq $false)
                            {
			                    $allSubOU = @($txtBoxSelected.Text)
                            }
                            Get-PermCompare $allSubOU $BolSkipDefPerm $BolSkipProtectedPerm $chkBoxReplMeta.IsChecked $chkBoxGetOwner.IsChecked $chkBoxGetOUProtected.IsChecked $chkBoxACLsize.IsChecked $bolTranslateGUIDStoObject
		                  }# End If
		                  $global:observableCollection.Insert(0,(LogMessage -strMessage "Finished" -strType "Info" -DateStamp ))
	                   }# End If
                    }
                    else
                    {
                        $global:observableCollection.Insert(0,(LogMessage -strMessage "Could not connect to $sADobjectName" -strType "Error" -DateStamp ))
                    }#End if not is empty
                }#else if test column names exist
                    else
                    {
                        $global:observableCollection.Insert(0,(LogMessage -strMessage "CSV file got wrong format! File:  $strCompareFile" -strType "Error" -DateStamp ))
                    } #End if test column names exist 
                } # End If Verify that a successful CSV import is performed before continue 
           }#End If $chkBoxEffectiveRights.isChecked  -or $chkBoxFilter.isChecked
    
        }#End If Test-Path
        else
        {
            $global:observableCollection.Insert(0,(LogMessage -strMessage "CSV file not found!" -strType "Error" -DateStamp ))
        }#End If Test-Path Else
    }# End If          

    #Restore the DC string to its original
    $global:strDC = $global:ResetDCvalue
}
else
{
        $global:observableCollection.Insert(0,(LogMessage -strMessage "No object selected!" -strType "Error" -DateStamp ))
}
$allSubOU = ""
$strFileCSV = ""
$strFileHTA = ""
$strFileHTM = ""
$sADobjectName = ""
$date= ""
}
function RunScan
{

$bolPreChecks = $true
If ($txtBoxSelected.Text)
{
    If(($chkBoxFilter.IsChecked -eq $true) -and  (($chkBoxType.IsChecked -eq $false) -and ($chkBoxObject.IsChecked -eq $false) -and ($chkBoxTrustee.IsChecked -eq  $false)))
    {
                   
                   $global:observableCollection.Insert(0,(LogMessage -strMessage "Filter Enabled , but no filter is specified!" -strType "Error" -DateStamp ))
                   $bolPreChecks = $false
    }
    else
    {
        If(($chkBoxFilter.IsChecked -eq $true) -and  (($combAccessCtrl.SelectedIndex -eq -1) -and ($combObjectFilter.SelectedIndex -eq -1) -and ($txtFilterTrustee.Text -eq  "")))
        {
                       
                       $global:observableCollection.Insert(0,(LogMessage -strMessage "Filter Enabled , but no filter is specified!" -strType "Error" -DateStamp ))
                       $bolPreChecks = $false
        }
    }
    
        If(($chkBoxEffectiveRights.IsChecked -eq $true) -and  ($global:tokens.count -eq 0))
    {
                    
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Effective rights enabled , but no service principal selected!" -strType "Error" -DateStamp ))
                    $bolPreChecks = $false
    }
    $global:intShowCriticalityLevel = 0
    if ($bolPreChecks -eq $true)
    {
        $strCompareFile = ""
        $allSubOU = New-Object System.Collections.ArrayList
        $allSubOU.Clear()
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Scanning..." -strType "Info" -DateStamp ))
	    $BolSkipDefPerm = $chkBoxDefaultPerm.IsChecked
        $BolSkipProtectedPerm =  $chkBoxSkipProtectedPerm.IsChecked
        $global:bolProgressBar = $chkBoxSkipProgressBar.IsChecked
	    $bolCSV = $rdbHTAandCSV.IsChecked

        $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC,$global:CREDS)
        $LDAPConnection.SessionOptions.ReferralChasing = "None"
        $request = New-Object System.directoryServices.Protocols.SearchRequest
        if($global:bolShowDeleted)
        {
            [string] $LDAP_SERVER_SHOW_DELETED_OID = "1.2.840.113556.1.4.417"
            [void]$request.Controls.Add((New-Object "System.DirectoryServices.Protocols.DirectoryControl" -ArgumentList "$LDAP_SERVER_SHOW_DELETED_OID",$null,$false,$true ))
        }
        $request.DistinguishedName = $txtBoxSelected.Text.ToString().Replace("/", "\/")
        $request.Filter = "(name=*)"
        $request.Scope = "Base"
        [void]$request.Attributes.Add("name")
        [void]$request.Attributes.Add("distinguishedname")
        $response = $LDAPConnection.SendRequest($request)
        $ADobject = $response.Entries[0]
        #Verify that attributes can be read
        if($null -ne $ADobject.Attributes.name)
        {
	        $strNode = $ADobject.Attributes.name[0]
            $bolTranslateGUIDStoObject = $false
            $date= get-date -uformat %Y%m%d_%H%M%S
            $strNode = fixfilename $strNode
	        $strFileCSV = $txtTempFolder.Text + "\" +$strNode + "_" + $global:strDomainShortName + "_adAclOutput" + $date + ".csv" 
	        $strFileHTA = $env:temp + "\ACLHTML.hta" 
	        $strFileHTM = $env:temp + "\"+"$global:strDomainShortName-$strNode"+".htm" 	
            if(!($rdbOnlyCSV.IsChecked))
            {			
                if ($chkBoxFilter.IsChecked)
                {
		            CreateHTA "$global:strDomainShortName-$strNode Filtered" $strFileHTA  $strFileHTM $CurrentFSPath
		            CreateHTM "$global:strDomainShortName-$strNode Filtered" $strFileHTM	
                }
                else
                {
                    CreateHTA "$global:strDomainShortName-$strNode" $strFileHTA $strFileHTM $CurrentFSPath
		            CreateHTM "$global:strDomainShortName-$strNode" $strFileHTM	
                }

	            InitiateHTM $strFileHTA $strNode $txtBoxSelected.Text.ToString() $chkBoxReplMeta.IsChecked $chkBoxACLsize.IsChecked $chkBoxGetOUProtected.IsChecked $chkBoxEffectiveRightsColor.IsChecked $false $BolSkipDefPerm $BolSkipProtectedPerm $strCompareFile $chkBoxFilter.isChecked $chkBoxEffectiveRights.isChecked $chkBoxObjType.isChecked
	            InitiateHTM $strFileHTM $strNode $txtBoxSelected.Text.ToString() $chkBoxReplMeta.IsChecked $chkBoxACLsize.IsChecked $chkBoxGetOUProtected.IsChecked $chkBoxEffectiveRightsColor.IsChecked $false $BolSkipDefPerm $BolSkipProtectedPerm $strCompareFile $chkBoxFilter.isChecked $chkBoxEffectiveRights.isChecked $chkBoxObjType.isChecked
            }			
	        If ($txtBoxSelected.Text.ToString().Length -gt 0)
            {
		        If ($rdbBase.IsChecked -eq $False)
		        {
                    If ($rdbSubtree.IsChecked -eq $true)
		            {
			            $allSubOU = GetAllChildNodes $txtBoxSelected.Text $true
                        Get-Perm $allSubOU $global:strDomainShortName $BolSkipDefPerm $BolSkipProtectedPerm $chkBoxFilter.IsChecked $chkBoxGetOwner.IsChecked $rdbOnlyCSV.IsChecked $chkBoxReplMeta.IsChecked $chkBoxACLsize.IsChecked $chkBoxEffectiveRights.IsChecked $chkBoxGetOUProtected.IsChecked $bolTranslateGUIDStoObject
                    }
                    else
                    {
			        
                        $allSubOU = GetAllChildNodes $txtBoxSelected.Text $false
                        Get-Perm $allSubOU $global:strDomainShortName $BolSkipDefPerm $BolSkipProtectedPerm $chkBoxFilter.IsChecked $chkBoxGetOwner.IsChecked $rdbOnlyCSV.IsChecked $chkBoxReplMeta.IsChecked $chkBoxACLsize.IsChecked $chkBoxEffectiveRights.IsChecked $chkBoxGetOUProtected.IsChecked $bolTranslateGUIDStoObject
                    }	    
                }
		        else
		        {
			        $allSubOU = @($txtBoxSelected.Text)
                    Get-Perm $allSubOU $global:strDomainShortName $BolSkipDefPerm $BolSkipProtectedPerm $chkBoxFilter.IsChecked $chkBoxGetOwner.IsChecked $rdbOnlyCSV.IsChecked $chkBoxReplMeta.IsChecked $chkBoxACLsize.IsChecked $chkBoxEffectiveRights.IsChecked $chkBoxGetOUProtected.IsChecked $bolTranslateGUIDStoObject
		        }
		        
	        }
        }
        else
        {
                $global:observableCollection.Insert(0,(LogMessage -strMessage "Could not read object $($txtBoxSelected.Text.ToString()). Enough permissions?" -strType "Error" -DateStamp ))
        }
    }
}
else
{
        $global:observableCollection.Insert(0,(LogMessage -strMessage "No object selected!" -strType "Error" -DateStamp ))
}
$global:observableCollection.Insert(0,(LogMessage -strMessage "Finished" -strType "Info" -DateStamp ))

$allSubOU = ""
$strFileCSV = ""
$strFileHTA = ""
$strFileHTM = ""
$sADobjectName = ""
$date= ""

}
function Get-XMLPath
{
Param($xmlElement)
    $Path = ""

    $FQDN = $xmlElement.Text

    return $FQDN
}

function AddXMLAttribute
{
    Param([ref]$node, $szName, $value)
	$attribute = $global:xmlDoc.createAttribute($szName);
	[void]$node.value.setAttributeNode($attribute);
	$node.value.setAttribute($szName, $value);
	#return $node;
}

function Add-ExcludeChild
{

    # Test if any node is selected
    if($txtBoxSelected.Text.Length -gt 0)
    {
        if($txtBoxExcluded.Text.Length -gt 0)
        {
            $txtBoxExcluded.Text = $txtBoxExcluded.Text + ";" + $txtBoxSelected.Text 
        }
        else
        {
            $txtBoxExcluded.Text =  $txtBoxSelected.Text
        }

    }

}

function Add-RefreshChild
{

    # Test if any node is selected
    if($txtBoxSelected.Text.Length -gt 0)
    {
        $xmlNode = $global:xmlDoc
        $NodeDNPath = $txtBoxSelected.Text

        if($global:TreeViewRootPath -eq $NodeDNPath)
        {
            $Mynodes = $xmlNode.SelectSingleNode("//DomainRoot[@Text='$NodeDNPath']")
            # Make sure a node was found
            if($Mynodes.Name.Length -gt 0)
            {
                $Mynodes.IsEmpty = $true
                $treeNodePath = $NodeDNPath.Replace("/", "\/")
       
                # Initialize and Build Domain OU Tree 

                ProcessOUTree -node $($Mynodes) -ADSObject $treeNodePath #-nodeCount 0 
                # Set tag to show this node is already enumerated 

            }
        }
        else
        {
            $Mynodes = $xmlNode.SelectSingleNode("//OU[@Text='$NodeDNPath']")
            # Make sure a node was found
            if($Mynodes.Name.Length -gt 0)
            {
                $Mynodes.IsEmpty = $true
                $treeNodePath = $NodeDNPath.Replace("/", "\/")
       
                # Initialize and Build Domain OU Tree 
                ProcessOUTree -node $($Mynodes) -ADSObject $treeNodePath #-nodeCount 0 
                # Set tag to show this node is already enumerated 

            }
        }
    }

}

#  Processes an OU tree

function ProcessOUTree
{

	Param($node, $ADSObject)

	# Increment the node count to indicate we are done with the domain level
 
	$strFilterOUCont = "(&(|(objectClass=organizationalUnit)(objectClass=container)))"
	$strFilterAll = "(&(!msds-nctype=*))"

    $PageSize=100
    $TimeoutSeconds = 120


    $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
    $LDAPConnection.SessionOptions.ReferralChasing = "None"
    $request = New-Object System.directoryServices.Protocols.SearchRequest
    [System.DirectoryServices.Protocols.PageResultRequestControl]$pagedRqc = new-object System.DirectoryServices.Protocols.PageResultRequestControl($pageSize)
    $request.Controls.Add($pagedRqc) | Out-Null    
    
    if($global:bolShowDeleted)
    {
        [string] $LDAP_SERVER_SHOW_DELETED_OID = "1.2.840.113556.1.4.417"
        [void]$request.Controls.Add((New-Object "System.DirectoryServices.Protocols.DirectoryControl" -ArgumentList "$LDAP_SERVER_SHOW_DELETED_OID",$null,$false,$true ))
    }
    $request.DistinguishedName = $ADSObject


    # Single line Directory searcher
    # set a filter



	If ($rdbBrowseAll.IsChecked -eq $true)
	{
	$request.Filter = $strFilterAll
		
	}
	else
	{
 	$request.Filter = $strFilterOUCont
	}
    # set search scope
    $request.Scope = "OneLevel"

    #$response.PropertiesToLoad.addrange(('cn','distinguishedName'))
    [void]$request.Attributes.Add("name")
    [void]$request.Attributes.Add("cn")
    [void]$request.Attributes.Add("distinguishedname")
    [void]$request.Attributes.Add("objectclass")
    
    $response = $LDAPConnection.SendRequest($request)

	# Now walk the list and recursively process each child
        while ($true)
        {
            $response = $LdapConnection.SendRequest($request, (new-object System.Timespan(0,0,$TimeoutSeconds))) -as [System.DirectoryServices.Protocols.SearchResponse];
                
            #for paged search, the response for paged search result control - we will need a cookie from result later
            if($pageSize -gt 0) {
                [System.DirectoryServices.Protocols.PageResultResponseControl] $prrc=$null;
                if ($response.Controls.Length -gt 0)
                {
                    foreach ($ctrl in $response.Controls)
                    {
                        if ($ctrl -is [System.DirectoryServices.Protocols.PageResultResponseControl])
                        {
                            $prrc = $ctrl;
                            break;
                        }
                    }
                }
                if($null -eq $prrc) {
                    #server was unable to process paged search
                    throw "Find-LdapObject: Server failed to return paged response for request $SearchFilter"
                }
            }
            #now process the returned list of distinguishedNames and fetch required properties using ranged retrieval
            $colResults = $response.Entries
	        foreach ($objResult in $colResults)
	        {             
		    
                if ($objResult.attributes.Count -ne 0)
                {
		            $NewOUNode = $global:xmlDoc.createElement("OU");
            
                    # Add an Attribute for the Name

                    if (($null -ne $($objResult.attributes.name[0])))
		            {

                        # Add an Attribute for the Name
                        $OUName = "$($objResult.attributes.name[0])"
        
                        AddXMLAttribute -node ([ref]$NewOUNode) -szName "Name" -value $OUName
                        $DNName = $objResult.attributes.distinguishedname[0]
                            AddXMLAttribute -node ([ref]$NewOUNode) -szName "Text" -value $DNName
                             Switch ($objResult.attributes.objectclass[$objResult.attributes.objectclass.count-1])
                            {
                            "domainDNS"
                            {
                            AddXMLAttribute -node ([ref]$NewOUNode) -szName "Img" -value "$env:temp\DomainDNS.png"
                            }
                            "OrganizationalUnit"
                            {
                            AddXMLAttribute -node ([ref]$NewOUNode) -szName "Img" -value "$env:temp\OU.png"
                            }
                            "user"
                            {
                             AddXMLAttribute -node ([ref]$NewOUNode) -szName "Img" -value "$env:temp\User.png"
                            }
                            "group"
                            {
                            AddXMLAttribute -node ([ref]$NewOUNode) -szName "Img" -value "$env:temp\Group.png"
                            }
                            "computer"
                            {
                            AddXMLAttribute -node ([ref]$NewOUNode) -szName "Img" -value "$env:temp\Computer.png"
                            }
                            "container"
                            {
                            AddXMLAttribute -node ([ref]$NewOUNode) -szName "Img" -value "$env:temp\Container.png"
                            }
                            default
                            {
                            AddXMLAttribute -node ([ref]$NewOUNode) -szName "Img" -value "$env:temp\Other.png"
                            }
                        }
                        AddXMLAttribute -node ([ref]$NewOUNode) -szName "Tag" -value "Enumerated"
   
		                $child = $node.appendChild($NewOUNode);

                        ProcessOUTreeStep2OnlyShow -node $NewOUNode -DNName $DNName
                           }
                    else
                    {
                        $global:observableCollection.Insert(0,(LogMessage -strMessage "Could not read object $($objResult.distinguishedname)" -strType "Error" -DateStamp ))
                    }
                }
                else
                {
                 if ($null -ne $objResult.distinguishedname)
		            {

                        # Add an Attribute for the Name
                        $DNName = $objResult.distinguishedname
                        $OUName = $DNName.toString().Split(",")[0]
                        if($OUName -match "=")
                        {
                        $OUName = $OUName.Split("=")[1]
                        }
        
                        AddXMLAttribute -node ([ref]$NewOUNode) -szName "Name" -value $OUName
                
                        AddXMLAttribute -node ([ref]$NewOUNode) -szName "Text" -value $DNName
                        AddXMLAttribute -node ([ref]$NewOUNode) -szName "Img" -value "$env:temp\Container.png"
                        AddXMLAttribute -node ([ref]$NewOUNode) -szName "Tag" -value "Enumerated"
   
                        $child = $node.appendChild($NewOUNode);

                        ProcessOUTreeStep2OnlyShow -node $NewOUNode -DNName $DNName
                    }

                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Could not read object $($objResult.distinguishedname). Enough permissions?" -strType "Warning" -DateStamp ))
                }

            }
            if($pageSize -gt 0) {
                if ($prrc.Cookie.Length -eq 0) {
                    #last page --> we're done
                    break;
                }
                #pass the search cookie back to server in next paged request
                $pagedRqc.Cookie = $prrc.Cookie;
            } else {
                #exit the processing for non-paged search
                break;
            }
        }


}
function ProcessOUTreeStep2OnlyShow
{
    Param($node, $DNName)

	# Increment the node count to indicate we are done with the domain level

    $strFilterOUCont = "(&(|(objectClass=organizationalUnit)(objectClass=container)))"
	$strFilterAll = "(&(name=*))"

   # $sADobjectName = "LDAP://$global:strDC/" + $DNName.Replace("/", "\/")
    
    $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
    $LDAPConnection.SessionOptions.ReferralChasing = "None"
    $request = New-Object System.directoryServices.Protocols.SearchRequest
    if($global:bolShowDeleted)
    {
        [string] $LDAP_SERVER_SHOW_DELETED_OID = "1.2.840.113556.1.4.417"
        [void]$request.Controls.Add((New-Object "System.DirectoryServices.Protocols.DirectoryControl" -ArgumentList "$LDAP_SERVER_SHOW_DELETED_OID",$null,$false,$true ))
    }
    $request.distinguishedName = $DNName 


    # Single line Directory searcher
    # set a filter

	If ($rdbBrowseAll.IsChecked -eq $true)
	{
	$request.Filter = $strFilterAll
		
	}
	else
	{
 	$request.Filter = $strFilterOUCont
	}

    # set search scope
    $request.Scope = "oneLevel"

    # set SizeLimit 
    $request.SizeLimit = 999
    [void]$request.Attributes.Add("name")
    [void]$request.Attributes.Add("cn")
    [void]$request.Attributes.Add("distinguishedname")
    #$dirSearch.PropertiesToLoad.addrange(('cn','distinguishedName'))	
    # execute query
    &{#Try
        $response = $LDAPConnection.SendRequest($request)
        $global:DirSrchResults = $response.Entries[0]
	    #$global:DirSrchResults  = $response.FindOne()
    }
    Trap [SystemException]
    {
        $_
        $global:DirSrchResults = $false
    }
	# Now walk the list and recursively process each child


    if ($global:DirSrchResults)
    {


        if ($null -ne $global:DirSrchResults.attributes)
        {
		    

            # Add an Attribute for the Name
            $NewOUNode = $global:xmlDoc.createElement("OU");
            # Add an Attribute for the Name
                
            AddXMLAttribute -node ([ref]$NewOUNode) -szName "Name" -value "Click ..."
            
            AddXMLAttribute -node ([ref]$NewOUNode) -szName "Text" -value "Click ..."
            AddXMLAttribute -node ([ref]$NewOUNode) -szName "Img" -value "$env:temp\Expand.png"
            AddXMLAttribute -node ([ref]$NewOUNode) -szName "Tag" -value "NotEnumerated"

		    [void]$node.appendChild($NewOUNode);
          
        }
        else
        {
              
            $global:observableCollection.Insert(0,(LogMessage -strMessage "At least one child object could not be accessed: $DNName" -strType "Warning" -DateStamp ))
            # Add an Attribute for the Name
            $NewOUNode = $global:xmlDoc.createElement("OU");
            # Add an Attribute for the Name
                
            AddXMLAttribute -node ([ref]$NewOUNode) -szName "Name" -value "Click ..."
            
            AddXMLAttribute -node ([ref]$NewOUNode) -szName "Text" -value "Click ..."
            AddXMLAttribute -node ([ref]$NewOUNode) -szName "Img" -value "$env:temp\Expand.png"
            AddXMLAttribute -node ([ref]$NewOUNode) -szName "Tag" -value "NotEnumerated"

		    [void]$node.appendChild($NewOUNode);
        }

	}	


}
function Get-XMLDomainOUTree
{

    param
    (
        $szDomainRoot
    )



    $treeNodePath = $szDomainRoot.Replace("/", "\/")

   
    # Initialize and Build Domain OU Tree 
    
    $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
    $LDAPConnection.SessionOptions.ReferralChasing = "None"
    $request = New-Object System.directoryServices.Protocols.SearchRequest
    if($global:bolShowDeleted)
    {
        [string] $LDAP_SERVER_SHOW_DELETED_OID = "1.2.840.113556.1.4.417"
        [void]$request.Controls.Add((New-Object "System.DirectoryServices.Protocols.DirectoryControl" -ArgumentList "$LDAP_SERVER_SHOW_DELETED_OID",$null,$false,$true ))
    }

    $request.distinguishedName = $treeNodePath 
    $request.filter = "(name=*)"
    $request.Scope = "base"
    [void]$request.Attributes.Add("name")
    [void]$request.Attributes.Add("distinguishedname")
    [void]$request.Attributes.Add("objectclass")
    $response = $LDAPConnection.SendRequest($request)
    $DomainRoot = $response.Entries[0]
    if($DomainRoot.attributes.count -ne 0)
    {
        $DNName = $DomainRoot.attributes.distinguishedname[0]
        $strObClass = $DomainRoot.attributes.objectclass[$DomainRoot.attributes.objectclass.count-1]
    }
    else
    {
        $DNName = $DomainRoot.distinguishedname
        $strObClass = "container"
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Could not read object $DNName . Enough permissions?" -strType "Error" -DateStamp ))
    }
    $global:xmlDoc = New-Object -TypeName System.Xml.XmlDocument
    $global:xmlDoc.PreserveWhitespace = $false

    $RootNode = $global:xmlDoc.createElement("DomainRoot")
    AddXMLAttribute -Node ([ref]$RootNode) -szName "Name" -value $szDomainRoot
    AddXMLAttribute -node ([ref]$RootNode) -szName "Text" -value $DNName
    AddXMLAttribute -node ([ref]$RootNode) -szName "Icon" -value "$env:temp\refresh2.png"
    AddXMLAttribute -node ([ref]$RootNode) -szName "Icon2" -value "$env:temp\exclude.png"

     Switch ($strObClass)
                {
                "domainDNS"
                {
                AddXMLAttribute -node ([ref]$RootNode) -szName "Img" -value "$env:temp\DomainDNS.png"
                }
                "OrganizationalUnit"
                {
                AddXMLAttribute -node ([ref]$RootNode) -szName "Img" -value "$env:temp\OU.png"
                }
                "user"
                {
                 AddXMLAttribute -node ([ref]$RootNode) -szName "Img" -value "$env:temp\User.png"
                }
                "group"
                {
                AddXMLAttribute -node ([ref]$RootNode) -szName "Img" -value "$env:temp\Group.png"
                }
                "computer"
                {
                AddXMLAttribute -node ([ref]$RootNode) -szName "Img" -value "$env:temp\Computer.png"
                }
                "container"
                {
                AddXMLAttribute -node ([ref]$RootNode) -szName "Img" -value "$env:temp\Container.png"
                }
                default
                {
                AddXMLAttribute -node ([ref]$RootNode) -szName "Img" -value "$env:temp\Other.png"
                }
            }
    [void]$global:xmlDoc.appendChild($RootNode)
    
    $node = $global:xmlDoc.documentElement;

    #Process the OU tree
    ProcessOUTree -node $node -ADSObject $treeNodePath  #-nodeCount 0

    return $global:xmlDoc
}







$global:dicRightsGuids = @{"Seed" = "xxx"}
$global:dicSidToName = @{"Seed" = "xxx"} 
$global:dicDCSpecialSids =@{"BUILTIN\Incoming Forest Trust Builders"="S-1-5-32-557";`
"BUILTIN\Account Operators"="S-1-5-32-548";`
"BUILTIN\Server Operators"="S-1-5-32-549";`
"BUILTIN\Pre-Windows 2000 Compatible Access"="S-1-5-32-554";`
"BUILTIN\Terminal Server License Servers"="S-1-5-32-561";`
"BUILTIN\Windows Authorization Access Group"="S-1-5-32-560"}
$global:dicWellKnownSids = @{"S-1-0"="Null Authority";`
"S-1-0-0"="Nobody";`
"S-1-1"="World Authority";`
"S-1-1-0"="Everyone";`
"S-1-2"="Local Authority";`
"S-1-2-0"="Local ";`
"S-1-2-1"="Console Logon ";`
"S-1-3"="Creator Authority";`
"S-1-3-0"="Creator Owner";`
"S-1-3-1"="Creator Group";`
"S-1-3-2"="Creator Owner Server";`
"S-1-3-3"="Creator Group Server";`
"S-1-3-4"="Owner Rights";`
"S-1-4"="Non-unique Authority";`
"S-1-5"="NT Authority";`
"S-1-5-1"="Dialup";`
"S-1-5-2"="Network";`
"S-1-5-3"="Batch";`
"S-1-5-4"="Interactive";`
"S-1-5-6"="Service";`
"S-1-5-7"="Anonymous";`
"S-1-5-8"="Proxy";`
"S-1-5-9"="Enterprise Domain Controllers";`
"S-1-5-10"="Principal Self";`
"S-1-5-11"="Authenticated Users";`
"S-1-5-12"="Restricted Code";`
"S-1-5-13"="Terminal Server Users";`
"S-1-5-14"="Remote Interactive Logon";`
"S-1-5-15"="This Organization";`
"S-1-5-17"="IUSR";`
"S-1-5-18"="Local System";`
"S-1-5-19"="NT Authority";`
"S-1-5-20"="NT Authority";`
"S-1-5-22"="ENTERPRISE READ-ONLY DOMAIN CONTROLLERS BETA";`
"S-1-5-32-544"="Administrators";`
"S-1-5-32-545"="Users";`
"S-1-5-32-546"="Guests";`
"S-1-5-32-547"="Power Users";`
"S-1-5-32-548"="BUILTIN\Account Operators";`
"S-1-5-32-549"="Server Operators";`
"S-1-5-32-550"="Print Operators";`
"S-1-5-32-551"="Backup Operators";`
"S-1-5-32-552"="Replicator";`
"S-1-5-32-554"="BUILTIN\Pre-Windows 2000 Compatible Access";`
"S-1-5-32-555"="BUILTIN\Remote Desktop Users";`
"S-1-5-32-556"="BUILTIN\Network Configuration Operators";`
"S-1-5-32-557"="BUILTIN\Incoming Forest Trust Builders";`
"S-1-5-32-558"="BUILTIN\Performance Monitor Users";`
"S-1-5-32-559"="BUILTIN\Performance Log Users";`
"S-1-5-32-560"="BUILTIN\Windows Authorization Access Group";`
"S-1-5-32-561"="BUILTIN\Terminal Server License Servers";`
"S-1-5-32-562"="BUILTIN\Distributed COM Users";`
"S-1-5-32-568"="BUILTIN\IIS_IUSRS";`
"S-1-5-32-569"="BUILTIN\Cryptographic Operators";`
"S-1-5-32-573"="BUILTIN\Event Log Readers ";`
"S-1-5-32-574"="BUILTIN\Certificate Service DCOM Access";`
"S-1-5-32-575"="BUILTIN\RDS Remote Access Servers";`
"S-1-5-32-576"="BUILTIN\RDS Endpoint Servers";`
"S-1-5-32-577"="BUILTIN\RDS Management Servers";`
"S-1-5-32-578"="BUILTIN\Hyper-V Administrators";`
"S-1-5-32-579"="BUILTIN\Access Control Assistance Operators";`
"S-1-5-32-580"="BUILTIN\Remote Management Users";`
"S-1-5-33"="Write Restricted Code";`
"S-1-5-64-10"="NTLM Authentication";`
"S-1-5-64-14"="SChannel Authentication";`
"S-1-5-64-21"="Digest Authentication";`
"S-1-5-65-1"="This Organization Certificate";`
"S-1-5-80"="NT Service";`
"S-1-5-84-0-0-0-0-0"="User Mode Drivers";`
"S-1-5-113"="Local Account";`
"S-1-5-114"="Local Account And Member Of Administrators Group";`
"S-1-5-1000"="Other Organization";`
"S-1-15-2-1"="All App Packages";`
"S-1-16-0"="Untrusted Mandatory Level";`
"S-1-16-4096"="Low Mandatory Level";`
"S-1-16-8192"="Medium Mandatory Level";`
"S-1-16-8448"="Medium Plus Mandatory Level";`
"S-1-16-12288"="High Mandatory Level";`
"S-1-16-16384"="System Mandatory Level";`
"S-1-16-20480"="Protected Process Mandatory Level";`
"S-1-16-28672"="Secure Process Mandatory Level";`
"S-1-18-1"="Authentication Authority Asserted Identityl";`
"S-1-18-2"="Service Asserted Identity"}

#==========================================================================
# Function		: LogMessage 
# Arguments     : Type of message, message, date stamping
# Returns   	: Custom psObject with two properties, type and message
# Description   : This function creates a custom object that is used as input to an ListBox for logging purposes
# 
#==========================================================================
function LogMessage 
{ 
     param ( 
         [Parameter(  
             Mandatory = $true
          )][String[]] $strType="Error" ,
        
        [Parameter(  
             Mandatory = $true 
          )][String[]]  $strMessage ,

       [Parameter(  
             Mandatory = $false
         )][switch]$DateStamp
     )
     
     process {

                if ($DateStamp)
                {

                    $newMessageObject = New-Object PSObject -Property @{Type="$strType";Message="[$(get-date)] $strMessage"}
                }
                else
                {

                    $newMessageObject = New-Object PSObject -Property @{Type="$strType";Message="$strMessage"}
                }

         
                return $newMessageObject
            }
 } 

#==========================================================================
# Function		: ConvertTo-ObjectArrayListFromPsCustomObject  
# Arguments     : Defined Object
# Returns   	: Custom Object List
# Description   : Convert a defined object to a custom, this will help you  if you got a read-only object 
# 
#==========================================================================
function ConvertTo-ObjectArrayListFromPsCustomObject 
{ 
     param ( 
         [Parameter(  
             Position = 0,   
             Mandatory = $true,   
             ValueFromPipeline = $true,  
             ValueFromPipelineByPropertyName = $true  
         )] $psCustomObject
     ); 
     
     process {
 
        $myCustomArray = New-Object System.Collections.ArrayList
     
         foreach ($myPsObject in $psCustomObject) { 
             $hashTable = @{}; 
             $myPsObject | Get-Member -MemberType *Property | ForEach-Object { 
                 $hashTable.($_.name) = $myPsObject.($_.name); 
             } 
             $Newobject = new-object psobject -Property  $hashTable
             [void]$myCustomArray.add($Newobject)
         } 
         return $myCustomArray
     } 
 } 

#==========================================================================
# Function		: GenerateTrustedDomainPicker
# Arguments     : -
# Returns   	: Domain DistinguishedName
# Description   : Windows Form List AD Domains in Forest 
#==========================================================================
Function GenerateTrustedDomainPicker
{
[xml]$TrustedDomainPickerXAML =@"
<Window x:Class="WpfApplication1.StatusBar"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="Window" Title="Locations" WindowStartupLocation = "CenterScreen"
        Width = "400" Height = "200" ShowInTaskbar = "False" ResizeMode="NoResize" WindowStyle="ToolWindow" Opacity="0.9">
    <Window.Background>
        <LinearGradientBrush>
            <LinearGradientBrush.Transform>
                <ScaleTransform x:Name="Scaler" ScaleX="1" ScaleY="1"/>
            </LinearGradientBrush.Transform>
            <GradientStop Color="#CC064A82" Offset="1"/>
            <GradientStop Color="#FF6797BF" Offset="0.7"/>
            <GradientStop Color="#FF6797BF" Offset="0.3"/>
            <GradientStop Color="#FFD4DBE1" Offset="0"/>
        </LinearGradientBrush>
    </Window.Background>
    <Grid>
        <StackPanel Orientation="Vertical">
            <Label x:Name="lblDomainPciker" Content="Select the location you want to search." Margin="10,05,00,00"/>
        <ListBox x:Name="objListBoxDomainList" HorizontalAlignment="Left" Height="78" Margin="10,05,0,0" VerticalAlignment="Top" Width="320"/>
        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
            <Button x:Name="btnOK" Content="OK" Margin="00,05,00,00" Width="50" Height="20"/>
            <Button x:Name="btnCancel" Content="Cancel" Margin="10,05,00,00" Width="50" Height="20"/>
        </StackPanel>
        </StackPanel>
    </Grid>
</Window>

"@

$TrustedDomainPickerXAML.Window.RemoveAttribute("x:Class") 

$reader=(New-Object System.Xml.XmlNodeReader $TrustedDomainPickerXAML)
$TrustedDomainPickerGui=[Windows.Markup.XamlReader]::Load( $reader )
$btnOK = $TrustedDomainPickerGui.FindName("btnOK")
$btnCancel = $TrustedDomainPickerGui.FindName("btnCancel")
$objListBoxDomainList = $TrustedDomainPickerGui.FindName("objListBoxDomainList")



$btnCancel.add_Click(
{
$TrustedDomainPickerGui.Close()
})

$btnOK.add_Click({
$global:strDomainPrinDNName=$objListBoxDomainList.SelectedItem

if ( $global:strDomainPrinDNName -eq $global:strDomainLongName )
{
    $lblSelectPrincipalDom.Content = $global:strDomainShortName+":"
}
else
{
    $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
    $LDAPConnection.SessionOptions.ReferralChasing = "None"
    $request = New-Object System.directoryServices.Protocols.SearchRequest("CN=System,$global:strDomainDNName", "(&(trustPartner=$global:strDomainPrinDNName))", "Onelevel")
    [void]$request.Attributes.Add("trustdirection")
    [void]$request.Attributes.Add("trustattributes")
    [void]$request.Attributes.Add("flatname")
    $response = $LDAPConnection.SendRequest($request)
    $colResults = $response.Entries[0]

    if($null -ne $colResults)
    {
            $global:strPrinDomDir = $colResults.attributes.trustdirection[0]
            $global:strPrinDomAttr = "{0:X2}" -f [int]  $colResults.attributes.trustattributes[0]
            $global:strPrinDomFlat = $colResults.attributes.flatname[0].ToString()
            $lblSelectPrincipalDom.Content = $global:strPrinDomFlat+":"

    }

}
$TrustedDomainPickerGui.Close()
})
 

$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
$LDAPConnection.SessionOptions.ReferralChasing = "None"
$request = New-Object System.directoryServices.Protocols.SearchRequest("CN=System,$global:strDomainDNName", "(&(cn=*)(objectClass=trustedDomain))", "Onelevel") 
[void]$request.Attributes.Add("trustpartner")
$response = $LDAPConnection.SendRequest($request)
$colResults = $response.Entries

foreach ($objResult in $colResults)
{
    [void] $objListBoxDomainList.Items.Add($objResult.attributes.trustpartner[0])
}



[void] $objListBoxDomainList.Items.Add($global:strDomainLongName)

$TrustedDomainPickerGui.ShowDialog()

}
#==========================================================================
# Function		: GenerateSupportStatement 
# Arguments     : -
# Returns   	: Support 
# Description   : Generate Support Statement 
#==========================================================================
Function GenerateSupportStatement
{
[xml]$SupportStatementXAML =@"
<Window x:Class="WpfApplication1.StatusBar"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="Window" Title="Support Statement" WindowStartupLocation = "CenterScreen"
        Width = "400" Height = "500" ShowInTaskbar = "False" ResizeMode="NoResize" WindowStyle="ToolWindow"  Background="#FFF0F0F0">
    <Grid HorizontalAlignment="Center">
        <StackPanel Orientation="Vertical"  Margin="0,0,00,0" HorizontalAlignment="Center">
            <Label x:Name="lblSupportHeader" Content="Carefully read and understand the support statement." Height="25" Width="350" FontSize="12" />
            <Label x:Name="lblSupportStatement" Content="" Height="380"  Width="370" FontSize="12" Background="White" BorderBrush="#FFC9C9CA" BorderThickness="1,1,1,1" FontWeight="Bold"/>
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                <Button x:Name="btnOK" Content="OK" Margin="00,10,00,00" Width="50" Height="20"/>
            </StackPanel>
        </StackPanel>
    </Grid>
</Window>

"@

$SupportStatementXAML.Window.RemoveAttribute("x:Class") 
$reader=(New-Object System.Xml.XmlNodeReader $SupportStatementXAML)
$SuportGui=[Windows.Markup.XamlReader]::Load( $reader )


$btnOK = $SuportGui.FindName("btnOK")
$lblSupportStatement = $SuportGui.FindName("lblSupportStatement")
$txtSupoprt = @"
THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT 
WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR
A PARTICULAR PURPOSE.

This sample is not supported under any Microsoft standard 
support program or service. The script is provided AS IS
without warranty of any kind. Microsoft further disclaims
all implied warranties including, without limitation, any
implied warranties of merchantability or of fitness for a
particular purpose.
The entire risk arising out of the use or performance of the
sample and documentation remains with you. In no event
shall Microsoft, its authors,or anyone else involved in the 
creation, production, or delivery of the script be liable 
for any damages whatsoever (including, without limitation,
damages for loss of business profits, business interruption,
loss of business information, or other pecuniary loss) 
arising out of the use of or inability to use the sample or
documentation, even if Microsoft has been advised of the 
possibility of such damages.
"@
$lblSupportStatement.Content = $txtSupoprt

$btnOK.add_Click(
{
$SuportGui.Close()
})




$SuportGui.ShowDialog()

}
#==========================================================================
# Function		: GenerateDomainPicker 
# Arguments     : -
# Returns   	: Domain DistinguishedName
# Description   : Windows Form List AD Domains in Forest 
#==========================================================================
Function GenerateDomainPicker
{
[xml]$DomainPickerXAML =@"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="Window" Title="Select a domain" WindowStartupLocation = "CenterScreen"
        Width = "400" Height = "200" ShowInTaskbar = "False" ResizeMode="NoResize" WindowStyle="ToolWindow" Opacity="0.9">
    <Window.Background>
        <LinearGradientBrush>
            <LinearGradientBrush.Transform>
                <ScaleTransform x:Name="Scaler" ScaleX="1" ScaleY="1"/>
            </LinearGradientBrush.Transform>
            <GradientStop Color="#CC064A82" Offset="1"/>
            <GradientStop Color="#FF6797BF" Offset="0.7"/>
            <GradientStop Color="#FF6797BF" Offset="0.3"/>
            <GradientStop Color="#FFD4DBE1" Offset="0"/>
        </LinearGradientBrush>
    </Window.Background>
    <Grid>
        <StackPanel Orientation="Vertical">
        <Label x:Name="lblDomainPciker" Content="Please select a domain:" Margin="10,05,00,00"/>
        <ListBox x:Name="objListBoxDomainList" HorizontalAlignment="Left" Height="78" Margin="10,05,0,0" VerticalAlignment="Top" Width="320"/>
        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
            <Button x:Name="btnOK" Content="OK" Margin="00,05,00,00" Width="50" Height="20"/>
            <Button x:Name="btnCancel" Content="Cancel" Margin="10,05,00,00" Width="50" Height="20"/>
        </StackPanel>
        </StackPanel>
    </Grid>
</Window>
"@

$DomainPickerXAML.Window.RemoveAttribute("x:Class") 

$reader=(New-Object System.Xml.XmlNodeReader $DomainPickerXAML)
$DomainPickerGui=[Windows.Markup.XamlReader]::Load( $reader )
$btnOK = $DomainPickerGui.FindName("btnOK")
$btnCancel = $DomainPickerGui.FindName("btnCancel")
$objListBoxDomainList = $DomainPickerGui.FindName("objListBoxDomainList")

$btnCancel.add_Click(
{
$DomainPickerGui.Close()
})

$btnOK.add_Click(
{
$strSelectedDomain = $objListBoxDomainList.SelectedItem
if ($strSelectedDomain)
{
    if($strSelectedDomain.Contains("."))
    {
        $global:TempDC = $strSelectedDomain
        $strSelectedDomain  = "DC=" + $strSelectedDomain.Replace(".",",DC=")
    }
    $global:strDommainSelect = $strSelectedDomain
}
$DomainPickerGui.Close()
})
$arrPartitions = New-Object System.Collections.ArrayList
$arrPartitions.Clear()

$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection("")
$LDAPConnection.SessionOptions.ReferralChasing = "None"
$request = New-Object System.directoryServices.Protocols.SearchRequest($null, "(objectClass=*)", "base")
[void]$request.Attributes.Add("dnshostname")
[void]$request.Attributes.Add("supportedcapabilities")
[void]$request.Attributes.Add("namingcontexts")
[void]$request.Attributes.Add("defaultnamingcontext")
[void]$request.Attributes.Add("schemanamingcontext")
[void]$request.Attributes.Add("configurationnamingcontext")
[void]$request.Attributes.Add("rootdomainnamingcontext")
[void]$request.Attributes.Add("isGlobalCatalogReady")                
try
{
    $response = $LDAPConnection.SendRequest($request)
    $global:bolLDAPConnection = $true
}
catch
{
	$global:bolLDAPConnection = $false
    #$global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! Domain does not exist or can not be connected" -strType "Error" -DateStamp ))
}
if($global:bolLDAPConnection -eq $true)
{
    $global:ForestRootDomainDN = $response.Entries[0].attributes.rootdomainnamingcontext[0]
    $global:SchemaDN = $response.Entries[0].attributes.schemanamingcontext[0]
    $global:ConfigDN = $response.Entries[0].attributes.configurationnamingcontext[0]
    $global:strDomainDNName = $response.Entries[0].attributes.defaultnamingcontext[0]
    $global:IS_GC = $response.Entries[0].Attributes.isglobalcatalogready[0]
}

#Get all NC and Domain partititons
$request = New-Object System.directoryServices.Protocols.SearchRequest("CN=Partitions,$global:ConfigDN ", "(&(cn=*)(systemFlags:1.2.840.113556.1.4.803:=3))", "Onelevel")
[void]$request.Attributes.Add("ncname")
[void]$request.Attributes.Add("dnsroot")
$response = $LDAPConnection.SendRequest($request)
$colResults = $response.Entries

foreach ($objResult in $colResults)
{
    [void] $arrPartitions.add($objResult.attributes.dnsroot[0])
    [void] $objListBoxDomainList.Items.Add($objResult.attributes.ncname[0])
}

#Get all incoming and bidirectional trusts
$request = New-Object System.directoryServices.Protocols.SearchRequest("CN=System,$global:strDomainDNName", "(&(cn=*)(objectClass=trustedDomain)(|(trustDirection:1.2.840.113556.1.4.803:=1)(trustDirection:1.2.840.113556.1.4.803:=3)))", "Onelevel")
[void]$request.Attributes.Add("trustdirection")
[void]$request.Attributes.Add("trustpartner")
$response = $LDAPConnection.SendRequest($request)
$colResults = $response.Entries

foreach ($objResult in $colResults)
{

    $bolPartitionMatch = $false
    foreach ($strPartition in $arrPartitions)
    {
        if($strPartition -eq $objResult.attributes.trustpartner[0])
        {
            $bolPartitionMatch = $true
        }
    }
    if(!($bolPartitionMatch))
    {
        [void] $objListBoxDomainList.Items.Add($objResult.attributes.trustpartner[0])
    }


}






$DomainPickerGui.ShowDialog()

}
#==========================================================================
# Function		: Get-SchemaData 
# Arguments     : 
# Returns   	: string
# Description   : Returns Schema Version
#==========================================================================
function Get-SchemaData
{
Param([System.Management.Automation.PSCredential] $SchemaCREDS)

	# Retrieve schema

$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $SchemaCREDS)
$LDAPConnection.SessionOptions.ReferralChasing = "None"
$request = New-Object System.directoryServices.Protocols.SearchRequest("$global:SchemaDN", "(CN=ms-Exch-Schema-Version-Pt)", "onelevel")
[void]$request.Attributes.Add("rangeupper")
$response = $LDAPConnection.SendRequest($request)
$adObject = $response.Entries

if($null -ne $adObject)
{
foreach ($entry  in $response.Entries)
{
 
   
	try
	{
		[int] $ExchangeVersion = $entry.Attributes.rangeupper[0]
					
		if ( $global:SchemaHashExchange.ContainsKey($ExchangeVersion) )
		{
			$txtBoxExSchema.Text = $global:SchemaHashExchange[$ExchangeVersion]
		}
		else
		{
			$txtBoxExSchema.Text = "Unknown"
		}
	}
	catch
	{
		$txtBoxExSchema.Text = "Not Found"
	}

}
}
else
{
	$txtBoxExSchema.Text = "Not Found"
}
$request = New-Object System.directoryServices.Protocols.SearchRequest("$global:SchemaDN", "(CN=ms-RTC-SIP-SchemaVersion)", "onelevel")
[void]$request.Attributes.Add("rangeupper")
$response = $LDAPConnection.SendRequest($request)
$adObject = $response.Entries

if($null -ne $adObject)
{
foreach ($entry  in $response.Entries)
{
 
   
	try
	{
		[int] $LyncVersion = $entry.Attributes.rangeupper[0]
					
		if ( $global:SchemaHashLync.ContainsKey($LyncVersion) )
		{
			$txtBoxLyncSchema.Text = $global:SchemaHashLync[$LyncVersion]
		}
		else
		{
			$txtBoxLyncSchema.Text = "Unknown"
		}
	}
	catch
	{
		$txtBoxLyncSchema.Text = "Not Found"
	}

}
}
else
{
	$txtBoxLyncSchema.Text = "Not Found"
}
$request = New-Object System.directoryServices.Protocols.SearchRequest("$global:SchemaDN", "(CN=*)", "Base")
[void]$request.Attributes.Add("objectversion")
$response = $LDAPConnection.SendRequest($request)
$adObject = $response.Entries

if($null -ne $adObject)
{
foreach ($entry  in $response.Entries)
{
 
   
	try
	{
		$ADSchemaVersion = $entry.Attributes.objectversion[0]
					
		if ( $global:SchemaHashAD.ContainsKey([int]$ADSchemaVersion) )
		{
			$txtBoxADSchema.Text = $global:SchemaHashAD[[int]$ADSchemaVersion]
		}
		else
		{
			$txtBoxADSchema.Text = $ADSchemaVersion
		}
	}
	catch
	{
		$txtBoxADSchema.Text = "Not Found"
	}

}
}
else
{
	$txtBoxADSchema.Text = "Not Found"
}

$request = New-Object System.directoryServices.Protocols.SearchRequest("$global:strDomainDNName", "(name=*)", "Base")
[void]$request.Attributes.Add("msds-behavior-version")
$response = $LDAPConnection.SendRequest($request)
$adObject = $response.Entries

if($null -ne $adObject)
{
foreach ($entry  in $response.Entries)
{
 
   
	try
	{
		$ADDFL = $entry.Attributes.'msds-behavior-version'[0]
					
		if ( $global:DomainFLHashAD.ContainsKey([int]$ADDFL) )
		{
			$txtBoxDFL.Text = $global:DomainFLHashAD[[int]$ADDFL]
		}
		else
		{
			$txtBoxDFL.Text = "Unknown"
		}
	}
	catch
	{
		$txtBoxDFL.Text = "Not Found"
	}

}
}
else
{
	$txtBoxDFL.Text = "Not Found"
}
$request = New-Object System.directoryServices.Protocols.SearchRequest("CN=Partitions,CN=Configuration,$global:ForestRootDomainDN", "(name=*)", "Base")
[void]$request.Attributes.Add("msds-behavior-version")
$response = $LDAPConnection.SendRequest($request)
$adObject = $response.Entries

if($null -ne $adObject)
{
foreach ($entry  in $response.Entries)
{
 
   
	try
	{
		$ADFFL = $entry.Attributes.'msds-behavior-version'[0]
					
		if ( $global:ForestFLHashAD.ContainsKey([int]$ADFFL) )
		{
			$txtBoxFFL.Text = $global:ForestFLHashAD[[int]$ADFFL]
		}
		else
		{
			$txtBoxFFL.Text = "Unknown"
		}
	}
	catch
	{
		$txtBoxFFL.Text = "Not Found"
	}

}
}
else
{
	$txtBoxFFL.Text = "Not Found"
}
$request = New-Object System.directoryServices.Protocols.SearchRequest("CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,$global:ForestRootDomainDN", "(dSHeuristics=*)", "Base")
[void]$request.Attributes.Add("dsheuristics")
$response = $LDAPConnection.SendRequest($request)
$adObject = $response.Entries

if($null -ne $adObject)
{
foreach ($entry  in $response.Entries)
{
 
   
	try
	{
		$DSHeuristics = $entry.Attributes.dsheuristics[0]
					
		if ($DSHeuristics.Substring(2,1) -eq "1")
		{
			$txtListObjectMode.Text = "Enabled"
		}
		else
		{
			$txtListObjectMode.Text = "Disabled"
		}
	}
	catch
	{
		$txtListObjectMode.Text = "Not Found"
	}

}
}
else
{
	$txtListObjectMode.Text = "Disabled"
}
}
#==========================================================================
# Function		: Get-HighestNetFrameWorkVer 
# Arguments     : 
# Returns   	: string
# Description   : Returns Highest .Net Framework Version
#==========================================================================
Function Get-HighestNetFrameWorkVer
{
$arrDotNetFrameWorkVersions = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
Get-ItemProperty -name Version,Release -EA 0 |
Where-Object { $_.PSChildName -match '^(?!S)\p{L}'} |
Select-Object Version 
$DotNetVer = $arrDotNetFrameWorkVersions | where-object{$_.version -ge 4.6} | Select-Object -Last 1
if($DotNetVer){$HighestDotNetFrmVer = $DotNetVer.Version}
else{
$DotNetVer = $arrDotNetFrameWorkVersions | where-object{$_.version -ge 4.5} | Select-Object -Last 1
if($DotNetVer){$HighestDotNetFrmVer = $DotNetVer.Version}
else{
$DotNetVer = $arrDotNetFrameWorkVersions | where-object{$_.version -ge 4.0} | Select-Object -Last 1
if($DotNetVer){$HighestDotNetFrmVer = $DotNetVer.Version}
else{
$DotNetVer = $arrDotNetFrameWorkVersions | where-object{$_.version -ge 3.5} | Select-Object -Last 1
if($DotNetVer){$HighestDotNetFrmVer = $DotNetVer.Version}
else{
$DotNetVer = $arrDotNetFrameWorkVersions | where-object{$_.version -ge 3.0} | Select-Object -Last 1
if($DotNetVer){$HighestDotNetFrmVer = $DotNetVer.Version}
else{
$DotNetVer = $arrDotNetFrameWorkVersions | where-object{$_.version -ge 2.0} | Select-Object -Last 1
if($DotNetVer){$HighestDotNetFrmVer = $DotNetVer.Version}
else{
$DotNetVer = $arrDotNetFrameWorkVersions | where-object{$_.version -ge 1.1} | Select-Object -Last 1
if($DotNetVer){$HighestDotNetFrmVer = $DotNetVer.Version}
else{
$DotNetVer = $arrDotNetFrameWorkVersions | where-object{$_.version -ge 1.0} | Select-Object -Last 1
if($DotNetVer){$HighestDotNetFrmVer = $DotNetVer.Version}
}}}}}}}

Remove-variable DotNetVer,arrDotNetFrameWorkVersions

return $HighestDotNetFrmVer

}
#==========================================================================
# Function		: GetDomainController 
# Arguments     : Domain FQDN,bol using creds, PSCredential
# Returns   	: Domain Controller
# Description   : Locate a domain controller in a specified domain
#==========================================================================
Function GetDomainController
{
Param([string] $strDomainFQDN,
[bool] $bolCreds,
[parameter(Mandatory=$false)]
[System.Management.Automation.PSCredential] $DCCREDS)

$strDomainController = ""

if ($bolCreds -eq $true)
{

        $Context = New-Object DirectoryServices.ActiveDirectory.DirectoryContext("Domain",$strDomainFQDN,$DCCREDS.UserName,$DCCREDS.GetNetworkCredential().Password)
        $ojbDomain = [DirectoryServices.ActiveDirectory.Domain]::GetDomain($Context)
        $strDomainController = $($ojbDomain.FindDomainController()).name
}
else
{

        $Context = New-Object DirectoryServices.ActiveDirectory.DirectoryContext("Domain",$strDomainFQDN )
        $ojbDomain = [DirectoryServices.ActiveDirectory.Domain]::GetDomain($Context)
        $strDomainController = $($ojbDomain.FindDomainController()).name
}

return $strDomainController

}

#==========================================================================
# Function		: Get-DirContext 
# Arguments     : string domain controller,credentials
# Returns   	: Directory context
# Description   : Get Directory Context
#==========================================================================
function Get-DirContext
{
Param($DomainController,
[System.Management.Automation.PSCredential] $DIRCREDS)

	if($global:CREDS)
		{
		$Context = new-object DirectoryServices.ActiveDirectory.DirectoryContext("DirectoryServer",$DomainController,$DIRCREDS.UserName,$DIRCREDS.GetNetworkCredential().Password)
	}
	else
	{
		$Context = New-Object DirectoryServices.ActiveDirectory.DirectoryContext("DirectoryServer",$DomainController)
	}
	

    return $Context
}
#==========================================================================
# Function		: TestCreds 
# Arguments     : System.Management.Automation.PSCredential
# Returns   	: Boolean
# Description   : Check If username and password is valid
#==========================================================================
Function TestCreds
{
Param([System.Management.Automation.PSCredential] $psCred)

[void][reflection.assembly]::LoadWithPartialName("System.DirectoryServices.AccountManagement")

if ($psCred.UserName -match "\\")
{
    If ($psCred.UserName.split("\")[0] -eq "")
    {
        [directoryservices.directoryEntry]$root = (New-Object system.directoryservices.directoryEntry)

        $ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, $root.name) 
    }
    else
    {
    
        $ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, $psCred.UserName.split("\")[0]) 
    }
    $bolValid = $ctx.ValidateCredentials($psCred.UserName.split("\")[1],$psCred.GetNetworkCredential().Password)
}
else
{
    [directoryservices.directoryEntry]$root = (New-Object system.directoryservices.directoryEntry)

    $ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, $root.name) 

    $bolValid = $ctx.ValidateCredentials($psCred.UserName,$psCred.GetNetworkCredential().Password)
}    

return $bolValid
}
#==========================================================================
# Function		: GetTokenGroups
# Arguments     : Principal DistinguishedName string
# Returns   	: ArrayList of groups names
# Description   : Group names of all sids in tokenGroups
#==========================================================================
Function GetTokenGroups{
Param($PrincipalDomDC,$PrincipalDN,
[bool] $bolCreds,
[parameter(Mandatory=$false)]
[System.Management.Automation.PSCredential] $GetTokenCreds)

$script:bolErr = $false$tokenGroups =  New-Object System.Collections.ArrayList

$tokenGroups.Clear()
$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($PrincipalDomDC,$GetTokenCreds)
$LDAPConnection.SessionOptions.ReferralChasing = "None"
$request = New-Object System.directoryServices.Protocols.SearchRequest
$request.DistinguishedName = $PrincipalDN
$request.Filter = "(name=*)"
$request.Scope = "Base"
[void]$request.Attributes.Add("tokengroups")
[void]$request.Attributes.Add("tokengroupsglobalanduniversal")
[void]$request.Attributes.Add("objectsid")
$response = $LDAPConnection.SendRequest($request)
$ADobject = $response.Entries[0]

if ( $global:strDomainPrinDNName -eq $global:strDomainDNName )
{
    $SIDs = $ADobject.Attributes.tokengroups
}
else
{
    $SIDs = $ADobject.Attributes.tokengroupsglobalanduniversal
}
$ownerSIDs = [string]$($ADobject.Attributes.objectsid)# Populate hash table with security group memberships. 


$arrForeignSecGroups = FindForeignSecPrinMemberships $(GenerateSearchAbleSID $ownerSIDs) $global:CREDS

foreach ($ForeignMemb in $arrForeignSecGroups)
{
       if($null -ne  $ForeignMemb)
        {            if($ForeignMemb.tostring().length -gt 0 )
            {            [void]$tokenGroups.add($ForeignMemb)
            }
        }} 

 
ForEach ($Value In $SIDs){


    $SID = New-Object System.Security.Principal.SecurityIdentifier $Value, 0

    # Translate into "pre-Windows 2000" name.
    &{#Try        $Script:Group = $SID.Translate([System.Security.Principal.NTAccount])
    }
    Trap [SystemException]
    {
     $script:bolErr = $true
     $script:sidstring = GetSidStringFromSidByte $Value
     continue
    }
    if ($script:bolErr  -eq $false)
     {    [void]$tokenGroups.Add($Script:Group.Value)      }      else
    {
        $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($PrincipalDomDC,$GetTokenCreds)
        $LDAPConnection.SessionOptions.ReferralChasing = "None"
        $request = New-Object System.directoryServices.Protocols.SearchRequest
        if($global:bolShowDeleted)
        {
            [string] $LDAP_SERVER_SHOW_DELETED_OID = "1.2.840.113556.1.4.417"
            [void]$request.Controls.Add((New-Object "System.DirectoryServices.Protocols.DirectoryControl" -ArgumentList "$LDAP_SERVER_SHOW_DELETED_OID",$null,$false,$true ))
        }
        $request.DistinguishedName = "<SID=$script:sidstring>"
        $request.Filter = "(name=*)"
        $request.Scope = "Base"
        [void]$request.Attributes.Add("samaccountname")
        $response = $LDAPConnection.SendRequest($request)
        $result = $response.Entries[0]
        try
        {
	        $script:sidstring =  $global:strPrinDomFlat + "\" + $result.attributes.samaccountname[0]
        }
        catch
        {
             
        }
        [void]$tokenGroups.Add($script:sidstring)
        $script:bolErr = $false
    }

    $arrForeignSecGroups = FindForeignSecPrinMemberships $(GenerateSearchAbleSID $Value) $global:CREDS

    foreach ($ForeignMemb in $arrForeignSecGroups)
    {
       if($null -ne $ForeignMemb)
        {            if($ForeignMemb.tostring().length -gt 0 )
            {            [void]$tokenGroups.add($ForeignMemb)
            }
        }    } 
    }
         [void]$tokenGroups.Add("Everyone")
         [void]$tokenGroups.Add("NT AUTHORITY\Authenticated Users")
if(($global:strPrinDomAttr -eq 14) -or ($global:strPrinDomAttr -eq 18) -or ($global:strPrinDomAttr -eq "5C") -or ($global:strPrinDomAttr -eq "1C") -or ($global:strPrinDomAttr -eq "44")  -or ($global:strPrinDomAttr -eq "54")  -or ($global:strPrinDomAttr -eq "50"))         
{
         [void]$tokenGroups.Add("NT AUTHORITY\Other Organization")}
else
{
         [void]$tokenGroups.Add("NT AUTHORITY\This Organization")
}Return $tokenGroups}


#==========================================================================
# Function		: GenerateSearchAbleSID
# Arguments     : SID Decimal form Value as string
# Returns   	: SID in String format for LDAP searcheds
# Description   : Convert SID from decimal to hex with "\" for searching with LDAP
#==========================================================================
Function GenerateSearchAbleSID
{
Param([String] $SidValue)

$SidDec =$SidValue.tostring().split("")
Foreach ($intSID in $SIDDec)
{
[string] $SIDHex = "{0:X2}" -f [int] $intSID
$strSIDHextString = $strSIDHextString + "\" + $SIDHex

}

return $strSIDHextString
}
#==========================================================================
# Function		: FindForeignSecPrinMemberships
# Arguments     : SID Decimal form Value as string
# Returns   	: Group names
# Description   : Searching for ForeignSecurityPrinicpals and return memberhsip
#==========================================================================
Function FindForeignSecPrinMemberships
{
Param([string] $strSearchAbleSID,
[System.Management.Automation.PSCredential] $ForeignCREDS)

$arrForeignMembership = New-Object System.Collections.ArrayList
[void]$arrForeignMembership.clear()

$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $ForeignCREDS)
$LDAPConnection.SessionOptions.ReferralChasing = "None"
$request = New-Object System.directoryServices.Protocols.SearchRequest
$request.DistinguishedName = "CN=ForeignSecurityPrincipals,$global:strDomainDNName"
$request.Filter = "(&(objectSID=$strSearchAbleSID))"
$request.Scope = "Subtree"
[void]$request.Attributes.Add("memberof")
$response = $LDAPConnection.SendRequest($request)

Foreach ( $obj in $response.Entries)
{
    
  $index = 0
    while($index -le $obj.Attributes.memberof.count -1) 
    {
        $member = $obj.Attributes.memberof[$index]
        $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC,$ForeignCREDS)
        $LDAPConnection.SessionOptions.ReferralChasing = "None"
        $request = New-Object System.directoryServices.Protocols.SearchRequest

        $request.DistinguishedName = $member
        $request.Filter = "(name=*)"
        $request.Scope = "Base"
        [void]$request.Attributes.Add("msDS-PrincipalName")
        [void]$request.Attributes.Add("samaccountname")
        $response = $LDAPConnection.SendRequest($request)
        $ADobject = $response.Entries[0]
        $strPrinName = $ADobject.Attributes."msds-principalname"[0]        if (($strPrinName -eq "") -or ($null -eq $strPrinName))        {            $strPrinName = "$global:strPrinDomFlat\$($ADobject.Attributes.samaccountname[0])"        }   
        [void]$arrForeignMembership.add($strPrinName)
        $index++
    }
}            


return $arrForeignMembership
}
#==========================================================================
# Function		: GetSidStringFromSidByte
# Arguments     : SID Value in Byte[]
# Returns   	: SID in String format
# Description   : Convert SID from Byte[] to String
#==========================================================================
Function GetSidStringFromSidByte
{
Param([byte[]] $SidByte)

    $objectSid = [byte[]]$SidByte
    $sid = New-Object System.Security.Principal.SecurityIdentifier($objectSid,0)  
    $sidString = ($sid.value).ToString() 
    return $sidString
}
#==========================================================================
# Function		: GetSecPrinDN
# Arguments     : samAccountName
# Returns   	: DistinguishedName
# Description   : Search Security Principal and Return DistinguishedName
#==========================================================================
Function GetSecPrinDN
{
Param([string] $samAccountName,
[string] $strDomainDC,
[bool] $bolCreds,
[parameter(Mandatory=$false)]
[System.Management.Automation.PSCredential] $SecPrinDNREDS)


$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($strDomainDC,$SecPrinDNREDS)
$LDAPConnection.SessionOptions.ReferralChasing = "None"
$request = New-Object System.directoryServices.Protocols.SearchRequest
$request.Filter = "(name=*)"
$request.Scope = "Base"
$response = $LDAPConnection.SendRequest($request)
$strPrinDomDC = $response.Entries[0].Attributes.dnshostname[0]
$strPrinDomDefNC = $response.Entries[0].Attributes.defaultnamingcontext[0]
if($strDomainDC -match ":")
{
    $strPrinDomDC = $strPrinDomDC + ":" + $strDomainDC.split(":")[1]
}
$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($strPrinDomDC,$SecPrinDNREDS)
$LDAPConnection.SessionOptions.ReferralChasing = "None"
$request = New-Object System.directoryServices.Protocols.SearchRequest
$request.DistinguishedName = $strPrinDomDefNC
$request.Filter = "(&(samAccountName=$samAccountName))"
$request.Scope = "Subtree"
[void]$request.Attributes.Add("name")
[void]$request.Attributes.Add("distinguishedname")
$response = $LDAPConnection.SendRequest($request)
$ADobject = $response.Entries[0]


if($ADobject.Attributes.Count -gt 0)
{

	$global:strPrincipalDN = $ADobject.Attributes.distinguishedname[0]
}
else
{
    $global:strPrincipalDN = ""
}

return $global:strPrincipalDN

}


#==========================================================================
# Function		: GetSchemaObjectGUID
# Arguments     : Object Guid or Rights Guid
# Returns   	: LDAPDisplayName or DisplayName
# Description   : Searches in the dictionaries(Hash) dicRightsGuids and $global:dicSchemaIDGUIDs  and in Schema 
#				for the name of the object or Extended Right, if found in Schema the dicRightsGuids is updated.
#				Then the functions return the name(LDAPDisplayName or DisplayName).
#==========================================================================
Function GetSchemaObjectGUID
{
Param([string] $Domain)
	[string] $strOut =""
	[string] $objSchemaRecordset = ""
	[string] $strLDAPname = ""
    
    [void]$combObjectFilter.Items.Clear()
    BuildSchemaDic
    foreach ($ldapDisplayName in $global:dicSchemaIDGUIDs.values)
    {
        [void]$combObjectFilter.Items.Add($ldapDisplayName)
    }

    $PageSize=100
    $TimeoutSeconds = 120
    $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
    $LDAPConnection.SessionOptions.ReferralChasing = "None"
    $request = New-Object System.directoryServices.Protocols.SearchRequest("$global:SchemaDN", "(&(schemaIDGUID=*))", "Subtree")
    [System.DirectoryServices.Protocols.PageResultRequestControl]$pagedRqc = new-object System.DirectoryServices.Protocols.PageResultRequestControl($pageSize)
    $request.Controls.Add($pagedRqc) | Out-Null
    [void]$request.Attributes.Add("ldapdisplayname")
    [void]$request.Attributes.Add("schemaidguid")
    while ($true)
    {
        $response = $LdapConnection.SendRequest($request, (new-object System.Timespan(0,0,$TimeoutSeconds))) -as [System.DirectoryServices.Protocols.SearchResponse];
                
        #for paged search, the response for paged search result control - we will need a cookie from result later
        if($pageSize -gt 0) {
            [System.DirectoryServices.Protocols.PageResultResponseControl] $prrc=$null;
            if ($response.Controls.Length -gt 0)
            {
                foreach ($ctrl in $response.Controls)
                {
                    if ($ctrl -is [System.DirectoryServices.Protocols.PageResultResponseControl])
                    {
                        $prrc = $ctrl;
                        break;
                    }
                }
            }
            if($null -eq $prrc) {
                #server was unable to process paged search
                throw "Find-LdapObject: Server failed to return paged response for request $SearchFilter"
            }
        }
        #now process the returned list of distinguishedNames and fetch required properties using ranged retrieval
        $colResults = $response.Entries
	    foreach ($objResult in $colResults)
	    {             
		    $strLDAPname = $objResult.attributes.ldapdisplayname[0]
		    $guidGUID = [System.GUID] $objResult.attributes.schemaidguid[0]
            $strGUID = $guidGUID.toString().toUpper()
		    If (!($global:dicSchemaIDGUIDs.ContainsKey($strGUID)))
            {
                $global:dicSchemaIDGUIDs.Add($strGUID,$strLDAPname)
                $global:dicNameToSchemaIDGUIDs.Add($strLDAPname,$strGUID)
                [void]$combObjectFilter.Items.Add($strLDAPname)
            }
				
	    }
        if($pageSize -gt 0) {
            if ($prrc.Cookie.Length -eq 0) {
                #last page --> we're done
                break;
            }
            #pass the search cookie back to server in next paged request
            $pagedRqc.Cookie = $prrc.Cookie;
        } else {
            #exit the processing for non-paged search
            break;
        }
    }

	          
        
	return $strOut
}

#==========================================================================
# Function		: Get-ADSchemaClass 
# Arguments     : string class,string domain controller,credentials
# Returns   	: Class Object
# Description   : Get AD Schema Class
#==========================================================================
function Get-ADSchemaClass
{
Param($Class = ".*")
    
    $ojbSchema =[System.DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetSchema($global:DirContext)
	$ADSchemaClass = $ojbSchema.FindAllClasses() | Where-Object{$_.Name -match "^$Class`$"}
    
    return $ADSchemaClass
}

#==========================================================================
# Function		: CheckDNExist 
# Arguments     : string distinguishedName, string directory server
# Returns   	: Boolean
# Description   : Check If distinguishedName exist
#==========================================================================
function CheckDNExist
{
Param (
  $sADobjectName,
  $strDC
  )

    $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($strDC, $global:CREDS)
    #$LDAPConnection.SessionOptions.ReferralChasing = "None"
    $request = New-Object System.directoryServices.Protocols.SearchRequest
    if($global:bolShowDeleted)
    {
        [string] $LDAP_SERVER_SHOW_DELETED_OID = "1.2.840.113556.1.4.417"
        [void]$request.Controls.Add((New-Object "System.DirectoryServices.Protocols.DirectoryControl" -ArgumentList "$LDAP_SERVER_SHOW_DELETED_OID",$null,$false,$true ))
    }
    $request.DistinguishedName = $sADobjectName
    $request.Filter = "(name=*)"
    $request.Scope = "Base"
    [void]$request.Attributes.Add("name")
    [void]$request.Attributes.Add("distinguishedname")
	try
	{
        $response = $LDAPConnection.SendRequest($request)
	}
	catch
	{
		return $false
	}
    if($response.Entries.count -gt 0)
    {
        $ADobject = $response.Entries[0]
        If($ADobject.attributes.count -ne 0)
        {
            If($null -eq $ADobject.attributes.distinguishedname[0])
            {return $false}
            else
            {return $true}
        }
        else
        {
            If($null -eq $ADobject.distinguishedname)
            {return $false}
            else
            {return $true}
        }
    }
}
#==========================================================================
# Function		: StripDN
# Arguments     : string
# Returns   	: string backwards
# Description   : Turn a string without CN,DN,DC or ","
#==========================================================================
Function DoubleReverse{param ($string)$string = ReverseString -String $string$newstring = $string.Split(",")Foreach ($StringSplit in $newstring){$DoubleReverseText+= ReverseString -String $StringSplit}return $DoubleReverseText }
#==========================================================================
# Function		: ReverseString
# Arguments     : string
# Returns   	: string backwards
# Description   : Turn a string backwards
#==========================================================================
Function ReverseString{param ($string)ForEach ($char in $string) {    ([regex]::Matches($char,'.','RightToLeft') | ForEach {$_.value}) -join ''} }#==========================================================================
# Function		: TestCSVColumnsDefaultSD
# Arguments     : CSV import for Default Security descriptor
# Returns   	: Boolean
# Description   : Search for all requried column names in CSV and return true or false
#==========================================================================
function TestCSVColumnsDefaultSD{param($CSVImport)$bolColumExist = $false$colHeaders = ( $CSVImport | Get-member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name')
$bolName = $false
$boldistinguishedName = $false
$bolVersion = $false
$bolModifiedDate = $false
$bolSDDL = $false

Foreach ($ColumnName in $colHeaders )
{

    if($ColumnName.Trim() -eq "Name")
    {
        $bolName = $true
    }
    if($ColumnName.Trim() -eq "distinguishedName")
    {
        $boldistinguishedName = $true
    }
    if($ColumnName.Trim() -eq "Version")
    {
        $bolVersion = $true
    }
    if($ColumnName.Trim() -eq "ModifiedDate")
    {
        $bolModifiedDate = $true
    }
    if($ColumnName.Trim() -eq "SDDL")
    {
        $bolSDDL = $true
    }
    

}
#if test column names exist
if($bolName -and $boldistinguishedName -and $bolVersion -and $bolModifiedDate -and $bolSDDL)
{    $bolColumExist = $true}return $bolColumExist}#==========================================================================
# Function		: TestCSVColumns
# Arguments     : CSV import 
# Returns   	: Boolean
# Description   : Search for all requried column names in CSV and return true or false
#==========================================================================
function TestCSVColumns{param($CSVImport)$bolColumExist = $false$colHeaders = ( $CSVImport | Get-member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name')
$bolAccessControlType = $false
$bolActiveDirectoryRights = $false
$bolIdentityReference = $false
$bolInheritanceFlags = $false
$bolInheritanceType = $false
$bolInheritedObjectType = $false
$bolInvocationID = $false
$bolIsInherited = $false
$bolLegendText = $false
$bolObjectFlags= $false
$bolObjectType = $false
$bolOrgUSN= $false
$bolOU = $false
$bolPropagationFlags = $false
$bolSDDate = $false
Foreach ($ColumnName in $colHeaders )
{

    if($ColumnName.Trim() -eq "AccessControlType")
    {
        $bolAccessControlType = $true
    }
    if($ColumnName.Trim() -eq "ActiveDirectoryRights")
    {
        $bolActiveDirectoryRights = $true
    }
    if($ColumnName.Trim() -eq "IdentityReference")
    {
        $bolIdentityReference = $true
    }
    if($ColumnName.Trim() -eq "InheritanceFlags")
    {
        $bolInheritanceFlags = $true
    }
    if($ColumnName.Trim() -eq "InheritanceType")
    {
        $bolInheritanceType = $true
    }
    if($ColumnName.Trim() -eq "InheritedObjectType")
    {
        $bolInheritedObjectType = $true
    }
    if($ColumnName.Trim() -eq "InvocationID")
    {
        $bolInvocationID = $true
    }
    if($ColumnName.Trim() -eq "IsInherited")
    {
        $bolIsInherited = $true
    }        
    if($ColumnName.Trim() -eq "LegendText")
    {
        $bolLegendText = $true
    }    
   
    if($ColumnName.Trim() -eq "ObjectFlags")
    {
        $bolObjectFlags= $true
    }    
    if($ColumnName.Trim() -eq "ObjectType")
    {
        $bolObjectType = $true
    }   
    if($ColumnName.Trim() -eq "OrgUSN")
    {
        $bolOrgUSN= $true
    }   
    if($ColumnName.Trim() -eq "OU")
    {
        $bolOU = $true
    }   
    if($ColumnName.Trim() -eq "PropagationFlags")
    {
        $bolPropagationFlags = $true
    }        
    if($ColumnName.Trim() -eq "SDDate")
    {
        $bolSDDate = $true
    }     

}
#if test column names exist
if($bolAccessControlType -and $bolActiveDirectoryRights -and $bolIdentityReference -and $bolInheritanceFlags -and $bolInheritanceType -and $bolInheritedObjectType `
    -and $bolInvocationID -and $bolIsInherited -and $bolLegendText -and $bolObjectFlags -and $bolObjectType -and $bolOrgUSN -and $bolOU -and $bolPropagationFlags`
    -and $bolSDDate)
{    $bolColumExist = $true}return $bolColumExist}
#==========================================================================
# Function		: GetAllChildNodes
# Arguments     : Node distinguishedName 
# Returns   	: List of Nodes
# Description   : Search for a Node and returns distinguishedName
#==========================================================================
function GetAllChildNodes
{
param ($firstnode,
[boolean] $bolSubtree)
$nodelist = New-Object System.Collections.ArrayList
$mySL = new-object system.collections.SortedList
$nodelist.Clear()
$mySL.Clear()
# Add all Children found as Sub Nodes to the selected TreeNode 

$strFilterAll = "(&(objectClass=*)(!msds-nctype=*))"
$strFilterContainer = "(&(|(objectClass=organizationalUnit)(objectClass=container)(objectClass=DomainDNS)(objectClass=dMD))(!msds-nctype=*))"
$strFilterOU = "(&(objectClass=organizationalUnit))"
#$strFilterOU = "(&(|(objectClass=organizationalUnit)(objectClass=DomainDNS)(objectClass=dMD))(!msds-nctype=*))"

$PageSize=100
$TimeoutSeconds = 120

$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
$LDAPConnection.SessionOptions.ReferralChasing = "None"
$request = New-Object System.directoryServices.Protocols.SearchRequest
[System.DirectoryServices.Protocols.PageResultRequestControl]$pagedRqc = new-object System.DirectoryServices.Protocols.PageResultRequestControl($pageSize)
$request.Controls.Add($pagedRqc) | Out-Null

if($global:bolShowDeleted)
{
    [string] $LDAP_SERVER_SHOW_DELETED_OID = "1.2.840.113556.1.4.417"
    [void]$request.Controls.Add((New-Object "System.DirectoryServices.Protocols.DirectoryControl" -ArgumentList "$LDAP_SERVER_SHOW_DELETED_OID",$null,$false,$true ))
}
if ($firstnode -match "/")
{
    $firstnode = $firstnode.Replace("/", "\/")
}


$request.DistinguishedName = $firstnode
If ($rdbScanAll.IsChecked -eq $true) 
{
	$request.Filter = $strFilterAll
}
If ($rdbScanOU.IsChecked -eq $true) 
{
	$request.Filter = $strFilterOU
}
If ($rdbScanContainer.IsChecked -eq $true) 
{
	$request.Filter = $strFilterContainer
}
if ($bolSubtree -eq $true)
{
    $request.Scope = "Subtree"
}
else
{
    $request.Scope = "onelevel"
}



[void]$request.Attributes.Add("cn")
[void]$request.Attributes.Add("distinguishedNAme")
$response = $LDAPConnection.SendRequest($request)


if($txtBoxExcluded.text.Length -gt 0)
{
$arrExcludedDN = $txtBoxExcluded.text.split(";")
 while ($true)
    {
    $response = $LdapConnection.SendRequest($request, (new-object System.Timespan(0,0,$TimeoutSeconds))) -as [System.DirectoryServices.Protocols.SearchResponse];
                
    #for paged search, the response for paged search result control - we will need a cookie from result later
    if($pageSize -gt 0) {
        [System.DirectoryServices.Protocols.PageResultResponseControl] $prrc=$null;
        if ($response.Controls.Length -gt 0)
        {
            foreach ($ctrl in $response.Controls)
            {
                if ($ctrl -is [System.DirectoryServices.Protocols.PageResultResponseControl])
                {
                    $prrc = $ctrl;
                    break;
                }
            }
        }
        if($null -eq $prrc) {
            #server was unable to process paged search
            throw "Find-LdapObject: Server failed to return paged response for request $SearchFilter"
        }
    }
    #now process the returned list of distinguishedNames and fetch required properties using ranged retrieval
    $colResults = $response.Entries
    $intTotalSearch =  $colResults.Count
    $intNomatch = 0
	foreach ($objResult in $colResults)
	{
        $bolInclude = $true
        Foreach( $strExcludeDN in $arrExcludedDN)
        {
          if(!($objResult.distinguishedName -notmatch $strExcludeDN ))
          {
              $bolInclude = $false
              break
          }
        }
        #Add objects with distinguihsedname not matching string
        if($bolInclude)
        {
            #Reverse string to be able to sort output
            [void]$mySL.Add($(DoubleReverse -String $objResult.distinguishedName),$objResult.distinguishedName)
            $intNomatch++
        }
        
    }
        if($pageSize -gt 0) {
            if ($prrc.Cookie.Length -eq 0) {
                #last page --> we're done
                break;
            }
            #pass the search cookie back to server in next paged request
            $pagedRqc.Cookie = $prrc.Cookie;
        } else {
            #exit the processing for non-paged search
            break;
        }
    }



    # Adding the selected node to the results too
    $intTotalSearch++

    $bolInclude = $true
    Foreach( $strExcludeDN in $arrExcludedDN)
    {
        if(!($objResult.distinguishedName -notmatch $strExcludeDN ))
        {
            $bolInclude = $false
            break
        }
    }
    if($bolInclude)
    {
        #Reverse string to be able to sort output    
        try
        {        
            [void]$mySL.Add($(DoubleReverse -String $firstnode),$firstnode)
        }
        catch
        {}
        $intNomatch++
                
    }
    

    
    #Caclulate number of objects exluded in search
    $global:intObjExluced = $intTotalSearch - $intNomatch
    # Log information about skipped objects
    $global:observableCollection.Insert(0,(LogMessage -strMessage "Number of objects excluded: $global:intObjExluced" -strType "Info" -DateStamp ))
}
# If no string in Excluded String box 
else
{
    while ($true)
    {
        $response = $LdapConnection.SendRequest($request, (new-object System.Timespan(0,0,$TimeoutSeconds))) -as [System.DirectoryServices.Protocols.SearchResponse];
                
        #for paged search, the response for paged search result control - we will need a cookie from result later
        if($pageSize -gt 0) {
            [System.DirectoryServices.Protocols.PageResultResponseControl] $prrc=$null;
            if ($response.Controls.Length -gt 0)
            {
                foreach ($ctrl in $response.Controls)
                {
                    if ($ctrl -is [System.DirectoryServices.Protocols.PageResultResponseControl])
                    {
                        $prrc = $ctrl;
                        break;
                    }
                }
            }
            if($null -eq $prrc) {
                #server was unable to process paged search
                throw "Find-LdapObject: Server failed to return paged response for request $SearchFilter"
            }
        }
        #now process the returned list of distinguishedNames and fetch required properties using ranged retrieval
        $colResults = $response.Entries
	    foreach ($objResult in $colResults)
	    {

            #Reverse string to be able to sort output
            [void]$mySL.Add($(DoubleReverse -String $objResult.DistinguishedName),$objResult.DistinguishedName)

        }
        if($pageSize -gt 0) {
            if ($prrc.Cookie.Length -eq 0) {
                #last page --> we're done
                break;
            }
            #pass the search cookie back to server in next paged request
            $pagedRqc.Cookie = $prrc.Cookie;
        } else {
            #exit the processing for non-paged search
            break;
        }
    }

    #Adding the selected node and reverse string to be able to sort output
    try
    {        
        [void]$mySL.Add($(DoubleReverse -String $firstnode),$firstnode)
    }
    catch
    {}
 
}

foreach ($SLKeys in $($mySL | sort-Object ))
{
    [void] $nodelist.Add($SLKeys.Values)

}


return $nodelist

}
#==========================================================================
# Function		: Get-DomainDN
# Arguments     : string AD object distinguishedName
# Returns   	: Domain DN
# Description   : Take dinstinguishedName as input and returns Domain name 
#                  in DN
#==========================================================================
function Get-DomainDN
{
Param($strADObjectDN)

        $strADObjectDNModified= $strADObjectDN.Replace(",DC=","*")

        [array]$arrDom = $strADObjectDNModified.split("*") 
        $intSplit = ($arrDom).count -1
        $strDomDN = ""
        for ($i=$intSplit;$i -ge 1; $i-- )
        {
            if ($i -eq 1)
            {
                $strDomDN="DC="+$arrDom[$i]+$strDomDN
            }
            else
            {
                $strDomDN=",DC="+$arrDom[$i]+$strDomDN
            }
        }
    $i = $null
    Remove-Variable -Name "i"
    return $strDomDN
}

#==========================================================================
# Function		: Get-DomainFQDN 
# Arguments     : string AD object distinguishedName
# Returns   	: Domain FQDN
# Description   : Take dinstinguishedName as input and returns Domain name 
#                  in FQDN
#==========================================================================
function Get-DomainFQDN
{
Param($strADObjectDN)

        $strADObjectDNModified= $strADObjectDN.Replace(",DC=","*")

        [array]$arrDom = $strADObjectDNModified.split("*") 
        $intSplit = ($arrDom).count -1
        $strDomName = ""
        for ($i=$intSplit;$i -ge 1; $i-- )
        {
            if ($i -eq $intSplit)
            {
                $strDomName=$arrDom[$i]+$strDomName
            }
            else
            {
                $strDomName=$arrDom[$i]+"."+$strDomName
            }
        }
    
    $i = $null
    Remove-Variable -Name "i"

    return $strDomName
}
#==========================================================================
# Function		: GetDomainShortName
# Arguments     : domain name 
# Returns   	: N/A
# Description   : Search for short domain name
#==========================================================================
function GetDomainShortName
{ 
Param($strDomain,
[string]$strConfigDN)

    $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
    $LDAPConnection.SessionOptions.ReferralChasing = "None"
    $request = New-Object System.directoryServices.Protocols.SearchRequest("CN=Partitions,$strConfigDN", "(&(objectClass=crossRef)(nCName=$strDomain))", "Subtree")
    [void]$request.Attributes.Add("netbiosname")
    $response = $LDAPConnection.SendRequest($request)
    $adObject = $response.Entries[0]

    if($null -ne $adObject)
    {

        $ReturnShortName = $adObject.Attributes.netbiosname[0]
	}
	else
	{
		$ReturnShortName = ""
	}
 
return $ReturnShortName
}

#==========================================================================
# Function		: Get-ProtectedPerm
# Arguments     : 
# Returns   	: ArrayList
# Description   : Creates the Security Descriptor with the Protect object from accidental deleations ACE
#==========================================================================
Function Get-ProtectedPerm
{

$sdProtectedDeletion =  New-Object System.Collections.ArrayList
$sdProtectedDeletion.clear()

$protectedDeletionsACE1 = New-Object PSObject -Property @{ActiveDirectoryRights="DeleteChild";InheritanceType="None";ObjectType ="00000000-0000-0000-0000-000000000000";`
InheritedObjectType="00000000-0000-0000-0000-000000000000";ObjectFlags="None";AccessControlType="Deny";IdentityReference="Everyone";IsInherited="False";`
InheritanceFlags="None";PropagationFlags="None"}

[void]$sdProtectedDeletion.insert(0,$protectedDeletionsACE)


$protectedDeletionsACE2 = New-Object PSObject -Property @{ActiveDirectoryRights="DeleteChild, DeleteTree, Delete";InheritanceType="None";ObjectType ="00000000-0000-0000-0000-000000000000";`
InheritedObjectType="00000000-0000-0000-0000-000000000000";ObjectFlags="ObjectAceTypePresent";AccessControlType="Deny";IdentityReference="Everyone";IsInherited="False";`
InheritanceFlags="None";PropagationFlags="None"}

$protectedDeletionsACE3 = New-Object PSObject -Property @{ActiveDirectoryRights="DeleteTree, Delete";InheritanceType="None";ObjectType ="00000000-0000-0000-0000-000000000000";`
InheritedObjectType="00000000-0000-0000-0000-000000000000";ObjectFlags="None";AccessControlType="Deny";IdentityReference="Everyone";IsInherited="False";`
InheritanceFlags="None";PropagationFlags="None"}

[void]$sdProtectedDeletion.insert(0,@($protectedDeletionsACE1,$protectedDeletionsACE2,$protectedDeletionsACE3))




return $sdProtectedDeletion

}
#==========================================================================
# Function		: Get-PermDef
# Arguments     : Object Class, Trustee Name
# Returns   	: ArrayList
# Description   : Fetch the Default Security Descriptor with the Default
#==========================================================================
Function Get-PermDef
{
Param($strObjectClass,
[string]$strTrustee)


$sdOUDef =  New-Object System.Collections.ArrayList
$sdOUDef.clear()



$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
$LDAPConnection.SessionOptions.ReferralChasing = "None"
$request = New-Object System.directoryServices.Protocols.SearchRequest("$global:SchemaDN", "(ldapdisplayname=$strObjectClass)", "Subtree")
[void]$request.Attributes.Add("defaultsecuritydescriptor")
$response = $LDAPConnection.SendRequest($request)
$colResults = $response.Entries

foreach ($entry  in $response.Entries)
{          
    $sec = New-Object System.DirectoryServices.ActiveDirectorySecurity
    $defSD = ""
    if($null -ne $entry.Attributes.defaultsecuritydescriptor)
    {
        $sec.SetSecurityDescriptorSddlForm($entry.Attributes.defaultsecuritydescriptor[0])
    }
    $defSD = $sec.GetAccessRules($true, $false, [System.Security.Principal.NTAccount])   
    $sec = $null
}


if($null -ne $defSD){

$(ConvertTo-ObjectArrayListFromPsCustomObject  $defSD)| ForEach-Object{[void]$sdOUDef.add($_)}
$defSD = $null
if ($strObjectClass -eq "computer")
{
  if($global:intObjeComputer -eq 0)
    {

        $global:additionalComputerACE1 = New-Object PSObject -Property @{ActiveDirectoryRights="DeleteTree, ExtendedRight, Delete, GenericRead";InheritanceType="None";ObjectType ="00000000-0000-0000-0000-000000000000";`
        InheritedObjectType="00000000-0000-0000-0000-000000000000";ObjectFlags="None";AccessControlType="Allow";IdentityReference=$global:strOwner;IsInherited="False";`
        InheritanceFlags="None";PropagationFlags="None"}
        
        #[void]$sdOUDef.insert(0,$global:additionalComputerACE)


        $global:additionalComputerACE2 = New-Object PSObject -Property @{ActiveDirectoryRights="WriteProperty";InheritanceType="None";ObjectType ="4c164200-20c0-11d0-a768-00aa006e0529";`
        InheritedObjectType="00000000-0000-0000-0000-000000000000";ObjectFlags="ObjectAceTypePresent";AccessControlType="Allow";IdentityReference=$global:strOwner;IsInherited="False";`
        InheritanceFlags="None";PropagationFlags="None"}

        #[void]$sdOUDef.insert(0,$global:additionalComputerACE)


        $global:additionalComputerACE3 = New-Object PSObject -Property @{ActiveDirectoryRights="WriteProperty";InheritanceType="None";ObjectType ="3e0abfd0-126a-11d0-a060-00aa006c33ed";`
        InheritedObjectType="00000000-0000-0000-0000-000000000000";ObjectFlags="ObjectAceTypePresent";AccessControlType="Allow";IdentityReference=$global:strOwner;IsInherited="False";`
        InheritanceFlags="None";PropagationFlags="None"}

        #[void]$sdOUDef.insert(0,$global:additionalComputerACE)


        $global:additionalComputerACE4 = New-Object PSObject -Property @{ActiveDirectoryRights="WriteProperty";InheritanceType="None";ObjectType ="bf967953-0de6-11d0-a285-00aa003049e2";`
        InheritedObjectType="00000000-0000-0000-0000-000000000000";ObjectFlags="ObjectAceTypePresent";AccessControlType="Allow";IdentityReference=$global:strOwner;IsInherited="False";`
        InheritanceFlags="None";PropagationFlags="None"}
        
        #[void]$sdOUDef.insert(0,$global:additionalComputerACE)

        $global:additionalComputerACE5 = New-Object PSObject -Property @{ActiveDirectoryRights="WriteProperty";InheritanceType="None";ObjectType ="bf967950-0de6-11d0-a285-00aa003049e2";`
        InheritedObjectType="00000000-0000-0000-0000-000000000000";ObjectFlags="ObjectAceTypePresent";AccessControlType="Allow";IdentityReference=$global:strOwner;IsInherited="False";`
        InheritanceFlags="None";PropagationFlags="None"}

        #[void]$sdOUDef.insert(0,$global:additionalComputerACE)

        $global:additionalComputerACE6 = New-Object PSObject -Property @{ActiveDirectoryRights="WriteProperty";InheritanceType="None";ObjectType ="5f202010-79a5-11d0-9020-00c04fc2d4cf";`
        InheritedObjectType="00000000-0000-0000-0000-000000000000";ObjectFlags="ObjectAceTypePresent";AccessControlType="Allow";IdentityReference=$global:strOwner;IsInherited="False";`
        InheritanceFlags="None";PropagationFlags="None"}

        #[void]$sdOUDef.insert(0,$global:additionalComputerACE)
        

        $global:additionalComputerACE7 = New-Object PSObject -Property @{ActiveDirectoryRights="Self";InheritanceType="None";ObjectType ="f3a64788-5306-11d1-a9c5-0000f80367c1";`
        InheritedObjectType="00000000-0000-0000-0000-000000000000";ObjectFlags="ObjectAceTypePresent";AccessControlType="Allow";IdentityReference=$global:strOwner;IsInherited="False";`
        InheritanceFlags="None";PropagationFlags="None"}

        #[void]$sdOUDef.insert(0,$global:additionalComputerACE)    
            
        $global:additionalComputerACE8 = New-Object PSObject -Property @{ActiveDirectoryRights="Self";InheritanceType="None";ObjectType ="72e39547-7b18-11d1-adef-00c04fd8d5cd";`
        InheritedObjectType="00000000-0000-0000-0000-000000000000";ObjectFlags="ObjectAceTypePresent";AccessControlType="Allow";IdentityReference=$global:strOwner;IsInherited="False";`
        InheritanceFlags="None";PropagationFlags="None"}

        [void]$sdOUDef.insert(0,@($global:additionalComputerACE1,$global:additionalComputerACE2,$global:additionalComputerACE3,$global:additionalComputerACE4,$global:additionalComputerACE5,$global:additionalComputerACE6,$global:additionalComputerACE7,$global:additionalComputerACE8))
    }
    else
    {
        [void]$sdOUDef.insert(0,@($global:additionalComputerACE1,$global:additionalComputerACE2,$global:additionalComputerACE3,$global:additionalComputerACE4,$global:additionalComputerACE5,$global:additionalComputerACE6,$global:additionalComputerACE7,$global:additionalComputerACE8))
    }
    $global:intObjeComputer++
}# End if Computer
}



return $sdOUDef

}
#==========================================================================
# Function		: CacheRightsGuids
# Arguments     : none
# Returns   	: nothing
# Description   : Enumerates all Extended Rights and put them in a Hash dicRightsGuids
#==========================================================================
Function CacheRightsGuids
{
	
        
        $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
        $LDAPConnection.SessionOptions.ReferralChasing = "None"
        $searcher = New-Object System.directoryServices.Protocols.SearchRequest
        $searcher.DistinguishedName = $global:ConfigDN

        [void]$searcher.Attributes.Add("cn")
        [void]$searcher.Attributes.Add("distinguishedname")
        [void]$searcher.Attributes.Add("name")                        
        [void]$searcher.Attributes.Add("rightsguid")
        [void]$searcher.Attributes.Add("validaccesses")
        [void]$searcher.Attributes.Add("displayname")
		$searcher.filter = "(&(objectClass=controlAccessRight))"

        $searcherSent = $LDAPConnection.SendRequest($searcher)
        $colResults = $searcherSent.Entries        
 		$intCounter = 0
	
	foreach ($objResult in $colResults)
	{

		    $strRightDisplayName = $objResult.Attributes.displayname[0]
		    $strRightGuid = $objResult.Attributes.rightsguid[0]
		    $strRightGuid = $($strRightGuid).toString()

            #Expecting to fail at lest once since two objects have the same rightsguid
            &{#Try

		        $global:dicRightsGuids.Add($strRightGuid,$strRightDisplayName)	
            }
            Trap [SystemException]
            {
                #Write-host "Failed to add CAR:$strRightDisplayName" -ForegroundColor red
                continue
            }

		$intCounter++
    }
			 

}
#==========================================================================
# Function		: MapGUIDToMatchingName
# Arguments     : Object Guid or Rights Guid
# Returns   	: LDAPDisplayName or DisplayName
# Description   : Searches in the dictionaries(Hash) dicRightsGuids and $global:dicSchemaIDGUIDs  and in Schema 
#				for the name of the object or Extended Right, if found in Schema the dicRightsGuids is updated.
#				Then the functions return the name(LDAPDisplayName or DisplayName).
#==========================================================================
Function MapGUIDToMatchingName
{
Param([string] $strGUIDAsString,[string] $Domain)
	[string] $strOut =""
	[string] $objSchemaRecordset = ""
	[string] $strLDAPname = ""

	If ($strGUIDAsString -eq "") 
	{

	 Break
	 }
	$strGUIDAsString = $strGUIDAsString.toUpper()
	$strOut =""
	if ($global:dicRightsGuids.ContainsKey($strGUIDAsString))
	{
		$strOut =$global:dicRightsGuids.Item($strGUIDAsString)
	}

	If ($strOut -eq "")
	{  #Didn't find a match in extended rights
		If ($global:dicSchemaIDGUIDs.ContainsKey($strGUIDAsString))
		{
			$strOut =$global:dicSchemaIDGUIDs.Item($strGUIDAsString)
		}
		else
		{
		
		 if ($strGUIDAsString -match("^(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}$"))
		 {
		 	
			$ConvertGUID = ConvertGUID($strGUIDAsString)
		            
            $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
            $LDAPConnection.SessionOptions.ReferralChasing = "None"
            $searcher = New-Object System.directoryServices.Protocols.SearchRequest
            $searcher.DistinguishedName = $global:SchemaDN

            [void]$searcher.Attributes.Add("cn")
            [void]$searcher.Attributes.Add("distinguishednAme")
            [void]$searcher.Attributes.Add("name")                        
            [void]$searcher.Attributes.Add("ldapdisplayname")
			$searcher.filter = "(&(schemaIDGUID=$ConvertGUID))"

            $searcherSent = $LDAPConnection.SendRequest($searcher)
            $objSchemaObject = $searcherSent.Entries[0]

			 if ($objSchemaObject)
			 {
				$strLDAPname =$objSchemaObject.attributes.ldapdisplayname[0]
				$global:dicSchemaIDGUIDs.Add($strGUIDAsString.toUpper(),$strLDAPname)
				$strOut=$strLDAPname
				
			 }
		}
	  }
	}
    
	return $strOut
}
#==========================================================================
# Function		: ConvertGUID
# Arguments     : Object Guid or Rights Guid
# Returns   	: AD Searchable GUID String
# Description   : Convert a GUID to a string

#==========================================================================
Function ConvertGUID
 {
    Param($guid)

	 $test = "(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})"
	 $pattern = '"\$4\$3\$2\$1\$6\$5\$8\$7\$9\$10\$11\$12\$13\$14\$15\$16"'
	 $ConvertGUID = [regex]::Replace($guid.replace("-",""), $test, $pattern).Replace("`"","")
	 return $ConvertGUID
}
#==========================================================================
# Function		: fixfilename
# Arguments     : Text for naming text file
# Returns   	: Text with replace special characters
# Description   : Replace characters that be contained in a file name.

#==========================================================================
function fixfilename
{
    Param([string] $strFileName)
    $strFileName = $strFileName.Replace("*","#")
    $strFileName = $strFileName.Replace("/","#")
    $strFileName = $strFileName.Replace("\","#")
    $strFileName = $strFileName.Replace(":","#")
    $strFileName = $strFileName.Replace("<","#")
    $strFileName = $strFileName.Replace(">","#")
    $strFileName = $strFileName.Replace("|","#")
    $strFileName = $strFileName.Replace('"',"#")
    $strFileName = $strFileName.Replace('?',"#")

    return $strFileName
}
#==========================================================================
# Function		: WritePermCSV
# Arguments     : Security Descriptor, OU distinguishedName, Ou put text file
# Returns   	: n/a
# Description   : Writes the SD to a text file.
#==========================================================================
function WritePermCSV
{
    Param($sd,[string]$ou,[string]$objType,[string] $fileout, [bool] $ACLMeta,[string]  $strACLDate,[string] $strInvocationID,[string] $strOrgUSN)
$sd  | foreach {
	    If ($global:dicDCSpecialSids.ContainsKey($_.IdentityReference.toString()))
	    {
		    $strAccName = $global:dicDCSpecialSids.Item($_.IdentityReference.toString())
	    }
        else
        {
            $strAccName = $_.IdentityReference.toString()
        }
        # Add Translated object GUID information to output
        if($chkBoxTranslateGUID.isChecked -eq $true)
        {
	        if($($_.InheritedObjectType.toString()) -ne "00000000-0000-0000-0000-000000000000" )
            {
            
                $strTranslatedInheritObjType = $(MapGUIDToMatchingName -strGUIDAsString $_.InheritedObjectType.toString() -Domain $global:strDomainDNName) 
            }
            else
            {
                $strTranslatedInheritObjType = "None" #$($_.InheritedObjectType.toString())
            }
	        if($($_.ObjectType.toString()) -ne "00000000-0000-0000-0000-000000000000" )
            {
            
                $strTranslatedObjType = $(MapGUIDToMatchingName -strGUIDAsString $_.ObjectType.toString() -Domain $global:strDomainDNName) 
            }
            else
            {
                $strTranslatedObjType = "None" #$($_.ObjectType.toString())
            }
        }
        else
        {
            $strTranslatedInheritObjType = $($_.InheritedObjectType.toString())
            $strTranslatedObjType = $($_.ObjectType.toString())
        }
        # Add Meta data info to output
        If ($ACLMeta -eq $true)
        {
            $strMetaData = $strACLDate.toString()+[char]34+","+[char]34+$strInvocationID.toString()+[char]34+","+[char]34+ $strOrgUSN.toString()+[char]34+","
	        
        }
        else
        {
            $strMetaData = [char]34+","+[char]34+[char]34+","+[char]34+[char]34+","

        }
        if($chkBoxEffectiveRightsColor.IsChecked -eq $true)
        {
            $intCriticalityValue = GetCriticality $_.ActiveDirectoryRights.toString() $_.AccessControlType.toString() $_.ObjectFlags.toString() $_.InheritanceType.toString()
            Switch ($intCriticalityValue)
            {
                0 {$strLegendText = "Info"+[char]34 +","}
                1 {$strLegendText = "Low"+[char]34 +","}
                2 {$strLegendText = "Medium"+[char]34 +","}
                3 {$strLegendText = "Warning"+[char]34 +","}
                4 {$strLegendText = "Critical"+[char]34 +","}
            }
        }
        else
        {
            $strLegendText = [char]34 +","
        }



        [char]34+$ou+[char]34+","+[char]34+`
        $objType+[char]34+","+[char]34+`
	    $_.IdentityReference.toString()+[char]34+","+[char]34+`
	    $_.ActiveDirectoryRights.toString()+[char]34+","+[char]34+`
	    $_.InheritanceType.toString()+[char]34+","+[char]34+`
	    $strTranslatedObjType+[char]34+","+[char]34+`
	    $strTranslatedInheritObjType+[char]34+","+[char]34+`
	    $_.ObjectFlags.toString()+[char]34+","+[char]34+`
        $(if($null -ne $_.AccessControlType)
        {
        $_.AccessControlType.toString()+[char]34+","+[char]34
        }
        else
        {
        $_.AuditFlags.toString()+[char]34+","+[char]34
        })+`
	    $_.IsInherited.toString()+[char]34+","+[char]34+`
	    $_.InheritanceFlags.toString()+[char]34+","+[char]34+`
        $_.PropagationFlags.toString()+[char]34+","+[char]34+`
        $strMetaData+[char]34+`
         $strLegendText | Out-File -Append -FilePath $fileout 



    } 
}
#==========================================================================
# Function		: ConvertSidToName
# Arguments     : SID string
# Returns   	: Friendly Name of Security Object
# Description   : Try to translate the SID if it fails it try to match a Well-Known.
#==========================================================================
function ConvertSidToName
{
    Param($server,$sid)
$global:strAccNameTranslation = ""     
$ID = New-Object System.Security.Principal.SecurityIdentifier($sid)

&{#Try
	$User = $ID.Translate( [System.Security.Principal.NTAccount])
	$global:strAccNameTranslation = $User.Value
}
Trap [SystemException]
{
	If ($global:dicWellKnownSids.ContainsKey($sid))
	{
		$global:strAccNameTranslation = $global:dicWellKnownSids.Item($sid)
		return $global:strAccNameTranslation
	}
	;Continue
}

if ($global:strAccNameTranslation -eq "")
{

    If ($global:dicSidToName.ContainsKey($sid))
    {
	    $global:strAccNameTranslation =$global:dicSidToName.Item($sid)
    }
    else
    {

        $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC,$global:CREDS)
        $LDAPConnection.SessionOptions.ReferralChasing = "None"
        $request = New-Object System.directoryServices.Protocols.SearchRequest
        if($global:bolShowDeleted)
        {
            [string] $LDAP_SERVER_SHOW_DELETED_OID = "1.2.840.113556.1.4.417"
            [void]$request.Controls.Add((New-Object "System.DirectoryServices.Protocols.DirectoryControl" -ArgumentList "$LDAP_SERVER_SHOW_DELETED_OID",$null,$false,$true ))
        }
        $request.DistinguishedName = "<SID=$sid>"
        $request.Filter = "(name=*)"
        $request.Scope = "Base"
        [void]$request.Attributes.Add("samaccountname")
        [void]$request.Attributes.Add("distinguishedname")
        $response = $LDAPConnection.SendRequest($request)
        $result = $response.Entries[0]
        try
        {
	        $global:strAccNameTranslation =  $global:strDomainShortName + "\" + $result.attributes.samaccountname[0]
        }
        catch
        {
             
        }

	    if(!($global:strAccNameTranslation))
        {
            $global:strAccNameTranslation =  $result.attributes.distinguishedname[0]
        }
        $global:dicSidToName.Add($sid,$global:strAccNameTranslation)
    }

}

If (($global:strAccNameTranslation -eq $nul) -or ($global:strAccNameTranslation -eq ""))
{
	$global:strAccNameTranslation =$sid
}

return $global:strAccNameTranslation
}
#==========================================================================
# Function		: GetCriticality
# Arguments     : $objRights,$objAccess,$objFlags,$objInheritanceType
# Returns   	: Integer
# Description   : Check criticality and returns number for rating
#==========================================================================
Function GetCriticality
{
    Param($objRights,$objAccess,$objFlags,$objInheritanceType)

$intCriticalityLevel = 0

Switch ($objRights)
{
    "ListChildren"
    {
        If ($objAccess -eq "Allow")
        {
            $intCriticalityLevel = 0
        }
    }
    "Modify permissions"
    {
        $intCriticalityLevel = 4
    }
    "DeleteChild, DeleteTree, Delete"
    {
        If ($objAccess -eq "Allow")
        {
            $intCriticalityLevel = 3
        }
    }
    "Delete"
    {
        If ($objAccess -eq "Allow")
        {
            $intCriticalityLevel = 3
        }
    }
    "GenericRead"
    {
        If ($objAccess -eq "Allow")
        {
            $intCriticalityLevel = 1
    	}
    }
    "CreateChild"
    {
        If ($objAccess -eq "Allow")
        {
            $intCriticalityLevel = 3
    	}
    }
    "DeleteChild"
    {
        If ($objAccess -eq "Allow")
        {
            $intCriticalityLevel = 3
    	}
    }
    "ExtendedRight"
    {
        If ($objAccess -eq "Allow")
        {
            $intCriticalityLevel = 4
        }
    }
    "GenericAll"
    {
        If ($objAccess -eq "Allow")
        {
            $intCriticalityLevel = 4
    	}
    }
    "CreateChild, DeleteChild"
    {
        If ($objAccess -eq "Allow")
        {
            $intCriticalityLevel = 3
    	}
    }
    "ReadProperty"
    {
        If ($objAccess -eq "Allow")
        {
            $intCriticalityLevel = 1
    	}
        Switch ($objInheritanceType) 
    	{
    	 	"None"
    	 	{
                #Switch ($objFlags)
                #{ 
                #    "ObjectAceTypePresent"
                #    {
                #       
                #        $objRights = "Read"	
                #    }
                #       	                
                #    "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                #    {
                #        $objRights = "Read"	
                #    }
                #    default
                #    {$objRights = "Read All Properties"	}
                #}#End switch
                $intCriticalityLevel = 1
            }
            "Children"
    	    {
                #Switch ($objFlags)
                #{ 
                #    "ObjectAceTypePresent"
                #    {
                #        $objRights = "Read"	
                #    }
                #    "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                #    {
                #        $objRights = "Read"	
                #    }
                #    default
                #    {$objRights = "Read All Properties"	}
                #}#End switch
                 
            }
            "Descendents"
            {
                #Switch ($objFlags)
                #{ 
                #    "ObjectAceTypePresent"
                #    {
                #        $objRights = "Read"	
                #    }
                #    "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                #    {
                #        $objRights = "Read"	
                #    }
                #    default
                #    {$objRights = "Read All Properties"	}
                #}#End switch
                                  
            }
    	    default
    	    {
                #$objRights = "Read All Properties"	
            }
        }#End switch
    }
    "ReadProperty, WriteProperty" 
    {
        If ($objAccess -eq "Allow")
        {
            $intCriticalityLevel = 2
    	}
        #$objRights = "Read All Properties;Write All Properties"			
    }
    "WriteProperty" 
    {
        If ($objAccess -eq "Allow")
        {
            $intCriticalityLevel = 2
    	}
        #Switch ($objInheritanceType) 
    	#{
    	# 	"None"
    	# 	{
     
                #Switch ($objFlags)
                #{ 
                #    "ObjectAceTypePresent"
                #    {
                #        $objRights = "Write"	
                #    }
                #    "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                #    {
                #        $objRights = "Write"	
                #    }
                #    default
                #    {
                #        $objRights = "Write All Properties"	
                #    }
                #}#End switch
        #    }
        #    "Children"
        #    {
                #Switch ($objFlags)
                #{ 
                #    "ObjectAceTypePresent"
                #    {
                #        $objRights = "Write"	
                #    }
                #               	                
                #    "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                #    {
                #        $objRights = "Write"	
                #    }
                #    default
                #    {
                #        $objRights = "Write All Properties"	
                #    }
                #}#End switch
        #    }
        #    "Descendents"
        #    {
                #Switch ($objFlags)
                #{ 
                #    "ObjectAceTypePresent"
                #    {
                #        $objRights = "Write"	
                #    }
                #    "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                #    {
                #        $objRights = "Write"	
                #    }
                #    default
                #    {
                #        $objRights = "Write All Properties"	
                #    }
                #}#End switch
        #    }
        #    default
        #    {
        #        #$objRights = "Write All Properties"
        #    }
        #}#End switch		
    }
    default
    {
        If ($objAccess -eq "Allow")
        {
            if($objRights -match "Write")
            {
                $intCriticalityLevel = 2
            }         
            if($objRights -match "Create")
            {
                $intCriticalityLevel = 3
            }        
            if($objRights -match "Delete")
            {
                $intCriticalityLevel = 3
            }
            if($objRights -match "ExtendedRight")
            {
                $intCriticalityLevel = 3
            }             
            if($objRights -match "WriteDacl")
            {
                $intCriticalityLevel = 4
            }
            if($objRights -match "WriteOwner")
            {
                $intCriticalityLevel = 4
            }       
        }     
    }
}# End Switch

Return $intCriticalityLevel

}
#==========================================================================
# Function		: WriteHTM
# Arguments     : Security Descriptor, OU dn string, Output htm file
# Returns   	: n/a
# Description   : Wites the SD info to a HTM table, it appends info if the file exist
#==========================================================================
function WriteHTM
{
    Param([bool] $bolACLExist,$sd,[string]$ou,[bool] $OUHeader,[string] $strColorTemp,[string] $htmfileout,[bool] $CompareMode,[bool] $FilterMode,[bool]$boolReplMetaDate,[string]$strReplMetaDate,[bool]$boolACLSize,[string]$strACLSize,[bool]$boolOUProtected,[bool]$bolOUPRotected,[bool]$bolCriticalityLevel,[bool]$bolTranslateGUID,[string]$strObjClass,[bool]$bolObjClass)

$strTHOUColor = "E5CF00"
$strTHColor = "EFAC00"
if ($bolCriticalityLevel -eq $true)
{
$strLegendColor =@"
bgcolor="#A4A4A4"
"@
}
else
{
$strLegendColor = ""
}
$strLegendColorInfo=@"
bgcolor="#A4A4A4"
"@
$strLegendColorLow =@"
bgcolor="#0099FF"
"@
$strLegendColorMedium=@"
bgcolor="#FFFF00"
"@
$strLegendColorWarning=@"
bgcolor="#FFCC00"
"@
$strLegendColorCritical=@"
bgcolor="#DF0101"
"@
$strFont =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontRights =@"
<FONT size="1" face="verdana, hevetica, arial">
"@ 
$strFontOU =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontTH =@"
<FONT size="2" face="verdana, hevetica, arial">
"@
If ($OUHeader -eq $true)
{
$strHTMLText =@"
$strHTMLText
<TR bgcolor="$strTHOUColor"><TD><b>$strFontOU $ou</b>
"@

if ($bolObjClass -eq $true)
{
$strHTMLText =@"
$strHTMLText
<TD><b>$strFontOU $strObjClass</b>
"@
}
if ($boolReplMetaDate -eq $true)
{
$strHTMLText =@"
$strHTMLText
<TD><b>$strFontOU $strReplMetaDate</b>
"@
}
if ($boolACLSize -eq $true)
{
$strHTMLText =@"
$strHTMLText
<TD><b>$strFontOU $strACLSize bytes</b>
"@
}
if ($boolOUProtected -eq $true)
{
    if ($bolOUProtected -eq $true)
    {
$strHTMLText =@"
$strHTMLText
<TD bgcolor="FF0000"><b>$strFontOU $bolOUProtected</b>
"@
    }
    else
    {
$strHTMLText =@"
$strHTMLText
<TD><b>$strFontOU $bolOUProtected</b>
"@
    }
}

$strHTMLText =@"
$strHTMLText
</TR>
"@
}


Switch ($strColorTemp) 
{

"1"
	{
	$strColor = "DDDDDD"
	$strColorTemp = "2"
	}
"2"
	{
	$strColor = "AAAAAA"
	$strColorTemp = "1"
	}		
"3"
	{
	$strColor = "FF1111"
}
"4"
	{
	$strColor = "00FFAA"
}     
"5"
	{
	$strColor = "FFFF00"
}          
	}# End Switch

if ($bolACLExist) 
{
	$sd  | foreach{
    if($null  -ne  $_.AccessControlType)
    {
        $objAccess = $($_.AccessControlType.toString())
    }
    else
    {
        $objAccess = $($_.AuditFlags.toString())
    }
	$objFlags = $($_.ObjectFlags.toString())
	$objType = $($_.ObjectType.toString())
	$objInheritedType = $($_.InheritedObjectType.toString())
	$objRights = $($_.ActiveDirectoryRights.toString())
    $objInheritanceType = $($_.InheritanceType.toString())
    


    if($chkBoxEffectiveRightsColor.IsChecked -eq $false)
    {
    	Switch ($objRights)
    	{
   		    "Self"
    		{
                #Self right are never express in gui it's a validated write ( 0x00000008 ACTRL_DS_SELF)

                 $objRights = ""
            }
    		"DeleteChild, DeleteTree, Delete"
    		{
    			$objRights = "DeleteChild, DeleteTree, Delete"

    		}
    		"GenericRead"
    		{
    			$objRights = "Read Permissions,List Contents,Read All Properties,List"
            }
    		"CreateChild"
    		{
    			$objRights = "Create"	
    		}
    		"DeleteChild"
    		{
    			$objRights = "Delete"		
    		}
    		"GenericAll"
    		{
    			$objRights = "Full Control"		
    		}
    		"CreateChild, DeleteChild"
    		{
    			$objRights = "Create/Delete"		
    		}
    		"ReadProperty"
    		{
    	        Switch ($objInheritanceType) 
    	        {
    	 	        "None"
    	 	        {
                     
                        	 		Switch ($objFlags)
    	    	                { 
    		      	                "ObjectAceTypePresent"
                    {
                       $objRights = "Read"	
                    }
                       	                
    		      	                "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                    {
                       $objRights = "Read"	
                    }
                      default
    	 	                        {$objRights = "Read All Properties"	}
                                }#End switch



                        }
                                  	 	        "Children"
    	 	        {
                     
                        	 		Switch ($objFlags)
    	    	                { 
    		      	                "ObjectAceTypePresent"
                    {
                       $objRights = "Read"	
                    }
                       	                
    		      	                "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                    {
                       $objRights = "Read"	
                    }
                      default
    	 	                        {$objRights = "Read All Properties"	}
                                }#End switch
                                }
                        	 	        "Descendents"
    	 	        {
                     
                        	 		Switch ($objFlags)
    	    	                { 
    		      	                "ObjectAceTypePresent"
                    {
                       $objRights = "Read"	
                    }
                       	                
    		      	                "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                    {
                       $objRights = "Read"	
                    }
                      default
    	 	                        {$objRights = "Read All Properties"	}
                                }#End switch
                                }
    	 	        default
    	 	        {$objRights = "Read All Properties"	}
                }#End switch

    			           	
    		}
    		"ReadProperty, WriteProperty" 
    		{
    			$objRights = "Read All Properties;Write All Properties"			
    		}
    		"WriteProperty" 
    		{
    	        Switch ($objInheritanceType) 
    	        {
    	 	        "None"
    	 	        {
                     
                        	 		Switch ($objFlags)
    	    	                { 
    		      	                "ObjectAceTypePresent"
                    {
                       $objRights = "Write"	
                    }
                       	                
    		      	                "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                    {
                       $objRights = "Write"	
                    }
                      default
    	 	                        {$objRights = "Write All Properties"	}
                                }#End switch



                        }
                                  	 	        "Children"
    	 	        {
                     
                        	 		Switch ($objFlags)
    	    	                { 
    		      	                "ObjectAceTypePresent"
                    {
                       $objRights = "Write"	
                    }
                       	                
    		      	                "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                    {
                       $objRights = "Write"	
                    }
                      default
    	 	                        {$objRights = "Write All Properties"	}
                                }#End switch
                                }
                        	 	        "Descendents"
    	 	        {
                     
                        	 		Switch ($objFlags)
    	    	                { 
    		      	                "ObjectAceTypePresent"
                    {
                       $objRights = "Write"	
                    }
                       	                
    		      	                "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                    {
                       $objRights = "Write"	
                    }
                      default
    	 	                        {$objRights = "Write All Properties"	}
                                }#End switch
                                }
    	 	        default
    	 	        {$objRights = "Write All Properties"	}
                }#End switch		
    		}
    	}# End Switch
    }
    else
    {
 
    	Switch ($objRights)
    	{
    		"Self"
    		{
                #Self right are never express in gui it's a validated write ( 0x00000008 ACTRL_DS_SELF)

                 $objRights = ""
            }
    		"GenericRead"
    		{
                 $objRights = "Read Permissions,List Contents,Read All Properties,List"
            }
    		"CreateChild"
    		{
                 $objRights = "Create"	
    		}
    		"DeleteChild"
    		{
                $objRights = "Delete"		
    		}
    		"GenericAll"
    		{
                $objRights = "Full Control"		
    		}
    		"CreateChild, DeleteChild"
    		{
                $objRights = "Create/Delete"		
    		}
    		"ReadProperty"
    		{
                Switch ($objInheritanceType) 
    	        {
    	 	        "None"
    	 	        {
                     
                        Switch ($objFlags)
    	    	        { 
    		      	        "ObjectAceTypePresent"
                            {
                                $objRights = "Read"	
                            }
    		      	        "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                            {
                                $objRights = "Read"	
                            }
                            default
    	 	                {$objRights = "Read All Properties"	}
                        }#End switch
                    }
                     "Children"
    	 	        {
                     
                        Switch ($objFlags)
    	    	        { 
    		      	        "ObjectAceTypePresent"
                            {
                                $objRights = "Read"	
                            }
    		      	        "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                            {
                                $objRights = "Read"	
                            }
                            default
    	 	                {$objRights = "Read All Properties"	}
                        }#End switch
                    }
                    "Descendents"
                    {
                        Switch ($objFlags)
                        { 
                            "ObjectAceTypePresent"
                            {
                            $objRights = "Read"	
                            }
                       	                
                            "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                            {
                            $objRights = "Read"	
                            }
                            default
                            {$objRights = "Read All Properties"	}
                        }#End switch
                    }
                    default
                    {$objRights = "Read All Properties"	}
                }#End switch
    		}
    		"ReadProperty, WriteProperty" 
    		{
                $objRights = "Read All Properties;Write All Properties"			
    		}
    		"WriteProperty" 
    		{
                Switch ($objInheritanceType) 
    	        {
    	 	        "None"
    	 	        {
                        Switch ($objFlags)
                        { 
                            "ObjectAceTypePresent"
                            {
                               $objRights = "Write"	
                            }
                            "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                            {
                               $objRights = "Write"	
                            }
                            default
                            {
                                $objRights = "Write All Properties"	
                            }
                        }#End switch
                    }
                    "Children"
                    {
                        Switch ($objFlags)
                        { 
                            "ObjectAceTypePresent"
                            {
                                $objRights = "Write"	
                            }
                            "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                            {
                                $objRights = "Write"	
                            }
                            default
                            {
                                $objRights = "Write All Properties"	
                            }
                        }#End switch
                    }
                    "Descendents"
                    {
                        Switch ($objFlags)
                        { 
                            "ObjectAceTypePresent"
                            {
                                $objRights = "Write"	
                            }
                            "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                            {
                                $objRights = "Write"	
                            }
                            default
                            {
                                $objRights = "Write All Properties"	
                            }
                        }#End switch
                    }
                    default
                    {
                        $objRights = "Write All Properties"
                    }
                }#End switch		
    		}
            default
            {
  
            }
    	}# End Switch  

        $intCriticalityValue = GetCriticality $_.ActiveDirectoryRights.toString() $_.AccessControlType.toString() $_.ObjectFlags.toString() $_.InheritanceType.toString()
        
        Switch ($intCriticalityValue)
        {
            0 {$strLegendText = "Info";$strLegendColor = $strLegendColorInfo}
            1 {$strLegendText = "Low";$strLegendColor = $strLegendColorLow}
            2 {$strLegendText = "Medium";$strLegendColor = $strLegendColorMedium}
            3 {$strLegendText = "Warning";$strLegendColor = $strLegendColorWarning}
            4 {$strLegendText = "Critical";$strLegendColor = $strLegendColorCritical}
        }
        $strLegendTextVal = $strLegendText
        if($intCriticalityValue -gt $global:intShowCriticalityLevel)
        {
            $global:intShowCriticalityLevel = $intCriticalityValue
        }
        
    }#End IF else

	$strNTAccount = $($_.IdentityReference.toString())
    
    If ($strNTAccount.contains("S-1-"))
	{
	 $strNTAccount = ConvertSidToName -server $global:strDomainLongName -Sid $strNTAccount

	}
   
    Switch ($strColorTemp) 
    {

    "1"
	{
	$strColor = "DDDDDD"
	$strColorTemp = "2"
	}
	"2"
	{
	$strColor = "AAAAAA"
	$strColorTemp = "1"
	}		
    "3"
	{
	$strColor = "FF1111"
    }
    "4"
	{
	$strColor = "00FFAA"
    }     
    "5"
	{
	$strColor = "FFFF00"
    }          
	}# End Switch

	 Switch ($objInheritanceType) 
	 {
	 	"All"
	 	{
	 		Switch ($objFlags) 
	    	{ 
		      	"InheritedObjectAceTypePresent"
		      	{
		      		$strPerm =  "$strFont This object and all child objects</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD>"
		      	}    	
		      	"ObjectAceTypePresent"
		      	{
		      		$strPerm =  "$strFont This object and all child objects</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName})</TD>"
		      	} 
		      	"ObjectAceTypePresent, InheritedObjectAceTypePresent"
		      	{
		      		$strPerm =  "$strFont $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName})</TD>"
		      	} 	      	
		      	"None"
		      	{
		      		$strPerm ="$strFont This object and all child objects</TD><TD $strLegendColor>$strFontRights $objRights</TD>"
		      	} 
		      		default
	 		    {
		      		$strPerm = "Error: Failed to display permissions 1K"
		      	} 	 
	
		    }# End Switch
	 		
	 	}
	 	"Descendents"
	 	{
	
	 		Switch ($objFlags)
	    	{ 
		      	"InheritedObjectAceTypePresent"
		      	{
		      	$strPerm = "$strFont $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD><TD $strLegendColor>$strFontRights $objRights</TD>"
		      	}
		      	"None"
		      	{
		      		$strPerm ="$strFont Child Objects Only</TD><TD $strLegendColor>$strFontRights $objRights</TD>"
		      	} 	      	
		      	"ObjectAceTypePresent"
		      	{
		      		$strPerm = "$strFont Child Objects Only</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName})</TD>"
		      	} 
		      	"ObjectAceTypePresent, InheritedObjectAceTypePresent"
		      	{
		      		$strPerm =	"$strFont $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName})</TD>"
		      	}
		      	default
	 			{
		      		$strPerm = "Error: Failed to display permissions 2K"
		      	} 	 
	
		    } 		
	 	}
	 	"None"
	 	{
	 		Switch ($objFlags)
	    	{ 
		      	"ObjectAceTypePresent"
		      	{
		      		$strPerm = "$strFont This Object Only</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName}) </TD>"
		      	} 
		      	"None"
		      	{
		      		$strPerm ="$strFont This Object Only</TD><TD $strLegendColor>$strFontRights $objRights </TD>"
		      	} 
		      		default
	 		{
		      		$strPerm = "Error: Failed to display permissions 4K"
		      	} 	 
	
			}
	 	}
	 	"SelfAndChildren"
	 	{
	 	 		Switch ($objFlags)
	    	{ 
		      	"ObjectAceTypePresent"
	      		{
		      		$strPerm = "$strFont This object and all child objects within this conatainer only</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName})</TD>"
		      	}
		      	"InheritedObjectAceTypePresent"
		      	{
		      		$strPerm = "$strFont Children within this conatainer only</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD>"
		      	} 

		      	"ObjectAceTypePresent, InheritedObjectAceTypePresent"
		      	{
		      		$strPerm =  "$strFont $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName})</TD>"
		      	} 	      	
		      	"None"
		      	{
		      		$strPerm ="$strFont This object and all child objects</TD><TD $strLegendColor>$strFontRights $objRights</TD>"
		      	}                                  	   
		      	default
	 		    {
		      		$strPerm = "Error: Failed to display permissions 5K"
		      	} 	 
	
			}   	
	 	} 	
	 	"Children"
	 	{
	 	 		Switch ($objFlags)
	    	{ 
		      	"InheritedObjectAceTypePresent"
		      	{
		      		$strPerm = "$strFont Children within this conatainer only</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD>"
		      	} 
		      	"None"
		      	{
		      		$strPerm = "$strFont Children  within this conatainer only</TD><TD $strLegendColor>$strFontRights $objRights</TD>"
		      	} 	      	
		      	"ObjectAceTypePresent, InheritedObjectAceTypePresent"
	      		{
		      		$strPerm = "$strFont $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD><TD>$strFont $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName}) $objRights</TD>"
		      	} 	
		      	"ObjectAceTypePresent"
	      		{
		      		$strPerm = "$strFont Children within this conatainer only</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName})</TD>"
		      	} 		      	
		      	default
	 			{
		      		$strPerm = "Error: Failed to display permissions 6K"
		      	} 	 
	
	 		}
	 	}
	 	default
	 		{
		      		$strPerm = "Error: Failed to display permissions 7K"
		    } 	 
	}# End Switch

##


$strACLHTMLText =@"
$strACLHTMLText
<TR bgcolor="$strColor"><TD>$strFont $ou</TD>
"@

if ($bolObjClass -eq $true)
{
$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont $strObjClass</TD>
"@
}
if ($boolReplMetaDate -eq $true)
{
$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont $strReplMetaDate</TD>
"@
}

if ($boolACLSize -eq $true)
{
$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont $strACLSize bytes</TD>
"@
}

if ($boolOUProtected -eq $true)
{
$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont $bolOUPRotected </TD>
"@
}
$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont $strNTAccount</TD>
<TD>$strFont $(if($null -ne $_.AccessControlType){$_.AccessControlType.toString()}else{$_.AuditFlags.toString()}) </TD>
<TD>$strFont $($_.IsInherited.toString())</TD>
<TD>$strPerm</TD>
"@

if($CompareMode)
{

$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont $($_.color.toString())</TD>
"@
}
if ($bolCriticalityLevel -eq $true)
{
$strACLHTMLText =@"
$strACLHTMLText
<TD $strLegendColor>$strFont $strLegendTextVal</TD>
"@

}
}# End Foreach

	
}
else
{
if ($OUHeader -eq $false)
{
if ($FilterMode)
{



if ($boolReplMetaDate -eq $true)
{
$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont $strReplMetaDate</TD>
"@
}

if ($boolACLSize -eq $true)
{
$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont $strACLSize bytes</TD>
"@
}

if ($boolOUProtected -eq $true)
{
$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont $bolOUPRotected </TD>
"@
}
$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont N/A</TD>
<TD>$strFont N/A</TD>
<TD>$strFont N/A</TD><
<TD>$strFont N/A</TD>
<TD>$strFont No Matching Permissions Set</TD>
"@



if ($bolCriticalityLevel -eq $true)
{
$strACLHTMLText =@"
$strACLHTMLText
<TD $strLegendColor>$strFont $strLegendTextVal</TD>
"@
}
}
else
{


if ($boolReplMetaDate -eq $true)
{
$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont $strReplMetaDate</TD>
"@
}

if ($boolACLSize -eq $true)
{
$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont $strACLSize bytes</TD>
"@
}

if ($boolOUProtected -eq $true)
{
$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont $bolOUPRotected </TD>
"@
}

$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont N/A</TD>
<TD>$strFont N/A</TD>
<TD>$strFont N/A</TD><
<TD>$strFont N/A</TD>
<TD>$strFont No Permissions Set</TD>
"@


if ($bolCriticalityLevel -eq $true)
{
$strACLHTMLText =@"
$strACLHTMLText
<TD $strLegendColor>$strFont $strLegendTextVal</TD>
"@
}

}# End If
}#end If OUHeader false
}
$strACLHTMLText =@"
$strACLHTMLText
</TR>
"@

#end ifelse OUHEader
$strHTMLText = $strHTMLText + $strACLHTMLText

Out-File -InputObject $strHTMLText -Append -FilePath $htmfileout 
Out-File -InputObject $strHTMLText -Append -FilePath $strFileHTM

$strHTMLText = $null
$strACLHTMLText = $null
Remove-Variable -Name "strHTMLText"
Remove-Variable -Name "strACLHTMLText"

}
#==========================================================================
# Function		: WriteHTM
# Arguments     : Security Descriptor, OU dn string, Output htm file
# Returns   	: n/a
# Description   : Wites the SD info to a HTM table, it appends info if the file exist
#==========================================================================
function WriteDefSDAccessHTM
{
    Param($sd, $strObjectClass, $strColorTemp,$htmfileout, $strFileHTM, $OUHeader, $boolReplMetaDate, $strReplMetaVer, $strReplMetaDate, $bolCriticalityLevel,
    [boolean]$CompareMode)

$strTHOUColor = "E5CF00"
$strTHColor = "EFAC00"
if ($bolCriticalityLevel -eq $true)
{
$strLegendColor =@"
bgcolor="#A4A4A4"
"@
}
else
{
$strLegendColor = ""
}
$strLegendColorInfo=@"
bgcolor="#A4A4A4"
"@
$strLegendColorLow =@"
bgcolor="#0099FF"
"@
$strLegendColorMedium=@"
bgcolor="#FFFF00"
"@
$strLegendColorWarning=@"
bgcolor="#FFCC00"
"@
$strLegendColorCritical=@"
bgcolor="#DF0101"
"@
$strFont =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontRights =@"
<FONT size="1" face="verdana, hevetica, arial">
"@ 
$strFontOU =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontTH =@"
<FONT size="2" face="verdana, hevetica, arial">
"@
If ($OUHeader -eq $true)
{
$strHTMLText =@"
$strHTMLText
<TR bgcolor="$strTHOUColor"><TD><b>$strFontOU $strObjectClass</b>
"@
if ($boolReplMetaDate -eq $true)
{
$strHTMLText =@"
$strHTMLText
<TD><b>$strFontOU $strReplMetaDate</b>
<TD><b>$strFontOU $strReplMetaVer</b>
"@
}



$strHTMLText =@"
$strHTMLText
</TR>
"@
}


Switch ($strColorTemp) 
{

"1"
	{
	$strColor = "DDDDDD"
	$strColorTemp = "2"
	}
	"2"
	{
	$strColor = "AAAAAA"
	$strColorTemp = "1"
	}		
"3"
	{
	$strColor = "FF1111"
}
"4"
	{
	$strColor = "00FFAA"
}     
"5"
	{
	$strColor = "FFFF00"
}          
	}# End Switch


	$sd  | foreach{
    if($null  -ne  $_.AccessControlType)
    {
        $objAccess = $($_.AccessControlType.toString())
    }
    else
    {
        $objAccess = $($_.AuditFlags.toString())
    }
	$objFlags = $($_.ObjectFlags.toString())
	$objType = $($_.ObjectType.toString())
	$objInheritedType = $($_.InheritedObjectType.toString())
	$objRights = $($_.ActiveDirectoryRights.toString())
    $objInheritanceType = $($_.InheritanceType.toString())
    


    if($chkBoxEffectiveRightsColor.IsChecked -eq $false)
    {
    	Switch ($objRights)
    	{
   		    "Self"
    		{
                #Self right are never express in gui it's a validated write ( 0x00000008 ACTRL_DS_SELF)

                 $objRights = ""
            }
    		"DeleteChild, DeleteTree, Delete"
    		{
    			$objRights = "DeleteChild, DeleteTree, Delete"

    		}
    		"GenericRead"
    		{
    			$objRights = "Read Permissions,List Contents,Read All Properties,List"
            }
    		"CreateChild"
    		{
    			$objRights = "Create"	
    		}
    		"DeleteChild"
    		{
    			$objRights = "Delete"		
    		}
    		"GenericAll"
    		{
    			$objRights = "Full Control"		
    		}
    		"CreateChild, DeleteChild"
    		{
    			$objRights = "Create/Delete"		
    		}
    		"ReadProperty"
    		{
    	        Switch ($objInheritanceType) 
    	        {
    	 	        "None"
    	 	        {
                     
                        	 		Switch ($objFlags)
    	    	                { 
    		      	                "ObjectAceTypePresent"
                    {
                       $objRights = "Read"	
                    }
                       	                
    		      	                "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                    {
                       $objRights = "Read"	
                    }
                      default
    	 	                        {$objRights = "Read All Properties"	}
                                }#End switch



                        }
                                  	 	        "Children"
    	 	        {
                     
                        	 		Switch ($objFlags)
    	    	                { 
    		      	                "ObjectAceTypePresent"
                    {
                       $objRights = "Read"	
                    }
                       	                
    		      	                "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                    {
                       $objRights = "Read"	
                    }
                      default
    	 	                        {$objRights = "Read All Properties"	}
                                }#End switch
                                }
                        	 	        "Descendents"
    	 	        {
                     
                        	 		Switch ($objFlags)
    	    	                { 
    		      	                "ObjectAceTypePresent"
                    {
                       $objRights = "Read"	
                    }
                       	                
    		      	                "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                    {
                       $objRights = "Read"	
                    }
                      default
    	 	                        {$objRights = "Read All Properties"	}
                                }#End switch
                                }
    	 	        default
    	 	        {$objRights = "Read All Properties"	}
                }#End switch

    			           	
    		}
    		"ReadProperty, WriteProperty" 
    		{
    			$objRights = "Read All Properties;Write All Properties"			
    		}
    		"WriteProperty" 
    		{
    	        Switch ($objInheritanceType) 
    	        {
    	 	        "None"
    	 	        {
                     
                        	 		Switch ($objFlags)
    	    	                { 
    		      	                "ObjectAceTypePresent"
                    {
                       $objRights = "Write"	
                    }
                       	                
    		      	                "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                    {
                       $objRights = "Write"	
                    }
                      default
    	 	                        {$objRights = "Write All Properties"	}
                                }#End switch



                        }
                                  	 	        "Children"
    	 	        {
                     
                        	 		Switch ($objFlags)
    	    	                { 
    		      	                "ObjectAceTypePresent"
                    {
                       $objRights = "Write"	
                    }
                       	                
    		      	                "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                    {
                       $objRights = "Write"	
                    }
                      default
    	 	                        {$objRights = "Write All Properties"	}
                                }#End switch
                                }
                        	 	        "Descendents"
    	 	        {
                     
                        	 		Switch ($objFlags)
    	    	                { 
    		      	                "ObjectAceTypePresent"
                    {
                       $objRights = "Write"	
                    }
                       	                
    		      	                "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                    {
                       $objRights = "Write"	
                    }
                      default
    	 	                        {$objRights = "Write All Properties"	}
                                }#End switch
                                }
    	 	        default
    	 	        {$objRights = "Write All Properties"	}
                }#End switch		
    		}
    	}# End Switch
    }
    else
    {
 
    	Switch ($objRights)
    	{
   		    "Self"
    		{
                #Self right are never express in gui it's a validated write ( 0x00000008 ACTRL_DS_SELF)

                 $objRights = ""
            }
    		"GenericRead"
    		{
                 $objRights = "Read Permissions,List Contents,Read All Properties,List"
            }
    		"CreateChild"
    		{
                 $objRights = "Create"	
    		}
    		"DeleteChild"
    		{
                $objRights = "Delete"		
    		}
    		"GenericAll"
    		{
                $objRights = "Full Control"		
    		}
    		"CreateChild, DeleteChild"
    		{
                $objRights = "Create/Delete"		
    		}
    		"ReadProperty"
    		{
                Switch ($objInheritanceType) 
    	        {
    	 	        "None"
    	 	        {
                     
                        Switch ($objFlags)
    	    	        { 
    		      	        "ObjectAceTypePresent"
                            {
                                $objRights = "Read"	
                            }
    		      	        "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                            {
                                $objRights = "Read"	
                            }
                            default
    	 	                {$objRights = "Read All Properties"	}
                        }#End switch
                    }
                     "Children"
    	 	        {
                     
                        Switch ($objFlags)
    	    	        { 
    		      	        "ObjectAceTypePresent"
                            {
                                $objRights = "Read"	
                            }
    		      	        "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                            {
                                $objRights = "Read"	
                            }
                            default
    	 	                {$objRights = "Read All Properties"	}
                        }#End switch
                    }
                    "Descendents"
                    {
                        Switch ($objFlags)
                        { 
                            "ObjectAceTypePresent"
                            {
                            $objRights = "Read"	
                            }
                       	                
                            "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                            {
                            $objRights = "Read"	
                            }
                            default
                            {$objRights = "Read All Properties"	}
                        }#End switch
                    }
                    default
                    {$objRights = "Read All Properties"	}
                }#End switch
    		}
    		"ReadProperty, WriteProperty" 
    		{
                $objRights = "Read All Properties;Write All Properties"			
    		}
    		"WriteProperty" 
    		{
                Switch ($objInheritanceType) 
    	        {
    	 	        "None"
    	 	        {
                        Switch ($objFlags)
                        { 
                            "ObjectAceTypePresent"
                            {
                               $objRights = "Write"	
                            }
                            "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                            {
                               $objRights = "Write"	
                            }
                            default
                            {
                                $objRights = "Write All Properties"	
                            }
                        }#End switch
                    }
                    "Children"
                    {
                        Switch ($objFlags)
                        { 
                            "ObjectAceTypePresent"
                            {
                                $objRights = "Write"	
                            }
                            "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                            {
                                $objRights = "Write"	
                            }
                            default
                            {
                                $objRights = "Write All Properties"	
                            }
                        }#End switch
                    }
                    "Descendents"
                    {
                        Switch ($objFlags)
                        { 
                            "ObjectAceTypePresent"
                            {
                                $objRights = "Write"	
                            }
                            "ObjectAceTypePresent, InheritedObjectAceTypePresent"
                            {
                                $objRights = "Write"	
                            }
                            default
                            {
                                $objRights = "Write All Properties"	
                            }
                        }#End switch
                    }
                    default
                    {
                        $objRights = "Write All Properties"
                    }
                }#End switch		
    		}
            default
            {
  
            }
    	}# End Switch  

        $intCriticalityValue = GetCriticality $_.ActiveDirectoryRights.toString() $_.AccessControlType.toString() $_.ObjectFlags.toString() $_.InheritanceType.toString()
        
        Switch ($intCriticalityValue)
        {
            0 {$strLegendText = "Info";$strLegendColor = $strLegendColorInfo}
            1 {$strLegendText = "Low";$strLegendColor = $strLegendColorLow}
            2 {$strLegendText = "Medium";$strLegendColor = $strLegendColorMedium}
            3 {$strLegendText = "Warning";$strLegendColor = $strLegendColorWarning}
            4 {$strLegendText = "Critical";$strLegendColor = $strLegendColorCritical}
        }
        $strLegendTextVal = $strLegendText
        if($intCriticalityValue -gt $global:intShowCriticalityLevel)
        {
            $global:intShowCriticalityLevel = $intCriticalityValue
        }
        
    }#End IF else

	$strNTAccount = $($_.IdentityReference.toString())
    
	If ($strNTAccount.contains("S-1-"))
	{
	 $strNTAccount = ConvertSidToName -server $global:strDomainLongName -Sid $strNTAccount

	}
   
    Switch ($strColorTemp) 
    {

    "1"
	{
	$strColor = "DDDDDD"
	$strColorTemp = "2"
	}
	"2"
	{
	$strColor = "AAAAAA"
	$strColorTemp = "1"
	}		
    "3"
	{
	$strColor = "FF1111"
    }
    "4"
	{
	$strColor = "00FFAA"
    }     
    "5"
	{
	$strColor = "FFFF00"
    }          
	}# End Switch

	 Switch ($objInheritanceType) 
	 {
	 	"All"
	 	{
	 		Switch ($objFlags) 
	    	{ 
		      	"InheritedObjectAceTypePresent"
		      	{
		      		$strPerm =  "$strFont This object and all child objects</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD>"
		      	}    	
		      	"ObjectAceTypePresent"
		      	{
		      		$strPerm =  "$strFont This object and all child objects</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName})</TD>"
		      	} 
		      	"ObjectAceTypePresent, InheritedObjectAceTypePresent"
		      	{
		      		$strPerm =  "$strFont $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName})</TD>"
		      	} 	      	
		      	"None"
		      	{
		      		$strPerm ="$strFont This object and all child objects</TD><TD $strLegendColor>$strFontRights $objRights</TD>"
		      	} 
		      		default
	 		    {
		      		$strPerm = "Error: Failed to display permissions 1K"
		      	} 	 
	
		    }# End Switch
	 		
	 	}
	 	"Descendents"
	 	{
	
	 		Switch ($objFlags)
	    	{ 
		      	"InheritedObjectAceTypePresent"
		      	{
		      	$strPerm = "$strFont $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD><TD $strLegendColor>$strFontRights $objRights</TD>"
		      	}
		      	"None"
		      	{
		      		$strPerm ="$strFont Child Objects Only</TD><TD $strLegendColor>$strFontRights $objRights</TD>"
		      	} 	      	
		      	"ObjectAceTypePresent"
		      	{
		      		$strPerm = "$strFont Child Objects Only</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName})</TD>"
		      	} 
		      	"ObjectAceTypePresent, InheritedObjectAceTypePresent"
		      	{
		      		$strPerm =	"$strFont $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName})</TD>"
		      	}
		      	default
	 			{
		      		$strPerm = "Error: Failed to display permissions 2K"
		      	} 	 
	
		    } 		
	 	}
	 	"None"
	 	{
	 		Switch ($objFlags)
	    	{ 
		      	"ObjectAceTypePresent"
		      	{
		      		$strPerm = "$strFont This Object Only</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName}) </TD>"
		      	} 
		      	"None"
		      	{
		      		$strPerm ="$strFont This Object Only</TD><TD $strLegendColor>$strFontRights $objRights </TD>"
		      	} 
		      		default
	 		{
		      		$strPerm = "Error: Failed to display permissions 4K"
		      	} 	 
	
			}
	 	}
	 	"SelfAndChildren"
	 	{
	 	 		Switch ($objFlags)
	    	{ 
		      	"ObjectAceTypePresent"
	      		{
		      		$strPerm = "$strFont This object and all child objects within this conatainer only</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName})</TD>"
		      	}
		      	"InheritedObjectAceTypePresent"
		      	{
		      		$strPerm = "$strFont Children within this conatainer only</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD>"
		      	} 

		      	"ObjectAceTypePresent, InheritedObjectAceTypePresent"
		      	{
		      		$strPerm =  "$strFont $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName})</TD>"
		      	} 	      	
		      	"None"
		      	{
		      		$strPerm ="$strFont This object and all child objects</TD><TD $strLegendColor>$strFontRights $objRights</TD>"
		      	}                                  	   
		      	default
	 		    {
		      		$strPerm = "Error: Failed to display permissions 5K"
		      	} 	 
	
			}   	
	 	} 	
	 	"Children"
	 	{
	 	 		Switch ($objFlags)
	    	{ 
		      	"InheritedObjectAceTypePresent"
		      	{
		      		$strPerm = "$strFont Children within this conatainer only</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD>"
		      	} 
		      	"None"
		      	{
		      		$strPerm = "$strFont Children  within this conatainer only</TD><TD $strLegendColor>$strFontRights $objRights</TD>"
		      	} 	      	
		      	"ObjectAceTypePresent, InheritedObjectAceTypePresent"
	      		{
		      		$strPerm = "$strFont $(if($bolTranslateGUID){$objInheritedType}else{MapGUIDToMatchingName -strGUIDAsString $objInheritedType -Domain $global:strDomainDNName})</TD><TD>$strFont $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName}) $objRights</TD>"
		      	} 	
		      	"ObjectAceTypePresent"
	      		{
		      		$strPerm = "$strFont Children within this conatainer only</TD><TD $strLegendColor>$strFontRights $objRights $(if($bolTranslateGUID){$objType}else{MapGUIDToMatchingName -strGUIDAsString $objType -Domain $global:strDomainDNName})</TD>"
		      	} 		      	
		      	default
	 			{
		      		$strPerm = "Error: Failed to display permissions 6K"
		      	} 	 
	
	 		}
	 	}
	 	default
	 		{
		      		$strPerm = "Error: Failed to display permissions 7K"
		    } 	 
	}# End Switch

##

$strACLHTMLText =@"
$strACLHTMLText
<TR bgcolor="$strColor"><TD>$strFont $strObjectClass</TD>
"@

if ($boolReplMetaDate -eq $true)
{
$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont $strReplMetaDate</TD>
<TD>$strFont $strReplMetaVer</TD>
"@
}
$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont $strNTAccount</TD>
<TD>$strFont $(if($null -ne $_.AccessControlType){$_.AccessControlType.toString()}else{$_.AuditFlags.toString()}) </TD>
<TD>$strFont $($_.IsInherited.toString())</TD>
<TD>$strPerm</TD>
"@

if($CompareMode)
{

$strACLHTMLText =@"
$strACLHTMLText
<TD>$strFont $($_.color.toString())</TD>
"@
}


}# End Foreach

	

$strACLHTMLText =@"
$strACLHTMLText
</TR>
"@

#end ifelse OUHEader
$strHTMLText = $strHTMLText + $strACLHTMLText

Out-File -InputObject $strHTMLText -Append -FilePath $htmfileout 
Out-File -InputObject $strHTMLText -Append -FilePath $strFileHTM

$strHTMLText = $null
$strACLHTMLText = $null
Remove-Variable -Name "strHTMLText"
Remove-Variable -Name "strACLHTMLText"

}
#==========================================================================
# Function		: InitiateDefSDAccessHTM
# Arguments     : Output htm file
# Returns   	: n/a
# Description   : Wites base HTM table syntax, it appends info if the file exist
#==========================================================================
Function InitiateDefSDAccessHTM
{
    Param([string] $htmfileout,
    [string]$strStartingPoint,
    $RepMetaDate,
    [bool]$bolCompare,
    [string] $strComparefile)

$strACLTypeHeader = "Access"
If($bolCompare)
{
$strHTMLText =@"
<h1 style="color: #79A0E0;text-align: center;">Default Security Descriptor COMPARE REPORT - $($strStartingPoint.ToUpper())</h1>
<h3 style="color: #191010;text-align: center;">
Template: $strComparefile
</h3>
"@ 
}
else
{
$strHTMLText =@"
<h1 style="color: #79A0E0;text-align: center;">Default Security Descriptor REPORT - $($strStartingPoint.ToUpper())</h1>
"@ 
}

$strHTMLText =@"
$strHTMLText
<TABLE BORDER=1>
"@ 
$strTHOUColor = "E5CF00"
$strTHColor = "EFAC00"
$strFont =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontOU =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontTH =@"
<FONT size="2" face="verdana, hevetica, arial">
"@
$strHTMLText =@"
$strHTMLText
<th bgcolor="$strTHColor">$strFontTH ObjectClass</font></th>
"@
if ($RepMetaDate -eq $true)
{
$strHTMLText =@"
$strHTMLText
<th bgcolor="$strTHColor">$strFontTH Security Descriptor Modified</font><th bgcolor="$strTHColor">$strFontTH Version</font>
"@
}
$strHTMLText =@"
$strHTMLText
<th bgcolor="$strTHColor">$strFontTH Trustee</font></th><th bgcolor="$strTHColor">$strFontTH $strACLTypeHeader</font></th><th bgcolor="$strTHColor">$strFontTH Inherited</font></th><th bgcolor="$strTHColor">$strFontTH Apply To</font></th><th bgcolor="$strTHColor">$strFontTH Permission</font></th>
"@

if ($bolCompare -eq $true)
{
$strHTMLText =@"
$strHTMLText
<th bgcolor="$strTHColor">$strFontTH State</font></th>
"@
}




Out-File -InputObject $strHTMLText -Append -FilePath $htmfileout 
$strHTMLText = $null
$strTHOUColor = $null
$strTHColor = $null
Remove-Variable -Name "strHTMLText"
Remove-Variable -Name "strTHOUColor"
Remove-Variable -Name "strTHColor"


}

#==========================================================================
# Function		: InitiateHTM
# Arguments     : Output htm file
# Returns   	: n/a
# Description   : Wites base HTM table syntax, it appends info if the file exist
#==========================================================================
Function InitiateHTM
{
    Param([string] $htmfileout,[string]$strStartingPoint,[string]$strDN,[bool]$RepMetaDate ,[bool]$ACLSize,[bool]$bolACEOUProtected,[bool]$bolCirticaltiy,[bool]$bolCompare,[bool]$SkipDefACE,[bool]$SkipProtectDelACE,[string]$strComparefile,[bool]$bolFilter,[bool]$bolEffectiveRights,[bool]$bolObjType)
If($rdbSACL.IsChecked)
{
$strACLTypeHeader = "Audit"
}
else
{
$strACLTypeHeader = "Access"
}
If($bolCompare)
{
$strHTMLText =@"
<h1 style="color: #79A0E0;text-align: center;">COMPARE REPORT - $($strStartingPoint.ToUpper())</h1>
<h3 style="color: #191010;text-align: center;">
Template: $strComparefile
</h3>
"@ 
}
else
{
If($bolFilter)
{
$strHTMLText =@"
<h1 style="color: #79A0E0;text-align: center;">FILTERED REPORT - $($strStartingPoint.ToUpper())</h1>
"@
}
else
{
If($bolEffectiveRights)
{

$strHTMLText =@"
<h1 style="color: #79A0E0;text-align: center;">EFFECTIVE RIGHTS REPORT <br>
Service Principal: $($global:strEffectiveRightAccount.ToUpper())</h1>
"@ 
}
else
{
$strHTMLText =@"
<h1 style="color: #79A0E0;text-align: center;">ACL REPORT - $($strStartingPoint.ToUpper())</h1>
"@ 
}
}
}
If($bolCirticaltiy)
{
$strHTMLText =@"
$strHTMLText
<div style="text-align: center;font-weight: bold}">
<FONT size="6"  color= "#79A0E0">Highest Criticality Level:</FONT> 20141220T021111056594002014122000</FONT>
</div>
"@ 
}
$strHTMLText =@"
$strHTMLText
<h3 style="color: #191010;text-align: center;">$strDN<br>
Report Created: $(get-date -uformat "%Y-%m-%d %H:%M:%S")</h3>
"@ 
If($SkipDefACE)
{
$strHTMLText =@"
$strHTMLText
<h3 style="color: #191010;text-align: center;">Default permissions excluced</h3>
"@ 
}
If($SkipProtectDelACE)
{
$strHTMLText =@"
$strHTMLText
<h3 style="color: #191010;text-align: center;">Protected against accidental deletions permissions excluced</h3>
"@ 
}
$strHTMLText =@"
$strHTMLText
<TABLE BORDER=1>
"@ 
$strTHOUColor = "E5CF00"
$strTHColor = "EFAC00"
$strFont =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontOU =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontTH =@"
<FONT size="2" face="verdana, hevetica, arial">
"@
$strHTMLText =@"
$strHTMLText
<th bgcolor="$strTHColor">$strFontTH Object</font></th>
"@
if ($bolObjType -eq $true)
{
$strHTMLText =@"
$strHTMLText
<th bgcolor="$strTHColor">$strFontTH ObjectClass</font>
"@
}
if ($RepMetaDate -eq $true)
{
$strHTMLText =@"
$strHTMLText
<th bgcolor="$strTHColor">$strFontTH Security Descriptor Modified</font>
"@
}
if ($ACLSize -eq $true)
{
$strHTMLText =@"
$strHTMLText
<th bgcolor="$strTHColor">$strFontTH DACL Size</font>
"@
}
if ($bolACEOUProtected -eq $true)
{
$strHTMLText =@"
$strHTMLText
<th bgcolor="$strTHColor">$strFontTH Inheritance Disabled</font>
"@
}
$strHTMLText =@"
$strHTMLText
</th><th bgcolor="$strTHColor">$strFontTH Trustee</font></th><th bgcolor="$strTHColor">$strFontTH $strACLTypeHeader</font></th><th bgcolor="$strTHColor">$strFontTH Inherited</font></th><th bgcolor="$strTHColor">$strFontTH Apply To</font></th><th bgcolor="$strTHColor">$strFontTH Permission</font></th>
"@

if ($bolCompare -eq $true)
{
$strHTMLText =@"
$strHTMLText
<th bgcolor="$strTHColor">$strFontTH State</font></th>
"@
}


if ($bolCirticaltiy -eq $true)
{
$strHTMLText =@"
$strHTMLText
<th bgcolor="$strTHColor">$strFontTH Criticality Level</font></th>
"@
}



Out-File -InputObject $strHTMLText -Append -FilePath $htmfileout 
$strHTMLText = $null
$strTHOUColor = $null
$strTHColor = $null
Remove-Variable -Name "strHTMLText"
Remove-Variable -Name "strTHOUColor"
Remove-Variable -Name "strTHColor"


}

#==========================================================================
# Function		: CreateHTA
# Arguments     : OU Name, Ou put HTA file
# Returns   	: n/a
# Description   : Initiates a base HTA file with Export(Save As),Print and Exit buttons.
#==========================================================================
function CreateHTA
{
    Param([string]$NodeName,[string]$htafileout,[string]$htmfileout,[string] $folder)([string]$NodeName,[string]$htafileout,[string]$htmfileout,[string] $folder)
$strHTAText =@"
<html>
<head>
<hta:Application ID="hta"
ApplicationName="Report">
<title>Report on $NodeName</title>
<script type="text/vbscript">
Sub ExportToCSV()
Dim objFSO,objFile,objNewFile,oShell,oEnv
Set oShell=CreateObject("wscript.shell")
Set oEnv=oShell.Environment("System")
strTemp=oShell.ExpandEnvironmentStrings("%USERPROFILE%")
strTempFile="$htmfileout"
strOutputFolder="$folder"
strFile=SaveAs("$NodeName.htm",strOutputFolder)
If strFile="" Then Exit Sub
Set objFSO=CreateObject("Scripting.FileSystemObject")
objFSO.CopyFile strTempFile,strFile, true
MsgBox "Finished exporting to " & strFile,vbOKOnly+vbInformation,"Export"
End Sub
Function SaveAs(strFile,strOutFolder)
Dim objDialog
SaveAs=InputBox("Enter the filename and path."&vbCrlf&vbCrlf&"Example: "&strOutFolder&"\CONTOSO-contoso.htm","Export",strOutFolder&"\"&strFile)
End Function
</script>
</head>
<body>
<input type="button" value="Export" onclick="ExportToCSV" tabindex="9">
<input id="print_button" type="button" value="Print" name="Print_button" class="Hide" onClick="Window.print()">
<input type="button" value="Exit" onclick=self.close name="B3" tabindex="1" class="btn">
"@
Out-File -InputObject $strHTAText -Force -FilePath $htafileout 
}
#==========================================================================
# Function		: WriteSPNHTM
# Arguments     : Security Principal Name,  Output htm file
# Returns   	: n/a
# Description   : Wites the account membership info to a HTM table, it appends info if the file exist
#==========================================================================
function WriteSPNHTM
{
    Param([string] $strSPN,$tokens,[string]$objType,[int]$intMemberOf,[string] $strColorTemp,[string] $htafileout,[string] $htmfileout)
#$strHTMLText ="<TABLE BORDER=1>" 
$strTHOUColor = "E5CF00"
$strTHColor = "EFAC00"
$strFont =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontOU =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontTH =@"
<FONT size="2" face="verdana, hevetica, arial">
"@

$strHTMLText =@"
$strHTMLText
<TR bgcolor="$strTHOUColor"><TD><b>$strFontOU $strSPN</b><TD><b>$strFontOU $objType</b><TD><b>$strFontOU $intMemberOf</b></TR>
"@
$strHTMLText =@"
$strHTMLText
<TR bgcolor="$strTHColor"><TD><b>$strFontTH Groups</b></TD><TD></TD><TD></TD></TR>
"@


$tokens  | foreach{
if ($($_.toString()) -ne $strSPN)
{
Switch ($strColorTemp) 
{

"1"
	{
	$strColor = "DDDDDD"
	$strColorTemp = "2"
	}
"2"
	{
	$strColor = "AAAAAA"
	$strColorTemp = "1"
	}		
"3"
	{
	$strColor = "FF1111"
}
"4"
	{
	$strColor = "00FFAA"
}     
"5"
	{
	$strColor = "FFFF00"
}          
	}# End Switch
$strGroupText=$strGroupText+@"
<TR bgcolor="$strColor"><TD>
$strFont $($_.toString())</TD></TR>
"@
}
}
$strHTMLText = $strHTMLText + $strGroupText


Out-File -InputObject $strHTMLText -Append -FilePath $htafileout
Out-File -InputObject $strHTMLText -Append -FilePath $htmfileout

$strHTMLText = ""

}
#==========================================================================
# Function		: CreateColorLegenedReportHTA
# Arguments     : OU Name, Ou put HTA file
# Returns   	: n/a
# Description   : Initiates a base HTA file with Export(Save As),Print and Exit buttons.
#==========================================================================
function CreateColorLegenedReportHTA
{
    Param([string]$htafileout)
$strHTAText =@"
<html>
<head>
<hta:Application ID="hta"
ApplicationName="Legend">
<title>Color Code</title>
<script type="text/vbscript">
Sub Window_Onload

 	self.ResizeTo 500,500
End sub
</script>
</head>
<body>

<input type="button" value="Exit" onclick=self.close name="B3" tabindex="1" class="btn">
"@

$strTHOUColor = "E5CF00"
$strTHColor = "EFAC00"
$strFont =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontOU =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontTH =@"
<FONT size="2" face="verdana, hevetica, arial">
"@
$strLegendColorInfo=@"
bgcolor="#A4A4A4"
"@
$strLegendColorLow =@"
bgcolor="#0099FF"
"@
$strLegendColorMedium=@"
bgcolor="#FFFF00"
"@
$strLegendColorWarning=@"
bgcolor="#FFCC00"
"@
$strLegendColorCritical=@"
bgcolor="#DF0101"
"@

$strHTAText =@"
$strHTAText
<h4>Use colors in report to identify criticality level of permissions.<br>This might help you in implementing <B>Least-Privilege</B> Administrative Models.</h4>
<TABLE BORDER=1>
<th bgcolor="$strTHColor">$strFontTH Permissions</font></th><th bgcolor="$strTHColor">$strFontTH Criticality</font></th>
<TR><TD> $strFontTH <B>Deny Permissions<TD $strLegendColorInfo> Info</TR>
<TR><TD> $strFontTH <B>List<TD $strLegendColorInfo>Info</TR>
<TR><TD> $strFontTH <B>Read Properties<TD $strLegendColorLow>Low</TR>
<TR><TD> $strFontTH <B>Read Object<TD $strLegendColorLow>Low</TR>
<TR><TD> $strFontTH <B>Read Permissions<TD $strLegendColorLow>Low</TR>
<TR><TD> $strFontTH <B>Write Propeties<TD $strLegendColorMedium>Medium</TR>
<TR><TD> $strFontTH <B>Create Object<TD $strLegendColorWarning>Warning</TR>
<TR><TD> $strFontTH <B>Delete Object<TD $strLegendColorWarning>Warning</TR>
<TR><TD> $strFontTH <B>ExtendedRight<TD $strLegendColorWarning>Warning</TR>
<TR><TD> $strFontTH <B>Modify Permisions<TD $strLegendColorCritical>Critical</TR>
<TR><TD> $strFontTH <B>Full Control<TD $strLegendColorCritical>Critical</TR>

"@


##
Out-File -InputObject $strHTAText -Force -FilePath $htafileout 
}
#==========================================================================
# Function		: WriteDefSDSDDLHTM
# Arguments     : Security Principal Name,  Output htm file
# Returns   	: n/a
# Description   : Wites the account membership info to a HTM table, it appends info if the file exist
#==========================================================================
function WriteDefSDSDDLHTM
{
    Param([string] $strColorTemp,[string] $htafileout,[string] $htmfileout,[string]$strObjectClass,[string]$strDefSDVer,[string]$strDefSDDate,[string]$strSDDL)
$strTHOUColor = "E5CF00"
$strTHColor = "EFAC00"
$strFont =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontOU =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontTH =@"
<FONT size="2" face="verdana, hevetica, arial">
"@

$strHTMLText =@"
$strHTMLText
<TR bgcolor="$strTHOUColor"><TD><b>$strFontOU $strObjectClass</b>
<TD><b>$strFontOU $strDefSDVer</b>
<TD><b>$strFontOU $strDefSDDate</b>
"@




$strHTMLText =@"
$strHTMLText
</TR>
"@

Switch ($strColorTemp) 
{

    "1"
	    {
	    $strColor = "DDDDDD"
	    $strColorTemp = "2"
	    }
    "2"
	    {
	    $strColor = "AAAAAA"
	    $strColorTemp = "1"
	    }		
    "3"
	    {
	    $strColor = "FF1111"
    }
    "4"
	    {
	    $strColor = "00FFAA"
    }     
    "5"
	    {
	    $strColor = "FFFF00"
    }          
}# End Switch

$strGroupText=$strGroupText+@"
<TR bgcolor="$strColor"><TD> $strFont $strObjectClass</TD><TD> $strFont $strDefSDVer</TD><TD> $strFont $strDefSDDate</TD><TD> $strFont $strSDDL</TD></TR>
"@


$strHTMLText = $strHTMLText + $strGroupText


Out-File -InputObject $strHTMLText -Append -FilePath $htafileout
Out-File -InputObject $strHTMLText -Append -FilePath $htmfileout

$strHTMLText = ""

}

#==========================================================================
# Function		: CreateDefaultSDReportHTA
# Arguments     : Forest Name, Output HTA file
# Returns   	: n/a
# Description   : Initiates a base HTA file with Export(Save As),Print and Exit buttons.
#==========================================================================
function CreateDefaultSDReportHTA
{
    Param([string]$Forest,[string]$htafileout,[string]$htmfileout,[string] $folder)
$strHTAText =@"
<html>
<head>
<hta:Application ID="hta"
ApplicationName="Report">
<title>defaultSecurityDescriptor Report on $Forest</title>
<script type="text/vbscript">
Sub ExportToCSV()
Dim objFSO,objFile,objNewFile,oShell,oEnv
Set oShell=CreateObject("wscript.shell")
Set oEnv=oShell.Environment("System")
strTemp=oShell.ExpandEnvironmentStrings("%USERPROFILE%")
strTempFile="$htmfileout"
strOutputFolder="$folder"
strFile=SaveAs("$($Forest.Split("\")[-1]).htm",strOutputFolder)
If strFile="" Then Exit Sub
Set objFSO=CreateObject("Scripting.FileSystemObject")
objFSO.CopyFile strTempFile,strFile, true
MsgBox "Finished exporting to " & strFile,vbOKOnly+vbInformation,"Export"
End Sub
Function SaveAs(strFile,strOutFolder)
Dim objDialog
SaveAs=InputBox("Enter the filename and path."&vbCrlf&vbCrlf&"Example: "&strOutFolder&"\CONTOSO-contoso.htm","Export",strOutFolder&"\"&strFile)
End Function
</script>
</head>
<body>
<input type="button" value="Export" onclick="ExportToCSV" tabindex="9">
<input id="print_button" type="button" value="Print" name="Print_button" class="Hide" onClick="Window.print()">
<input type="button" value="Exit" onclick=self.close name="B3" tabindex="1" class="btn">
"@
Out-File -InputObject $strHTAText -Force -FilePath $htafileout 
}
#==========================================================================
# Function		: CreateSPNHTM
# Arguments     : OU Name, Ou put HTM file
# Returns   	: n/a
# Description   : Initiates a base HTM file with Export(Save As),Print and Exit buttons.
#==========================================================================
function CreateDefSDHTM
{
    Param([string]$SPN,[string]$htmfileout)
$strHTAText =@"
<html>
<head[string]$SPN
<title>Default Security Descritor Report on $SPN</title>
"@
Out-File -InputObject $strHTAText -Force -FilePath $htmfileout 

}
#==========================================================================
# Function		: InitiateSPNHTM
# Arguments     : Output htm file
# Returns   	: n/a
# Description   : Wites base HTM table syntax, it appends info if the file exist
#==========================================================================
Function InitiateDefSDHTM
{
    Param([string] $htmfileout,[string] $strStartingPoint)
$strHTMLText =@"
<h1 style="color: #79A0E0;text-align: center;">Default Security Descriptor REPORT - $($strStartingPoint.ToUpper())</h1>
"@ 
$strHTMLText =$strHTMLText +"<TABLE BORDER=1>" 
$strTHOUColor = "E5CF00"
$strTHColor = "EFAC00"
$strFont =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontOU =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontTH =@"
<FONT size="2" face="verdana, hevetica, arial">
"@


$strHTMLText =@"
$strHTMLText
<th bgcolor="$strTHColor">$strFontTH Object</font></th><th bgcolor="$strTHColor">$strFontTH Version</font></th><th bgcolor="$strTHColor">$strFontTH Modified Date</font><th bgcolor="$strTHColor">$strFontTH SDDL</font></th>
"@



Out-File -InputObject $strHTMLText -Append -FilePath $htmfileout 
}
#==========================================================================
# Function		: CreateServicePrincipalReportHTA
# Arguments     : OU Name, Ou put HTA file
# Returns   	: n/a
# Description   : Initiates a base HTA file with Export(Save As),Print and Exit buttons.
#==========================================================================
function CreateServicePrincipalReportHTA
{
    Param([string]$SPN,[string]$htafileout,[string]$htmfileout,[string] $folder)
$strHTAText =@"
<html>
<head>
<hta:Application ID="hta"
ApplicationName="Report">
<title>Membership Report on $SPN</title>
<script type="text/vbscript">
Sub ExportToCSV()
Dim objFSO,objFile,objNewFile,oShell,oEnv
Set oShell=CreateObject("wscript.shell")
Set oEnv=oShell.Environment("System")
strTemp=oShell.ExpandEnvironmentStrings("%USERPROFILE%")
strTempFile="$htmfileout"
strOutputFolder="$folder"
strFile=SaveAs("$($SPN.Split("\")[-1]).htm",strOutputFolder)
If strFile="" Then Exit Sub
Set objFSO=CreateObject("Scripting.FileSystemObject")
objFSO.CopyFile strTempFile,strFile, true
MsgBox "Finished exporting to " & strFile,vbOKOnly+vbInformation,"Export"
End Sub
Function SaveAs(strFile,strOutFolder)
Dim objDialog
SaveAs=InputBox("Enter the filename and path."&vbCrlf&vbCrlf&"Example: "&strOutFolder&"\CONTOSO-contoso.htm","Export",strOutFolder&"\"&strFile)
End Function
</script>
</head>
<body>
<input type="button" value="Export" onclick="ExportToCSV" tabindex="9">
<input id="print_button" type="button" value="Print" name="Print_button" class="Hide" onClick="Window.print()">
<input type="button" value="Exit" onclick=self.close name="B3" tabindex="1" class="btn">
"@
Out-File -InputObject $strHTAText -Force -FilePath $htafileout 
}
#==========================================================================
# Function		: CreateSPNHTM
# Arguments     : OU Name, Ou put HTM file
# Returns   	: n/a
# Description   : Initiates a base HTM file with Export(Save As),Print and Exit buttons.
#==========================================================================
function CreateSPNHTM
{
    Param([string]$SPN,[string]$htmfileout)
$strHTAText =@"
<html>
<head[string]$SPN
<title>Membership Report on $SPN</title>
"@
Out-File -InputObject $strHTAText -Force -FilePath $htmfileout 

}
#==========================================================================
# Function		: InitiateSPNHTM
# Arguments     : Output htm file
# Returns   	: n/a
# Description   : Wites base HTM table syntax, it appends info if the file exist
#==========================================================================
Function InitiateSPNHTM
{
    Param([string] $htmfileout)
$strHTMLText ="<TABLE BORDER=1>" 
$strTHOUColor = "E5CF00"
$strTHColor = "EFAC00"
$strFont =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontOU =@"
<FONT size="1" face="verdana, hevetica, arial">
"@
$strFontTH =@"
<FONT size="2" face="verdana, hevetica, arial">
"@


$strHTMLText =@"
$strHTMLText
<th bgcolor="$strTHColor">$strFontTH Account Name</font></th><th bgcolor="$strTHColor">$strFontTH Object Type</font></th><th bgcolor="$strTHColor">$strFontTH Number of Groups</font></th>
"@



Out-File -InputObject $strHTMLText -Append -FilePath $htmfileout 
}
#==========================================================================
# Function		: CreateHTM
# Arguments     : OU Name, Ou put HTM file
# Returns   	: n/a
# Description   : Initiates a base HTM file with Export(Save As),Print and Exit buttons.
#==========================================================================
function CreateHTM
{
    Param([string]$NodeName,[string]$htmfileout)
$strHTAText =@"
<html>
<head>
<title>Report on $NodeName</title>
"@

Out-File -InputObject $strHTAText -Force -FilePath $htmfileout 
}


#==========================================================================
# Function		: Select-File
# Arguments     : n/a
# Returns   	: folder path
# Description   : Dialogbox for selecting a file
#==========================================================================
function Select-File
{
    param (
        [System.String]$Title = "Select Template File", 
        [System.String]$InitialDirectory = $CurrentFSPath, 
        [System.String]$Filter = "All Files(*.csv)|*.csv"
    )
    
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = $filter
    $dialog.InitialDirectory = $initialDirectory
    $dialog.ShowHelp = $true
    $dialog.Title = $title
    $result = $dialog.ShowDialog($owner)

    if ($result -eq "OK")
    {
        return $dialog.FileName
    }
    else
    {
        return ""

    }
}
#==========================================================================
# Function		: Select-Folder
# Arguments     : n/a
# Returns   	: folder path
# Description   : Dialogbox for selecting a folder
#==========================================================================
function Select-Folder
{  
    Param($message='Select a folder', $path = 0)
    $object = New-Object -comObject Shell.Application   
      
    $folder = $object.BrowseForFolder(0, $message, 0, $path)  
    if ($null -ne $folder) {  
        $folder.self.Path  
    }  
} 
#==========================================================================
# Function		: Get-Perm
# Arguments     : List of OU Path
# Returns   	: All Permissions on a speficied object
# Description   : Enumerates all access control entries on a speficied object
#==========================================================================
Function Get-Perm
{
    Param([System.Collections.ArrayList]$ALOUdn,[string]$DomainNetbiosName,[boolean]$SkipDefaultPerm,[boolean]$SkipProtectedPerm,[boolean]$FilterEna,[boolean]$bolGetOwnerEna,[boolean]$bolCSVOnly,[boolean]$bolReplMeta, [boolean]$bolACLsize,[boolean]$bolEffectiveR,[boolean] $bolGetOUProtected,[boolean] $bolGUIDtoText)
$SDResult = $false
$bolCompare = $false
$bolACLExist = $true
$global:strOwner = ""
$strACLSize = ""
$bolOUProtected = $false
$aclcount = 0
$sdOUProtect = ""

If ($bolCSV)
{
	If ((Test-Path $strFileCSV) -eq $true)
	{
	Remove-Item $strFileCSV
	}
}

$count = 0
$i = 0
$intCSV = 0
if (($PSVersionTable.PSVersion -ne "2.0") -and ($global:bolProgressBar))
{
    $intTot = 0
    #calculate percentage
    $intTot = $ALOUdn.count
    if ($intTot -gt 0)
    {
    LoadProgressBar
   
    }
}

while($count -le $ALOUdn.count -1)
{
$global:secd = ""
$bolACLExist = $true
$global:GetSecErr = $false

if (($PSVersionTable.PSVersion -ne "2.0") -and ($global:bolProgressBar))
{
    $i++
    [int]$pct = ($i/$intTot)*100
    #Update the progress bar
    
    while(($null -eq $global:ProgressBarWindow.Window.IsInitialized) -and ($intLoop -lt 20))
    {
                Start-Sleep -Milliseconds 1
                $cc++
    }
    if ($global:ProgressBarWindow.Window.IsInitialized -eq $true)
    {
        Update-ProgressBar "Currently scanning $i of $intTot objects" $pct 
    }    
    
}


    $sd =  New-Object System.Collections.ArrayList
    $GetOwnerEna = $bolGetOwnerEna
    $ADObjDN = $($ALOUdn[$count])

    if ($ADObjDN -match "####")
    {
        if ($rdbOneLevel.IsChecked -eq $false)
        {
 
            if ($ADObjDN -match "/")
            {
                $ADObjDN = $ADObjDN.Replace("/", "\/")
            }
            else
            {
                $ADObjDN = $ADObjDN.Replace("/", "\\\/")
            }
         }
         else
         {
          if($count -lt $ALOUdn.count -1)
          {

            if ($ADObjDN -match "/")
            {
 
                $ADObjDN = $ADObjDN.Replace("/", "\/")
            }
            else
            {
                $ADObjDN = $ADObjDN.Replace("/", "\\\/")
            }
          }
         }
     }
      
        
        $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
        $LDAPConnection.SessionOptions.ReferralChasing = "None"
        $request = New-Object System.directoryServices.Protocols.SearchRequest("$ADObjDN", "(name=*)", "base")
        if($global:bolShowDeleted)
        {
            [string] $LDAP_SERVER_SHOW_DELETED_OID = "1.2.840.113556.1.4.417"
            [void]$request.Controls.Add((New-Object "System.DirectoryServices.Protocols.DirectoryControl" -ArgumentList "$LDAP_SERVER_SHOW_DELETED_OID",$null,$false,$true ))
        }
        [void]$request.Attributes.Add("objectclass")
        [void]$request.Attributes.Add("ntsecuritydescriptor")
        [void]$request.Attributes.Add("distinguishedname")
  
    
        if ($rdbDACL.IsChecked)
        {
            $SecurityMasks = [System.DirectoryServices.Protocols.SecurityMasks]'Owner' -bor [System.DirectoryServices.Protocols.SecurityMasks]'Group'-bor [System.DirectoryServices.Protocols.SecurityMasks]'Dacl' #-bor [System.DirectoryServices.Protocols.SecurityMasks]'Sacl'
            $control = New-Object System.DirectoryServices.Protocols.SecurityDescriptorFlagControl($SecurityMasks)
            [void]$request.Controls.Add($control)
            $response = $LDAPConnection.SendRequest($request)
            $DSobject = $response.Entries[0]
            #Check if any NTsecuritydescr
            if($null -ne $DSobject.Attributes.ntsecuritydescriptor)
            {
                $strObjectClass = $DSobject.Attributes.objectclass[$DSobject.Attributes.objectclass.count-1]
                $sec = New-Object System.DirectoryServices.ActiveDirectorySecurity
                $sec.SetSecurityDescriptorBinaryForm($DSobject.Attributes.ntsecuritydescriptor[0])

                &{#Try
                    $global:secd = $sec.GetAccessRules($true, $chkInheritedPerm.IsChecked, [System.Security.Principal.NTAccount])

                }
                Trap [SystemException]
                { 
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed to translate identity:$ADObjDN" -strType "Warning" -DateStamp ))
                    &{#Try
                        $global:secd = $sec.GetAccessRules($true, $chkInheritedPerm.IsChecked, [System.Security.Principal.SecurityIdentifier])
                    }
                    Trap [SystemException]
                    { 

                        Continue
                        $global:GetSecErr = $true

                    }
                    Continue
                }
            }
            else
            {
                #Fail futher scan when NTsecurityDescriptor is null
                $global:GetSecErr = $true
            }
        }
        else
        {
            $SecurityMasks = [System.DirectoryServices.Protocols.SecurityMasks]'Owner' -bor [System.DirectoryServices.Protocols.SecurityMasks]'Group'-bor [System.DirectoryServices.Protocols.SecurityMasks]'Dacl' -bor [System.DirectoryServices.Protocols.SecurityMasks]'Sacl'
            $control = New-Object System.DirectoryServices.Protocols.SecurityDescriptorFlagControl($SecurityMasks)
            [void]$request.Controls.Add($control)
            $response = $LDAPConnection.SendRequest($request)
            $DSobject = $response.Entries[0]
            $strObjectClass = $DSobject.Attributes.objectclass[$DSobject.Attributes.objectclass.count-1]
            $sec = New-Object System.DirectoryServices.ActiveDirectorySecurity
            $sec.SetSecurityDescriptorBinaryForm($DSobject.Attributes.ntsecuritydescriptor[0])
            &{#Try
                #$DSobject.psbase.Options.SecurityMasks = [System.DirectoryServices.SecurityMasks]'Owner' -bor [System.DirectoryServices.SecurityMasks]'Group'-bor [System.DirectoryServices.SecurityMasks]'Dacl' -bor [System.DirectoryServices.SecurityMasks]'Sacl'
                $global:secd = $sec.GetAuditRules($true, $chkInheritedPerm.IsChecked, [System.Security.Principal.NTAccount])
            }
            Trap [SystemException]
            { 
                $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed to translate identity:$ADObjDN" -strType "Warning" -DateStamp ))
                &{#Try
                    $global:secd = $sec.GetAuditRules($true, $chkInheritedPerm.IsChecked, [System.Security.Principal.SecurityIdentifier])
                }
                Trap [SystemException]
                { 

                    Continue
                    $global:GetSecErr = $true

                }
                Continue
            }
        }

    if(($global:GetSecErr -ne $true) -or ($global:secd -ne ""))
    {
        $sd.clear()
        if($null -ne $global:secd){
            $(ConvertTo-ObjectArrayListFromPsCustomObject  $global:secd)| ForEach-Object{[void]$sd.add($_)}
        }
        If ($GetOwnerEna -eq $true)
        {
    
            &{#Try
                $global:strOwner = $sec.GetOwner([System.Security.Principal.NTAccount]).value
            }
   
            Trap [SystemException]
            { 
                if($global:bolADDSType)
                {
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed to translate owner identity:$ADObjDN" -strType "Warning" -DateStamp ))
                }
                $global:strOwner = $sec.GetOwner([System.Security.Principal.SecurityIdentifier]).value
                Continue
            }

            $newSdOwnerObject = New-Object PSObject -Property @{ActiveDirectoryRights="Read permissions, Modify permissions";InheritanceType="None";ObjectType ="None";`
            InheritedObjectType="None";ObjectFlags="None";AccessControlType="Owner";IdentityReference=$global:strOwner;IsInherited="False";`
            InheritanceFlags="None";PropagationFlags="None"}

            [void]$sd.insert(0,$newSdOwnerObject)
 
        }
 	    If ($SkipDefaultPerm)
	    {
            If ($GetOwnerEna -eq $false)
                {
    
                &{#Try
                    $global:strOwner = $sec.GetOwner([System.Security.Principal.NTAccount]).value
                }
   
                Trap [SystemException]
                { 
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed to translate owner identity:$ADObjDN" -strType "Error" -DateStamp ))
                    $global:strOwner = $sec.GetOwner([System.Security.Principal.SecurityIdentifier]).value
                    Continue
                }
            } 
            #$objNodeDefSD = Get-ADSchemaClass $strObjectClass
        }

        if ($bolACLsize -eq $true) 
        {
            $strACLSize = $sec.GetSecurityDescriptorBinaryForm().length
        }
        if ($bolGetOUProtected -eq $true)
        {
            $bolOUProtected = $sec.AreAccessRulesProtected
        }
        if ($bolReplMeta -eq $true)
        {
    
            $AclChange = $(GetACLMeta  $global:strDC $ADObjDN)
            $objLastChange = $AclChange.split(";")[0]
            $strOrigInvocationID = $AclChange.split(";")[1]
            $strOrigUSN = $AclChange.split(";")[2]
        }
    

        If (($FilterEna -eq $true) -and ($bolEffectiveR -eq $false))
        {
            If ($chkBoxType.IsChecked)
            {
                if ($combAccessCtrl.SelectedIndex -gt -1)
                {
                $sd = @($sd | Where-Object{$_.AccessControlType -eq $combAccessCtrl.SelectedItem})
                }
            }    
            If ($chkBoxObject.IsChecked)
            {
                if ($combObjectFilter.SelectedIndex -gt -1)
                {

                    $sd = @($sd | Where-Object{($_.ObjectType -eq $global:dicNameToSchemaIDGUIDs.Item($combObjectFilter.SelectedItem)) -or ($_.InheritedObjectType -eq $global:dicNameToSchemaIDGUIDs.Item($combObjectFilter.SelectedItem))})
                }
            }
            If ($chkBoxTrustee.IsChecked)
            {
                if ($txtFilterTrustee.Text.Length -gt 0)
                {
                    $sd = @($sd | Where-Object{if($_.IdentityReference -like "S-1-*"){`
                    $(ConvertSidToName -server $global:strDomainLongName -Sid $_.IdentityReference) -like $txtFilterTrustee.Text}`
                    else{$_.IdentityReference -like $txtFilterTrustee.Text}})

                }
            }

        }


        if ($bolEffectiveR -eq $true)
        {

                if ($global:tokens.count -gt 0)
                {

                    $sdtemp2 =  New-Object System.Collections.ArrayList
            
                    if ($global:strPrincipalDN -eq $ADObjDN)
                    {
                            $sdtemp = ""
                            $sdtemp = $sd | Where-Object{$_.IdentityReference -eq "NT AUTHORITY\SELF"}
                            if($sdtemp)
                            {
                                $sdtemp2.Add( $sdtemp)
                            }
                    }
                    foreach ($tok in $global:tokens) 
	                {
 
                            $sdtemp = ""
                            $sdtemp = $sd | Where-Object{$_.IdentityReference -eq $tok}
                            if($sdtemp)
                            {
                                $sdtemp2.Add( $sdtemp)
                            }
                  
             
                    }
                     $sd = $sdtemp2
                }

        }
        $intSDCount =  $sd.count
  
        if (!($null -eq $sd))
        {



		    $index=0
		    $permcount = 0

        if ($intSDCount -gt 0)
        {        
    
		    while($index -le $sd.count -1) 
		    {
                    $bolMatchDef = $false
                    $bolMatchprotected = $false
                    $strNTAccount = $sd[$index].IdentityReference.ToString()
	                If ($strNTAccount.contains("S-1-"))
	                {
	                    $strNTAccount = ConvertSidToName -server $global:strDomainLongName -Sid $strNTAccount
	                }  
                    #Remove Default Permissions if SkipDefaultPerm selected
                    if($SkipDefaultPerm)
                    {
                        if($strObjectClass  -ne $strTemoObjectClass)
                        {
                            $sdOUDef = Get-PermDef $strObjectClass $strNTAccount
                        }
                        $strTemoObjectClass = $strObjectClass
                        $indexDef=0
                        while($indexDef -le $sdOUDef.count -1)
                        {
			                if (($sdOUDef[$indexDef].IdentityReference -eq $strNTAccount) -and ($sdOUDef[$indexDef].ActiveDirectoryRights -eq $sd[$index].ActiveDirectoryRights) -and ($sdOUDef[$indexDef].AccessControlType -eq $sd[$index].AccessControlType) -and ($sdOUDef[$indexDef].ObjectType -eq $sd[$index].ObjectType) -and ($sdOUDef[$indexDef].InheritanceType -eq $sd[$index].InheritanceType) -and ($sdOUDef[$indexDef].InheritedObjectType -eq $sd[$index].InheritedObjectType))
			                {
			                    $bolMatchDef = $true
			                } #End If
                            $indexDef++
                        } #End While
                    }

                    if($bolMatchDef)
				    {
				    }
				    else
				    {
                        #Remove Protect Against Accidental Deletaions Permissions if SkipProtectedPerm selected
                        if($SkipProtectedPerm)
                        {
                            if($sdOUProtect -eq "")
                            {
                                $sdOUProtect = Get-ProtectedPerm
                            }
                            $indexProtected=0
                            while($indexProtected -le $sdOUProtect.count -1)
                            {
			                    if (($sdOUProtect[$indexProtected].IdentityReference -eq $strNTAccount) -and ($sdOUProtect[$indexProtected].ActiveDirectoryRights -eq $sd[$index].ActiveDirectoryRights) -and ($sdOUProtect[$indexProtected].AccessControlType -eq $sd[$index].AccessControlType) -and ($sdOUProtect[$indexProtected].ObjectType -eq $sd[$index].ObjectType) -and ($sdOUProtect[$indexProtected].InheritanceType -eq $sd[$index].InheritanceType) -and ($sdOUProtect[$indexProtected].InheritedObjectType -eq $sd[$index].InheritedObjectType))
			                    {
			                        $bolMatchprotected = $true
			                    }#End If
                                $indexProtected++
                            } #End While
                        }

                        if($bolMatchprotected)
				        {
				        }
				        else
				        {
					        If ($bolCSV -or $bolCSVOnly)
					        {
                                if($intCSV -eq 0)
                                {

                                $strCSVHeader | Out-File -FilePath $strFileCSV
                                }
                                $intCSV++
				 		        WritePermCSV $sd[$index] $DSobject.Attributes.distinguishedname[0].toString() $strObjectClass $strFileCSV $bolReplMeta $objLastChange $strOrigInvocationID $strOrigUSN

				 	        }# End If
                            If (!($bolCSVOnly))
                            {
					            If ($strColorTemp -eq "1")
					            {
						            $strColorTemp = "2"
					            }# End If
					            else
					            {
						            $strColorTemp = "1"
					            }# End If				 	
				 	            if ($permcount -eq 0)
				 	            {
                                    $bolOUHeader = $true    
				 		            WriteHTM $bolACLExist $sd[$index] $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader $strColorTemp $strFileHTA $bolCompare $FilterEna $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked

				 	            }
				 	            else
				 	            {
                                     $bolOUHeader = $false 
				 		            WriteHTM $bolACLExist $sd[$index] $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader $strColorTemp $strFileHTA $bolCompare $FilterEna $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked

				 	            }# End If
                            }
                            $aclcount++
					        $permcount++
				        }# End If SkipProtectedPerm
                    }# End If SkipDefaultPerm
				    $index++
		    }# End while

        }
        else
        {

            If (!($bolCSVOnly))
            {            
			    If ($strColorTemp -eq "1")
			    {
			    $strColorTemp = "2"
			    }
			    else
			    {
			    $strColorTemp = "1"
			    }		
		 	    if ($permcount -eq 0)
		 	    {
                    $bolOUHeader = $true 
		 		    WriteHTM $bolACLExist $sd $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader $strColorTemp $strFileHTA $bolCompare $FilterEna $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked

                   
		 	    }
		 	    else
		 	    {
                    $bolOUHeader = $false 
                    $GetOwnerEna = $false
                    WriteHTM $bolACLExist $sd $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader $strColorTemp $strFileHTA $bolCompare $FilterEna $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked
                    #$aclcount++
		 	    }
            }

            $permcount++
 
        }#End if array        
    
        If (!($bolCSVOnly))
        {
        $bolACLExist = $false
            if (($permcount -eq 0) -and ($index -gt 0))
            {
                $bolOUHeader = $true 
	            WriteHTM $bolACLExist $sd $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader "1" $strFileHTA $bolCompare $FilterEna $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked 
                $aclcount++
            }# End If
            }
            else #if isNull
            {
                $bolOUHeader = $true 
                WriteHTM $bolACLExist $sd $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader "1" $strFileHTA $bolCompare $FilterEna $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked

            }# End if isNull
        }
    }#End $global:GetSecErr
	$count++
}# End while
    

    if (($count -gt 0))
    {
if ($aclcount -eq 0)
{
    $global:observableCollection.Insert(0,(LogMessage -strMessage "No Permissions found!" -strType "Error" -DateStamp ))
    if (($PSVersionTable.PSVersion -ne "2.0") -and ($global:bolProgressBar))
    {
        $global:ProgressBarWindow.Window.Dispatcher.invoke([action]{$global:ProgressBarWindow.Window.Close()},"Normal")
        $ProgressBarWindow = $null
        Remove-Variable -Name "ProgressBarWindow" -Scope Global
    } 

}  
else
{
if($chkBoxEffectiveRightsColor.IsChecked)
{
    Switch ($global:intShowCriticalityLevel)
    {
        0
        {
        (Get-Content $strFileHTA) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "grey">INFO' | Set-Content $strFileHTA
        (Get-Content $strFileHTM) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "grey">INFO' | Set-Content $strFileHTM
        }
        1
        {
        (Get-Content $strFileHTA) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "blue">LOW' | Set-Content $strFileHTA
        (Get-Content $strFileHTM) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "blue">LOW' | Set-Content $strFileHTM
        }
        2
        {
        (Get-Content $strFileHTA) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "yellow">MEDIUM' | Set-Content $strFileHTA
        (Get-Content $strFileHTM) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "yellow">MEDIUM' | Set-Content $strFileHTM
        }
        3
        {
        (Get-Content $strFileHTA) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "orange">WARNING' | Set-Content $strFileHTA
        (Get-Content $strFileHTM) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "orange">WARNING' | Set-Content $strFileHTM
        }
        4
        {
        (Get-Content $strFileHTA) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "red">CRITICAL' | Set-Content $strFileHTA
        (Get-Content $strFileHTM) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "red">CRITICAL' | Set-Content $strFileHTM
        }
    }
}
if (($PSVersionTable.PSVersion -ne "2.0") -and ($global:bolProgressBar))
{
        
        $global:ProgressBarWindow.Window.Dispatcher.invoke([action]{$global:ProgressBarWindow.Window.Close()},"Normal")
        #Remove-Variable -Name "ProgressBarWindow" -Scope Global
} 
        If ($bolCSV -or $bolCSVOnly)
        {

           $global:observableCollection.Insert(0,(LogMessage -strMessage "Report saved in $strFileCSV" -strType "Warning" -DateStamp ))
        }
        else
        {
	        Invoke-Item $strFileHTA
        }

    }# End If
}
else
{
    $global:observableCollection.Insert(0,(LogMessage -strMessage "No objects found!" -strType "Error" -DateStamp ))
}
$i = $null
Remove-Variable -Name "i"
$secd = $null


return $SDResult

}

#==========================================================================
# Function		: Get-PermCompare
# Arguments     : OU Path 
# Returns   	: N/A
# Description   : Compare Permissions on node with permissions in CSV file
#==========================================================================
Function Get-PermCompare
{
    Param([System.Collections.ArrayList]$ALOUdn,[boolean]$SkipDefaultPerm,[boolean]$SkipProtectedPerm,[boolean]$bolReplMeta,[boolean]$bolGetOwnerEna,[boolean]$bolGetOUProtected,[boolean]$bolACLsize,[boolean] $bolGUIDtoText)
$Error
&{#Try
$arrOUList = New-Object System.Collections.ArrayList
$bolCompare = $true
$bolCompareDelegation = $false
$bolFilter = $false
$bolOUPRotected = $false
$strACLSize = ""
$bolAClMeta = $false
$strOwner = ""
$count = 0
$aclcount = 0
$SDUsnCheck = $false
$ExitCompare = $false
$sdOUProtect = ""
if ($chkBoxTemplateNodes.IsChecked -eq $true)
{

    $index = 0
    #Enumerate all Nodes in CSV
    while($index -le $global:csvHistACLs.count -1) 
    {
        $arrOUList.Add($global:csvHistACLs[$index].OU)
        $index++
    }
    $arrOUListUnique = $arrOUList | Select-Object -Unique


    #Replace any existing strings matching <DOMAIN-DN>
    $arrOUListUnique = $arrOUListUnique -replace "<DOMAIN-DN>",$global:strDomainDNName
    
    #Replace any existing strings matching <ROOT-DN>
    $arrOUListUnique = $arrOUListUnique -replace "<ROOT-DN>",$global:ForestRootDomainDN
    #If the user entered any text replace matching string from CSV

    if($txtReplaceDN.text.Length -gt 0)
    {

        $arrOUListUnique = $arrOUListUnique -replace $txtReplaceDN.text,$global:strDomainDNName

    }
    $ALOUdn = @($arrOUListUnique)
}

If ($bolReplMeta -eq $true)
{
        If ($global:csvHistACLs[0].SDDate.length -gt 1)
        {
        $bolAClMeta = $true
        }
        $arrUSNCheckList = $global:csvHistACLs | Select-Object -Property OU,OrgUSN -Unique
}
#Verify that USN exist in file and that Meta data will be retreived
if($chkBoxScanUsingUSN.IsChecked -eq $true)
{
    if($bolAClMeta -eq $true)
    {
        $SDUsnCheck = $true
    }
    else
    {
        If ($bolReplMeta -eq $true)
        {
            $MsgBox = [System.Windows.Forms.MessageBox]::Show("Could not compare using USN.`nDid not find USNs in template.`nDo you want to continue?",”Information”,3,"Warning")
            Switch ($MsgBOx)
            {
                "YES"
                {$ExitCompare = $false}
                "NO"
                {$ExitCompare = $true}
                Default
                {$ExitCompare = $true}
            }
        }
        else
        {
            $MsgBox = [System.Windows.Forms.MessageBox]::Show("Could not compare using USN.`nMake sure scan option SD Modified is selected.`nDo you want to continue?",”Information”,3,"Warning")
            Switch ($MsgBOx)
            {
                "YES"
                {$ExitCompare = $false}
                "NO"
                {$ExitCompare = $true}
                Default
                {$ExitCompare = $true}
            }
        }
    }
}
if(!($ExitCompare))
{
$i = 0
if (($PSVersionTable.PSVersion -ne "2.0") -and ($global:bolProgressBar))
{
    $intTot = 0
    #calculate percentage
    $intTot = $ALOUdn.count
    if ($intTot -gt 0)
    {
    LoadProgressBar
    
    }
}

while($count -le $ALOUdn.count -1)
{
    $global:GetSecErr = $false
    $global:secd = ""
    if (($PSVersionTable.PSVersion -ne "2.0") -and ($global:bolProgressBar))
    {
        $i++
        [int]$pct = ($i/$intTot)*100
        #Update the progress bar
        while(($null -eq $global:ProgressBarWindow.Window.IsInitialized) -and ($intLoop -lt 20))
        {
                    Start-Sleep -Milliseconds 1
                    $cc++
        }
        if ($global:ProgressBarWindow.Window.IsInitialized -eq $true)
        {
            Update-ProgressBar "Currently scanning $i of $intTot objects" $pct 
        }  
        
    }


    $OUMatchResultOverall = $false
    $bolAddedACL = $false
    $bolMissingACL = $false

    $sd =  New-Object System.Collections.ArrayList
    $GetOwnerEna = $bolGetOwnerEna
    $ADObjDN = $($ALOUdn[$count])
    $OUdnorgDN = $ADObjDN 
    if ($ADObjDN -match "/")
    {
        if ($rdbOneLevel.IsChecked -eq $false)
        {
 
            if ($ADObjDN -match "/")
            {
                $ADObjDN = $ADObjDN.Replace("/", "\/")
            }
            else
            {
                $ADObjDN = $ADObjDN.Replace("/", "\\\/")
            }
         }
         else
         {
          if($count -lt $ALOUdn.count -1)
          {

            if ($ADObjDN -match "/")
            {
 
                $ADObjDN = $ADObjDN.Replace("/", "\/")
            }
            else
            {
                $ADObjDN = $ADObjDN.Replace("/", "\\\/")
            }
          }
         }
     }

    #Counter used for fitlerout Nodes with only defaultpermissions configured
    $intAclOccurence = 0

    $LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
    $LDAPConnection.SessionOptions.ReferralChasing = "None"
    $request = New-Object System.directoryServices.Protocols.SearchRequest("$ADObjDN", "(name=*)", "base")
    if($global:bolShowDeleted)
    {
        [string] $LDAP_SERVER_SHOW_DELETED_OID = "1.2.840.113556.1.4.417"
        [void]$request.Controls.Add((New-Object "System.DirectoryServices.Protocols.DirectoryControl" -ArgumentList "$LDAP_SERVER_SHOW_DELETED_OID",$null,$false,$true ))
    }
    [void]$request.Attributes.Add("objectclass")
    [void]$request.Attributes.Add("ntsecuritydescriptor")
    [void]$request.Attributes.Add("distinguishedname")
    $response = $null
     $DSobject = $null
    ##
    if ($rdbDACL.IsChecked)
    {
        $SecurityMasks = [System.DirectoryServices.Protocols.SecurityMasks]'Owner' -bor [System.DirectoryServices.Protocols.SecurityMasks]'Group'-bor [System.DirectoryServices.Protocols.SecurityMasks]'Dacl' #-bor [System.DirectoryServices.Protocols.SecurityMasks]'Sacl'
        $control = New-Object System.DirectoryServices.Protocols.SecurityDescriptorFlagControl($SecurityMasks)
        [void]$request.Controls.Add($control)
        $response = $LDAPConnection.SendRequest($request)
        $DSobject = $response.Entries[0]
        #Check if any NTsecuritydescr
        if($null -ne $DSobject.Attributes.ntsecuritydescriptor)
        {
            $strObjectClass = $DSobject.Attributes.objectclass[$DSobject.Attributes.objectclass.count-1]
            $sec = New-Object System.DirectoryServices.ActiveDirectorySecurity
            $sec.SetSecurityDescriptorBinaryForm($DSobject.Attributes.ntsecuritydescriptor[0])
            &{#Try
                $global:secd = $sec.GetAccessRules($true, $chkInheritedPerm.IsChecked, [System.Security.Principal.NTAccount])

            }
            Trap [SystemException]
            { 
                $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed to translate identity:$ADObjDN" -strType "Warning" -DateStamp ))
                &{#Try
                    $global:secd = $sec.GetAccessRules($true, $chkInheritedPerm.IsChecked, [System.Security.Principal.SecurityIdentifier])
                }
                Trap [SystemException]
                { 

                    Continue
                    $global:GetSecErr = $true

                }
                Continue
            }
        }
        else
        {
            #Fail futher scan when NTsecurityDescriptor is null
            $global:GetSecErr = $true
        }
     
    }
    else
    {
        $SecurityMasks = [System.DirectoryServices.Protocols.SecurityMasks]'Owner' -bor [System.DirectoryServices.Protocols.SecurityMasks]'Group'-bor [System.DirectoryServices.Protocols.SecurityMasks]'Dacl' -bor [System.DirectoryServices.Protocols.SecurityMasks]'Sacl'
        $control = New-Object System.DirectoryServices.Protocols.SecurityDescriptorFlagControl($SecurityMasks)
        [void]$request.Controls.Add($control)
        $response = $LDAPConnection.SendRequest($request)
        $DSobject = $response.Entries[0]
        $strObjectClass = $DSobject.Attributes.objectclass[$DSobject.Attributes.objectclass.count-1]
        $sec = New-Object System.DirectoryServices.ActiveDirectorySecurity
        $sec.SetSecurityDescriptorBinaryForm($DSobject.Attributes.ntsecuritydescriptor[0])
        &{#Try
            #$DSobject.psbase.Options.SecurityMasks = [System.DirectoryServices.SecurityMasks]'Owner' -bor [System.DirectoryServices.SecurityMasks]'Group'-bor [System.DirectoryServices.SecurityMasks]'Dacl' -bor [System.DirectoryServices.SecurityMasks]'Sacl'
            $global:secd = $sec.GetAuditRules($true, $chkInheritedPerm.IsChecked, [System.Security.Principal.NTAccount])
        }
        Trap [SystemException]
        { 
            $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed to translate identity:$ADObjDN" -strType "Warning" -DateStamp ))
            &{#Try
                $global:secd = $sec.GetAuditRules($true, $chkInheritedPerm.IsChecked, [System.Security.Principal.SecurityIdentifier])
            }
            Trap [SystemException]
            { 

                Continue
                $global:GetSecErr = $true

            }
            Continue
        }
    }
    if($DSobject.attributes.count -gt 0)
    {
    if(($global:GetSecErr -ne $true) -or ($global:secd -ne ""))
    {
        $sd.clear()
        if($null -ne $global:secd){
            $(ConvertTo-ObjectArrayListFromPsCustomObject  $global:secd)| ForEach-Object{[void]$sd.add($_)}
        }
        If ($GetOwnerEna -eq $true)
        {
    
            &{#Try
                $global:strOwner = $sec.GetOwner([System.Security.Principal.NTAccount]).value
            }
   
            Trap [SystemException]
            { 
                if($global:bolADDSType)
                {
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed to translate owner identity:$ADObjDN" -strType "Warning" -DateStamp ))
                }
                $global:strOwner = $sec.GetOwner([System.Security.Principal.SecurityIdentifier]).value
                Continue
            }


            $newSdOwnerObject = New-Object PSObject -Property @{ActiveDirectoryRights="Read permissions, Modify permissions";InheritanceType="None";ObjectType ="None";`
            InheritedObjectType="None";ObjectFlags="None";AccessControlType="Owner";IdentityReference=$global:strOwner;IsInherited="False";`
            InheritanceFlags="None";PropagationFlags="None"}

            [void]$sd.insert(0,$newSdOwnerObject)
 
        }
 	    If ($SkipDefaultPerm)
	    {
            If ($GetOwnerEna -eq $false)
                {
    
                &{#Try
                    $global:strOwner = $sec.GetOwner([System.Security.Principal.NTAccount]).value
                }
   
                Trap [SystemException]
                { 
                    $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed to translate owner identity:$ADObjDN" -strType "Error" -DateStamp ))
                    $global:strOwner = $sec.GetOwner([System.Security.Principal.SecurityIdentifier]).value
                    Continue
                }
            } 
            #$objNodeDefSD = Get-ADSchemaClass $strObjectClass
        }

        if ($bolACLsize -eq $true) 
        {
            $strACLSize = $sec.GetSecurityDescriptorBinaryForm().length
        }
        if ($bolGetOUProtected -eq $true)
        {
            $bolOUProtected = $sec.AreAccessRulesProtected
        }
        if ($bolReplMeta -eq $true)
        {
    
            $AclChange = $(GetACLMeta  $global:strDC $ADObjDN)
            $objLastChange = $AclChange.split(";")[0]
            $strOrigInvocationID = $AclChange.split(";")[1]
            $strOrigUSN = $AclChange.split(";")[2]
        }

  
    
        $rar = @($($sd | select-Object -Property *))


        $index = 0
        $SDResult = $false
        $OUMatchResult = $false
            

        $SDUsnNew = $true
        if ($SDUsnCheck -eq $true)
        {

               	       

                    while($index -le $arrUSNCheckList.count -1) 
                    {
                        $SDHistResult = $false

                        $strOUcol = $arrUSNCheckList[$index].OU
                        if($strOUcol.Contains("<DOMAIN-DN>") -gt 0)
                        {
		                    $strOUcol = ($strOUcol -Replace "<DOMAIN-DN>",$global:strDomainDNName)

                        }
                        if($strOUcol.Contains("<ROOT-DN>") -gt 0)
                        {
		                    $strOUcol = ($strOUcol -Replace "<ROOT-DN>",$global:ForestRootDomainDN)

                        }
                        if($txtReplaceDN.text.Length -gt 0)
                        {
		                    $strOUcol = ($strOUcol -Replace $txtReplaceDN.text,$global:strDomainDNName)

                        }     
			            if ($OUdnorgDN -eq $strOUcol )
			            {
                            $OUMatchResult = $true
                            $SDResult = $true

                            if($strOrigUSN -eq $arrUSNCheckList[$index].OrgUSN)
                            {
                                $aclcount++
                                foreach($sdObject in $rar)
            	                {

                
                                    if($null  -ne $sdObject.AccessControlType)
                                    {
                                        $ACEType = $sdObject.AccessControlType
                                    }
                                    else
                                    {
                                        $ACEType = $sdObject.AuditFlags
                                    }
                                    $strNTAccount = $sdObject.IdentityReference
	                                If ($strNTAccount.contains("S-1-"))
	                                {
	                                    $strNTAccount = ConvertSidToName -server $global:strDomainLongName -Sid $strNTAccount

	                                }
                                    $newSdObject = New-Object PSObject -Property @{ActiveDirectoryRights=$sdObject.ActiveDirectoryRights;InheritanceType=$sdObject.InheritanceType;ObjectType=$sdObject.ObjectType;`
                                    InheritedObjectType=$sdObject.InheritedObjectType;ObjectFlags=$sdObject.ObjectFlags;AccessControlType=$ACEType;IdentityReference=$strNTAccount;IsInherited=$sdObject.IsInherited;`
                                    InheritanceFlags=$sdObject.InheritanceFlags;PropagationFlags=$sdObject.PropagationFlags;Color="Match"}

                                    $OUMatchResultOverall = $true
                                    if ($intAclOccurence -eq 0)
                                    {
                                        $intAclOccurence++
                                        $bolOUHeader = $true 
                                        WriteHTM $false $sd $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader $strColorTemp $strFileHTA $bolCompare $bolFilter $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked
                        
                                    }
                                    $bolOUHeader = $false 
                                    WriteHTM $true $newSdObject $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader "4" $strFileHTA $bolCompare $bolFilter $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked
                                }
                                $SDUsnNew = $false
                                break
                            }
                            else
                            {
                                $aclcount++

                                $SDUsnNew = $true
                                break
                            }

                        }
                        $index++
                    }
                
               
        } 

        If (($SDUsnCheck -eq $false) -or ($SDUsnNew -eq $true))
        { 
	        foreach($sdObject in $rar)
	        {
                $bolMatchDef = $false
                $bolMatchprotected = $false
                $strNTAccount = $sdObject.IdentityReference.toString()
	            If ($strNTAccount.contains("S-1-"))
	            {
	                $strNTAccount = ConvertSidToName -server $global:strDomainLongName -Sid $strNTAccount

	            }
                #Remove Default Permissions if SkipDefaultPerm selected
                if($SkipDefaultPerm)
                {
                    if($strObjectClass  -ne $strTemoObjectClass)
                    {
                        $sdOUDef = Get-PermDef $strObjectClass $strNTAccount
                    }
                    $strTemoObjectClass = $strObjectClass
                    $indexDef=0
                    while($indexDef -le $sdOUDef.count -1) {
			                    if (($sdOUDef[$indexDef].IdentityReference -eq $strNTAccount) -and ($sdOUDef[$indexDef].ActiveDirectoryRights -eq $sdObject.ActiveDirectoryRights) -and ($sdOUDef[$indexDef].AccessControlType -eq $sdObject.AccessControlType) -and ($sdOUDef[$indexDef].ObjectType -eq $sdObject.ObjectType) -and ($sdOUDef[$indexDef].InheritanceType -eq $sdObject.InheritanceType) -and ($sdOUDef[$indexDef].InheritedObjectType -eq $sdObject.InheritedObjectType))
			                    {
			                        $bolMatchDef = $true
			                    }#} #End If
                        $indexDef++
                    } #End While
                }

                if($bolMatchDef)
				{
				}
                else
                {
                    #Remove Protect Against Accidental Deletaions Permissions if SkipProtectedPerm selected
                    if($SkipProtectedPerm)
                    {
                        if($sdOUProtect -eq "")
                        {
                            $sdOUProtect = Get-ProtectedPerm
                        }
                        $indexProtected=0
                        while($indexProtected -le $sdOUProtect.count -1)
                        {
			                if (($sdOUProtect[$indexProtected].IdentityReference -eq $strNTAccount) -and ($sdOUProtect[$indexProtected].ActiveDirectoryRights -eq $sdObject.ActiveDirectoryRights) -and ($sdOUProtect[$indexProtected].AccessControlType -eq $sdObject.AccessControlType) -and ($sdOUProtect[$indexProtected].ObjectType -eq $sdObject.ObjectType) -and ($sdOUProtect[$indexProtected].InheritanceType -eq $sdObject.InheritanceType) -and ($sdOUProtect[$indexProtected].InheritedObjectType -eq $sdObject.InheritedObjectType))
			                {
			                    $bolMatchprotected = $true
			                }#End If
                            $indexProtected++
                        } #End While
                    }

                    if($bolMatchprotected)
				    {
				    }
				    else
				    {

		                $index = 0
		                $SDResult = $false
                        $OUMatchResult = $false
                        $aclcount++
                        if($null  -ne $sdObject.AccessControlType)
                        {
                            $ACEType = $sdObject.AccessControlType
                        }
                        else
                        {
                            $ACEType = $sdObject.AuditFlags
                        }

                        $newSdObject = New-Object PSObject -Property @{ActiveDirectoryRights=$sdObject.ActiveDirectoryRights;InheritanceType=$sdObject.InheritanceType;ObjectType=$sdObject.ObjectType;`
                        InheritedObjectType=$sdObject.InheritedObjectType;ObjectFlags=$sdObject.ObjectFlags;AccessControlType=$ACEType;IdentityReference=$strNTAccount;IsInherited=$sdObject.IsInherited;`
                        InheritanceFlags=$sdObject.InheritanceFlags;PropagationFlags=$sdObject.PropagationFlags;Color="Match"}

		                while($index -le $global:csvHistACLs.count -1) 
		                {
                            $strOUcol = $global:csvHistACLs[$index].OU

                            if($strOUcol.Contains("<DOMAIN-DN>") -gt 0)
                            {
		                        $strOUcol = ($strOUcol -Replace "<DOMAIN-DN>",$global:strDomainDNName)

                            }
                            if($strOUcol.Contains("<ROOT-DN>") -gt 0)
                            {
		                        $strOUcol = ($strOUcol -Replace "<ROOT-DN>",$global:ForestRootDomainDN)

                            }
                            if($txtReplaceDN.text.Length -gt 0)
                            {
		                        $strOUcol = ($strOUcol -Replace $txtReplaceDN.text,$global:strDomainDNName)

                            }
			                if ($OUdnorgDN -eq $strOUcol )
			                {
                                $OUMatchResult = $true
                                $OUMatchResultOverall = $true
				                $strIdentityReference = $global:csvHistACLs[$index].IdentityReference
                                if($strIdentityReference.Contains("<DOMAIN-NETBIOS>"))
                                {
		                            $strIdentityReference = ($strIdentityReference -Replace "<DOMAIN-NETBIOS>",$global:strDomainShortName)

                                }
                                if($strIdentityReference.Contains("<ROOT-NETBIOS>"))
                                {
		                            $strIdentityReference = ($strIdentityReference -Replace "<ROOT-NETBIOS>",$global:strRootDomainShortName)

                                }
	                            If ($strIdentityReference.contains("S-1-"))
	                            {
	                                $strIdentityReference = ConvertSidToName -server $global:strDomainLongName -Sid $strIdentityReference

	                            }
                                if($txtReplaceNetbios.text.Length -gt 0)
                                {
		                            $strIdentityReference = ($strIdentityReference -Replace $txtReplaceNetbios.text,$global:strDomainShortName)

                                }
				                $strTmpActiveDirectoryRights = $global:csvHistACLs[$index].ActiveDirectoryRights				
				                $strTmpInheritanceType = $global:csvHistACLs[$index].InheritanceType			
				                $strTmpObjectTypeGUID = $global:csvHistACLs[$index].ObjectType
				                $strTmpInheritedObjectTypeGUID = $global:csvHistACLs[$index].InheritedObjectType
				                $strTmpObjectFlags = $global:csvHistACLs[$index].ObjectFlags
				                $strTmpAccessControlType = $global:csvHistACLs[$index].AccessControlType
                                if ($strTmpAccessControlType -eq "Owner" )
                                {
                                    $global:strOwnerTemplate = $strIdentityReference
                                }
				                $strTmpIsInherited = $global:csvHistACLs[$index].IsInherited
				                $strTmpInheritedFlags = $global:csvHistACLs[$index].InheritanceFlags
				                $strTmpPropFlags = $global:csvHistACLs[$index].PropagationFlags

                                If (($newSdObject.IdentityReference -eq $strIdentityReference) -and ($newSdObject.ActiveDirectoryRights -eq $strTmpActiveDirectoryRights) -and ($newSdObject.AccessControlType -eq $strTmpAccessControlType) -and ($newSdObject.ObjectType -eq $strTmpObjectTypeGUID) -and ($newSdObject.InheritanceType -eq $strTmpInheritanceType) -and ($newSdObject.InheritedObjectType -eq $strTmpInheritedObjectTypeGUID))
		 		                {
					                $SDResult = $true
		 		                }
 		 	                }
			                $index++
		                }# End While
         
                    if ($SDResult)
                    {
                        if ($intAclOccurence -eq 0)
                        {
                            $intAclOccurence++
                            $bolOUHeader = $true 
                            WriteHTM $false $sd $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader $strColorTemp $strFileHTA $bolCompare $bolFilter $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked
                        
                        }
                        $bolOUHeader = $false 
                        WriteHTM $true $newSdObject $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader "4" $strFileHTA $bolCompare $bolFilter $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked
                    
                    }
		            If ($OUMatchResult -And !($SDResult))
		            {
                        if ($intAclOccurence -eq 0)
                        {
                            $intAclOccurence++
                            $bolOUHeader = $true 
                            WriteHTM $false $sd $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader $strColorTemp $strFileHTA $bolCompare $bolFilter $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked
                        }
                        $bolAddedACL = $true       
                        $newSdObject.Color = "New"
                        $bolOUHeader = $false 
                        WriteHTM $true $newSdObject $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader "5" $strFileHTA $bolCompare $bolFilter $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked
            
                     }
                }# End If SkipProtectedPerm
            }# End If SkipDefaultPerm
	    }
            } # if $SDUsnCheck -eq $true

        If (($SDUsnCheck -eq $false) -or ($SDUsnNew -eq $true))
        {
            $index = 0

            while($index -le $global:csvHistACLs.count -1) 
            {
                $SDHistResult = $false

                $strOUcol = $global:csvHistACLs[$index].OU
                if($strOUcol.Contains("<DOMAIN-DN>") -gt 0)
                {
		            $strOUcol = ($strOUcol -Replace "<DOMAIN-DN>",$global:strDomainDNName)

                }
                if($strOUcol.Contains("<ROOT-DN>") -gt 0)
                {
		            $strOUcol = ($strOUcol -Replace "<ROOT-DN>",$global:ForestRootDomainDN)

                }
                if($txtReplaceDN.text.Length -gt 0)
                {
		            $strOUcol = ($strOUcol -Replace $txtReplaceDN.text,$global:strDomainDNName)

                }     
			    if ($OUdnorgDN -eq $strOUcol )
			    {
                    $OUMatchResult = $true
				    $strIdentityReference = $global:csvHistACLs[$index].IdentityReference

                    if($strIdentityReference.Contains("<DOMAIN-NETBIOS>"))
                    {
		                $strIdentityReference = ($strIdentityReference -Replace "<DOMAIN-NETBIOS>",$global:strDomainShortName)

                    }
                    if($strIdentityReference.Contains("<ROOT-NETBIOS>"))
                    {
		                $strIdentityReference = ($strIdentityReference -Replace "<ROOT-NETBIOS>",$global:strRootDomainShortName)

                    }
	                If ($strIdentityReference.contains("S-1-"))
	                {
	                 $strIdentityReference = ConvertSidToName -server $global:strDomainLongName -Sid $strIdentityReference

	                }
                    if($txtReplaceNetbios.text.Length -gt 0)
                    {
		                $strIdentityReference = ($strIdentityReference -Replace $txtReplaceNetbios.text,$global:strDomainShortName)

                    }
				    $strTmpActiveDirectoryRights = $global:csvHistACLs[$index].ActiveDirectoryRights			
				    $strTmpInheritanceType = $global:csvHistACLs[$index].InheritanceType				
				    $strTmpObjectTypeGUID = $global:csvHistACLs[$index].ObjectType
				    $strTmpInheritedObjectTypeGUID = $global:csvHistACLs[$index].InheritedObjectType
				    $strTmpObjectFlags = $global:csvHistACLs[$index].ObjectFlags
				    $strTmpAccessControlType = $global:csvHistACLs[$index].AccessControlType
                    if ($strTmpAccessControlType -eq "Owner" )
                    {
                        $global:strOwnerTemplate = $strIdentityReference
                    }
				    $strTmpIsInherited = $global:csvHistACLs[$index].IsInherited
				    $strTmpInheritedFlags = $global:csvHistACLs[$index].InheritanceFlags
				    $strTmpPropFlags = $global:csvHistACLs[$index].PropagationFlags

                
                    $rarHistCheck = @($($sd | select-object -Property *))

	                foreach($sdObject in $rarHistCheck)
	                {
                        $bolMatchDef = $false
                        $strNTAccount = $sdObject.IdentityReference.toString()
	                    If ($strNTAccount.contains("S-1-"))
	                    {
	                     $strNTAccount = ConvertSidToName -server $global:strDomainLongName -Sid $strNTAccount

	                    }
                        #Remove Default Permissions if SkipDefaultPerm selected
                        if($SkipDefaultPerm)
                        {
                            if($strObjectClass  -ne $strTemoObjectClass)
                            {
                                $sdOUDef = Get-PermDef $strObjectClass $strNTAccount
                            }
                            $strTemoObjectClass = $strObjectClass
                            $indexDef=0
                            while($indexDef -le $sdOUDef.count -1) {
			                            if (($sdOUDef[$indexDef].IdentityReference -eq $strNTAccount) -and ($sdOUDef[$indexDef].ActiveDirectoryRights -eq $sdObject.ActiveDirectoryRights) -and ($sdOUDef[$indexDef].AccessControlType -eq $sdObject.AccessControlType) -and ($sdOUDef[$indexDef].ObjectType -eq $sdObject.ObjectType) -and ($sdOUDef[$indexDef].InheritanceType -eq $sdObject.InheritanceType) -and ($sdOUDef[$indexDef].InheritedObjectType -eq $sdObject.InheritedObjectType))
			                            {
			                                $bolMatchDef = $true
			                            }#} #End If
                                $indexDef++
                            } #End While
                        }

                        if($bolMatchDef)
				        {
				        }
                        else
                        {     
                            #Remove Protect Against Accidental Deletaions Permissions if SkipProtectedPerm selected
                            if($SkipProtectedPerm)
                            {
                                if($sdOUProtect -eq "")
                                {
                                    $sdOUProtect = Get-ProtectedPerm
                                }
                                $indexProtected=0
                                while($indexProtected -le $sdOUProtect.count -1)
                                {
			                        if (($sdOUProtect[$indexProtected].IdentityReference -eq $strNTAccount) -and ($sdOUProtect[$indexProtected].ActiveDirectoryRights -eq $sdObject.ActiveDirectoryRights) -and ($sdOUProtect[$indexProtected].AccessControlType -eq $sdObject.AccessControlType) -and ($sdOUProtect[$indexProtected].ObjectType -eq $sdObject.ObjectType) -and ($sdOUProtect[$indexProtected].InheritanceType -eq $sdObject.InheritanceType) -and ($sdOUProtect[$indexProtected].InheritedObjectType -eq $sdObject.InheritedObjectType))
			                        {
			                            $bolMatchprotected = $true
			                        }#End If
                                    $indexProtected++
                                } #End While
                            }

                            if($bolMatchprotected)
				            {
				            }
				            else
				            {                     
                                if($null  -ne $sdObject.AccessControlType)
                                {
                                    $ACEType = $sdObject.AccessControlType
                                }
                                else
                                {
                                    $ACEType = $sdObject.AuditFlags
                                }                                          
           
                                $newSdObject = New-Object PSObject -Property @{ActiveDirectoryRights=$sdObject.ActiveDirectoryRights;InheritanceType=$sdObject.InheritanceType;ObjectType=$sdObject.ObjectType;`
                                InheritedObjectType=$sdObject.InheritedObjectType;ObjectFlags=$sdObject.ObjectFlags;AccessControlType=$ACEType;IdentityReference=$strNTAccount;IsInherited=$sdObject.IsInherited;`
                                InheritanceFlags=$sdObject.InheritanceFlags;PropagationFlags=$sdObject.PropagationFlags}

                                If (($newSdObject.IdentityReference -eq $strIdentityReference) -and ($newSdObject.ActiveDirectoryRights -eq $strTmpActiveDirectoryRights) -and ($newSdObject.AccessControlType -eq $strTmpAccessControlType) -and ($newSdObject.ObjectType -eq $strTmpObjectTypeGUID) -and ($newSdObject.InheritanceType -eq $strTmpInheritanceType) -and ($newSdObject.InheritedObjectType -eq $strTmpInheritedObjectTypeGUID))
                                {
                                    $SDHistResult = $true
                                }#End If $newSdObject
                            }# End If SkipProtectedPerm
                        }# End If SkipDefaultPerm
                    }# End foreach 

                    #If OU exist in CSV but no matching ACE found
                    If ($OUMatchResult -And !($SDHistResult))
                    {

                        $bolMissingACL = $true
                        $strIdentityReference = $global:csvHistACLs[$index].IdentityReference
                        if($strIdentityReference.Contains("<DOMAIN-NETBIOS>"))
                        {
		                    $strIdentityReference = ($strIdentityReference -Replace "<DOMAIN-NETBIOS>",$global:strDomainShortName)

                        }
                        if($strIdentityReference.Contains("<ROOT-NETBIOS>"))
                        {
		                    $strIdentityReference = ($strIdentityReference -Replace "<ROOT-NETBIOS>",$global:strRootDomainShortName)

                        }
                        if($txtReplaceNetbios.text.Length -gt 0)
                        {
		                    $strIdentityReference = ($strIdentityReference -Replace $txtReplaceNetbios.text,$global:strDomainShortName)

                        }                  
	                    If ($strIdentityReference.contains("S-1-"))
	                    {
	                     $strIdentityReference = ConvertSidToName -server $global:strDomainLongName -Sid $strIdentityReference

	                    }
                        $histSDObject = New-Object PSObject -Property @{ActiveDirectoryRights=$global:csvHistACLs[$index].ActiveDirectoryRights;InheritanceType=$global:csvHistACLs[$index].InheritanceType;ObjectType=$global:csvHistACLs[$index].ObjectType;`
                        InheritedObjectType=$global:csvHistACLs[$index].InheritedObjectType;ObjectFlags=$global:csvHistACLs[$index].ObjectFlags;AccessControlType=$global:csvHistACLs[$index].AccessControlType;IdentityReference=$strIdentityReference;IsInherited=$global:csvHistACLs[$index].IsInherited;`
                        InheritanceFlags=$global:csvHistACLs[$index].InheritanceFlags;PropagationFlags=$global:csvHistACLs[$index].PropagationFlags;Color="Missing"}
                    
                        if ($intAclOccurence -eq 0)
                        {
                            $intAclOccurence++
                            $bolOUHeader = $true 
                            WriteHTM $false $sd $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader $strColorTemp $strFileHTA $bolCompare $bolFilter $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked
                        }
                        $bolOUHeader = $false               
                        WriteHTM $true $histSDObject $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader "3" $strFileHTA $bolCompare $bolFilter $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked
                        $histSDObject = ""
                    }# End If $OUMatchResult
                }# End if $OUdn
			    $index++
		    }# End While
#            if ($bolMissingACL -eq $true)
#            {
#                #Write-host "This is a object has lost a ACL $OUdnorgDN"
#            }
#            if ($bolAddedACL -eq $true)
#            {
#                #Write-host "This is a object has a new ACL $OUdnorgDN"
#            }
        } #End If If ($SDUsnCheck -eq $false)

        #If the OU was not found in the CSV
        If (!$OUMatchResultOverall)        
        {

	        foreach($sdObject in $rar)
            {
                $bolMatchDef = $false
                if($sdObject.IdentityReference.value)
                {
                    $strNTAccount = $sdObject.IdentityReference.value
                }
                else
                {
                   $strNTAccount = $sdObject.IdentityReference
                }
	            If ($strNTAccount.contains("S-1-"))
	            {
	             $strNTAccount = ConvertSidToName -server $global:strDomainLongName -Sid $strNTAccount

	            }

                #Remove Default Permissions if SkipDefaultPerm selected
                if($SkipDefaultPerm -or $bolCompareDelegation) 
                {
                    if($strObjectClass  -ne $strTemoObjectClass)
                    {
                        $sdOUDef = Get-PermDef $strObjectClass $strNTAccount
                    }
                    $strTemoObjectClass = $strObjectClass
                    $indexDef=0
                    while($indexDef -le $sdOUDef.count -1) {
			                    if (($sdOUDef[$indexDef].IdentityReference -eq $strNTAccount) -and ($sdOUDef[$indexDef].ActiveDirectoryRights -eq $sd[$index].ActiveDirectoryRights) -and ($sdOUDef[$indexDef].AccessControlType -eq $sd[$index].AccessControlType) -and ($sdOUDef[$indexDef].ObjectType -eq $sd[$index].ObjectType) -and ($sdOUDef[$indexDef].InheritanceType -eq $sd[$index].InheritanceType) -and ($sdOUDef[$indexDef].InheritedObjectType -eq $sd[$index].InheritedObjectType))
			                    {
			                        $bolMatchDef = $true
			                    }#} #End If
                        $indexDef++
                    } #End While
                }

                if($bolMatchDef)
			    {
			    }
                else
                {   
                    if($SkipDefaultPerm -or $bolCompareDelegation) 
                    {
                        $strDelegationNotation = "Out of Policy"


                        If (($strNTAccount -eq $global:strOwnerTemplate) -and ($sdObject.ActiveDirectoryRights -eq "Read permissions, Modify permissions") -and ($sdObject.AccessControlType -eq "Owner") -and ($sdObject.ObjectType -eq "None") -and ($sdObject.InheritanceType -eq "None") -and ($sdObject.InheritedObjectType -eq "None"))
                        {
                                
                        }#End If $newSdObject
                        else
                        {

                            $MissingOUSdObject = New-Object PSObject -Property @{ActiveDirectoryRights=$sdObject.ActiveDirectoryRights;InheritanceType=$sdObject.InheritanceType;ObjectType=$sdObject.ObjectType;`
                            InheritedObjectType=$sdObject.InheritedObjectType;ObjectFlags=$sdObject.ObjectFlags;AccessControlType=$sdObject.AccessControlType;IdentityReference=$strNTAccount;IsInherited=$sdObject.IsInherited;`
                            InheritanceFlags=$sdObject.InheritanceFlags;PropagationFlags=$sdObject.PropagationFlags;Color=$strDelegationNotation}

                            if ($intAclOccurence -eq 0)
                            {
                                $intAclOccurence++
                                $bolOUHeader = $true 
                                WriteHTM $false $sd $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader $strColorTemp $strFileHTA $bolCompare $bolFilter $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked
                            }
                            $bolOUHeader = $false 
                            WriteHTM $true $MissingOUSdObject $OUdn $bolOUHeader "5" $strFileHTA $bolCompare $bolFilter $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked
                        }
                    }
                    else
                    {
                        if($SDUsnCheck -eq $false)
                        {
                            $strDelegationNotation = "Node not in file"
            

                            $MissingOUSdObject = New-Object PSObject -Property @{ActiveDirectoryRights=$sdObject.ActiveDirectoryRights;InheritanceType=$sdObject.InheritanceType;ObjectType=$sdObject.ObjectType;`
                            InheritedObjectType=$sdObject.InheritedObjectType;ObjectFlags=$sdObject.ObjectFlags;AccessControlType=$sdObject.AccessControlType;IdentityReference=$strNTAccount;IsInherited=$sdObject.IsInherited;`
                            InheritanceFlags=$sdObject.InheritanceFlags;PropagationFlags=$sdObject.PropagationFlags;Color=$strDelegationNotation}
 
                            if ($intAclOccurence -eq 0)
                            {
                                $intAclOccurence++
                                $bolOUHeader = $true 
                                WriteHTM $false $sd $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader $strColorTemp $strFileHTA $bolCompare $bolFilter $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked
                            }
                            $bolOUHeader = $false                  
                            WriteHTM $true $MissingOUSdObject $DSobject.Attributes.distinguishedname[0].toString() $bolOUHeader "5" $strFileHTA $bolCompare $bolFilter $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked
                        }
                    }
                }#Skip Default or bolComparedelegation
            }#End Forech $rar
        } #End If not OUMatchResultOverall
      }#End Global:GetSecErr
  }#else if adobject missing name
  else
  {
  $index = 0
     while($index -le $global:csvHistACLs.count -1) 
     {
        $SDHistResult = $false

        $strOUcol = $global:csvHistACLs[$index].OU

        if($strOUcol.Contains("<DOMAIN-DN>") -gt 0)
        {
		    $strOUcol = ($strOUcol -Replace "<DOMAIN-DN>",$global:strDomainDNName)

        }
        if($strOUcol.Contains("<ROOT-DN>") -gt 0)
        {
		    $strOUcol = ($strOUcol -Replace "<ROOT-DN>",$global:ForestRootDomainDN)

        }
        if($txtReplaceDN.text.Length -gt 0)
        {
		    $strOUcol = ($strOUcol -Replace $txtReplaceDN.text,$global:strDomainDNName)

        }           
	    if ($OUdnorgDN -eq $strOUcol )
	    {

            $strIdentityReference = $global:csvHistACLs[$index].IdentityReference
            if($strIdentityReference.Contains("<DOMAIN-NETBIOS>"))
            {
		        $strIdentityReference = ($strIdentityReference -Replace "<DOMAIN-NETBIOS>",$global:strDomainShortName)

            }
            if($strIdentityReference.Contains("<ROOT-NETBIOS>"))
            {
		        $strIdentityReference = ($strIdentityReference -Replace "<ROOT-NETBIOS>",$global:strRootDomainShortName)

            }
            if($txtReplaceNetbios.text.Length -gt 0)
            {
		        $strIdentityReference = ($strIdentityReference -Replace $txtReplaceNetbios.text,$global:strDomainShortName)

            }    
	        If ($strIdentityReference.contains("S-1-"))
	        {
	         $strIdentityReference = ConvertSidToName -server $global:strDomainLongName -Sid $strIdentityReference

	        }
            $histSDObject = New-Object PSObject -Property @{ActiveDirectoryRights=$global:csvHistACLs[$index].ActiveDirectoryRights;InheritanceType=$global:csvHistACLs[$index].InheritanceType;ObjectType=$global:csvHistACLs[$index].ObjectType;`
            InheritedObjectType=$global:csvHistACLs[$index].InheritedObjectType;ObjectFlags=$global:csvHistACLs[$index].ObjectFlags;AccessControlType=$global:csvHistACLs[$index].AccessControlType;IdentityReference=$strIdentityReference;IsInherited=$global:csvHistACLs[$index].IsInherited;`
            InheritanceFlags=$global:csvHistACLs[$index].InheritanceFlags;PropagationFlags=$global:csvHistACLs[$index].PropagationFlags;Color="Node does not exist in AD"}
                    
            if ($intAclOccurence -eq 0)
            {
                $intAclOccurence++
                $bolOUHeader = $true 
                WriteHTM $false $histSDObject $strOUcol $bolOUHeader $strColorTemp $strFileHTA $bolCompare $bolFilter $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked
            }
            $bolOUHeader = $false               
            WriteHTM $true $histSDObject $strOUcol $bolOUHeader "3" $strFileHTA $bolCompare $bolFilter $bolReplMeta $objLastChange $bolACLsize $strACLSize $bolGetOUProtected $bolOUProtected $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $chkBoxObjType.IsChecked
            $histSDObject = ""
        }
        $index++
    }
  }#End if adobject missing name
  $count++
}# End While $ALOUdn.count

if (($count -gt 0))
{
    if (($PSVersionTable.PSVersion -ne "2.0") -and ($global:bolProgressBar))
    {
                
            $global:ProgressBarWindow.Window.Dispatcher.invoke([action]{$global:ProgressBarWindow.Window.Close()},"Normal")
    } 
       
    if ($aclcount -eq 0)
    {
    [System.Windows.Forms.MessageBox]::Show("No Permissions found!" , "Status") 
    }  
    else
    {
        if($chkBoxEffectiveRightsColor.IsChecked)
        {
            Switch ($global:intShowCriticalityLevel)
            {
                0
                {
                (Get-Content $strFileHTA) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "grey">INFO' | Set-Content $strFileHTA
                (Get-Content $strFileHTM) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "grey">INFO' | Set-Content $strFileHTM
                }
                1
                {
                (Get-Content $strFileHTA) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "blue">LOW' | Set-Content $strFileHTA
                (Get-Content $strFileHTM) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "blue">LOW' | Set-Content $strFileHTM
                }
                2
                {
                (Get-Content $strFileHTA) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "yellow">MEDIUM' | Set-Content $strFileHTA
                (Get-Content $strFileHTM) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "yellow">MEDIUM' | Set-Content $strFileHTM
                }
                3
                {
                (Get-Content $strFileHTA) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "orange">WARNING' | Set-Content $strFileHTA
                (Get-Content $strFileHTM) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "orange">WARNING' | Set-Content $strFileHTM
                }
                4
                {
                (Get-Content $strFileHTA) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "red">CRITICAL' | Set-Content $strFileHTA
                (Get-Content $strFileHTM) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "red">CRITICAL' | Set-Content $strFileHTM
                }
            }
        }
        if ($bolCSVOnly)
        {

            [System.Windows.Forms.MessageBox]::Show("Done!" , "Status") 
        }
        else
        {
	        Invoke-Item $strFileHTA
        }

    }# End If
}
else
{
[System.Windows.Forms.MessageBox]::Show("No objects found!" , "Status") 


}
}#End if ExitCompare
}# End Try
 Trap [SystemException]
 {
#

Invoke-Item $strFileHTA
;Continue
 }  

$histSDObject = ""
$sdObject = ""   
$MissingOUSdObject = ""
$newSdObject = ""
$DSobject = ""
$global:strOwner = ""
$global:csvHistACLs = ""
  

$secd = $null
Remove-Variable -Name "secd" -Scope Global
}

#==========================================================================
# Function		:  ConvertCSVtoHTM
# Arguments     : Fle Path 
# Returns   	: N/A
# Description   : Convert CSV file to HTM Output
#==========================================================================
Function ConvertCSVtoHTM
{
    Param($CSVInput,[boolean] $bolGUIDtoText)
$bolReplMeta = $false
If(Test-Path $CSVInput){
    $fileName = $(Get-ChildItem $CSVInput).BaseName
	$strFileHTA = $env:temp + "\ACLHTML.hta" 
	$strFileHTM = $env:temp + "\"+"$fileName"+".htm" 	

    $global:csvHistACLs = import-Csv $CSVInput
    #Test CSV file format



    if(TestCSVColumns $global:csvHistACLs)
    {
        If ($global:csvHistACLs[0].SDDate.length -gt 1)
        {
            $bolReplMeta = $true
        }

        $colHeaders = ( $global:csvHistACLs| Get-member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name')
        $bolObjType = $false
        Foreach ($ColumnName in $colHeaders )
        {

            if($ColumnName.Trim() -eq "ObjectClass")
            {
                $bolObjType = $true
            }
        }

        CreateHTM $fileName $strFileHTM
        CreateHTA $fileName $strFileHTA $strFileHTM $CurrentFSPath
	
        InitiateHTM $strFileHTM $fileName $fileName $bolReplMeta $false $false $chkBoxEffectiveRightsColor.IsChecked $false $false $false $strCompareFile $false $false $bolObjType
	    InitiateHTM $strFileHTA $fileName $fileName $bolReplMeta $false $false $chkBoxEffectiveRightsColor.IsChecked $false $false $false $strCompareFile $false $false $bolObjType
    
   

        $tmpOU = ""
        $index = 0
        while($index -le $global:csvHistACLs.count -1)
        {
	    
            $strOUcol = $global:csvHistACLs[$index].OU
        
	


            If ($bolReplMeta -eq $true)
            {

		        $strOU = $strOUcol
		        $strTrustee = $global:csvHistACLs[$index].IdentityReference
		        $strRights = $global:csvHistACLs[$index].ActiveDirectoryRights				
		        $strInheritanceType = $global:csvHistACLs[$index].InheritanceType				
		        $strObjectTypeGUID = $global:csvHistACLs[$index].ObjectType
		        $strInheritedObjectTypeGUID = $global:csvHistACLs[$index].InheritedObjectType
		        $strObjectFlags = $global:csvHistACLs[$index].ObjectFlags
		        $strAccessControlType = $global:csvHistACLs[$index].AccessControlType
		        $strIsInherited = $global:csvHistACLs[$index].IsInherited
		        $strInheritedFlags = $global:csvHistACLs[$index].InheritanceFlags
		        $strPropFlags = $global:csvHistACLs[$index].PropagationFlags
                $strTmpACLDate = $global:csvHistACLs[$index].SDDate

            }
            else
            {

		        $strOU = $strOUcol
		        $strTrustee = $global:csvHistACLs[$index].IdentityReference
		        $strRights = $global:csvHistACLs[$index].ActiveDirectoryRights				
		        $strInheritanceType = $global:csvHistACLs[$index].InheritanceType				
		        $strObjectTypeGUID = $global:csvHistACLs[$index].ObjectType
		        $strInheritedObjectTypeGUID = $global:csvHistACLs[$index].InheritedObjectType
		        $strObjectFlags = $global:csvHistACLs[$index].ObjectFlags
		        $strAccessControlType = $global:csvHistACLs[$index].AccessControlType
		        $strIsInherited = $global:csvHistACLs[$index].IsInherited
		        $strInheritedFlags = $global:csvHistACLs[$index].InheritanceFlags
		        $strPropFlags = $global:csvHistACLs[$index].PropagationFlags

            }                                
            
            If ($bolObjType -eq $true)
            {

		        $strObjectClass = $global:csvHistACLs[$index].ObjectClass
            }

            $txtSdObject = New-Object PSObject -Property @{ActiveDirectoryRights=$strRights;InheritanceType=$strInheritanceType;ObjectType=$strObjectTypeGUID;`
            InheritedObjectType=$strInheritedObjectTypeGUID;ObjectFlags=$strObjectFlags;AccessControlType=$strAccessControlType;IdentityReference=$strTrustee;IsInherited=$strIsInherited;`
            InheritanceFlags=$strInheritedFlags;PropagationFlags=$strPropFlags}

	        If ($strColorTemp -eq "1")
	        {
		        $strColorTemp = "2"
	        }# End If
	        else
	        {
		        $strColorTemp = "1"
	        }# End If                  
            if ($tmpOU -ne $strOU)      
            {
  
                $bolOUHeader = $true   
                WriteHTM $true $txtSdObject $strOU $bolOUHeader $strColorTemp $strFileHTA $false $false $bolReplMeta $strTmpACLDate $false $strACLSize $false $false $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $bolObjType
   
    
                $tmpOU = $strOU
            }
            else
            {
                $bolOUHeader = $false   
                WriteHTM $true $txtSdObject $strOU $bolOUHeader $strColorTemp $strFileHTA $false $false $bolReplMeta $strTmpACLDate  $false $strACLSize $false $false $chkBoxEffectiveRightsColor.IsChecked $bolGUIDtoText $strObjectClass $bolObjType

            }
			
            $index++
				
        }#End While


        if($chkBoxEffectiveRightsColor.IsChecked)
        {
            Switch ($global:intShowCriticalityLevel)
            {
                0
                {
                (Get-Content $strFileHTA) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "grey">INFO' | Set-Content $strFileHTA
                (Get-Content $strFileHTM) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "grey">INFO' | Set-Content $strFileHTM
                }
                1
                {
                (Get-Content $strFileHTA) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "blue">LOW' | Set-Content $strFileHTA
                (Get-Content $strFileHTM) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "blue">LOW' | Set-Content $strFileHTM
                }
                2
                {
                (Get-Content $strFileHTA) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "yellow">MEDIUM' | Set-Content $strFileHTA
                (Get-Content $strFileHTM) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "yellow">MEDIUM' | Set-Content $strFileHTM
                }
                3
                {
                (Get-Content $strFileHTA) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "orange">WARNING' | Set-Content $strFileHTA
                (Get-Content $strFileHTM) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "orange">WARNING' | Set-Content $strFileHTM
                }
                4
                {
                (Get-Content $strFileHTA) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "red">CRITICAL' | Set-Content $strFileHTA
                (Get-Content $strFileHTM) -replace "20141220T021111056594002014122000", '<FONT size="6" color= "red">CRITICAL' | Set-Content $strFileHTM
                }
            }
        }

        Invoke-Item $strFileHTA
    }#else if test column names exist
    else
    {
        $global:observableCollection.Insert(0,(LogMessage -strMessage "CSV file got wrong format! File:  $CSVInput" -strType "Error" -DateStamp ))
    } #End if test column names exist 
}
else
{
    $global:observableCollection.Insert(0,(LogMessage -strMessage "Failed! $CSVInput does not exist!" -strType "Error" -DateStamp ))
}

}# End Function



#==========================================================================
# Function		: New-Type
# Arguments     : C# Code, dll 
# Returns   	: n/a
# Description   : Takes C# source code, and compiles it (in memory) for use in scri ...
#==========================================================================
function New-Type 
{
   param([string]$TypeDefinition,[string[]]$ReferencedAssemblies)
   
   $provider = New-Object Microsoft.CSharp.CSharpCodeProvider
   $dllName = [PsObject].Assembly.Location
   $compilerParameters = New-Object System.CodeDom.Compiler.CompilerParameters

   $assemblies = @("System.dll", $dllName)
   $compilerParameters.ReferencedAssemblies.AddRange($assemblies)
   if($ReferencedAssemblies) { 
      $compilerParameters.ReferencedAssemblies.AddRange($ReferencedAssemblies) 
   }

   $compilerParameters.IncludeDebugInformation = $true
   $compilerParameters.GenerateInMemory = $true

   $compilerResults = $provider.CompileAssemblyFromSource($compilerParameters, $TypeDefinition)
   if($compilerResults.Errors.Count -gt 0) {
     $compilerResults.Errors | ForEach-Object{ Write-Error ("{0}:`t{1}" -f $_.Line,$_.ErrorText) }
   }
}
#==========================================================================
# Function		: GetACLMeta
# Arguments     : Domain Controller, AD Object DN 
# Returns   	: Semi-colon separated string
# Description   : Get AD Replication Meta data LastOriginatingChange, LastOriginatingDsaInvocationID
#                  usnOriginatingChange and returns as string
#==========================================================================
Function GetACLMeta
{
    Param($DomainController,$objDN)

$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
$LDAPConnection.SessionOptions.ReferralChasing = "None"
$request = New-Object System.directoryServices.Protocols.SearchRequest($objDN, "(name=*)", "base")
$SecurityMasks = [System.DirectoryServices.Protocols.SecurityMasks]'Owner' -bor [System.DirectoryServices.Protocols.SecurityMasks]'Group'-bor [System.DirectoryServices.Protocols.SecurityMasks]'Dacl' #-bor [System.DirectoryServices.Protocols.SecurityMasks]'Sacl'
$control = New-Object System.DirectoryServices.Protocols.SecurityDescriptorFlagControl($SecurityMasks)
[void]$request.Controls.Add($control)
[void]$request.Attributes.Add("ntsecuritydescriptor")
[void]$request.Attributes.Add("name")
[void]$request.Attributes.Add("distinguishedName")
[void]$request.Attributes.Add("msDS-ReplAttributeMetaData")
$response = $LDAPConnection.SendRequest($request)

foreach ($entry  in $response.Entries)
{
    
    $index = 0
    while($index -le $entry.attributes.'msds-replattributemetadata'.count -1) 
         {
            $childMember = $entry.attributes.'msds-replattributemetadata'[$index]
            $childMember = $childMember.replace("$($childMember[-1])","")
            If ($([xml]$childMember).DS_REPL_ATTR_META_DATA.pszAttributeName -eq "nTSecurityDescriptor")
            {
                $strLastChangeDate = $([xml]$childMember).DS_REPL_ATTR_META_DATA.ftimeLastOriginatingChange
                $strInvocationID = $([xml]$childMember).DS_REPL_ATTR_META_DATA.uuidLastOriginatingDsaInvocationID
                $strOriginatingChange = $([xml]$childMember).DS_REPL_ATTR_META_DATA.usnOriginatingChange
            }
            $index++
         }    
}
if ($strLastChangeDate -eq $nul)
{
    $ACLdate = $(get-date "1601-01-01" -UFormat "%Y-%m-%d %H:%M:%S")
    $strInvocationID = "00000000-0000-0000-0000-000000000000"
    $strOriginatingChange = "000000"
}
else
{
$ACLdate = $(get-date $strLastChangeDate -UFormat "%Y-%m-%d %H:%M:%S")
}
  return "$ACLdate;$strInvocationID;$strOriginatingChange"
}

#==========================================================================
# Function		: Get-DefaultSD
# Arguments     : string ObjectClass
# Returns   	: 
# Description   : Create report of default Security Descriptor 
#==========================================================================
Function Get-DefaultSD
{
    Param( [String[]] $strObjectClass,[bool] $bolChangedDefSD,[bool]$bolSDDL)
$strFileDefSDHTA = $env:temp + "\ModifiedDefSDAccess.hta" 
$strFileDefSDHTM = $env:temp + "\ModifiedDefSDAccess.htm" 
$bolOUHeader = $true 
$bolReplMeta = $true    
$bolCompare = $false 
$intNumberofDefSDFound = 0
if($bolSDDL -eq $true)
{
        CreateDefaultSDReportHTA $global:strDomainLongName $strFileDefSDHTA $strFileDefSDHTM $CurrentFSPath
        CreateDefSDHTM $global:strDomainLongName $strFileDefSDHTM
        InitiateDefSDHTM $strFileDefSDHTM $strObjectClass
        InitiateDefSDHTM $strFileDefSDHTA $strObjectClass
}
else
{
    CreateHTM "strObjectClass" $strFileDefSDHTM					
    CreateHTA "$strObjectClass" $strFileDefSDHTA $strFileDefSDHTM $CurrentFSPath
    InitiateDefSDAccessHTM $strFileDefSDHTA $strObjectClass $bolReplMeta $false ""
    InitiateDefSDAccessHTM $strFileDefSDHTM $strObjectClass $bolReplMeta $false ""
}

$strColorTemp = 1 

$PageSize=100
$TimeoutSeconds = 120

$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
$LDAPConnection.SessionOptions.ReferralChasing = "None"
$request = New-Object System.directoryServices.Protocols.SearchRequest($global:SchemaDN, "(&(objectClass=classSchema)(name=$strObjectClass))", "Subtree")
[System.DirectoryServices.Protocols.PageResultRequestControl]$pagedRqc = new-object System.DirectoryServices.Protocols.PageResultRequestControl($pageSize)
$request.Controls.Add($pagedRqc) | Out-Null
[void]$request.Attributes.Add("defaultsecuritydescriptor")
[void]$request.Attributes.Add("name")
[void]$request.Attributes.Add("distinguishedname")
[void]$request.Attributes.Add("msds-replattributemetadata")

$CountadObject = 0
while ($true)
{
    $response = $LdapConnection.SendRequest($request, (new-object System.Timespan(0,0,$TimeoutSeconds))) -as [System.DirectoryServices.Protocols.SearchResponse];
                
    #for paged search, the response for paged search result control - we will need a cookie from result later
    if($pageSize -gt 0) {
        [System.DirectoryServices.Protocols.PageResultResponseControl] $prrc=$null;
        if ($response.Controls.Length -gt 0)
        {
            foreach ($ctrl in $response.Controls)
            {
                if ($ctrl -is [System.DirectoryServices.Protocols.PageResultResponseControl])
                {
                    $prrc = $ctrl;
                    break;
                }
            }
        }
        if($null -eq $prrc) {
            #server was unable to process paged search
            throw "Find-LdapObject: Server failed to return paged response for request $SearchFilter"
        }
    }
    #now process the returned list of distinguishedNames and fetch required properties using ranged retrieval

    $CountadObject = $CountadObject + $response.Entries.Count

    if($pageSize -gt 0) 
    {
        if ($prrc.Cookie.Length -eq 0)
        {
            #last page --> we're done
            break;
        }
        #pass the search cookie back to server in next paged request
        $pagedRqc.Cookie = $prrc.Cookie;
    }
    else
    {
        #exit the processing for non-paged search
        break;
    }
}#End While

#Load Progressbar
if (($PSVersionTable.PSVersion -ne "2.0") -and ($global:bolProgressBar))
{
    $intTot = 0
    #calculate percentage
    $intTot = $CountadObject
    if ($intTot -gt 0)
    {
    LoadProgressBar
    
    }
}

$response = $null

$PageSize=100
$TimeoutSeconds = 120

$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
$LDAPConnection.SessionOptions.ReferralChasing = "None"
$request = New-Object System.directoryServices.Protocols.SearchRequest($global:SchemaDN, "(&(objectClass=classSchema)(name=$strObjectClass))", "Subtree")
[System.DirectoryServices.Protocols.PageResultRequestControl]$pagedRqc = new-object System.DirectoryServices.Protocols.PageResultRequestControl($pageSize)
$request.Controls.Add($pagedRqc) | Out-Null
[void]$request.Attributes.Add("defaultsecuritydescriptor")
[void]$request.Attributes.Add("name")
[void]$request.Attributes.Add("distinguishedname")
[void]$request.Attributes.Add("msds-replattributemetadata")
while ($true)
{
    $response = $LdapConnection.SendRequest($request, (new-object System.Timespan(0,0,$TimeoutSeconds))) -as [System.DirectoryServices.Protocols.SearchResponse];
                
    #for paged search, the response for paged search result control - we will need a cookie from result later
    if($pageSize -gt 0) {
        [System.DirectoryServices.Protocols.PageResultResponseControl] $prrc=$null;
        if ($response.Controls.Length -gt 0)
        {
            foreach ($ctrl in $response.Controls)
            {
                if ($ctrl -is [System.DirectoryServices.Protocols.PageResultResponseControl])
                {
                    $prrc = $ctrl;
                    break;
                }
            }
        }
        if($null -eq $prrc) {
            #server was unable to process paged search
            throw "Find-LdapObject: Server failed to return paged response for request $SearchFilter"
        }
    }
    #now process the returned list of distinguishedNames and fetch required properties using ranged retrieval

    foreach ($entry  in $response.Entries)
    {
        #Update Progressbar
        if (($PSVersionTable.PSVersion -ne "2.0") -and ($global:bolProgressBar))
        {
            $i++
            [int]$pct = ($i/$intTot)*100
            #Update the progress bar
            while(($null -eq $global:ProgressBarWindow.Window.IsInitialized) -and ($intLoop -lt 20))
            {
                        Start-Sleep -Milliseconds 1
                        $cc++
            }
            if ($global:ProgressBarWindow.Window.IsInitialized -eq $true)
            {
                Update-ProgressBar "Currently scanning $i of $intTot objects" $pct 
            }  
        
        } 
        $index = 0
        while($index -le $entry.attributes.'msds-replattributemetadata'.count -1) 
            {
            $childMember = $entry.attributes.'msds-replattributemetadata'[$index]
            $childMember = $childMember.replace("$($childMember[-1])","")
            If ($([xml]$childMember).DS_REPL_ATTR_META_DATA.pszAttributeName -eq "defaultSecurityDescriptor")
            {
                $strLastChangeDate = $([xml]$childMember).DS_REPL_ATTR_META_DATA.ftimeLastOriginatingChange
                $strVersion = $([xml]$childMember).DS_REPL_ATTR_META_DATA.dwVersion
                if ($strLastChangeDate -eq $nul)
                {
                    $strLastChangeDate = $(get-date "1601-01-01" -UFormat "%Y-%m-%d %H:%M:%S")
     
                }
                else
                {
                $strLastChangeDate = $(get-date $strLastChangeDate -UFormat "%Y-%m-%d %H:%M:%S")
                }             
            }
            $index++
            }   

        if($bolChangedDefSD -eq $true)
        {
               
            if($strVersion -gt 1)
            {
                $strObjectClassName = $entry.Attributes.name[0]
                $sec = New-Object System.DirectoryServices.ActiveDirectorySecurity

              if($bolSDDL -eq $true)
              {
                $strSDDL = ""
                if($null -ne $entry.Attributes.defaultsecuritydescriptor)
                {
                    $strSDDL = $entry.Attributes.defaultsecuritydescriptor[0]
                }  
                #Indicate that a defaultsecuritydescriptor was found
                $intNumberofDefSDFound++
                WriteDefSDSDDLHTM $strColorTemp $strFileDefSDHTA $strFileDefSDHTM $strObjectClassName $strVersion $strLastChangeDate $strSDDL
                Switch ($strColorTemp) 
                {

                    "1"
	                    {
	                    $strColorTemp = "2"
	                    }
                    "2"
	                    {
	                    $strColorTemp = "1"
	                    }	
                }
              }
              else
              {
                $sd = ""
                if($null -ne $entry.Attributes.defaultsecuritydescriptor)
                {
                    $sec.SetSecurityDescriptorSddlForm($entry.Attributes.defaultsecuritydescriptor[0])
                }
                $sd = $sec.GetAccessRules($true, $false, [System.Security.Principal.NTAccount])   
                #Indicate that a defaultsecuritydescriptor was found
                $intNumberofDefSDFound++  
                WriteDefSDAccessHTM $sd $strObjectClassName $strColorTemp $strFileDefSDHTA $strFileDefSDHTM $bolOUHeader $bolReplMeta $strVersion $strLastChangeDate $chkBoxEffectiveRightsColor.IsChecked $bolCompare
               } 
            
            }
        }
        else
        {
            $strObjectClassName = $entry.Attributes.name[0]
            $sec = New-Object System.DirectoryServices.ActiveDirectorySecurity
            if($bolSDDL -eq $true)
            {
                $strSDDL = ""
                if($null -ne $entry.Attributes.defaultsecuritydescriptor)
                {
                    $strSDDL = $entry.Attributes.defaultsecuritydescriptor[0]
                } 
                #Indicate that a defaultsecuritydescriptor was found
                $intNumberofDefSDFound++                           
                WriteDefSDSDDLHTM $strColorTemp $strFileDefSDHTA $strFileDefSDHTM $strObjectClassName $strVersion $strLastChangeDate $strSDDL
                Switch ($strColorTemp) 
                {

                    "1"
	                    {
	                    $strColorTemp = "2"
	                    }
                    "2"
	                    {
	                    $strColorTemp = "1"
	                    }	
                }
            }
            else
            {
                $sd = ""
                if($null -ne $entry.Attributes.defaultsecuritydescriptor)
                {
                    $sec.SetSecurityDescriptorSddlForm($entry.Attributes.defaultsecuritydescriptor[0])
                }
                $sd = $sec.GetAccessRules($true, $false, [System.Security.Principal.NTAccount])   
                #Indicate that a defaultsecuritydescriptor was found
                $intNumberofDefSDFound++
                WriteDefSDAccessHTM $sd $strObjectClassName $strColorTemp $strFileDefSDHTA $strFileDefSDHTM $bolOUHeader $bolReplMeta $strVersion $strLastChangeDate $chkBoxEffectiveRightsColor.IsChecked $bolCompare
            }
        }
    }

    if($pageSize -gt 0) 
    {
        if ($prrc.Cookie.Length -eq 0)
        {
            #last page --> we're done
            break;
        }
        #pass the search cookie back to server in next paged request
        $pagedRqc.Cookie = $prrc.Cookie;
    }
    else
    {
        #exit the processing for non-paged search
        break;
    }
}#End While

if (($PSVersionTable.PSVersion -ne "2.0") -and ($global:bolProgressBar))
{
    $global:ProgressBarWindow.Window.Dispatcher.invoke([action]{$global:ProgressBarWindow.Window.Close()},"Normal")
    $ProgressBarWindow = $null
    Remove-Variable -Name "ProgressBarWindow" -Scope Global
} 
if($intNumberofDefSDFound  -gt 0)
{
    Invoke-Item $strFileDefSDHTA 
}
else
{
    $global:observableCollection.Insert(0,(LogMessage -strMessage "No defaultsecuritydescriptor found!" -strType "Error" -DateStamp ))
}
}

#==========================================================================
# Function		: Get-DefaultSDCompare
# Arguments     : string ObjectClass
# Returns   	: 
# Description   : Compare the default Security Descriptor 
#==========================================================================
Function Get-DefaultSDCompare
{
    Param( [String[]] $strObjectClass="*",
    [string] $strTemplate
    )
$strFileDefSDHTA = $env:temp + "\ModifiedDefSDAccess.hta" 
$strFileDefSDHTM = $env:temp + "\ModifiedDefSDAccess.htm" 
$bolOUHeader = $true 
$bolReplMeta = $true     
$bolCompare = $true
#Indicator that a defaultsecuritydescriptor was found
$intNumberofDefSDFound = 0

CreateHTM "strObjectClass" $strFileDefSDHTM					
CreateHTA "$strObjectClass" $strFileDefSDHTA $strFileDefSDHTM $CurrentFSPath
InitiateDefSDAccessHTM $strFileDefSDHTA $strObjectClass $bolReplMeta $true $strTemplate
InitiateDefSDAccessHTM $strFileDefSDHTM $strObjectClass $bolReplMeta $true $strTemplate

#Default color
$strColorTemp = 1 

$PageSize=100
$TimeoutSeconds = 120

$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
$LDAPConnection.SessionOptions.ReferralChasing = "None"
$request = New-Object System.directoryServices.Protocols.SearchRequest($global:SchemaDN, "(&(objectClass=classSchema)(name=$strObjectClass))", "Subtree")
[System.DirectoryServices.Protocols.PageResultRequestControl]$pagedRqc = new-object System.DirectoryServices.Protocols.PageResultRequestControl($pageSize)
$request.Controls.Add($pagedRqc) | Out-Null
[void]$request.Attributes.Add("defaultsecuritydescriptor")
[void]$request.Attributes.Add("name")
[void]$request.Attributes.Add("distinguishedname")
[void]$request.Attributes.Add("msds-replattributemetadata")

$CountadObject = 0
while ($true)
{
    $response = $LdapConnection.SendRequest($request, (new-object System.Timespan(0,0,$TimeoutSeconds))) -as [System.DirectoryServices.Protocols.SearchResponse];
                
    #for paged search, the response for paged search result control - we will need a cookie from result later
    if($pageSize -gt 0) {
        [System.DirectoryServices.Protocols.PageResultResponseControl] $prrc=$null;
        if ($response.Controls.Length -gt 0)
        {
            foreach ($ctrl in $response.Controls)
            {
                if ($ctrl -is [System.DirectoryServices.Protocols.PageResultResponseControl])
                {
                    $prrc = $ctrl;
                    break;
                }
            }
        }
        if($null -eq $prrc) {
            #server was unable to process paged search
            throw "Find-LdapObject: Server failed to return paged response for request $SearchFilter"
        }
    }
    #now process the returned list of distinguishedNames and fetch required properties using ranged retrieval

    $CountadObject = $CountadObject + $response.Entries.Count

    if($pageSize -gt 0) 
    {
        if ($prrc.Cookie.Length -eq 0)
        {
            #last page --> we're done
            break;
        }
        #pass the search cookie back to server in next paged request
        $pagedRqc.Cookie = $prrc.Cookie;
    }
    else
    {
        #exit the processing for non-paged search
        break;
    }
}#End While

#Load Progressbar
if (($PSVersionTable.PSVersion -ne "2.0") -and ($global:bolProgressBar))
{
    $intTot = 0
    #calculate percentage
    $intTot = $CountadObject
    if ($intTot -gt 0)
    {
    LoadProgressBar
    
    }
}


$PageSize=100
$TimeoutSeconds = 120

$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
$LDAPConnection.SessionOptions.ReferralChasing = "None"
$request = New-Object System.directoryServices.Protocols.SearchRequest($global:SchemaDN, "(&(objectClass=classSchema)(name=$strObjectClass))", "Subtree")
[System.DirectoryServices.Protocols.PageResultRequestControl]$pagedRqc = new-object System.DirectoryServices.Protocols.PageResultRequestControl($pageSize)
$request.Controls.Add($pagedRqc) | Out-Null
[void]$request.Attributes.Add("defaultsecuritydescriptor")
[void]$request.Attributes.Add("name")
[void]$request.Attributes.Add("distinguishedname")
[void]$request.Attributes.Add("msds-replattributemetadata")

while ($true)
{
    $response = $LdapConnection.SendRequest($request, (new-object System.Timespan(0,0,$TimeoutSeconds))) -as [System.DirectoryServices.Protocols.SearchResponse];
                
    #for paged search, the response for paged search result control - we will need a cookie from result later
    if($pageSize -gt 0) {
        [System.DirectoryServices.Protocols.PageResultResponseControl] $prrc=$null;
        if ($response.Controls.Length -gt 0)
        {
            foreach ($ctrl in $response.Controls)
            {
                if ($ctrl -is [System.DirectoryServices.Protocols.PageResultResponseControl])
                {
                    $prrc = $ctrl;
                    break;
                }
            }
        }
        if($null -eq $prrc) {
            #server was unable to process paged search
            throw "Find-LdapObject: Server failed to return paged response for request $SearchFilter"
        }
    }
    #now process the returned list of distinguishedNames and fetch required properties using ranged retrieval

    foreach ($entry  in $response.Entries)
    {
        $SDDLMatch = $true
        $ObjectMatchResult = $false
        #Update Progressbar
        if (($PSVersionTable.PSVersion -ne "2.0") -and ($global:bolProgressBar))
        {
            $i++
            [int]$pct = ($i/$intTot)*100
            #Update the progress bar
            while(($null -eq $global:ProgressBarWindow.Window.IsInitialized) -and ($intLoop -lt 20))
            {
                        Start-Sleep -Milliseconds 1
                        $cc++
            }
            if ($global:ProgressBarWindow.Window.IsInitialized -eq $true)
            {
                Update-ProgressBar "Currently scanning $i of $intTot objects" $pct 
            }  
        
        }
        #Counter for Metadata
        $index = 0
        #Get metadata for defaultSecurityDescriptor
        while($index -le $entry.attributes.'msds-replattributemetadata'.count -1) 
        {
            $childMember = $entry.attributes.'msds-replattributemetadata'[$index]
            $childMember = $childMember.replace("$($childMember[-1])","")
            If ($([xml]$childMember).DS_REPL_ATTR_META_DATA.pszAttributeName -eq "defaultSecurityDescriptor")
            {
                $strLastChangeDate = $([xml]$childMember).DS_REPL_ATTR_META_DATA.ftimeLastOriginatingChange
                $strVersion = $([xml]$childMember).DS_REPL_ATTR_META_DATA.dwVersion
                if ($strLastChangeDate -eq $nul)
                {
                    $strLastChangeDate = $(get-date "1601-01-01" -UFormat "%Y-%m-%d %H:%M:%S")
     
                }
                else
                {
                    $strLastChangeDate = $(get-date $strLastChangeDate -UFormat "%Y-%m-%d %H:%M:%S")
                }             
            }
            $index++
        }
        #Get object name
        $strObjectClassName = $entry.Attributes.name[0]


        #Make sure strSDDL is empty
        $strSDDL = ""
        if($null -ne $entry.Attributes.defaultsecuritydescriptor)
        {
            $strSDDL = $entry.Attributes.defaultsecuritydescriptor[0]
        }  
        $index = 0 
        #Enumerate template file
        $ObjectMatchResult = $false  
        while($index -le $global:csvdefSDTemplate.count -1) 
	    {
            $strNamecol = $global:csvdefSDTemplate[$index].Name
            #Check for matching object names
		    if ($strObjectClassName -eq $strNamecol )
		    {
                $ObjectMatchResult = $true    
                $strSDDLcol = $global:csvdefSDTemplate[$index].SDDL
                #Replace any <ROOT-DOAMIN> strngs with Forest Root Domain SID
                if($strSDDLcol.Contains("<ROOT-DOMAIN>"))
                {
                    if($global:ForestRootDomainSID -gt "")
                    {
                        $strSDDLcol  = $strSDDLcol.Replace("<ROOT-DOMAIN>",$global:ForestRootDomainSID)
                    }
                }
                #Compare SDDL
                if($strSDDL -eq $strSDDLcol)
                {
                    $SDDLMatch = $true
                    $sd = ""
                    #Create ad security object
                    $sec = New-Object System.DirectoryServices.ActiveDirectorySecurity
                    if($null -ne $entry.Attributes.defaultsecuritydescriptor)
                    {
                        $sec.SetSecurityDescriptorSddlForm($entry.Attributes.defaultsecuritydescriptor[0])
                    }
                    $sd = $sec.GetAccessRules($true, $false, [System.Security.Principal.NTAccount]) 
                    #Count ACE for applying header on fist
                    $intACEcount = 0
                    foreach($ObjectDefSD in $sd)
                    {
                        $strNTAccount = $ObjectDefSD.IdentityReference.toString()
	                    If ($strNTAccount.contains("S-1-"))
	                    {
	                     $strNTAccount = ConvertSidToName -server $global:strDomainLongName -Sid $strNTAccount

	                    }
                        $newObjectDefSD = New-Object PSObject -Property @{ActiveDirectoryRights=$ObjectDefSD.ActiveDirectoryRights;InheritanceType=$ObjectDefSD.InheritanceType;ObjectType=$ObjectDefSD.ObjectType;`
                        InheritedObjectType=$ObjectDefSD.InheritedObjectType;ObjectFlags=$ObjectDefSD.ObjectFlags;AccessControlType=$ObjectDefSD.AccessControlType;IdentityReference=$strNTAccount;IsInherited=$ObjectDefSD.IsInherited;`
                        InheritanceFlags=$ObjectDefSD.InheritanceFlags;PropagationFlags=$ObjectDefSD.PropagationFlags;Color="Match"}

                        #Matching color "green"
                        $strColorTemp = 4
                        #If first ACE add header
                        if ($intACEcount -eq 0)
				 	    {
                            #Indicate that a defaultsecuritydescriptor was found
                            $intNumberofDefSDFound++
                            $bolOUHeader = $true
                            WriteDefSDAccessHTM $newObjectDefSD $strObjectClassName $strColorTemp $strFileDefSDHTA $strFileDefSDHTM $bolOUHeader $bolReplMeta $strVersion $strLastChangeDate $chkBoxEffectiveRightsColor.IsChecked $bolCompare
                        }
                        else
                        {
                            $bolOUHeader = $false
                            WriteDefSDAccessHTM $newObjectDefSD $strObjectClassName $strColorTemp $strFileDefSDHTA $strFileDefSDHTM $bolOUHeader $bolReplMeta $strVersion $strLastChangeDate $chkBoxEffectiveRightsColor.IsChecked $bolCompare
                        }
                        #Count ACE to not ad a header
                        $intACEcount++
                    }
                    $newObjectDefSD = $null
                    $sd = $null
                    $sec = $null
                }
                else
                {
                    $sd = ""
                    #Create ad security object
                    $sec = New-Object System.DirectoryServices.ActiveDirectorySecurity
                    if($null -ne $entry.Attributes.defaultsecuritydescriptor)
                    {
                        $sec.SetSecurityDescriptorSddlForm($entry.Attributes.defaultsecuritydescriptor[0])
                    }
                    $sd = $sec.GetAccessRules($true, $false, [System.Security.Principal.NTAccount]) 
                    #Count ACE for applying header on fist
                    $intACEcount = 0
                    #Comare DefaultSecurityDesriptor in schema with template looking for matching and new ACE's
                    foreach($ObjectDefSD in $sd)
                    {
                        #Check if matchin ACE exits, FALSE until found 
                        $SDCompareResult = $false

                        $strNTAccount = $ObjectDefSD.IdentityReference.toString()
	                    If ($strNTAccount.contains("S-1-"))
	                    {
	                     $strNTAccount = ConvertSidToName -server $global:strDomainLongName -Sid $strNTAccount

	                    }

                        $newObjectDefSD = New-Object PSObject -Property @{ActiveDirectoryRights=$ObjectDefSD.ActiveDirectoryRights;InheritanceType=$ObjectDefSD.InheritanceType;ObjectType=$ObjectDefSD.ObjectType;`
                        InheritedObjectType=$ObjectDefSD.InheritedObjectType;ObjectFlags=$ObjectDefSD.ObjectFlags;AccessControlType=$ObjectDefSD.AccessControlType;IdentityReference=$strNTAccount;IsInherited=$ObjectDefSD.IsInherited;`
                        InheritanceFlags=$ObjectDefSD.InheritanceFlags;PropagationFlags=$ObjectDefSD.PropagationFlags;Color="New"}

                        $sdFile = ""
                        #Create ad security object
                        $secFile = New-Object System.DirectoryServices.ActiveDirectorySecurity
                        if($null -ne $strSDDLcol)
                        {
                            $secFile.SetSecurityDescriptorSddlForm($strSDDLcol)
                        }
                        $sdFile = $secFile.GetAccessRules($true, $false, [System.Security.Principal.NTAccount]) 
                        foreach($ObjectDefSDFile in $sdFile)
                        {
                                If (($newObjectDefSD.IdentityReference -eq $ObjectDefSDFile.IdentityReference) -and ($newObjectDefSD.ActiveDirectoryRights -eq $ObjectDefSDFile.ActiveDirectoryRights) -and ($newObjectDefSD.AccessControlType -eq $ObjectDefSDFile.AccessControlType) -and ($newObjectDefSD.ObjectType -eq $ObjectDefSDFile.ObjectType) -and ($newObjectDefSD.InheritanceType -eq $ObjectDefSDFile.InheritanceType) -and ($newObjectDefSD.InheritedObjectType -eq $ObjectDefSDFile.InheritedObjectType))
		 		                {
					                $SDCompareResult = $true
		 		                }
                        }
                        if ($SDCompareResult)
                        {
                            #Change from New to Match
                            $newObjectDefSD.Color = "Match"
                            #Match color "Green"
                            $strColorTemp = 4
                            #If first ACE add header
                            if ($intACEcount -eq 0)
				 	        {
                                #Indicate that a defaultsecuritydescriptor was found
                                $intNumberofDefSDFound++
                                $bolOUHeader = $true
                                WriteDefSDAccessHTM $newObjectDefSD $strObjectClassName $strColorTemp $strFileDefSDHTA $strFileDefSDHTM $bolOUHeader $bolReplMeta $strVersion $strLastChangeDate $chkBoxEffectiveRightsColor.IsChecked $bolCompare
                            }
                            else
                            {
                                $bolOUHeader = $false
                                WriteDefSDAccessHTM $newObjectDefSD $strObjectClassName $strColorTemp $strFileDefSDHTA $strFileDefSDHTM $bolOUHeader $bolReplMeta $strVersion $strLastChangeDate $chkBoxEffectiveRightsColor.IsChecked $bolCompare
                            }
                            #Count ACE to not ad a header
                            $intACEcount++
                        }
                        else
                        {
                            #New color "Yellow"
                            $strColorTemp = 5
                            #If first ACE add header
                            if ($intACEcount -eq 0)
				 	        {
                                #Indicate that a defaultsecuritydescriptor was found
                                $intNumberofDefSDFound++
                                $bolOUHeader = $true
                                WriteDefSDAccessHTM $newObjectDefSD $strObjectClassName $strColorTemp $strFileDefSDHTA $strFileDefSDHTM $bolOUHeader $bolReplMeta $strVersion $strLastChangeDate $chkBoxEffectiveRightsColor.IsChecked $bolCompare
                            }
                            else
                            {
                                $bolOUHeader = $false
                                WriteDefSDAccessHTM $newObjectDefSD $strObjectClassName $strColorTemp $strFileDefSDHTA $strFileDefSDHTM $bolOUHeader $bolReplMeta $strVersion $strLastChangeDate $chkBoxEffectiveRightsColor.IsChecked $bolCompare
                            }
                            #Count ACE to not ad a header
                            $intACEcount++        
                        }
                    }
                    $newObjectDefSD = $null
                    #Comare DefaultSecurityDesriptor in template with schema looking for missing ACE's
                    $secFile = New-Object System.DirectoryServices.ActiveDirectorySecurity
                    if($null -ne $strSDDLcol)
                    {
                        $secFile.SetSecurityDescriptorSddlForm($strSDDLcol)
                    }
                    $sdFile = $secFile.GetAccessRules($true, $false, [System.Security.Principal.NTAccount]) 
                    foreach($ObjectDefSDFromFile in $sdFile)
                    {
                        #Check if matchin ACE missing, TRUE until found 
                        $SDMissingResult = $true

                        $ObjectDefSDFile = New-Object PSObject -Property @{ActiveDirectoryRights=$ObjectDefSDFromFile.ActiveDirectoryRights;InheritanceType=$ObjectDefSDFromFile.InheritanceType;ObjectType=$ObjectDefSDFromFile.ObjectType;`
                        InheritedObjectType=$ObjectDefSDFromFile.InheritedObjectType;ObjectFlags=$ObjectDefSDFromFile.ObjectFlags;AccessControlType=$ObjectDefSDFromFile.AccessControlType;IdentityReference=$ObjectDefSDFromFile.IdentityReference;IsInherited=$ObjectDefSDFromFile.IsInherited;`
                        InheritanceFlags=$ObjectDefSDFromFile.InheritanceFlags;PropagationFlags=$ObjectDefSDFromFile.PropagationFlags;Color="Missing"}

                        foreach($ObjectDefSD in $sd)
                        {

                            If (($ObjectDefSD.IdentityReference -eq $ObjectDefSDFile.IdentityReference) -and ($ObjectDefSD.ActiveDirectoryRights -eq $ObjectDefSDFile.ActiveDirectoryRights) -and ($ObjectDefSD.AccessControlType -eq $ObjectDefSDFile.AccessControlType) -and ($ObjectDefSD.ObjectType -eq $ObjectDefSDFile.ObjectType) -and ($ObjectDefSD.InheritanceType -eq $ObjectDefSDFile.InheritanceType) -and ($ObjectDefSD.InheritedObjectType -eq $ObjectDefSDFile.InheritedObjectType))
		 		            {
					            $SDMissingResult = $false
		 		            }
                        }
                        if ($SDMissingResult)
                        {
                            #Missig´ng color "Red"
                            $strColorTemp = 3
                            #If first ACE add header
                            if ($intACEcount -eq 0)
				 	        {
                                #Indicate that a defaultsecuritydescriptor was found
                                $intNumberofDefSDFound++
                                $bolOUHeader = $true
                                WriteDefSDAccessHTM $ObjectDefSDFile $strObjectClassName $strColorTemp $strFileDefSDHTA $strFileDefSDHTM $bolOUHeader $bolReplMeta $strVersion $strLastChangeDate $chkBoxEffectiveRightsColor.IsChecked $bolCompare
                            }
                            else
                            {
                                $bolOUHeader = $false
                                WriteDefSDAccessHTM $ObjectDefSDFile $strObjectClassName $strColorTemp $strFileDefSDHTA $strFileDefSDHTM $bolOUHeader $bolReplMeta $strVersion $strLastChangeDate $chkBoxEffectiveRightsColor.IsChecked $bolCompare
                            }
                            #Count ACE to not ad a header
                            $intACEcount++
                        }
                    }
                    $secFile = $null
                    $sdFile = $null
                    $ObjectDefSDFile = $null
                    $ObjectDefSDFromFile = $null
                    $ObjectDefSD = $null
                    $sd = $null
                    $sec = $null
                }#End matchin SDDL
            }#End matching object name
            $index++
        }#End while 
        #Check if the schema object does not exist in template
        if($ObjectMatchResult -eq $false)
        {
            $sd = ""
            #Create ad security object
            $sec = New-Object System.DirectoryServices.ActiveDirectorySecurity
            if($null -ne $entry.Attributes.defaultsecuritydescriptor)
            {
                $sec.SetSecurityDescriptorSddlForm($entry.Attributes.defaultsecuritydescriptor[0])
            }
            $sd = $sec.GetAccessRules($true, $false, [System.Security.Principal.NTAccount]) 
            #Count ACE for applying header on fist
            $intACEcount = 0
            foreach($ObjectDefSD in $sd)
            {

                $newObjectDefSD = New-Object PSObject -Property @{ActiveDirectoryRights=$ObjectDefSD.ActiveDirectoryRights;InheritanceType=$ObjectDefSD.InheritanceType;ObjectType=$ObjectDefSD.ObjectType;`
                InheritedObjectType=$ObjectDefSD.InheritedObjectType;ObjectFlags=$ObjectDefSD.ObjectFlags;AccessControlType=$ObjectDefSD.AccessControlType;IdentityReference=$ObjectDefSD.IdentityReference;IsInherited=$ObjectDefSD.IsInherited;`
                InheritanceFlags=$ObjectDefSD.InheritanceFlags;PropagationFlags=$ObjectDefSD.PropagationFlags;Color="Missing in file"}

                #Matching color "green"
                $strColorTemp = 5
                #If first ACE add header
                if ($intACEcount -eq 0)
			    {
                    $bolOUHeader = $true
                    #Indicate that a defaultsecuritydescriptor was found
                    $intNumberofDefSDFound++
                    WriteDefSDAccessHTM $newObjectDefSD $strObjectClassName $strColorTemp $strFileDefSDHTA $strFileDefSDHTM $bolOUHeader $bolReplMeta $strVersion $strLastChangeDate $chkBoxEffectiveRightsColor.IsChecked $bolCompare
                }
                else
                {
                    $bolOUHeader = $false
                    WriteDefSDAccessHTM $newObjectDefSD $strObjectClassName $strColorTemp $strFileDefSDHTA $strFileDefSDHTM $bolOUHeader $bolReplMeta $strVersion $strLastChangeDate $chkBoxEffectiveRightsColor.IsChecked $bolCompare
                }
                #Count ACE to not ad a header
                $intACEcount++
            }
            $newObjectDefSD = $null
            $sd = $null    
        }

    }#End foreach
    if($pageSize -gt 0) 
    {
        if ($prrc.Cookie.Length -eq 0)
        {
            #last page --> we're done
            break;
        }
        #pass the search cookie back to server in next paged request
        $pagedRqc.Cookie = $prrc.Cookie;
    }
    else
    {
        #exit the processing for non-paged search
        break;
    }
}#End While
if (($PSVersionTable.PSVersion -ne "2.0") -and ($global:bolProgressBar))
{
    $global:ProgressBarWindow.Window.Dispatcher.invoke([action]{$global:ProgressBarWindow.Window.Close()},"Normal")
    $ProgressBarWindow = $null
    Remove-Variable -Name "ProgressBarWindow" -Scope Global
} 

if($intNumberofDefSDFound  -gt 0)
{
    Invoke-Item $strFileDefSDHTA 
}
else
{
    $global:observableCollection.Insert(0,(LogMessage -strMessage "No defaultsecuritydescriptor found!" -strType "Error" -DateStamp ))
}
}
#==========================================================================
# Function		: Write-DefaultSDCSV
# Arguments     : string ObjectClass
# Returns   	: 
# Description   : Write the default Security Descriptor to a CSV
#==========================================================================
Function Write-DefaultSDCSV
{
    Param( [string] $fileout,
    $strObjectClass="*")

#Number of columns in CSV import
$strCSVHeaderDefsd = @"
"Name","distinguishedName","Version","ModifiedDate","SDDL"
"@


If ((Test-Path $fileout) -eq $true)
{
    Remove-Item $fileout
}

$strCSVHeaderDefsd | Out-File -FilePath $fileout

$PageSize=100
$TimeoutSeconds = 120

$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($global:strDC, $global:CREDS)
$LDAPConnection.SessionOptions.ReferralChasing = "None"
$request = New-Object System.directoryServices.Protocols.SearchRequest($global:SchemaDN, "(&(objectClass=classSchema)(name=$strObjectClass))", "Subtree")
[System.DirectoryServices.Protocols.PageResultRequestControl]$pagedRqc = new-object System.DirectoryServices.Protocols.PageResultRequestControl($pageSize)
$request.Controls.Add($pagedRqc) | Out-Null
[void]$request.Attributes.Add("defaultsecuritydescriptor")
[void]$request.Attributes.Add("name")
[void]$request.Attributes.Add("distinguishedname")
[void]$request.Attributes.Add("msds-replattributemetadata")
while ($true)
{
    $response = $LdapConnection.SendRequest($request, (new-object System.Timespan(0,0,$TimeoutSeconds))) -as [System.DirectoryServices.Protocols.SearchResponse];
                
    #for paged search, the response for paged search result control - we will need a cookie from result later
    if($pageSize -gt 0) {
        [System.DirectoryServices.Protocols.PageResultResponseControl] $prrc=$null;
        if ($response.Controls.Length -gt 0)
        {
            foreach ($ctrl in $response.Controls)
            {
                if ($ctrl -is [System.DirectoryServices.Protocols.PageResultResponseControl])
                {
                    $prrc = $ctrl;
                    break;
                }
            }
        }
        if($null -eq $prrc) {
            #server was unable to process paged search
            throw "Find-LdapObject: Server failed to return paged response for request $SearchFilter"
        }
    }
    #now process the returned list of distinguishedNames and fetch required properties using ranged retrieval

    foreach ($entry  in $response.Entries)
    {
        $index = 0
        while($index -le $entry.attributes.'msds-replattributemetadata'.count -1) 
        {
            $childMember = $entry.attributes.'msds-replattributemetadata'[$index]
            $childMember = $childMember.replace("$($childMember[-1])","")
            If ($([xml]$childMember).DS_REPL_ATTR_META_DATA.pszAttributeName -eq "defaultSecurityDescriptor")
            {
                $strLastChangeDate = $([xml]$childMember).DS_REPL_ATTR_META_DATA.ftimeLastOriginatingChange
                $strVersion = $([xml]$childMember).DS_REPL_ATTR_META_DATA.dwVersion
                if ($strLastChangeDate -eq $nul)
                {
                    $strLastChangeDate = $(get-date "1601-01-01" -UFormat "%Y-%m-%d %H:%M:%S")
     
                }
                else
                {
                $strLastChangeDate = $(get-date $strLastChangeDate -UFormat "%Y-%m-%d %H:%M:%S")
                }             
            }
            $index++
        }   

        $strSDDL = ""
        if($null -ne $entry.Attributes.defaultsecuritydescriptor)
        {
            $strSDDL = $entry.Attributes.defaultsecuritydescriptor[0]
        }            
        $strName = $entry.Attributes.name[0]
        $strDistinguishedName = $entry.Attributes.distinguishedname[0]

        #Write to file
        [char]34+$strName+[char]34+","+[char]34+`
        $strDistinguishedName+[char]34+","+[char]34+`
        $strVersion+[char]34+","+[char]34+`
        $strLastChangeDate+[char]34+","+[char]34+`
        $strSDDL+[char]34 | Out-File -Append -FilePath $fileout 

    
    }

    if($pageSize -gt 0) 
    {
        if ($prrc.Cookie.Length -eq 0)
        {
            #last page --> we're done
            break;
        }
        #pass the search cookie back to server in next paged request
        $pagedRqc.Cookie = $prrc.Cookie;
    }
    else
    {
        #exit the processing for non-paged search
        break;
    }
}#End While
$global:observableCollection.Insert(0,(LogMessage -strMessage "Report saved in $fileout" -strType "Warning" -DateStamp ))

}
#==========================================================================
# Function		: GetEffectiveRightSP
# Arguments     : 
# Returns   	: 
# Description   : Rs
#==========================================================================
Function GetEffectiveRightSP
{
    param([string] $strPrincipal,
[string] $strDomainDistinguishedName
)
$global:strEffectiveRightSP = ""
$global:strEffectiveRightAccount = ""
$global:strSPNobjectClass = ""
$global:strPrincipalDN = ""
$strPrinName = ""

if ($global:strPrinDomDir -eq 2)
{
    &{#Try

    $Script:CredsExt = $host.ui.PromptForCredential("Need credentials", "Please enter your user name and password.", "", "$global:strPrinDomFlat")
    $ADACLGui.Window.Activate()
    }
    Trap [SystemException]
    {
    continue
    }
    $h =  (get-process -id $global:myPID).MainWindowHandle # just one notepad must be opened!
    [SFW]::SetForegroundWindow($h)
    if($null -ne $Script:CredsExt.UserName)
    {
        if (TestCreds $CredsExt)
        {    
            $global:strPinDomDC = $(GetDomainController $global:strDomainPrinDNName $true $Script:CredsExt)
            $global:strPrincipalDN = (GetSecPrinDN $strPrincipal $global:strPinDomDC $true $Script:CredsExt)
         }
         else
         {
             $global:observableCollection.Insert(0,(LogMessage -strMessage "Bad user name or password!" -strType "Error" -DateStamp ))
             $lblEffectiveSelUser.Content = ""
         }
     }
     else
     {
        $global:observableCollection.Insert(0,(LogMessage -strMessage "Faild to insert credentials!" -strType "Error" -DateStamp ))

     }
}
else
{
    if ( $global:strDomainPrinDNName -eq $global:strDomainDNName )
    {
        $lblSelectPrincipalDom.Content = $global:strDomainShortName+":"
        $global:strPinDomDC = $global:strDC
        $global:strPrincipalDN = (GetSecPrinDN $strPrincipal $global:strPinDomDC $false)
    }
    else
    {
        $global:strPinDomDC = $(GetDomainController $global:strDomainPrinDNName $false)
        $global:strPrincipalDN = (GetSecPrinDN $strPrincipal $global:strPinDomDC $false)
    }
}
if ($global:strPrincipalDN -eq "")
{
    $global:observableCollection.Insert(0,(LogMessage -strMessage "Could not find $strPrincipal!" -strType "Error" -DateStamp ))
    $lblEffectiveSelUser.Content = ""
}
else
{
    $global:strEffectiveRightAccount = $strPrincipal
    $global:observableCollection.Insert(0,(LogMessage -strMessage "Found security principal" -strType "Info" -DateStamp ))
    if ($global:strPrinDomDir -eq 2)
    {
        [System.Collections.ArrayList] $global:tokens = @(GetTokenGroups $global:strPinDomDC $global:strPrincipalDN $true $Script:CredsExt)
                $objADPrinipal = new-object DirectoryServices.DirectoryEntry("LDAP://$global:strPinDomDC/$global:strPrincipalDN",$Script:CredsExt.UserName,$Script:CredsExt.GetNetworkCredential().Password)

        
        $objADPrinipal.psbase.RefreshCache("msDS-PrincipalName")        $strPrinName = $($objADPrinipal.psbase.Properties.Item("msDS-PrincipalName"))        $global:strSPNobjectClass = $($objADPrinipal.psbase.Properties.Item("objectClass"))[$($objADPrinipal.psbase.Properties.Item("objectClass")).count-1]        if (($strPrinName -eq "") -or ($null -eq $strPrinName))        {            $strPrinName = "$global:strPrinDomFlat\$($objADPrinipal.psbase.Properties.Item("samAccountName"))"        }        $global:strEffectiveRightSP = $strPrinName        $global:tokens.Add($strPrinName)
        $lblEffectiveSelUser.Content = $strPrinName    
    }
    else
    {
        [System.Collections.ArrayList] $global:tokens = @(GetTokenGroups $global:strPinDomDC $global:strPrincipalDN $false)
        

        $objADPrinipal = new-object DirectoryServices.DirectoryEntry("LDAP://$global:strPinDomDC/$global:strPrincipalDN")

                    
        $objADPrinipal.psbase.RefreshCache("msDS-PrincipalName")        $strPrinName = $($objADPrinipal.psbase.Properties.Item("msDS-PrincipalName"))        $global:strSPNobjectClass = $($objADPrinipal.psbase.Properties.Item("objectClass"))[$($objADPrinipal.psbase.Properties.Item("objectClass")).count-1]        if (($strPrinName -eq "") -or ($null -eq $strPrinName))        {            $strPrinName = "$global:strPrinDomFlat\$($objADPrinipal.psbase.Properties.Item("samAccountName"))"        }        $global:strEffectiveRightSP = $strPrinName        $global:tokens.Add($strPrinName)
        $lblEffectiveSelUser.Content = $strPrinName
    }

}

}



function LoadProgressBar
{
$global:ProgressBarWindow = [hashtable]::Synchronized(@{})
$newRunspace =[runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"          
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("global:ProgressBarWindow",$global:ProgressBarWindow)          
$psCmd = [PowerShell]::Create().AddScript({   
    [xml]$xamlProgressBar = @"
<Window x:Class="WpfApplication1.StatusBar"
         xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="Window" Title="Scanning..." WindowStartupLocation = "CenterScreen"
        Width = "350" Height = "150" ShowInTaskbar = "False" ResizeMode="NoResize" WindowStyle="ToolWindow" Opacity="0.9" Background="#FF165081" >
    <Grid>
        <StackPanel >
            <Label x:Name="lblProgressBarInfo" Foreground="white" Content="Currently scanning 0 of 0 objects" HorizontalAlignment="Center" Margin="10,20,0,0"  FontWeight="Bold" FontSize="14"/>
            <ProgressBar  x:Name = "ProgressBar" HorizontalAlignment="Left" Height="23" Margin="10,0,0,0" VerticalAlignment="Top" Width="320"   >
                <ProgressBar.Foreground>
                    <LinearGradientBrush EndPoint="1,0.5" StartPoint="0,0.5">
                        <GradientStop Color="#FF237026"/>
                        <GradientStop Color="#FF0BF815" Offset="1"/>
                        <GradientStop Color="#FF0BF815" Offset="1"/>
                    </LinearGradientBrush>
                </ProgressBar.Foreground>
            </ProgressBar>
        </StackPanel>

    </Grid>
</Window>
"@
 
$xamlProgressBar.Window.RemoveAttribute("x:Class")  
    $reader=(New-Object System.Xml.XmlNodeReader $xamlProgressBar)
    $global:ProgressBarWindow.Window=[Windows.Markup.XamlReader]::Load( $reader )
    $global:ProgressBarWindow.lblProgressBarInfo = $global:ProgressBarWindow.window.FindName("lblProgressBarInfo")
    $global:ProgressBarWindow.ProgressBar = $global:ProgressBarWindow.window.FindName("ProgressBar")
    $global:ProgressBarWindow.ProgressBar.Value = 0
    $global:ProgressBarWindow.Window.ShowDialog() | Out-Null
    $global:ProgressBarWindow.Error = $Error
})
$psCmd.Runspace = $newRunspace

[void]$psCmd.BeginInvoke()



}
Function Update-ProgressBar
{
Param ($txtlabel,$valProgress)

        &{#Try
           $global:ProgressBarWindow.ProgressBar.Dispatcher.invoke([action]{ $global:ProgressBarWindow.lblProgressBarInfo.Content = $txtlabel;$global:ProgressBarWindow.ProgressBar.Value = $valProgress},"Normal")
           
        }
        Trap [SystemException]
        {
            $global:observableCollection.Insert(0,(LogMessage -strMessage "Progressbar Failed!" -strType "Error" -DateStamp ))
           
        }

}




#Number of columns in CSV import
$strCSVHeader = @"
"OU","ObjectClass","IdentityReference","ActiveDirectoryRights","InheritanceType","ObjectType","InheritedObjectType","ObjectFlags","AccessControlType","IsInherited","InheritanceFlags","PropagationFlags","SDDate","InvocationID","OrgUSN","LegendText"
"@

$global:myPID = $PID
$global:csvHistACLs = New-Object System.Collections.ArrayList
$CurrentFSPath = split-path -parent $MyInvocation.MyCommand.Path
$strLastCacheGuidsDom = ""
$sd = ""
$global:intObjeComputer = 0


[void][Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.Protocols")
[void]$ADACLGui.Window.ShowDialog()