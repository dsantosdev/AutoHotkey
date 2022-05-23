File_Version=0.0.0
Save_To_Sql=0

If	!A_Args
	ExitApp
;@Ahk2Exe-SetMainIcon C:\AHK\icones\pc.ico

;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\auth.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cameras.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\date.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\file.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\folder.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\sync_data.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

/*	Bancos de Dados utilizados

*/

;	Configurações
	; #NoTrayIcon
	split	:=	StrSplit( A_Args[1], "`n" )
	foscam	:= {}
	Loop,%	split.Count() {
		dados	:=	StrSplit( split[A_Index], "__" )
		if	dados[1]
			foscam[ dados[1] ]	:=	dados[2]
	}
	#SingleInstance, Force
	; #NoTrayIcon
	if A_IsCompiled
		ext	=	.exe
	Else
		ext =	.ahk
	if ( A_UserName = "dsantos" ) {
		motion_folder	=	\\srvftp\Monitoramento\FTP\Motion\
		FTP				=	\\srvftp\Monitoramento\FTP\
	}
	Else	{
		motion_folder	=	D:\FTP\monitoramento\FTP\Motion\
		FTP				=	D:\FTP\monitoramento\FTP\
	}
;	Code
	Loop {
		Debug( A_LineNumber, "Movendo Imagens" )
	;	Reseta Inibidos quando tempo expirado
		segundo_do_dia	:=	( A_Hour * 60 * 60 ) + ( A_Min * 60 ) + A_Sec	;	É inserido na tabela quando uma câmera é inibida	
		u		=
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
	;

	;	Foscam
		Loop, Files, %motion_folder%Foscam\*.jpg, R
		{
			p_foscam:=	StrSplit( A_LoopFileFullPath, "\" )
			mac		:=	SubStr( p_foscam[p_foscam.Count()-2],	instr( p_foscam[p_foscam.Count()-2], "_" ) + 1 )
			data	:=	SubStr( p_foscam[p_foscam.Count()],		InStr( p_foscam[p_foscam.Count()], "_" ) + 1 , 8 )
			hora	:=	SubStr( p_foscam[p_foscam.Count()],		InStr( p_foscam[p_foscam.Count()], "_" ) + 10, 6 )
			ip		:=	foscam[ mac ]
			If( StrLen( ip ) = 0 )	{	;	Gera log se a consulta não retornar nome de câmera
				FileAppend,%	SubStr( datetime(), 1, 10 ) " | Mac = " mac " | Data = " data " | Hora = " hora " | IP = " ip "`n", %FTP%Log\Não achou no DB.txt
				; MsgBox %motion_folder%%ip%_%data%-%hora%.jpg
				FileMove,%	A_LoopFileFullPath,	%FTP%AddBD\MAC - %mac% - %A_LoopFileName%
			}
			Else{
				; MsgBox %motion_folder%%ip%_%data%-%hora%.jpg
				FileMove,%	A_LoopFileFullPath, %motion_folder%%ip%_%data%-%hora%.jpg,	1
			}

		}
	;

	;	Dahua
		Loop, Files, %motion_folder%Dahua\*.jpg, R
		{
			path:=	StrSplit( A_LoopFileFullPath, "\" )
			If( path.Count() = 10 )	{
				horario	:=	StrRep( SubStr( A_LoopFileName, 1, instr( A_LoopFileName, "[" )-1 ), , "." )
				ip		:=	StrReplace( path[7], "_", "." )
				novonome:=	ip "_" StrReplace( path[8], "-" ) "-" horario ".jpg"
			}
			Else If( path.Count() = 12 )	{
				tempo	:=	StrSplit( SubStr( A_LoopFileName, 1, InStr( A_LoopFileName, "[" )-1 ), "." )
				horario	:=	tempo[1] tempo[2]
				ip		:=	StrReplace( path[7], "_", "." )
				novonome:=	ip "_" StrReplace( path[8], "-" ) "-" path[11] horario ".jpg"
			}
			Else If( path.Count() = 14 )	{	;	
				segundos:=	SubStr( A_LoopFileName, 1, InStr( A_LoopFileName, "[" ) - 1 )
				ip		:=	StrReplace( path[8], "_", "." )
				novonome:=	ip "_" StrReplace( path[9], "-" ) "-" path[12] path[13] segundos ".jpg"
			}
			Else	{
				segundos:=	SubStr( A_LoopFileName, 1, InStr( A_LoopFileName, "[" ) - 1 )
				ip		:=	StrReplace( path[7], "_", "." )
				novonome:=	ip "_" StrReplace( path[8], "-" ) "-" path[11] path[12] segundos ".jpg"
			}
			FileMove,%	A_LoopFileFullPath,%	motion_folder novonome,	1
		}
	;

	;	Intelbras
		Loop, Files, %motion_folder%Intelbras\*.jpg, R
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
				FileAppend,%	A_LoopFileFullPath "`n", %FTP%Log\Erro De Split.txt
				FileDelete,%	A_LoopFileFullPath
				Return
			}
			FileMove,%	A_LoopFileFullPath,%	Motion novonome,	1
		}
	;

	;	Limpa folders vazios
		Folder.Clear( motion_folder "Dahua" )
		Folder.Clear( motion_folder "Intelbras" )
		Folder.Clear( motion_folder "Foscam" )
	;
	}
