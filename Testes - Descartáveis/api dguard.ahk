File_Version=0.0.0
Save_To_Sql=0
;@Ahk2Exe-SetMainIcon C:\AHK\icones\pc.ico

;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\auth.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cameras.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\date.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\file.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\folder.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\sync_data.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

token	:=	Dguard.token( "192.9.100.111" )
var		:=	Dguard.layouts( "192.9.100.111", token )

loop,% var.layouts.count()
	If	RegExMatch( var.layouts[A_Index].name, "Layout" )
		MsgBox	%		var.layouts[A_Index].guid