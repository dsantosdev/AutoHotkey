/*
	* * * Compile_AHK SETTINGS BEGIN * * *
	[AHK2EXE]
		Exe_File=C:\users\dsantos\desktop\executáveis\gui - unidades.exe
		Created_Date=1
	[VERSION]
		Set_Version_Info=1
		Company_Name=Heimdall
		File_Description=
		File_Version=0.0.0.1
		Inc_File_Version=1
		Product_Name=gui - unidades
		Product_Version=1.1.33.2
		Set_AHK_Version=1
	* * * Compile_AHK SETTINGS END * * *
*/


;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safedata.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

;	Arrays
;

;	Configurações
	; #NoTrayIcon
	#SingleInstance, Force

	show_tooltip	:=	A_Args[1]	;	recebe o argumento 1 para exibir
		if ( A_UserName = "dsantos" )
			show_tooltip = 1
		CoordMode, ToolTip, Screen

	if ( A_IsCompiled = 1 )
		ext	=	exe
	Else
		ext = ahk

;

;	Variáveis
	w	:=	A_ScreenWidth		;	width
	SysGet,	t,	31				;	Title bar Size
	h	:=	A_ScreenHeight - t	;	heigth - title
;

;	Login
;

;	Interface
	Gui,	Add,	Edit,%		"x5							  w" w/5*1	"	 vfiltro_unidades"						,	Edit
	Gui,	Add,	CheckBox,%	pos( "filtro_unidades" ).ys	" w" w/5*1	"	 vcb"						,	Operador
	Gui,	Add,	ListView,%	pos( "filtro_unidades" ).xs	" w" w/5*2	" R7 vlv_unidade	gseleciona_unidade	AltSubmit"	,	 nome|entreposto|endereco|safra|abertura_manha|fechamento_manha|abertura_tarde|fechamento_tarde
		Gosub lista_unidades
	Gui,	Add,	Text,%		pos( "cb" ).ys	" w" w/5*3-15	" vunidade					Center	0x1000"	,	Unidade
	; Gui,	Add,	ListView,	xp		y45		w380	R7		vlv_endereco								, 	Endereço
	; 	LV_ModifyCol(1, 375)
	; Gui,	Add,	ListView,	xp+385	y45		w380	R7		vlv_notas									,	Observações
	; 	LV_ModifyCol(1, 375)
	; Gui,	Add,	Tab2,		x5				w1270	h780												,	Informações|E-Mails
	; Gui,	Tab,	Informações
	; Gui,	Add,	Edit,		x10		y225	w370											Section
	; Gui,	Add,	ListView,					w370	R10													,	Responsáveis
	; Gui,	Add,	Edit,				ys		w370											Section
	; Gui,	Add,	ListView,					w370	R10													,	Autorizados
	; Gui,	Add,	Edit,				ys		w370											Section
	; Gui,	Add,	ListView,					w370	R10													,	Colaboradores
	Gui,	Show,%								"w" w	" h" h-30												,	Título de Gui
	return
;

;	Code
	lista_unidades:
		s =
		(
			SELECT 
				 [nome]
				,[entreposto]
				,[endereco]
				,[safra]
				,[abertura_manha]
				,[fechamento_manha]
				,[abertura_tarde]
				,[fechamento_tarde]
			FROM
				[Cotrijal].[dbo].[unidades]
			WHERE
				[Cliente_de_Email] = 1
			ORDER BY
				1
		)
		unidades := sql( s , 3 )
		Loop,% unidades.Count()-1
			LV_Add(	""
				,	unidades[A_Index+1 , 1]
				,	unidades[A_Index+1 , 2]
				,	unidades[A_Index+1 , 3]
				,	unidades[A_Index+1 , 4]
				,	unidades[A_Index+1 , 5]
				,	unidades[A_Index+1 , 6]
				,	unidades[A_Index+1 , 7]
				,	unidades[A_Index+1 , 8]	)

		LV_ModifyCol()
		Loop, 7
			LV_ModifyCol(	A_Index+1, 0	)
		
	Return

	seleciona_unidade:
	Gui, ListView, lv_unidade
	if (A_GuiEvent = "Normal")	{
		LV_GetText( nome			, A_EventInfo, 1 )
		LV_GetText( entreposto		, A_EventInfo, 2 )
		LV_GetText( endereco		, A_EventInfo, 3 )
		LV_GetText( safra			, A_EventInfo, 4 )
		LV_GetText( abertura_manha	, A_EventInfo, 5 )
		LV_GetText( fechamento_manha, A_EventInfo, 6 )
		LV_GetText( abertura_tarde 	, A_EventInfo, 7 )
		LV_GetText( fechamento_tarde, A_EventInfo, 8 )
		GuiControl, , Unidade,% nome
		Gui, ListView, lv_endereco
		LV_Delete()
		LV_Add("", endereco)
	}
	Return
;

;	GuiClose
	GuiClose:
	ExitApp
;

pos( control ) {
	/*
		p:=pos( "filtro_unidade" )
		msgbox % p.x
	*/

	GuiControlGet,	position_,	Pos,% control	
	p := {	x	:	"x"	position_x
		,	y	:	"y"	position_y
		,	w	:	"w"	position_w
		,	h	:	"h"	position_h
		,	xs	:	"x"	position_x " y" position_y + position_h + 5
		,	ys	:	"x"	position_x + position_w + 5 " y" position_y	}
	Return p
}
