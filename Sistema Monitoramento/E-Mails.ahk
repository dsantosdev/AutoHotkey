;@Ahk2Exe-SetMainIcon C:\Dih\zIco\2Agenda.ico

; #Include ..\class\classes.ahk
	#Include ..\class\sql.ahk
	#Include ..\class\array.ahk
	#Include ..\class\safedata.ahk
	#Include ..\class\gui.ahk
	#Include ..\class\windows.ahk
	#Include ..\class\string.ahk
	#Include ..\class\functions.ahk
	#SingleInstance,	Force
	#IfWinActive		E-Mails
	#NoTrayIcon
;

;	Local vars
	AndOr = 1
	test =
	debug = 0
	WinGetPos,,,,taskbar, ahk_class Shell_TrayWnd
;

Menu,	Tray,	Icon
	Menu,	Tray,	Tip,	E-Mails
;

interface:
	;	Header
			header	=	Agenda|Fechar ;|Avisos|Ocomon|Frota
		Gui,	-Caption -Border
		Gui.Cores( "", "9BACC0", "374658" )
		Gui.Font( "S11", "cWhite", "Bold" )
		Gui,	Add,		Tab3,%		"x5		w" A_ScreenWidth-10	"										h" A_ScreenHeight - ( taskbar * 1.5) "	vtab		gTab		AltSubmit	Bottom"		,%	header
			Gui.Font()
	;	Tab	1	-	Agenda
		Gui,	Add,		MonthCal,	x15									y15		w460					h163									vmcall		g_date Section
		;	FILTROS
			Gui.Font( "Bold", "cWhite" )
			Gui,	Add, Text,%		"		ys		w" A_ScreenWidth-505 "	h20					0x1000	Center"			,	FILTROS
			Gui,	Add, Checkbox,					w700					h20	vbyDate	g_date							,	Filtrar por período
				Guicontrol, +Redraw +cB8B8B8, byDate
			Gui,	Add, Checkbox,												vOp1	g_date	Section			Checked	,	Operador 1
			Gui,	Add, Checkbox,												vOp2	g_date					Checked	,	Operador 2
			Gui,	Add, Checkbox,												vOp3	g_date					Checked	,	Operador 3
			Gui,	Add, Checkbox,												vOp4	g_date					Checked	,	Operador 4
			Gui,	Add, Checkbox,												vOp5	g_date					Checked	,	Operador 5
				Loop, 5
					GuiControl, +Redraw +c2BDC33, Op%A_Index%
			Gui,	Add, Text, 				ys		w200					h15					0x1000	Center			,	Contendo(separe com vírgula)
				Gui.Font()
			Gui,	Add, Edit, 						w200						vBusca	g_date
				Gui.Font( "Bold", "cWhite" )
			Gui,	Add, Checkbox,					wp						h20	vAndOr	g_words	0x1000	Hidden	Checked	,	Todas as palavras
				Gui.Font()
		Gui,	Add,		ListView,%	"x15								y185	w" A_ScreenWidth-30	"	h130									vlv			g_agenda	AltSubmit	Grid"			,	Data|Mensagem|Operador|Unidade|IdAviso
			Gui.Font( "S15", "cWhite", "Bold" )
		Gui,	Add,		Text,%		"x15								y320	w" A_ScreenWidth-30 "	h30																			Center	0x1000"	,	Conteúdo
			Gui.Font()
		Gui,	Add,		Edit,%		"x15								y350	w" A_ScreenWidth-30 "	h" A_ScreenHeight-taskbar-430 "			veditbox"
			gosub	_date 
	;	Tab	2	-	Avisos
		Gui,	Tab,			2
			Gui.Font( "S11", "cWhite", "Bold" )
		Gui,	Add,		Text,		x10		y38																					,	Buscar contendo:
			Gui.Font()
		Gui,	Add,		Edit,		x135	y35		w250	h24		vfiltro2
		Gui,	Add,		Button,		x385	y36		w250	h22					gTab									,	Filtrar
		Gui,	Add,		ListView,	x10		y60		w1235			vlv2		g_avisos		AltSubmit	Grid	R7	NoSort	,	Agendado para:|Mensagem
			Gui.Font( "S11", "cWhite", "Bold" )	
		Gui,	Add,		Text,		x10		y210	w1235	h20									Center		0x1000				,	Conteúdo
			Gui.Font()
		Gui,	Add,		Edit,		xp		y235	w1235	h300	veditbox2 
			if ( debug = 1 )
				OutputDebug % "Avisos " SubStr( A_Now, -1 )
	;	Tab	3	-	Ocomon
		Gui,	Tab,		3
			Gui.Font( "S11", "cWhite", "Bold" )
		Gui,	Add,		Text,		x10		y38																					,	Buscar contendo:
			Gui.Font()
		Gui,	Add,		Edit,		x135	y35		w250	h24		vfiltro3
		Gui,	Add,		Button,		x385	y36		w250	h22					gTab									,	Filtrar
		Gui,	Add,		ListView,	x10		y60		w1235			vlv3		g_ocomon		AltSubmit	Grid	R7	NoSort	,	Data|Mensagem
			Gui.Font( "S11", "cWhite", "Bold" )	
		Gui,	Add,		Text,		x10		y210	w1235	h20									Center	0x1000					,	Conteúdo
			Gui.Font()
		Gui,	Add,		Edit,		xp		y235	w1235	h300	veditbox3
			if ( debug = 1 )
				OutputDebug % "Ocomon " SubStr( A_Now, -1 )
	;	Tab 4	-	Frota
		Gui,	Tab,		4
			Gui.Font( "S11", "cWhite", "Bold" )
		Gui,	Add,		Text,		x10		y38																					,	Buscar contendo:
			Gui.Font()
		Gui,	Add,		Edit,		x135	y35		w250	h24		vfiltro4
		Gui,	Add,		Button,		x385	y36		w250	h22					gTab									,	Filtrar
		Gui,	Add,		ListView,	x10		y60		w1235			vlv4		g_frota			AltSubmit	Grid	R7	NoSort	,	Data|Mensagem
			Gui.Font( "S11", "cWhite", "Bold" )
		Gui,	Add,		Text,		x10		y210	w1235	h20									Center	0x1000					,	Conteúdo
			Gui.Font()
		Gui,	Add,		Edit,		xp		y235	w1235	h300	veditbox4
			if ( debug = 1 )
				OutputDebug % "Frota " SubStr( A_Now, -1 )
	Gui,	Show,%	"x-2	y0		w" A_ScreenWidth+2	"	h" A_ScreenHeight-taskbar	,	E-Mails
		Send,	{Down}
		if ( trocou = 1 )	{
			trocou	=
			GuiControl,	Choose,	tab,	5
			}
return

_words:
	Gui, Submit, NoHide
	OutputDebug % "and or =" andor
	modo	:=	andor = 1
			?	"Todas as palavras"	:	"Qualquer palavra"
	GuiControl, , AndOr,%	modo
;	fim do words

_date:
	search_delay()
	Gui, Submit, NoHide
	if ( StrLen( Busca ) > 0 )	{
		GuiControl, Show, AndOr
		if ( InStr( busca, ",") > 0 )	{
			buscar := StrSplit( busca, "," )
			operator := AndOr	= 1
								? "AND"
								: "OR"
			contendo =
			in =
			Loop,%	buscar.Count()	{
				if ( buscar[A_Index] = "" )
					Continue
				if ( A_Index = 1 )
					if ( andor = 1)
						contendo .= "AND p.Mensagem LIKE '`%" buscar[A_Index] "`%"
					Else
						contendo .= "AND (p.Mensagem LIKE '`%" buscar[A_Index] "`%'"
			
				Else if ( A_Index = buscar.Count() )
					if ( andor = 1)
						contendo .= " `%" buscar[A_Index] "`%'"
					Else
						contendo .= " or p.Mensagem LIKE '`%" buscar[A_Index] "`%')"
				
				Else
					if ( andor = 1)
						contendo .=" `%" buscar[A_Index] "`%"
					Else
						contendo .=" or p.Mensagem LIKE '`%" buscar[A_Index] "`%'"
			}
		}
		Else	{	
			GuiControl, Hide, AndOr
			contendo := "AND p.Mensagem LIKE '`%" busca "`%'"
		}
	}
	Else	{
		GuiControl, Hide, AndOr
		contendo =
	}

	if ( byDate = 1 )	{
		FormatTime,	diaAntes,% mcall,	YDay
		FormatTime,	mcall	,% mcall,	yyyy-MM-dd
		FormatTime,	Today	,% A_Now,	yyyy-MM-dd
		dias	:=	A_YDay - diaAntes
		GuiControl,	+c2BDC33	+Redraw,	byDate
		GuiControl,						,	byDate,	Filtrado por período
		if ( dias = 0 )
			byDate :=	"AND CONVERT(VARCHAR(25), Quandoavisar, 126) like '" mcall "`%'"
		else
			byDate :=	"AND CAST(Quandoavisar AS DATE) >= '" mcall "' AND CAST(Quandoavisar AS DATE) <= '" Today "'"
	}
	Else {
		GuiControl,	+cB8B8B8 +Redraw	, byDate
		GuiControl,	,	byDate			, Filtrar por período
		FormatTime,	mcall,%	mcall		, yyyy-MM-dd
		byDate := "AND CONVERT(VARCHAR(25), Quandoavisar, 126) like '" mcall "`%'"
	}

	operador =
	o1 := op1 = 1 ? operador .= "'1'," : ""
		if ( StrLen( o1 ) = 0 )
			Guicontrol, +Redraw +cB8B8B8, Op1
		Else
			Guicontrol, +Redraw +c2BDC33, Op1
	o2 := op2 = 1 ? operador .= "'2'," : ""
		if ( StrLen( o2 ) = 0 )
			Guicontrol, +Redraw +cB8B8B8, Op2
		Else
			Guicontrol, +Redraw +c2BDC33, Op2
	o3 := op3 = 1 ? operador .= "'3'," : ""
		if ( StrLen( o3 ) = 0 )
			Guicontrol, +Redraw +cB8B8B8, Op3
		Else
			Guicontrol, +Redraw +c2BDC33, Op3
	o4 := op4 = 1 ? operador .= "'4'," : ""
		if ( StrLen( o4 ) = 0 )
			Guicontrol, +Redraw +cB8B8B8, Op4
		Else
			Guicontrol, +Redraw +c2BDC33, Op4
	o5 := op5 = 1 ? operador .= "'5'," : ""
		if ( StrLen( o5 ) = 0 )
			Guicontrol, +Redraw +cB8B8B8, Op5
		Else
			Guicontrol, +Redraw +c2BDC33, Op5

	if ( StrLen( o1 o2 o3 o4 o5) = 0 )	{
	 	operador = '1','2','3','4','5'
		 Loop, 5
		 {
		 	GuiControl, , op%A_Index%, 1
			GuiControl, +Redraw +c2BDC33, Op%A_Index%
		 }
	}
	Else
		operador	:= SubStr( operador, 1, -1)
	;

	lastrow =
	FormatTime,	yday,%	mcall,	yyyy-MM-dd
	LV_Delete()
;_date end

carrega_lv:
	if ( StrLen( byDate ) >= )
		Gui,	Submit,	NoHide
	FormatTime,	mcall,	%mcall%,	yyyy-MM-dd
	if ( byDate = 0 )
		byDate	= AND CONVERT(VARCHAR(25), Quandoavisar, 126) like '%mcall%`%'
	Gui, ListView, lv
	LV_Delete()
	data := SubStr(mcall,1,4)	"-"	SubStr(mcall,5,2)	"-"	SubStr(mcall,7,2)
	s =
		(
		SELECT	p.IdCliente
			,	p.QuandoAvisar
			,	p.Mensagem
			,	p.Assunto
			,	c.Nome
			,	p.Idaviso
		FROM
			[IrisSQL].[dbo].[Agenda] p
		LEFT JOIN
			[IrisSQL].[dbo].[Clientes] c ON
				p.IdCliente=c.IdUnico
		WHERE
			[Assunto] IN (%operador%)
			%byDate%
			%contendo%
			%in%
		ORDER BY
			6 DESC
		)
	; Clipboard := s

	dados := sql( s )
	Loop, % dados.Count()-1	{
		hour :=	dados[A_Index+1, 2]
		oper :=	RegExReplace( dados[A_Index+1, 3], "(^|\R)\K\s+" )
		subj :=	dados[A_Index+1, 4]
		unit :=	dados[A_Index+1, 5]
		idav :=	dados[A_Index+1, 6]
		if ( A_Index = 1 )
			last_id := idav
		StringUpper, unit, unit, T
		LV_Add( ""
			,	hour
			,	oper
			,	subj
			,	unit
			,	idav )
	}
	LV_ModifyCol(1, 115)
	LV_ModifyCol(1, Sort)
	LV_ModifyCol(2, 800)
	LV_ModifyCol(3, 60)
	LV_ModifyCol(4, 200)
	LV_ModifyCol(5, 0)
	LV_GetText( edb, 1, 2 )
	edb := RegExReplace( edb,"(^|\R)\K\s+")
	if ( StrLen( edb ) < 6 )
		edb =
	Gui.Font( "S11" )
	GuiControl, Font, editbox
	GuiControl, , editbox,% edb
return

_agenda:
	Gui,	ListView,	lv
	row	:=	LV_GetNext()
	if ( row = 0 )
		row = 1
	if (	A_GuiEvent = Normal
		||	A_GuiEvent = K	) {
		LV_GetText( edb, A_EventInfo, 2 )
		Loop	{
			edb := RegExReplace( edb, "\R+\R", "`r`n ")
			if ( ErrorLevel = 0)
				break
		}
		Gui.Font("S11")
		GuiControl,	Font,	editbox
		GuiControl,	, editbox,%	edb
		return
	}
	LV_GetText( edb, row, 2)
	Gui, Font,	S11
	GuiControl,	Font,	editbox
	GuiControl,	,	editbox,	%	edb
return

_avisos:
	Gui, ListView,	lv2
	row2 := LV_GetNext()
	if ( row2 = 0 )
		row2			=		1
	if ( A_GuiEvent = Normal ) {
		LV_GetText( edb, A_EventInfo, 2)
		Loop {
			edb := RegExReplace(edb, "\R+\R", "`r`n ")
			if ( ErrorLevel = 0 )
				break
			}
		Gui,	Font,	S11
		GuiControl,	Font,	editbox2
		GuiControl,	,	editbox2,	%	edb
		return
		}
	LV_GetText(edb, row2, 2)
	Gui,	Font,	S11
	GuiControl,	Font,	editbox2
	GuiControl,	,	editbox2,	%	edb
return

_ocomon:
	Gui, ListView,	lv3
	row3 :=	LV_GetNext()
	if ( row3 = 0 )
		row3 = 1
	if ( A_GuiEvent = Normal ) {
		LV_GetText(edb, A_EventInfo, 2)
		Loop {
			edb := RegExReplace(edb, "\R+\R", "`r`n ")
			if ErrorLevel = 0
				break
			}
		Gui, Font,	S11
		GuiControl,	Font,	editbox3
		GuiControl,	, editbox3,%	edb
		return
		}
	LV_GetText(edb, row3, 2)
	Gui,	Font,	S11
	GuiControl,	Font,	editbox3
	GuiControl,	,	editbox3,	%	edb
return

_frota:
	Gui, ListView,	lv4
	row4 :=	LV_GetNext()
	if ( row4 = 0 )
		row4			=		1
	if ( A_GuiEvent = Normal ) {
		LV_GetText( edb, A_EventInfo, 2)
		Loop {
			edb := RegExReplace(edb, "\R+\R", "`r`n ")
			if ErrorLevel = 0
				break
			}
		Gui,	Font,	S11
		GuiControl,	Font,	editbox4
		GuiControl,	,	editbox4,	%	edb
		return
		}
	LV_GetText( edb, row4, 2)
	Gui,	Font,	S11
	GuiControl,	Font,	editbox4
	GuiControl,	,	editbox4,	%	edb
return

Tab:
	Gui, Submit, NoHide
	
	if ( tab = 1 )	{
		GuiControl,	,	filtro2
		GuiControl,	,	filtro3
		GuiControl,	,	filtro4
		GuiControl,	,	filtro6
		GuiControl,	,	filtro7
		GuiControl,	Focus,	lv
		}
	if ( tab = 2 )	{
		goto GuiClose
		GuiControl,	,	filtro3
		GuiControl,	,	filtro4
		GuiControl,	,	filtro6
		GuiControl,	,	filtro7
		Gui,	ListView,	lv2
		if ( filtro2 = "" )
			filtrar =
			else
			filtrar	:=	" AND p.Mensagem like '%" filtro2 "%'"
		LV_Delete()
		sqlv =
			(
			SELECT	p.IdCliente
				,	p.QuandoAvisar
				,	p.Mensagem
				,	p.Assunto
				,	c.Nome
			FROM
				[IrisSQL].[dbo].[Agenda] p
			LEFT JOIN
				[IrisSQL].[dbo].[Clientes] c ON
					p.IdCliente = c.IdUnico
			WHERE
				c.[Nome]='Avisos Monitoramento'
				%filtrar%
			ORDER BY
				2 DESC
			)
		fill := sql( sqlv )
		LV_ModifyCol(1,115)
		LV_ModifyCol(2,1100)
		Loop, % fill.Count()-1
			LV_Add(	""
				,	fill[A_Index+1,2]
				,	fill[A_Index+1,3]	)
		LV_ModifyCol(1,Sort)
		GuiControl,	Focus,	lv2
		}
	if ( tab = 3 )	{
		Gui,	ListView,	lv3
		GuiControl,	,	filtro2
		GuiControl,	,	filtro4
		GuiControl,	,	filtro6
		GuiControl,	,	filtro7
		if ( filtro3 = "" )
			filtrar	=
			else
			filtrar := " AND p.Mensagem like '%" filtro3 "%'"
		LV_Delete()
		sqlv =
			(
			SELECT	p.IdCliente
				,	p.QuandoAvisar
				,	p.Mensagem
				,	p.Assunto
				,	c.Nome
			FROM
				[IrisSQL].[dbo].[Agenda] p
			LEFT JOIN
				[IrisSQL].[dbo].[Clientes] c ON
					p.IdCliente = c.IdUnico
			WHERE
				c.[Nome]='Ocomon'
				%filtrar%
			ORDER BY
				2 DESC
			)
		fill := sql( sqlv )
		Loop, % fill.Count()-1
			LV_Add("",	fill[A_Index+1,2],	fill[A_Index+1,3])
			LV_ModifyCol(1,Sort)
			LV_ModifyCol(1,115)
			LV_ModifyCol(2,1100)
		GuiControl	Focus,	lv3
		}
	if ( tab = 4 )	{
		Gui,	ListView,	lv4
		GuiControl,	,	filtro2
		GuiControl,	,	filtro3
		GuiControl,	,	filtro6
		GuiControl,	,	filtro7
		if ( filtro4 = "" )
			filtrar	=
			else
			filtrar	:=	" AND p.Mensagem like '%" filtro4 "%'"
		LV_Delete()
		sqlv =
			(
			SELECT	p.IdCliente
				,	p.QuandoAvisar
				,	p.Mensagem
				,	p.Assunto
				,	c.Nome
			FROM
				[IrisSQL].[dbo].[Agenda] p
			LEFT JOIN
				[IrisSQL].[dbo].[Clientes] c ON
					p.IdCliente = c.IdUnico
			WHERE
				c.[Nome]='Caminhoes'
				%filtrar%
			ORDER BY
				2 DESC
			)
		fill := sql( sqlv )
		Loop, % fill.Count()-1
			LV_Add("",	fill[A_Index+1,2],	fill[A_Index+1,3])
			LV_ModifyCol(1,Sort)
			LV_ModifyCol(1,115)
			LV_ModifyCol(2,1100)
		GuiControl	Focus,	lv4
		}
return

~Enter::
	~NumpadEnter::
	if ( tab != 1 )
		return
	Gui, Submit,	NoHide
	goto _date

Esc::
	GuiClose:
	LoginGuiClose:
ExitApp

Login:
	#IfWinActive, Login Cotrijal
	Gui.Cores( "login", "9BACC0", "374658" )
		Gui, login:Font,	Bold	S10 cWhite
	Gui, login:Add, Text,	x10	y10		w80		h20									, Usuário
	Gui, login:Add, Text,	x10	y30		w80		h20									, Senha
		Gui, login:Font
		Gui, login:Font, Bold S10
	Gui, login:Add, Edit,	x90	y10		w140	h20		v@usuario
	Gui, login:Add, Edit,	x90	y30		w140	h20		v@senha		Password
	Gui, login:Add, Button,	x10	y55		w221	h25		vAutentica	g_Autenticar	, Ok
		Gui, login:Font
	Gui, login: +AlwaysOnTop	-MinimizeBox
	Gui, login:Show,																, Login Cotrijal
	Sleep, 500
	Gui, login:+LastFound
	Guicontrol, login:Focus, @usuario
	Return

	_Autenticar:
		Gui,	Login:Submit,	NoHide
		is_login := Login( @usuario, @senha )
		if	( logou = "interface" )
			Return
		goto,%	logou := Login( @usuario, @senha ) =	0
													?	"GuiClose"
													:	"Interface"
	Return

return