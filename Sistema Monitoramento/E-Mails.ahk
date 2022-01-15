/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\users\dsantos\desktop\executáveis\E-Mails.exe
Created_Date=1
Run_After="C:\Users\dsantos\Desktop\Executáveis\AHK2BD.exe "E-Mails" "0.0.0.5" """
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Version=0.0.0.6
Inc_File_Version=1
Product_Name=E-Mails
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\Dih\zico\heimdall blue\mail.ico

* * * Compile_AHK SETTINGS END * * *
*/
;@Ahk2Exe-SetMainIcon C:\Dih\zico\heimdall blue\mail.ico

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
	Multi = 0
	destaca_1 = 0
	destaca_2 = 0
	test =
	debug = 0
	WinGetPos,,,,taskbar, ahk_class Shell_TrayWnd
;

Menu,	Tray,	Icon
	Menu,	Tray,	Tip,	E-Mails
;

interface:
	;	Header
			header	=	Agenda|Importantes|Fechar ;|Ocomon|Frota
		Gui,	-Caption -Border
		Gui.Cores( "", "9BACC0", "374658" )
		Gui.Font( "S11", "cWhite", "Bold" )
		Gui,	Add,		Tab3,%		"x5											w" A_ScreenWidth-10	"	h" A_ScreenHeight-( taskbar * 1.5) "	vtab		gTab		AltSubmit	Bottom"			,%	header
			Gui.Font()
	;	Tab	1	-	Agenda
		Gui,	Add,		MonthCal,	x15									y15		w460					h163								vmcall			g_date Section
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
			Gui,	Add, Text, 				ys		w200					h17					0x1000	Center			,	Contendo( separe com ESPAÇO )
				Gui.Font()
			Gui,	Add, Edit, 						w200						vBusca	g_date
				Gui.Font( "Bold", "cWhite" )
			Gui,	Add, Checkbox,					wp						h20	vdestaca_1	g_agenda	Hidden			,	Destacar busca?
				Gui.Font()
		Gui,	Add,		ListView,%	"x15								y185	w" A_ScreenWidth-30	"	h130								vlv				g_agenda	AltSubmit	Grid"					,	Data|Mensagem|Operador|Unidade|IdAviso
			Gui.Font( "S15", "cWhite", "Bold" )
		Gui,	Add,		Text,%		"x15								y320	w" A_ScreenWidth-30 "	h30																	Center	0x1000"					,	Conteúdo
			Gui.Font()
		Gui,	Add,		Edit,%		"x15								y350	w" A_ScreenWidth-30 "	h" A_ScreenHeight-taskbar-400 "		veditbox"
			gosub	_date 
	;	Tab	2	-	Importantes
		Gui,	Tab,			2
			Gui.Font( "S11", "cWhite", "Bold" )
		Gui,	Add,	Radio,	Section												w250					h20													g_avisos					0x1000	Checked		,	Avisos
		Gui,	Add,	Radio,	xs													w250					h20													g_frota						0x1000				,	Frota
		Gui,	Add,	Radio,	xs													w250					h20													g_ocomon					0x1000				,	Ocomon
		Gui,	Add,	Text,	xs													w250					h15																	Center		0x1000				,	Filtrar avisos
			Gui.Font()
		Gui,	Add,	Edit,														w250					h24									vb_importantes	gTab
			Gui.Font( "Bold", "cB8B8B8" )
		Gui,	Add,	Checkbox,													wp						h20									vdestaca_2		g_importantes	Hidden							,	Destacar busca?
			Gui.Font( )
		Gui,	Add,	ListView,%	"									ys		w" A_ScreenWidth-300 "										vImportantes	g_importantes	AltSubmit	Grid	R8	NoSort"	,	Agendado para:|Mensagem
			Gui.Font( "S15", "cWhite", "Bold" )	
		Gui,	Add,	Text,%		"x15								y195	w" A_ScreenWidth-33 "	h30																	Center		0x1000"				,	Conteúdo
			Gui.Font()
		Gui,	Add,	Edit,%		"											w" A_ScreenWidth-33 "	h" A_ScreenHeight-taskbar-283 "		vexibe_importantes"
			if ( debug = 1 )
				OutputDebug % "Importantes " SubStr( A_Now, -1 )

	Gui,	Show,%					"x-2								y0		w" A_ScreenWidth+2	"	h" A_ScreenHeight-taskbar																			,	E-Mails
	GuiControl, Focus, busca
return

;	-	Funções de E-Mails
	_date:
		search_delay()
		Gui, Submit, NoHide
		contendo =
		if ( StrLen( Busca ) > 0 )	{
			GuiControl, Show, destaca_1
			if ( destaca_1 = 1)
				Guicontrol, +Redraw +c2BDC33, destaca_1
			Else
				Guicontrol, +Redraw +cB8B8B8, destaca_1	
			GuiControl, % StrLen( busca ) > 0 ? "Show" : "Hide"	, destaca_1
			if ( InStr( busca, " " ) > 0 )	{
				if ( SubStr( busca, -0 ) = " " )
					busca := SubStr( busca, 1, StrLen( busca )-1 )
				if ( InStr( busca, " " ) > 0 )	{
					buscar := StrSplit( busca, " " )
					Loop,%	buscar.Count()
						if ( A_Index = 1 )
							contendo .= "AND (p.[Mensagem] like '`%" buscar[A_Index] "`%' COLLATE Latin1_General_CI_AI"
						Else if ( A_Index = buscar.Count() )
							contendo .= " AND p.[Mensagem] like '`%" buscar[A_Index] "`%' COLLATE Latin1_General_CI_AI)"
						Else
							contendo .= " AND p.[Mensagem] like '`%" buscar[A_Index] "`%' COLLATE Latin1_General_CI_AI"
				}
			}
			Else
				contendo := "AND p.Mensagem LIKE '`%" busca "`%' COLLATE Latin1_General_CI_AI"
		}
		Else	{	;	sem busca
			GuiControl, Hide, destaca_1
			if ( destaca_1 = 1 )
				Guicontrol, +Redraw +c2BDC33, destaca_1
			Else
				Guicontrol, +Redraw +cB8B8B8, destaca_1
			GuiControl, % StrLen( busca ) > 0 ? "Show" : "Hide"	, destaca_1
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
		data := SubStr( mcall, 1, 4)	"-"	SubStr( mcall, 5, 2 )	"-"	SubStr( mcall, 7, 2 )
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
		if ( destaca_1 = 1 )
			buscar := StrSplit( busca, " " )

		Loop, % dados.Count()-1	{
			quebra =
			hour :=	dados[A_Index+1, 2]
			oper :=	RegExReplace( dados[A_Index+1, 3], "(^|\R)\K\s+" )
				if (	destaca_1 = 1	;	Se for mais de uma palavra e deve conter destaca_1 as palavras na mensagem
					&&	buscar.Count() > 1 )
					Loop,%	buscar.Count()
						if ( InStr( oper, buscar[A_Index] ) = 0 )
							quebra++
					if ( quebra > 0 )
						continue
				;

			subj :=	dados[A_Index+1, 4]
			unit :=	Format("{:T}", dados[A_Index+1, 5])
			idav :=	dados[A_Index+1, 6]
				if ( A_Index = 1 )
					last_id := idav
			
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
		if (	StrLen( busca ) > 0
			&&	destaca_1 = 1 )
			edb := string.Destaca_Busca( edb, busca )
		GuiControl, Font, editbox
		GuiControl, , editbox,% edb
	return

	_agenda:
		Gui, Submit, NoHide
		GuiControl, , destaca_1,%	destaca_1	=	1
										?	"Busca em destaque"
										:	"Destacar busca?"
		if ( destaca_1 = 1)
			Guicontrol, +Redraw +c2BDC33, destaca_1
		Else
			Guicontrol, +Redraw +cB8B8B8, destaca_1
		GuiControl, % StrLen( busca ) > 0 ? "Show" : "Hide"	, destaca_1
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
			return
		}
		Else
			LV_GetText( edb, row, 2)
		Gui.Font( "S11" )
		GuiControl,	Font,	editbox
		if (	StrLen( busca ) > 0
			&&	destaca_1 = 1 )
			edb := string.Destaca_Busca( edb, busca )
		GuiControl,	,	editbox,	%	edb
	return
;

;	-	Funções
	_importantes:	;	Seleciona para exibir
		Gui, Submit, NoHide
		Gui, ListView,	importantes
		GuiControl, , destaca_2,%	destaca_2	=	1
										?	"Busca em destaque"
										:	"Destacar busca?"
		if ( destaca_2 = 1)
			Guicontrol, +Redraw +c2BDC33, destaca_2
		Else
			Guicontrol, +Redraw +cB8B8B8, destaca_2
		GuiControl, % StrLen( b_importantes ) > 0 ? "Show" : "Hide"	, destaca_2
		if (	A_GuiEvent = "Normal"
		||		A_GuiEvent = "K" ) {
			if ( A_GuiEvent = "K" )
				LV_GetText( edb, LV_GetNext(), 2)
			Else
				LV_GetText( edb, A_EventInfo, 2)	
			If( A_EventInfo = 0 )
				LV_GetText( edb, 1, 2)
			Loop {
				edb := RegExReplace(edb, "\R+\R", "`r`n ")
				if ( ErrorLevel = 0 )
					break
			}
			Gui.Font( "S11" )
			GuiControl,	Font,	exibe_importantes
			if ( destaca_2 = 1)
				edb := String.Destaca_Busca( edb, b_importantes )
			GuiControl,		,	exibe_importantes,	%	edb
			return
		}
	return

	_avisos:
		tipo = Avisos Monitoramento
		GuiControl, , b_importantes
		GuiControl, , destaca_2, 0
		Goto, Tab
	; return

	_frota:
		tipo = Caminhoes
		GuiControl, , b_importantes
		GuiControl, , destaca_2, 0
		Goto, Tab
	; return

	_ocomon:
		tipo = Ocomon
		GuiControl, , b_importantes
		GuiControl, , destaca_2, 0
		Goto, Tab
	; return
	;
;

Tab:
	Gui, Submit, NoHide
	if ( tab = 1 )	{
		Loop, 5
			GuiControl, , op%A_Index%, 1
		Guicontrol, , busca
		Guicontrol, , b_importantes
		Guicontrol, , byDate, 0
		Guicontrol, , mcall,% A_Now
		Gui, Submit, NoHide
		Gui, ListView,	lv
		GuiControl, , destaca_1,%	destaca_1	=	1
										?	"Busca em destaque"
										:	"Destacar busca?"
		if ( destaca_1 = 1)
			Guicontrol, +Redraw +c2BDC33, destaca_1
		Else
			Guicontrol, +Redraw +cB8B8B8, destaca_1
		GuiControl, % StrLen( busca ) > 0 ? "Show" : "Hide"	, destaca_1
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
	}
	if ( tab = 2 )	{
		search_delay()
		Gui, Submit, NoHide
		Gui,	ListView,	Importantes
		if ( tipo = "" )
			tipo = Avisos Monitoramento
		contendo =
		if ( InStr( b_importantes, " " ) > 0 )	{
			if ( SubStr( b_importantes, -0 ) = " " )
				b_importantes := SubStr( b_importantes, 1, StrLen( b_importantes )-1 )
			if ( InStr( b_importantes, " " ) > 0 )	{
				buscari := StrSplit( b_importantes, " " )
				Loop,%	buscari.Count()
					if ( A_Index = 1 )
						contendo .= "AND (p.[Mensagem] like '`%" buscari[A_Index] "`%' COLLATE Latin1_General_CI_AI"
					Else if ( A_Index = buscari.Count() )
						contendo .= " AND p.[Mensagem] like '`%" buscari[A_Index] "`%' COLLATE Latin1_General_CI_AI)"
					Else
						contendo .= " AND p.[Mensagem] like '`%" buscari[A_Index] "`%' COLLATE Latin1_General_CI_AI"
			}
		}
		Else
			contendo := "AND p.Mensagem LIKE '`%" b_importantes "`%' COLLATE Latin1_General_CI_AI"
		
		s =
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
				c.[Nome]='%tipo%'
				%contendo%
			ORDER BY
				2 DESC
			)
			; Clipboard := s
		importantes := sql( s )
		LV_ModifyCol( 1, 115 )
		LV_ModifyCol( 2, A_ScreenWidth-450 )
		LV_Delete()
		Loop, % importantes.Count()-1
			LV_Add(	""
				,	importantes[A_Index+1,2]
				,	importantes[A_Index+1,3]	)
		LV_ModifyCol( 1, Sort )
		GuiControl,	Focus,	b_importantes
		Gosub, _importantes
	}
	if ( tab = 3 )
		Goto, GuiClose
return

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