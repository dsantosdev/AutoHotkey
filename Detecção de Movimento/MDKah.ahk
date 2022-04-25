;@Ahk2Exe-SetMainIcon C:\AHK\icones\_gray\2motion.ico
/*
BD = MotionDetection
*/

;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\date.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safedata.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

Menu,	Tray,	Icon,	C:\Seventh\Backup\ico\2motion.ico
#Persistent
#SingleInstance, Force
	sys_vers	= Detecção de Movimento 1.5.2 - 15/04/2022
	operadores2	= 0

;	verifica se há Sinistro em andamento e ajusta o trayicon
	s	=
		(
			SELECT
				[inicio]
				,[fim]
			FROM
				[MotionDetection].[dbo].[operadores]
			WHERE
				[ip] = '%A_IPAddress1%'
			AND
				[Finalizado] is NULL
			ORDER BY
				[pkid]
			DESC
		)
	s	:=	sql( s, 3 )
	If( s.Count()-1 != 0 )	{
		_agora		:= Date.toSeconds( A_Now )
		iniciou		:= s[2,1]
		finalizar	:= s[2,2]
		; MsgBox % _agora "`n" iniciou "`n" finalizar
		If( _agora > finalizar )	{
			Sinistro_	=	0
			finalizar	:=	iniciou	:=	_agora	:= 
		}
		Else	{
			Sinistro_	=	1
			Menu,	Tray,	Icon,	C:\Seventh\Backup\ico\2motion.ico
			SetTimer,	sinistro_counter,	1000
			Menu,	Tray,	Add,	Finalizar sinistro, Restauro
		}
	}
	Menu,	Tray,	Add,	Trabalho com 2 operadores,	2operadores
;

;	Configuração
	;	Variáveis
	Sinistro_	=	0
		camid	:=	"camerasnomes.cgi"
		mjpeg	:=	"mjpegstream.cgi?camera="
		Gui.ScreenSizes()
		ip_cam	=	999.999.999.999	;	cant be null
		Global	debug
			,	x
			,	camid
			,	nomedacamera
			,	id
		http	:=	"http://admin:admin@localhost/"
	;	Folders
		Folder	=	\\srvftp\monitoramento\FTP\
		ip	:= StrSplit( A_IPAddress1 , "." )
		If ip[4] not in ( "100", "102", "106", "109", "114", "118", "123" )
			ExitApp
		If( A_UserName = "dsantos" || A_IPAddress1 = "192.9.100.100" )	;	Define operador
			oper = 0000
		Else	{
			if(		 A_IPAddress1 = "192.9.100.102" )
				oper = 0001
			Else If( A_IPAddress1 = "192.9.100.106" )
				oper = 0002
			Else If( A_IPAddress1 = "192.9.100.109" )
				oper = 0003
			Else If( A_IPAddress1 = "192.9.100.114" )
				oper = 0004
			Else If( A_IPAddress1 = "192.9.100.118" )
				oper = 0005
			Else If( A_IPAddress1 = "192.9.100.123" )
				oper = 0006
			Menu, Tray, Nostandard
		}

		buscar	=	\\srvftp\monitoramento\FTP\%oper%\*.jpg
		if A_IsCompiled
			SetTimer,	verifica_imagens,	2000
		Else
			SetTimer,	verifica_imagens,	1
	; Settimer,	get,		500
return

verifica_imagens:
	;	Verifica se é horário de detecção e se está compilado
		if paused = 1
			Return
		OutputDebug % "Verifica se é horário de detecção e se está compilado"
		If( Substr( A_Now, 9 ) < "200000"	;	ícones e desabilita modo 2 operadores
		&&	SubStr( A_Now, 9 ) > "060000" )	{
			ico			=	2motionp
			operadores2	=	0
		}
		Else
			ico	=	2motion
	;
	;	2 Operadores Sala 1 - Intervalo
		OutputDebug % "2 Operadores Sala 1 - Intervalo"
		If( A_IPAddress1 = "192.9.100.106" ) {
			If( (	SubStr( A_Now, 9, 4 ) > 2100
			&&		SubStr( A_Now, 9, 4 ) < 2330 )
			||	(	SubStr( A_Now, 9, 4 ) > 0300
			&&		SubStr( A_Now, 9, 4 ) < 0415 ) ) {
				Menu,	Tray,	Icon,	C:\Seventh\Backup\ico\2motion.ico
				Sinistro_	=	1
			}
		}
		Else {
			If( operadores2 = 1 )
				Sinistro_ = 1
			Else
				Sinistro_ = 0
		}
		Menu,	Tray,	Icon,	C:\Seventh\Backup\ico\%ico%.ico
	;
	;	Sinistro ativo
		OutputDebug % "Sinistro ativo"
		If( Sinistro_ != 0 )	{
			If( operadores2 = 1 )
				Menu Tray, Tip,%	sys_vers "`nModo 2 operadores"
			Else
				Menu Tray, Tip,%	sys_vers "`nSinistro Ativo"
		}
		Else
			Menu Tray, Tip,%	sys_vers
	;
	;	Impede de abrir duas detecções simultaneamente
		OutputDebug % "Impede de abrir duas detecções simultaneamente"
		IfWinActive, Detecção de Movimento
			WinWaitClose, Detecção de Movimento
	;
	;	Loop imagens
		OutputDebug % "Imagens"
		Loop,	Files,%	buscar
		{
			If( A_IPAddress1 != "192.9.100.100" )	{	;	Lida com imagens fora do horário de atendimento
				If( A_Hour > 6
				&&	A_Hour < 20 )	{
					FileDelete,%	A_LoopFileFullPath
					Continue
				}
				Else If( A_Hour	= 20
				&&	A_Min	< 30 )	{	;	antes das 20:30 impede imagem de ser exibida
					FileDelete,%	A_LoopFileFullPath
					Continue
				}
			}

			arquivo			:=	StrSplit( A_LoopFileName, "_" )

			data_e_hora		:=	StrRep( arquivo[1],, "-" )
			ip_cam			:=	arquivo[2]
			nome_da_camera	:=	arquivo[3]
			op_sinistro		:=	StrReplace( arquivo[4], ".jpg" )
		
			If( Sinistro_ = 1 )	{	;	Move para o operador correspondente ao sinistro
				Loop,	\\srvftp\monitoramento\FTP\%oper%\*.jpg
					FileMove,%	A_LoopFileFullPath,	\\srvftp\monitoramento\FTP\%op_sinistro%\%A_LoopFileName%
				Continue	;	13/04/2022
			}

			;	Verifica Inibidos
				infos	=
					(
						SELECT TOP(1)
							 b.[restaurado]
							,a.[nome]
							,a.[Setor]
						FROM
							[MotionDetection].[dbo].[inibidos]	as b
						JOIN
							[MotionDetection].[dbo].[cameras]	as a
						ON
							b.[ip] = a.[ip]
						WHERE
							b.[ip] = '%ip_cam%'
						ORDER BY
							b.[id]
						DESC
					)
				infos	:=	sql( infos, 3 )
				If( A_IPAddress1 != "192.9.100.100" )	;	Operadores
					If( infos.Count()-1 = 1				;	Está nos inibidos
					&& StrLen( infos[2,1] ) = 0 ) {		;	e não há horário de ter sido encerrado o tempo de inibir
						Loop, Files,%	buscar
							If	RegExMatch( A_LoopFileFullPath, ip_cam )
								FileDelete,% A_LoopFileFullPath
						return
					}
			;
			displayed	:=	datetime()
			fullfile	:=	A_LoopFileFullPath
			h			:=	A_Hour
			m			:=	A_Min
			s			:=	A_Sec
			Goto	Interface
		}
return

Interface:
	IfWinActive, Detecção de Movimento
		WinWaitClose, Detecção de Movimento
	If A_IsCompiled
		Gui,	-Border	+AlwaysOnTop +ToolWindow
	Else
		Gui,	-Border	+ToolWindow

	Gui, Add,	Pic,%			"x10  	y45 			w" monitor_w "	h" work_h-7	"	vPic						",%	fullfile
		Gui, Font,	S12
	Gui, Add,	Edit,%			"x10 	y" work_h-125 "	w999	h100					vmotivo				Hidden	"
		Gui, Font
	Gui, Add,	Button,%		"x10	y" work_h-25 "	w150	h25		gsem_motivo		vnada	-TabStop			", Sem motivo aparente
	Gui, Add,	Button,%		"xp+151	y" work_h-25 "	w150	h25		gb_movimento	vmov	-TabStop			", Evento devido a...
	Gui, Add,	Button,%		"xp+151	y" work_h-25 "	w150	h25		gb_inibir		vini	-TabStop			", Inibir eventos
	Gui, Add,	Button,%		"xp+151	y" work_h-25 "	w150	h25		gb_sinistro		vSini	-TabStop			", Sinistro em Andamento
	Gui, Add,	Button,%		"xp+151	y" work_h-25 "	w150	h25		gb_Pause		vPause	-TabStop			", Pausar por 30 Segundos
	Gui, Add,	Button,%		"xp+400	y" work_h-125 "	w260	h21						vbText	Center		Hidden	", % "Inibir " nome_da_camera " por:"
	Gui, Add,	DropDownList,%	"xp		yp+20			w260	h30						vinibe	Choose2	r7	Hidden	", 30 Minutos|60 Minutos|120 Minutos|180 Minutos|240 Minutos
	Gui, Add,	Button,			 xp		yp-20			w260	h21						vbMot	Center		Hidden	,  Escolher motivo do movimento no local:
	Gui, Add,	DropDownList,%	"xp		yp+20			w260	h30		gmoti			vmoti	Choose1	r7	Hidden	", |Moradores da unidade|Animais no local|Veículos passando na parte externa|Chuva e/ou relâmpagos|Colaboradores trabalhando no local|Insetos ou poeira em frente a câmera|Fonte de luz incidindo sobre a câmera|Vigilante realizando ronda
	Gui, Add,	Button,%		"xp		y" work_h-25 "	w260	h25		gConfirmar		vconf	-TabStop	Hidden	", Confirmar
		Gui, Font,	S15 Bold
	Gui, Add,	Text,%			"x200	y0																	cGreen	", % StrRep( nome_da_camera,".jpg" ) " | "	datetime( data_e_hora )
	Gui, Add,	Button,%		"x10	y0								gao_vivo		vlive	-TabStop			",	Verificar Ao Vivo
		Gui, Font
		; GuiControl,, Pic,%	"							*w1260			 *h720 " 
		Gui, Color,	000000, FFFFFF
	Gui, Show ,%				"x0		y0				 w" monitor_w-7 " h"	work_h								 , Detecção de Movimento
	Sleep	1000
		WinWaitClose, Detecção de Movimento
return

get:
	if(A_Hour	>	6		and	A_Hour	<	20)
		return
	SetTimer,	get, off
	Loop
	{
		Sleep	500
		WinGet,	saida,	ProcessName, A
		if(instr(saida,"chrome")>0 or instr(saida,"firefox")>0 or instr(saida,"iexplore")>0 )	{
			WinGetTitle,	page,	A
			if(instr(page,"wisenet")>0 or instr(page,"settings")>0 or instr(page,"ipcam")>0 or instr(page,"configuração")>0 or instr(page,"live")>0)	{
				if(instr(page,"wisenet")>0)
					what = samsung
				if(instr(page,"settings")>0)
					what = dahua
				if(instr(page,"ipcam")>0)
					what = foscam
				if(instr(page,"configuração")>0)
					what = sony
				if(instr(page,"live")>0)
					what = dahua
				WinGetPos,	x1, y1, w1, h1, A
				x1		:=	x1+10
				y1		:=	y1+10
				w1		:=	w1-10
				h1		:=	h1-10
				ptok	:=	Gdip_Startup()
				img		:=	Gdip_Bitmapfromscreen(x1 "|" y1 "|" w1 "|" h1)
				Gdip_SaveBitmapToFile(img, "\\srvftp\Monitoramento\FTP\Acessos Indevidos\" A_IPAddress1	" - " what	"-" A_Now ".png")
				FileAppend,	%	A_IPAddress1	" - "	what	" - " datetime() "`n", \\srvftp\Monitoramento\FTP\Log\Acesso Configuração de Câmera.txt
				Gdip_DisposeImage(img)
				Gdip_Shutdown(ptok)
				Sleep,	15000
			}
		}
	}
return

;	Botões
	confirmar:
		Gui, Submit, NoHide
		If( StrLen( motivo ) < 10
		||	StrLen( motivo ) > 150 )	{
			if( is_live = 0 )
				WinSet,	AlwaysOnTop,	Off,	Detecção de Movimento
			else
				WinSet,	AlwaysOnTop,	Off,	Live
			MsgBox O encerramento do evento precisa ter pelo menos 10 carateres e no máximo 150 caracteres.
			If( is_live = 0 )
				WinSet,	AlwaysOnTop,	On,	Detecção de Movimento
			Else
				WinSet,	AlwaysOnTop,	On,	Live
			return
		}
		Else	{
			If( inibidor = 1 )	{
				t_ini	:=	Floor( StrReplace( inibe, " Minutos" ) / 60 )
				i_a		:=	A_Hour + t_ini
				if( t_ini = "0" )	{					;	Se foi 30
					if( ( A_Min + 30 ) >= "60" )	{	;	se passa de 1 hora
						i_a	:=	A_Hour+1
						m	:=	( A_min + 30 ) - 60
					}
					else
						m	:=	A_min+StrReplace( inibe, " Minutos" )
				}
				if( i_a > 24 )	{						;	se passou da meia noite
					i_a			:=	Round( i_a - 24 )
					outroDia	=	1
				}
				if( i_a = 24 )	{						;	Se for meia noite
					i_a			:=	"00"
					outroDia	=	1
				}
				else
					i_a			:=	Round( i_a )
				if( StrLen( m ) = "1" )
					m	:=	"0" m
				FileMove,% fullfile ,% Folder "Inibidos\" ip_cam " - " oper " - " StrReplace( nome_da_camera, ".jpg" ) " - " SubStr( A_Now, 1, 8 ) "_" SubStr( A_Now, 9 )	" - " inibe ".jpg", 1
			}
			if( ocorrencia = 1 ){	
				dia_verificar	:= MOD( A_YDay, 2 ) = 1 ? "Dia 1" : "Dia 2"
				move_path		:=	Folder								;	\\srvftp\monitoramento\FTP\
							.	"Verificados\" dia_verificar "\"
							.	ip_cam "_"								;	10.1.52.118
							.	oper "_"								;	0000
							.	StrRep( nome_da_camera,, ".jpg" ) "_"	;	SD - M. Sede Caixas 1 a 4
							.	SubStr( data_e_hora, 1, 8 ) "_"			;	YYYYMMDD_
							.	SubStr( data_e_hora, 9 )				;	HHmmss
							.	".jpg"									;	extensão
				FileMove, % fullfile , % move_path, 1
			}
			exibido=
			gosub sql
		}
		Gui,	Destroy
		Gui,	live:Destroy
	return

	b_pause:
		Gui,	Destroy
		paused = 1
		SetTimer, Pause_counter, -30000
	return

	b_inibir:
		inibidor	:=	!inibidor
		if	(inibidor	=	1)	{
			GuiControl,	Show,	bText
			GuiControl,	Show,	inibe
			GuiControl,	Show,	conf
			GuiControl,	Show,	canc
			GuiControl,	Show,	motivo
			GuiControl,	Hide,	nada
			GuiControl,	Hide,	Sini
			GuiControl,	Hide,	Pause
			GuiControl,	Hide,	mov
			GuiControl,		,	ini,	Voltar
			GuiControl,	Focus,	motivo
		}	else	{
			GuiControl,	Hide,	bText
			GuiControl,	Hide,	inibe
			GuiControl,	Hide,	conf
			GuiControl,	Hide,	canc
			GuiControl,	Hide,	motivo
			GuiControl,	Show,	Sini
			GuiControl,	Show,	Pause
			GuiControl,	Show,	nada
			GuiControl,	Show,	mov
			GuiControl,		,	ini,	Inibir eventos
		}
	return

	b_movimento:
		ocorrencia	:=	!ocorrencia
		if	(	ocorrencia = 1	)	{
			GuiControl,	Hide,	bText
			GuiControl,	Hide,	inibe
			GuiControl,	Show,	moti
			GuiControl,	Show,	bMot
			GuiControl,	Show,	conf
			GuiControl,	Show,	canc
			GuiControl,	Hide,	motivo
			GuiControl,	Hide,	nada
			GuiControl,	Hide,	Sini
			GuiControl,	Hide,	Pause
			GuiControl,	Hide,	ini
			GuiControl,		,	mov,	Voltar
			GuiControl,	Show,	motivo
			GuiControl,	Focus,	motivo
		}	else	{
			GuiControl,	Hide,	bText
			GuiControl,	Hide,	inibe
			GuiControl,	Hide,	moti
			GuiControl,	Hide,	bMot
			GuiControl,	Hide,	conf
			GuiControl,	Hide,	canc
			GuiControl,	Hide,	motivo
			GuiControl,	Show,	nada
			GuiControl,	Show,	Sini
			GuiControl,	Show,	Pause
			GuiControl,	Show,	ini
			GuiControl,		,	mov,	Evento devido a...
			GuiControl,	Hide,	motivo
		}
	return

	sem_motivo:
		nada	=	1
		Gui,	Destroy
		Gui,	live:Destroy
		dia_verificar	:= MOD( A_YDay, 2 ) = 1 ? "Dia 1" : "Dia 2"
		; MsgBox % Clipboard := Folder						;	\\srvftp\monitoramento\FTP\
				; .	"Verificados\" dia_verificar "\"
				; .	ip_cam "_"								;	10.1.52.118
				; .	oper "_"								;	0000
				; .	StrRep( nome_da_camera,, ".jpg" ) "_"	;	SD - M. Sede Caixas 1 a 4
				; .	SubStr( data_e_hora, 1, 8 ) "_"			;	YYYYMMDD_
				; .	SubStr( data_e_hora, 9 )				;	HHmmss
				; .	".jpg"
		move_path	:=	Folder								;	\\srvftp\monitoramento\FTP\
				.	"Verificados\" dia_verificar "\"
				.	ip_cam "_"								;	10.1.52.118
				.	oper "_"								;	0000
				.	StrRep( nome_da_camera,, ".jpg" ) "_"	;	SD - M. Sede Caixas 1 a 4
				.	SubStr( data_e_hora, 1, 8 ) "_"			;	YYYYMMDD_
				.	SubStr( data_e_hora, 9 )				;	HHmmss
				.	".jpg"									;	extensão
		FileMove,% fullfile ,% move_path, 1
		Gosub SQL
	return

	b_sinistro:
		WinSet,	AlwaysOnTop,	Off,	Detecção de Movimento
		MsgBox,	52,	Sinistro Em Andamento, Somente utilizar essa opção em caso de SINISTRO`, as imagens geradas durante 15 minutos serão direcionadas ao(s) operador(es) ao(s) lado(s).
		IfMsgBox,	Yes
		{
			Sinistro_ = 1
			u	=	;	user logado
			(
				SELECT	TOP(1)	[LOG~USUARIO],[LOG~ORDEM]
				FROM	[BdIrisLog].[dbo].[SYS~Log]
				WHERE	[LOG~DADOS]		=	'Login no Painel de Monitoramento.'
				AND		[LOG~ESTACAO]	=	'%A_ComputerName%'
				ORDER	BY	2	DESC
			)
			u	:=	sql(u)
			user_iris	:=	u[2,1]
				If(	StrLen(	u[ 2, 1 ]	) < 3 )
					user_iris	:=	A_IPAddress1
			;	Data e horário de inicio e para Encerrar
			iniciou		:=	Date.toSeconds()
			finalizar	:=	Date.toSeconds( A_Now + 1500 )	;	15 minutos - Padrão
			;
			operador_	=
				(
					INSERT INTO
						[MotionDetection].[dbo].[operadores]
							( [ip]				, [patrimonio]		, [operador]	, [inicio]		, [fim] )
						VALUES
							( '%A_IPAddress1%'	, '%A_ComputerName%', '%user_iris%'	, '%iniciou%'	, '%finalizar%' )
				)
			operador_	:=	sql( operador_, 3 )
			Gui,	Destroy
			Gui,	live:Destroy
			Loop,	\\srvftp\monitoramento\FTP\%oper%\*.jpg
			{
				arquivo			:=	StrSplit(A_LoopFileName, "_" )
				data_e_hora		:=	StrRep( arquivo[1],, "-" )
				ip_cam			:=	arquivo[2]
				nome_da_camera	:=	arquivo[3]
				op_sinistro		:=	StrRep( arquivo[4],, ".jpg" )
				FileMove,%	A_LoopFileFullPath,	\\srvftp\monitoramento\FTP\%op_sinistro%\%A_LoopFileName%
			}
			Menu,	Tray,	Icon,	C:\Seventh\Backup\ico\2motion.ico
			SetTimer,	sinistro_counter,	1000
			Menu, Tray, Add, Finalizar sinistro, Restauro
		}
		else
			WinSet,	AlwaysOnTop,	On,	Detecção de Movimento
	return

	2operadores:
		operadores2	:=	!operadores2
		If( operadores2 = 1 )	{
			; If( A_UserName != "dsantos" )	{	;	Migrar função autenticar
			; autenticou	:=	Autenticar.LoginAD( "usuarios" )
			autenticou = 11
			Loop
				If( StrLen( autenticou ) > 0 )	{
					if( SubStr( autenticou, 1, 1 ) = 1 )
						Goto autenticou
					if( SubStr( autenticou, 1, 1 ) = 0 )	{
						WinSet,	AlwaysOnTop,	Off,	Login Cotrijal
						MsgBox,,Autenticação Falhou,	Verifique seu usuário e senha.
						ExitApp
					}
				}
				else
					autenticou = 1|dsantos
			autenticou:
			; logs.habilitou( SubStr( autenticou, 3 ), "Modo 2 operadores" )
			Menu, Tray, Tip,%	sys_vers "`nModo 2 operadores"
			Menu, Tray, Delete, Trabalho com 2 operadores
			Menu, Tray, Add, Desabilitar Modo 2 operadores, 2operadores
		}
		else	{
			Menu, Tray, Tip,%	sys_vers
			Menu, Tray, Add,	Trabalho com 2 operadores, 2operadores
			Menu, Tray, Delete, Desabilitar Modo 2 operadores
		}
	return

	Restauro:	;	restaura o Sinistro
		Sinistro_	=	0
		Menu,		Tray,	Icon,	C:\Seventh\Backup\ico\2motion.ico
		SetTimer,	sinistro_counter,	Off
		Menu, 		Tray, Tip, %	sys_vers
		FormatTime,	agora,	A_Now,	yyy/MM/dd HH:m:ss
		up_sini	=
			(
				UPDATE
					[MotionDetection].[dbo].[operadores]
				SET
					[Finalizado] = CAST('%agora%' as datetime)
				WHERE
					[ip] = '%A_IPAddress1%'
				AND
					[Finalizado] is NULL
			)
		up_sini	:=	sql( up_sini, 3 )
	return

	Pause_Counter:
		paused = 0
	return

	sinistro_counter:	;	traytip apenas
		agora_	:=	Date.toSeconds( A_Now )
		If( agora_ > finalizar && agora_ < finalizar + 5 )
			goto	Restauro
		minutos		:=	Floor( ( finalizar - agora_ ) /60 )
		segundos	:=	( finalizar - agora_ ) - ( minutos * 60 )
		if( StrLen( segundos ) < 2 )
			segundos	:=	"0"	segundos
		resta	:=	"Tempo até expirar o sinistr: "	minutos ":"	segundos
		Menu,	Tray,	Tip,	%resta%
	return

	ao_vivo:
		;	Prepara variáveis
			WinSet,	AlwaysOnTop,	Off,	Detecção de Movimento
			is_live		=	1
			nomedacamera:=	StrReplace( StrRep( nome_da_camera, ".jpg" ), "-", "|", , 1 )

			Loop, 5 {
				IDS	:=	HttpGet( StrReplace( http, "localhost", "vdm0" A_Index ":85" ) camid, nomedacamera )
				If( IDS = "Erro" )
					Continue
				Else	{
					if( A_Index = 5 ) {
						FileAppend,%	oper " - " nomedacamera " - " A_IPAddress1 " `t "	http camid " | " datetime() "`n", \\srvftp\Monitoramento\FTP\Log\Falha nos ID.txt
						MsgBox,,Câmera Indisponível para visualização, Câmera indisponível no momento para visualização.`nEm caso de emergência visualizar no Ctrl+3 - Layout TODAS
						WinSet,	AlwaysOnTop,	On,	Detecção de Movimento
						Goto	liveClose
					}
					vdm	:=	"vdm0" A_Index ":85"
					break
				}
			}
		;
		ID	:=	SubStr( IDS, 1, Instr( IDS, "=" ) - 1 )
		vivo:=	SubStr( IDS, Instr( IDS, "=" ) + 1 )
		vlcx.playlist.stop()
		url	:=	StrReplace( http, "localhost", vdm ) mjpeg id

		options=""

		If A_IsCompiled
			Gui,	live: -Border +AlwaysOnTop	+ToolWindow
		Gui,	live:Font, S15 Bold
		Gui,	live:Add, Button,	 x10		y0									gliveClose			,	Fechar visualização ao Vivo
		Gui,	live:Add, Text,%	"x320	y0								vaovivo				cGreen"	,%  vivo
		Gui,	live:Add, ActiveX,%	"x10	y45	w" monitor_w " h" work_h "	vVlcx"						,	VideoLAN.VLCPlugin
		Gui,	live:Color, 000000,	FFFFFF
		Gui,	live:Show,%			"x0		y0	w" monitor_w " h" work_h								, Live
		Gui,	live:Font
		vlcx.playlist.add( url, "", options )
		; vlcx.playlist.next()
		vlcx.playlist.play()
	return

	liveClose:
		vlcx.playlist.stop()
		If A_IsCompiled
			WinSet,	AlwaysOnTop,	On,	Detecção de Movimento
		is_live	=	0
		Gui,	live:Destroy
	return

	moti:
		Gui,	Submit,	NoHide
		GuiControl,	,	motivo,	%moti%
	return

	sql:
		encerra	:=	datetime()
		u	=	;	Usuário Logado
			(
				SELECT TOP(1)
					[LOG~USUARIO],
					[LOG~ORDEM]
				FROM
					[BdIrisLog].[dbo].[SYS~Log]
				WHERE
					[LOG~DADOS] = 'Login no Painel de Monitoramento.'
				AND
					[LOG~ESTACAO] = '%A_ComputerName%'
				ORDER BY
					2 DESC
			)
			u	:=	sql( u )
			usuarioatual	:=	u[2,1]
		;
		if( inibidor = 1 )	{
			campo1		:=	StrRep( nome_da_camera,, ".jpg" )
			campo2		:=	datetime( 1, data_e_hora )
			campo3		:=	datetime( 1, displayed )
			campo4		:=	datetime( 1, A_Now )
			campo6		:=	StrRep( inibe,, " Minutos" )
			campo9		:=	ip_cam
			if( outroDia = 1 )
				campo10	:=	A_YDay+1
			else
				campo10	:=	A_YDay
			campo11		:=	( i_a * 60 * 60 ) + ( m * 60 ) + s
			campo12		:=	oper
			inibidor	=	0
			finaliza1	=
				(
					INSERT INTO [MotionDetection].[dbo].[Encerrados]
						( [Camera]	, [Gerado]	, [Exibido] , [Finalizado]	, [Usuario]			, [Ocorrido]					, [Descricao]	, [IP]		, [Operador]	)
					VALUES
						( '%campo1%', '%campo2%', '%campo3%', '%campo4%'	, '%usuarioatual%'	, 'Inibido -  %campo6% minutos'	, '%motivo%'	, '%campo9%', '%campo12%'	);

					INSERT INTO [MotionDetection].[dbo].[inibidos]
						( [operador]		, [ip]			, [camera]		, [inibido]		, [duracao]	, [encerraDia]	, [encerraHorario]	)
					VALUES
						( '%usuarioatual%'	, '%campo9%'	, '%campo1%'	, '%campo3%'	, '%campo6%', '%campo10%'	, '%campo11%'		);
				)
				Log := sql( finaliza1, 3 )
				outroDia =
		}
		if( ocorrencia = 1 )	{
			campo1		:=	StrRep( nome_da_camera,, ".jpg" )
			campo2		:=	datetime( 1, data_e_hora )
			campo3		:=	datetime( 1, displayed )
			campo4		:=	datetime( 1, A_Now )
			campo5		:=	usuarioatual
			campo7		:=	"Ocorrência"
			campo8		:=	motivo
			campo9		:=	ip_cam
			campo10		:=	oper
			ocorrencia	=	0
			finaliza	=
				(
					INSERT INTO [MotionDetection].[dbo].[Encerrados]
						( [Camera]	, [Gerado]	, [Exibido]	, [Finalizado]	, [Usuario]	, [Ocorrido], [Descricao]	, [IP]		, [Operador]	)
					VALUES
						( '%campo1%', '%campo2%', '%campo3%', '%campo4%'	, '%campo5%', '%campo7%', '%campo8%'	, '%campo9%', '%campo10%'	)
				)
				Log := sql( finaliza, 3 )
		}
		if( nada = 1 )	{
			campo1	:=	StrRep( nome_da_camera,, ".jpg" )
			campo2	:=	datetime( 1, data_e_hora )
			campo3	:=	datetime( 1, displayed )
			campo4	:=	datetime( 1, A_Now )
			campo5	:=	usuarioatual
			campo7	:=	"Sem Motivo Aparente"
			campo8	:=	""
			campo9	:=	ip_cam
			campo10	:=	oper
			nada	=	0
			finaliza=
				(
					INSERT INTO [MotionDetection].[dbo].[Encerrados]
						( [Camera]	, [Gerado]	, [Exibido]	, [Finalizado]	, [Usuario]	, [Ocorrido]	, [Descricao]	, [IP]		, [Operador]	)
					VALUES
						( '%campo1%', '%campo2%', '%campo3%', '%campo4%'	, '%campo5%', '%campo7%'	, '%campo8%'	, '%campo9%', '%campo10%'	)
				)
				Log	:=	sql( finaliza, 3 )
		}
	return

	HttpGet( URL, nomedacamera )	{
		responseText=
		static	req	:=	ComObjCreate( "Msxml2.XMLHTTP" )
		req.open( "GET", URL, false )
		req.SetRequestHeader( "Authorization", "Basic YWRtaW46QGRtMW4=" )
		req.SetRequestHeader( "If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT" )
		req.send()
		o	:=	StrSplit( req.responseText, "&" )
		Loop,%	o.Count()	{
			oa	:=	StrReplace( o[A_Index], "`n" )
			if( Instr( oa, "IPC" ) > 0 )
				oa	:=	StrReplace( oa, "IPC", SubStr( oa, InStr( oa, "=" ) + 1, InStr( oa, ".IPC" ) - 5 ) )
			if( Instr( oa, "camera 01" ) > 0 )
				oa	:=	StrReplace( oa, "camera 01", SubStr( oa, InStr( oa, "=" ) + 1, InStr( oa, ".camera 01" ) - 11 ) )
			oa2	:=	oa
			oa	:=	StrReplace( StrReplace( oa, "`r" ), ". ", "_ " )
			oa	:=	StrSplit( oa, "." )
			oa	:=	StrReplace( oa[1], "_", "." )
			id	:=	SubStr( oa, 1, InStr(oa ,"=" ) - 1 )
			oa	:=	SubStr( oa, InStr( oa, "=" ) + 1 )
			If( oa = nomedacamera )	;	se for igual, retorna o id para exibição do vídeo
				break
			Else
				id	=
		}
		If( StrLen( id ) = 0 )
			return "Erro"
		Else 
			return	id	"="	oa
	}

	^END::
		GuiClose:
		ExitApp

	^F1::
		ListVars
		Return