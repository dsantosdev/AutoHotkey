/*
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

;	Config
	#Persistent
	#SingleInstance	Force
	Menu,	Tray,	Tip,	Sincronizador MSSQL x ORACLE
;

;	Variáveis
	for_timer	= 07	;	Horário câmeras
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
		for_timer	:=	A_Hour - 12 < 0 ? 24 + ( for_timer - 12 ) : A_Hour - 12
		inicia		:=	SubStr( A_Now , 11 )
		finaliza	:=	inicia + 10
	Return

	End::	;	Encerra o aplicativo
		ExitApp
	;
;

;	Code
	executor:
		;	Tooltip ativado ou não
			Process, Exist, atualiza_contatos.exe
			if (tooltips	!= 1
			||	ErrorLevel	<> 0 )
				ToolTip
			Else
				ToolTip,%	StrLen( atualizado ) = 0
												 ? "Não efetuou atualização ainda, aguarde a próxima troca de hora ou pressione CTRL+F2"
												 : "Contatos atualizados às " atualizado "`nmmss = " mmss,	50,	50
		;

		;	prepara variável de tempo
			time_now	:=	SubStr( A_Now, 9 )
			time_check	:=	SubStr( A_Now, 11)
		;

		;	Execução
			; tooltip, % sistemas.Count() "`n" time_now "`n" time_check

			Loop,%	sistemas.Count() {
				if ( sistemas[ A_index ].lacuna = 1 )	{	;	Hora em hora

					ToolTip % "Horário Lacuna = 1`n" time_now "`t" A_Hour . inicia "`t" A_Hour . finaliza "`n" sistemas[ A_index ].nome
					Sleep, 3000
					if ((time_now > A_Hour . inicia	&&	time_now < A_Hour . finaliza)				;	horário
					&&	windows.ProcessExist( software := sistemas[ A_index ].nome ".exe" ) = 0)	;	processo não estiver rodando
						Gosub, Run

				}
				Else	{									;	Intervalo Definido

					ToolTip, %	"Horário Lacuna != 1`n"
					 		.	"manhã " for_timer . inicia
					 		.	"`ntarde " for_timer + sistemas[ A_index ].lacuna . finaliza
							.	"`n" A_Hour . time_check " || " A_Hour . time_check
							.	"`n" sistemas[ A_index ].nome
					sleep 10000
					MsgBox
					;	
					if ((for_timer . inicia > A_Hour . time_check && for_timer . finaliza < A_Hour . time_check)
					||	(for_timer + sistemas[ A_index ].lacuna . time_check > A_Hour . inicia	&&	for_timer + sistemas[ A_index ].lacuna . time_check < A_Hour . finaliza)	;	horário
					&&	windows.ProcessExist( software := sistemas[ A_index ].nome ".exe" ) = 0)																				;	processo não estiver rodando
						Gosub, Run
				}
			}
		;

		SetTimer,	executor,	5000
	Return

	Run:
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
			FileDelete,% path "\" software
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
		Menu, Tray,	Tip, Sicronizador MSSQL x ORACLE	Sicronizador MSSQL x ORACLE`nùltima Sincronização: %atualizado%
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