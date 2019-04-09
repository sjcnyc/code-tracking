$typeDef = @"
Imports System
Imports System.Runtime.InteropServices

Public Class WinAPI
    <FlagsAttribute> _
    Public Enum EXECUTION_STATE As UInteger
        ES_AWAYMODE_REQUIRED = &H40
        ES_CONTINUOUS        = &H80000000UI
        ES_DISPLAY_REQUIRED  = &H2
        ES_SYSTEM_REQUIRED   = &H1
        ES_USER_PRESENT      = &H4 ' Do not use, here for legacy support
    End Enum
 
    <DllImport("kernel32.dll", CharSet:=CharSet.Auto, SetLastError:=True)> _
    Public Shared Function SetThreadExecutionState(esFlags As EXECUTION_STATE) As EXECUTION_STATE
    End Function
 
    Public Shared Sub PreventMonitorPowerdown()
        SetThreadExecutionState(EXECUTION_STATE.ES_DISPLAY_REQUIRED Or EXECUTION_STATE.ES_CONTINUOUS)
    End Sub
 
    Public Shared Sub AllowMonitorPowerdown()
        SetThreadExecutionState(EXECUTION_STATE.ES_CONTINUOUS)
    End Sub
 
    Public Shared Sub PreventSleep()
        ' Prevent Idle-to-Sleep (monitor not affected)
        SetThreadExecutionState(EXECUTION_STATE.ES_CONTINUOUS Or EXECUTION_STATE.ES_AWAYMODE_REQUIRED)
    End Sub
 
    Public Shared Sub KeepSystemAwake()
        SetThreadExecutionState(EXECUTION_STATE.ES_SYSTEM_REQUIRED)
    End Sub

    <StructLayout(LayoutKind.Sequential)> _
    Public Structure LASTINPUTINFO
        <MarshalAs(UnmanagedType.U4)> _
        Public cbSize As Integer
        <MarshalAs(UnmanagedType.U4)> _
        Public dwTime As Integer
    End Structure
 
    <DllImport("user32.dll")> _
    Public Shared Function GetLastInputInfo(ByRef plii As LASTINPUTINFO) As Boolean
    End Function
 
    Public Shared Function GetLastInputTime() As Integer
        Dim idletime As Integer = 0
        Dim lastInputInf As New LASTINPUTINFO
        lastInputInf.cbSize = Marshal.SizeOf(lastInputInf)
        lastInputInf.dwTime = 0
 
        If GetLastInputInfo(lastInputInf) Then
            idletime = Environment.TickCount - lastInputInf.dwTime
        End If
 
        If idletime > 0 Then
            Return idletime / 1000
        Else
            Return 0
        End If
    End Function
End Class
"@
 
Add-Type -Language VisualBasic -TypeDefinition $typeDef

[winapi]::KeepSystemAwake()

while (-not (Start-Sleep -Seconds 1)) {
    "Idle Timer: {0}" -f [WinAPI]::GetLastInputTime()
}