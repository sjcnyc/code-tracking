<#
.SYNOPSIS
    Simplify data collection and diagnostics for troubleshooting Azure Virtual Desktop issues and a convenient method for submitting and following quick & easy action plans.

.DESCRIPTION
    This script is designed to collect information that will help Microsoft Customer Support Services (CSS) troubleshoot an issue you may be experiencing with Azure Virtual Desktop.
    The collected data may contain Personally Identifiable Information (PII) and/or sensitive data, such as (but not limited to) IP addresses; PC names; and user names.
    The script will save the collected data in a folder and also compress the results into a ZIP file, both in the same location from where the script has been launched.
    This folder and its contents or the ZIP file are not automatically sent to Microsoft.
    You can send the ZIP file to Microsoft CSS using a secure file transfer tool - Please discuss this with your support professional and also any concerns you may have.
    Find our privacy statement here: https://privacy.microsoft.com/en-US/privacystatement

    Run 'Get-Help .\AVD-Collect.ps1 -Full' for more details.

    USAGE SUMMARY:
    The script must be run with elevated permissions in order to collect all required data.
    Run the script on AVD host VMs and/or on Windows based devices from where you connect to the AVD hosts, as needed.

    The script has multiple module (.psm1) files located in a "Modules" folder. This folder (with its underlying .psm1 files) must stay in the same folder as the main AVD-Collect.ps1 
    file for the script to work properly.
    Make sure you are launching the main AVD-Collect.ps1 script from the context of the folder where it is located, so that it can reach its modules.
    The script will import the required module(s) on the fly when specific data is being invoked. You do not need to manually import the modules.

    When launched without any command line parameter, you can select one of the available data collection/diagnostics scenarios from the provided list. Diagnostics will run for every scenario.
    If you want to combine multiple scenarios or to skip the manual scenario selection, use command line parameters.

.NOTES
    Authors          : Robert Klemencz (Microsoft CSS) & Alexandru Olariu (Microsoft CSS)
    Requires         : At least PowerShell 5.1 and to be run elevated
    Last update      : May 18th, 2022
    Version          : 220518.3
    Feedback         : Send an e-mail to AVDCollectTalk@microsoft.com

.LINK
    Download: https://aka.ms/avd-collect

.PARAMETER Core
    Collect only basic AVD data (without Profiles/Teams/MSIX App Attach/MSRA/Smart Card/IME/Azure Stack HCI related data). Diagnostics will run at the end.

.PARAMETER Profiles
    Collect Core + Profiles related data. Diagnostics will run at the end.

.PARAMETER Teams
    Collect Core + Microsoft Teams related data. Diagnostics will run at the end.

.PARAMETER MSIXAA
    Collect Core + MSIX App Attach related data. Diagnostics will run at the end.

.PARAMETER MSRA
    Collect Core + Remote Assistance related data. Diagnostics will run at the end.

.PARAMETER SCard
    Collect Core + Smart Card related data. Diagnostics will run at the end.

.PARAMETER IME
    Collect Core + input method related data. Diagnostics will run at the end.

.PARAMETER HCI
    Collect Core + Azure Stack HCI related data. Diagnostics will run at the end.

.PARAMETER DumpPID
    Collect Core data + Collect a process dump based on the provided PID. Diagnostics will run at the end.

.PARAMETER DiagOnly
    Skip collecting troubleshooting data (even if any other parameters are specificed) and will only perform diagnostics. The results of the diagnostics will be stored in the 'AVD-Diag.txt' and 'AVD-Diag.html' files.
    Depending on the issues found during the diagnostic, additional files may be generated with exported event log entries coresponding to those identified issues.

.PARAMETER AcceptEula
    Silently accepts the Microsoft Diagnostic Tools End User License Agreement.

.PARAMETER AcceptNotice
    Silently accepts the Important Notice message displayed when the script is launched.

.PARAMETER OutputDir
    ​​​​​​Specify a custom directory where to store the collected files. By default, if this parameter is not specified, the script will store the collected data under "C:\MSDATA". If the path specified does not exit, the script will attempt to create it.

.PARAMETER NoGUI
    Start the script without a graphical user interface (legacy mode)

.OUTPUTS
    By default, all collected data are stored in a subfolder under C:\MSDATA. You can change this location by using the "-OutputDir" command line parameter.
#>

    param ([switch]$Core = $false, [switch]$DiagOnly = $false, [switch]$Teams = $false, [switch]$Profiles = $false, [switch]$MSIXAA = $false, [switch]$MSRA = $false, 
    [switch]$SCard = $false, [switch]$IME = $false, [switch]$HCI = $false, [int]$DumpPID, [switch]$AcceptEula, [switch]$AcceptNotice = $false, [string]$OutputDir, [switch]$NoGUI = $false)

$global:version = "220518.3"
$global:showGUI = $false
$global:LogRoot = "C:\MSDATA"
$global:LogrootUI = ""
$global:collectcount = 0

$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
if (-not $myWindowsPrincipal.IsInRole($adminRole)) {
    Write-Host "This script needs to be run as Administrator" -ForegroundColor Yellow
    exit
}

Function InitFolders {

    If ($OutputDir) { $global:LogRoot = $OutputDir } elseif ($global:LogrootUI) { $global:LogRoot = $global:LogrootUI } else { $global:LogRoot = "C:\MSDATA" }

    $global:LogFolder = "AVD-Results-" + $env:computername +"-" + $(get-date -f yyyyMMdd_HHmmss)
    $global:LogDir = "$LogRoot\$LogFolder\"
    $global:LogFilePrefix = $env:computername + "_"

    $global:BasicLogFolder = $global:LogDir + $global:LogFilePrefix
    $global:CertLogFolder = $global:BasicLogFolder + "Certificates\"
    $global:DumpFolder = $global:BasicLogFolder + "Dumps\"
    $global:EventLogFolder = $global:BasicLogFolder + "EventLogs\"
    $global:LogFileLogFolder = $global:BasicLogFolder + "LogFiles\"
    $global:NetLogFolder = $global:BasicLogFolder + "Networking\"
    $global:RegLogFolder = $global:BasicLogFolder + "RegistryKeys\"
    $global:GenevaLogFolder = $global:BasicLogFolder + "Monitoring\"
    $global:SchtaskFolder = $global:BasicLogFolder + "ScheduledTasks\"
    $global:MonTablesFolder = $global:GenevaLogFolder + "MonTables\"
    $global:SysInfoLogFolder = $global:BasicLogFolder + "SystemInfo\"
    $global:RDSLogFolder = $global:BasicLogFolder + "RDS\"
    $global:RDCTraceFolder = $global:BasicLogFolder + "RDClientAutoTrace\"
    $global:FSLogixLogFolder = $global:BasicLogFolder + "FSLogix\"
    $global:TeamsLogFolder = $global:BasicLogFolder + "Teams\"
    $global:ErrorLogFile = $global:BasicLogFolder + "AVD-Collect-Error.txt"
    $global:TempCommandErrorFile = $global:BasicLogFolder + "AVD-Collect-CommandError.txt"
    $global:OutputLogFile = $global:BasicLogFolder + "AVD-Collect-Log.txt"
    $global:DiagFile = $global:BasicLogFolder + "AVD-Diag.txt"

    $createfolder = New-Item -itemtype directory -path $LogDir -ErrorAction Stop

}

if (!(Test-Path ".\Modules\")) {
    Write-Host "'Modules' folder not found. Please launch AVD-Collect.ps1 from within the same folder that contains the script's Modules subfolder. See AVD-Collect-ReadMe.txt for more details." -ForegroundColor Yellow
    Exit
}

InitFolders

if ($DumpPID) { $global:dpid = $DumpPID }

$global:LogLevel = @{
    'Normal' = 0
    'Info' = 1
    'Warning' = 2
    'Error' = 3
    'ErrorLogFileOnly' = 4
    'WarnLogFileOnly' = 5
    'DiagFileOnly' = 7
}

$global:ver = (Get-CimInstance Win32_OperatingSystem).Caption
$global:fqdn = [System.Net.Dns]::GetHostByName(($env:computerName)).HostName
$global:agentpath = "C:\Program Files\Microsoft RDInfra\"

Set-Variable -Name 'fLogFileOnly' -Value $True -Scope Global #-Option ReadOnly

[void][System.Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')

#region ### Functions ###

function ShowEULAPopup($mode) {
    $EULA = New-Object -TypeName System.Windows.Forms.Form
    $richTextBox1 = New-Object System.Windows.Forms.RichTextBox
    $btnAcknowledge = New-Object System.Windows.Forms.Button
    $btnCancel = New-Object System.Windows.Forms.Button

    $EULA.SuspendLayout()
    $EULA.Name = "EULA"
    $EULA.Text = "Microsoft Diagnostic Tools End User License Agreement"

    $richTextBox1.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $richTextBox1.Location = New-Object System.Drawing.Point(12,12)
    $richTextBox1.Name = "richTextBox1"
    $richTextBox1.ScrollBars = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical
    $richTextBox1.Size = New-Object System.Drawing.Size(776, 397)
    $richTextBox1.TabIndex = 0
    $richTextBox1.ReadOnly=$True
    $richTextBox1.Add_LinkClicked({Start-Process -FilePath $_.LinkText})
    $richTextBox1.Rtf = @"
{\rtf1\ansi\ansicpg1252\deff0\nouicompat{\fonttbl{\f0\fswiss\fprq2\fcharset0 Segoe UI;}{\f1\fnil\fcharset0 Calibri;}{\f2\fnil\fcharset0 Microsoft Sans Serif;}}
{\colortbl ;\red0\green0\blue255;}
{\*\generator Riched20 10.0.19041}{\*\mmathPr\mdispDef1\mwrapIndent1440 }\viewkind4\uc1
\pard\widctlpar\f0\fs19\lang1033 MICROSOFT SOFTWARE LICENSE TERMS\par
Microsoft Diagnostic Scripts and Utilities\par
\par
{\pict{\*\picprop}\wmetafile8\picw26\pich26\picwgoal32000\pichgoal15
0100090000035000000000002700000000000400000003010800050000000b0200000000050000
000c0202000200030000001e000400000007010400040000000701040027000000410b2000cc00
010001000000000001000100000000002800000001000000010000000100010000000000000000
000000000000000000000000000000000000000000ffffff00000000ff040000002701ffff0300
00000000
}These license terms are an agreement between you and Microsoft Corporation (or one of its affiliates). IF YOU COMPLY WITH THESE LICENSE TERMS, YOU HAVE THE RIGHTS BELOW. BY USING THE SOFTWARE, YOU ACCEPT THESE TERMS.\par
{\pict{\*\picprop}\wmetafile8\picw26\pich26\picwgoal32000\pichgoal15
0100090000035000000000002700000000000400000003010800050000000b0200000000050000
000c0202000200030000001e000400000007010400040000000701040027000000410b2000cc00
010001000000000001000100000000002800000001000000010000000100010000000000000000
000000000000000000000000000000000000000000ffffff00000000ff040000002701ffff0300
00000000
}\par
\pard
{\pntext\f0 1.\tab}{\*\pn\pnlvlbody\pnf0\pnindent0\pnstart1\pndec{\pntxta.}}
\fi-360\li360 INSTALLATION AND USE RIGHTS. Subject to the terms and restrictions set forth in this license, Microsoft Corporation (\ldblquote Microsoft\rdblquote ) grants you (\ldblquote Customer\rdblquote  or \ldblquote you\rdblquote ) a non-exclusive, non-assignable, fully paid-up license to use and reproduce the script or utility provided under this license (the "Software"), solely for Customer\rquote s internal business purposes, to help Microsoft troubleshoot issues with one or more Microsoft products, provided that such license to the Software does not include any rights to other Microsoft technologies (such as products or services). \ldblquote Use\rdblquote  means to copy, install, execute, access, display, run or otherwise interact with the Software. \par
\pard\widctlpar\par
\pard\widctlpar\li360 You may not sublicense the Software or any use of it through distribution, network access, or otherwise. Microsoft reserves all other rights not expressly granted herein, whether by implication, estoppel or otherwise. You may not reverse engineer, decompile or disassemble the Software, or otherwise attempt to derive the source code for the Software, except and to the extent required by third party licensing terms governing use of certain open source components that may be included in the Software, or remove, minimize, block, or modify any notices of Microsoft or its suppliers in the Software. Neither you nor your representatives may use the Software provided hereunder: (i) in a way prohibited by law, regulation, governmental order or decree; (ii) to violate the rights of others; (iii) to try to gain unauthorized access to or disrupt any service, device, data, account or network; (iv) to distribute spam or malware; (v) in a way that could harm Microsoft\rquote s IT systems or impair anyone else\rquote s use of them; (vi) in any application or situation where use of the Software could lead to the death or serious bodily injury of any person, or to physical or environmental damage; or (vii) to assist, encourage or enable anyone to do any of the above.\par
\par
\pard\widctlpar\fi-360\li360 2.\tab DATA. Customer owns all rights to data that it may elect to share with Microsoft through using the Software. You can learn more about data collection and use in the help documentation and the privacy statement at {{\field{\*\fldinst{HYPERLINK https://aka.ms/privacy }}{\fldrslt{https://aka.ms/privacy\ul0\cf0}}}}\f0\fs19 . Your use of the Software operates as your consent to these practices.\par
\pard\widctlpar\par
\pard\widctlpar\fi-360\li360 3.\tab FEEDBACK. If you give feedback about the Software to Microsoft, you grant to Microsoft, without charge, the right to use, share and commercialize your feedback in any way and for any purpose.\~ You will not provide any feedback that is subject to a license that would require Microsoft to license its software or documentation to third parties due to Microsoft including your feedback in such software or documentation. \par
\pard\widctlpar\par
\pard\widctlpar\fi-360\li360 4.\tab EXPORT RESTRICTIONS. Customer must comply with all domestic and international export laws and regulations that apply to the Software, which include restrictions on destinations, end users, and end use. For further information on export restrictions, visit {{\field{\*\fldinst{HYPERLINK https://aka.ms/exporting }}{\fldrslt{https://aka.ms/exporting\ul0\cf0}}}}\f0\fs19 .\par
\pard\widctlpar\par
\pard\widctlpar\fi-360\li360\qj 5.\tab REPRESENTATIONS AND WARRANTIES. Customer will comply with all applicable laws under this agreement, including in the delivery and use of all data. Customer or a designee agreeing to these terms on behalf of an entity represents and warrants that it (i) has the full power and authority to enter into and perform its obligations under this agreement, (ii) has full power and authority to bind its affiliates or organization to the terms of this agreement, and (iii) will secure the permission of the other party prior to providing any source code in a manner that would subject the other party\rquote s intellectual property to any other license terms or require the other party to distribute source code to any of its technologies.\par
\pard\widctlpar\par
\pard\widctlpar\fi-360\li360\qj 6.\tab DISCLAIMER OF WARRANTY. THE SOFTWARE IS PROVIDED \ldblquote AS IS,\rdblquote  WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL MICROSOFT OR ITS LICENSORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THE SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.\par
\pard\widctlpar\qj\par
\pard\widctlpar\fi-360\li360\qj 7.\tab LIMITATION ON AND EXCLUSION OF DAMAGES. IF YOU HAVE ANY BASIS FOR RECOVERING DAMAGES DESPITE THE PRECEDING DISCLAIMER OF WARRANTY, YOU CAN RECOVER FROM MICROSOFT AND ITS SUPPLIERS ONLY DIRECT DAMAGES UP TO U.S. $5.00. YOU CANNOT RECOVER ANY OTHER DAMAGES, INCLUDING CONSEQUENTIAL, LOST PROFITS, SPECIAL, INDIRECT, OR INCIDENTAL DAMAGES. This limitation applies to (i) anything related to the Software, services, content (including code) on third party Internet sites, or third party applications; and (ii) claims for breach of contract, warranty, guarantee, or condition; strict liability, negligence, or other tort; or any other claim; in each case to the extent permitted by applicable law. It also applies even if Microsoft knew or should have known about the possibility of the damages. The above limitation or exclusion may not apply to you because your state, province, or country may not allow the exclusion or limitation of incidental, consequential, or other damages.\par
\pard\widctlpar\par
\pard\widctlpar\fi-360\li360 8.\tab BINDING ARBITRATION AND CLASS ACTION WAIVER. This section applies if you live in (or, if a business, your principal place of business is in) the United States.  If you and Microsoft have a dispute, you and Microsoft agree to try for 60 days to resolve it informally. If you and Microsoft can\rquote t, you and Microsoft agree to binding individual arbitration before the American Arbitration Association under the Federal Arbitration Act (\ldblquote FAA\rdblquote ), and not to sue in court in front of a judge or jury. Instead, a neutral arbitrator will decide. Class action lawsuits, class-wide arbitrations, private attorney-general actions, and any other proceeding where someone acts in a representative capacity are not allowed; nor is combining individual proceedings without the consent of all parties. The complete Arbitration Agreement contains more terms and is at {{\field{\*\fldinst{HYPERLINK https://aka.ms/arb-agreement-4 }}{\fldrslt{https://aka.ms/arb-agreement-4\ul0\cf0}}}}\f0\fs19 . You and Microsoft agree to these terms. \par
\pard\widctlpar\par
\pard\widctlpar\fi-360\li360 9.\tab LAW AND VENUE. If U.S. federal jurisdiction exists, you and Microsoft consent to exclusive jurisdiction and venue in the federal court in King County, Washington for all disputes heard in court (excluding arbitration). If not, you and Microsoft consent to exclusive jurisdiction and venue in the Superior Court of King County, Washington for all disputes heard in court (excluding arbitration).\par
\pard\widctlpar\par
\pard\widctlpar\fi-360\li360 10.\tab ENTIRE AGREEMENT. This agreement, and any other terms Microsoft may provide for supplements, updates, or third-party applications, is the entire agreement for the software.\par
\pard\sa200\sl276\slmult1\f1\fs22\lang9\par
\pard\f2\fs17\lang2057\par
}
"@
    $richTextBox1.BackColor = [System.Drawing.Color]::White
    $btnAcknowledge.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    $btnAcknowledge.Location = New-Object System.Drawing.Point(544, 415)
    $btnAcknowledge.Name = "btnAcknowledge";
    $btnAcknowledge.Size = New-Object System.Drawing.Size(119, 23)
    $btnAcknowledge.TabIndex = 1
    $btnAcknowledge.Text = "Accept"
    $btnAcknowledge.UseVisualStyleBackColor = $True
    $btnAcknowledge.Add_Click({$EULA.DialogResult=[System.Windows.Forms.DialogResult]::Yes})

    $btnCancel.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    $btnCancel.Location = New-Object System.Drawing.Point(669, 415)
    $btnCancel.Name = "btnCancel"
    $btnCancel.Size = New-Object System.Drawing.Size(119, 23)
    $btnCancel.TabIndex = 2
    if($mode -ne 0)
    {
	    $btnCancel.Text = "Close"
    }
    else
    {
	    $btnCancel.Text = "Decline"
    }
    $btnCancel.UseVisualStyleBackColor = $True
    $btnCancel.Add_Click({$EULA.DialogResult=[System.Windows.Forms.DialogResult]::No})

    $EULA.AutoScaleDimensions = New-Object System.Drawing.SizeF(6.0, 13.0)
    $EULA.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
    $EULA.ClientSize = New-Object System.Drawing.Size(800, 450)
    $EULA.Controls.Add($btnCancel)
    $EULA.Controls.Add($richTextBox1)
    if($mode -ne 0)
    {
	    $EULA.AcceptButton=$btnCancel
    }
    else
    {
        $EULA.Controls.Add($btnAcknowledge)
	    $EULA.AcceptButton=$btnAcknowledge
        $EULA.CancelButton=$btnCancel
    }
    $EULA.ResumeLayout($false)
    $EULA.Size = New-Object System.Drawing.Size(800, 650)

    Return ($EULA.ShowDialog())
}

function ShowEULAIfNeeded($toolName, $mode) {
	$eulaRegPath = "HKCU:Software\Microsoft\CESDiagnosticTools"
	$eulaAccepted = "No"
	$eulaValue = $toolName + " EULA Accepted"
	if(Test-Path $eulaRegPath)
	{
		$eulaRegKey = Get-Item $eulaRegPath
		$eulaAccepted = $eulaRegKey.GetValue($eulaValue, "No")
	}
	else
	{
		$eulaRegKey = New-Item $eulaRegPath
	}
	if($mode -eq 2) # silent accept
	{
		$eulaAccepted = "Yes"
       		$ignore = New-ItemProperty -Path $eulaRegPath -Name $eulaValue -Value $eulaAccepted -PropertyType String -Force
	}
	else
	{
		if($eulaAccepted -eq "No")
		{
			$eulaAccepted = ShowEULAPopup($mode)
			if($eulaAccepted -eq [System.Windows.Forms.DialogResult]::Yes)
			{
	        		$eulaAccepted = "Yes"
	        		$ignore = New-ItemProperty -Path $eulaRegPath -Name $eulaValue -Value $eulaAccepted -PropertyType String -Force
			}
		}
	}
	return $eulaAccepted
}

Function VersionInt($verString) {
    $verSplit = $verString.Split([char]0x0a, [char]0x0d, '.')
    $vFull = 0; $i = 0; $vNum = 256 * 256 * 256
    while ($vNum -gt 0) { $vFull += [int] $verSplit[$i] * $vNum; $vNum = $vNum / 256; $i++ };
    return $vFull
}

Function CheckVersion($verCurrent) {

    UEXAVD_LogMessage $LogLevel.Normal "Checking if a new version is available"
    try {
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $verNew = $WebClient.DownloadString('https://cesdiagtools.blob.core.windows.net/windows/AVD-Collect.ver')
        $verNew = $verNew.TrimEnd([char]0x0a, [char]0x0d)
        [long] $lNew = VersionInt($verNew)
        [long] $lCur = VersionInt($verCurrent)
        if($lNew -gt $lCur) {
            $updnotice = "A newer version is available: v"+$verNew+" (you are currently on v"+$verCurrent+").`n`nFor best results, download and use the latest version from https://aka.ms/avd-collect`n`nIf you select 'Yes', a browser window will open to download the latest 'AVD-Collect.zip' file and the current script will exit. Otherwise the current script will continue as is."
            $wshell = New-Object -ComObject Wscript.Shell
            $answer = $wshell.Popup("$updnotice",0,"Would you like to download the new version now?",4+32)
            if ($answer -eq 6) {
                UEXAVD_LogMessage $LogLevel.Info ("Opening default browser to download the latest 'AVD-Collect.zip' from https://aka.ms/avd-collect")
                Start-Process https://aka.ms/avd-collect
                UEXAVD_LogMessage $LogLevel.Info ("Exiting")
                UEXAVD_CleanUpandExit
            } else {
                UEXAVD_LogMessage $LogLevel.Info "You have decided not to download the latest version yet. For best results, download and use the latest version from https://aka.ms/avd-collect"
            }
        }
        else {
            UEXAVD_LogMessage $LogLevel.Info  ("You are running the latest version (v"+$verCurrent+")")
        }
    } catch {
        UEXAVD_LogMessage $LogLevel.Warning ("Unable to check script version... " + $_)
        UEXAVD_LogMessage $LogLevel.Info "For best results, always use the latest version from https://aka.ms/avd-collect"
    }
    
    UEXAVD_LogMessage $LogLevel.Normal "Continuing with script execution`n"
}


Function global:UEXAVD_LogMessage {
    param( [ValidateNotNullOrEmpty()][int] $Level, [ValidateNotNullOrEmpty()][string] $Message, [ValidateNotNullOrEmpty()][string] $Color)

    If (!$Level) { $Level = $LogLevel.Normal }

    $LogMessage = (get-date).ToString("yyyyMMdd HH:mm:ss.fff") + " " + $Message

    Switch($Level){
        '0'{ $LogConsole = $True; $MessageColor = 'White' } # Normal + console
        '1'{ $LogConsole = $True; $MessageColor = 'Yellow' } # Info + console
        '2'{ $LogConsole = $True; $MessageColor = 'Magenta' } # Warning + console
        '3'{ $LogConsole = $False; $MessageColor = 'Red' } # Error
        '4'{ $LogConsole = $False } # ErrorLogFileOnly
        '5'{ $LogConsole = $False } # WarnLogFileOnly
    }

    If (($Color) -and $Color.Length -ne 0) { $MessageColor = $Color }

    $Index = 0
    # In case of Warning/Error/Debug, add line and function name to message.
    If($Level -eq $LogLevel.Warning -or $Level -eq $LogLevel.Error -or $Level -eq $LogLevel.Debug -or $Level -eq $LogLevel.ErrorLogFileOnly -or $Level -eq $LogLevel.WarnLogFileOnly){
        $CallStack = Get-PSCallStack
        $CallerInfo = $CallStack[$Index]

        If ($CallerInfo.FunctionName -like "*UEXAVD_LogMessage") { $CallerInfo = $CallStack[$Index+1] }
        If ($CallerInfo.FunctionName -like "*UEXAVD_LogException") { $CallerInfo = $CallStack[$Index+2] }

        $FuncName = $CallerInfo.FunctionName
        If ($FuncName -eq "<ScriptBlock>") { $FuncName = "Main" }

        $LogMessage = ((Get-Date).ToString("yyyyMMdd HH:mm:ss.fff") + ': [' + $FuncName + '(' + $CallerInfo.ScriptLineNumber + ')] ' + $Message)

    } Else {
        $LogMessage = (Get-Date).ToString("yyyyMMdd HH:mm:ss.fff") + " " + $Message
    }

    # In case of Error, log to error file
    If(($Level -eq $LogLevel.Error) -or ($Level -eq $LogLevel.ErrorLogFileOnly)) {
        If (!(Test-Path -Path $LogDir)) { UEXAVD_CreateLogFolder $LogDir }
        $LogMessage | Out-File -Append $global:ErrorLogFile
    }

    if ($LogConsole) {
        If ($global:showGUI) {
            $psBox.SelectionStart = $psBox.TextLength
            $psBox.SelectionLength = 0
            $psBox.SelectionColor = $MessageColor
            $psBox.AppendText("`r`n$LogMessage")
            $psBox.Refresh()
            $psBox.ScrollToCaret()
        } else {
            Write-Host $LogMessage -ForegroundColor $MessageColor
        }
        $LogMessage | Out-File -Append $OutputLogFile
    }
    
    if ($Level -eq $LogLevel.WarnLogFileOnly) { $LogMessage | Out-File -Append $OutputLogFile }

    
}

Function global:UEXAVD_LogDiag {
    param( [ValidateNotNullOrEmpty()][int] $Level, [ValidateNotNullOrEmpty()][string] $Message, [string] $Color)

    If (!$Level) { $Level = $LogLevel.Normal }

    $DiagMessage = (get-date).ToString("yyyyMMdd HH:mm:ss.fff") + " " + $Message

    Switch($Level){
        '0'{ $LogConsole = $True; $MessageColor = 'Yellow' } # Normal
        '2'{ $LogConsole = $True; $MessageColor = 'Magenta' } # Warning
        '3'{ $LogConsole = $True; $MessageColor = 'Red' } # Error
        '7'{ $LogConsole = $False } # Info only
    }

    If ((!$Color) -and $Color.Length -ne 0) { $MessageColor = $Color }

    If (!(Test-Path -Path $LogDir)) { UEXAVD_CreateLogFolder $LogDir }

    $DiagMessage | Out-File -Append $DiagFile

    if ($LogConsole) {
        if ($global:showGUI) {
            $psBox.SelectionStart = $psBox.TextLength
            $psBox.SelectionLength = 0
            $psBox.SelectionColor = $MessageColor
            $psBox.AppendText("`r`n$DiagMessage")
            $psBox.Refresh()
            $psBox.ScrollToCaret()
        } else {
            Write-Host $DiagMessage -ForegroundColor $MessageColor
            $DiagMessage | Out-File -Append $OutputLogFile
        }
    }    

    if (($Level -eq $LogLevel.Normal) -or ($Level -eq $LogLevel.Warning)) { $DiagMessage | Out-File -Append $OutputLogFile }
}

Function global:UEXAVD_CreateLogFolder {
    Param([Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$LogFolder)

    If (!(test-path -Path $LogFolder)) {
        Try {
            if (($NoGUI) -or !($showGUI)) {
                Write-Host ((get-date).ToString("yyyyMMdd HH:mm:ss.fff") + " Creating log folder $LogFolder") -ForegroundColor Yellow
            } else {
                Add-OutputBoxLine ((get-date).ToString("yyyyMMdd HH:mm:ss.fff") + " Creating log folder $LogFolder") "Yellow"
            }

            (get-date).ToString("yyyyMMdd HH:mm:ss.fff") + " Creating log folder $LogFolder" | Out-File -Append $OutputLogFile
            New-Item $LogFolder -ItemType Directory -ErrorAction Stop | Out-Null
        } Catch {
            UEXAVD_LogException "ERROR: An error occurred while creating $LogFolder" -ErrObj $_ $fLogFileOnly
        }
    } Else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "$LogFolder already exist."
    }
}

Function global:UEXAVD_CleanUpandExit{
    If (($Null -ne $TempCommandErrorFile) -and (Test-Path -Path $TempCommandErrorFile)) { Remove-Item $TempCommandErrorFile -Force | Out-Null }
    If ($fQuickEditCodeExist) { [DisableConsoleQuickEdit]::SetQuickEdit($False) | Out-Null }
    If ($global:showGUI) { $main_form.Close() } else { Exit }
}

Function global:UEXAVD_LogException{
    param([parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][String]$Message, [parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Management.Automation.ErrorRecord]$ErrObj, [Bool]$fErrorLogFileOnly)

    $ErrorCode = "0x" + [Convert]::ToString($ErrObj.Exception.HResult,16)
    $ExternalException = [System.ComponentModel.Win32Exception]$ErrObj.Exception.HResult
    $ErrorMessage = $Message + "`n" `
        + "Command/Function: " + $ErrObj.CategoryInfo.Activity + " failed with $ErrorCode => " + $ExternalException.Message + "`n" `
        + $ErrObj.CategoryInfo.Reason + ": " + $ErrObj.Exception.Message + "`n" `
        + "ScriptStack:" + "`n" `
        + $ErrObj.ScriptStackTrace

    If ($fErrorLogFileOnly) { UEXAVD_LogMessage $LogLevel.ErrorLogFileOnly $ErrorMessage } Else { UEXAVD_LogMessage $LogLevel.Error $ErrorMessage }
}

Function global:UEXAVD_RunCommands{
    param([parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][String]$LogPrefix, [parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][String[]]$CmdletArray, 
        [parameter(Mandatory=$true)][Bool]$ThrowException, [parameter(Mandatory=$true)][Bool]$ShowMessage, [Bool]$ShowError=$False)

    ForEach($CommandLine in $CmdletArray){
        $tmpMsg = $CommandLine -replace "\| Out-File.*$",""
        $tmpMsg = $tmpMsg -replace "\| Out-Null.*$",""
        $tmpMsg = $tmpMsg -replace "\-ErrorAction Stop",""
        $tmpMsg = $tmpMsg -replace "\-ErrorAction SilentlyContinue",""
        $CmdlineForDisplayMessage = $tmpMsg -replace "2>&1",""
        Try{
            If ($ShowMessage) { UEXAVD_LogMessage $LogLevel.Normal ("[$LogPrefix] Running $CmdlineForDisplayMessage") }

            # There are some cases where Invoke-Expression does not reset $LASTEXITCODE and $LASTEXITCODE has old error value. Hence initialize the powershell managed value manually...
            $LASTEXITCODE = 0

            # Run actual command here. Redirect all streams to temporary error file as some commands output an error to warning stream(3) and others are to error stream(2).
            Invoke-Expression -Command $CommandLine -ErrorAction Stop *> $TempCommandErrorFile

            # It is possible $LASTEXITCODE becomes null in some sucessful case, so perform null check and examine error code.
            If($LASTEXITCODE -ne $Null -and $LASTEXITCODE -ne 0) {
                $Message = "An error happened during running `'$CommandLine` " + '(Error=0x' + [Convert]::ToString($LASTEXITCODE,16) + ')'
                UEXAVD_LogMessage $LogLevel.ErrorLogFileOnly $Message
                If (Test-Path -Path $TempCommandErrorFile) {
                    # Always log error to error file.
                    Get-Content $TempCommandErrorFile -ErrorAction SilentlyContinue | Out-File -Append $global:ErrorLogFile
                    # If -ShowError:$True, show the error to console.
                    If ($ShowError) {
                        Write-Host ("Error happened in $CommandLine.") -ForegroundColor Red
                        Write-Host ('---------- ERROR MESSAGE ----------')
                        Get-Content $TempCommandErrorFile -ErrorAction SilentlyContinue
                        Write-Host ('-----------------------------------')
                    }
                }
                Remove-Item $TempCommandErrorFile -Force -ErrorAction SilentlyContinue | Out-Null
                If ($ThrowException) { Throw($Message) }
            } Else {
                Remove-Item $TempCommandErrorFile -Force -ErrorAction SilentlyContinue | Out-Null
            }

        } Catch {
            If ($ThrowException) {
                Throw $_   # Leave the error handling to upper function.
            } Else {
                $Message = "An error happened in Invoke-Expression with $CommandLine"
                UEXAVD_LogException ($Message) -ErrObj $_ $fLogFileOnly
                If ($ShowError){
                    Write-Host ("ERROR: $Message") -ForegroundColor Red
                    Write-Host ('---------- ERROR MESSAGE ----------')
                    $_
                    Write-Host ('-----------------------------------')
                }
                Continue
            }
        }
    }
}

function global:UEXAVD_TestRegistryValue {
    param ([parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$Path, [parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$Value)

    try {
        $trv = Get-ItemProperty -Path $Path -ErrorAction Stop | Select-Object -ExpandProperty $Value -ErrorAction Stop
        if (($trv) -or ($trv -eq "")) { return $true } else { return $false }
    }
    catch {
        return $false
    }
}

Function global:UEXAVD_GetRegKeys {
    Param([Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$RegRoot, [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$RegPath, [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$RegFile)

    $RegOut = $RegLogFolder + $LogFilePrefix + $RegRoot + "-" + $RegFile + ".txt"
    $RegFullPath = $RegRoot + "\" + $RegPath
    $RegTest = $RegRoot + ":\" + $RegPath

    if (Test-path $RegTest) {
        Try{
            reg export $RegFullPath $RegOut | Out-Null
        } Catch {
            UEXAVD_LogException ("Error: An exception occurred in UEXAVD_GetRegKeys $RegFullPath.") -ErrObj $_ $fLogFileOnly
            Continue
        }
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] Reg key '$RegFullPath' not found."
        Continue
    }
}

Function global:UEXAVD_GetEventLogs {
    Param([Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$EventSource, [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$EventFile)

    $EventOut = $EventLogFolder + $LogFilePrefix + $EventFile + ".evtx"

    if (Get-WinEvent -ListLog $EventSource -ErrorAction SilentlyContinue) {
        Try {
            $CommandLine = "wevtutil epl '$EventSource' '$EventOut' 2>&1 | Out-Null"
            Invoke-Expression $CommandLine
            $CommandLine = "wevtutil al '$EventOut' /l:en-us 2>&1 | Out-Null"
            Invoke-Expression $CommandLine
        } Catch {
            UEXAVD_LogException ("Error: An error occurred in $CommandLine") -ErrObj $_ $fLogFileOnly
            Continue
        }
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] Event log '$EventSource' not found."
    }
}

function global:UEXAVD_CloseMSRDC {
    $msrdc = Get-Process msrdc -ErrorAction SilentlyContinue

    if ($msrdc) {
        Write-host "The AVD desktop client (MSRDC) has been detected as running."
        Write-host "To collect the most recent AVD Desktop Client specific ETL traces, MSRDC.exe must be closed first.
        "
        $confirm = Read-Host "Do you want to close the MSRDC.exe now? This will disconnect all outgoing active AVD connections on this client! [Y/N]"
        ""
        if ($confirm.ToLower() -eq "n") {
            UEXAVD_LogMessage $LogLevel.Warning ("MSRDC.exe has not been closed. The most recent ETL traces will NOT be available for troubleshooting! Continuing data collection.")
        } elseif ($confirm.ToLower() -eq "y") {
            UEXAVD_LogMessage $LogLevel.Info "Closing MSRDC.exe ..."
            $msrdc.CloseMainWindow() | Out-Null
            Start-Sleep 5
            if (!$msrdc.HasExited) { $msrdc | Stop-Process -Force }
            UEXAVD_LogMessage $LogLevel.Info "MSRDC.exe has been closed. Waiting 20 seconds for the latest trace file(s) to get saved before continuing with the data collection."
            Start-Sleep 20
        } else {
            UEXAVD_CloseMSRDC
        }
        ""
    }
}

Function global:UEXAVD_CheckRegPath {
    Param([Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$RegPath, [string]$OptNote)

    $isPath = Test-Path -path $RegPath
    if ($isPath) { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Reg path '$RegPath' exists. " + $OptNote) }
    else { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Reg path '$RegPath' not found. " + $OptNote) }
}

Function global:UEXAVD_FileVersion {
    param(
        [string] $FilePath, [bool] $Log = $false
    )

    if (Test-Path -Path $FilePath) {
        $fileobj = Get-item $FilePath
        $filever = $fileobj.VersionInfo.FileMajorPart.ToString() + "." + $fileobj.VersionInfo.FileMinorPart.ToString() + "." + $fileobj.VersionInfo.FileBuildPart.ToString() + "." + $fileobj.VersionInfo.FilePrivatepart.ToString()

        if ($log) {
            ($FilePath + "," + $filever + "," + $fileobj.CreationTime.ToString("yyyyMMdd HH:mm:ss")) 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "KeyFileVersions.csv")
        }
        return $filever | Out-Null
    } else {
        return ""
    }
}


function global:UEXAVD_GetRDRoleInfo {
    param ($Class, $Namespace, $ComputerName = "localhost", $Auth = "PacketPrivacy", $Impersonation = "Impersonate")

    Get-WmiObject -Class $Class -Namespace $Namespace -ComputerName $ComputerName -Authentication $Auth -Impersonation $Impersonation

}

$code = @"
using System;
using System.Drawing;
using System.Runtime.InteropServices;
 
namespace System
{ public class IconExtractor
{ public static Icon Extract(string file, int number, bool largeIcon)
{
IntPtr large;
IntPtr small;
ExtractIconEx(file, number, out large, out small, 1);
try
{ return Icon.FromHandle(largeIcon ? large : small); }
catch
{ return null; }
}
[DllImport("Shell32.dll", EntryPoint = "ExtractIconExW", CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
private static extern int ExtractIconEx(string sFile, int iIndex, out IntPtr piLargeVersion, out IntPtr piSmallVersion, int amountIcons);
}
}
"@
Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing

#endregion ### Functions ###


# This function disable quick edit mode. If the mode is enabled, console output will hang when key input or strings are selected.
# So disable the quick edit mode during running script and re-enable it after script is finished.
$QuickEditCode=@"
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Runtime.InteropServices;


public static class DisableConsoleQuickEdit
{

    const uint ENABLE_QUICK_EDIT = 0x0040;

    // STD_INPUT_HANDLE (DWORD): -10 is the standard input device.
    const int STD_INPUT_HANDLE = -10;

    [DllImport("kernel32.dll", SetLastError = true)]
    static extern IntPtr GetStdHandle(int nStdHandle);

    [DllImport("kernel32.dll")]
    static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);

    [DllImport("kernel32.dll")]
    static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);

    public static bool SetQuickEdit(bool SetEnabled)
    {

        IntPtr consoleHandle = GetStdHandle(STD_INPUT_HANDLE);

        // get current console mode
        uint consoleMode;
        if (!GetConsoleMode(consoleHandle, out consoleMode))
        {
            // ERROR: Unable to get console mode.
            return false;
        }

        // Clear the quick edit bit in the mode flags
        if (SetEnabled)
        {
            consoleMode &= ~ENABLE_QUICK_EDIT;
        }
        else
        {
            consoleMode |= ENABLE_QUICK_EDIT;
        }

        // set the new mode
        if (!SetConsoleMode(consoleHandle, consoleMode))
        {
            // ERROR: Unable to set console mode
            return false;
        }

        return true;
    }
}
"@

Try {
    $QuickEditMode = add-type -TypeDefinition $QuickEditCode -Language CSharp -ErrorAction Stop
    $fQuickEditCodeExist = $True
} Catch {
    $fQuickEditCodeExist = $False
}


#region GUI

[System.Windows.Forms.Application]::EnableVisualStyles()

Function Add-OutputBoxLine {
    Param ($Message, [System.Drawing.Color]$color = "White")

    $psBox.SelectionStart = $psBox.TextLength
    $psBox.SelectionLength = 0
    $psBox.SelectionColor = $color
    $psBox.AppendText("`r`n$Message")
    $psBox.Refresh()
    $psBox.ScrollToCaret()
}

Function Find-Folder {
    [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    
    $browse = New-Object System.Windows.Forms.FolderBrowserDialog
    $browse.SelectedPath = "C:\"
    $browse.ShowNewFolderButton = $true
    $browse.Description = "Select a directory"

    $loop = $true
    while($loop) {
        if ($browse.ShowDialog() -eq "OK") {
            $loop = $false
		    $outdirBox.Text = $browse.SelectedPath
            $global:LogrootUI = $outdirBox.Text
        } else {
            return
        }
    }
    $browse.SelectedPath
    $browse.Dispose()
}

Function AVDCollectGUI {

    $global:showGUI = $true

    $main_form = New-Object System.Windows.Forms.Form
    $main_form.Text = 'AVD-Collect'
    $main_form.Width = 1000
    $main_form.Height = 600
    $main_form.StartPosition = "CenterScreen"
    $main_form.BackColor = "#eeeeee"
    $iconpath = (Get-Item .).FullName + "\AVD-Collect.ico"
    $main_form.Icon = New-Object system.drawing.icon ("$iconpath")

    $main_formMenu = new-object System.Windows.Forms.MenuStrip

    $SeparatorMenuItem1 = new-object System.Windows.Forms.ToolStripSeparator
    $SeparatorMenuItem2 = new-object System.Windows.Forms.ToolStripSeparator
    $SeparatorMenuItem3 = new-object System.Windows.Forms.ToolStripSeparator
    
    #File menu
    $OptionsMenuItem = new-object System.Windows.Forms.ToolStripMenuItem
    $OptionsMenuItem.Text = "&File"
    $CheckUpdMenuItem = new-object System.Windows.Forms.ToolStripMenuItem
    $ExitMenuItem = new-object System.Windows.Forms.ToolStripMenuItem
    [void]$OptionsMenuItem.DropDownItems.Add($CheckUpdMenuItem)
    [void]$OptionsMenuItem.DropDownItems.Add($SeparatorMenuItem3)
    [void]$OptionsMenuItem.DropDownItems.Add($ExitMenuItem)

    $CheckUpdMenuItem.Text = "Check for &Update"
    $CheckUpdMenuItem.Add_Click({
        CheckVersion($version)
    })

    $ExitMenuItem.Text = "Exit"
    $ExitMenuItem.Add_Click({
        if ($global:collectcount -eq 0) { Remove-Item -path $LogDir -Recurse | Out-Null }
        $global:collectcount = 0
        $main_form.Close()
        If (($Null -ne $TempCommandErrorFile) -and (Test-Path -Path $TempCommandErrorFile)) { Remove-Item $TempCommandErrorFile -Force | Out-Null }
        If ($fQuickEditCodeExist) { [DisableConsoleQuickEdit]::SetQuickEdit($False) | Out-Null }
    })

    #Results menu
    $ResultsMenuItem = new-object System.Windows.Forms.ToolStripMenuItem
    $ResultsMenuItem.Text = "&Results"
    $ResultsMenuItem.Add_Click({
        If ($LogrootUI) {
            If (Test-Path $LogrootUI) { explorer $LogrootUI } 
            else { Add-OutputBoxLine "`n[WARNING] The selected output location could not be found." "Yellow" }
        } elseif (Test-Path $LogRoot) { explorer $LogRoot } 
        else { Add-OutputBoxLine "`n[WARNING] The selected output location could not be found." "Yellow" }        
    })

    #Help menu
    $HelpMenuItem = new-object System.Windows.Forms.ToolStripMenuItem
    $HelpMenuItem.Text = "&Help"
    $ReadMeMenuItem = new-object System.Windows.Forms.ToolStripMenuItem
    $WhatsNewMenuItem = new-object System.Windows.Forms.ToolStripMenuItem
    $FeedbackMenuItem = new-object System.Windows.Forms.ToolStripMenuItem
    $AboutMenuItem = new-object System.Windows.Forms.ToolStripMenuItem
    [void]$HelpMenuItem.DropDownItems.Add($ReadMeMenuItem)
    [void]$HelpMenuItem.DropDownItems.Add($WhatsNewMenuItem)
    [void]$HelpMenuItem.DropDownItems.Add($SeparatorMenuItem1)
    [void]$HelpMenuItem.DropDownItems.Add($FeedbackMenuItem)
    [void]$HelpMenuItem.DropDownItems.Add($SeparatorMenuItem2)
    [void]$HelpMenuItem.DropDownItems.Add($AboutMenuItem)
        
    $ReadMeMenuItem.Text = "&ReadMe"
    $ReadMeMenuItem.Image = [System.Drawing.SystemIcons]::Information
    $ReadMeMenuItem.Add_Click({
        $readmepath = (Get-Item .).FullName + "\AVD-Collect-ReadMe.txt"
        notepad $readmepath
    })

    $AboutMenuItem.Text = "&About"
    $AboutMenuItem.Image = [System.Drawing.SystemIcons]::Application
    $AboutMenuItem.Add_Click({
    [Windows.Forms.MessageBox]::Show("AVD-Collect version: $version`n
Authors: 
    Robert Klemencz (Microsoft CSS)
    Alexandru Olariu (Microsoft CSS)`n
Contact: 
    AVDCollectTalk@microsoft.com`n
Always use the latest package from https://aka.ms/avd-collect", “About”, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
    })

    $FeedbackMenuItem.Text = "Provide &Feedback"
    $FeedbackMenuItem.Image = [System.IconExtractor]::Extract("imageres.dll", 15, $true)
    $FeedbackMenuItem.Add_Click({ [System.Diagnostics.Process]::start("mailto:AVDCollectTalk@microsoft.com?subject=AVD-Collect%20Feedback") })

    $WhatsNewMenuItem.Size = new-object System.Drawing.Size(51, 20)
    $WhatsNewMenuItem.Text = "&What's New"
    $WhatsNewMenuItem.Image = [System.Drawing.SystemIcons]::Question
    $WhatsNewMenuItem.Add_Click({
        $readmepath = (Get-Item .).FullName + "\AVD-Collect-RevisionHistory.txt"
        notepad $readmepath
    })

    $main_formMenu.Items.AddRange(@($OptionsMenuItem, $ResultsMenuItem, $HelpMenuItem))
    $main_formMenu.Location = new-object System.Drawing.Point(0, 0)
    $main_formMenu.Size = new-object System.Drawing.Size(200, 24)
    $main_formMenu.TabIndex = 0
    $main_formMenu.BackColor = [System.Drawing.Color]::White
        
    $main_form.Controls.Add($main_formMenu)
    $main_form.MainMenuStrip = $main_formMenu

    $groupOpt = New-Object System.Windows.Forms.GroupBox
    $groupOpt.Text = "Scenarios"
    $groupOpt.Location = New-Object System.Drawing.Point(10,40)
    $groupOpt.Size  = New-Object System.Drawing.Point(150,230)
    $groupOpt.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $groupOpt.AutoSize = $True
    $main_form.Controls.Add($groupOpt)
    
    $CBCore = New-Object System.Windows.Forms.CheckBox
    $CBCore.Text = "Core"
    $CBCore.Location = New-Object System.Drawing.Point(20,30)
    $CBCore.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $CBCore.AutoSize = $True
    $CBCore.Checked = $True
    $CBCore.Enabled = $False
    $CBCore.Cursor = [System.Windows.Forms.Cursors]::Hand
    $CBCoreToolTip = New-Object System.Windows.Forms.ToolTip
    $CBCoreToolTip.SetToolTip($CBCore, "Collect basic/Core troubleshooting data (always enabled by default). See 'ReadMe' for a full list of the collected data")
    $groupOpt.Controls.Add($CBCore)
    
    $CBProfiles = New-Object System.Windows.Forms.CheckBox
    $CBProfiles.Text = "Profiles"
    $CBProfiles.Location = New-Object System.Drawing.Point(20,55)
    $CBProfiles.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $CBProfiles.AutoSize = $True
    $CBProfiles.Cursor = [System.Windows.Forms.Cursors]::Hand
    $CBProfToolTip = New-Object System.Windows.Forms.ToolTip
    $CBProfToolTip.SetToolTip($CBProfiles, "Collect User Profile related data (incl. FSLogix if available). See 'ReadMe' for a full list of the collected data")
    $CBProfiles.Add_CheckStateChanged({ if ($CBProfiles.Checked) { $script:Profiles = $true } else { $script:Profiles = $false } })
    $groupOpt.Controls.Add($CBProfiles)

    $CBTeams = New-Object System.Windows.Forms.CheckBox
    $CBTeams.Text = "Teams"
    $CBTeams.Location = New-Object System.Drawing.Point(20,80)
    $CBTeams.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $CBTeams.AutoSize = $True
    $CBTeams.Cursor = [System.Windows.Forms.Cursors]::Hand
    $CBTeamsToolTip = New-Object System.Windows.Forms.ToolTip
    $CBTeamsToolTip.SetToolTip($CBTeams, "Collect Teams AVD optimization related data. See 'ReadMe' for a full list of the collected data")
    $CBTeams.Add_CheckStateChanged({ if ($CBTeams.Checked) { $script:Teams = $true } else { $script:Teams = $false } })
    $groupOpt.Controls.Add($CBTeams)

    $CBMSIXAA = New-Object System.Windows.Forms.CheckBox
    $CBMSIXAA.Text = "MSIXAA"
    $CBMSIXAA.Location = New-Object System.Drawing.Point(20,105)
    $CBMSIXAA.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $CBMSIXAA.AutoSize = $True
    $CBMSIXAA.Cursor = [System.Windows.Forms.Cursors]::Hand
    $CBMSIXAAToolTip = New-Object System.Windows.Forms.ToolTip
    $CBMSIXAAToolTip.SetToolTip($CBMSIXAA, "Collect MSIX App Attach related data. See 'ReadMe' for a full list of the collected data")
    $CBMSIXAA.Add_CheckStateChanged({ if ($CBMSIXAA.Checked) { $script:MSIXAA = $true } else { $script:MSIXAA = $false } })
    $groupOpt.Controls.Add($CBMSIXAA)

    $CBMSRA = New-Object System.Windows.Forms.CheckBox
    $CBMSRA.Text = "MSRA"
    $CBMSRA.Location = New-Object System.Drawing.Point(20,130)
    $CBMSRA.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $CBMSRA.AutoSize = $True
    $CBMSRA.Cursor = [System.Windows.Forms.Cursors]::Hand
    $CBMSRAToolTip = New-Object System.Windows.Forms.ToolTip
    $CBMSRAToolTip.SetToolTip($CBMSRA, "Collect Remote Assistance related data. See 'ReadMe' for a full list of the collected data")
    $CBMSRA.Add_CheckStateChanged({ if ($CBMSRA.Checked) { $script:MSRA = $true } else { $script:MSRA = $false } })
    $groupOpt.Controls.Add($CBMSRA)

    $CBSCard = New-Object System.Windows.Forms.CheckBox
    $CBSCard.Text = "SCard"
    $CBSCard.Location = New-Object System.Drawing.Point(20,155)
    $CBSCard.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $CBSCard.AutoSize = $True
    $CBSCard.Cursor = [System.Windows.Forms.Cursors]::Hand
    $CBSCardToolTip = New-Object System.Windows.Forms.ToolTip
    $CBSCardToolTip.SetToolTip($CBSCard, "Collect Smart Card related data. See 'ReadMe' for a full list of the collected data")
    $CBSCard.Add_CheckStateChanged({ if ($CBSCard.Checked) { $script:SCard = $true } else { $script:SCard = $false } })
    $groupOpt.Controls.Add($CBSCard)

    $CBIME = New-Object System.Windows.Forms.CheckBox
    $CBIME.Text = "IME"
    $CBIME.Location = New-Object System.Drawing.Point(20,180)
    $CBIME.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $CBIME.AutoSize = $True
    $CBIME.Cursor = [System.Windows.Forms.Cursors]::Hand
    $CBIMEToolTip = New-Object System.Windows.Forms.ToolTip
    $CBIMEToolTip.SetToolTip($CBIME, "Collect input method related data. See 'ReadMe' for a full list of the collected data")
    $CBIME.Add_CheckStateChanged({ if ($CBIME.Checked) { $script:IME = $true } else { $script:IME = $false } })
    $groupOpt.Controls.Add($CBIME)

    $CBHCI = New-Object System.Windows.Forms.CheckBox
    $CBHCI.Text = "HCI"
    $CBHCI.Location = New-Object System.Drawing.Point(20,205)
    $CBHCI.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $CBHCI.AutoSize = $True
    $CBHCI.Cursor = [System.Windows.Forms.Cursors]::Hand
    $CBHCIToolTip = New-Object System.Windows.Forms.ToolTip
    $CBHCIToolTip.SetToolTip($CBHCI, "Collect Azure Stack HCI related data. See 'ReadMe' for a full list of the collected data")
    $CBHCI.Add_CheckStateChanged({ if ($CBHCI.Checked) { $script:HCI = $true } else { $script:HCI = $false } })
    $groupOpt.Controls.Add($CBHCI)

    $CBDiagOnly = New-Object System.Windows.Forms.CheckBox
    $CBDiagOnly.Text = "DiagOnly"
    $CBDiagOnly.Location = New-Object System.Drawing.Point(20,255)
    $CBDiagOnly.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $CBDiagOnly.AutoSize = $True
    $CBDiagOnly.Cursor = [System.Windows.Forms.Cursors]::Hand
    $CBDiagOToolTip = New-Object System.Windows.Forms.ToolTip
    $CBDiagOToolTip.SetToolTip($CBDiagOnly, "Skip data collection and run diagnostics only`nSome event log entries may still be collected if issues are found. See 'ReadMe' for a full list of the checks performed")
    $CBDiagOnly.Add_CheckStateChanged({ 
        if ($CBDiagOnly.Checked) { 
            $script:DiagOnly = $True
            $CBProfiles.Checked = $False; $CBProfiles.Enabled = $False; $script:Profiles = $False; 
            $CBMSIXAA.Checked = $False; $CBMSIXAA.Enabled = $False; $script:MSIXAA = $False; 
            $CBTeams.Checked = $False; $CBTeams.Enabled = $False; $script:Teams = $False; 
            $CBMSRA.Checked = $False; $CBMSRA.Enabled = $False; $script:MSRA = $False; 
            $CBSCard.Checked = $False; $CBSCard.Enabled = $False; $script:SCard = $False; 
            $CBIME.Checked = $False; $CBIME.Enabled = $False; $script:IME = $False; 
            $CBHCI.Checked = $False; $CBHCI.Enabled = $False; $script:HCI = $False; 
            $CBDumpPID.Checked = $False; $CBDumpPID.Enabled = $False; $script:dpid = ""; 
            $CBCore.Checked = $False; $CBCore.Enabled = $False; $script:Core = $False;
        } else { 
            $script:DiagOnly = $False
            $CBProfiles.Enabled = $True; $script:Profiles = $False; 
            $CBMSIXAA.Enabled = $True; $script:MSIXAA = $False;
            $CBTeams.Enabled = $True; $script:Teams = $False;
            $CBMSRA.Enabled = $True; $script:MSRA = $False;
            $CBSCard.Enabled = $True; $script:SCard = $False;
            $CBIME.Enabled = $True; $script:IME = $False;
            $CBHCI.Enabled = $True; $script:HCI = $False;
            $CBDumpPID.Enabled = $True; $script:dpid = "";
            $CBCore.Checked = $True; $CBCore.Enabled = $False; $script:Core = $True;
        } 
    })
    $groupOpt.Controls.Add($CBDiagOnly)

    $CBDumpPID = New-Object System.Windows.Forms.CheckBox
    $CBDumpPID.Text = "DumpPID"
    $CBDumpPID.Location = New-Object System.Drawing.Point(20,230)
    $CBDumpPID.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $CBDumpPID.AutoSize = $True
    $CBDumpPID.Cursor = [System.Windows.Forms.Cursors]::Hand
    $CBDumpPIDToolTip = New-Object System.Windows.Forms.ToolTip
    $CBDumpPIDToolTip.SetToolTip($CBDumpPID, "Dump the process with the corresponding PID")
    $CBDumpPID.Add_CheckStateChanged({ if ($CBDumpPID.Checked) { $dumppidBox.Enabled = $true } else { $dumppidBox.Text = ""; $dumppidBox.Enabled = $false } })
    $groupOpt.Controls.Add($CBDumpPID)

    $dumppidBox = New-Object System.Windows.Forms.TextBox
    $dumppidBox.Location  = New-Object System.Drawing.Point(97,230)
    $dumppidBox.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $dumppidBox.Size  = New-Object System.Drawing.Point(45,30)
    $dumppidBox.AutoSize = $True
    $dumppidBox.Enabled = $False
    $dumppidBox.Text = ""
    $dumppidBox.Cursor = [System.Windows.Forms.Cursors]::Hand
    $dumppidBoxToolTip = New-Object System.Windows.Forms.ToolTip
    $dumppidBoxToolTip.SetToolTip($dumppidBox, "​​​​​​Specify the PID of a process to dump")
    $groupOpt.Controls.Add($dumppidBox)

    $groupOpt2 = New-Object System.Windows.Forms.GroupBox
    $groupOpt2.Text = "Output location"
    $groupOpt2.Location = New-Object System.Drawing.Point(10,345)
    $groupOpt2.Size  = New-Object System.Drawing.Point(150,60)
    $groupOpt2.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $groupOpt2.AutoSize = $True
    $main_form.Controls.Add($groupOpt2)

    $outdirBox = New-Object System.Windows.Forms.TextBox
    $outdirBox.Location  = New-Object System.Drawing.Point(10,30)
    $outdirBox.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $outdirBox.Size  = New-Object System.Drawing.Point(105,40)
    $outdirBox.AutoSize = $True
    if ($OutputDir) { $outdirBox.Text = $OutputDir } else { $outdirBox.Text = "C:\MSDATA" }
    $outdirBox.Enabled = $False
    $groupOpt2.Controls.Add($outdirBox)

    $BPath = New-Object System.Windows.Forms.Button
    $BPath.Location = New-Object System.Drawing.Size(120,31)
    $BPath.Size = New-Object System.Drawing.Size(18,18)
    $BPath.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $BPath.BackColor = "#e6e6e6"
    $BPath.Cursor = [System.Windows.Forms.Cursors]::Hand
    $BPath.Image = [System.IconExtractor]::Extract("shell32.dll", 4, $true)
    $BPath.FlatStyle = "Flat"
    $BPath.FlatAppearance.BorderSize = 0
    $BPathToolTip = New-Object System.Windows.Forms.ToolTip
    $BPathToolTip.SetToolTip($BPath, "​​​​​​Select a custom location to store the collected files")
    $groupOpt2.Controls.Add($BPath)

    $BPath.Add_Click({
        Find-Folder
    })

    $BLaunch = New-Object System.Windows.Forms.Button
    $BLaunch.Location = New-Object System.Drawing.Size(45,455)
    $BLaunch.Size = New-Object System.Drawing.Size(80,25)
    $BLaunch.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $BLaunch.Text = "Start"
    $BLaunch.BackColor = "#e6e6e6"
    $BLaunch.Cursor = [System.Windows.Forms.Cursors]::Hand
    $BLaunchToolTip = New-Object System.Windows.Forms.ToolTip
    $BLaunchToolTip.SetToolTip($BLaunch, "Start the data collection/diagnostic")
    $main_form.Controls.Add($BLaunch)
    $BLaunch.Add_Click({
        $global:LogrootUI = $outdirBox.Text

        if (($global:collectcount -eq 0) -and ($OutputDir) -and ($global:LogrootUI -ne $OutputDir)) { InitFolders }

        if (($global:collectcount -gt 0) -or (!($OutputDir) -and ($global:LogrootUI -ne "C:\MSDATA"))) { InitFolders }
        if ($dumppidBox.Text -ne "") { $global:dpid = $dumppidBox.Text }
        $global:showGUI = $True
        CollectData
    })

    $BExit = New-Object System.Windows.Forms.Button
    $BExit.Location = New-Object System.Drawing.Size(45,490)
    $BExit.Size = New-Object System.Drawing.Size(80,25)
    $BExit.Font = New-Object System.Drawing.Font("MS Shell Dlg", 9)
    $BExit.Text = "Exit"
    $BExit.BackColor = "#e6e6e6"
    $BExit.Cursor = [System.Windows.Forms.Cursors]::Hand
    $BExitToolTip = New-Object System.Windows.Forms.ToolTip
    $BExitToolTip.SetToolTip($BExit, "Close AVD-Collect")
    $main_form.Controls.Add($BExit)
    $BExit.Add_Click({
        if ($global:collectcount -eq 0) { Remove-Item -path $LogDir -Recurse | Out-Null }
        $global:collectcount = 0
        $main_form.Close()
        If (($Null -ne $TempCommandErrorFile) -and (Test-Path -Path $TempCommandErrorFile)) { Remove-Item $TempCommandErrorFile -Force | Out-Null }
        If ($fQuickEditCodeExist) { [DisableConsoleQuickEdit]::SetQuickEdit($False) | Out-Null }
    })

    $objStatusBar = New-Object System.Windows.Forms.StatusBar
    $objStatusBar.Name = "statusBar"
    $objStatusBar.Text = "Ready"
    $main_form.Controls.Add($objStatusBar)

    $psBox = New-Object System.Windows.Forms.RichTextBox
    $psBox.Location  = New-Object System.Drawing.Point(170,40)
    $psBox.Font = New-Object System.Drawing.Font("Consolas", 9)
    $psBox.Size = New-Object System.Drawing.Point(800,500)
    $psBox.AutoSize = $True
    $psBox.Anchor = 'Top,Left,Bottom,Right'
    $psBox.Multiline = $True
    $psBox.ReadOnly = $True
    $psBox.Scrollbars = "Vertical"
    $psBox.BackColor = "#012456"
    $psBox.ForeColor = "White"
    $main_form.Controls.Add($psBox)

    Add-OutputBoxLine "    Select one or more scenario(s) from the left side and click the 'Start' button when ready."
    Add-OutputBoxLine $messageopt

    $main_form.ShowDialog() | Out-Null

}

#endregion GUI

Function CollectData {

    $StopWatchDC = [system.diagnostics.stopwatch]::startNew()

        if (($global:showGUI) -and ($global:LogrootUI -ne "C:\MSDATA")) {
            UEXAVD_LogMessage $LogLevel.Info "Using custom folder path to store the results: $global:LogrootUI"
        }

        if (!($DiagOnly)) {
            if ($global:showGUI) { $objStatusBar.Text = "Collecting Core data. Please wait..." }
            Import-Module -Name ".\Modules\AVD-Collect-Core" -DisableNameChecking
            CollectUEX_AVDCoreLog

            if ($Profiles) { 
                if ($global:showGUI) { $objStatusBar.Text = "Collecting Profiles related data. Please wait..." }
                Import-Module -Name ".\Modules\AVD-Collect-Profiles" -DisableNameChecking
                CollectUEX_AVDProfilesLog
            }
            if ($Teams) { 
                if ($global:showGUI) { $objStatusBar.Text = "Collecting Teams related data. Please wait..." }
                Import-Module -Name ".\Modules\AVD-Collect-Teams" -DisableNameChecking
                CollectUEX_AVDTeamsLog
            }
            if ($MSIXAA) { 
                if ($global:showGUI) { $objStatusBar.Text = "Collecting MSIX App Attach related data. Please wait..." }
                Import-Module -Name ".\Modules\AVD-Collect-MSIXAA" -DisableNameChecking
                CollectUEX_AVDMSIXAALog
            }
            if ($MSRA) { 
                if ($global:showGUI) { $objStatusBar.Text = "Collecting Remote Assistance related data. Please wait..." }
                Import-Module -Name ".\Modules\AVD-Collect-MSRA" -DisableNameChecking
                CollectUEX_AVDMSRALog
            }
            if ($SCard) {
                if ($global:showGUI) { $objStatusBar.Text = "Collecting Smart Card related data. Please wait..." }
                Import-Module -Name ".\Modules\AVD-Collect-SCard" -DisableNameChecking
                CollectUEX_AVDSCardLog
            }
            if ($IME) {
                if ($global:showGUI) { $objStatusBar.Text = "Collecting IME related data. Please wait..." }
                Import-Module -Name ".\Modules\AVD-Collect-IME" -DisableNameChecking
                CollectUEX_AVDIMELog
            }
            if ($HCI) {
                if ($global:showGUI) { $objStatusBar.Text = "Collecting Azure Stack HCI related data. Please wait..." }
                Import-Module -Name ".\Modules\AVD-Collect-HCI" -DisableNameChecking
                CollectUEX_AVDHCILog
            }
        }

        if ($global:showGUI) { $objStatusBar.Text = "Running diagnostics. Please wait..." }
        Import-Module -Name ".\Modules\AVD-Collect-Diag" -DisableNameChecking
        RunUEX_AVDDiag

    #region ##### Archive results #####
    $StopWatchDC.Stop()
    $tsDC =  [timespan]::fromseconds(($StopWatchDC.Elapsed).TotalSeconds)
    $elapsedDC = ("{0:hh\:mm\:ss\.fff}" -f $tsDC)

    "`n`n" | Out-File -Append $OutputLogFile
    UEXAVD_LogMessage $LogLevel.Info "Diagnostics complete - archiving files!" -Color "Cyan"
    UEXAVD_LogMessage $LogLevel.Normal "Data collection/diagnostics duration (hh:mm:ss.fff): $elapsedDC`n"
    $destination = $LogRoot + "\" + $LogFolder + ".zip"

    Compress-Archive -Path $LogDir -DestinationPath $destination -CompressionLevel Optimal -Force
        
    if (Test-path -path $destination) {
            UEXAVD_LogMessage $LogLevel.Normal "Zip file ready: $destination`n" -Color "Green"
        } else {
            UEXAVD_LogMessage $LogLevel.Error "Zip file could not be created. Please manually archive the data collected under: $LogRoot\$LogFolder`n"
        }
        UEXAVD_LogMessage $LogLevel.Normal "Always use a secure file transfer tool when sharing these results with Microsoft CSS. Discuss this with your support professional and also any concerns you may have.`n" -Color "White"
        UEXAVD_LogMessage $LogLevel.Normal "If you have any feedback about this script, send an e-mail to AVDCollectTalk@microsoft.com`n`n" -Color "White"

    explorer $LogRoot

    if ($global:showGUI) {
        $objStatusBar.Text = "Ready"
        $global:collectcount = 1
    }
    
    [System.GC]::Collect()

    #endregion ##### Archive results #####

}


#region ##### MAIN #####

# Disabling quick edit mode as somethimes this causes the script stop working until enter key is pressed.
If ($fQuickEditCodeExist) { [DisableConsoleQuickEdit]::SetQuickEdit($True) | Out-Null }

UEXAVD_LogMessage $LogLevel.Info "Starting AVD-Collect - v$version`n" -Color "Cyan"

if ($AcceptEula) {
    UEXAVD_LogMessage $LogLevel.Info ("AcceptEula switch specified, silently continuing")
    $eulaAccepted = ShowEULAIfNeeded "AVD-Collect" 2
} else {
    $eulaAccepted = ShowEULAIfNeeded "AVD-Collect" 0
    if ($eulaAccepted -ne "Yes") {
        UEXAVD_LogMessage $LogLevel.Info ("EULA declined, exiting")
        UEXAVD_CleanUpandExit
    }
}
UEXAVD_LogMessage $LogLevel.Info ("EULA accepted, continuing")

CheckVersion($version)

$notice = "========= Microsoft CSS Diagnostics Script =========`n
This Data Collection is for troubleshooting reported issues for the given scenarios.
Once you have started this script please wait until all data has been collected.`n`n
============= IMPORTANT NOTICE =============`n
This script is designed to collect information that will help Microsoft Customer Support Services (CSS) troubleshoot an issue you may be experiencing with Azure Virtual Desktop.`n
The collected data may contain Personally Identifiable Information (PII) and/or sensitive data, such as (but not limited to) IP addresses; PC names; and user names.`n
The script will save the collected data in a folder and also compress the results into a ZIP file, both in the same location from where the script has been launched.
This folder and its contents or the ZIP file are not automatically sent to Microsoft.`n
You can send the ZIP file to Microsoft CSS using a secure file transfer tool - Please discuss this with your support professional and also any concerns you may have.`n
Find our privacy statement at: https://privacy.microsoft.com/en-US/privacystatement`n
"

if ($AcceptNotice) {
    UEXAVD_LogMessage $LogLevel.Info "AcceptNotice switch specified, silently continuing`n"
} else { 
    $wshell = New-Object -ComObject Wscript.Shell
    $answer = $wshell.Popup("$notice",0,"Are you sure you want to continue?",4+32)
    if ($answer -eq 7) {
        Write-Host "Script execution not approved by the admin user, exiting.`n"
        Remove-Item -path $LogDir -Recurse | Out-Null
        UEXAVD_CleanUpandExit
    }
}

$global:messageopt = "
    ===================================================================================================
     1) 'Core'           - Collect general AVD troubleshooting data + Run Diagnostics (default)
     2) 'Profiles'       - Collect Profiles specific data (includes 'Core') + Run Diagnostics
     3) 'Teams'          - Collect Teams specific data (includes 'Core') + Run Diagnostics
     4) 'MSIXAA'         - Collect MSIX App Attach specific data (includes 'Core') + Run Diagnostics
     5) 'MSRA'           - Collect Remote Assistance specific data (includes 'Core') + Run Diagnostics
     6) 'SCard'          - Collect Smart Card specific data (includes 'Core') + Run Diagnostics
     7) 'IME'            - Collect Input method specific data (includes 'Core') + Run Diagnostics
     8) 'HCI'            - Collect Azure Stack HCI specific data (includes 'Core') + Run Diagnostics
     9) 'DumpPID'        - Dump the process with the provided PID (includes 'Core') + Run Diagnostics
     D) 'DiagOnly'       - Run 'Diagnostics' only
    ===================================================================================================`n`n
"

if (($NoGUI) -or ($Core) -or ($Profiles) -or ($MSIXAA) -or ($MSRA) -or ($IME) -or ($HCI) -or ($Teams) -or ($SCard) -or ($DiagOnly) -or ($DumpPID)) {
    $global:showGUI = $false
    
    if (!($Core) -and !($Profiles) -and !($MSIXAA) -and !($MSRA) -and !($IME) -and !($HCI) -and !($Teams) -and !($SCard) -and !($DiagOnly) -and !($DumpPID) -and ($NoGUI)) {

        $title = "Please select one of the following AVD-Collect scenarios:"
        $optCore = New-Object System.Management.Automation.Host.ChoiceDescription ' &1-Core ', 'Collect core troubleshooting data without Profiles/Teams/MSIX App Attach/MSRA/Smart Card/IME/HCI related information. + Run Diagnostics'
        $optProfiles = New-Object System.Management.Automation.Host.ChoiceDescription ' &2-Profiles ', 'Collect all troubleshooting data included in the Core scenario and Profiles/FSLogix/OneDrive related data, as available. + Run Diagnostics'
        $optTeams = New-Object System.Management.Automation.Host.ChoiceDescription ' &3-Teams  ', 'Collect all troubleshooting data included in the Core scenario and Teams related information, as data. + Run Diagnostics'
        $optMsixaa = New-Object System.Management.Automation.Host.ChoiceDescription ' &4-MSIXAA ', 'Collect all troubleshooting data included in the Core scenario and MSIX App Attach related data, as available. + Run Diagnostics'
        $optMsra = New-Object System.Management.Automation.Host.ChoiceDescription ' &5-MSRA ', 'Collect all troubleshooting data included in the Core scenario and Remote Assistance related data, as available. + Run Diagnostics'
        $optScard = New-Object System.Management.Automation.Host.ChoiceDescription ' &6-SCard ', 'Collect all troubleshooting data included in the Core scenario and Smart Card related data, as available. + Run Diagnostics'
        $optIME = New-Object System.Management.Automation.Host.ChoiceDescription ' &7-IME ', 'Collect all troubleshooting data included in the Core scenario and input method related data, as available. + Run Diagnostics'
        $optHCI = New-Object System.Management.Automation.Host.ChoiceDescription ' &8-HCI ', 'Collect all troubleshooting data included in the Core scenario and Azure Stack HCI related data, as available. + Run Diagnostics'
        $optDump = New-Object System.Management.Automation.Host.ChoiceDescription ' &9-DumpPID ', 'Collect all troubleshooting data included in the Core scenario and a memory dump of the process with the provided PID, as available. + Run Diagnostics'
        $optDiag = New-Object System.Management.Automation.Host.ChoiceDescription ' &DiagOnly ', 'Only run Diagnostics and log the results. It may collect information about crashes and process hangs, AVD agent, MSIX App Attach or FSLogix related issues, if found.'

        $options = [System.Management.Automation.Host.ChoiceDescription[]]($optCore, $optProfiles, $optTeams, $optMsixaa, $optMsra, $optScard, $optIME, $optHCI, $optDump, $optDiag)
        $result = $host.ui.PromptForChoice($title, $messageopt, $options, 0)

        switch ($result) {
            0 { UEXAVD_LogMessage $LogLevel.Info ("'Core' scenario selected."); $script:Core = $True }
            1 { UEXAVD_LogMessage $LogLevel.Info ("'Core + Profiles' scenario selected."); $script:Profiles = $True }
            2 { UEXAVD_LogMessage $LogLevel.Info ("'Core + Teams' scenario selected."); $script:Teams = $True }
            3 { UEXAVD_LogMessage $LogLevel.Info ("'Core + MSIX App Attach' scenario selected."); $script:MSIXAA = $True }
            4 { UEXAVD_LogMessage $LogLevel.Info ("'Core + MSRA' scenario selected."); $script:MSRA = $True }
            5 { UEXAVD_LogMessage $LogLevel.Info ("'Core + Smart Card' scenario selected."); $script:SCard = $True }
            6 { UEXAVD_LogMessage $LogLevel.Info ("'Core + IME' scenario selected."); $script:IME = $True }
            7 { UEXAVD_LogMessage $LogLevel.Info ("'Core + HCI' scenario selected."); $script:HCI = $True }
            8 { UEXAVD_LogMessage $LogLevel.Info ("'Core + DumpPID' scenario selected."); 
                [uint16]$enterpid = Read-Host -Prompt "Please enter the PID of the process you want to dump: "
                $global:dpid = $enterpid
              }
            9 { UEXAVD_LogMessage $LogLevel.Info ("'Diagnostics Only' scenario selected."); $script:DiagOnly = $True }
        }
    }

    CollectData

} else {

    AVDCollectGUI

}

#endregion ##### MAIN #####

# SIG # Begin signature block
# MIIntwYJKoZIhvcNAQcCoIInqDCCJ6QCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDYxhOllV3jdNmG
# de5GarlG1t1NMNnyyWvDrqco8G3Br6CCDYEwggX/MIID56ADAgECAhMzAAACUosz
# qviV8znbAAAAAAJSMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjEwOTAyMTgzMjU5WhcNMjIwOTAxMTgzMjU5WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDQ5M+Ps/X7BNuv5B/0I6uoDwj0NJOo1KrVQqO7ggRXccklyTrWL4xMShjIou2I
# sbYnF67wXzVAq5Om4oe+LfzSDOzjcb6ms00gBo0OQaqwQ1BijyJ7NvDf80I1fW9O
# L76Kt0Wpc2zrGhzcHdb7upPrvxvSNNUvxK3sgw7YTt31410vpEp8yfBEl/hd8ZzA
# v47DCgJ5j1zm295s1RVZHNp6MoiQFVOECm4AwK2l28i+YER1JO4IplTH44uvzX9o
# RnJHaMvWzZEpozPy4jNO2DDqbcNs4zh7AWMhE1PWFVA+CHI/En5nASvCvLmuR/t8
# q4bc8XR8QIZJQSp+2U6m2ldNAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUNZJaEUGL2Guwt7ZOAu4efEYXedEw
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDY3NTk3MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAFkk3
# uSxkTEBh1NtAl7BivIEsAWdgX1qZ+EdZMYbQKasY6IhSLXRMxF1B3OKdR9K/kccp
# kvNcGl8D7YyYS4mhCUMBR+VLrg3f8PUj38A9V5aiY2/Jok7WZFOAmjPRNNGnyeg7
# l0lTiThFqE+2aOs6+heegqAdelGgNJKRHLWRuhGKuLIw5lkgx9Ky+QvZrn/Ddi8u
# TIgWKp+MGG8xY6PBvvjgt9jQShlnPrZ3UY8Bvwy6rynhXBaV0V0TTL0gEx7eh/K1
# o8Miaru6s/7FyqOLeUS4vTHh9TgBL5DtxCYurXbSBVtL1Fj44+Od/6cmC9mmvrti
# yG709Y3Rd3YdJj2f3GJq7Y7KdWq0QYhatKhBeg4fxjhg0yut2g6aM1mxjNPrE48z
# 6HWCNGu9gMK5ZudldRw4a45Z06Aoktof0CqOyTErvq0YjoE4Xpa0+87T/PVUXNqf
# 7Y+qSU7+9LtLQuMYR4w3cSPjuNusvLf9gBnch5RqM7kaDtYWDgLyB42EfsxeMqwK
# WwA+TVi0HrWRqfSx2olbE56hJcEkMjOSKz3sRuupFCX3UroyYf52L+2iVTrda8XW
# esPG62Mnn3T8AuLfzeJFuAbfOSERx7IFZO92UPoXE1uEjL5skl1yTZB3MubgOA4F
# 8KoRNhviFAEST+nG8c8uIsbZeb08SeYQMqjVEmkwggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIZjDCCGYgCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAlKLM6r4lfM52wAAAAACUjAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgXgfLVtDd
# al2Ea9P5cwpDNUbssoqid9LYAWTH5Jz/GacwQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQANXHYFTzt7uxbrM8uuVbXLTfrOUJQNljkUIwxAXZVH
# x0MuUmHZIr7xN0XL0a1UqDiXCnC3xj57K4j9yR0oXh8oEHrBK9o/prsFKcl+HS+b
# ugF7XXx9DZI/B+De5evNKosbFnYiiXJeCoTjngFRWI5nN3O8WmgzP1Uzi9DZSI19
# QGGtekjfUNdHhEXXKQRqhcGxurJHCfNhKUssD/ACgC6OmpG9DEc8FPUZBSVobxl8
# 3FgI8hyhHuS15K75SLB4A7shKLuU/kbHUsDz0phT3Tnjep1NXwh+Ilvzf/qrrG/c
# K8FazL3BVHKZcFVxSPBXMR8qyleMd7EnkITJZvUfjo24oYIXFjCCFxIGCisGAQQB
# gjcDAwExghcCMIIW/gYJKoZIhvcNAQcCoIIW7zCCFusCAQMxDzANBglghkgBZQME
# AgEFADCCAVkGCyqGSIb3DQEJEAEEoIIBSASCAUQwggFAAgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIG3gb/Is4MoHoLnkKYascHMtdWIxVUYTP+jF2Kqm
# X2+ZAgZibESKmrsYEzIwMjIwNTE5MDUzODQyLjY2NlowBIACAfSggdikgdUwgdIx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1p
# Y3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhh
# bGVzIFRTUyBFU046MkFENC00QjkyLUZBMDExJTAjBgNVBAMTHE1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFNlcnZpY2WgghFlMIIHFDCCBPygAwIBAgITMwAAAYZ45RmJ+CRL
# zAABAAABhjANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMDAeFw0yMTEwMjgxOTI3MzlaFw0yMzAxMjYxOTI3MzlaMIHSMQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQg
# SXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1Mg
# RVNOOjJBRDQtNEI5Mi1GQTAxMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
# cCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAwI3G2Wpv
# 6B4IjAfrgfJpndPOPYO1Yd8+vlfoIxMW3gdCDT+zIbafg14pOu0t0ekUQx60p7Pa
# dH4OjnqNIE1q6ldH9ntj1gIdl4Hq4rdEHTZ6JFdE24DSbVoqqR+R4Iw4w3GPbfc2
# Q3kfyyFyj+DOhmCWw/FZiTVTlT4bdejyAW6r/Jn4fr3xLjbvhITatr36VyyzgQ0Y
# 4Wr73H3gUcLjYu0qiHutDDb6+p+yDBGmKFznOW8wVt7D+u2VEJoE6JlK0EpVLZus
# dSzhecuUwJXxb2uygAZXlsa/fHlwW9YnlBqMHJ+im9HuK5X4x8/5B5dkuIoX5lWG
# jFMbD2A6Lu/PmUB4hK0CF5G1YaUtBrME73DAKkypk7SEm3BlJXwY/GrVoXWYUGEH
# yfrkLkws0RoEMpoIEgebZNKqjRynRJgR4fPCKrEhwEiTTAc4DXGci4HHOm64EQ1g
# /SDHMFqIKVSxoUbkGbdKNKHhmahuIrAy4we9s7rZJskveZYZiDmtAtBt/gQojxbZ
# 1vO9C11SthkrmkkTMLQf9cDzlVEBeu6KmHX2Sze6ggne3I4cy/5IULnHZ3rM4ZpJ
# c0s2KpGLHaVrEQy4x/mAn4yaYfgeH3MEAWkVjy/qTDh6cDCF/gyz3TaQDtvFnAK7
# 0LqtbEvBPdBpeCG/hk9l0laYzwiyyGY/HqMCAwEAAaOCATYwggEyMB0GA1UdDgQW
# BBQZtqNFA+9mdEu/h33UhHMN6whcLjAfBgNVHSMEGDAWgBSfpxVdAF5iXYP05dJl
# pxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAx
# MCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUtU3Rh
# bXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMA0GCSqGSIb3DQEBCwUAA4ICAQDD7mehJY3fTHKC4hj+wBWB8544
# uaJiMMIHnhK9ONTM7VraTYzx0U/TcLJ6gxw1tRzM5uu8kswJNlHNp7RedsAiwviV
# QZV9AL8IbZRLJTwNehCwk+BVcY2gh3ZGZmx8uatPZrRueyhhTTD2PvFVLrfwh2li
# DG/dEPNIHTKj79DlEcPIWoOCUp7p0ORMwQ95kVaibpX89pvjhPl2Fm0CBO3pXXJg
# 0bydpQ5dDDTv/qb0+WYF/vNVEU/MoMEQqlUWWuXECTqx6TayJuLJ6uU7K5QyTkQ/
# l24IhGjDzf5AEZOrINYzkWVyNfUOpIxnKsWTBN2ijpZ/Tun5qrmo9vNIDT0lobgn
# ulae17NaEO9oiEJJH1tQ353dhuRi+A00PR781iYlzF5JU1DrEfEyNx8CWgERi90L
# KsYghZBCDjQ3DiJjfUZLqONeHrJfcmhz5/bfm8+aAaUPpZFeP0g0Iond6XNk4YiY
# bWPFoofc0LwcqSALtuIAyz6f3d+UaZZsp41U4hCIoGj6hoDIuU839bo/mZ/AgESw
# GxIXs0gZU6A+2qIUe60QdA969wWSzucKOisng9HCSZLF1dqc3QUawr0C0U41784K
# o9vckAG3akwYuVGcs6hM/SqEhoe9jHwe4Xp81CrTB1l9+EIdukCbP0kyzx0WZzte
# eiDN5rdiiQR9mBJuljCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUw
# DQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
# dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhv
# cml0eSAyMDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIyNVowfDELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg
# 4r25PhdgM/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aO
# RmsHFPPFdvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41
# JmTamDu6GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v3byNpOORj7I5
# LFGc6XBpDco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL
# 64NF50ZuyjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viSkR4dPf0gz3N9
# QZpGdc3EXzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj
# 0XOmTTd0lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlMjgK8QmguEOqE
# UUbi0b1qGFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0
# kZSU2LlQ+QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AFemzFER1y7435
# UsSFF5PAPBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIurQIDAQABo4IB
# 3TCCAdkwEgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTE
# mr6CkTxGNSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwG
# A1UdIARVMFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93
# d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNV
# HSUEDDAKBggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNV
# HQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo
# 0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29m
# dC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5j
# cmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDAN
# BgkqhkiG9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4
# sQaTlz0xM7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN3Zi6th54
# 2DYunKmCVgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRX
# ud2f8449xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBew
# VIVCs/wMnosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0
# DLzskYDSPeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB62FD+Cljd
# QDzHVG2dY3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/HltEAY5aGZFr
# DZ+kKNxnGSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFh
# bHP+CrvsQWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7n
# tdAoGokLjzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+
# oDEzfbzL6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6Fw
# ZvKhggLUMIICPQIBATCCAQChgdikgdUwgdIxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046MkFENC00Qjky
# LUZBMDExJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoB
# ATAHBgUrDgMCGgMVAAGu2DRzWkKljmXySX1korHL4fMnoIGDMIGApH4wfDELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwDQYJKoZIhvcNAQEFBQACBQDmL85WMCIY
# DzIwMjIwNTE5MDM1ODE0WhgPMjAyMjA1MjAwMzU4MTRaMHQwOgYKKwYBBAGEWQoE
# ATEsMCowCgIFAOYvzlYCAQAwBwIBAAICCmMwBwIBAAICEVAwCgIFAOYxH9YCAQAw
# NgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgC
# AQACAwGGoDANBgkqhkiG9w0BAQUFAAOBgQBRWVrnlWWGuTHdiDlgNVhV+PuxhMOE
# fwHpMGK6iFP/aveAccT14pftdyzdvB0mMRKqqwhPJGqu2r4eiWbjBWz/hdFeI2mg
# Q4tyt4dZTEadMz10WDaUQxSbC4FS5sqJv5tH6J4esD9ddPB1uamCxjwVCp9U4mBM
# fbT/5YpjZ2Z7vjGCBA0wggQJAgEBMIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
# QSAyMDEwAhMzAAABhnjlGYn4JEvMAAEAAAGGMA0GCWCGSAFlAwQCAQUAoIIBSjAa
# BgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEICXc2m9g
# yd58HkpupKfFMYEFI5iZdX216Sz8VKVo0lYVMIH6BgsqhkiG9w0BCRACLzGB6jCB
# 5zCB5DCBvQQgGpmI4LIsCFTGiYyfRAR7m7Fa2guxVNIw17mcAiq8Qn4wgZgwgYCk
# fjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
# Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAYZ45RmJ+CRLzAAB
# AAABhjAiBCAURJT1MddR726a4gUswAF2yYKXrTapknQuun+woueHyDANBgkqhkiG
# 9w0BAQsFAASCAgB3X8sUyHvsP5pRdaMR2jYoUAmJGuBegwDBt1YlzadzH5YL6ajJ
# DuhOat3Hv0/ZScvdv6eMbzaEfLArb3WGxjJ2pMDK7AU3Zcrs7zIH8UUMnRP88kFz
# XczpbotKaNNZiSmnakNCqMlgzY15ozkXpqfNjcy7hgYCY/yuY75y/JBGW0JMY0fJ
# RkSRzEth8GfiLwgg3DDnBEIJK0H6YdZkvZJ4uTnaM4ftVP3urziRXrwMiaftROHS
# Y3uiPZ7UcGSKkk8ZZkXo5mpSHLxcKv0tSSlu0od1xZAe9TzBLB54bBC08iUfutob
# TzsRxc/RsnpuZoyfwv4yCUxkv6PZ/DzZ/Yw82MX/hMrBgh84VmZ6ljl1dk+Hqw7T
# XdxeGOX4qh7ITDPWtvnXq9vmqjoJiBBPnO2Kbseq7oA7xb6k2/6hlhCTsQxIIgmG
# EbjJELTg1qE6NgzQrz/37PBb8fhlOPR/y2IttdAJioGXdmlY8UrYPR2CoYk34FeS
# bLHySqxqb2AgXal9f5XbigLg2Pt9lKoOcOTDHBP7ciC3DQ2GN5BywWrOx5U0sYv+
# E55lfo0/zldVsck/bGplo/5UFtVugD5ieyUmHggLLtXNPQF3YAzpPlniu6EJ1lDV
# 8T7YrfKCUvTij3ZZezVW6rQWOpA0eego6uH2pvMo5v1oqgGfq7adZH9IBQ==
# SIG # End signature block
