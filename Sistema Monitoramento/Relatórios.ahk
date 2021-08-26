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

; Globais
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
	Gui, Add, MonthCal,		x10		y5	w225	h393	gs_mes		vmes
		Gui.Font( "Bold", "cFFFFFF" )
	Gui, Add, Text,			x240	y10	w120	h20															,	Apenas Operador = 
	Gui, Add, DropDownList,	y5							gs_mes		vOperador					AltSubmit	,	Todos||Operador 1|Operador 2|Operador 3|Operador 4|Operador 5|Facilitador
	Gui, Add, Checkbox,		y10			w418			gs_mes		vPeriodo								,	Filtrado por dia
	Gui, Add, Checkbox,		y10							gs_mes		v_M					%d%	%c%				,	Filtrar apenas Eventos Especiais
	Gui, Add, Text,			y10			w60																	,	Contendo:
		Gui.Font()
	Gui, Add, Edit,			y5			w100						vBusca
		Gui.Font()
	Gui, Add, ListView,		x240	y30	w1020			gSelectLV	veventos	Grid	R20		AltSubmit	,	idStart|idEnd|Operador Inicial|Relatório|Estação|Cliente|Partição|Operador Final|CodEvento|Setor|Tipo|idCliente|Unidade
		Gui.Font( "Bold", "cFFFFFF" )
	Gui, Add, Text,			x10			w750	h20										0x1000	Center		,	SEQUÊNCIA DE EVENTOS
	Gui, Add, Text,			x770	yp	w490	h20										0x1000	Center		,	RELATÓRIO
		Gui.Font()
	Gui, Add, ListView,		x10			w750						vocorridos	Grid	R10					,	Unidade|Data|Evento|Complemento|Descrição
		Gui.Font( "S10" )
	Gui, Add, Edit,			x770	yp	w490	h197				vdescritivo	+VScroll
		Gui.Font()
	Gosub	Preenche
	Gui, -DPIScale
	if	(	A_UserName	=	"dsantos"
	||		A_UserName	=	"llopes"
	||		A_UserName	=	"alberto"
	||		A_UserName	=	"arsilva"
	||		A_UserName	=	"jcsilva"
	||		A_UserName	=	"ddiel" )
		; Gui,	Add, Button,xm					h25		gRelatorio							Center		,	GERAR RELATÓRIO
	Gui, Show,	y0,	Relatórios
	GuiControl,	Focus,	eventos
	Send,	{Down}
return

Preenche:
	LV_Delete()
	Gui, Submit, NoHide
	lastrow =
	FormatTime,	yday,	%mes%,	yyyy-MM-dd
	is_m := _M = 1 ? "a.[tipo]='m' AND" : ""
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
			%is_m%
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

SelectLV:
	Gui, Submit,	NoHide
	If ( A_GuiEvent = "S" )
		Return
	Gui, ListView,	eventos
	row	:=	LV_GetNext()
	if ( lastrow = row )
		return
	if ( row = 0 )	{
		row		=	1
		lastrow	:=	row
	}
	lastrow := row
	LV_GetText(	b,	row,	1)
	LV_GetText(	a,	row,	2)
	LV_GetText(	u,	row,	8)
	LV_GetText(	o,	row,	4)
	LV_GetText(	ev,	row,	9)
	LV_GetText(	ox,	row,	14)
	LV_GetText(	i,	row,	12)
	LV_GetText(	l,	row,	13)
	l	:=	StrReplace(	l,	"|",	"-"	)
	Gosub	SQL
	GuiControl,	,	Descritivo,	%o%`n_____________`n%u%
	o2	:=	o
	r:=o:=""
return

SQL:
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
			p.Sequencia	between	'%a%' AND '%b%'	AND
			p.idCliente = '%i%'
		ORDER BY
			2 ASC
		)
	s	:=	sql( s )
	Gui, ListView,	ocorridos
	LV_Delete()
	e130:=e570:=hora_disparo:=hora_desarme:=hora_restauro:=hora_arme:=""
	zonas		:=[]
	Inibidas	:=[]
	Loop, % s.Count()-1	{
		LV_Add(	""
			,	s[A_Index+1,1]
			,	s[A_Index+1,2]
			,	s[A_Index+1,3]
			,	s[A_Index+1,4]
			,	s[A_Index+1,5]	)
		if	(	s[A_Index+1,3] = "E130" )	{
			e130++
			if ( A_Index+1 = 2 ) {	;	Se for a hora do primeiro disparo
				zonas.Push( s[A_Index+1,4] . " - " . alarm.Name( s[A_Index+1,4], id_cliente ) )
				hora_disparo := SubStr( s[A_Index+1,2], InStr(s[A_Index+1,2]," ")+1 )
			}
			Else				
				zonas.Push( s[A_Index+1,4] . " - " . alarm.Name( s[A_Index+1,4], id_cliente ) )
		}
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
		||		s[A_Index+1,3] = "E577")	{
			e570++
			Inibidas.Push( s[A_Index+1,4] . " - " . alarm.Name( s[A_Index+1,4], id_cliente ) )
		}
	}
	sensores =
	if( ev = "E130" )	{
		descricao := StrReplace( StrReplace( o, "`n", "++" ), "`r", "--" )
			loop,	2
				if (	SubStr( descricao, 1, 2 ) = "++"
				||		SubStr( descricao, 1, 2 ) = "--" )
					descricao := SubStr( descricao, 3 )
			descricao := StrReplace( descricao, "--++" , "`n" )

		if ( Inibidas.Count() > 1 )
			Loop,%	Inibidas.Count()
				if( A_index = 1 )	
					zInibidas := "`nZonas inibidas:`n`t" Inibidas[A_Index]
				else
					zInibidas .= "`n`t" Inibidas[A_Index]
		if ( Inibidas.Count() = 1 )
			zInibidas :=	"`nZona inibida:`n`t" Inibidas[1]
		if ( Inibidas.Count() = 0 )
			zInibidas =
		if ( zonas.Count() > 1 ) {
			Loop,%	zonas.Count()
				sensores .=	"`n`t" zonas[A_Index]
			if ( StrLen( hora_desarme ) > 1 )
				fim_disparo :=	"Alarme desarmado às "	hora_desarme
			if ( StrLen( hora_arme ) > 1 )
				fim_disparo :=	"Alarme desarmado às "	hora_desarme ".`nArmado novamente às " hora_arme	zInibidas
			if ( StrLen( hora_restauro ) > 1 )
				fim_disparo	:=	"Alarme restaurado às "	hora_restauro
			encerramento	=	Disparo as %hora_disparo%, nas zonas:%sensores%`n%fim_disparo%`n%descricao%
		}
		Else	{
			if ( StrLen( hora_desarme ) > 1 )
				fim_disparo	:=	"Alarme desarmado às "	hora_desarme
			if ( StrLen( hora_arme ) > 1 )
				fim_disparo	:=	"Alarme desarmado às "	hora_desarme ".`nArmado novamente às " hora_arme	zInibidas
			if ( StrLen( hora_restauro ) > 1 )
				fim_disparo	:=	"Alarme restaurado às "	hora_restauro
			sensores	:=	"`n`t"zonas[1] "`n"
			encerramento	=	Disparo as %hora_disparo%, na zona%sensores%%fim_disparo%`n%descricao%
		}
		o := encerramento
		encerramento:=fim_disparo:=zInibidas:=""
	}
	LV_ModifyCol( 1, 200 )
	LV_ModifyCol( 2, 120 )
	LV_ModifyCol( 3, 50 )
	LV_ModifyCol( 4, 80 )
	LV_ModifyCol( 5, 295 )
return

s_mes:
	Gui,	Submit,	NoHide
	if ( StrLen( Busca ) > "0" )
		b = AND a.Observacoes_conta LIKE '`%%Busca%`%'
	else
		b =
	if ( periodo = 1 )	{
		FormatTime,	diaAntes,	%mes%,	YDay
		FormatTime,	mes,	%mes%,	yyyy-MM-dd
		FormatTime,	Today,	%A_Now%,	yyyy-MM-dd
		periodox := A_YDay-diaAntes
		GuiControl,	+c2BDC33 +Redraw, periodo
		if ( operador > 1 )
			op := operador-1
		if ( periodox = 0 )
			periodo	:=	"DATEDIFF(DAY,a.Disparo,'"	mes	"') = "	periodox
		else
			periodo	:=	"CAST(a.Disparo AS DATE) >= '"	mes	"'	and CAST(a.Disparo AS DATE) <= '"	Today	"'"
	}
	else	{
		GuiControl,	+cB8B8B8 +Redraw, periodo
		FormatTime,	mes,	%mes%,	yyyy-MM-dd
		periodo = DATEDIFF(DAY,a.Disparo,'%mes%') = 0
		GuiControl,	,	Periodo,	Filtrado por dia
	}
	if ( operador = 1 )	{
		operador=
	}
	Else if (	operador > 1
		&&		operador < 7 ) {
		operador := operador-1
		operador =	AND	c.Descricao = 'OPERADOR 0%operador%'
	}
	Else
		operador =	AND	c.Descricao = 'MONITORAMENTO'
	lastrow	=
	is_m := _M = 1 ? "a.[tipo] = 'm' AND" : ""
	FormatTime,	yday,	%mes%,	yyyy-MM-dd
	e =
		(
		SELECT	a.IdSequencia
				,a.IdSeqStart
				,a.OperadorDisparo
				,a.Observacoes_conta
				,a.EstacaoDisparo
				,a.Cliente
				,a.Particao
				,a.OperadorFinalizou
				,a.CodEvtFinalizou
				,c.Descricao
				,a.Tipo
				,a.IdCliente
				,b.Nome
				,d.desconformidade
		FROM [IrisSQL].[dbo].[Procedimentos] a
		LEFT JOIN
			[IrisSQL].[dbo].[Clientes] b ON	a.IdCliente = b.IdUnico
		LEFT JOIN
			[IrisSQL].[dbo].[Setores] c	ON	b.Setor = c.Setor
		LEFT JOIN
			[ASM].[Sistema_Monitoramento].[dbo].[desconformidades]	d ON a.IdSequencia = d.nr_procedimento
		WHERE
			(a.Observacoes_conta IS NOT NULL)	AND
			(DATALENGTH(a.Observacoes_conta) <> 0)	AND
			%is_m%
			%periodo%
			AND	c.Descricao	!=	'GUARITA'
			%operador%
			%b%
		ORDER BY
			a.IdSequencia DESC
		)
	; Clipboard:=e
	e	:=	sql( e )
	Gui,	ListView,	eventos
	LV_Delete()
	Loop, % e.Count()-1	{
		eventos		:=	e[A_index+1,4]
		id_cliente	:=	e[A_index+1,12]
		if( _M = 1 )
			if ( e[A_Index+1,11] != "M" )
				return
		LV_Add(	autosize
			,	e[A_index+1,1]
			,	e[A_index+1,2]
			,	e[A_index+1,3]
			,	eventos
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
	gosub	SelectLV
return

~Enter::
	~NumpadEnter::
	Gui,	Submit,	NoHide
	goto	s_mes
;

GuiClose:
	ExitApp
;