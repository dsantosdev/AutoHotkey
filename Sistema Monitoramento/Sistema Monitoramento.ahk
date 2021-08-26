;@Ahk2Exe-SetMainIcon	C:\Seventh\Backup\ico\2sm.ico
global	iniciou	;	Verificar necessidade
	,	server01
	,	server02
	,	server03
;

;Local
	exe_dir	= \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\
	salvar	= 1
	debug	= 0
	version	= 2.8.0
	bggui	= 9BACC0
;

; #InstallKeybdHook
	#Persistent
	#SingleInstance Force
	#Include ..\class\array.ahk
	#Include ..\class\cor.ahk
	; #Include ..\class\dguard.ahk	;	desnecessário até então
	#Include ..\class\functions.ahk
	#Include ..\class\gui.ahk
	#Include ..\class\safedata.ahk
	#Include ..\class\sql.ahk
	#Include ..\class\windows.ahk
;

;	Definições	-	Função
	chrome_incognito()
	chrome_history()
;

Menu,		Tray,	Icon
	Menu,	Tray,	Color,	%bggui%
	if ( A_UserName != "dsantos" )
		Menu,	Tray,	NoStandard
;	Gui de LOADING
	Gui.Font( "s25", "Bold", "cWhite" )
	Gui,	-Caption	-DPIScale	+AlwaysOnTop
	Gui,	Margin,	0,	0
	Gui,	Add,	Pic,%	"w" A_ScreenWidth "	h40	hwndHPIC"
	Gui,	Add,	Text,	wp			xp	yp	hp	BackgroundTrans	vLoader	Center,%	"Sistema Monitoramento - " version
	Cor.Gradiente( HPIC, Blue,,1,1 )
	Gui,	Show,	x0	y0	NoActivate
;	Return ;	UTILIZADO PARA DEBUGAR A GUI INICIAL
	; F5::
	; Reload
;	Copia executável de update
	FileCreateDir,	C:\Seventh\backup
	FileCopy,		%exe_dir%update.exe,	C:\Seventh\backup\update.exe,				1
;	Timers
	if (	A_UserName != "Alberto"
	||		SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 184 ) {
		SetTimer,	window_handler,	50		;	Lida com as janelas existentes no dguard
		SetTimer,	auto_restore,	1000	;	Verifica se é 07:00 ou 19:00 para efetuar o restauro dos layouts das colunas
	}
	SetTimer, end_loading, -3000	;	Limpa as GUI's iniciais do Sistema Monitoramento
;	Return

;	TrayMenu
	if (	SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 162	;	exibido apenas os operadores
	||		SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 166
	||		SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 169
	||		SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 176
	||		SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 179
	||		SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 184
	||		A_UserName	= "alberto"
	||		A_UserName	= "llopes"
	||		A_UserName	= "dsantos" ) {
		if ( A_UserName = "dsantos" ) {	;	Menu	BETA - apenas no meu user
			Menu,	Beta,	Add,	Unidades, Unidades
			Menu,	Beta,	Icon,	Unidades, C:\Seventh\Backup\ico\2admin.ico
			Menu,	Beta,	Color,	%	bggui
			Menu,	Tray,	Add,	Em Desenvolvimento,	:Beta
			Menu,	Tray,	add
		}
		;	Menu	ADMIN
			Menu,	Admin,	Add,	Gestão de Câmeras,						_gestor_camera
				Menu, Admin, Icon, Gestão de Câmeras, C:\Seventh\Backup\ico\2LembEdit.ico
			Menu,	Admin,	Add,	Gestão de Unidades,						_gestor_unidades
				Menu, Admin, Icon, Gestão de Unidades, C:\Seventh\Backup\ico\2useradd.ico
			Menu,	Admin,	Add,	Gestão de E-Mails,						_gestor_email
				Menu, Admin, Icon, Gestão de E-Mails, C:\Seventh\Backup\ico\2useradd.ico
			Menu,	Admin,	Color,	%	bggui
			Menu,	Tray,	Add,	Administrar,							:Admin
				Menu	,Tray,	Icon,	Administrar,													C:\Seventh\Backup\ico\2admin.ico
			Menu,	Tray,	add
		;	Menu	PADRÃO
			if (	SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 176	;	Reboot de câmera operador 4
			||		A_UserName	= "dsantos" )	{
				Menu,	Tray,	add,	Reboot LV | Administrativo,		reboot
				Menu,	Tray,	Icon,	Reboot LV | Administrativo,		C:\Seventh\Backup\ico\2update.ico
			}
			Menu,	Tray,	add,		Contatos					,	Contatos
				Menu, Tray, Icon, Contatos, C:\Seventh\Backup\ico\2contatos.ico
			Menu,	Tray,	add,		E-mails						,	Emails
				Menu, Tray, Icon, E-mails, C:\Seventh\Backup\ico\2mail.ico
			Menu,	Tray,	add,		Relatórios					,	Relatórios
				Menu, Tray, Icon, Relatórios, C:\Seventh\Backup\ico\2LembEdit.ico
			Menu,	Tray,	add,		Unidades					,	Unidades
				Menu, Tray, Icon, Unidades, C:\Seventh\Backup\ico\2resp.ico
			Menu,	Tray,	add,		Operador					,	Operador
				Menu, Tray, Icon, Operador, C:\Seventh\Backup\ico\2resp.ico
			Menu,	Tray,	add
	}
	Menu,	Tray,	Tip,	%	"Sistema Monitoramento`nCompilado em: " datetime( , modificado ) "`n`nIP - " A_IPAddress1
	q =
		(
		SELECT
			[funcao]
		FROM [ASM].[dbo].[_gestao_sistema]
		WHERE
			[descricao] = '%A_IPAddress1%'
		)
	funcao_da_maquina := sql( q, 3 e)
	if ( funcao_da_maquina[2, 1] = "operador" )	{	;	Executa agenda e detecção de movimento
		; Windows.Run( "Detecções de Movimento" )		;	mdkah
		Windows.Run( "Detecções" )	
		; Windows.Run( "Notificador" )				;	mdage
		Windows.Run( "Notificador" )
		}
;	Tray END

;	Atalhos
	F1::	;	Relatórios
		if (   SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 162
			|| SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 166
			|| SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 169
			|| SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 176
			|| SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 179
			|| SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 184
			|| A_UserName = "Alberto" )
			Windows.Run( "Relatórios" )	;mdrelatórios
	return

	^F10::	;	Adiciona E-mails e chamados
		Windows.Run( "Gestor de E-Mails" )
	return

	F10::	;	E-Mails, ocomon e registros
		Windows.Run( "E-Mails" )
	return

	^ins::
		pass =
		InputBox,	pass,	Comando Sistema Monitoramento,	,	HIDE	;{
		if ( pass = "" )
			return
		else if ( pass = "close" )
				ExitApp
		else if ( pass = "debug" )			{
			ListVars
			return
			}
		else if ( pass = "noite" )	{
			FileMove,	%exe_dir%registros\Noite\%A_IPAddress1%.reg
					,	%exe_dir%Registros\Noite\older\%A_IPAddress1% - %A_DD%-%A_MM%-%A_YYYY% %A_Hour%_%A_Min%_%A_Sec%.reg
			run,	cmd.exe /c "reg export HKCU\Software\Seventh\DGuardCenter %exe_dir%registros\Noite\%A_IPAddress1%.reg /y", , Hide
			MsgBox, , , Exportado com Sucesso, 1
			Gosub, restauro_normal
			return
			}
		else if ( pass = "dia" )		{
			FileMove,	%exe_dir%registros\Dia\%A_IPAddress1%.reg
					,	%exe_dir%Registros\Dia\older\%A_IPAddress1% - %A_DD%-%A_MM%-%A_YYYY% %A_Hour%_%A_Min%_%A_Sec%.reg
			Run,	cmd.exe /c "reg export HKCU\Software\Seventh\DGuardCenter %exe_dir%registros\Dia\%A_IPAddress1%.reg /y", , Hide
			MsgBox, , , Exportado com Sucesso, 1
			Gosub, restauro_normal
			return
			}
		else if ( pass = "todas" )		{
			FileMove,	%exe_dir%registros\Todas\%A_IPAddress1%.reg
					,	%exe_dir%Registros\Todas\older\%A_IPAddress1% - %A_DD%-%A_MM%-%A_YYYY% %A_Hour%_%A_Min%_%A_Sec%.reg
			run,	cmd.exe /c "reg export HKCU\Software\Seventh\DGuardCenter %exe_dir%registros\Todas\%A_IPAddress1%.reg /y", , Hide
			MsgBox, , , Exportado com Sucesso, 1
			gosub	restauro_normal
			return
			}
		else if ( pass = "reload" )
			Reload
		else
			MsgBox,	,Comando Inexistente,	Este comando não existe = %pass%
	return

	^g::	;	Gerenciador e outra janelas do D-Guard 
		SysGet, MonitorPrimary, MonitorPrimary
		SysGet, MonitorName, MonitorName, %MonitorPrimary%
		SysGet,	Monitor, Monitor, %MonitorPrimary%
		SysGet,	MonitorWorkArea, MonitorWorkArea, %MonitorPrimary%
		If	Not WinActive(ahk_group ahk_class TfmGerenciador)
			&&	exibe_gerenciador := !exibe_gerenciador = 1
			{
			WinActivate, ahk_class TfmGerenciador
			WinShow, ahk_class TfmGerenciador
			}
			Else
				WinMinimize, ahk_class TfmGerenciador
		WinMove,	ahk_class TfmGerenciador,	,	5,		%MonitorTop%,	,% MonitorWorkAreaBottom
		WinMove,	ahk_class TfmAutenticacao,	,	400,	%MonitorTop%
		WinMove,	ahk_class TfmConfigSistema,	,	400,	%MonitorTop%
		WinMove,	ahk_class TfmUsuarios,		,	400,	%MonitorTop%
		WinMove,	ahk_class TfmAvisos,		,	400,	%MonitorTop%
		WinMove,	ahk_class TfmConfigLegenda,	,	400,	%MonitorTop%
	return

	; ^o::	;	Organiza as janelas do D-guard
		; SysGet,	MonitorCount	, MonitorCount
		; SysGet, MonitorPrimary	, MonitorPrimary
		; Positions := []
		; Loop, % MonitorCount {
			; SysGet, Monitor			, Monitor			, %A_Index%
			; Positions.push(MonitorTop)
		; }
		; positions := Array.Sort( Positions, , 1 )
		; 
		; WinGet,	Windows,	List
		; Loop, % windows	{
			; id := windows%A_Index%
			; WinGetTitle, WinTitle, ahk_id %id%
			; If ( InStr( WinTitle, "Monitor " ) > 0 )	{	;	é janela de exibição do dguard
				; WinActivate, ahk_id %id%
				; display := SubStr( StrReplace( WinTitle , "Monitor " ), 1, 1 )
				; if display = 1
					; MsgBox % display "`n" WinTitle "`n" Positions[display].1
				; else if display = 2
					; MsgBox % display "`n" WinTitle "`n" Positions[display].2
				; else if display = 3
					; MsgBox % display "`n" WinTitle "`n" Positions[display].3
				; else if display = 4
					; MsgBox % display "`n" WinTitle "`n" Positions[display].4
			; }
		; }
	; Return

	^u::
		update:
		FileCopy,	%exe_dir%update.exe
				,	C:\Seventh\backup\update.exe,	1
		if	(	ErrorLevel	=	1	)
			MsgBox	Cópia do "Update.exe" falhou!`nINFORME AO FACILITADOR!
			else
				ToolTip Cópia do "Update.exe" finalizado!
		ToolTip,	Iniciando!
		Sleep	1000
		Windows.Run( "update", "C:\Seventh\backup\" )
	ExitApp
;Return

;	Funções de Layouts
	^b::
		restauro_normal:
		if (	SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 184
			||	A_UserName = "alberto"
			||	A_UserName = "llopes" )
			return
		if (	A_Hour > 6
			&&	A_Hour < 19 )
			goto dia
			else
				goto noite

	^Numpad1::
		if (	SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 184
			||	A_UserName = "Alberto" )
			return
		goto,	dia

	^Numpad2::
		if (	SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 184
			||	A_UserName = "Alberto" )
			return
		goto,	noite

	^Numpad3::
		if (	SubStr( A_IpAddress1, InStr( A_IPAddress1, ".",,, 3 )+1 ) = 184
			||	A_UserName = "Alberto" )
			return
		goto,	todas
;Return

;	Operadores
	reboot:
		s=SELECT DATEDIFF(MI,modificado,getdate()), [usuario] FROM [ASM].[dbo].[_gestao_sistema] WHERE [funcao] = 'reboot'
		s:=sql(s,3)
		recente:=s[2,1]
		autenticado_:=s[2,2]
		if(recente<5)	{
			MsgBox,,Câmera Reiniciada Recentemente, Câmera reiniciada a menos de 5 minutos por %autenticado_%.`nAguarde mais um momento o reinício da mesma.
			return
			}
		if(recente<30)	{
			MsgBox,,Câmera Reiniciada Recentemente, %autenticado_%`n`nCâmera reiniciada a menos de 30 minutos por %autenticado_%.
			return
			}
		Autenticar.LoginAD("todos")
		SetTimer,	reboot_ok, 100
	return

	reboot_ok:
		if (	InStr( autenticou, "1" ) = 0
			||	autenticou = "" )
			return
		SetTimer,	reboot_ok, off
		usuario := SubStr(autenticou,InStr(autenticou,"|")+1)
		modificado	:=	datetime()
		s =
			(
			UPDATE [ASM].[dbo].[_gestao_sistema]
			SET
				[descricao] 	= 'executado'
				,[usuario]		= '%usuario%'
				,[modificado]	= '%modificado%'
			WHERE
				[funcao]		= 'reboot'
			)
		sql( s, 3 )
		if ( http( "http://admin:tq8hSKWzy5A@10.2.46.220/cgi-bin/system.cgi?msubmenu=reset&action=reset&status=ok" ) = "Ok" )
			MsgBox,, Reboot com Sucesso, Aguarde alguns minutos para o retorno da câmera.
		autenticou = 0
		recente = 0
	return

	Unidades:
		Windows.Run( "Unidades" )
	return

	Operador:
		Windows.Run( "Operador" )
	return

	Emails:
		Windows.Run( "E-Mails" )
	return
	
	Relatórios:
		Windows.Run( "Relatórios" )
	return
	
	Contatos:
		Windows.Run( "Contatos" )
	return
;return

;	Gerenciamento
	_gestor_camera:
		Windows.Run( "Gestor de Câmeras" )
	return

	_gestor_unidades:
		Windows.Run( "Gestor de Unidades" )
	return

	_gestor_email:
		Windows.Run( "Gestor de E-Mails" )
	return
;return

;	Beta
	Unidades_beta:
		Windows.Run( "unidades_beta" )
	return
;return

window_handler:
	if WinExist( "Selecione o tema de sua preferência" )
		WinClose,	Selecione o tema de sua preferência
	ifWinExist,	DDguard Player.exe	;	Meu sistema?
		{
		WinActivate,	DDguard Player.exe
		ControlGetText,	couldnot,	static1,	DDguard Player.exe
		if ( instr( couldnot,"could" ) > 0 )	{
			ControlClick,	Button2,	DDguard Player.exe,	,	Left
			Send,	{tab}{Enter}
			WinClose,	DDguard Player.exe
			}
		}
	if WinExist( "Mensagem" )
		WinClose,	Mensagem
return

;	Restauro dos layouts
	auto_restore:
		if 		(	SubStr( A_Now, 9 ) > _manha
			&&	SubStr( A_Now, 9 ) < ( _manha + 10 ) )	{	;	entre 070000 e 070010(horário padrão)
			SetTimer,	auto_restore,	OFF
			Gosub,	dia
			goto	update
			}
		Else if (	SubStr( A_Now, 9 ) > _tarde
				&&	SubStr( A_Now, 9 ) < ( _tarde + 10 ) )	{
			SetTimer,	auto_restore,	OFF
			Gosub,	noite
			goto	update
			}
			notificar( )
	return

	todas:
		FileCopy,	%exe_dir%registros\todas\%A_IPAddress1%.reg,	%A_MyDocuments%\%A_IPAddress1%.reg, 1
		Random,		soundvol,	20,	30
			SoundSet,	%soundvol%
		Process,	Close,	WatchdogServices.exe
		Process,	Close,	Watchdog.exe
		Process,	Close,	DGuard.exe
		Process,	Close,	Player.exe
		RegDelete,	HKEY_CURRENT_USER\Software\Seventh\DGuardCenter
		Run,		cmd.exe /c "reg import %A_MyDocuments%\%A_IPAddress1%.reg", , Hide
		Loop,	5	{
			ToolTip	%	"Reiniciando em "	5-A_Index " - TODAS"
			Sleep	1000
			}
		ToolTip
		FileRemoveDir,	C:\Seventh\DGuardCenter\Dados\Servidores,	1
		Windows.Run("Dguard","C:\Seventh\DGuardCenter\")
		FileDelete,	%A_MyDocuments%\*.reg
		Send,		{LCtrl Up}
	return

	dia:
		FileCopy,	%exe_dir%registros\Dia\%A_IPAddress1%.reg,	%A_MyDocuments%\%A_IPAddress1%.reg, 1
		Random,		soundvol,	20,	30
			SoundSet,	%soundvol%
		Process,	Close,	WatchdogServices.exe
		Process,	Close,	Watchdog.exe
		Process,	Close,	DGuard.exe
		Process,	Close,	Player.exe
		RegDelete,	HKEY_CURRENT_USER\Software\Seventh\DGuardCenter
		Run,		cmd.exe /c "reg import %A_MyDocuments%\%A_IPAddress1%.reg", , Hide
		Loop,	5	{
			ToolTip	%	"Reiniciando em "	5-A_Index " - DIA"
			Sleep	1000
			}
		ToolTip
		FileRemoveDir,	C:\Seventh\DGuardCenter\Dados\Servidores,	1
		Windows.Run("Dguard","C:\Seventh\DGuardCenter\")
		FileDelete,	%A_MyDocuments%\*.reg
		Send,		{LCtrl Up}
	return

	noite:
		FileCopy,	%exe_dir%registros\noite\%A_IPAddress1%.reg,	%A_MyDocuments%\%A_IPAddress1%.reg, 1
		Random,		soundvol,	20,	30
			SoundSet,	%soundvol%
		Process,	Close,	WatchdogServices.exe
		Process,	Close,	Watchdog.exe
		Process,	Close,	DGuard.exe
		Process,	Close,	Player.exe
		RegDelete,	HKEY_CURRENT_USER\Software\Seventh\DGuardCenter
		Run,		cmd.exe /c "reg import %A_MyDocuments%\%A_IPAddress1%.reg", , Hide
		Loop,	5	{
			ToolTip	%	"Reiniciando em "	5-A_Index " - NOITE"
			Sleep	1000
			}
		ToolTip
		FileRemoveDir,	C:\Seventh\DGuardCenter\Dados\Servidores,	1
		Windows.Run("Dguard","C:\Seventh\DGuardCenter\")
		FileDelete,%	A_MyDocuments "\*.reg"
		Send, {LCtrl Up}
	return
;return

end_loading:
	Gui,		Destroy
	SetTimer,	end_loading,	off
	s =
		(
		SELECT	[complemento1]
			,	[complemento2]
		FROM [ASM].[dbo].[_gestao_sistema]
		WHERE
			[funcao]	= 'restauro' AND
			[descricao] = 'automatico'
		)
	q := sql( s, 3 )
	if ( StrLen( _manha := q[2, 1] ) = 0 )
		_manha = 070000	
	if ( strlen( _tarde := q[3, 1] ) = 0 )
		_tarde = 190000
return
