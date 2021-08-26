;@Ahk2Exe-SetMainIcon C:\Dih\zIco\2LembEdit.ico

#IfWinActive	Relatórios
	#SingleInstance Force
	#Persistent
	#Include ..\class\sql.ahk
	#Include ..\class\functions.ahk
	; #Include ..\class\windows.ahk
	; #Include ..\class\array.ahk
	#Include ..\class\gui.ahk
	; #Include ..\class\safedata.ahk
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
	Gui, Add, Text,			x240	y10	w120	h20														,	ÚLTIMOS EVENTOS
	Gui, Add, DropDownList,	y5							gs_mes		vOperador				AltSubmit	,	Todos||Operador 1|Operador 2|Operador 3|Operador 4|Operador 5|Facilitador
	Gui, Add, Checkbox,		y10			w418			gs_mes		vPeriodo							,	Filtrado por dia
	Gui, Add, Checkbox,		y10							gs_mes		v_M					%d%	%c%			,	Filtrar apenas úteis
	Gui, Add, Text,			y10			w60																,	Contendo:
		Gui.Font()
	Gui, Add, Edit,			y5			w100						vBusca
		Gui.Font()
	Gui, Add, ListView,		x240	y30	w1020			gSelectLV	vEv1	Grid	R20		AltSubmit	,	idStart|idEnd|Operador Inicial|Relatório|Estação|Cliente|Partição|Operador Final|CodEvento|Setor|Tipo|idCliente|Unidade|disparo
		Gui.Font( "Bold", "cFFFFFF" )
	Gui, Add, Text,			x10			w750	h20									0x1000	Center		,	SEQUÊNCIA DE EVENTOS
	Gui, Add, Text,			x770	yp	w490	h20									0x1000	Center		,	RELATÓRIO
		Gui.Font()
	Gui, Add, ListView,		x10			w750						vEv2	Grid	R10					,	Unidade|Data|Evento|Complemento|Descrição
		Gui.Font( "S10" )
	Gui, Add, Edit,			x770	yp	w490	h197				vEv3					+VScroll
		Gui.Font()
		gosub	Preenche
	Gui, -DPIScale
	if	(	A_UserName	=	"dsantos"
	||		A_UserName	=	"llopes"
	||		A_UserName	=	"alberto"
	||		A_UserName	=	"arsilva"
	||		A_UserName	=	"jcsilva"
	||		A_UserName	=	"ddiel" )
		Gui,	Add, Button,xm					h25		gRelatorio							Center		,	GERAR RELATÓRIO
	Gui, Show,	y0,	Relatórios
	GuiControl,	Focus,	Ev1
	Send,	{Down}
return

Preenche:
	LV_Delete()
	Gui,	Submit,	NoHide
	lastrow=
	FormatTime,	yday,	%mes%,	yyyy-MM-dd
	is_m:=(_M=1)?("a.[tipo]='m'	AND"):("")
	e	=	
	(
		SELECT		a.IdSequencia,
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
		FROM	[IrisSQL].[dbo].[Procedimentos]	a
		LEFT JOIN	[IrisSQL].[dbo].[Clientes]		b	ON	a.IdCliente	=	b.IdUnico
		LEFT JOIN	[IrisSQL].[dbo].[Setores]		c	ON	b.Setor		=	c.Setor
		LEFT JOIN	[ASM].[Sistema_Monitoramento].[dbo].[desconformidades]	d	ON	a.IdSequencia	=	d.nr_procedimento
		WHERE	(a.Observacoes_conta IS NOT NULL)	AND
		%is_m%
		(DATALENGTH(a.Observacoes_conta)<>0)		AND
		DATEDIFF(day,a.Disparo,'%yday%') = 0				AND
		a.Cliente BETWEEN	'10001'								AND	'10999'
		ORDER	BY	a.IdSequencia DESC
	)
	; MsgBox % Clipboard:=e
	e:=sql(e)
	Gui,	ListView,	Ev1
	Loop,	14
		LV_ModifyCol(A_Index,0)
	LV_ModifyCol(4,500)
	LV_ModifyCol(8,100)
	LV_ModifyCol(10,100)
	LV_ModifyCol(13,290)
	Loop, % e.Count()-1	{
		o:=e[A_index+1,4]
		if(InStr(o,"#disparo")!=0)		{
			o	:=	StrReplace(o,"#disparo ","#disparo`n")
			o	:=	StrReplace(o,"#disparo.","#disparo`n")
			o	:=	StrReplace(o,"#disparo")
			disparo	=	#disparo
			}
			else	{
				disparo	=
			}
		i:=e[A_index+1,12]
		if(StrLen(e[A_index+1,14])>3)		{	;	Marca um X na frente dos relat�rios em desconformidade para os admins
			if(A_UserName="dsantos"	or	A_UserName="llopes"	or	A_UserName="alberto"	or	A_UserName="arsilva")
				o	:=	"X - " o
			}
		LV_Add(autosize,e[A_index+1,1],e[A_index+1,2],e[A_index+1,3],o,e[A_index+1,5],e[A_index+1,6],e[A_index+1,7],e[A_index+1,8],e[A_index+1,9],e[A_index+1,10],e[A_index+1,11],i,e[A_index+1,13],disparo)
		}
return

GuiContextMenu:
	if(A_IPAddress1!="192.9.100.184")
		return
	if (A_GuiControl != "Ev1")
		return
	Menu, Marcar, Show, %A_GuiX%, %A_GuiY%
	return	;}
	_desconforme:		;{
	Gui,	m:Add,	DropDownList,	x20		y10		w700	h40		R5					vNConf	gmddl	, |N�o consta sensores|N�o consta hor�rio|N�o consta motivo|N�o consta procedimentos adotados|N�o ligou atr�s
	Gui,	m:Add,	Edit,					x20		y40		w700	h40								vON					,	%o2%
	Gui,	m:Add,	Edit,					x20		y85		w700	h60								vON2
	Gui,	m:Add,	Button,				x20		y160	w340	h30		g_finalizar									, Marcar
	Gui,	m:Add,	Button,				x380	y160	w340	h30		gMGuiClose								, Cancelar
	Gui,	m:Show
	o2	=
return

Exclude:
		Gui,	ListView,	Ev1
		Gui,	ListView,	Default
		row:=LV_GetNext()
		LV_GetText(iddel,row,1) "`n" row
		MsgBox,	4,	Deletar,	Tem certeza que deseja deletar esse relat�rio?
		IfMsgBox,	No
			return
		if ( iddel = "" )
			return
		d=DELETE FROM [IrisSQL].[dbo].[Procedimentos] WHERE idSequencia = '%iddel%'
		d:=sql(d)
		gosub	Preenche
return

_finalizar:
	Gui,	M:Submit
	if(StrLen(NConf)>0)	{
		ON2	:=	NConf
		}
	if(StrLen(NConf)=0 AND	StrLen(ON2)=0)	{
		return
		}
	doup=INSERT INTO [Sistema_Monitoramento].[dbo].[desconformidades] (nr_procedimento,desconformidade) VALUES ('%b%','%ON2%')
	doup:=sql(doup,3)
	Gui,	M:Destroy
	return	;}
	mddl:						;{
	Gui,	M:Submit,	NoHide
	if(StrLen(NConf)>0)	{
		GuiControl,	M:Disable,	ON2
		GuiControl,	M:,	ON2
	}
	else
		GuiControl,	M:Enable,	ON2
	return					;}
	SelectLV:				;{
	Gui,	Submit,	NoHide
	Gui,	ListView,	Ev1
	row	:=	LV_GetNext()
	if(lastrow=row)
		return
	if(row=0)	{
		row			=		1
		lastrow	:=	row
	}
	lastrow:=row
	LV_GetText(b,row,1)
	LV_GetText(a,row,2)
	LV_GetText(u,row,8)
	LV_GetText(o,row,4)
	LV_GetText(ev,row,9)
	LV_GetText(ox,row,14)
	LV_GetText(i,row,12)
	LV_GetText(l,row,13)
	l:=StrReplace(l,"|","-")
	gosub	SQL
	GuiControl,	,	Ev3,	%o%`n_____________`n%u%
	o2	:=	o
	r	=
	o	=
return

SQL:
	s	=
	(
		SELECT c.Nome,p.Data,p.Evento,p.Zona,p.Descricao	FROM [IrisSQL].[dbo].[Eventos] p
		LEFT JOIN [IrisSQL].[dbo].[Clientes] c ON p.IdCliente = c.IdUnico	WHERE	p.Sequencia	between	'%a%'	AND	'%b%'	AND	p.idCliente = '%i%'
		order by 2 asc
	)
	s	:=	sql(s)
	Gui,	ListView,	Ev2
	;~ MsgBox % o
	LV_Delete()	;{	Limpa vars #disparo
		e130				=
		e570				=
		hora_disparo	=
		hora_desarme=
		hora_restauro=
		hora_arme		=
		zonas				:=[]
		zonasInibidas	:=[]
	;}
	Loop, % s.Count()-1
	{
		LV_Add("",s[A_Index+1,1],s[A_Index+1,2],s[A_Index+1,3],s[A_Index+1,4],s[A_Index+1,5])
		;{GERENCIAMENTO DE #DISPARO
		if(s[A_Index+1,3]="E130")	{																					;	Se for evento de disparo
			e130++
			if(A_Index+1=2)	{																								;	Se for a hora do primeiro disparo
				; busca_sensor(s[A_Index+1,4],i)
				zonas.Push(zona . " - " . nomeSensor)
				;~ zonas.Push(s[A_Index+1,4] . " - " s[A_Index+1,5])
				hora_disparo	:=	SubStr(s[A_Index+1,2],InStr(s[A_Index+1,2]," ")+1)
			}	Else	{																													;	do segundo disparo em diante
				; busca_sensor(s[A_Index+1,4],i)
				zonas.Push(zona . " - " . nomeSensor)
				;~ zonas.Push(s[A_Index+1,4] . " - " s[A_Index+1,5])
			}
		}
		if(s[A_Index+1,3]="R402" or	s[A_Index+1,3]="R401")										;{	Se for evento de arme
				hora_arme			:=	SubStr(s[A_Index+1,2],InStr(s[A_Index+1,2]," ")+1)	;}
		if(s[A_Index+1,3]="E402" or	s[A_Index+1,3]="E401")										;{	Se for evento de desarme
				hora_desarme	:=	SubStr(s[A_Index+1,2],InStr(s[A_Index+1,2]," ")+1)	;}
		if(s[A_Index+1,3]="R130")																						;{	Se for evento de restauro
				hora_restauro	:=	SubStr(s[A_Index+1,2],InStr(s[A_Index+1,2]," ")+1)	;}
		if(s[A_Index+1,3]="E570" or s[A_Index+1,3]="E571" or s[A_Index+1,3]="E572" or s[A_Index+1,3]="E573" or s[A_Index+1,3]="E574" or s[A_Index+1,3]="E575" or s[A_Index+1,3]="E576" or s[A_Index+1,3]="E577")	{			;{	Se for evento de sensor inibido
			e570++
			if(A_Index+1=2)	{																								;	Se for a hora do primeiro disparo
				; busca_sensor(s[A_Index+1,4],i)
				zonasInibidas.Push(zona . " - " . nomeSensor)
			}
			Else																															;	do segundo disparo em diante
			{
				; busca_sensor(s[A_Index+1,4],i)
				zonasInibidas.Push(zona . " - " . nomeSensor)
			}
		}	;}	;}
	}
	;~ MsgBox % o
	sensores	=
	if(InStr(ox,"#disparo")!=0 or ev="E130")	{
		descricao:=StrReplace(StrReplace(o,"`n","++"),"`r","--")	;{	Remove double newlines
		loop,	2
		{
			if(SubStr(descricao,1,2)="++")
				descricao:=SubStr(descricao,3)
			if(SubStr(descricao,1,2)="--")
				descricao:=SubStr(descricao,3)
		}
		; Loop,	%	st_count(descricao,"--++--++")
		; 	descricao:=StrReplace(descricao,"--++--++","--++")
		descricao:=StrReplace(descricao,"--++","`n")	;}
		if(zonasInibidas.Count()>1)	;{
			Loop,	%	zonasInibidas.Count()
				if(A_index=1)	
					zInibidas	:=	"`nZonas inibidas:`n`t" zonasInibidas[A_Index]
				else
					zInibidas	.=	"`n`t" zonasInibidas[A_Index]
		if(zonasInibidas.Count()=1)
			zInibidas	:=	"`nZona inibida:`n`t" zonasInibidas[1]
		if(zonasInibidas.Count()=0)
			zInibidas		=		;}
		if(zonas.Count()>1)	{	;{
			Loop,	%	zonas.Count()
				sensores	.=	"`n`t" zonas[A_Index]
			if(StrLen(hora_desarme)>1)
				fim_disparo	:=	"Alarme desarmado as "	hora_desarme
			if(StrLen(hora_arme)>1)
				fim_disparo	:=	"Alarme desarmado as "	hora_desarme ".`nArmado novamente as " hora_arme	zInibidas
			if(StrLen(hora_restauro)>1)
				fim_disparo	:=	"Alarme restaurado as "	hora_restauro
			encerramento	=	Disparo as %hora_disparo%, nas zonas:%sensores%`n%fim_disparo%`n%descricao%
		}		else		{
			if(StrLen(hora_desarme)>1)
				fim_disparo	:=	"Alarme desarmado as "	hora_desarme
			if(StrLen(hora_arme)>1)
				fim_disparo	:=	"Alarme desarmado as "	hora_desarme ".`nArmado novamente as " hora_arme	zInibidas
			if(StrLen(hora_restauro)>1)
				fim_disparo	:=	"Alarme restaurado as "	hora_restauro
			sensores	:=	"`n`t"zonas[1] "`n"
			encerramento	=	Disparo as %hora_disparo%, na zona%sensores%%fim_disparo%`n%descricao%
		}	;}
		o:=encerramento
		encerramento	=
		fim_disparo		=
		zInibidas				=
	}
	LV_ModifyCol(1,200)
	LV_ModifyCol(2,120)
	LV_ModifyCol(3,50)
	LV_ModifyCol(4,80)
	LV_ModifyCol(5,295)
return

s_mes:
	Gui,	Submit,	NoHide
	if(StrLen(Busca)>"0")	;{
		b	=	AND	a.Observacoes_conta	LIKE	'`%%Busca%`%'
	else
		b	=	;}
	if(periodo=1)	{	;{	Se a checkbox para periodo selecionado
		FormatTime,	diaAntes,	%mes%,	YDay
		FormatTime,	mes,	%mes%,	yyyy-MM-dd
		FormatTime,	Today,	%A_Now%,	yyyy-MM-dd
		periodox:=A_YDay-diaAntes
		GuiControl,	+cYellow +Redraw, periodo
		if(operador=1)
			GuiControl,	,	Periodo,	Filtrado de %mes% � %Today% com TODOS os operadores
		if(operador>1 and operador<7)
			GuiControl,	,	Periodo,	Filtrado de %mes% � %Today% eventos do OPERADOR %op%
		if(operador=7)
			GuiControl,	,	Periodo,	Filtrado de %mes% � %Today% eventos do FACILITADOR
		if(operador>1)
			op:=operador -1
		if(periodox=0)	{
			periodo	:=	"DATEDIFF(DAY,a.Disparo,'"	mes	"') = "	periodox
		if(operador=1)
			GuiControl,	,	Periodo,	Filtrado de %mes% � %Today% com TODOS os operadores
		if(operador>1 and operador<7)
			GuiControl,	,	Periodo,	Filtrado de %mes% � %Today% eventos do OPERADOR %op%
		if(operador=7)
			GuiControl,	,	Periodo,	Filtrado de %mes% � %Today% eventos do FACILITADOR
		}
		else	{
			periodo	:=	"CAST(a.Disparo AS DATE) >= '"	mes	"'	and CAST(a.Disparo AS DATE) <= '"	Today	"'"
		}
	}
	else	{
		GuiControl,	+cWhite +Redraw, periodo
		FormatTime,	mes,	%mes%,	yyyy-MM-dd
		periodo = DATEDIFF(DAY,a.Disparo,'%mes%') = 0
		GuiControl,	,	Periodo,	Filtrado por dia
	}	;}
	if(operador=1)	{
		operador	=
		}	else	if(operador>1 and operador<7){
			operador:=operador-1
		operador	=	AND	c.Descricao	=	'OPERADOR 0%operador%'
		}	else	{
		operador	=	AND	c.Descricao	=	'MONITORAMENTO'
		}
	lastrow	=
	is_m:=(_M=1)?("a.[tipo]='m'	AND"):("")
	FormatTime,	yday,	%mes%,	yyyy-MM-dd
	e	=	;{	Busca os eventos para popular a listview
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
		FROM	[IrisSQL].[dbo].[Procedimentos] 											a
		LEFT JOIN	[IrisSQL].[dbo].[Clientes]													b	ON	a.IdCliente			=	b.IdUnico
		LEFT JOIN	[IrisSQL].[dbo].[Setores]													c	ON	b.Setor				=	c.Setor
		LEFT JOIN	[ASM].[Sistema_Monitoramento].[dbo].[desconformidades]	d	ON	a.IdSequencia	=	d.nr_procedimento
		WHERE			(a.Observacoes_conta IS NOT NULL)	AND
		(DATALENGTH(a.Observacoes_conta) <> 0)				AND
		%is_m%
		%periodo%
		AND	c.Descricao	!=	'GUARITA'
		%operador%
		%b%
		ORDER	BY	a.IdSequencia DESC
	)
	Clipboard:=e
	e	:=	sql(e)	;}
	Gui,	ListView,	Ev1
	LV_Delete()
	Loop, % e.Count()-1	{	;	Insere eventos na lista principal
		o	:=	e[A_index+1,4]
		i	:=	e[A_index+1,12]
		if(InStr(o,"#disparo")!=0)	{			;{	Se conter a #disparo
			o	:=	StrReplace(o,"#disparo ","#disparo`n")
			o	:=	StrReplace(o,"#disparo")
			disparo	=	#disparo
		}
		else
			disparo	=	;}
		if(StrLen(e[A_index+1,14])>3)	{	;	Se estiver marcado como desconformidade.
			if(A_UserName="dsantos"	or	A_UserName="llopes"	or	A_UserName="alberto"	or	A_UserName="arsilva")
				o	:=	"X - " o
		}
		
		if(_M=1)
			if(e[A_Index+1,11]!="M")
				return
		LV_Add(autosize,e[A_index+1,1],e[A_index+1,2],e[A_index+1,3],o,e[A_index+1,5],e[A_index+1,6],e[A_index+1,7],e[A_index+1,8],e[A_index+1,9],e[A_index+1,10],e[A_index+1,11],i,e[A_index+1,13],disparo)
	}
	gosub	SelectLV
return

Limpa:
	GuiControl,	,	Busca
	goto	s_mes
;

Relatorio:
	Gui,	Submit,	NoHide
	r	:=	l "`n_______________________________________`n`n"
	Gui,	ListView,	Ev2
	xz	:=		LV_GetCount()
	Loop,	%	LV_GetCount()	{
		LV_GetText(r1,A_Index,1)
		LV_GetText(r2,A_Index,2)
		LV_GetText(r3,A_Index,3)
		LV_GetText(r4,A_Index,4)
		LV_GetText(r5,A_Index,5)
		r1	:=	StrReplace(r1,"|","-")
		if(xz=A_Index)	{
			r	.=	r1 " | "r2 " | "r5
		}
		else
		{
			r	.=	r1 " | "r2 " | "r5 "`n"
		}
	}
	r	.=	" `n`nConforme relatado abaixo:`n_______________________________________`n" Ev3
	Run,	Notepad
	Clipboard	:=	r
	WinWaitActive,	ahk_class Notepad
	WinMaximize,	ahk_class Notepad
	Send,	^V
	Clipboard=
	return	;}
	~Enter::				;{
	~NumpadEnter::
	Gui,	Submit,	NoHide
	goto	s_mes
;

GuiClose:
	ExitApp
;

MGuiClose:
	Gui,	M:Destroy
return
