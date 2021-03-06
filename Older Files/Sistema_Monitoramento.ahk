File_Version=0.2.0
Save_to_sql=0
;@Ahk2Exe-SetMainIcon	C:\Seventh\Backup\ico\2sm.ico
;	Configs
	#SingleInstance, Force
	if(need_admin=1)
		if !A_IsAdmin || !(DllCall("GetCommandLine","Str")~=" /restart(?!\S)")
			Try RunWait, % "*RunAs """ (A_IsCompiled?A_ScriptFullPath """ /restart":A_AhkPath """ /restart """ A_ScriptFullPath """")
	FileEncoding,	UTF-8
	ToolTip
	if(A_UserName="dsantos")
		Menu,	Tray,	Icon
	SysGet, Monitores, MonitorCount
	smk				=	\\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\
	software		=	asm
	salvar			=	0
	notificacao		=	1
	debug			=	0
	version			=	2.7.4
	need_admin		=	1
	tray_bg_color	=	9BACC0
	Global	iniciou
		,	server01
		,	server02
		,	server03
		,	last_id
;

;	Includes
	; #Include ..\class\alarm.ahk
	; #Include ..\class\array.ahk
	; #Include ..\class\base64.ahk
	; #Include ..\class\convert.ahk
	; #Include ..\class\cor.ahk
	; #Include ..\class\dguard.ahk
	#Include ..\class\functions.ahk
	; #Include ..\class\gui.ahk
	; #Include ..\class\listview.ahk
	; #Include ..\class\mail.ahk
	; #Include ..\class\safe_data.ahk
	#Include ..\class\sql.ahk
	; #Include ..\class\string.ahk
	; #Include ..\class\telegram.ahk
	; #Include ..\class\windows.ahk
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
	FileCopy,		%smk%update.exe,	C:\Seventh\backup\update.exe,				1
;

;	Timers
	if ( ip != 100 ) {
		if ( A_UserName != "Alberto" ) {
			SetTimer,	timerms,			50		;	Define o tema do dguard ao iniciar, se houver disparo no iris gera o disparo sonoro e fecha janelas desnecessárias do dguard
			SetTimer,	RestauroAutomático,	1000	;	Verifica se é 07:00 ou 19:00 para efetuar o restauro dos layouts das colunas
		}
		SetTimer,	horas_restauro,			60000	;	Verifica se é necessário o sistema monitoramento efetuar update automático ou não
	}

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
	if ( m[2,1] = "operador" )	{	;	Executa agenda e detecção de movimento
		executar( "MDKah" )
		executar( "MDAge" )
	}
	SetTimer,	up,	1000
	Gui,	Destroy
;	Finaliza o gui de loading


#Q::
	Shutdown, 6
Return

; ^Numpad0::	;	Gui de debug
; 	InputBox,	pass_user,	who?,who are da bozz? `;p	,Hide, 200, 130
; 	if ( logon_ad( SubStr(pass_user,1,instr(pass_user," ")-1), SubStr(pass_user,instr(pass_user," ")+1)) = 1 )	{
; 		Loop,	10
; 			if(A_Index=1)
; 			Gui,	debug:Add,	Text,			x10	y10			w440	h20	0x1000	vdebug1
; 		else
; 			Gui,	debug:Add,	Text,	%	"	x10	yp"+30	"	w440	h20	0x1000	vdebug"	A_Index
; 		Gui,	debug:Show,,Debug
; 	}
; return

F1::		;	Eventos
	executar("MDRelatorios")
return

^F10::		;	Adiciona E-mails e chamados
	executar("Agenda")
return

F10::		;	E-Mails, ocomon e registros
	executar("Agenda_user")
return

^ins::
	pass =
	InputBox,	pass,	Comando Sistema Monitoramento,	,	HIDE	;{
	if(pass="")
		return
	else if(pass="close")
			ExitApp
	else if(pass="debug")			{
		ListVars
		return
		}
	else if ( pass = "noite" )		{
		FileMove,	%smk%registros\Noite\%A_IPAddress1%.reg,	%smk%Registros\Noite\older\%A_IPAddress1% - %A_DD%-%A_MM%-%A_YYYY% %A_Hour%_%A_Min%_%A_Sec%.reg
		run,	cmd.exe /c "reg export HKCU\Software\Seventh\DGuardCenter %smk%registros\Noite\%A_IPAddress1%.reg /y", , Hide
		MsgBox, , , Exportado com Sucesso, 1
		gosub	restauro_normal
		return
		}
	else if ( pass = "dia" )		{
		FileMove,	%smk%registros\Dia\%A_IPAddress1%.reg,	%smk%Registros\Dia\older\%A_IPAddress1% - %A_DD%-%A_MM%-%A_YYYY% %A_Hour%_%A_Min%_%A_Sec%.reg
		Run,	cmd.exe /c "reg export HKCU\Software\Seventh\DGuardCenter %smk%registros\Dia\%A_IPAddress1%.reg /y", , Hide
		MsgBox, , , Exportado com Sucesso, 1
		gosub	restauro_normal
		return
		}
	else if ( pass = "todas" )		{
		FileMove,	%smk%registros\Todas\%A_IPAddress1%.reg,	%smk%Registros\Todas\older\%A_IPAddress1% - %A_DD%-%A_MM%-%A_YYYY% %A_Hour%_%A_Min%_%A_Sec%.reg
		run,	cmd.exe /c "reg export HKCU\Software\Seventh\DGuardCenter %smk%registros\Todas\%A_IPAddress1%.reg /y", , Hide
		MsgBox, , , Exportado com Sucesso, 1
		gosub	restauro_normal
		return
		}
	else if ( pass = "notifica" )
		notificacao := !notificacao
	else if ( pass = "reload" )
		Reload
	else if ( pass = "rms" )		{
		gosub	delay_rms
		return
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
	Settimer,	timerms,	Off
	FileCopy,	%smk%update.exe,	C:\Seventh\backup\update.exe,	1
	if(ErrorLevel=1)	{
		MsgBox	Cópia do "Update.exe" falhou!
		ExitApp
	}
	else
		ToolTip Cópia do "Update.exe" finalizado!
	ToolTip,	Iniciando!
	Sleep	1000
	if ( StrLen( _up ) = 0 )
		_up = Update por Comando
	; _logs( "ASM", _up )
	_up =
	executar("update","C:\Seventh\backup\")
ExitApp

;	Funções de Layouts
	^b::
		restauro_normal:
		if Monitores < 3
			return
		if ( A_Hour > 6 and A_Hour < 19 )
			goto dia
			else
				goto noite

	^Numpad1::
		if Monitores < 3
			return
		goto,	dia

	^Numpad2::
		if Monitores < 3
			return
		goto,	noite

	^Numpad3::
		if Monitores < 3
			return
		goto,	todas
;

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

delay_rms:
	SetTimer,	timerms, Off
	SetTimer,	timerms_on,	-60000
	GuiControl,	debug:,	debug7,	%		"TimerMS: Off - " datetime()
return

timerms_on:
	SetTimer,	timerms, 50		
	GuiControl,	debug:,	debug7,	%		"TimerMS: 50 - " datetime()
return

timerms:
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
	IfWinExist,	Mensagem
		{
		WinActivate,	Mensagem
		WinClose,	Mensagem
		}
return

;	Restauro dos layouts
	RestauroAutomático:
		GuiControl,	debug:,	debug3,	%		"Check do restauro automático: " SubStr(A_Now,9)
		if ( SubStr(A_Now,9) > _manha && SubStr(A_Now,9) < (_manha+10) )	{
			SetTimer,	RestauroAutomático,	OFF
			gosub	dia
			_up	=	Programado
			Sleep, 30000
			goto	update
			}
		if ( SubStr(A_Now,9) > _tarde && SubStr(A_Now,9) < (_tarde+10) )	{
			SetTimer,	RestauroAutomático,	OFF
			gosub	noite
			_up	=	Programado
			Sleep, 30000
			goto	update
			}
		if(notificacao=1)
			email_notificador()
	return

	todas:
		FileCopy,	%smk%registros\todas\%A_IPAddress1%.reg,	%A_MyDocuments%\%A_IPAddress1%.reg, 1
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
		executar("Dguard","C:\Seventh\DGuardCenter\")
		FileDelete,	%A_MyDocuments%\*.reg
		Send,		{LCtrl Up}
	return

	dia:
		FileCopy,	%smk%registros\Dia\%A_IPAddress1%.reg,	%A_MyDocuments%\%A_IPAddress1%.reg, 1
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
		executar("Dguard","C:\Seventh\DGuardCenter\")
		FileDelete,	%A_MyDocuments%\*.reg
		Send,		{LCtrl Up}
	return

	noite:
		FileCopy,	%smk%registros\noite\%A_IPAddress1%.reg,	%A_MyDocuments%\%A_IPAddress1%.reg, 1
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
		executar("Dguard","C:\Seventh\DGuardCenter\")
		FileDelete,%	A_MyDocuments "\*.reg"
		Send, {LCtrl Up}
	return
;

up:	
	; comando.verificar()
return

guid:
	Gui,		Destroy
	SetTimer,	guid,	off
	horas_restauro:
		incognito	:=Gestor.chrome_incognito()
		history		:=Gestor.chrome_history()
		GuiControl,	debug:,	debug8,	%		"Históricos: " history "\t|\tIncognito: " incognito
		s=SELECT [complemento1], [complemento2] FROM [ASM].[ASM].[dbo].[_gestao_sistema] WHERE [funcao] = 'restauro' AND [descricao] = 'automatico'
		q:=sql(s)
		if(StrLen(_manha:=q[2,1])=0)
			_manha=070000	
			else if(strlen(_tarde:=q[3,1])=0)
				_tarde=190000
		GuiControl,	debug:,	debug2,	%		"Manhã: " _manha	" | Tarde: " _tarde " | Atualizado: " datetime()
return
