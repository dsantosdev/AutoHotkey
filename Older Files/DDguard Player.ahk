File_Version=0.2.8.0
Save_to_sql=1

;@Ahk2Exe-SetMainIcon	C:\Seventh\Backup\ico\2sm.ico
;	Configs
	SetTitleMatchMode, 2
	#SingleInstance, Force
	if(need_admin=1)
		if !A_IsAdmin || !(DllCall("GetCommandLine","Str")~=" /restart(?!\S)")
			Try RunWait, % "*RunAs """ (A_IsCompiled?A_ScriptFullPath """ /restart":A_AhkPath """ /restart """ A_ScriptFullPath """")
	FileEncoding,	UTF-8
	ToolTip
	if(A_UserName="dsantos")
		Menu,	Tray,	Icon
	SysGet, Monitores,	MonitorCount
	smk				=	\\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\
	software		=	ASM
	salvar			=	0
	debug			=	0
	version			=	0.2.8.0
	need_admin		=	1
	tray_bg_color	=	9BACC0
	reg_backup_srv	=	
	Global	iniciou
		,	server01
		,	server02
		,	server03
		,	last_id
		,	is_operator
;
	
;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk

	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

;	Traymenu
	Menu,	Tray,	Icon
	Menu,	Tray,	Color,	%tray_bg_color%
	if ( A_UserName != "dsantos" )
		Menu,	Tray,	NoStandard
;

;	Load GUI
	Gui	+LastFound	+AlwaysOnTop	-Caption	+ToolWindow -DPIScale
	Gui,	Font,	s25	cFFFFFF
	Gui,	Color,	000000
	Gui,	Add,	Text,	vLoader	Center	w%A_ScreenWidth%,	Carregando Classes
	Gui,	Show,	x0	y0	NoActivate
	FileGetTime,	modificado,	C:\Dguard Advanced\DDguard Player.exe,	M
	GuiControl,	,	Loader,	%	"Sistema Monitoramento - " version "	-	" datetime(modificado)
	Sleep	1000	;	apenas para dar tempo de ver a gui de abertura
;

;	Prepara os diretórios e copia o executável de update
	FileCreateDir,	C:\Seventh\backup
	FileCopy,%	smk	"update.exe",	C:\Seventh\backup\update.exe,	1
;

;	Timers
		if ( A_UserName != "Alberto" ) {
			SetTimer,	close_messageBox,	50		;	Define o tema do dguard ao iniciar, se houver disparo no iris gera o disparo sonoro e fecha janelas desnecessárias do dguard
			SetTimer,	auto_restore,		1000	;	Verifica se é 07:00 ou 19:00 para efetuar o restauro dos layouts das colunas
			SetTimer,	talkto,				30000	;	Sistema de speech to text via telegram
		}
		SetTimer,	restore_time,			60000
		SetTimer,	new_mail,				60000

	SetTimer, guid, -5000	;	Limpa as GUI's iniciais do Sistema Monitoramento
;

;	TrayMenu
	if ( A_UserName = "dsantos" ) {	;	Menu	BETA
		; Menu,	Tray,	Add,	,					OS APLICATIVOS NESSE MENU NÃO ESTÃO 100% FUNCIONAIS
		Menu,	Beta,	Add,	Unidades,			Unidades	
		Menu,	Beta,	Icon,	Unidades,			C:\Seventh\Backup\ico\2admin.ico
		Menu,	Beta,	Color,	%tray_bg_color%
		Menu,	Tray,	Add,	Em Desenvolvimento,	:Beta
		Menu,	Tray,	Add
	}
	;	Menu	ADMIN
		Menu,	Admin,	Add,	Inserir Câmeras,						_insere_camera
			Menu,	Admin,	Icon,	Inserir Câmeras,					C:\Seventh\Backup\ico\2LembEdit.ico
		Menu,	Admin,	Add,	Editar Câmeras,							_edita_camera
			Menu,	Admin,	Icon,	Editar Câmeras,						C:\Seventh\Backup\ico\2LembEdit.ico
		Menu,	Admin,	Add,	Adicionar Responsáveis,					Add_responsavel
			Menu,	Admin,	Icon,	Adicionar Responsáveis,				C:\Seventh\Backup\ico\2userAdd.ico
		Menu,	Admin,	Add,	Remover Responsáveis,					del_responsavel
			Menu,	Admin,	Icon,	Remover Responsáveis,				C:\Seventh\Backup\ico\2userdel.ico
		Menu,	Admin,	Add,	Adicionar Autorizado,					Add_autorizado
			Menu,	Admin,	Icon,	Adicionar Autorizado,				C:\Seventh\Backup\ico\2autAdd.ico
		Menu,	Admin,	Add,	Remover Autorizado,						rem_autorizado
			Menu,	Admin,	Icon,	Remover Autorizado,					C:\Seventh\Backup\ico\2autdel.ico
		Menu,	Admin,	Add,	Editar Lembretes e Dados da Unidade,	edi_lembrete
			Menu,	Admin,	Icon,	Editar Lembretes e Dados da Unidade,	C:\Seventh\Backup\ico\2LembEdit.ico
		Menu,	Admin,	Color,	%tray_bg_color%
		Menu,	Tray,	Add,	Administrar,							:Admin
			Menu	,Tray,	Icon,	Administrar,													C:\Seventh\Backup\ico\2admin.ico
		Menu,	Tray,	Add
	;	Menu	PADRÃO
		Menu,	Tray,	Add,	Reboot LV | Administrativo,				reboot
			Menu,	Tray,		Icon,	Reboot LV | Administrativo,		C:\Seventh\Backup\ico\2update.ico
		Menu,	Tray,	Add,	Colaboradores da Cotrijal,				Colaboradores
			Menu,Tray,	Icon,		Colaboradores da Cotrijal,		C:\Seventh\Backup\ico\2contatos.ico
		Menu,	Tray,	Add,	E-mails  - Ocomon - Registros,			Emails
			Menu,Tray,	Icon,		E-mails  - Ocomon - Registros,	C:\Seventh\Backup\ico\2mail.ico
		Menu,	Tray,	Add,	Relatórios e Eventos,					Eventos
			Menu,Tray,	Icon,		Relatórios e Eventos,			C:\Seventh\Backup\ico\2LembEdit.ico
		Menu,	Tray,	Add,	Responsáveis e Mapas,					Responsáveis
			Menu,Tray,	Icon,	Responsáveis e Mapas,				C:\Seventh\Backup\ico\2resp.ico
		; Menu,	Tray,	Add
		Menu,	Tray,	Tip,		%	"Sistema Monitoramento`nCompilado em: " datetime(modificado) "`n`nIP - " A_IPAddress1
;

;	Atalhos
	updatado := comando.update( A_IPAddress1 )
	q =
		(
			SELECT
				[funcao]
			FROM
				[ASM].[dbo].[_gestao_sistema]
			WHERE
				[descricao] = '%A_IPAddress1%'
		)
	m := sql( q , 3 )
	if ( m[ 2, 1 ] = "operador" )	{	;	Executa agenda e detecção de movimento
		executar( "MDKah" )
		executar( "MDAge" )
		is_operator	:=	m[ 2, 1 ]
	}
	SetTimer,	up,	1000
	Gui,	Destroy
;	Finaliza o gui de loading


#Q::
	Shutdown, 6
Return

; ^Numpad0::	;	Gui de debug
	; InputBox,	pass_user,	who?,who are da bozz? `;p	,Hide, 200, 130
	; if ( logon_ad( SubStr(pass_user,1,instr(pass_user," ")-1), SubStr(pass_user,instr(pass_user," ")+1)) = 1 )	{
		; Loop,	10
			; if(A_Index=1)
			; Gui,	debug:Add,	Text,			x10	y10			w440	h20	0x1000	vdebug1
		; else
			; Gui,	debug:Add,	Text,	%	"	x10	yp"+30	"	w440	h20	0x1000	vdebug"	A_Index
		; Gui,	debug:Show,,Debug
	; }
; return

~F1::		;	Eventos
	If !WinActive( "Visual Studio Code" )
		executar("MDRelatorios")
return

^F10::		;	Adiciona E-mails e chamados
	executar("Agenda")
return

F10::		;	E-Mails, ocomon e registros
	executar("Agenda_user")
return

~^ins::
	If WinActive( "TeamViewer" )
		Return
	pass =
	InputBox,	pass,	Comando Sistema Monitoramento,	,	HIDE	;{
	if( pass = "" )
		return
	else if( pass = "close" )
			ExitApp
	else if( pass = "path" )
			MsgBox % "C:\Users\dsantos\Desktop\AutoHotkey\Older Files\DDguard Player.ahk"
	else if( pass = "toasty" )		{
			email_notificador( "toasty" )
		Return
		}
	else if( pass = "hahaha" )		{
		disable_hahaha := !disable_hahaha
		Return
		}
	else if( pass = "debug" )		{
		ListVars
		return
		}
	else if( pass = "dia"
		||	 pass = "noite"
		||	 pass = "todas" )		{

		dont_close = 1

		;	arquivo reg de segurança, para uso manual ou em caso de máquina formatada
			runCmd( "reg export HKCU\Software\Seventh\DGuardCenter " smk "registros\" pass "\" A_IPAddress1 "_NEW.reg /y" )
			start_export := A_Now
			while !FileExist( smk "registros\" pass "\" A_IPAddress1 "_NEW.reg" ) {
				Sleep, 1000
				if ( ( A_Now - start_export ) > 4 ) {
					MsgBox % "Falha ao salvar o registro de backup.`nTente executar o Sistema Monitoramento como administrador e salvar o registro novamente."
					Return
				}
			}
		;

		;	substituição do arquivo de segurança
			FileDelete,%	smk "registros\" pass "\" A_IPAddress1 ".reg"
				Sleep 500
			FileMove,%		smk "registros\" pass "\" A_IPAddress1 "_NEW.reg",% smk "registros\" pass "\" A_IPAddress1 ".reg"

			start_check := A_Now
			while !FileExist( smk "registros\" pass "\" A_IPAddress1 ".reg" ) {
				Sleep, 1000
				if ( ( A_Now - start_check ) > 4 ) {
					MsgBox % "Falha ao salvar o registro de backup(2).`nTente executar o Sistema Monitoramento como administrador e salvar o registro novamente."
					Return
				}
			}
		;

		;	Registro de backup para restauro
			runCmd( "REG COPY HKCU\SOFTWARE\Seventh\DguardCenter HKCU\SOFTWARE\Seventh\_" pass " /s /f" )
			if ( A_UserName = "dsantos" )
				runCmd( "REG COPY HKCU\SOFTWARE\Seventh\DguardCenter HKCU\SOFTWARE\Seventh\" A_UserName " /s /f" )
			regWrite( "REG_SZ" , "HKCU\SOFTWARE\Seventh\_" pass, "_BackupAtualizado", datetime() )
			; RegWrite, REG_SZ, HKCU\SOFTWARE\Seventh\_%pass%, _BackupAtualizado,% datetime()
		;

		MsgBox, , , Exportado com Sucesso, 1
		; runCmd( "REG COPY HKCU\SOFTWARE\Seventh\DguardCenter \\srvftp\HKLM\SOFTWARE\BACKUP_DGUARD\" pass "_" A_IPAddress1 " /s /f" )

		restore_period	:= pass
		Goto	restore_layout

		}

	else if( pass = "reload" )
		Reload
	else if( pass = "debugdia" )	{
		_manha	:=	A_Now
		_manha	+=	1, Seconds
		_manha	:=	SubStr( _manha , 9 )
		set_restore	=	1
		Goto	auto_restore
		}
	else if( pass = "debugnoite" )	{
		_tarde	:=	A_Now
		_tarde	+=	1, Seconds
		_tarde	:=	SubStr( _tarde , 9 )
		set_restore = 2
		Goto	auto_restore
		}
	else
		MsgBox,	,Comando Inexistente,	Este comando não existe = %pass%
return

^g::
	yger = 0
	IfWinNotActive,	ahk_group ahk_class TfmGerenciador
	{
		WinShow,	ahk_class TfmGerenciador
		if Monitores = 5
			yger := "-1800"
		WinMove,	ahk_class TfmGerenciador,	,	5,	%yger%
		WinActivate,	ahk_class TfmGerenciador
		WinMove,	ahk_class TfmAutenticacao,	,	400,	%yger%
		WinMove,	ahk_class TfmConfigSistema,	,	400,	%yger%
		WinMove,	ahk_class TfmUsuarios,	,		400,	%yger%
		WinMove,	ahk_class TfmAvisos,	,		400,	%yger%
		WinMove,	ahk_class TfmConfigLegenda,	,	400,	%yger%
		}
	else	{
		WinHide,	ahk_class TfmGerenciador
		WinMove,	ahk_class TfmGerenciador,	,	5,	%yger%
		WinMove,	ahk_class TfmAutenticacao,	,	400,	%yger%
		WinMove,	ahk_class TfmConfigSistema,	,	400,	%yger%
		WinMove,	ahk_class TfmUsuarios,	,		400,	%yger%
		WinMove,	ahk_class TfmAvisos,	,		400,	%yger%
		WinMove,	ahk_class TfmConfigLegenda,	,	400,	%yger%
		}
return

^u::	;	Update:
	update:
	ToolTip,	update em andamento
	comando.update( A_IPAddress1, "1" )
	Settimer,	up,	Off
	Settimer,	close_messageBox,	Off
	FileCopy,	%smk%update.exe,	C:\Seventh\backup\update.exe,	1
	if ( ErrorLevel = 1 )	{
		MsgBox	Cópia do "Update.exe" falhou!
		Return
	}
	else
		ToolTip Cópia do "Update.exe" finalizado!
	ToolTip,	Iniciando!
	Sleep	1000
	if ( StrLen( _up ) = 0 )
		_up = Update por Comando
	; _logs( "ASM", _up )
	_up =
	executar( "update" , "C:\Seventh\backup\" )
ExitApp

;	Funções de Layouts
	^b::
		if ( A_IPAddress1 = "192.9.100.100" ) {
			MsgBox, 4, , Tem certeza que quer exibir o layout %restore_period% na máquina do facilitador?
			IfMsgBox, No
				Return
		}
		restore_period := A_Hour > 6 && A_Hour < 19 ? "dia" : "noite"
		Goto restore_layout

	^Numpad1::
		if ( A_IPAddress1 = "192.9.100.100" ) {
			MsgBox, 4, , Tem certeza que quer exibir o layout %restore_period% na máquina do facilitador?
			IfMsgBox, No
				Return
		}
		restore_period = dia
		Goto restore_layout

	^Numpad2::
		if ( A_IPAddress1 = "192.9.100.100" ) {
			MsgBox, 4, , Tem certeza que quer exibir o layout %restore_period% na máquina do facilitador?
			IfMsgBox, No
				Return
		}

		restore_period = noite
		Goto restore_layout

	^Numpad3::
		if ( A_IPAddress1 = "192.9.100.100" ) {
			MsgBox, 4, , Tem certeza que quer exibir o layout %restore_period% na máquina do facilitador?
			IfMsgBox, No
				Return
		}

		restore_period = todas
		Goto restore_layout

	^Numpad4::
		Return
		temp_exist := RegRead( "HKCU\SOFTWARE\Seventh\_temp", "_BackupAtualizado" )
		; RegRead, temp_exist, HKCU\SOFTWARE\Seventh\_temp, _BackupAtualizado
		if !temp_exist {
			MsgBox, , , Registro temporário inexistente!
			Return
		}
		Goto temp_restore
	^Numpad5::
		Return
		RegDelete( "HKCU\SOFTWARE\Seventh\_temp" )
		; RegDelete, HKCU\SOFTWARE\Seventh\_temp
		runCmd( "REG COPY HKCU\SOFTWARE\Seventh\DguardCenter HKCU\SOFTWARE\Seventh\_temp /s /f" )
		runCmd( "REG IMPORT " smk "\registros\temp.reg" )
		while imported = ""
			imported := regRead( "HKEY_CURRENT_USER\SOFTWARE\Seventh\DguardCenter\WorkspaceManager\Workspace0\WorkspaceForm1", "StayOnTop" )
			; RegRead, imported,HKEY_CURRENT_USER\SOFTWARE\Seventh\DguardCenter\WorkspaceManager\Workspace0\WorkspaceForm1, StayOnTop
		Sleep, 1000

		Process,	Close,	WatchdogServices.exe
			Process,Close,	Watchdog.exe
			Process,Close,	DGuard.exe
			Process,Close,	Player.exe
		executar( "Dguard","C:\Seventh\DGuardCenter\" )
	Return
;

;	Operadores
	reboot:
		s =
			(
				SELECT
					DATEDIFF( MI , modificado , getdate() ),
					[usuario]
				FROM
					[ASM].[dbo].[_gestao_sistema]
				WHERE
					[funcao] = 'reboot'
			)
		s := sql( s , 3 )
		recente := s[ 2,1 ]
		autenticado_ := s[ 2,2 ]
		if( recente < 5 )	{
			MsgBox,,Câmera Reiniciada Recentemente, Câmera reiniciada a menos de 5 minutos por %autenticado_%.`nAguarde mais um momento o reinício da mesma.
			return
		}
		if( recente < 30 )	{
			MsgBox,,Câmera Reiniciada Recentemente, %autenticado_%`n`nCâmera reiniciada a menos de 30 minutos por %autenticado_%.
			return
			}
		Autenticar.LoginAD( "todos" )
		SetTimer,	reboot_ok, 100
	return

	reboot_ok:
		if(InStr(autenticou,"1")=0 or autenticou="")
			return
		SetTimer,	reboot_ok, off
		sql("UPDATE [ASM].[ASM].[dbo].[_gestao_sistema] SET [descricao]	=	'executado', [usuario] = '"	SubStr(autenticou,InStr(autenticou,"|")+1)	"', [modificado]='"	datetime()	"' where [funcao] = 'reboot'")
		if(http("http://admin:tq8hSKWzy5A@10.2.46.220/cgi-bin/system.cgi?msubmenu=reset&action=reset&status=ok")="Ok")
			MsgBox,, Reboot com Sucesso, Aguarde alguns minutos para o retorno da câmera.
		autenticou=0
		recente=0
	return

	_edita_camera:
		executar("_Edita_Cameras")
	return

	_insere_camera:
		executar("_Insere_Cameras")
	return

	Responsáveis:
		executar("MDResp")
	return

	Emails:
		executar("Agenda_user")
	return
	
	Eventos:
		executar("MDRelatorios")
	return
	
	Colaboradores:
		executar("MDCol")
	return
	
;

;	Gerenciamento
	Add_responsavel:
		executar("RespAdd")
	return

	del_responsavel:
		executar("RespDel")
	return

	edi_lembrete:
		executar("LembEdit")
	return

	Add_autorizado:
		executar("AutAdd")
	return

	rem_autorizado:
		executar("AutRem")
	return

	adicionar_email:
		executar("Agenda")
	return
;

Unidades:
	executar("unidades")
return

close_messageBox:
	ListLines, Off
	IfWinExist,	Selecione o tema de sua preferência
	WinClose,	Selecione o tema de sua preferência
	ifWinExist,	DDguard Player.exe
		{
		WinActivate,	DDguard Player.exe
		ControlGetText,	couldnot,	static1,	DDguard Player.exe
		if ( instr(couldnot,"could") > 0 )	{
			ControlClick,	Button2,	DDguard Player.exe,	,	Left
			Send,	{tab}{Enter}
			WinClose,	DDguard Player.exe
			}
		}
	if	dont_close
		Return
	IfWinExist,	Mensagem
		{
		WinActivate,	Mensagem
		WinClose,	Mensagem
		}
	ListLines,	On
return

;	Restauro dos layouts
	auto_restore:
		; ListLines,	Off
		if ( SubStr( A_Now , 9 ) > _manha && SubStr( A_Now , 9 ) < ( _manha+10 ) )
		|| ( SubStr( A_Now , 9 ) > _tarde && SubStr( A_Now , 9 ) < ( _tarde+10 ) ) {

			restore_period := set_restore = 1 ? "dia" : set_restore = 2 ? "noite" : SubStr( A_Now , 9 ) > 070000 && SubStr( A_Now , 9 ) < 190000 ? "dia" : "noite"
			SetTimer,	auto_restore,	OFF
			Gosub		restore_layout
			_up	=		Programado
			Sleep,		10000
			ListLines,	On
			Goto		update
		}
		if !disable_hahaha {
			WinGetActiveTitle, n
			if ( n = o )
				return
			o := n
			if InStr( n , "Web Filter Violation" )
				SoundPlay, \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\hahaha.wav
		}
		OutputDebug % "Auto Restore"
		ListLines,	On
	return

	restore_layout:
		FileRemoveDir,	C:\Seventh\DGuardCenter\Dados\Servidores,	1
		Random,			soundvol,	20,	30
			SoundSet,	%soundvol%
		Process,		Close,	WatchdogServices.exe
			Process,Close,	Watchdog.exe
			Process,Close,	DGuard.exe
			Process,Close,	Player.exe
		exist_test =
		exist_test := RegRead( "HKCU\SOFTWARE\Seventh\_" restore_period , "_BackupAtualizado" )
		; RegRead, exist_test,% "HKCU\SOFTWARE\Seventh\_" restore_period , _BackupAtualizado
		if !exist_test {

			if	FileExist( smk "\registros\" restore_period "\" A_IPAddress1 ".reg" ) {	;	verifica registro físico no W
				MsgBox % "IMPORTANDO ARQUIVO .REG`nLAYOUT DE EXIBIÇÃO DO PERÍODO PRECISA SER SALVO!!!`n`nO Layout atual será salvo provisoriamente como padrão para o período " restore_period "!"
				runCmd(" reg import " smk "\registros\" restore_period "\" A_IPAddress1 ".reg" )
			}
			else if reg_backup_srv	;	caso não, busca remotamente
				runCmd( "REG COPY \\" reg_backup_srv "\HKCU\SOFTWARE\Seventh\DguardCenter HKCU\SOFTWARE\Seventh\_" restore_period " /s /f" )
			runCmd( "REG COPY HKCU\SOFTWARE\Seventh\DguardCenter HKCU\SOFTWARE\Seventh\_" restore_period " /s /f" )	;	ATUALIZA backup pois não existia
			RegWrite, REG_SZ,% "HKCU\SOFTWARE\Seventh\_" restore_period, _BackupAtualizado,% datetime()				;	atualiza marca de atualização
		}
		Else	{

			if ( A_UserName = "dsantos" )
				runCmd( "REG COPY HKCU\SOFTWARE\Seventh\" A_UserName " HKCU\SOFTWARE\Seventh\DguardCenter /s /f" )
			Else
				runCmd( "REG COPY HKCU\SOFTWARE\Seventh\_" restore_period " HKCU\SOFTWARE\Seventh\DguardCenter /s /f" )
		}

		executar( "Dguard","C:\Seventh\DGuardCenter\" )
		Send,			{LCtrl Up}
		restore_period =
	Return

	temp_restore:
		regDelete( "HKCU\SOFTWARE\Seventh\DguardCenter" )
		; RegDelete, HKCU\SOFTWARE\Seventh\DguardCenter
		runCmd( "REG COPY HKCU\SOFTWARE\Seventh\_temp HKCU\SOFTWARE\Seventh\DguardCenter /s /f" )
		Process,		Close,	WatchdogServices.exe
			Process,Close,	Watchdog.exe
			Process,Close,	DGuard.exe
			Process,Close,	Player.exe
		executar( "Dguard","C:\Seventh\DGuardCenter\" )
		regDelete( "HKCU\SOFTWARE\Seventh\_temp" )
	Return
;

new_mail:
	email_notificador()
Return

up:	
	; comando.verificar()
return

guid:
	Gui,		Destroy
	SetTimer,	guid,	off
	restore_time:
		Gestor.chrome_incognito()
		Gestor.chrome_history()
		s =
			(
				SELECT
					[complemento1],
					[complemento2]
				FROM
					[ASM].[dbo].[_gestao_sistema]
				WHERE
					[funcao] = 'restauro' AND
					[descricao] = 'automatico'
			)
		q := sql( s , 3 )
		if ( StrLen( _manha := q[2,1] ) = 0 )
			_manha = 070000	
		else if( strlen( _tarde := q[3,1] ) = 0 )
			_tarde = 190000
return


talkto:
	OutputDebug % "Talk To"
	
	if ( (	SubStr( A_Now, 1, 10 )	> "185900"
		&&	SubStr( A_Now, 1, 10 )	< "190011" )
	|| (	SubStr( A_Now, 1, 10 )	> "065900"
		&&	SubStr( A_Now, 1, 10 )	< "070011" ) )
		Return
	talk_operador := A_IPAddress1	= "192.9.100.102"
									? "1"
									: A_IPAddress1	= "192.9.100.106"
									? "2"
									: A_IPAddress1	= "192.9.100.109"
									? "3"
									: A_IPAddress1	= "192.9.100.114"
									? "4"
									: A_IPAddress1	= "192.9.100.118"
									? "5"
									: A_IPAddress1	= "192.9.100.123"
									? "6"
									: A_IPAddress1	= "192.9.100.100"
									? "0"
									: ""

	if	( talk_operador = "" )
		Return

	s	=
		(
			SELECT
				 [id]
				,[command]
			FROM
				[Telegram].[dbo].[command]
			WHERE
				[return] IS NULL 
			AND
				[command] LIKE '%talk_operador%]`%'
		)
	talk_messages := sql( s, 3 )
	Loop,% talk_messages.Count()-1 {
		id_executado	:=	talk_messages[A_Index+1,1]
		message			:=	StrSplit( talk_messages[A_index+1, 2], "][" )
				
		SoundGet, master_volume
		SoundSet, 100
		Sleep, 1000
		windows.speak( message[2] )
		SoundSet,%	master_volume
		Telegram.SendMessage( "Mensagem executada para o operador " message[1], "reply_to_message_id=" message[3], "chat_id=" message[4] )
		u =
			(
				UPDATE [Telegram].[dbo].[command]
				SET [return] = 'Executado'
				WHERE [id] = '%id_executado%'
			)
		sql( u, 3 )
	}
Return