﻿param( [string] $auditlist)

function End-Script 
{
   param
   (
     [bool]
     $failure
   )

	if ($failure -eq $true)
	{
		Read-Host 'The diagnostic was unsuccessful. Please press any key to exit.';
		exit;
	}
	else
	{
		$Action = Read-Host 'The diagnostic was successful! Would you like to open the log file? (Y/N)';
		if ($action -eq 'Y')
		{
			Invoke-Item $Filename;
		}
		
		exit;
	}
	
}

if ($auditlist -eq ''){
	Write-Host 'No list specified, using Localhost'
	$targets = 'localhost'
}
else
{
	if ((Test-Path $auditlist) -eq $false)
	{
		Write-Host "Invalid audit path specified: $auditlist"
		exit
	}
	else
	{
		Write-Host "Using Audit list: $auditlist"
		$Targets = Get-Content $auditlist
	}
}

$Date = Get-Date

Foreach ($Target in $Targets)
{
	$Filename = 'C:\windows\temp\' + $Target + '_' + $date.Hour + $date.Minute + '_' + $Date.Day + '-' + $Date.Month + '-' + $Date.Year + '.htm'

	# =====================================================================================================================
	#	CREATE HTML OUTPUT
	# =====================================================================================================================
	
	Write-Output ' '| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '<html ES_auditInitialized='false'><head><title>Audit</title>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "<META http-equiv=Content-Type content='text/html; charset=windows-1252'>"| out-file -Append -encoding ASCII -filepath $Filename
	
	# ---------- Start of Style Definition Section ------------------------------------------------------------------------
	
	Write-Output '<STYLE type=text/css>'| out-file -Append -encoding ASCII -filepath $Filename
		
	Write-Output '	DIV .expando {DISPLAY: block; FONT-WEIGHT: normal; FONT-SIZE: 8pt; RIGHT: 10px; COLOR: #ffffff; FONT-FAMILY: Tahoma; POSITION: absolute; TEXT-DECORATION: underline}'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	TABLE {TABLE-LAYOUT: fixed; FONT-SIZE: 100%; WIDTH: 100%}'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	#objshowhide {PADDING-RIGHT: 10px; FONT-WEIGHT: bold; FONT-SIZE: 8pt; Z-INDEX: 2; CURSOR: hand; COLOR: #000000; MARGIN-RIGHT: 0px; FONT-FAMILY: Tahoma; TEXT-ALIGN: right; TEXT-DECORATION: underline; WORD-WRAP: normal}'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	.heading0_expanded {BORDER-RIGHT: #bbbbbb 1px solid; PADDING-RIGHT: 5em; BORDER-TOP: #bbbbbb 1px solid; DISPLAY: block; PADDING-LEFT: 8px; FONT-WEIGHT: bold; FONT-SIZE: 8pt; MARGIN-BOTTOM: -1px; MARGIN-LEFT: 0px; BORDER-LEFT: #bbbbbb 1px solid; WIDTH: 100%; CURSOR: hand; COLOR: #FFFFFF; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: #bbbbbb 1px solid; FONT-FAMILY: Tahoma; POSITION: relative; HEIGHT: 2.25em; BACKGROUND-COLOR: #cc0000}'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	.heading1 {BORDER-RIGHT: #bbbbbb 1px solid; PADDING-RIGHT: 5em; BORDER-TOP: #bbbbbb 1px solid; DISPLAY: block; PADDING-LEFT: 16px; FONT-WEIGHT: bold; FONT-SIZE: 8pt; MARGIN-BOTTOM: -1px; MARGIN-LEFT: 5px; BORDER-LEFT: #bbbbbb 1px solid; WIDTH: 100%; CURSOR: hand; COLOR: #ffffff; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: #bbbbbb 1px solid; FONT-FAMILY: Tahoma; POSITION: relative; HEIGHT: 2.25em; BACKGROUND-COLOR: #7BA7C7}'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	.heading2 {BORDER-RIGHT: #bbbbbb 1px solid; PADDING-RIGHT: 5em; BORDER-TOP: #bbbbbb 1px solid; DISPLAY: block; PADDING-LEFT: 16px; FONT-WEIGHT: bold; FONT-SIZE: 8pt; MARGIN-BOTTOM: -1px; MARGIN-LEFT: 5px; BORDER-LEFT: #bbbbbb 1px solid; WIDTH: 100%; CURSOR: hand; COLOR: #ffffff; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: #bbbbbb 1px solid; FONT-FAMILY: Tahoma; POSITION: relative; HEIGHT: 2.25em; BACKGROUND-COLOR: #A5A5A5}'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	.tableDetail {BORDER-RIGHT: #bbbbbb 1px solid; BORDER-TOP: #bbbbbb 1px solid; DISPLAY: block; PADDING-LEFT: 16px; FONT-SIZE: 8pt;MARGIN-BOTTOM: -1px; PADDING-BOTTOM: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #bbbbbb 1px solid; WIDTH: 100%; COLOR: #000000; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: #bbbbbb 1px solid; FONT-FAMILY: Tahoma; POSITION: relative; BACKGROUND-COLOR: #f9f9f9}'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	.filler {BORDER-RIGHT: medium none; BORDER-TOP: medium none; DISPLAY: block; BACKGROUND: none transparent scroll repeat 0% 0%; MARGIN-BOTTOM: -1px; FONT: 100%/8px Tahoma; MARGIN-LEFT: 43px; BORDER-LEFT: medium none; COLOR: #ffffff; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: medium none; POSITION: relative}'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	.Solidfiller {BORDER-RIGHT: medium none; BORDER-TOP: medium none; DISPLAY: block; BACKGROUND: none transparent scroll repeat 0% 0%; MARGIN-BOTTOM: -1px; FONT: 100%/8px Tahoma; MARGIN-LEFT: 0px; BORDER-LEFT: medium none; COLOR: #000000; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: medium none; POSITION: relative; BACKGROUND-COLOR: #000000}'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	td {VERTICAL-ALIGN: TOP; FONT-FAMILY: Tahoma}'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	th {VERTICAL-ALIGN: TOP; COLOR: #cc0000; TEXT-ALIGN: left}'| out-file -Append -encoding ASCII -filepath $Filename
	
	Write-Output '</STYLE>'| out-file -Append -encoding ASCII -filepath $Filename
	
	# ---------- End of Style Definition Section --------------------------------------------------------------------------
	# ---------- Start of Control Script Section --------------------------------------------------------------------------
	
	Write-Output '<SCRIPT language=vbscript>'| out-file -Append -encoding ASCII -filepath $Filename
	
	# ---------- Declare Global Variables for Routines --------------------------------------------------------------------
	
	Write-Output '	strShowHide = 1'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	strShow = "show"'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	strHide = "hide"'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	strShowAll = "show all"'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	strHideAll = "hide all"'| out-file -Append -encoding ASCII -filepath $Filename
	
	Write-Output 'Function window_onload()'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	If UCase(document.documentElement.getAttribute("ES_auditInitialized")) <> "TRUE" Then'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		Set objBody = document.body.all'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		For Each obji in objBody'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			If IsSectionHeader(obji) Then'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				If IsSectionExpandedByDefault(obji) Then'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '					ShowSection obji'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				Else'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '					HideSection obji'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				End If'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			End If'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		Next'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		objshowhide.innerText = strShowAll'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		document.documentElement.setAttribute "ES_auditInitialized", "true"'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	End If'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output 'End Function'| out-file -Append -encoding ASCII -filepath $Filename
	
	Write-Output 'Function IsSectionExpandedByDefault(objHeader)'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	IsSectionExpandedByDefault = (Right(objHeader.className, Len("_expanded")) = "_expanded")'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output 'End Function'| out-file -Append -encoding ASCII -filepath $Filename
	
	Write-Output 'Function document_onclick()'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	Set strsrc = window.event.srcElement'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	While (strsrc.className = "sectionTitle" or strsrc.className = "expando")'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		Set strsrc = strsrc.parentElement'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	Wend'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	If Not IsSectionHeader(strsrc) Then Exit Function'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	ToggleSection strsrc'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	window.event.returnValue = False'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output 'End Function'| out-file -Append -encoding ASCII -filepath $Filename
	
	Write-Output 'Sub ToggleSection(objHeader)'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	SetSectionState objHeader, "toggle"'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output 'End Sub'| out-file -Append -encoding ASCII -filepath $Filename
	
	Write-Output 'Sub SetSectionState(objHeader, strState)'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	i = objHeader.sourceIndex'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	Set all = objHeader.parentElement.document.all'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	While (all(i).className <> "container")'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		i = i + 1'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	Wend'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	Set objContainer = all(i)'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	If strState = "toggle" Then'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		If objContainer.style.display = "none" Then'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			SetSectionState objHeader, "show" '| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		Else'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			SetSectionState objHeader, "hide" '| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		End If'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	Else'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		Set objExpando = objHeader.children.item(1)'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		If strState = "show" Then'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			objContainer.style.display = "block" '| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			objExpando.innerText = strHide'| out-file -Append -encoding ASCII -filepath $Filename
	
	Write-Output '		ElseIf strState = "hide" Then'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			objContainer.style.display = "none" '| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			objExpando.innerText = strShow'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		End If'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	End If'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output 'End Sub'| out-file -Append -encoding ASCII -filepath $Filename
	
	Write-Output 'Function objshowhide_onClick()'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	Set objBody = document.body.all'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	Select Case strShowHide'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		Case 0'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			strShowHide = 1'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			objshowhide.innerText = strShowAll'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			For Each obji In objBody'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				If IsSectionHeader(obji) Then'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '					HideSection obji'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				End If'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			Next'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		Case 1'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			strShowHide = 0'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			objshowhide.innerText = strHideAll'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			For Each obji In objBody'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				If IsSectionHeader(obji) Then'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '					ShowSection obji'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				End If'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			Next'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	End Select'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output 'End Function'| out-file -Append -encoding ASCII -filepath $Filename
	
	Write-Output 'Function IsSectionHeader(obj) : IsSectionHeader = (obj.className = "heading0_expanded") Or (obj.className = "heading1_expanded") Or (obj.className = "heading1") Or (obj.className = "heading2"): End Function'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output 'Sub HideSection(objHeader) : SetSectionState objHeader, "hide" : End Sub'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output 'Sub ShowSection(objHeader) : SetSectionState objHeader, "show": End Sub'| out-file -Append -encoding ASCII -filepath $Filename
	
	Write-Output '</SCRIPT>'| out-file -Append -encoding ASCII -filepath $Filename
	
	# ---------- End of Control Script Section ----------------------------------------------------------------------------
	
	Write-Output '	</HEAD>'| out-file -Append -encoding ASCII -filepath $Filename
	
	# ---------- End of Head Section --------------------------------------------------------------------------------------
	
	# ---------- Start of Body Section ------------------------------------------------------------------------------------
	
	
	Write-Output '<BODY>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	<p><b><font face="Arial" size="5">'$Target' Audit<hr size="8" color="#CC0000"></font></b>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	<font face="Arial" size="1"><b><i>Version 1.0 by Phillip Marshall</i></b></font><br>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	<font face="Arial" size="1">Report generated on ' (Get-Date) '</font></p>'| out-file -Append -encoding ASCII -filepath $Filename
	
	Write-Output '<TABLE cellSpacing=0 cellPadding=0>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	<TBODY>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<TR>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<TD>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<DIV id=objshowhide tabIndex=0><FONT face=Arial></FONT></DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			</TD>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</TR>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	</TBODY>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '</TABLE>'| out-file -Append -encoding ASCII -filepath $Filename

	write-output "Writing Detail for $Target"
	$ComputerSystem = Get-WmiObject -computername $Target Win32_ComputerSystem
	switch ($ComputerSystem.DomainRole)
	{
		0 { $ComputerRole = 'Standalone Workstation' }
		1 { $ComputerRole = 'Member Workstation' }
		2 { $ComputerRole = 'Standalone Server' }
		3 { $ComputerRole = 'Member Server' }
		4 { $ComputerRole = 'Domain Controller' }
		5 { $ComputerRole = 'Domain Controller' }
		default { $ComputerRole = 'Information not available' }
	}
	
	$OperatingSystems = Get-WmiObject -computername $Target Win32_OperatingSystem
	$TimeZone = Get-WmiObject -computername $Target Win32_Timezone
	$Keyboards = Get-WmiObject -computername $Target Win32_Keyboard
	$SchedTasks = Get-WmiObject -computername $Target Win32_ScheduledJob
	
	$BootINI = $OperatingSystems.SystemDrive + 'boot.ini'
	
	$RecoveryOptions = Get-WmiObject -computername $Target Win32_OSRecoveryConfiguration
	
	# ---------- Start of COMPUTER DETAILS Section HTML Code --------------------------------------------------------------
	
	Write-Output '<DIV class=heading0_expanded>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "	<SPAN class=sectionTitle tabIndex=0>$target Details</SPAN>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "	<A class=expando href='#'></A>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '<DIV class=filler></DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	
	# ---------- Start of COMPUTER DETAILS - GENERAL Sub Section HTML Code ------------------------------------------------
	write-output '..Computer Details'
	
	Write-Output '<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	<DIV class=heading1>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<SPAN class=sectionTitle tabIndex=0>General</SPAN>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "		<A class=expando href='#'></A>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=tableDetail>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<th width='25%'><b>Computer Name</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<td width='75%'> " $ComputerSystem.Name '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<th width='25%'><b>Computer Role</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<td width='75%'> $ComputerRole </font></td>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	
	switch ($ComputerRole)
	{
		'Member Workstation' { Write-Output "					<th width='25%'><b>Computer Domain</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename	}
		'Domain Controller' { Write-Output "					<th width='25%'><b>Computer Domain</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename	 }
		'Member Server' { Write-Output "					<th width='25%'><b>Computer Domain</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename	 }
		default { Write-Output "					<th width='25%'><b>Computer Workgroup</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename}
	}
	
	Write-Output "					<td width='75%'>" $ComputerSystem.Domain '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<th width='25%'><b>Operating System</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<td width='75%'>" $OperatingSystems.Caption '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<th width='25%'><b>Service Pack</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<td width='75%'>" $OperatingSystems.CSDVersion '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<th width='25%'><b>System Root</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<td width='75%'>" $OperatingSystems.SystemDrive '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<th width='25%'><b>Manufacturer</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<td width='75%'>" $ComputerSystem.Manufacturer '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 				</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<th width='25%'><b>Model</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<td width='75%'>" $ComputerSystem.Model '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 				</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<th width='25%'><b>Number of Processors</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<td width='75%'>" $ComputerSystem.NumberOfProcessors '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 				</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<th width='25%'><b>Memory</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<td width='75%'>" $ComputerSystem.TotalPhysicalMemory '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 				</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<th width='25%'><b>Registered User</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<td width='75%'>" $ComputerSystem.PrimaryOwnerName '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 				</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 				<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<th width='25%'><b>Registered Organisation</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "					<td width='75%'>" $OperatingSystems.Organization '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '  				<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "   				<th width='25%'><b>Last System Boot</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	$LBTime=$OperatingSystems.ConvertToDateTime($OperatingSystems.Lastbootuptime)
	Write-Output "					<td width='75%'>" $LBTime '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			</TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	<DIV class=filler></DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	
	#---------- End of COMPUTER DETAILS - GENERAL Sub-section HTML Code --------------------------------------------------
	
	# ---------- Start of COMPUTER DETAILS - HOFIXES Sub-section HTML Code ------------------------------------------------
	
	write-output '..Hotfix Information'
	
	$colQuickFixes = Get-WmiObject Win32_QuickFixEngineering
	
	Write-Output '	<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=heading1>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<SPAN class=sectionTitle tabIndex=0>HotFixes</SPAN>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "			<A class=expando href='#'></A>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<DIV class=tableDetail>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "  						<th width='25%'><b>HotFix Number</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "  						<th width='75%'><b>Description</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
}	
	ForEach ($objQuickFix in $colQuickFixes)
	{
		if ($objQuickFix.HotFixID -ne 'File 1')
		{
			Write-Output '				<tr>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "					<td width='25%'>" $objQuickFix.HotFixID '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "					<td width='75%'>" $objQuickFix.Description '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output '				</tr>'| out-file -Append -encoding ASCII -filepath $Filename
		}
	}
	Write-Output '				</TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	<DIV class=filler></DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	
	#---------- End of COMPUTER DETAILS - HOFIXES Sub-section HTML Code --------------------------------------------------
	
	#---------- Start of COMPUTER DETAILS - LOGICAL DISK CONFIGURATION Sub-section HTML Code -----------------------------
	
	write-output '..Logical Disks'
	
	$colDisks = Get-WmiObject -ComputerName $Target Win32_LogicalDisk
	
	Write-Output '	<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=heading1>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<SPAN class=sectionTitle tabIndex=0>Logical Disk Configuration</SPAN>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "			<A class=expando href='#'></A>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<DIV class=tableDetail>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "  						<th width='15%'><b>Drive Letter</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "  						<th width='20%'><b>Label</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "  						<th width='20%'><b>File System</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "  						<th width='15%'><b>Disk Size</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "  						<th width='15%'><b>Disk Free Space</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "  						<th width='15%'><b>% Free Space</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '  					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	
	Foreach ($objDisk in $colDisks)
	{
		if ($objDisk.DriveType -eq 3)
		{
			Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "						<td width='15%'>"$objDisk.DeviceID'</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output " 						<td width='20%'>"$objDisk.VolumeName'</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output " 						<td width='20%'>"$objDisk.FileSystem'</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			$disksize = [math]::round(($objDisk.size / 1048576))
			Write-Output " 						<td width='15%'>"$disksize" MB</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
			$freespace = [math]::round(($objDisk.FreeSpace / 1048576))
			Write-Output " 						<td width='15%'>"$Freespace" MB</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
			$percFreespace=[math]::round(((($objDisk.FreeSpace / 1048576)/($objDisk.Size / 1048676)) * 100),0)
			Write-Output " 						<td width='15%'>"$percFreespace" %</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output '					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
		}
	}
	
	Write-Output '				</TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	<DIV class=filler></DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	
	# ---------- End of COMPUTER DETAILS - LOGICAL DISK CONFIGURATION Sub-section HTML Code -------------------------------
	# ---------- Start of COMPUTER DETAILS - NIC CONFIGURATION Sub-section HTML Code --------------------------------------
	
	write-output '..Network Configuration'
	
	$NICCount = 0
	$colAdapters = Get-WmiObject -ComputerName $Target Win32_NetworkAdapterConfiguration
	
	Write-Output '	<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=heading1>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<SPAN class=sectionTitle tabIndex=0>NIC Configuration</SPAN>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "			<A class=expando href='#'></A>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<DIV class=tableDetail>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	
	$NICCount = 0
	Foreach ($objAdapter in $colAdapters)
	{
		if ($objAdapter.IPEnabled -eq 'True')
		{
			$NICCount = $NICCount + 1
			If ($NICCount -gt 1)
			{
				Write-Output '			</TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
				Write-Output '				<DIV class=Solidfiller></DIV>'| out-file -Append -encoding ASCII -filepath $Filename
				Write-Output '			<TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
			}
		Write-Output '  					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "	 					<th width='25%'><b>Description</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "    					<td width='75%'>" $objAdapter.Description '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '  					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '  					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "						<th width='25%'><b>Physical address</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "						<td width='75%'>" $objAdapter.MACaddress '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output ' 					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
		If ($objAdapter.IPAddress -ne $Null)
		{
			Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "						<th width='25%'><b>IP Address / Subnet Mask</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "						<td width='75%'>" $objAdapter.IPAddress ' / ' $objAdapter.IPSubnet '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output '					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output '					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "						<th width='25%'><b>Default Gateway</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "						<td width='75%'>" $objAdapter.DefaultIPGateway '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output '					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
		
		}
		Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "						<th width='25%'><b>DHCP enabled</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
		If ($objAdapter.DHCPEnabled -eq 'True')
		{
			Write-Output "						<td width='75%'>Yes</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
		}
		Else
		{
			Write-Output "						<td width='75%'>No</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
		}
		Write-Output '					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "							<th width='25%'><b>DNS Servers</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "							<td width='75%'>"| out-file -Append -encoding ASCII -filepath $Filename
		If ($objAdapter.DNSServerSearchOrder -ne $Null)
		{
			Write-Output $objAdapter.DNSServerSearchOrder | out-file -Append -encoding ASCII -filepath $Filename
		}
		Write-Output '					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "						<th width='25%'><b>Primary WINS Server</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "						<td width='75%'>" $objAdapter.WINSPrimaryServer '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "						<th width='25%'><b>Secondary WINS Server</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "						<td width='75%'>" $objAdapter.WINSSecondaryServer '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
		$NICCount = $NICCount + 1
		}
	}
	Write-Output '				</TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	<DIV class=filler></DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	
	#---------- End of COMPUTER DETAILS - NIC CONFIGURATION Sub-section HTML Code ----------------------------------------
	
	#---------- Start of COMPUTER DETAILS - Software Sub-section HTML Code -------------------------------------------
	
	if ((get-wmiobject -namespace 'root/cimv2' -list) | Where-Object {$_.name -match 'Win32_Product'})
	{
		write-output '..Installed Software'
	
		$colShares = get-wmiobject -ComputerName $Target Win32_Product | Select-Object Name,Version,Vendor,InstallDate
		
		Write-Output '	<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '		<DIV class=heading1>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '			<SPAN class=sectionTitle tabIndex=0>Software</SPAN>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "			<A class=expando href='#'></A>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '		<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '			<DIV class=tableDetail>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '				<TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "  						<th width='25%'><b>Name</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "  						<th width='25%'><b>Version</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "  						<th width='25%'><b>Vendor</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "  						<th width='25%'><b>Install Date</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
		
		Foreach ($objShare in $colShares)
		{
			Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "						<td width='50%'>" $objShare.Name '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "						<td width='20%'>" $objShare.Version '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "						<td width='15%'>" $objShare.Vendor '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "						<td width='15%'>" $objShare.InstallDate '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output '					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
		}
		Write-Output '				</TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '			</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '	</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '	<DIV class=filler></DIV>'| out-file -Append -encoding ASCII -filepath $Filename
		
	}
	# ---------- End of COMPUTER DETAILS - Software Sub-section HTML Code ---------------------------------------------
	
	#---------- Start of COMPUTER DETAILS - LOCAL SHARES Sub-section HTML Code -------------------------------------------
	
	write-output '..Local Shares'
	
	$colShares = Get-wmiobject -ComputerName $Target Win32_Share
	
	Write-Output '	<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=heading1>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<SPAN class=sectionTitle tabIndex=0>Local Shares</SPAN>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "			<A class=expando href='#'></A>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<DIV class=tableDetail>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "  						<th width='25%'><b>Share</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "  						<th width='25%'><b>Path</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "  						<th width='50%'><b>Comment</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	
	Foreach ($objShare in $colShares)
	{
		Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "						<td width='25%'>" $objShare.Name '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "						<td width='25%'>" $objShare.Path '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "						<td width='50%'>" $objShare.Caption '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	}
	Write-Output '				</TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	<DIV class=filler></DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	
	#---------- End of COMPUTER DETAILS - LOCAL SHARES Sub-section HTML Code ---------------------------------------------
	
	#---------- Start of COMPUTER DETAILS - PRINTERS Sub-section HTML Code -----------------------------------------------
	
	Write-output '..Printers'
	
	$colInstalledPrinters =  Get-WmiObject -ComputerName $Target Win32_Printer
	
	Write-Output '	<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=heading1>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<SPAN class=sectionTitle tabIndex=0>Printers</SPAN>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "			<A class=expando href='#'></A>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<DIV class=tableDetail>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "						<th width='25%'><b>Printer</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "						<th width='25%'><b>Location</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "						<th width='25%'><b>Default Printer</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "						<th width='25%'><b>Portname</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	
	Foreach ($objPrinter in $colInstalledPrinters)
	{
		If ($objPrinter.Name -eq '')
		{
			Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "						<td width='100%'>No Printers Installed</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
		}
		Else
		{
			Write-Output '					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "						<td width='25%'>" $objPrinter.Name '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "						<td width='25%'>" $objPrinter.Location '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			if ($objPrinter.Default -eq 'True')
			{
				Write-Output "						<td width='25%'>Yes</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
			}
			Else
			{
				Write-Output "						<td width='25%'>No</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
			}
			Write-Output "						<td width='25%'>"$objPrinter.Portname'</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
		}
		Write-Output '					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	}
	Write-Output '				</TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	<DIV class=filler></DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	
	#---------- End of COMPUTER DETAILS - PRINTERS Sub-section HTML Code -------------------------------------------------
	
	#---------- Start of COMPUTER DETAILS - SERVICES Sub-section HTML Code -----------------------------------------------
	
	Write-Output '..Services'
	
	$colListOfServices = Get-WmiObject -ComputerName $Target Win32_Service
	
	Write-Output '	<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=heading1>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<SPAN class=sectionTitle tabIndex=0>Services</SPAN>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "			<A class=expando href='#'></A>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<DIV class=tableDetail>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '  					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "	 					<th width='20%'><b>Name</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "	 					<th width='20%'><b>Account</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "	 					<th width='20%'><b>Start Mode</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "	 					<th width='20%'><b>State</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "	 					<th width='20%'><b>Expected State</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '  					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	
	Foreach ($objService in $colListOfServices)
	{
		Write-Output ' 					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "	 					<td width='20%'>"$objService.Caption'</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "	 					<td width='20%'>"$objService.Startname'</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "	 					<td width='20%'>"$objService.StartMode'</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
		If ($objService.StartMode -eq 'Auto')
		{
			if ($objService.State -eq 'Stopped')
			{
				Write-Output "						<td width='20%'><font color='#FF0000'>"$objService.State'</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
				Write-Output "						<td width='25%'><font face='Wingdings'color='#FF0000'>û</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
			}
		}
		If ($objService.StartMode -eq 'Auto')
		{
			if ($objService.State -eq 'Running')
			{
				Write-Output "						<td width='20%'><font color='#009900'>"$objService.State'</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
				Write-Output "						<td width='20%'><font face='Wingdings'color='#009900'>ü</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
			}
		}
		If ($objService.StartMode -eq 'Disabled')
		{
			If ($objService.State -eq 'Running')
			{
				Write-Output "						<td width='20%'><font color='#FF0000'>"$objService.State'</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
				Write-Output "						<td width='25%'><font face='Wingdings'color='#FF0000'>û</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
			}
		}
		If ($objService.StartMode -eq 'Disabled')
		{
			if ($objService.State -eq 'Stopped')
			{
				Write-Output "						<td width='20%'><font color='#009900'>"$objService.State'</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
				Write-Output "						<td width='20%'><font face='Wingdings'color='#009900'>ü</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
			}
		}
		If ($objService.StartMode -eq 'Manual')
		{
			Write-Output "						<td width='20%'><font color='#009900'>"$objService.State'</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "						<td width='20%'><font face='Wingdings'color='#009900'>ü</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
		}
		If ($objService.State -eq 'Paused')
		{
			Write-Output "						<td width='20%'><font color='#FF9933'>"$objService.State'</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "						<td width='20%'><font face='Wingdings'color='#009900'>ü</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
		}
		Write-Output '  					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	}
	Write-Output '				</TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	<DIV class=filler></DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	
	#---------- End of COMPUTER DETAILS - SERVICES Sub-section HTML Code -------------------------------------------------
	
	#---------- Start of COMPUTER DETAILS - REGIONAL SETTINGS Sub-section HTML Code --------------------------------------
	
	Write-Output '..Regional Options'
	
	$ObjKeyboards = Get-WmiObject -ComputerName $Target Win32_Keyboard
	
	Write-Output '	<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=heading1>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<SPAN class=sectionTitle tabIndex=0>Regional Settings</SPAN>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "			<A class=expando href='#'></A>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<DIV class=tableDetail>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "	 					<th width='25%'><b>Time Zone</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "	 					<td width='75%'>" $TimeZone.Description '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "	 					<th width='25%'><b>Country Code</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "	 					<td width='75%'>" $OperatingSystems.Countrycode '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "		 				<th width='25%'><b>Locale</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "		 				<td width='75%'>" $OperatingSystems.Locale'</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "		 				<th width='25%'><b>Operating System Language</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "		 				<td width='75%'>" $OperatingSystems.OSLanguage'</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	
	switch ($ObjKeyboards.Layout)
	{
		'00000402'{ $keyb = 'BG' }
		'00000404'{ $keyb = 'CH' }
		'00000405'{ $keyb = 'CZ' }
		'00000406'{ $keyb = 'DK' }
		'00000407'{ $keyb = 'GR' }
		'00000408'{ $keyb = 'GK' }
		'00000409'{ $keyb = 'US' }
		'0000040A'{ $keyb = 'SP' }
		'0000040B'{ $keyb = 'SU' }
		'0000040C'{ $keyb = 'FR' }
		'0000040E'{ $keyb = 'HU' }
		'0000040F'{ $keyb = 'IS' }
		'00000410'{ $keyb = 'IT' }
		'00000411'{ $keyb = 'JP' }
		'00000412'{ $keyb = 'KO' }
		'00000413'{ $keyb = 'NL' }
		'00000414'{ $keyb = 'NO' }
		'00000415'{ $keyb = 'PL' }
		'00000416'{ $keyb = 'BR' }
		'00000418'{ $keyb = 'RO' }
		'00000419'{ $keyb = 'RU' }
		'0000041A'{ $keyb = 'YU' }
		'0000041B'{ $keyb = 'SL' }
		'0000041C'{ $keyb = 'US' }
		'0000041D'{ $keyb = 'SV' }
		'0000041F'{ $keyb = 'TR' }
		'00000422'{ $keyb = 'US' }
		'00000423'{ $keyb = 'US' }
		'00000424'{ $keyb = 'YU' }
		'00000425'{ $keyb = 'ET' }
		'00000426'{ $keyb = 'US' }
		'00000427'{ $keyb = 'US' }
		'00000804'{ $keyb = 'CH' }
		'00000809'{ $keyb = 'UK' }
		'0000080A'{ $keyb = 'LA' }
		'0000080C'{ $keyb = 'BE' }
		'00000813'{ $keyb = 'BE' }
		'00000816'{ $keyb = 'PO' }
		'00000C0C'{ $keyb = 'CF' }
		'00000C1A'{ $keyb = 'US' }
		'00001009'{ $keyb = 'US' }
		'0000100C'{ $keyb = 'SF' }
		'00001809'{ $keyb = 'US' }
		'00010402'{ $keyb = 'US' }
		'00010405'{ $keyb = 'CZ' }
		'00010407'{ $keyb = 'GR' }
		'00010408'{ $keyb = 'GK' }
		'00010409'{ $keyb = 'DV' }
		'0001040A'{ $keyb = 'SP' }
		'0001040E'{ $keyb = 'HU' }
		'00010410'{ $keyb = 'IT' }
		'00010415'{ $keyb = 'PL' }
		'00010419'{ $keyb = 'RU' }
		'0001041B'{ $keyb = 'SL' }
		'0001041F'{ $keyb = 'TR' }
		'00010426'{ $keyb = 'US' }
		'00010C0C'{ $keyb = 'CF' }
		'00010C1A'{ $keyb = 'US' }
		'00020408'{ $keyb = 'GK' }
		'00020409'{ $keyb = 'US' }
		'00030409'{ $keyb = 'USL' }
		'00040409'{ $keyb = 'USR' }
		'00050408'{ $keyb = 'GK' }
		default { $keyb = 'Unknown' }
	}


	Write-Output "		 				<th width='25%'><b>Keyboard Layout</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "		 				<td width='75%'>" $keyb '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				</TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			</div>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	<DIV class=filler></DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	
	#---------- End of COMPUTER DETAILS - REGIONAL SETTINGS Sub-section HTML Code ----------------------------------------
	#---------- Start of COMPUTER DETAILS - EVENT LOGS Sub-section HTML Code ---------------------------------------------
	Write-Output '	<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=heading1>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<SPAN class=sectionTitle tabIndex=0>Event Logs</SPAN>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "			<A class=expando href='#'></A>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<DIV class=tableDetail>'| out-file -Append -encoding ASCII -filepath $Filename
	
	#---------- Start of COMPUTER DETAILS - EVENT LOGS - EVENT LOG SETTINGS Sub-section HTML Code ------------------------
	
	Write-Output '..Event Log Settings'
	
	$colLogFiles = Get-WmiObject -ComputerName $Target Win32_NTEventLogFile
	
	Write-Output '	<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=heading2>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<SPAN class=sectionTitle tabIndex=0>Event Log Settings</SPAN>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "			<A class=expando href='#'></A>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			<DIV class=tableDetail>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '				<TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '  					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "    					<th width='25%'><b>Log Name</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "    					<th width='25%'><b>Overwrite Outdated Records</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output "  					  	<th width='25%'><b>Maximum Size</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output " 					   	<th width='25%'><b>Current Size</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output ' 					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	ForEach ($objLogFile in $colLogfiles)
	{
		Write-Output ' 					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "	 					<td width='25%'>" $objLogFile.LogFileName '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
		If ($objLogfile.OverWriteOutdated -lt 0)
		{
			Write-Output "	 					<td width='25%'>Never</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
		}
		if ($objLogFile.OverWriteOutdated -eq 0)
		{
			Write-Output "	 					<td width='25%'>As needed</font></td>"| out-file -Append -encoding ASCII -filepath $Filename
		}
		Else
		{
			Write-Output "	 					<td width='25%'>After " $objLogFile.OverWriteOutdated ' days</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
		}
		Write-Output "	 					<td width='25%'>" (($objLogfile.MaxFileSize)/1024) ' KB</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "	 					<td width='25%'>" (($objLogfile.FileSize)/1024) ' KB</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '  					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
	}
	Write-Output '				</TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '			</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	Write-Output '	<DIV class=filler></DIV>'| out-file -Append -encoding ASCII -filepath $Filename
	
	#---------- End of COMPUTER DETAILS - EVENT LOGS - EVENT LOG SETTINGS Sub-section HTML Code --------------------------
	# ---------- Start of COMPUTER DETAILS - EVENT LOGS - ERROR ENTRIES Sub-section HTML Code -----------------------------
	
		write-output '..Event Log Errors'
		
		$WmidtQueryDT = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime([DateTime]::Now.AddDays(-14))
		$colLoggedEvents = Get-WmiObject -computer 'Localhost' -query ("Select * from Win32_NTLogEvent Where Type='Error' and TimeWritten >='" + $WmidtQueryDT + "'")
	
		Write-Output '	<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '		<DIV class=heading2>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '			<SPAN class=sectionTitle tabIndex=0>ERROR Entries</SPAN>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "			<A class=expando href='#'></A>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '		</DIV>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '		<DIV class=container>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '			<DIV class=tableDetail>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '				<TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '  					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "    					<th width='10%'><b>Event Code</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "   					<th width='10%'><b>Source Name</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "    					<th width='15%'><b>Time</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "    					<th width='10%'><b>Log</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output "    					<th width='55%'><b>Message</b></font></th>"| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '  					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
		ForEach ($objEvent in $colLoggedEvents)
		{
			$dtmEventDate = $ObjEvent.ConvertToDateTime($objEvent.TimeWritten)
			Write-Output ' 					<tr>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "	 					<td width='10%'>" $objEvent.EventCode '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "	 					<td width='10%'>" $objEvent.SourceName '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "	 					<td width='15%'>" $dtmEventDate '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "	 					<td width='10%'>" $objEvent.LogFile '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output "	 					<td width='55%'>" $objEvent.Message '</font></td>'| out-file -Append -encoding ASCII -filepath $Filename
			Write-Output '  					</tr>'| out-file -Append -encoding ASCII -filepath $Filename
		}
		Write-Output '				</TABLE>'| out-file -Append -encoding ASCII -filepath $Filename
		Write-Output '			</DIV>' | out-file -Append -encoding ASCII -filepath $Filename


End-Script
		