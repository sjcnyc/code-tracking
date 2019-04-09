$typeDef = @"
Imports System
Imports System.Drawing
Imports System.Runtime.InteropServices
 
Namespace Tools
  Public Class Mouse
    <DllImport("user32.dll")> _
    Public Shared Function GetCursorPos(ByRef lpPoint As Point) As Integer
    End Function
 
    <DllImport("user32.dll")> _
    Public Shared Function SetCursorPos(ByVal x As Integer, ByVal y As Integer) As Integer
    End Function
 
    Private Declare Sub mouse_event Lib "user32" Alias "mouse_event" (ByVal dwFlags As MouseFlags, ByVal dx As Integer, ByVal dy As Integer, ByVal cButtons As Integer, ByVal dwExtraInfo As Integer)
 
    Private Enum MouseFlags As Integer
      LEFTDOWN   = &H2
      LEFTUP     = &H4
      MIDDLEDOWN = &H20
      MIDDLEUP   = &H40
      RIGHTDOWN  = &H8
      RIGHTUP    = &H10
    End Enum
 
    Public Shared Sub LeftDown()
      mouse_event(MouseFlags.LEFTDOWN, 0, 0, 0, 0)
    End Sub
    Public Shared Sub LeftUp()
      mouse_event(MouseFlags.LEFTUP, 0, 0, 0, 0)
    End Sub
    Public Shared Sub LeftClick()
      LeftDown()
      LeftUp()
    End Sub
    Public Shared Sub DoubleClick()
      LeftClick()
      LeftClick()
    End Sub

    Public Shared Sub MiddleDown()
      mouse_event(MouseFlags.MIDDLEDOWN, 0, 0, 0, 0)
    End Sub
    Public Shared Sub MiddleUp()
      mouse_event(MouseFlags.MIDDLEUP, 0, 0, 0, 0)
    End Sub
    Public Shared Sub MiddleClick()
      MiddleDown()
      MiddleUp()
    End Sub
 
    Public Shared Sub RightDown()
      mouse_event(MouseFlags.RIGHTDOWN, 0, 0, 0, 0)
    End Sub
    Public Shared Sub RightUp()
      mouse_event(MouseFlags.RIGHTUP, 0, 0, 0, 0)
    End Sub
    Public Shared Sub RightClick()
      RightDown()
      RightUp()
    End Sub
 
    Public Shared Function GetPosition() As Point
      Dim temp As New Point
      GetCursorPos(temp)
      Return temp
    End Function
 
    Public Shared Sub SetPosition(ByVal newPos As Point)
      SetPosition(newPos.X, newPos.Y)
    End Sub
    Public Shared Sub SetPosition(ByVal x As Integer, ByVal y As Integer)
      SetCursorPos(x, y)
    End Sub
  End Class
End Namespace
"@
 
Add-Type -Language VisualBasic -TypeDefinition $typeDef -ReferencedAssemblies System.Drawing

$mousePos = [Tools.Mouse]::GetPosition()
[Tools.Mouse]::SetPosition($mousePos.X + 10, $mousePos.Y + 10)
[Tools.Mouse]::RightClick()