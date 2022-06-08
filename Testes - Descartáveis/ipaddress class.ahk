File_Version=0.0.0
Save_To_Sql=0
;@Ahk2Exe-SetMainIcon C:\AHK\icones\pc.ico

#Include C:\Users\dsantos\Desktop\AutoHotkey\class\ipcontrol.ahk

Gui, +LastFound
guiID := WinExist()
OnMessage(78,"IPAddress_WMNotify") ;ref: http://msdn.microsoft.com/en-us/library/bb761376

IP1 := IPAddress_Control(guiID, 10, 10, 150, 20)     ;Lib format
IP2 := IPAddress_Control(guiID, 10, 50, 150, 20)
IP3 := new IPAddress_Control(guiID, 10, 90, 150, 20) ;Class format
If !IsObject(IP1)
	Quit(IP1)

Gui, Add, Text, x170 y52, <-- Range maximum set to 127
Loop 4
	IP2.SetRange(A_Index,0,127)
Gui, Add, Button, x170 y10 gGet_IP1_Value Default, <-- Get Value / Clear

Gui, Add, Button, x10 y200 w50 gGuiClose, E&xit
Gui, Add, StatusBar,, WM_Notify notifications
Gui, Add, Text, x10 y130, WM Notify Ref`:
Gui, Font, cBlue Underline
Gui, Add, Text, yp x+7 cBlue gRef1, http://msdn.microsoft.com/en-us/library/bb761376
Gui, Show, w400, IP Address Demo

IP1.SetAddress("192.168.0.11"), IP2.SetAddress("127.0.0.1"), IP3.SetAddress("192.168.100.99")
IP1.SetFocus(1)
Return

GuiEscape:
GuiClose:
ExitApp

Get_IP1_Value:
	MsgBox % IP1.GetAddress() . " (" . IP1.GetAddress("Integer") . ")"
	IP1.ClearAddress()
Return

Ref1: 
Run, http://msdn.microsoft.com/en-us/library/bb761376
return

Quit(Msg) {
MsgBox % Msg
ExitApp	
}

IPAddress_WMNotify(wParam, lParam, msg, hwnd)
{
    global IP1,IP2,IP3
	hwndFrom := NumGet(lParam+0, 0, "Ptr")
	if (hwndFrom = IP1.hwnd || hwndFrom = IP2.hwnd || hwndFrom = IP3.hwnd)
		{
		; idFrom   := NumGet(lParam+0, A_PtrSize, "Ptr")
		; code     := NumGet(lParam+0, 2*A_PtrSize, "UInt")
		iField   := NumGet(lParam+0, 2*A_PtrSize+4, "Int")
		iValue   := NumGet(lParam+0, 2*A_PtrSize+8, "Int")
		SB_SetText("WM_Notify :   Handle = " hwndFrom "    Field = " iField+1 "   Value = " iValue)
		}
}
;
