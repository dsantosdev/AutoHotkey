;@Ahk2Exe-SetMainIcon C:\Dih\zIco\srv.ico
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
;

;	Includes
	#Include	..\class\base64.ahk
	#Include	..\class\sql.ahk
	#Include	..\class\windows.ahk
;

;	Timer
	SetTimer,	executor,	5000
	Return
;

;	Shortcuts
	F1::	;	Exibe tooltip
		t	:=	!t
	return

	F2::	;	Executa agora
		inicia		:=	SubStr( A_Now , 11 )
		finaliza	:=	inicia + 5
		fazagora	=	1
	return

	End::	;	Sai do aplicativo
		ExitApp
	;
;


executor:
	;	Tooltip ativado ou não
		if ( tooltips = 0 )
			ToolTip
		Else
			ToolTip,	%	"Contatos atualizados às " atualizado "`n" mmss,	50,	50
	;

	mmss := SubStr( A_Now , 11 )

	;	Atualiza contatos - Chamada de procedimento
		if ((	mmss > inicia && mmss < finaliza)							;	Executa apenas quando virar as horas(##:00:00 até ##:00:10)
		&&		windows.ProcessExist( "atualiza_contatos.exe" ) = 0 )	{	;	e se não estiver rodando já a atualização
			FileGetVersion, exe_version , C:\Dieisson\Motion Detection\atualiza_contatos.exe
			s =
				(
				SELECT	TOP (1)
						[Name]
						,[Bin]
						,[Version]
						,[Obs]
				FROM
					[ASM].[dbo].[Softwares]
				WHERE
					[Name] = 'atualiza_contatos'
				AND
					[Obs] = 'Produção'
				)
				bins := sql( s, 3 )
			if ( exe_version != bins[ 2 , 2 ] )
				FileDelete, C:\Dieisson\Motion Detection\atualiza_contatos.exe
			if (FileExist( "C:\Dieisson\Motion Detection\atualiza_contatos.exe") = ""
			||	exe_version != bins[ 2 , 2 ] ) 	;	Garante a existência do executável
				Base64.FileDec( bins[2, 2] , "C:\Dieisson\Motion Detection\" bins[ 2 , 1 ] ".exe" )	;	transforma o arquivo bas64 em executável
			Loop
				If ( FileExist( "C:\Dieisson\Motion Detection\" bins[ 2 , 1 ] ".exe" ) != "" )
					Break
			Run, C:\Dieisson\Motion Detection\atualiza_contatos.exe "1"
			atualizado	:=	SubStr( A_Now , 1 , 4 ) "/" SubStr( A_Now , 5 , 2 ) "/" SubStr( A_Now , 7 , 2 ) " "
						.	SubStr( A_Now , 9 , 2 ) ":" SubStr( A_Now , 11 , 2 ) ":" SubStr( A_Now , 13 , 2 )
			Menu, Tray, Tip, Sicronizador MSSQL x ORACLE	Sicronizador MSSQL x ORACLE`nùltima Sincronização: %atualizado%
			inicia		=	0000
			finaliza	=	0010
			atualizou	=	1
		}
	;
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