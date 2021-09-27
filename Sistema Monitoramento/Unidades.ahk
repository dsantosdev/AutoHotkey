/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\users\dsantos\desktop\executáveis\Relatórios.exe
Created_Date=1
Run_After="C:\Users\dsantos\Desktop\Executáveis\AHK2BD.exe "Relatórios" "0.0.0.4" """
[VERSION]
Set_Version_Info=1
File_Version=0.0.0.3
Inc_File_Version=1
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\Dih\zIco\compiler.ico

* * * Compile_AHK SETTINGS END * * *
*/

;@Ahk2Exe-SetMainIcon C:\Dih\zIco\2LembEdit.ico

#IfWinActive	Relatórios
	#SingleInstance	Force
	#Persistent
	#Include	..\class\alarm.ahk
	; #Include	..\class\array.ahk
	#Include	..\class\functions.ahk
	#Include	..\class\gui.ahk
	; #Include	..\class\safedata.ahk
	#Include	..\class\sql.ahk
	; #Include	..\class\windows.ahk
;

;	Local vars
	WinGetPos,,,,taskbar, ahk_class Shell_TrayWnd

;

; Global Vars
	global	zona
;

;	Config
	if ( A_UserName != "dsantos" )	{
		d	= Hidden
		c	=
		Menu,	Tray,	Nostandard
	}
	Else	{
		c	=	Checked
		d	=
	}
	AutoTrim,	On
;

;	INTERFACE
		Gui.Cores()
	Gui, -Caption -Border
		Gui.Font( "S10" , "Bold" , "cWhite" )
	Gui, Add, Edit,		 x10	y10		w380						h25								Section	0x1000			g_busca	, 
	Gui, Add, ListView,	 xs				w380						h190									0x1000					, Unidade|id
		LV_ModifyCol( 2 , 0 )
	Gui, Add, Text,%	"		ys		w" A_ScreenWidth-410 "		h25						Center	Section	0x1000"					, Unidade
	Gui, Add, Text,%	"xs				w"(A_ScreenWidth-421)/2 "	h190							Section	0x1000"					, Endereços
	Gui, Add, Text,%	"		ys		w"(A_ScreenWidth-421)/2 "	h190									0x1000"					, Notas
	Gui, Add, Tab2,%	"x10	y245	w" A_ScreenWidth-17 "		h" A_ScreenHeight-taskbar-250 "	Bottom	0x1000	vtab	g_tab"	, Emergência|Mapas|Fechar
	Gui, Show,%			"x0		y0		w" A_ScreenWidth	"		h" A_ScreenHeight-taskbar										, Relatórios
return

_tab:
	Gui, Submit, NoHide
	if ( tab = "Fechar" )
		ExitApp
Return

_busca:
	Gui, Submit, NoHide
	search_delay()
	Gui, Submit, NoHide
	if ( StrLen( busca ) > "0" )
		MsgBox % busca
return

SelectLV:
	Gui, Submit, NoHide
	If ( A_GuiEvent = "S" )
		Return
	Gui, ListView,	eventos
	row	:=	LV_GetNext()
	if ( row = 0 )
		row = 1
	if ( lastrow = row )
		return
	if (	A_GuiEvent = Normal
		||	A_GuiEvent = K	)
		row := A_EventInfo
	lastrow := row
	LV_GetText(	operador_final	, row,	2	)
	LV_GetText(	relatorio		, row,	3	)
	LV_GetText(	end				, row,	6	)
	LV_GetText(	start			, row,	7	)
	LV_GetText(	id_cliente		, row,	8	)
	LV_GetText(	ev_final		, row,	9	)
return

;	Preenche Lista de Unidades
	s =
		(
		
		)

;

~Enter::
	~NumpadEnter::
	Gui,	Submit,	NoHide
	;	goto	s_mes
;

Esc::
	GuiClose:
	ExitApp
;