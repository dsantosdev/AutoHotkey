;@Ahk2Exe-SetMainIcon C:\AHK\icones\_gray\2update.ico
; var local
	smk = \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\
;

;	INCLUDES
	#Persistent
	#SingleInstance Force
	; #Include ..\class\array.ahk
	#Include ..\class\cor.ahk
	; #Include ..\class\functions.ahk
	#Include ..\class\gui.ahk
	; #Include ..\class\safe_data.ahk
	#Include ..\class\sql.ahk
	; #Include ..\class\windows.ahk
;

; INTERFACE
	Gui	+LastFound +AlwaysOnTop -Caption +ToolWindow 
	Gui,	Color, 000000
	Gui.Font( "s20", "ceef442")
	Gui,	Add,	Text,%	"x2	y20	h30	w" A_ScreenWidth "	Center	vUpdate",	Update em andamento
	Gui.Font( "s10", "cFF0000" )
	Gui,	Show, x0  y0  NoActivate
	Gui.Font( "s10", "c229b1b" )
;

if ( A_UserName = "dsantos" )
	Menu, Tray, Icon
;

;	Trava taskbar
	PostMessage, 0x111, 424, 0,, ahk_class Shell_TrayWnd
;

s =	;	Seleciona os ip's dos operadores
	(
	SELECT
		[descricao]
	FROM [ASM].[dbo].[_gestao_sistema]
	WHERE
		[Funcao] = 'operador'
	)
	ip := sql( s, 3 )
	GuiControl, ,   Update, Finalizando Processos
	Loop,	%	ip.Count()
		estacoes .= ip[A_Index+1, 1] ","
		estacoes := SubStr( estacoes, 1, -2 )
;

s =	;	Seleciona todos os programas cadastrados e fecha
	(
	SELECT
		[complemento1]
	FROM [ASM].[dbo].[_gestao_sistema]
	WHERE
		[Funcao] = 'Sistemas'
	)
	s := sql( s, 3 )
	s := StrSplit( s[2, 1], "," )
	GuiControl, ,   Update, Finalizando Processos
	Loop,%	s.Count()
		Process,	Close,	%	 s[ A_Index ]	".exe"
;

; GuiControl, ,   Update, Verificando executável
	; if ( StrLen( FileExist( smk "DDguard Player.exe") ) = 0 )	;	Finaliza o sistema monitoramento se estiver rodando
		; if ( StrLen( FileExist( "\\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\Sistema Monitoramento.exe") ) = 0 )	;	Finaliza o sistema monitoramento se estiver rodando
		; ExitApp
;

GuiControl, ,   Update, Deletando folder do Sistema Monitoramento
	FileRemoveDir,	C:\Sistema Monitoramento,	1
	FileRemoveDir,	C:\Dguard Advanced,	1
;

GuiControl, ,   Update, Deletando folder de backup
	FileRemoveDir,	C:\Seventh\Backup,	1
;

GuiControl, ,   Update,	Criando folder do Sistema Monitoramento
	FileCreateDir,	C:\Sistema Monitoramento
	FileCreateDir,	C:\Dguard Advanced
;

if (	InStr( estacoes, A_IPAddress1 ) > 0		;	estações operadoras
	||	A_UserName = "Alberto" )	{
	FileCreateDir,	C:\Dguard Advanced\Color	;	Diretório para seleção de cores
	FileCopy, %smk%Gestor de Unidades.exe,						C:\DGuard Advanced\Gestor de Unidades.exe,					1
		; AutRem.exe
		; AutAdd.exe
		; RespAdd.exe
		; RespDel.exe
		; LembEdit.exe

	FileCopy, %smk%Detecção de Movimento.exe,					C:\DGuard Advanced\Detecção de Movimento.exe,			 	1
		; MDKah.exe
		
	FileCopy, %smk%Notificador.exe,								C:\DGuard Advanced\Notificador.exe, 						1
		; MDAge.exe

	FileCopy, %smk%Gestor de Câmeras.exe,						C:\DGuard Advanced\Gestor de Câmeras.exe,					1
		; _Insere_Cameras.exe
		; _Edita_Cameras.exe

	FileCopy, %smk%Gestão de E-Mails.exe,						C:\DGuard Advanced\Gestão de E-Mails.exe,					1
		; Agenda.exe

	FileCopy, %smk%E-Mails - Ocomon - Registros - Frota.exe,	C:\DGuard Advanced\E-Mails - Ocomon - Registros - Frota.exe,1
		; agenda_user.exe

	FileCopy, %smk%Colaboradores.exe,							C:\DGuard Advanced\Colaboradores.exe, 						1
		; MDCol.exe

	FileCopy, %smk%Mapas.exe,									C:\DGuard Advanced\Mapas.exe,								1
		; MDMapas.exe

	FileCopy, %smk%Relatórios.exe,								C:\DGuard Advanced\Relatórios.exe,							1
		; MDRelatorios.exe

	FileCopy, %smk%Responsáveis.exe,							C:\DGuard Advanced\Responsáveis.exe,						1
		; MDResp.exe

	FileCopy, %smk%Relatório Individual.exe,					C:\DGuard Advanced\Relatório Individual.exe,				1
		; relatorio_individual.exe
	}

FileCopy, %smk%map\color\*.png,			C:\Dguard Advanced\Color,	1
GuiControl, ,   Update, Criando folder de Backup
	FileCreateDir,	C:\Seventh\Backup
GuiControl, ,   Update, Criando folder Pasta de Mapas
	FileCreateDir,	C:\Seventh\Backup\Map
GuiControl, ,   Update, Criando folder de Icones
	FileCreateDir,	C:\Seventh\Backup\ico
GuiControl, ,   Update, Atualizando Ícones
	FileCopyDir,	%smk%ico,	C:\Seventh\Backup\ico,	1
GuiControl, ,   Update, Atualizando Mapas
	FileCopy,	%smk%map\*.jpg,	C:\Seventh\Backup\map,	1
GuiControl, ,   Update, Atualizando Executável do Sistema Monitoramento
	FileCopy, %smk%Sistema Monitoramento.exe, C:\DGuard Advanced\Sistema Monitoramento.exe,	1
GuiControl, ,   Update, Atualização do Sistema Monitoramento Finalizado!
	try
		Run, C:\Dguard Advanced\Sistema Monitoramento.exe
Sleep 2000
	Gui,	Destroy
	ExitApp