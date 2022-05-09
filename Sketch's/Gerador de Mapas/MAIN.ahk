/*
	* * * Compile_AHK SETTINGS BEGIN * * *
	[AHK2EXE]
		Exe_File=C:\users\dsantos\desktop\executáveis\MAIN.exe
		Created_Date=1
	[VERSION]
		Set_Version_Info=1
		Company_Name=Heimdall
		File_Description=
		File_Version=0.0.0.1
		Inc_File_Version=1
		Product_Name=Configurador de Mapas
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
	; #Include ..\class\safe_data.ahk
	; #Include ..\class\sql.ahk
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

	show_tooltip	:=	A_Args[1]	;	recebe o argumento 1 para exibir
		if ( A_UserName = "dsantos" )
			show_tooltip = 1
		CoordMode, ToolTip, Screen

	;	Utilizado para chamar outras aplicações
		if ( A_IsCompiled = 1 )
			ext	=	exe
		Else
			ext = ahk
	;

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

;	Core
	;	Gui
		Gui, Main:Add, Picture, x0 y0 gCriarElemento, \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\mapz\52.jpg
		Gui, Main:Show
		return
	;

	;	Code
		CriarElemento:
			MouseGetPos, x, y
			Gui, Main:Add, Picture, x%x% y%y% w50 h50 vpic, C:\AHK\ico\2autadd.png
			GuiControl, , Main:pic, C:\AHK\ico\2autadd.png w50 h50 x%x% y%y%
			Gui, Main:Submit, NoHide
		Return
	;
;

;	GuiClose
	MainGuiClose:
		ExitApp
;
