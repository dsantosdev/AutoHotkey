;@Ahk2Exe-SetMainIcon	C:\Seventh\Backup\ico\2LembEdit.ico
;	Inicio Header Principal
global	debug
	,	is_test
	,	admins
;local
	is_test = 
	debug = 
	delay = 500	;	No typing interval for start filtering
	done = 0
#IfWinActive, Login Cotrijal
#InstallKeybdHook
#SingleInstance Force
#Persistent
#Include ..\class\sql.ahk
#Include ..\class\functions.ahk
#Include ..\class\windows.ahk
#Include ..\class\array.ahk
#Include ..\class\gui.ahk
#Include ..\class\safedata.ahk
if ( is_test = 1 )	{
	@usuario = dsantos
	Goto interface
	}
	Else
		Goto, Login
;	Return

Interface:
	Gui, Login:Destroy
		user	:=	A_UserName = "dsantos" ? "dsantos" : @user
		;	Fim do Header Principal
	Gui.Cores( "CamerasEdit" )
	Gui,	CamerasEdit:Default
	Gui,	CamerasEdit:Add,	Edit,	w610						v_filter	g_filtro	,	%	ddl_unidades
		Gui.Font( "CamerasEdit", "CWhite", "Bold" )
	Gui,	CamerasEdit:Add,	Text,	Section												,	IP
	Gui,	CamerasEdit:Add,	Text,														,	Nome
	Gui,	CamerasEdit:Add,	Text,														,	Local
	Gui,	CamerasEdit:Add,	Text,														,	Alterações
		Gui.Font( "CamerasEdit" )
	Gui,	CamerasEdit:Add,	Edit,	ys	Section	w130	v_ip				Disabled
	Gui,	CamerasEdit:Add,	Edit,						w130	v_nome		Disabled
	Gui,	CamerasEdit:Add,	Edit,						w130	v_local		Disabled
		Gui.Font( "CamerasEdit", "CWhite", "Bold" )
	Gui,	CamerasEdit:Add,	Text,	ys	Section											,	MAC
	Gui,	CamerasEdit:Add,	Text,														,	Marca
	Gui,	CamerasEdit:Add,	Text,														,	Patrimônio
		Gui.Font( "CamerasEdit" )
	Gui,	CamerasEdit:Add,	Edit,	ys	Section			w130	v_mac		Disabled
	Gui,	CamerasEdit:Add,	Edit,						w130	v_model		Disabled
	Gui,	CamerasEdit:Add,	Edit,						w130	v_serial	ReadOnly
		Gui.Font( "CamerasEdit", "CWhite", "Bold" )
	Gui,	CamerasEdit:Add,	Text,	ys	Section											,	Operador
	Gui,	CamerasEdit:Add,	Text,														,	Sinistro
	Gui,	CamerasEdit:Add,	Text,														,	Por
		Gui.Font( "CamerasEdit" )
	Gui,	CamerasEdit:Add,	Edit,	ys	Section			w127	v_setor		Disabled
	Gui,	CamerasEdit:Add,	DropDownList,				w127	v_sinistro	Disabled	,	||1|2|3|4|5
		Gui.Font( "CamerasEdit", "CWhite", "Bold" )
	Gui,	CamerasEdit:Add,	Edit,						w127	v_operador	ReadOnly
	Gui,	CamerasEdit:Add,	Edit,	x80	y115			w540	v_change	ReadOnly
		Gui.Font( "CamerasEdit" )
	Gui,	CamerasEdit:Add,	ListView,xm	Grid	AltSubmit		vlv	w610	R15	g_s_cam	,	IP|Nome|md|mac|last_md|Setor|patrimonio|Modelo|comentario|modificado|operador|alteracoes|local|id|Sinistro
		gosub	_preenche_lv
	Gui,	CamerasEdit:Add,	Button,	xm	Section	Hidden			v_n_ok		g_n_ok		,	Inserir
	Gui,	CamerasEdit:Add,	Button,	ys			Hidden			v_n_cancel	g_n_cancel	,	Cancelar
	Gui,	CamerasEdit:Add,	Button,	ys							v_new_cam	g_new_cam	,	Inserir Nova Câmera
	Gui,	CamerasEdit:Add,	Button,	xs	ys						v_ok		g_ok		,	Confirmar
	Loop,	14	;	LV_Options
		LV_ModifyCol(A_Index,0)
		LV_ModifyCol(1,100)
		LV_ModifyCol(2,200)
		LV_ModifyCol(6,50)
		LV_ModifyCol(8,140)
	Gui,	CamerasEdit:Show,																,	Editar Câmeras
return

_done:
	Gui, CamerasEdit:Default
	LV_Delete()
	done = 1
	ip:=nome:=local:=modificado:=mac:=model:=patrimonio:=setor:=operador:=_filter:=""
	sinistro := 0
	GuiControl, CamerasEdit:, _filter
	gosub clear
; 	goto _preenche_lv
; Return

_filtro:
	if ( done = 0 )
		Loop
			if ( A_TimeIdleKeyboard > delay )
				break
	Else
		done = 0
	Gui,	CamerasEdit:Submit, NoHide
	where := StrLen( _filter ) > 0 ? "And [nome] like '%" _filter "%'" : ""
	if ( StrLen( where ) > 0 )
		LV_Delete()
;return

_preenche_lv:
	s =
		(
		SELECT	[ip]
			,	[Nome]
			,	[md]
			,	[mac]
			,	[last_md]
			,	[setor]
			,	[patrimonio]
			,	[modelo]
			,	[comentario]
			,	[modificado]
			,	[operador]
			,	[alteracoes]
			,	[local]
			,	[id]
			,	[em_sinistro]
		FROM
			[MotionDetection].[dbo].[Cameras]
		WHERE
			Len([nome]) > 3
			%where%
		ORDER BY
			1
		)
	ips	:=	{}
	cams := sql( s, 3 )
	Loop,	%	cams.Count()-1	{
		LV_Add(	""
			,	ip_		:= cams[A_Index+1,1]
			,	nome_	:= cams[A_Index+1,2]
			,	cams[A_Index+1,3]
			,	cams[A_Index+1,4]
			,	cams[A_Index+1,5]
			,	cams[A_Index+1,6]
			,	cams[A_Index+1,7]
			,	cams[A_Index+1,8]
			,	cams[A_Index+1,9]
			,	cams[A_Index+1,10]
			,	cams[A_Index+1,11]
			,	cams[A_Index+1,12]
			,	cams[A_Index+1,13]
			,	cams[A_Index+1,14]
			,	cams[A_Index+1,15]		 )
		ips.Push({	ip		:	ip_
				,	nome	:	nome_ })
		}
return

_s_cam:
	if (	A_EventInfo 	= 0
		||	LV_GetNext()	= 0 )
		return
	if (	LV_GetText( ip,	LV_GetNext(), 1 )	=	last
		||	ip	=	"IP"	)
		return
		lastid	:= LV_GetNext()
		last	:= ip
	LV_GetText(	nome,		LV_GetNext(), 2 )
	LV_GetText(	mac,		LV_GetNext(), 4 )
	LV_GetText(	last_md,	LV_GetNext(), 5 )
	LV_GetText(	setor,		LV_GetNext(), 6 )
	LV_GetText(	patrimonio,	LV_GetNext(), 7 )
	LV_GetText(	model,		LV_GetNext(), 8 )
	LV_GetText(	comentario,	LV_GetNext(), 9 )
	LV_GetText(	operador,	LV_GetNext(), 11 )
	LV_GetText(	modificado,	LV_GetNext(), 12 )
	LV_GetText(	local,		LV_GetNext(), 13 )
	LV_GetText(	id,			LV_GetNext(), 14 )
	LV_GetText(	sinistro,	LV_GetNext(), 15 )
;return

;Controles_de_GUI
clear:
	GuiControl,	CamerasEdit:,		_ip,%		ip
		status := StrLen( ip ) > 0 ? "Enable" : "Disable"
		GuiControl,	CamerasEdit:%status%,		_ip
	GuiControl,	CamerasEdit:,		_nome,%		nome
		status := StrLen( nome ) > 0 ? "Enable" : "Disable"
		GuiControl,	CamerasEdit:%status%,	_nome
	GuiControl,	CamerasEdit:,		_local,%	local
		status := StrLen( local ) > 0 ? "Enable" : "Disable"
		GuiControl,	CamerasEdit:%status%,	_local
	GuiControl,	CamerasEdit:,		_mac,%		mac
		status := StrLen( mac ) > 0 ? "Enable" : "Disable"
		GuiControl,	CamerasEdit:%status%,	_mac
	GuiControl,	CamerasEdit:,		_model,%	model
		status := StrLen( model ) > 0 ? "Enable" : "Disable"
		GuiControl,	CamerasEdit:%status%,	_model
	GuiControl,	CamerasEdit:,		_serial,%	patrimonio
	GuiControl,	CamerasEdit:,		_setor,%	setor
		status := StrLen( setor ) > 0 ? "Enable" : "Disable"
		GuiControl,	CamerasEdit:%status%,	_setor
	GuiControl,	CamerasEdit:,		_operador,%	operador
	GuiControl,	CamerasEdit:Choose,	_sinistro,%	sinistro+1
		status := StrLen( sinistro ) > 1 ? "Enable" : "Disable"
		GuiControl,	CamerasEdit:%status%,	_sinistro
	GuiControl,	CamerasEdit:,		_change,%	modificado
return

_ok:
	Gui,	CamerasEdit:Submit,	NoHide
	u_1	:=	ip			!= _ip
		?	"IP era`n`t" ip				"`nmudou para`n`t" _ip "`n____"
		:	""
	u_2	:=	nome		!= _nome
		?	"`nNome era`n`t" nome			"`nmudou para`n`t" _nome "`n____"
		:	""
	u_3	:=	local		!= _local
		?	"`nLocal era`n`t" local			"`nmudou para`n`t" _local "`n____"
		:	""
	u_4	:=	mac			!= _mac
		?	"`nMAC era`n`t" mac				"`nmudou para`n`t" _mac "`n____"
		:	""
	u_5	:=	model		!= _model
		?	"`nModelo era`n`t" model			"`nmudou para`n`t" _model "`n____"
		:	""
	u_6	:=	setor		!= _setor
		?	"`nSetor era`n`t" setor			"`nmudou para`n`t" _setor "`n____"
		:	""
	u_7	:=	sinistro	!= _sinistro
		?	"`nSinistro era`n`t" sinistro	"`nmudou para`n`t" _sinistro "`n____"
		:	""
	Loop, 7
		alterado .= u_%A_Index%
	if ( StrLen( alterado ) = 0 )	{
			MsgBox	Nenhum campo alterado.
			return
		}
	user		:=	A_UserName = "dsantos" ? "dsantos" : user
	alterado	:=	"alterado em:`t" datetime() "`nPor:`t" user "`n`n" alterado
	modificar	=
		If ( StrLen( u_1 ) > 0 )
			modificar := "[ip] = '" _ip "',"
		If ( StrLen( u_2 ) > 0 )
			modificar .= "[nome] = '" _nome "',"
		If ( StrLen( u_3 ) > 0 )
			modificar .= "[local] = '" _local "',"
		If ( StrLen( u_4 ) > 0 )
			modificar .= "[mac] = '" _mac "',"
		If ( StrLen( u_5 ) > 0 )
			modificar .= "[modelo] = '" _model "',"
		If ( StrLen( u_6 ) > 0 )
			modificar .= "[setor] = '" _setor "',"
		If ( StrLen( u_7 ) > 0 )
			modificar .= "[sinistro] = '" _sinistro "',"
		if ( InStr( modificar, "," ) > 0 )
			modificar := modificar "[operador] = '" user "',[modificado] = CAST('" datetime( 1 ) "' as datetime)" 
	do_up =
		(
		UPDATE	[MotionDetection].[dbo].[Cameras]
			SET
				%modificar%
			WHERE
				[ip] = '%ip%';

		INSERT INTO	[ASM].[dbo].[_log_sistema]
				(	[software]
				,	[ip]
				,	[cmp1]
				,	[cmp2]
				,	[cmp3]	)
			VALUES
				(	'Editor de Câmeras'
				,	'%A_IPAddress1%'
				,	'Alteração de Dados'
				,	'%user%'
				,	'%alterado%'	);
		)
	sql( do_up, 3 )
	if ( strlen( sql_le ) > 0 )
		MsgBox,,ERRO - INFORME AO DESENVOLVEDOR,% "O seguinte erro ocorreu:`n" sql_le
	alterado	=
	gosub	_done
return

_new_cam:
	ip			=	1.1.1.1
	nome		=	nome_da_camera
	local		=	local_da_camera(conforme outras da unidade)
	mac			=	mac_da_camera
	model		=	modelo_da_camera
	setor		=	operador_da_câmera(número)
	operador	:=	strlen( user ) = 0 ? user := A_UserName : user
	sinistro	=	99
	modificado	=	Inseriu nova câmera
	Gosub, clear
	GuiControl,	CamerasEdit:,			_model
	GuiControl,	CamerasEdit:,			_ip
	GuiControl,	CamerasEdit:,			_nome
	GuiControl,	CamerasEdit:,			_mac
	GuiControl,	CamerasEdit:,			_setor
	GuiControl,	CamerasEdit:,			_local
	GuiControl,	CamerasEdit:,			_serial
	GuiControl,	CamerasEdit:Choose,		_sinistro, 1
	GuiControl, CamerasEdit:+Hidden,	_new_cam
	GuiControl, CamerasEdit:+Hidden,	_filter
	GuiControl, CamerasEdit:+Hidden,	_ok
	GuiControl, CamerasEdit:-Hidden,	_n_ok
	GuiControl, CamerasEdit:+Hidden,	_serial
	GuiControl, CamerasEdit:-Hidden,	_n_cancel
	GuiControl, CamerasEdit:+Hidden,	lv
Return

_n_ok:
	Gui,	CamerasEdit:Submit,	NoHide
	;if's
		if ( StrLen( _ip ) <	7 )	{
			MsgBox,,,Ip possuí muito poucos caracteres
			Return
			}
			Else	{
				ip_size	:=	StrSplit(_ip, "." )
				verify	=
				Loop, %	ip_size.Count()	{
					if (	StrLen( ip_size[ A_Index ] ) > 3
						||	ip_size[ A_Index ] > 255 
						||	ip_size[ A_Index ] < 1 )	{
							MsgBox,,,Algum dos campos de ip`, contém mais que 3 digitos ou valor maior que 255
							Return
							}
						has_dot	:= A_Index = 1 ? "" : "."
						verify	.= has_dot LTrim( ip_size[ A_Index ], 0 )
					}
				if ( index_ := Array.InDict( ips, verify, "ip" ) > 0 )	{
					MsgBox,,,%	"Este IP já está cadastrado na base de dados para a câmera :`n" ips[index_].nome
					Return
					}
			}
		if ( StrLen( _nome ) = 0 )	{
			MsgBox,,,O campo NOME não pode ser em branco.
			Return
			}
			Else if ( index_ := Array.InDict( ips, _nome, "nome" ) > 0 )	{
			MsgBox,,,%	"Este NOME já está cadastrado na base de dados para a câmera :`n" ips[index_].ip
				Return
				}
		; if ( StrLen( _local ) = 0 )	{
			;	MsgBox,,,O campo LOCAL não pode ser em branco.
			;	Return
			;	}
		; if ( StrLen( _mac ) = 0 )		{
			; MsgBox,,,O campo MAC não pode ser em branco.
			; Return
			; }
		if ( StrLen( _model ) = 0 )	{
			MsgBox,,,O campo MARCA não pode ser em branco.
			Return
			}
		if ( StrLen( _setor ) = 0 )	{
			MsgBox,,,O campo OPERADOR não pode ser em branco.`nDeve ser um valor entre 1 e 6.
			Return
			}
		if ( StrLen( _sinistro ) = 0 )	{
			MsgBox,,,O campo SINISTRO deve ser selecionado.
			Return
			}
			modificado := datetime( 1 )
	i =
		(
		INSERT INTO [MotionDetection].[dbo].[cameras]
			(	[ip]
    			,[nome]
    			,[mac]
    			,[setor]
    			,[modelo]
    			,[operador]
    			,[alteracoes]
    			,[local]
    			,[em_sinistro]
				,[modificado]	)
		VALUES
			(	'%_ip%'
			,	'%_nome%'
			,	'%_mac%'
			,	'%_setor%'
			,	'%_model%'
			,	'%user%'
			,	'Inserção de Nova Câmera'
			,	'%_local%'
			,	'%_sinistro%'
			,	CAST('%modificado%' as datetime)	)
		)
		sql( i, 3 )
		Gosub, _done
;Return

_n_cancel:
	ip:=nome:=local:=modificado:=mac:=model:=patrimonio:=setor:=operador:=_filter:=""
	sinistro	:=	0
	GuiControl, CamerasEdit:-Hidden, lv
	GuiControl, CamerasEdit:-Hidden, _new_cam
	GuiControl, CamerasEdit:-Hidden, _ok
	GuiControl, CamerasEdit:+Hidden, _n_ok
	GuiControl, CamerasEdit:+Hidden, _n_cancel
	GuiControl, CamerasEdit:-Hidden, _filter
	Gosub, Clear
Return

CamerasEditGuiClose:
ExitApp

up:
	comando.verificar( "sistema" )
return

CamerasEditGuiContextMenu()	{
	if (	A_eventInfo		=	0
		||	A_GuiControl	!=	"lv" )
			return
	global	line := LV_GetNext()
	Menu, exclude, Add, Excluir,	exclude
	Menu, exclude, Show, %A_GuiX%, %A_GuiY%
}

exclude:
Gui, CamerasEdit:Default
	LV_GetText(	ip,			line, 1 )
	LV_GetText(	nome,		line, 2 )
	LV_GetText(	md,			line, 3 )
	LV_GetText(	mac,		line, 4 )
	LV_GetText(	last_md,	line, 5 )
	LV_GetText(	setor,		line, 6 )
	LV_GetText(	patrimonio,	line, 7 )
	LV_GetText(	modelo,		line, 8 )
	LV_GetText(	comentario,	line, 9 )
	LV_GetText(	operador,	line, 11 )
	LV_GetText(	alteracoes,	line, 12 )
	LV_GetText(	local,		line, 13 )
	LV_GetText(	id,			line, 14 )
	LV_Delete( line )
	reinsert =
		(
		INSERT INTO	[MotionDetection].[dbo].[cameras]
			(	[ip]
			,	[nome]
			,	[md]
			,	[mac]
			,	[last_md]
			,	[setor]
			,	[patrimonio]
			,	[modelo]
			,	[comentario]
			,	[operador]
			,	[alteracoes]
			,	[local]	)
			VALUES
			(	''%ip%''
			,	''%nome%''
			,	''%md%''
			,	''%mac%''
			,	''%last_md%''
			,	''%setor%''
			,	''%patrimonio%''
			,	''%modelo%''
			,	''%comentario%''
			,	''%user%''
			,	''Reinserido na base de dados''
			,	''%local%'' )
		)
	d =
		(
		DELETE FROM [MotionDetection].[dbo].[Cameras]
			WHERE
				[id] = '%id%'
		)
	sql( d, 3 )
	modificado := datetime( 1 )
	i =
		(
		INSERT INTO [ASM].[dbo].[_log_sistema]
			(	[gerado]
			,	[software]
			,	[ip]
			,	[cmp1]
			,	[cmp2]
			,	[cmp3]	)
		VALUES
			(	CAST('%modificado%' as datetime)
			,	'Editor de Câmeras'
			,	'%A_IPAddress1%'
			,	'%reinsert%'
			,	'BACKUP de Câmera'
			,	'%user%')
		)
	e := sql( i, 3 )
	Gosub, _done
return

Login:
	s=select usuario from [asm].dbo._colaboradores where access_level > 0
	s	:=	sql( s, 3 )
	Loop, % s.Count()
		admins	.=	s[ A_Index+1, 1 ] ","
		admins := SubStr(admins, 1, -1 )
	gui.Cores( "login", "9BACC0", "374658" )
		Gui, login:Font,	Bold	S10 cWhite
	Gui, login:Add, Text,	x10	y10		w80		h25		0x1200		center			, Usuário
	Gui, login:Add, Text,	x10	y40		w80		h25		0x1200		center			, Senha
		Gui, login:Font
		Gui, login:Font, Bold S10
	Gui, login:Add, Edit,	x90	y10		w140	h25		v@usuario
	Gui, login:Add, Edit,	x90	y40		w140	h25		v@senha		Password
	; Gui, login:Add, Button,	x10	y55		w221	h25					g_Autenticar	, Ok
		Gui, login:Font
	Gui, login: +AlwaysOnTop	-MinimizeBox
	Gui, login:Show,																, Login Cotrijal
	Sleep, 500
	Gui, login:+LastFound
	Guicontrol, login:Focus, @usuario
	Return

	_Autenticar:
		Gui,	Login:Submit,	NoHide
		is_login := Login( @usuario, @senha, 1 )
		if ( logou = "interface" )
			Return
		goto,	%	logou := is_login	=	0
										?	"GuiClose"
										:	"Interface"
	Return

	Login( @usuario, @senha, @admin = "" )	{
		if	@admin
			if InStr(admins, @usuario )
				return DllCall(	"advapi32\LogonUser"
							,	"str",	@usuario
							,	"str",	"Cotrijal"
							,	"str",	@senha
							,	"Ptr",	3
							,	"Ptr",	3
							,	"UintP"
							,	nSize	)	=	1
								?	"1"
								:	"0"
		Else
			Return 0
	}
	~Enter::
		~NumpadEnter::
		Goto _Autenticar
Return