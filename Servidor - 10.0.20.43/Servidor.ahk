File_version=0.0.0.36
save_to_sql=1
;@Ahk2Exe-SetMainIcon C:\AHK\icones\fun\bat.ico

;	Informações
	; Base de dados usadas:
		; asm._gestão_servidor		=	Contém as informações de path dos executáveis e executáveis que devem ser executados
		; asm.softwares				=	Contém os binários do executáveis para conversão
;

;	Config
	#Persistent
	#SingleInstance	Force
	Menu,	Tray,	Tip,	Gestor de Serviços`nSistema Monitoramento
;

;	Variáveis
	tooltips	= 0
;

;	Arrays e Maps
	sistemas := {}
;

;	Configuração
	CoordMode,	ToolTip, Screen
;

;	Includes
	#Include	C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	#Include	C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	#Include	C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	#Include	C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	#Include	C:\Users\dsantos\Desktop\AutoHotkey\class\sync_data.ahk
	#Include	C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

;	Timers
	Gosub, load_vars
	SetTimer,	verifica_horario_execução,	5000	;	a cada 5 segundos verifica os horários
;

;	Shortcuts
	F1::	;	Exibe tooltip
		tooltips	:=	!tooltips
	return

	F4::	;	Debug only
		debuguion=1
		; SetTimer, verifica_horario_execução, Off
		Gui, Font, S10 Bold
		Gui, Add, Button, gcopia_log, Copiar log para o clipboard
		Gui, Add, Edit,% "w500 h" A_ScreenHeight-45 "	vdebugui"
		Gui, Show, ,Debugger
		Return

		GuiClose:
			debuguion=0
			Gui, Destroy
		Return

		copia_log:
			Gui, Submit, NoHide
			clipboard:=debugui
			tooltip, Log copiado com sucesso
			Sleep, 2000
			tooltip
			Gosub, GuiClose
		Return

		Loop,% sistemas.Count()	{
			debug_index		:=	A_Index
			OutputDebug % sistemas[ A_index ].horas.Count()

			debug_horas_executar=

			Loop,%	sistemas[ A_index ].horas.Count()
				debug_horas_executar .=	sistemas[debug_index].horas[A_Index] "`n`t"

			debug_horas_executar	:=	SubStr( debug_horas_executar, 1, -1 )
			_outputdebug	.= "Sistema:`n`t"	sistemas[ A_index ].software "`nHorários:`n`n`t" debug_horas_executar
		}

		MsgBox % clipboard := _outputdebug
		SetTimer, verifica_horario_execução, 5000

	Return

	^Home::	;	Roda sistema forçado
		SetTimer, verifica_horario_execução, Off
		Gui, Add, Text,							,	Selecione o Sistema que deseja executar agora:
		Loop,% sistemas.Count()
			Gui, Add, Button,	gexecute_system	,%	sistemas[A_Index].software
		Gui, Add, Button,	gexecute_system	, Recarregar Sistema
		Gui, Show
	Return

	End::	;	Encerra o aplicativo
		ExitApp
	;
;

;	Code
	load_vars:
		select =
			(
				SELECT
					 [sistema]
					,[minutes]
					,[horas_executar]
				FROM
					[ASM].[dbo].[_gestao_servidor]
			)
			s := sql( select , 3 )

		Loop,%	s.Count()-1 {	;	 se intervalo for zero, sabe que é o path

			main_index	:=	A_Index

			if ( s[main_index+1 , 2] = "" )	{
				path	:=	SubStr( s[main_index+1 , 1],	InStr( s[main_index+1 , 1], "|" )+1 )
				Continue
			}
			Else	{	;	Prepara horários de execução

				horas	:=	[]
				if ( InStr( s[ A_Index+1 , 3 ], ";" ) > 0 ) {	;	Se há mais de um horário de execução
					horarios	:=	StrSplit( s[main_index+1 , 3], ";" )
					Loop,%	horarios.Count() {
						hora	:=	horarios[A_Index] . "0000"
						hora	+=	s[main_index+1 , 2] . "00"
						; MsgBox % s[main_index+1 , 1] "`n" hora "`n" s[main_index+1 , 3]
						horas.Push( hora )
					}
				}
				Else	{

					hora	:=	s[main_index+1 , 3] . "0000"
					hora	+=	s[main_index+1 , 2] . "00"
					; MsgBox %  s[main_index+1 , 1] "`n" hora "`n" s[main_index+1 , 3]
					horas.Push( hora )
				}
				sistemas.push({	software	:	s[main_index+1 , 1]
							,	horas		:	horas })
			}
		}

		OutputDebug % "Sistemas pré carregados`n`t" sistemas.Count() "`nPath`n`t" path
	Return

	execute_system:
		Gui,	Submit
		if ( A_GuiControl = "Recarregar Sistema")
			Reload
		software	:=	A_GuiControl ".exe" ; necessário para conversão de bin para exe
		
		Gosub	Run
		SetTimer, verifica_horario_execução, 5000
	Return

	verifica_horario_execução:
		;	Tooltip ativado ou não
			if (tooltips != 1
			||	ErrorLevel <> 0)
				ToolTip
			Else
				ToolTip,%	StrLen( atualizado )	= 0
													? "Não efetuou atualização ainda, aguarde a próxima troca de hora ou pressione CTRL+F2"
													: "Última execução às " atualizado "`nmm : ss = " A_Min " : " A_Sec,	50,	50
		;

		;	prepara variável de tempo
			time_now	:=	SubStr( A_Now, 9 )	;	hhmmss
		;

		;	Execução

			Loop,%	sistemas.Count() {

				
				SetTimer, verifica_horario_execução, Off
				sleep,	1000
				index :=	A_Index
				_software := sistemas[A_Index].software
				GuiControl, , debugui,% log .="`n" "Verificando horário de execução de " _software

				Loop,%	sistemas[ A_index ].horas.Count()	{
					 log	.=	"`n`n`tInicio`t"	sistemas[index].horas[A_Index]
							.	"`n`tAgora`t"		time_now
							.	"`n`tFim`t"			sistemas[index].horas[A_Index]+10

					if(	time_now > sistemas[index].horas[A_Index]
					&&	time_now < sistemas[index].horas[A_Index]  + 10 )	{

						log .= "`nHORA OK`n" "Verifica se o software já está rodando:"
							.	"`t" windows.ProcessExist( software := _software ".exe" ) = 1 ? "RODANDO" : "`nPronto para ser executado"

						if !windows.ProcessExist( software := _software ".exe" )	{	;	processo não estiver rodando
							if ( _software = "atualiza_contatos" ) {
								log .=	"`nExecutando Atualização de colaboradores com senha"
								sync_data.alarms()
							}
							log .="`n`n" _software " iniciado às " datetime()
							Gosub, Run
						}
					}
				}
				if	debuguion	{
					contagem = 11
					GuiControl, , debugui
					GuiControl, , debugui,% log
					if rodou
						Loop, 10 {
							WinSetTitle, Debugger, ,% "Debugger - " contagem-A_Index
							Sleep, 1000
						}
					rodou =
					WinSetTitle, Debugger - 1, ,Debugger
					log	=
				}
			}
		;

		SetTimer,	verifica_horario_execução,	5000
	Return

	Run:
		rodou = 1
		if FileExist( path "\" software )
			FileDelete,% path "\" software

		nome_do_software_para_sql := StrRep( software,,".exe" )
		OutputDebug % "Executando " nome_do_software_para_sql

		s =
			(
			SELECT TOP (1)
				[Bin]
			FROM
				[ASM].[dbo].[Softwares]
			WHERE
				[Name]	= '%nome_do_software_para_sql%'
			)
			bins := sql( s, 3 )

		if	( bins.Count()-1	=	0 ) {

			log2 .= "`nBINÁRIO NÃO ENCONTRADO`n"

			if !nome_do_software_para_sql
				body	:=	"Sistema`t"" " software " "" não foi encontrado na base de dados`npara ser executado em `t" datetime()
			Else
				body	:=	"Sistema`t"" " nome_do_software_para_sql " "" não foi encontrado na base de dados`npara ser executado em `t" datetime()
			mail.new("dsantos@cotrijal.com.br","10.0.20.43 - Erro Gestor de Serviços", body )

			log2 .= "`nE-mail de aviso de erro enviado para dsantos@cotrijal.com.br`n"

			Menu, Tray,	Tip, %software% NÃO EXISTE NA BASE DE DADOS
			Return
		}
		Sleep, 3000
		
		log2 .="`nVerificando se o software " _software " já existe em " path "`n"	FileExist( path "\" software ) = 1
																					? "Existe"
																					: "Não Existe"
		
		if ( FileExist( path "\" software ) = "" )	{			;	Garante a inexistência do executável
			Base64.FileDec( bins[2, 1] , path "\" software )	;	Transforma o arquivo base64 em executável
			log2 .= "`nExecutável criado no destino"
		}
		Loop	{												;	Garante a existência do arquivo antes de executar para evitar erro
			If (FileExist( path "\" software ) != ""
			||	A_Index > 25 ) {
				log2 .= "`nEXECUTÁVEL ENCONTRADO, encerrando Loop. Index atual = " A_index "`n"
				Break
			}
			Else {
				log2 .= "`nEXECUTÁVEL NÃO ENCONTRADO, encerrando Loop. Index atual = " A_index "`n"
				Return
			}
		}
		Sleep,	1000

		atualizado	:=	A_YYYY "/" A_MM "/" A_DD " "
					.	A_Hour ":" A_Min ":" A_Sec

		Run,% path "\" software

		log	.="`n`n" _software " executado às " datetime() "`n" log2
		log2=
		Menu, Tray,	Tip, Gestor de Serviços`nùltima execução: %atualizado%`t%software%
	Return
;