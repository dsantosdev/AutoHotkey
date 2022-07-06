File_Version=0.3.0
Save_To_Sql=1
FileEncoding, UTF-8
; 04-07-2022

;@Ahk2Exe-SetMainIcon C:\AHK\icones\pc.ico

;	Includes
	#Include md_libs.ahk
	OnMessage(0x004A, "wm_read")
	version := sql_version()
	Menu, Tray, Tip ,% "Versão atual do Preparador de Imagens: " version[1] "`nCompilação: " version[2]
;

/*	Bancos de Dados utilizados
	[Dguard].[dbo].[cameras]
	[Dguard].[dbo].[cameras_mac]
	[MotionDetection].[dbo].[inibidos]
*/

;	Configurações
	folders = intelbras,dahua,foscam,Motion
	Gosub, pre_load_foscam

	#SingleInstance, Force
	; #NoTrayIcon
	if( A_IsCompiled )
		ext	=	.exe

	Else
		ext =	.ahk
	if ( A_UserName = "dsantos" ) {
		isnt_server		=	1
		motion_folder	=	\\srvftp\Monitoramento\FTP\Motion\
		FTP				=	\\srvftp\Monitoramento\FTP\
	}
	Else	{
		isnt_server		=	0
		motion_folder	=	D:\FTP\monitoramento\FTP\Motion\
		FTP				=	D:\FTP\monitoramento\FTP\
	}
;	Code
	Loop {
		If	ShowData
			Gosub, Show_Version
		If((A_Hour = 19 && A_Min = 00 )
		&&	(A_Sec > 00 && A_Sec < 05) )
			Gosub, pre_load_foscam
		Sleep, 1000
		Gosub, reseta_inibidos

	;	Main Folder

		OutputDebug, % A_now "`tMain " 

		Loop, Files,%	motion_folder "*.*", FDR
		{
			If( A_LoopFileName = "IPCWorkDirectory" )
				FileDelete,% A_LoopFileFullPath
			else If( A_LoopFileName = "DVRWorkDirectory" )
				FileDelete,% A_LoopFileFullPath
			If InStr( folders, SubStr( A_LoopFileDir, InStr( A_LoopFileDir, "\", , -1)+1 ) )
				Continue

			FileMove,% A_LoopFileFullPath,%	motion_folder StrRep( A_LoopFileName,, " " ), 1

			OutputDebug, % current_folder "`t" StrRep( A_LoopFileName,, " " ) ;"`n`t" A_LoopFileFullPath

			last_folder	:= SubStr( A_LoopFileDir, InStr( A_LoopFileDir, "\", , -1)+1 )
			if( current_folder != last_folder )
				folder.Clear( A_LoopFileDir )

			current_folder	:=	SubStr( A_LoopFileDir, InStr( A_LoopFileDir, "\", , -1)+1 )

		}

	;

	;	Foscam

		OutputDebug, % A_Now "`tFoscam"

		Loop, Files, %motion_folder%Foscam\*.jpg, R
		{

			p_foscam:=	StrSplit( A_LoopFileFullPath, "\" )
			mac		:=	SubStr( p_foscam[p_foscam.Count()-2],	instr( p_foscam[p_foscam.Count()-2], "_" )	+ 1 )
			data	:=	SubStr( p_foscam[p_foscam.Count()],		InStr( p_foscam[p_foscam.Count()], "_" )	+ 1 , 8 )
			hora	:=	SubStr( p_foscam[p_foscam.Count()],		InStr( p_foscam[p_foscam.Count()], "_" )	+ 10, 6 )
			ip		:=	foscam[ mac ]
			If( StrLen( ip ) = 0 )
				FileMove,%	A_LoopFileFullPath,	%FTP%AddBD\MAC - %mac% - %A_LoopFileName%

			Else
				FileMove,%	A_LoopFileFullPath, %motion_folder%%ip%_%data%-%hora%.jpg,	1

		}
		Folder.Clear( motion_folder "Foscam" )
	;

	;	Dahua

		OutputDebug, % A_Now "`tDahua"

		Loop, Files, %motion_folder%Dahua\*.jpg, R
		{
			new_file	:=	InStr( A_LoopFileFullPath, "[" ) > 0 ? SuBStr( A_LoopFileFullPath, 1, (isnt_server = 1 ? -16 : -15) ) : A_LoopFileFullPath

			if ( last_file = new_file ) {

				FileDelete,% A_LoopFileFullPath
				continue

			}

			horario :=	novonome := is_path := ""
			path	:=	StrSplit( A_LoopFileFullPath, "\" )

			If( path.Count() = (isnt_server = 1 ? 11 : 10) )	{
				novonome:=	StrRep( (isnt_server = 1 ? path[8] : path[7]),, "_:."	) "_"
						.	StrRep( (isnt_server = 1 ? path[9] : path[8]),, "-"		) "-"
						.	horario := StrRep( (isnt_server = 1 ? path[11] : path[10]),, ".", "_", "/", "jpg") ".jpg"
			}

			Else {
				Loop,% path.Count() {

					If ( A_Index < 10 )
						Continue
					Else If(InStr( path[A_Index], "[" ) > 0
						&&	InStr( path[A_Index], "[" ) != ""  ) {
						is_path := SubStr( path[A_Index], 1, InStr( path[A_Index], "[" )-1 )
					}
					Else
						is_path := path[A_Index]
					horario .= StrRep( is_path, , "/", ".", "_", "jpg" )

				}
				novonome:=	StrRep( (isnt_server = 1 ? path[8] : path[7])	,, "_:." ) "_" StrReplace( (isnt_server = 1 ? path[9] : path[8]), "-" ) "-" horario ".jpg"

			}

			if ( last_hour = horario)
				continue

			last_file:=	new_file
			last_hour:= horario

			OutputDebug % novonome
			; if instr( novonome, "[" )
				; MsgBox
			FileMove,%	A_LoopFileFullPath,%	motion_folder novonome,	1

		}
		Folder.Clear( motion_folder "Dahua" )
	;

	;	Intelbras

		OutputDebug, % A_Now "`tIntelbras"

		Loop, Files, %motion_folder%Intelbras\*.jpg, R
		{
			new_file	:=	InStr( A_LoopFileFullPath, "[" ) > 0 ? SuBStr( A_LoopFileFullPath, 1, (isnt_server = 1 ? -16 : -15) ) : A_LoopFileFullPath
			if ( last_file = new_file ) {

				FileDelete,% A_LoopFileFullPath
				continue

			}

			horario := novonome := is_path := ""
			path:=	StrSplit( A_LoopFileFullPath, "\" )
			If( path.Count() = 11 ) {	;	MUDAR TODAS POR API, AQUI VIRA 10 e NOS PATH DIMINUI 1
				If(InStr( path[11], "[" ) > 0
				&&	InStr( path[11], "[" ) != ""  )	{
						path[11] := SubStr( path[11], 1, InStr( path[11], "[" )-1 )
					; Msgbox	%	path[11]
				}
				; Msgbox	%	StrRep( path[11],, ".",	"/", "_", "jpg" )
				novonome:=	StrRep( path[8],, "_:." ) "_"
						.	StrRep( path[9],, "-" ) "-"
						.	horario := StrRep( path[11],, ".", "/", "_", "jpg" )
						.	".jpg"
			}
			Else {
				Loop,% path.Count() {
					If ( A_Index < 11 )
						Continue
					Else If(InStr( path[A_Index], "[" ) > 0
						&&	InStr( path[A_Index], "[" ) != ""  ) {
						is_path := SubStr( path[A_Index], 1, InStr( path[A_Index], "[" )-1 )
					}
					Else
						is_path := path[A_Index]
					horario .= StrRep( is_path, , "/", ".", "_", "jpg" )
				
					novonome:=	StrRep( path[8],, "_:." ) "_"
							.	StrReplace( path[9], "-" ) "-"
							.	horario ".jpg"
				}

			}
			if ( last_hour = horario)
				continue

			last_file:=	new_file
			last_hour:= horario
			OutputDebug, % novonome
			FileMove,%	A_LoopFileFullPath,%	motion_folder novonome,	1

		}
		Folder.Clear( motion_folder "Intelbras" )
	;

	}
Return

pre_load_foscam:
	OutputDebug, % A_Now "`t SQL"
	s	=
		(
			SELECT
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
				c.[ip] = m.[ip]
			WHERE
				LEFT( c.[vendormodel], charindex(' ', c.[vendormodel]) - 1) = 'Foscam'
		)
		s	:=	sql( s, 3 )
		foscam := {}
	IF( ( s.Count()-1 ) > 1 )
		Loop,%	s.Count()-1
			foscam[s[A_Index+1,2]]	:=	s[A_Index+1,1]

	Else
		mail.new(	"dsantos@cotrijal.com.br"
				,	"Falha Servidor de Detecções - " Substr( datetime(), 1, 10 )
				,	"Busca SQL não retornou nenhuma câmera para montar o array de consulta`n`t`tPreparaImagens" )
	Sleep, 4000
Return

reseta_inibidos:
	segundo_do_dia	:=	( A_Hour * 60 * 60 ) + ( A_Min * 60 ) + A_Sec	;	É inserido na tabela quando uma câmera é inibida	
	u	=
		(
			UPDATE
				[MotionDetection].[dbo].[inibidos]
			SET
				 [restaurado]	=	GETDATE()
				,[geradas]		=	''
			WHERE
				[encerraDia]	<=	'%A_YDay%'
			AND
				[encerraHorario]<=	'%segundo_do_dia%'
			AND
				[restaurado] IS NULL
		)
	sql( u, 3 )
Return

Show_version:
	Menu, Tray, Tip ,% "Versão atual do Preparador de Imagens: " version[1] "`nCompilação: " version[2]
	ShowData = 0
Return