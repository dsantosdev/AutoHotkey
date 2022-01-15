/*
	* * * Compile_AHK SETTINGS BEGIN * * *
	[AHK2EXE]
		Exe_File=C:\users\dsantos\desktop\executáveis\Cria Unidades.exe
		Created_Date=1
	[VERSION]
		Set_Version_Info=1
		Company_Name=Heimdall
		File_Description=
		File_Version=0.0.0.1
		Inc_File_Version=1
		Product_Name=Cria Unidades
		Product_Version=1.1.33.2
		Set_AHK_Version=1
	* * * Compile_AHK SETTINGS END * * *
*/

;	Includes
	; #Include ..\class\alarm.ahk
	; #Include ..\class\array.ahk
	; #Include ..\class\base64.ahk
	; #Include ..\class\convert.ahk
	; #Include ..\class\cor.ahk
	; #Include ..\class\dguard.ahk
	; #Include ..\class\functions.ahk
	; #Include ..\class\gui.ahk
	; #Include ..\class\listview.ahk
	; #Include ..\class\mail.ahk
	; #Include ..\class\safedata.ahk
	#Include ..\class\sql.ahk
	; #Include ..\class\string.ahk
	; #Include ..\class\telegram.ahk
	; #Include ..\class\windows.ahk
;

;	-Arrays
	;
;

;	Configurações
	; #NoTrayIcon
	#SingleInstance, Force
	SetBatchLines, -1
	CoordMode,	Window
	show_tooltip	:=	A_Args[1]	;	recebe o argumento 1 para exibir
		if ( A_UserName = "dsantos" )
			show_tooltip = 1
	if ( A_IsCompiled = 1 )
		ext	=	exe
	Else
		ext = ahk
	Return

;

;	-Variáveis
	;
;

;	-Login
	;
;

;	-Interface
	;
;

;	-Code
F1::
	s =
		(
			SELECT nm_unidade, id_entreposto
			FROM   [ASM].[dbo].[_unidades]
			WHERE  id_entreposto IS NOT NULL and nm_unidade not in  ('frota','Passo Fundo - Viveiro')
			ORDER  BY 1
		)
	unidades := sql( s , 3 )
	Loop,%	unidades.Count()-1	{
		WinActivate, admin@localhost - The Dude 3.6
		sleep, 200
		Click, 402, 84 Left	3	;	Add New
		WinActivate, New Network Map
		WinWaitActive, New Network Map
		Sleep, 400
		Click, 30, 45 Left
		Sleep, 200
		ControlSetText, Edit1
		Sleep, 100
		ControlSetText, Edit1,% unidades[ A_Index+1 , 1 ] "|" unidades[ A_Index+1 , 2 ], New Network Map
		Click, 135, 103 Left
		Sleep, 10
		Send, F{Enter}
		Sleep, 200
		Click, 135, 40 Left	3	;	Select Color tab
		Sleep, 200
		Click, 175, 155 Left 2	;	Open Cor selection
		Sleep, 100
		WinWaitActive, Cor
		Sleep, 200
		Click, 23, 168 Left		;	Select Black Color
		Sleep, 100
		Click, 41, 306 Left		;	Ok Button
		WinWaitActive, New Network Map
		Sleep, 100
		Click, 1881, 47 Left	;	Ok(END)
		Sleep, 200
	}
	ExitApp

F2::
	
	Loop,	70 {
		WinActivate, Network Maps
		Sleep 100
		Send {Down 2}{Enter}
		Loop	{
			WinGetActiveTitle, new
			if ( new != "Network Maps" )
				Break
		}
		Sleep, 100
		ControlGetText, id, Edit1, % new
		id := SubStr( id, InStr(id, "|", , 0 )+1 )
		if ( id = 1 ) {
			Click, 1880, 50 Left
			Continue
		}
		Click, 100, 250 Left
		WinWaitActive, New Discover Info
		Sleep, 100
		ControlSetText, Edit1,% "10.2."id ".201-10.2." id ".239" , New Discover Info
		Click, 350, 50 Left
		Sleep, 100
		Click, 1880, 50 Left
	}
Return
F3::
	Loop, 70 {
		Click, 455, 146	Left
		Sleep, 300
		Send {Delete}
		WinWait, Confirm Network Map Remove
		Sleep, 50
		Send {Enter}
		Sleep, 500
	}
Return
F4::
	y = 150
	x = 500
	Loop, 70	{
		WinActivate, admin@localhost - The Dude 3.6
		Sleep, 300
		Click, 422, 85 Left
		Sleep, 300
		Send, {Down 3}{Enter}
		Sleep, 200
		if A_Index in 11,21,31,41,51,61
		{
			x +=	170
			y =		150
		}
		Else if ( A_Index = 1 )
			y =		150
		Else
			y +=	40
		Click, %x%, %y% Left
		Sleep, 200
		WinActivate,	Add Submap
		WinWaitActive,	Add Submap
		Sleep, 200
		Send, {Tab}{Space}
		WinWaitActive,	Add Submap
		if ( A_Index > 1 )	{
			Send, {Down %A_Index%}
			if ( A_Index > 25 )
				Sleep, 500
			Send, {Enter}{Tab 2}{Enter}
		}	Else
			Send, {Tab 2}{Enter}
		Sleep, 100
	}
Return
;



;	-GuiClose
	;
;

END::
	ExitApp
	