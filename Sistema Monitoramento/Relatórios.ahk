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
	#SingleInstance Force
	#Persistent
	#Include ..\class\alarm.ahk
	; #Include ..\class\array.ahk
	#Include ..\class\functions.ahk
	#Include ..\class\gui.ahk
	; #Include ..\class\safedata.ahk
	#Include ..\class\sql.ahk
	; #Include ..\class\windows.ahk
;
;	Local vars
	WinGetPos,,,,taskbar, ahk_class Shell_TrayWnd
	primeira = 1
	start =
	end =
	id_cliente =
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
	Gui, Add, Tab3,%		"x5	y5	w" A_ScreenWidth-5 	" h" A_ScreenHeight-taskbar-10 " vtab g_tab	Bottom"	,	Relatórios|Fechar
	;	Bloco 1 Esquerda
		Gui, Add, MonthCal,	x20	y20	w225		gs_mes		vmes
			Gui.Font( "Bold", "c2BDC33" )
		Gui, Add, Checkbox,						gs_mes		vPeriodo			Checked		,	Filtrado por dia
		Gui, Add, Checkbox,						gs_mes		vOp1		Section	Checked		,	Operador 1
		Gui, Add, Checkbox,		ys				gs_mes		vOp2				Checked		,	Operador 2
		Gui, Add, Checkbox,	xs					gs_mes		vOp3		Section	Checked		,	Operador 3
		Gui, Add, Checkbox,		ys				gs_mes		vOp4				Checked		,	Operador 4
		Gui, Add, Checkbox,	xs					gs_mes		vOp5		Section	Checked		,	Operador 5
		Gui, Add, Checkbox,		ys				gs_mes		vOp6				Checked		,	Especial
			Gui.Font( "cWhite" )
		Gui, Add, Text,		xs					w225	h17				0x1000	Center		,	Buscar contendo palavra
			Gui.Font()
		Gui, Add, Edit,			yp+20	w225	gs_mes		vBusca
			Gui.Font( "Bold", "c2BDC33" )
		Gui, Add, Checkbox,						gs_mes		vev_especial	Section	%d%	%c%	,	Filtrar apenas Eventos Especiais
			Gui.Font()
	;

	;	ListView de Eventos
			Gui.Font( "S10" )
		Gui, Add, ListView,% "x260 y20	w" A_ScreenWidth-270	"	gSelectLV	veventos	Grid	R22		AltSubmit"	,	Disparo|Finalizou|Relatório|Cliente|Unidade|start|end|id_cliente|ev_final
		LV_ModifyCol( 1, 80 )
		LV_ModifyCol( 2, 80 )
		LV_ModifyCol( 3, 490 )
		LV_ModifyCol( 4, 60 )
		LV_ModifyCol( 5, 290 )
		LV_ModifyCol( 6, 0 )
		LV_ModifyCol( 7, 0 )
		LV_ModifyCol( 8, 0 )
		LV_ModifyCol( 9, 0 )
	;

	;	Header Bloco 3 Horizontal
			Gui.Font( "Bold", "cFFFFFF" )
		Gui, Add, Text,%	"x20	ys+170	w" (A_ScreenWidth-30)/2-10 "	h20	Section	0x1000	Center"	,	RELATÓRIO
		Gui, Add, Text,%	"		ys		w" (A_ScreenWidth-30)/2-2	 "	h20			0x1000	Center"	,	SEQUÊNCIA DE EVENTOS
			Gui.Font()
	;

	;	ListView de Eventos Selecionados
			Gui.Font( "S10" )
		Gui, Add, Edit,%	"x20 yp+25	w" (A_ScreenWidth-30)/2-10 "	h" A_ScreenHeight-taskbar-555 "	Section	vdescritivo	+VScroll"
			Gui.Font()
		Gui, Add, ListView,%	"ys		w" (A_ScreenWidth-30)/2-2	 "	h" A_ScreenHeight-taskbar-555	"		vocorridos	Grid"	,	Unidade|Data|Evento|XXX|Descrição
	;

	;	Gui Show
		Gui, -DPIScale
		; if	(	A_UserName	=	"dsantos"
		; ||		A_UserName	=	"llopes"
		; ||		A_UserName	=	"alberto"
		; ||		A_UserName	=	"arsilva"
		; ||		A_UserName	=	"jcsilva"
		; ||		A_UserName	=	"ddiel" 	)
			; Gui,	Add, Button,xm					h25		gRelatorio							Center		,	GERAR RELATÓRIO
			Gosub	s_mes
		Gui, Show,% "x0	y0 w" A_ScreenWidth "h" A_ScreenHeight-taskbar,	Relatórios
			Gosub	SelectLV
			Gosub	busca_informações
			primeira = 0
	;

	GuiControl,	Focus,	eventos
	Send,	{Down}
return

_tab:
Gui, Submit, NoHide
	if ( tab = "Fechar" )
		ExitApp
Return

s_mes:
	search_delay()
	Gui, Submit, NoHide
	if ( StrLen( Busca ) > "0" )
		busca := "AND a.[Observacoes_conta] LIKE '`%" Busca "`%'"
		else
			busca =
	if ( Periodo	= 1 )	{
		FormatTime,	diaAntes,	%mes%	,	YDay
		FormatTime,	mes		,	%mes%	,	yyyy-MM-dd
		FormatTime,	Today	,	%A_Now%	,	yyyy-MM-dd
		periodox	:=	A_YDay-diaAntes
		GuiControl,	+c2BDC33 +Redraw, periodo
		GuiControl,	,	Periodo,	Filtrado por dia
		if ( periodox = 0 )
			periodoz	:=	"AND CAST(a.[Disparo] AS DATE) >= '"	mes "'"
		else
			periodoz	:=	"AND (CAST(a.[Disparo] AS DATE) >= '"	mes	"' AND CAST(a.[Disparo] AS DATE) <= '" Today "')"
		}
	else	{
		GuiControl,	+cB8B8B8 +Redraw, periodo
		GuiControl,	,	Periodo,	Filtrar por dia?
		FormatTime,	mes,	%mes%,	yyyy-MM-dd
		periodoz	:=	"AND CAST(a.Disparo AS DATE) >= '"	mes "'"
	}
	;	Operadores
		operadores := []
		operador =
		if (op1	= 0
		&&	op2	= 0
		&&	op3	= 0
		&&	op4	= 0
		&&	op5	= 0
		&&	op6	= 0 )	{
			Loop, 6
				GuiControl, , Op%A_Index%, 1
			Gui, Submit, NoHide
		}
		o := op1 = 1 ? operadores.push("0001")	: ""
		o := op2 = 1 ? operadores.push("0002")	: ""
		o := op3 = 1 ? operadores.push("0003")	: ""
		o := op4 = 1 ? operadores.push("0004")	: ""
		o := op5 = 1 ? operadores.push("0005")	: ""
		o := op6 = 1 ? operadores.push("0998")	: ""
		Loop,% operadores.Count()
			if (A_index = 1
			&&	A_Index = operadores.Count() )
				operador := "AND (`tb.[Setor] = '" operadores[A_Index] "')`n"
			Else if ( A_index = 1 )
				operador := "AND (`tb.[Setor] = '" operadores[A_Index] "'`n"
			Else if ( A_Index = operadores.Count() )
				operador .= "`t`t`t`tOR`tb.[Setor] = '" operadores[A_Index] "')"
			Else
				operador .= "`t`t`t`tOR`tb.[Setor] = '" operadores[A_Index] "'`n"
		Loop, 6
			if ( op%A_Index% = 1)
				GuiControl, +Redraw +c2BDC33, Op%A_Index%
				Else
					GuiControl, +Redraw +cB8B8B8, Op%A_Index%
	lastrow	=
	only_especial := ev_especial = 1 ? "AND a.[Tipo] = 'M'" : ""
	FormatTime,	yday,	%mes%,	yyyy-MM-dd
	s =
		(
		SELECT	 a.[OperadorDisparo]
				,a.[OperadorFinalizou]
				,a.[Observacoes_conta]
				,a.[Cliente]
				,b.[Nome]
				,a.[IdSequencia]
				,a.[IdSeqStart]
				,a.[IdCliente]
				,a.[CodEvtFinalizou]
		FROM [IrisSQL].[dbo].[Procedimentos] a
		LEFT JOIN
			[IrisSQL].[dbo].[Clientes] b
				ON	a.[IdCliente] = b.[IdUnico]
		WHERE
			a.[Observacoes_conta] IS NOT NULL AND
			DATALENGTH(a.[Observacoes_conta]) <> 0
			%only_especial%
			%periodoz%
			%operador%
			%busca%
		ORDER BY
			a.[IdSequencia] DESC
		)
	e	:=	sql( s )
	Gui, ListView,	eventos
	LV_Delete()
	Loop, % e.Count()-1
		LV_Add(	""
			,	StrLen( e[A_Index+1,1] ) = 0 ? Format( "{:T}", e[A_index+1,2] ) : Format( "{:T}", e[A_index+1,1] )
			,	Format( "{:T}", e[A_index+1,2] )
			,	e[A_index+1,3]
			,	e[A_index+1,4]
			,	Format( "{:T}", e[A_index+1,5] )
			,	e[A_index+1,6]
			,	e[A_index+1,7]
			,	e[A_index+1,8]
			,	e[A_index+1,9]	)
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
	LV_GetText(	operador_final	, row,	2)
	LV_GetText(	relatorio		, row,	3)
	LV_GetText(	end				, row,	6)
	LV_GetText(	start			, row,	7)
	LV_GetText(	id_cliente		, row,	8)
	LV_GetText(	ev_final		, row,	9)
	if ( primeira = 0 )
		Gosub	busca_informações
return

busca_informações:
	s	=
		(
		SELECT	c.Nome
			,	p.Data
			,	p.Evento
			,	p.Zona
			,	p.Descricao
		FROM [IrisSQL].[dbo].[Eventos] p
		LEFT JOIN
			[IrisSQL].[dbo].[Clientes] c ON p.IdCliente = c.IdUnico
		WHERE
			p.Sequencia	between	'%start%' AND '%end%' AND
			p.idCliente = '%id_cliente%'
		ORDER BY
			2 ASC
		)
	s	:=	sql( s )
	Gui, ListView,	ocorridos
	LV_Delete()
	e130:=e570:=hora_disparo:=hora_desarme:=hora_restauro:=hora_arme:=""
	zonas		:=	[]
	Inibidas	:=	[]
	Loop, % s.Count()-1	{
		LV_Add(	""
			,	SubStr(	s[A_Index+1,1], 1
					,	InStr( s[A_Index+1,1], "|" ) > 0
						?	InStr( s[A_Index+1,1], "|" )-1
						:	StrLen( s[A_Index+1,1]) )
			,	s[A_Index+1,2]
			,	s[A_Index+1,3]
			,	s[A_Index+1,4]
			,	s[A_Index+1,5]	)
		if	(	s[A_Index+1,3] = "E130" )
			if ( A_Index+1 = 2 ) {	;	Se for a hora do primeiro disparo
				zonas.Push( s[A_Index+1,4] . " - " . alarm.Name( s[A_Index+1,4], id_cliente ) )
				hora_disparo := SubStr( s[A_Index+1,2], InStr(s[A_Index+1,2]," ")+1 )
				}
				Else				
					zonas.Push( s[A_Index+1,4] . " - " . alarm.Name( s[A_Index+1,4], id_cliente ) )
		if	(	s[A_Index+1,3] = "R402"
		||		s[A_Index+1,3] = "R401" )
				hora_arme := SubStr( s[A_Index+1,2], InStr( s[A_Index+1,2], " " )+1 )
		if	(	s[A_Index+1,3] = "E402"
		||		s[A_Index+1,3] = "E401" )
				hora_desarme := SubStr( s[A_Index+1,2], InStr( s[A_Index+1,2], " " )+1 )
		if	(	s[A_Index+1,3] = "R130" )
				hora_restauro := SubStr( s[A_Index+1,2], InStr( s[A_Index+1,2], " " )+1 )
		if	(	s[A_Index+1,3] = "E570"
		||		s[A_Index+1,3] = "E571"
		||		s[A_Index+1,3] = "E572"
		||		s[A_Index+1,3] = "E573"
		||		s[A_Index+1,3] = "E574"
		||		s[A_Index+1,3] = "E575"
		||		s[A_Index+1,3] = "E576"
		||		s[A_Index+1,3] = "E577") {
			e570++
			Inibidas.Push( s[A_Index+1,4] . " - " . alarm.Name( s[A_Index+1,4], id_cliente ) )
		}
	}
	sensores =
	if( ev_final = "E130" )	{
		descricao := StrReplace( StrReplace( relatorio, "`n", "++" ), "`r", "--" )
		loop,	2
			if (	SubStr( descricao, 1, 2 ) = "++"
			||		SubStr( descricao, 1, 2 ) = "--" )
				descricao := SubStr( descricao, 3 )
	 	descricao := StrReplace( descricao, "--++" , "`n" )

		if ( Inibidas.Count() > 1 )
			Loop,%	Inibidas.Count()
				if( A_index = 1 )	
					zInibidas := "`n`nZonas inibidas:`n`t" Inibidas[A_Index]
				else
					zInibidas .= "`n`t" Inibidas[A_Index]
		if ( Inibidas.Count() = 1 )
			zInibidas :=	"`n`nZona inibida:`n`t" Inibidas[1]
		if ( Inibidas.Count() = 0 )
			zInibidas =
		if ( zonas.Count() > 1 ) {
			Loop,%	zonas.Count()
				sensores .=	"`n`t" zonas[A_Index]
			if ( StrLen( hora_desarme ) > 1 )
				fim_disparo :=	"`t[DESARMADO]`tàs "	hora_desarme
			if ( StrLen( hora_arme ) > 1 )
				fim_disparo :=	"`t[DESARMADO]`tàs "	hora_desarme ".`n`t[ATIVADO]`tàs " hora_arme	zInibidas
			if ( StrLen( hora_restauro ) > 1 )
				fim_disparo	:=	"`t[RESTAURADO]`tàs "	hora_restauro
			encerramento	=	Disparo as %hora_disparo%, nas zonas:%sensores%`n%fim_disparo%`n`n%descricao%
		}
		Else	{
			if ( StrLen( hora_desarme ) > 1 )
				fim_disparo	:=	"`t[DESARMADO]`tàs "	hora_desarme
			if ( StrLen( hora_arme ) > 1 )
				fim_disparo	:=	"`t[DESARMADO]`tàs "	hora_desarme ".`n`t[ATIVADO]`tàs " hora_arme	zInibidas
			if ( StrLen( hora_restauro ) > 1 )
				fim_disparo	:=	"`t[RESTAURADO]`tàs "	hora_restauro
			sensores	:=	"`n`t"zonas[1] "`n"
			encerramento	=	Disparo as %hora_disparo%, na zona%sensores%%fim_disparo%`n`n%descricao%
		}
		o := encerramento
		encerramento:=fim_disparo:=zInibidas:=""
	}
	Else
		o	:=	relatorio
	LV_ModifyCol( 1, 150 )
	LV_ModifyCol( 2, 120 )
	LV_ModifyCol( 3, 50 )
	LV_ModifyCol( 4, 40 )
	LV_ModifyCol( 5, 255 )
	GuiControl, , Descritivo,%	o "`n_____________`n" operador_final
	relatorio:=operador_final:=""
return

~Enter::
	~NumpadEnter::
	Gui,	Submit,	NoHide
	goto	s_mes
;

Esc::
	GuiClose:
	ExitApp
;

mes:
	LV_Delete()
	Gui, Submit, NoHide
	lastrow =
	FormatTime,	yday,	%mes%,	yyyy-MM-dd
	only_especial := ev_especial = 1 ? "a.[tipo]='m' AND" : ""
	e	=	
		(
		SELECT	a.IdSequencia,
				a.IdSeqStart,
				a.OperadorDisparo,
				a.Observacoes_conta,
				a.EstacaoDisparo,
				a.Cliente,
				a.Particao,
				a.OperadorFinalizou,
				a.CodEvtFinalizou,
				c.Descricao,
				a.Tipo,
				a.IdCliente,
				b.Nome,
				d.desconformidade
		FROM [IrisSQL].[dbo].[Procedimentos] a
		LEFT JOIN
			[IrisSQL].[dbo].[Clientes] b ON	a.IdCliente = b.IdUnico
		LEFT JOIN
			[IrisSQL].[dbo].[Setores] c	ON b.Setor = c.Setor
		LEFT JOIN
			[ASM].[Sistema_Monitoramento].[dbo].[desconformidades] d ON a.IdSequencia = d.nr_procedimento
		WHERE
			( a.Observacoes_conta IS NOT NULL ) AND
			%only_especial%
			( DATALENGTH( a.Observacoes_conta ) <> 0 ) AND
			DATEDIFF( day,a.Disparo, '%yday%' ) = 0 AND
			a.Cliente BETWEEN '10001' AND '10999'
		ORDER BY
			a.IdSequencia DESC
		)
	; MsgBox % Clipboard:=e
	e := sql( e )
	Gui, ListView, eventos
	Loop, 13
		LV_ModifyCol( A_Index, 0)
		LV_ModifyCol( 4, 500 )
		LV_ModifyCol( 8, 100 )
		LV_ModifyCol( 10, 100 )
		LV_ModifyCol( 13, 290 )
	Loop, % e.Count()-1	{
		evento		:= e[A_index+1,4]
		id_cliente	:= e[A_index+1,12]
		LV_Add(	autosize
			,	e[A_index+1,1]
			,	e[A_index+1,2]
			,	e[A_index+1,3]
			,	evento
			,	e[A_index+1,5]
			,	e[A_index+1,6]
			,	e[A_index+1,7]
			,	e[A_index+1,8]
			,	e[A_index+1,9]
			,	e[A_index+1,10]
			,	e[A_index+1,11]
			,	id_cliente
			,	e[A_index+1,13]	)
	}
return