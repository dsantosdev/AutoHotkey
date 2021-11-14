/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\users\dsantos\desktop\executáveis\servidor.exe
Created_Date=1
Run_After="C:\Users\dsantos\Desktop\Executáveis\AHK2BD.exe "servidor" "0.0.0.20" """
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Version=0.0.0.20
Inc_File_Version=1
Product_Name=servidor
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\Dih\zIco\fun\bat.ico

* * * Compile_AHK SETTINGS END * * *
*/

;@Ahk2Exe-SetMainIcon C:\Dih\zIco\fun\bat.ico

;	Config
	#Persistent
	#SingleInstance	Force
	if ( A_UserName != "dsantos" )
		Menu,	Tray,	NoStandard
	Menu,	Tray,	Tip,	Sincronizador MSSQL x ORACLE
;

;	Variáveis
	inicia		= 0000
	finaliza	= 0010
	tooltips	= 0
;

;	Configuração
	CoordMode, ToolTip, Screen
;

;	Includes
	#Include	..\class\base64.ahk
	#Include	..\class\sql.ahk
	#Include	..\class\windows.ahk
;

;	Timer
	SetTimer,	executor,	5000
	if ( A_Args[1] = 1 )
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
		finaliza	:=	inicia + 5
	;	fazagora	=	1
	return
	
	End::	;	Sai do aplicativo
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
				ToolTip,	%	StrLen(atualizado) = 0 ? "Não efetuou atualização ainda, aguarde a próxima troca de hora ou pressione CTRL+F2" : "Contatos atualizados às " atualizado "`nmmss = " mmss,	50,	50
				; ToolTip,	%	StrLen(atualizado) = 0 ? "Não efetuou atualização ainda, aguarde a próxima troca de hora ou pressione CTRL+F2" : "Contatos atualizados às " atualizado "`nmmss = " mmss "`n" tooltips "`t" ErrorLevel,	50,	50
		;

		mmss := SubStr( A_Now , 11 )
		;	Atualiza contatos - Chamada de procedimento
			if ((mmss > inicia && mmss < finaliza)							;	Executa apenas quando virar as horas(##:00:00 até ##:00:10)
			&&	windows.ProcessExist( "atualiza_contatos.exe" ) = 0 )	{	;	e se não estiver rodando já a atualização
				FileDelete, C:\Dieisson\Motion Detection\atualiza_contatos.exe
				s =
					(
					SELECT TOP (1)
							 [Name]
							,[Bin]
							,[Version]
					FROM
						[ASM].[dbo].[Softwares]
					WHERE
						[Name]	= 'atualiza_contatos'
					AND
						[Obs]	= ''
					ORDER BY
						3
					DESC
					)
					bins := sql( s, 3 )
					Sleep, 1000
				if (FileExist( "C:\Dieisson\Motion Detection\atualiza_contatos.exe" ) = "" )			;	Garante a existência do executável
					Base64.FileDec( bins[2, 2] , "C:\Dieisson\Motion Detection\" bins[ 2 , 1 ] ".exe" )	;	Transforma o arquivo bas64 em executável
				Loop
					If ( FileExist( "C:\Dieisson\Motion Detection\" bins[ 2 , 1 ] ".exe" ) != "" )
						Break
					Sleep, 1000
				; Run, C:\Dieisson\Motion Detection\atualiza_contatos.exe "1"
				Run,% "C:\Dieisson\Motion Detection\" bins[ 2 , 1 ] ".exe 1"
				atualizado	:=	SubStr( A_Now , 1 , 4 ) "/" SubStr( A_Now , 5 , 2 ) "/" SubStr( A_Now , 7 , 2 ) " "
							.	SubStr( A_Now , 9 , 2 ) ":" SubStr( A_Now , 11 , 2 ) ":" SubStr( A_Now , 13 , 2 )
				Menu, Tray, Tip, Sicronizador MSSQL x ORACLE	Sicronizador MSSQL x ORACLE`nùltima Sincronização: %atualizado%
				inicia		=	0000
				finaliza	=	0010
				atualizou	=	1
			}
		;
		Return

		
		if (( SubStr( A_Now , 9 ) > "070500" && SubStr( A_Now , 9 ) < "070510" )
		||	( fazagora = 1 && outros = 0 ) )	{	;	Atualiza contagem de detecções durante tempo inibido	|	Remove dados antigos das tabelas | Executa 2 vezes ao dia
			SetTimer,	executor,	Off
				ToolTip,	%	"Contatos atualizados às " atualizado "`n" mmss "`nIniciado verificação de demitidos Autorizados",	50,	50
			; conta_inibidas()	;	 Atualiza no banco de dados ASM as quantia de imagens geradas em período que a câmera estava inibida
				ToolTip,	%	"Contatos atualizados às " atualizado "`n" mmss "`nIniciado Remoção de Imagens Geradas",	50,	50
			if ( atualizou = 1 )	{
				atualizou	= 0
				fazagora	= 0
				outros		= 0
			}
			Else
				outros = 1
		}
		SetTimer,	executor,	1000
	return
;