﻿/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\users\dsantos\desktop\executáveis\servidor.exe
Created_Date=1
Run_After="C:\Users\dsantos\Desktop\Executáveis\AHK2BD.exe "servidor" "0.0.0.34" """
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Version=0.0.0.34
Inc_File_Version=1
Product_Name=servidor
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\AHK\icones\fun\bat.ico

* * * Compile_AHK SETTINGS END * * *
*/

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
	for_timer	= 07	;	Horário das câmeras
	inicia		= 0000
	finaliza	= 0010
	tooltips	= 0
;

;	Arrays e Maps
	sistemas := {}
;

;	Configuração
	CoordMode,	ToolTip, Screen
;

;	Includes
	#Include	..\class\base64.ahk
	#Include	..\class\sql.ahk
	#Include	..\class\windows.ahk
;

;	Timers
	Gosub, load_vars
	SetTimer,	executor,	5000	;	a cada 5 segundos verifica os horários
	if ( A_Args[1] = 1 )			;	para chamada dinâmica por outro sistema
		Gosub, executa_atualizado
	Return
;

;	Shortcuts
	F1::	;	Exibe tooltip
		tooltips	:=	!tooltips
	return

	^F2::	;	Executa agora
		executa_atualizado:
		inicia		:=	SubStr( A_Now , 11 )
		finaliza	:=	inicia + 10
	return

	F3::	;	Atualiza horários e sistemas via query sql manualmente
		for_timer	:=	A_Hour - 12 < 0 ? StrLen( 24 + ( for_timer - 12 ) ) = 1 ? : : A_Hour - 12	;	se passar da meia noite
		; inicia		:=	0700
		inicia		:=	A_Min A_Sec
			Loop	;	Deal with zeros in minutes
				if ( StrLen( inicia ) = 4 )
					Break
				Else
					inicia := "0" inicia

		finaliza	:=	inicia + 10
			if ( SubStr( finaliza , -1) >= 60 )		;	Segundos passam de 59
				finaliza := finaliza + 40

			if ( SubStr( finaliza , -3) >= 6000 )	;	Minutos passam de 59
				finaliza := finaliza + 4000

			if ( SubStr( finaliza , -5) >= 235959 )	;	Hora passa de 235959
				finaliza := finaliza - 240000
			Loop
				if ( StrLen( finaliza ) = 4 )
					Break
				Else
					finaliza := "0" finaliza
		Gosub, executor
	Return

	End::	;	Encerra o aplicativo
		ExitApp
	;
;

;	Code
	executor:
		;	Tooltip ativado ou não
			Process, Exist, atualiza_contatos.exe
			if (tooltips != 1
			||	ErrorLevel <> 0)
				ToolTip
			Else
				ToolTip,%	StrLen( atualizado )	= 0
													? "Não efetuou atualização ainda, aguarde a próxima troca de hora ou pressione CTRL+F2"
													: "Contatos atualizados às " atualizado "`nmmss = " mmss,	50,	50
		;

		;	prepara variável de tempo
			time_now	:=	SubStr( A_Now, 9 )
			time_check	:=	SubStr( A_Now, 11)
		;

		;	Execução
			Loop,%	sistemas.Count() {
				SetTimer, executor, Off
				sleep,	1000
				if ( sistemas[ A_index ].lacuna = 1 )	{	;	Hora em hora
					h_inicio_m	:= A_Hour . inicia
					h_fim_m	 	:= A_Hour . finaliza

					if ((time_now > h_inicio_m && time_now < h_fim_m)								;	horário
					&&	windows.ProcessExist( software := sistemas[ A_index ].nome ".exe" ) = 0)	;	processo não estiver rodando
						Gosub, Run

				}
				Else	{									;	Intervalo Definido
					inicio_t	:= for_timer + sistemas[ A_index ].lacuna . inicia
					fim_t		:= for_timer + sistemas[ A_index ].lacuna . finaliza
					m_inicio_m	:= for_timer . inicia
					m_fim_m		:= for_timer . finaliza

					manhã :=	time_now >= m_inicio_m && time_now	< m_fim_m
																? "True"
																: "False"
					tarde :=	time_now >= inicio_t && time_now  < fim_t
															 ? "True"
															 : "False"
					processo :=	windows.ProcessExist( software := sistemas[ A_index ].nome ".exe" )	= 0
																								? "True"
																								: "False"
					; MsgBox,%	manhã " OU ( " tarde " E " processo " )`n"
							; .	time_now " >= " m_inicio_m	" && " time_now " < " m_fim_m "`n"
							; .	time_now " >= " inicio_t	" && " time_now " < " fim_t "`n"
							; .	windows.ProcessExist( software := sistemas[ A_index ].nome ".exe" )
					;

					if ((manhã		= "true" )		;	manhã
					||	(tarde		= "true" 		;	tarde e ↓
					&&	 processo	= "true" ) ) {	;			processo não estiver rodando
						; MsgBox 1
						Gosub, Run
					}
					; MsgBox 2
				}
			}
		;

		SetTimer,	executor,	5000
	Return

	Run:
		FileDelete,% path "\" software
		for_sql := SubStr( software , 1 , -4 )

		s =
			(
			SELECT TOP (1)
				[Bin]
			FROM
				[ASM].[dbo].[Softwares]
			WHERE
				[Name]	= '%for_sql%'
			AND
				[Obs]	= ''
			)
			bins := sql( s, 3 )
			Sleep, 1000
		if (FileExist( path "\" software ) = "" )				;	Garante a existência do executável
			Base64.FileDec( bins[2, 1] , path "\" software )	;	Transforma o arquivo base64 em executável

		Loop													;	Garante a existência do arquivo antes de executar para evitar erro
			If (FileExist( path "\" software ) != ""
			||	A_Index > 25 )
				Break
			Sleep,	1000
		Run,% path "\" software " 1"

		atualizado	:=	A_YYYY "/" A_MM "/" A_DD " "
					.	A_Hour ":" A_Min ":" A_Sec
		Menu, Tray,	Tip, Gestor de Serviços`nùltima Sincronização: %atualizado%
	Return

	load_vars:
		select =
			(
				SELECT
					 [sistema]
					,[lacuna]
				FROM
					[ASM].[dbo].[_gestao_servidor]
			)
			s := sql( select , 3 )
		Loop,%	s.Count()-1	;	 se lacuna for zero, sabe que é o path
			if ( s[ A_Index+1 , 2 ] = 0 )	{
				path := SubStr( s[ A_Index+1 , 1 ], InStr( s[ A_Index+1 , 1 ], "|" )+1 )
				Continue
			}
			Else
				sistemas.push({	nome	:	s[ A_Index+1 , 1 ]
							,	lacuna	:	s[ A_Index+1 , 2 ]	 })
	Return
;