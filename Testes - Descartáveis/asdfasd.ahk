File_Version=0.2.0
Save_to_Sql=1
;@Ahk2Exe-SetMainIcon C:\AHK\icones\_gray\2motion.ico
/*
	BD = MotionDetection
	16/01/2021	-	Alterado para inserir as imagens geradas apenas a cada 100 eventos
	28/01/2021	-	Ajustado o nome "local" na variavel de distribuicao para remover nova linha e evitar erros ao mover
	11/02/2021	-	Inserido linha para restart do banco de dados MotionDetection ANTES de recriar o array de c�meras
	19/02/2021	-	Incrementado sistema de sinistro
	04/04/2021	-	Adicionado sub fun��o Restaura_Sinistro para finalizar sinistros expirados e n�o encerrados pelo cliente
	03/04/2022	-	Migrado para o Visual Code
	17/05/2022	-	Alterado banco de dados para o banco autom�tico do dguard e alterado o sistema de arrays
*/

/*	Bancos de Dados
	[Dguard].[dbo].[cameras]
	[Dguard].[dbo].[cameras_mac]
	[MotionDetection].[dbo].[operadores]
*/

;	Includes
	; #Include D:\FTP\Monitoramento\FTP\VS Code\class\alarm.ahk
	; #Include D:\FTP\Monitoramento\FTP\VS Code\class\array.ahk
	; #Include D:\FTP\Monitoramento\FTP\VS Code\class\base64.ahk
	; #Include D:\FTP\Monitoramento\FTP\VS Code\class\convert.ahk
	; #Include D:\FTP\Monitoramento\FTP\VS Code\class\cor.ahk
	; #Include D:\FTP\Monitoramento\FTP\VS Code\class\dguard.ahk
	#Include D:\FTP\Monitoramento\FTP\VS Code\class\date.ahk
	#Include D:\FTP\Monitoramento\FTP\VS Code\class\folder.ahk
	#Include D:\FTP\Monitoramento\FTP\VS Code\class\functions.ahk
	; #Include D:\FTP\Monitoramento\FTP\VS Code\class\gui.ahk
	; #Include D:\FTP\Monitoramento\FTP\VS Code\class\listview.ahk
	#Include D:\FTP\Monitoramento\FTP\VS Code\class\mail.ahk
	; #Include D:\FTP\Monitoramento\FTP\VS Code\class\safe_data.ahk
	#Include D:\FTP\Monitoramento\FTP\VS Code\class\sql.ahk
	; #Include D:\FTP\Monitoramento\FTP\VS Code\class\string.ahk
	; #Include D:\FTP\Monitoramento\FTP\VS Code\class\telegram.ahk
	#Include D:\FTP\Monitoramento\FTP\VS Code\class\timer.ahk
	; #Include D:\FTP\Monitoramento\FTP\VS Code\class\windows.ahk
;

;	Configura��es
	#Persistent
	#SingleInstance, Force
	SetBatchLines, -1

	If( A_IsCompiled )	{
		If !A_IsAdmin
		|| !( DllCall( "GetCommandLine", "Str" ) ~= " /restart(?!\S)" )
			Try
				RunWait, % "*RunAs """ ( A_IsCompiled ? A_ScriptFullPath """ /restart" : A_AhkPath """ /restart """ A_ScriptFullPath """" )
		Menu,	Tray, NoStandard
		FileInstall,	C:\AHK\icones\_gray\2motion.ico,	%A_ScriptDir%\Log\2motion.ico,1
		FileInstall,	C:\AHK\icones\_gray\2motionp.ico,	%A_ScriptDir%\Log\2motionp.ico,1
	}

	Global	ext
	If ( A_IsCompiled = 1 )
		ext	=	.exe
	Else
		ext	=	.ahk
	OnExit( "close_preparaImagens" )

	ger_vers = Gerenciador de Imagens %File_Version% - 15/05/2022
	Debug( A_LineNumber, "Traytip=`n`t" ger_vers )

	geradas	:=	[]

	ToolTip	Executando em 1 segundo...
		Sleep	1000
	ToolTip

	Menu	Tray,	Tip,	Gerenciador de Imagens

	if ( A_UserName = "dsantos" ) {
		Motion	=	\\srvftp\Monitoramento\FTP\Motion\
		FTP		=	\\srvftp\Monitoramento\FTP\
	}
	Else	{
		Motion	=	D:\FTP\monitoramento\FTP\Motion\
		FTP		=	D:\FTP\monitoramento\FTP\
	}

		Debug( A_LineNumber, "Preparando Array" )
	Gosub	prepara_array
		Debug( A_LineNumber, "Array Preparado" )

	SetTimer,	distribui_imagens_por_operador,		999
return

prepara_array:	;	SQL
	SetTimer,	distribui_imagens_por_operador,		Off
	Sleep,		2000

	reset_bd	=	;	Reseta o banco de dados motiondetection
		(
			alter database [MotionDetection] set offline with rollback immediate;
			alter database [MotionDetection] set online
		)
		sql( reset_bd, 3 )
		Sleep,	2000

	;	Rotina de array de cameras e limpeza de log de imagens geradas de per�odo maior que 40 dias(mesmo per�odo de grava��es)
		s	=
			(
				Select
					 c.[ip]
					,m.[mac]
					,c.[name]
					,c.[operador]
					,c.[sinistro]
					,LEFT( c.[vendormodel], charindex(' ', c.[vendormodel]) - 1)
				FROM
					[Dguard].[dbo].[cameras] c
				LEFT JOIN
					[Dguard].[dbo].[cameras_mac] m
				ON
					c.[ip] = m.[ip];

				DELETE
					FROM
						[MotionDetection].[dbo].[Geradas]
					WHERE
						[horario] < DATEADD( day, -40, GETDATE()) ;
			)
		s	:=	sql( s, 3 )

		IF ( s.Count() - 1 ) > 1	{
			cameras := {}
			Loop,%	s.Count()-1 {
				cameras[s[A_Index+1,1]]	:=	(s[A_Index+1,2] = "" ? "0000" : s[A_Index+1,2]) "&&"
										.	 s[A_Index+1,3] "&&"
										.	(s[A_Index+1,4] = "" ? "0000" : s[A_Index+1,4]) "&&"
										.	(s[A_Index+1,5] = "" ? "0000" : s[A_Index+1,5])
				if ( s[A_Index+1,6] = "Foscam" )
					foscam	.=	 s[A_Index+1,2] "__" s[A_Index+1,1] "`n"
			}
		}
		Else
			mail.new(	"dsantos@cotrijal.com.br"
					,	"Falha Servidor de Detec��es" Substr(datetime(), 1, 10 )
					,	"Busca SQL n�o retornou nenhuma c�mera para montar o array de consulta" )
	;

	SetTimer,	prepara_array,	-3600000
	Run,%	A_ScriptDir "\preparaimagens" ext " " SubStr( foscam, 1, -1 )
	SetTimer,	distribui_imagens_por_operador,	On
return

distribui_imagens_por_operador:
	Loop, Files,% Motion "*.jpg"
	{
		StartTime := A_TickCount
		img	:= local := setor := ""	;	limpa vari�veis
		img	:=	StrSplit( A_LoopFileName, "_" )
		;	Verifica se a c�mera n�o est� cadastrada
			ip			:= img[1]
			hora_imagem := datetime( 1, img[2] )
			If( cameras[ ip ] = "" )	{	;	Se n�o constar no CADASTRO, gera log , move e vai pra pr�xima
				FileRead, sem_cadastro, %FTP%Log\Sem cadastro.txt
				if( RegExMatch( sem_cadastro, img[1] ) = 0 ) {	;	Se n�o consta registro, registra e move o arquivo
					FileAppend,%	ip "`n", %FTP%Log\Sem cadastro.txt
					FileMove,%		A_LoopFileFullPath,%	FTP "AddBD\" ip ".jpg"
				}
				Else
					FileDelete,%	A_LoopFileFullPath
				continue
			}
		;

		;	Distribui imagem para o operador
			cam_data 	:=	StrSplit( cameras[ ip ], "&&" )
			local		:=	cam_data[2]					;	Nome da C�mera
			setor		:=	"000" cam_data[3]			;	Operador
			data_e_hora	:=	SubStr( img[2], 1, 15 )		;	Data e Hor�rio
			op_sinistro	:=	"000" cam_data[4]	= 000	;	Operador quando em sinistro
												? "0000"
												: "000" cam_data[4]

			If( geradas.Count() >= 100					;	Se pronto para inserir
			||	comando_inserir = 1 )	{				;	Se inser��o for�ada
				SetTimer,	distribui_imagens_por_operador,	Off
				geradas2 := geradas
				SetTimer,	distribui_imagens_por_operador,	On
				For i, v in geradas2
					If( i = geradas2.count() )																					;	Quando tiver 100 eventos
						insere_	.=	geradas2[i]
					Else If( i = 1 )																							;	No primeiro evento
						insere_	.=	"INSERT INTO  [MotionDetection].[dbo].[Geradas] (ip,horario,folder) VALUES " geradas2[i]	",`n"
					Else																										;	Durante os eventos
						insere_ .= geradas2[i]	",`n"
				Try																												;	executa inser��o no banco de dados sem gerar msg de erro
					sql( insere_, 3 )
				insere_			=
				geradas			:=	[]
				geradas2		:=	[]
				comando_inserir	=	0
			}
			Else
				geradas.push( "('" img[1] "','" hora_imagem "','" setor "')" )
		FileMove,%	A_LoopFileFullPath,%	FTP setor "\" data_e_hora "_" img[1] "_" StrReplace( local, "|", "-" ) "_" op_sinistro ".jpg", 1	;	Adicionado ultimo parametro
		; MsgBox % FTP setor "\" data_e_hora "_" img[1] "_" StrReplace( local, "|", "-" ) "_" op_sinistro ".jpg"
		OutputDebug %	format("{1:0.3f}" ,(A_TickCount - StartTime)/1000)
					.	"`nerrorlevel = " ErrorLevel
					.	"`n" FTP setor "\" data_e_hora "_" img[1] "_" StrReplace( local, "|", "-" ) "_" op_sinistro ".jpg"
	}
return

^F1::	;	Tooltips
	IS_TOOLTIP_ON	:=	!IS_TOOLTIP_ON
	If( IS_TOOLTIP_ON = 1 )	{
		If( debug = 0 )
			Menu,	Tray,	Icon,	%A_ScriptDir%\Log\2motionp.ico
		ToolTip,%	data_e_hora	"_" img[1] "_" local "`nInibida:" inibida
				.	"`n"	datetime()
				.	"`n" setor
				.	"`n`tModo dia = " dia
				.	"`nImagens em log para inser��o no BD(insere a cada 100)= " geradas.count(),	10, 10
	}
	Else	{
		If( debug = 0 )
			Menu,	Tray,	Icon,	%A_ScriptDir%\Log\2motion.ico
		ToolTip
		MsgBox,,, Tooltip %IS_TOOLTIP_ON%, 1
	}
return

^F2::
	dia	:=	!dia
	If( dia = 1 )	{
		IS_TOOLTIP_ON	:=	!IS_TOOLTIP_ON = 1
		If( debug = 0 )
			Menu,	Tray,	Icon,	%A_ScriptDir%\Log\2motionp.ico
		ToolTip,%	data_e_hora	"_" img[1] "_" local
				.	"`nInibida:"	inibida
				.	"`n"			datetime()
				.	"`n"			setor
				.	"`n`tModo dia = " dia
				.	"`nImagens em log para inser��o no BD(insere a cada 100)= " geradas.count(),	10, 10
		MsgBox,	,	Verificar Dia,	Ativado, 1
	}
	Else	{
		MsgBox,	,	Verificar Dia,	Desativado, 1
		If( IS_TOOLTIP_ON = 1 )
			ToolTip,%	data_e_hora	"_" img[1] "_" local
					.	"`nInibida:" inibida
					.	"`n"	datetime()
					.	"`n"	setor
					.	"`n`tModo dia = "	dia
					.	"`nImagens em log para inser��o no BD(insere a cada 100)= " geradas.count(),	10, 10
	}
return

^F3::
	comando_inserir	:=	!comando_inserir
return

^End::
	GuiClose:
	ExitApp

close_preparaImagens( ) {
	Process, Close,% "preparaimagens" ext
}