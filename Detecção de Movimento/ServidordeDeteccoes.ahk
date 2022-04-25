/*
	* * * Compile_AHK SETTINGS BEGIN * * *
	[AHK2EXE]
		Exe_File=C:\users\dsantos\desktop\executáveis\ServidordeDeteccoes.exe
		Created_Date=1
	[VERSION]
		Set_Version_Info=1
		Company_Name=Heimdall
		File_Description=
		File_Version=0.0.0.1
		Inc_File_Version=1
		Product_Name=ServidordeDeteccoes
		Product_Version=1.1.33.2
		Set_AHK_Version=1
	* * * Compile_AHK SETTINGS END * * *
*/

;@Ahk2Exe-SetMainIcon C:\AHK\icones\_gray\2motion.ico
/*
	BD = MotionDetection
	16/01/2021	-	Alterado para inserir as imagens geradas apenas a cada 100 eventos
	28/01/2021	-	Ajustado o nome "local" na variavel de distribuicao para remover nova linha e evitar erros ao mover
	11/02/2021	-	Inserido linha para restart do banco de dados MotionDetection ANTES de recriar o array de câmeras
	19/02/2021	-	Incrementado sistema de sinistro
	04/04/2021	-	Adicionado sub função Restaura_Sinistro para finalizar sinistros expirados e não encerrados pelo cliente
	03/04/2022	-	Migrado para o Visual Code
*/


;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\date.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\folder.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safedata.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

#SingleInstance, Force
If !A_IsAdmin || !(DllCall("GetCommandLine","Str")~=" /restart(?!\S)")
	Try RunWait, % "*RunAs """ (A_IsCompiled?A_ScriptFullPath """ /restart":A_AhkPath """ /restart """ A_ScriptFullPath """")

ger_vers = Gerenciador de Imagens 1.2.11	-	19/04/2022

If( A_IsCompiled )	{
	Menu,	Tray, NoStandard
	FileInstall,	C:\AHK\icones\_gray\2motion.ico,	%A_ScriptDir%\Log\2motion.ico,1
	FileInstall,	C:\AHK\icones\_gray\2motionp.ico,	%A_ScriptDir%\Log\2motionp.ico,1
}

ToolTip	Rodando em 1 segundo...
	Sleep	1000
ToolTip

#Persistent
	Menu	Tray,	Tip,	Gerenciador de Imagens
	if ( A_UserName = "dsantos" )
		Motion	=	\\srvftp\Monitoramento\FTP\Motion\
	Else
		Motion	=	D:\FTP\monitoramento\FTP\Motion\
	gosub	prepara_array
	SetTimer,	prepara_imagens,	1000
	SetTimer,	Restaura_Sinistro,	300000
	SetTimer,	distribuição,		999
return

prepara_array:	;	SQL
	SetTimer,	prepara_imagens,	Off
	SetTimer,	distribuição,		Off
	Sleep,		2000
	reset_bd	=	;	Reseta o bando de dados motiondetection
		(
			alter database [MotionDetection] set offline with rollback immediate;
			alter database [MotionDetection] set online
		)
		sql( reset_bd, 3 )
		Sleep,	2000

	;	Rotina de array de cameras e imagens geradas
		s	=
			(
				Select
					 [ip]
					,[mac]
					,[nome]
					,[setor]
					,[em_sinistro]
				FROM
					[motiondetection].[dbo].[cameras]
				WHERE
					[ip] LIKE '`%' + '.' + '`%' + '.' + '`%' + '.' + '`%'
			)
		s	:=	sql( s, 3 )

		IF ( s.Count() - 1 ) > 1	{
			cameras	:=	{}
			geradas	:=	[]
			Loop,%	s.Count()-1
				cameras.push({	ip			: s[A_Index+1,1]
							,	mac			: s[A_Index+1,2]
							,	nome		: s[A_Index+1,3]
							,	operador	: s[A_Index+1,4]
							,	sinistro	: s[A_Index+1,5]	} )
		}

	;	Rotina de informações de operadores
		s	=
			(
				SELECT
					 [ip]
					,[patrimonio]
					,[sinistro]
					,[inicio]
					,[fim]
					,[finalizado]
				FROM
					[MotionDetection].[dbo].[operadores]
			)
		s	:=	sql( s , 3 )
		sinistro	:=	{}
		Loop,%	s.Count()-1
			sinistro.push({	ip			:	s[A_Index+1,1]
						,	cpc			:	s[A_Index+1,2]
						,	estado		:	s[A_Index+1,3]
						,	inicio		:	s[A_Index+1,4]
						,	fim			:	s[A_Index+1,5]
						,	finalizado	:	s[A_Index+1,6]	})
	SetTimer,	prepara_array,	-3600000
	SetTimer,	prepara_imagens,	On
	SetTimer,	distribuição,	On
return

prepara_imagens:	;	SEM SQL
	IfWinExist,	ServidordeDeteccoes.exe		;	Fecha janela de erro?
		WinClose,	ServidordeDeteccoes.exe
	;	Reseta Inibidos
		rdia	:=	A_YDay
		rsec	:=	( A_Hour * 60 * 60 ) + ( A_Min * 60 ) + A_Sec
		u		=
			(
				UPDATE
					[MotionDetection].[dbo].[inibidos]
				SET
					 [restaurado]	=	GETDATE()
					,[geradas]		=	''
				WHERE
					[encerraDia]	<=	'%rdia%'
				AND
					[encerraHorario]<=	'%rsec%'
				AND
					[restaurado] IS NULL
			)
		sql( u, 3 )
	;	Foscam
		Loop, Files, %Motion%Foscam\*.jpg, R
		{
			p_foscam:=	StrSplit( A_LoopFileFullPath, "\" )
			mac		:=	SubStr( p_foscam[7], instr( p_foscam[7], "_" ) + 1 )
			data	:=	SubStr( p_foscam[9], InStr( p_foscam[9], "_" ) + 1 , 8 )
			hora	:=	SubStr( p_foscam[9], InStr( p_foscam[9], "_" ) + 10, 6 )
			ip		=
			ip		:=	cameras[ Array.InDict( cameras, mac, "mac" ) ].ip
			If( StrLen( ip ) = 0 )	{	;	Gera log se a consulta não retornar nome de câmera
				FileAppend,%	datetime() " | Mac = " mac " | Data = " data " | Hora = " hora " | IP = " ip "`n", D:\FTP\Monitoramento\FTP\Log\Não achou no DB.txt
				FileMove,%	A_LoopFileFullPath,	D:\FTP\monitoramento\FTP\AddBD\MAC - %mac% - %A_LoopFileName%
			}
			Else	{
				FileAppend,%	datetime() "|Mac = " mac "|" A_LoopFileFullPath "`n", D:\FTP\Monitoramento\FTP\Log\Geradas\Foscam %A_MM% - %A_DD%.txt
				FileMove,%	A_LoopFileFullPath, %Motion%%ip%_%data%-%hora%.jpg,	1
			}
		}

	;	Dahua
		Loop, Files, %Motion%Dahua\*.jpg, R
		{
			StringSplit,	path,	A_LoopFileFullPath,	\
			If( path0 = 10 )	{
				horario	:=	StrReplace( SubStr( path10, 1, instr( path10, "[" ) - 1 ), "." )
				ip		:=	StrReplace( path7, "_", "." )
				novonome:=	ip "_" StrReplace( path8, "-" ) "-" horario ".jpg"
			}
			Else If( path0 = 12 )	{
				tempo	:=	StrSplit( SubStr( path%path0%, 1, InStr( path%path0%, "[" ) - 1 ), "." )
				horario	:=	tempo[1] tempo[2]
				ip		:=	StrReplace( path7, "_", "." )
				novonome:=	ip "_" StrReplace( path8, "-" ) "-" path11 horario ".jpg"
			}
			Else	{
				segundos:=	SubStr( path13, 1, InStr( path13, "[" ) - 1 )
				ip		:=	StrReplace( path7, "_", "." )
				novonome:=	ip "_" StrReplace( path8, "-" ) "-" path11 path12 segundos ".jpg"
			}
			FileAppend,%	datetime() " | "	novonome "`tpath="	path0	"`n", D:\FTP\Monitoramento\FTP\Log\Geradas\Dahua %A_MM% - %A_DD%.txt
			FileMove,%	A_LoopFileFullPath,%	Motion novonome,	1
		}

	;	Intelbras
		Loop, Files, %Motion%Intelbras\*.jpg, R
		{
			path	:=	StrSplit( A_LoopFileFullPath,	"\" )
			If( ( contagem := path.count() ) = 12 )	{
				tempo	:=	StrSplit( SubStr( path[ contagem ], 1, InStr( path[ contagem ], "[")-1 ), "." )
				segundos:=	tempo[1] tempo[2]
				ip		:=	StrReplace( path[7], "_", "." )
				novonome:=	ip "_"
						.	StrReplace( path[8], "-" ) "-"		;	Data
						.	path[10] path[11] segundos ".jpg"	;	Horário
			}
			Else If( ( contagem := path.count() ) = 11 )	{
				tempo	:=	StrSplit( SubStr( path[ contagem ], 1, InStr( path[ contagem ], "[")-1 ), "." )
				segundos:=	tempo[1] tempo[2] tempo[3]
				ip		:=	StrReplace( path[7], "_", "." )
				novonome:=	ip "_"
						.	StrReplace( path[8], "-" ) "-"	;	Data
						.	segundos ".jpg"					;	Horário
			}
			else	{	;	temporário
				FileAppend,%	A_LoopFileFullPath "`n", D:\FTP\Monitoramento\FTP\Log\Erro De Split.txt
				FileDelete,%	A_LoopFileFullPath
				Return
			}
			FileMove,%	A_LoopFileFullPath,%	Motion novonome,	1
		}
	;	Limpa folders vazios
		Folder.Clear( Motion "Dahua" )
		Folder.Clear( Motion "Intelbras" )
		Folder.Clear( Motion "Foscam" )
return

distribuição:
	If( A_Hour < 6 && A_Hour > 0 )
		dia_ano	:=	A_YDay - 1
	else
		dia_ano	:=	A_YDay

	Loop, Files,% motion "*.jpg"
	{
		img	:= local := setor := ""
		;	Trata Exceções
			If( InStr( A_LoopFileName, "schedule" ) > 0 )	{
				FileDelete,%	A_LoopFileLongPath
				continue
			}
			else If( InStr( A_LoopFileName, "MOTION_DETECTION" ) > 0 )	{	;	Hikvision Settings
				StringSplit, imgx, A_LoopFileName,	_
				img	:=	imgx1 "_" SubStr( imgx3, 1, 8 ) "-" SubStr( imgx3, 9, 6 )
				StringSplit, img, img,	_
			}
			Else
				StringSplit, img, A_LoopFileName,	_
		;
		Gosub	verificaInibidos	;	Verifica se a câmera está inibida
		If( inibida = 1 )	{
			geradas.push( "('" img1 "',CONVERT(DateTime,'" cdii_hora "',120),'Inibido')" )
			continue
		}
		If( Array.InDict( cameras, img1 ) = 0 )	{			;	Se não constar no CADASTRO, gera log , move e vai pra próxima
			FileRead, sem_cadastro, D:\FTP\Monitoramento\FTP\Log\Sem cadastro - %dia_ano%.txt
			if( RegExMatch( sem_cadastro, img1 ) = 0 ) {	;	Se não consta registro, registra e move o arquivo
				FileAppend,%	img1 "`n", D:\FTP\Monitoramento\FTP\Log\Sem cadastro - %dia_ano%.txt
				FileMove,%	A_LoopFileFullPath,	D:\FTP\monitoramento\FTP\AddBD\%img1%.jpg
			}
			Else
				FileDelete,%	A_LoopFileFullPath
			continue
		}

		local		:=	cameras[ Array.InDict( cameras, img1 ) ].nome			;	Nome da Câmera
		setor		:=	"000" cameras[ Array.InDict( cameras, img1 ) ].operador	;	Operador 
			If( setor = "000" )	;	Se não estiver registrada para algum operador, define como operador 6
				setor = 0006

		data_e_hora	:=	SubStr( img2, 1, 15 )									;	Data e Horário
		op_sinistro	:=	"000" cameras[ Array.InDict( cameras, img1 ) ].sinistro	;	Operador quando em sinistro
			If( op_sinistro = "000" )
				op_sinistro=0006

		If( IS_TOOLTIP_ON = 1 )	;	DEBUG APENAS
			ToolTip,%	data_e_hora	"_" img1 "_" local "`nInibida:"	inibida
					.	"`n" datetime()
					.	"`n" setor
					.	"`n`tModo dia = " dia "`nImagens em log para inserção no BD(insere a cada 100)= " geradas.count(),	10, 10
		Else
			ToolTip

		If( dia != 1 )	{	;	tooltip
			If( SubStr( A_Now, 9 ) > "190500"	;	 Se fora da faixa de horário
			&&	SubStr( A_Now, 9 ) < "195500" ) {
				FileRead, faixa_de_horario, D:\FTP\Monitoramento\FTP\Log\Faixa de Horário Incorreta - %dia_ano%.txt
				if RegExMatch( faixa_de_horario, img1 ) = 0
					FileAppend,	%A_LoopFileName%`t-`t%img1%`n, D:\FTP\Monitoramento\FTP\Log\Faixa de Horário Incorreta - %dia_ano%.txt
			}
			Else {
				If( geradas.Count() >= 100	;	Se pronto para inserir
				||	comando_inserir = 1 )	{
					SetTimer,	prepara_imagens,	Off
					SetTimer,	distribuição,		Off
					For i, v in geradas
						If( i = geradas.count() )	;	Quando tiver 100 eventos
							insere_	.=	geradas[i]
						Else If( i = 1 )		;	No primeiro evento
							insere_	.=	"INSERT INTO  [MotionDetection].[dbo].[Geradas] (ip,horario,folder) VALUES " geradas[i]	",`n"
						Else	;	Durante os eventos
							insere_ .= geradas[i]	",`n"

					Try sql( insere_, 3 )
					If( debug = 1 )
						If( Strlen( sql_le ) > 0 )
							MsgBox % sql_le "`n`n" Clipboard := insere_
					insere_			=
					geradas			:=	[]
					comando_inserir	=	0
					SetTimer,	prepara_imagens,	On
					SetTimer,	distribuição,		On
				}
				Else	{
					img2x		:=	StrReplace( img2, "-" )
					cdii_hora	:=	SubStr( img2x, 1, 4 ) "-" SubStr( img2x, 5, 2 ) "-" SubStr( img2x, 7, 2 ) " " SubStr( img2x, 9, 2 ) ":" SubStr( img2x, 11, 2) ":" SubStr( img2x, 13, 2 )
					geradas.push( "('" img1 "',CONVERT(DateTime,'" cdii_hora "',120),'" setor "')" )
				}
			}
		}

		local	:=	StrRep(local,"+", "\+-", "/+-", "|+-", "<+-", ">+-", "*+-", ":+-", """+-", "?+-", "`n", "`r" )
		FileMove,%	A_LoopFileFullPath,	D:\FTP\monitoramento\FTP\%setor%\%data_e_hora%_%img1%_%local%_%op_sinistro%.jpg	;	Adicionado ultimo parametro
	}
return

verificaInibidos:
	anot	:=	SubStr( StrReplace( img2, "-" ), 1 ,4 )
	mest	:=	SubStr( StrReplace( img2, "-" ), 5 ,2 )
	diat	:=	SubStr( StrReplace( img2, "-" ), 7 ,2 )
	hort	:=	SubStr( StrReplace( img2, "-" ), 9 ,2 )
	mint	:=	SubStr( StrReplace( img2, "-" ), 11, 2 )
	segt	:=	SubStr( StrReplace( img2, "-" ), 13, 2 )
	time	:=	anot "/" mest "/" diat " " hort ":" mint ":" segt
	; MsgBox % time	;	ERRO REFERENTE A DATAS, VERIFICAR AQUI
	last_image	=	;	Atualiza quando foi a última imagem gerada
		(
			UPDATE
				[MotionDetection].[dbo].[Cameras]
			SET
				[last_md] = CONVERT( DATETIME, '%time%', 120 )
			WHERE
				[ip]	=	'%img1%'
		)
	; MsgBox % Clipboard:=last_image
	last_image	:=	Try sql( last_image, 3 )
	If( debug = 1 )
		If( Strlen( sql_le ) > 0 )	{
			MsgBox % sql_le "`n`n update" Clipboard:=last_image
			Pause
		}
	inibida	=	0
	i	=
		(
			SELECT
				[ip]
			FROM
				[MotionDetection].[dbo].[inibidos]
			WHERE
				[ip] = '%img1%'
			AND
				[restaurado] is null
		)
	ii	:=	sql( i, 3 )
	If( debug = 1 )
		If( Strlen( sql_le ) > 0 )
			MsgBox % sql_le "`n`n inibida?"
	If( ii.count() - 1 > = 1 )	{	;	 Se está inibida
		inibida		=	1
		img2		:=	StrReplace( StrReplace( img2, "-" ), ".jpg" )
		cdii_hora	:=	SubStr( img2, 1, 4 ) "-" SubStr( img2, 5, 2 ) "-" SubStr( img2, 7, 2 ) " " SubStr( img2, 9, 2 ) ":" SubStr( img2, 11, 2 ) ":" SubStr( img2, 13, 2 )
		If( A_Hour < 6 && A_Hour > 0 )
			dia_ano	:=	A_YDay - 1
		Else
			dia_ano	:=	A_YDay
		FileDelete,%	A_LoopFileFullPath
	}
	Else	;	Caso não esteja inibida
		inibida	=	0
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
		ToolTip,%	data_e_hora	"_" img1 "_" local "`nInibida:" inibida
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
		ToolTip,%		data_e_hora	"_" img1 "_" local "`nInibida:" inibida "`n"	datetime() "`n" setor "`n`tModo dia = " dia "`nImagens em log para inserção no BD(insere a cada 100)= " geradas.count(),	10, 10
		MsgBox,	,	Verificar Dia,	Ativado, 1
	}
	Else	{
		MsgBox,	,	Verificar Dia,	Desativado, 1
		If( IS_TOOLTIP_ON = 1 )
			ToolTip,%	data_e_hora	"_" img1 "_" local
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