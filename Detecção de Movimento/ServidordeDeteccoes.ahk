File_Version=0.2.0
Save_to_Sql=1
;@Ahk2Exe-SetMainIcon C:\AHK\icones\_gray\2motion.ico
/*
	BD = MotionDetection
	16/01/2021	-	Alterado para inserir as imagens geradas apenas a cada 100 eventos
	28/01/2021	-	Ajustado o nome "local" na variavel de distribuicao para remover nova linha e evitar erros ao mover
	11/02/2021	-	Inserido linha para restart do banco de dados MotionDetection ANTES de recriar o array de câmeras
	19/02/2021	-	Incrementado sistema de sinistro
	04/04/2021	-	Adicionado sub função Restaura_Sinistro para finalizar sinistros expirados e não encerrados pelo cliente
	03/04/2022	-	Migrado para o Visual Code
	17/05/2022	-	Alterado banco de dados para o banco automático do dguard e alterado o sistema de arrays
*/

/*	Bancos de Dados
	[Dguard].[dbo].[cameras]
	[Dguard].[dbo].[cameras_mac]
	[MotionDetection].[dbo].[operadores]
*/

;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\date.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\folder.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

;	Configurações
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
	
	SetTimer,	Restaura_Sinistro,	300000
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

	;	Rotina de array de cameras e limpeza de log de imagens geradas de período maior que 40 dias(mesmo período de gravações)
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
					,	"Falha Servidor de Detecções" Substr(datetime(), 1, 10 )
					,	"Busca SQL não retornou nenhuma câmera para montar o array de consulta" )
	;

	SetTimer,	prepara_array,	-3600000
	Run,%	A_ScriptDir "\preparaimagens" ext " " SubStr( foscam, 1, -1 )
	SetTimer,	distribui_imagens_por_operador,	On
return

distribui_imagens_por_operador:
	Loop, Files,% Motion "*.jpg"
	{
		StartTime := A_TickCount
		img	:= local := setor := ""	;	limpa variáveis
		img	:=	StrSplit( A_LoopFileName, "_" )
		;	Verifica se a câmera está inibida ou se não está cadastrada 
			Gosub	verificaInibidos
			If( inibida = 1 )	{
				geradas.push( "('" img[1] "','" hora_imagem "','Inibido')" )
				continue
			}
			If( cameras[ img[1] ] = "" )	{	;	Se não constar no CADASTRO, gera log , move e vai pra próxima
				FileRead, sem_cadastro, %FTP%Log\Sem cadastro.txt
				if( RegExMatch( sem_cadastro, img[1] ) = 0 ) {	;	Se não consta registro, registra e move o arquivo
					FileAppend,%	img[1] "`n", %FTP%Log\Sem cadastro.txt
					FileMove,%		A_LoopFileFullPath,%	FTP "AddBD\" img[1] ".jpg"
				}
				Else				
					FileDelete,%	A_LoopFileFullPath
				continue
			}
		;

		;	Distribui imagem para o operador
			cam_data := StrSplit( cameras[ img[1] ], "&&" )
			local		:=	cam_data[2]				;	Nome da Câmera
			setor		:=	"000" cam_data[3]		;	Operador 
			data_e_hora	:=	SubStr( img[2], 1, 15 )	;	Data e Horário
			op_sinistro	:=	"000" cam_data[4]		;	Operador quando em sinistro
				If( op_sinistro = "000" )
					op_sinistro=0000
			If( geradas.Count() >= 100				;	Se pronto para inserir
			||	comando_inserir = 1 )	{			;	Se inserção forçada
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
				Try																												;	executa inserção no banco de dados sem gerar msg de erro
					sql( insere_, 3 )
				insere_			=
				geradas			:=	[]
				geradas2		:=	[]
				comando_inserir	=	0
			}
			Else
				geradas.push( "('" img[1] "','" hora_imagem "','" setor "')" )
		FileMove,%	A_LoopFileFullPath,%	FTP setor "\" data_e_hora "_" img[1] "_" StrReplace( local, "|", "-" ) "_" op_sinistro ".jpg", 1	;	Adicionado ultimo parametro
		; OutputDebug % format("{1:0.3f}" ,(A_TickCount - StartTime)/1000) " errorlevel = " ErrorLevel
		; if errorlevel
			; MsgBox % FTP setor "\" data_e_hora "_" img[1] "_" StrReplace( local, "|", "-" ) "_" op_sinistro ".jpg"
	}
return

verificaInibidos:
	inibida	=	0
	ip	:=	img[1]
	i	=
		(
			SELECT
				[ip]
			FROM
				[MotionDetection].[dbo].[inibidos]
			WHERE
				[ip] = '%ip%'
			AND
				[restaurado] IS NULL
		)
	_inibido :=	sql( i, 3 )
	If( _inibido.count()-1 > = 1 )	{	;	 Se está inibida
		inibida		=	1
		FileDelete,%	A_LoopFileFullPath
	}
	Else	;	Caso não esteja inibida
		inibida	=	0
	hora_imagem := datetime( 1, img[2] ) ; usado no sql
Return

Restaura_Sinistro:
	s	=
		(
			SELECT
					[inicio]
				,[fim]
				,[pkid]
			FROM
				[MotionDetection].[dbo].[operadores]
			WHERE
				[Finalizado] is NULL
		)
	s	:=	sql( s, 3 )
	If( s.Count()-1 != 0 )
		Loop,%	s.Count()-1	{
			_agora		:=	Date.toSeconds( A_Now )
			iniciou		:=	s[A_Index+1 , 1]
			finalizar	:=	s[A_Index+1 , 2]
			pkid		:=	s[A_Index+1 , 3]
			If( _agora > finalizar )	{
				FormatTime,	agora,	A_Now,	yyy/MM/dd HH:m:ss
				u	=
					(
						UPDATE
							[MotionDetection].[dbo].[operadores]
						SET
							[Finalizado] = CAST( '%agora%' as datetime )
						WHERE
							[pkid] = '%pkid%'
					)
				sql( u, 3 )
				finalizar := iniciou := _agora :=
			}
		}
Return

^F1::	;	Tooltips
	IS_TOOLTIP_ON	:=	!IS_TOOLTIP_ON
	If( IS_TOOLTIP_ON = 1 )	{
		If( debug = 0 )
			Menu,	Tray,	Icon,	%A_ScriptDir%\Log\2motionp.ico
		ToolTip,%	data_e_hora	"_" img[1] "_" local "`nInibida:" inibida
				.	"`n"	datetime()
				.	"`n" setor
				.	"`n`tModo dia = " dia
				.	"`nImagens em log para inserção no BD(insere a cada 100)= " geradas.count(),	10, 10
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
		ToolTip,%	data_e_hora	"_" img[1] "_" local "`nInibida:" inibida "`n"	datetime() "`n" setor "`n`tModo dia = " dia "`nImagens em log para inserção no BD(insere a cada 100)= " geradas.count(),	10, 10
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
					.	"`nImagens em log para inserção no BD(insere a cada 100)= " geradas.count(),	10, 10
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
	ExitApp