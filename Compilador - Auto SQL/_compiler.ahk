File_Version=0.0.0.1
save_to_sql=0
;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\auth.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cameras.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\date.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\file.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\folder.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

/*	Bancos de Dados Utilizados
	[ASM].[dbo].[softwares]			-	Utilizado para salvar os programas em base64
	[ASM].[dbo].[software_config]	-	Utilizado para verificar as configuraçõees que devem ser utilizados por este executável
*/

FileSelectFile,	file_ahk
if !file_ahk
	ExitApp
;	Configurações
	#SingleInstance, Force
	if A_IsCompiled
		ext		= exe
		Else
			ext = ahk
;

;	File
	path	:=	StrSplit( file_ahk, "\" )
	Loop,%	path.Count()
		If ( A_Index = path.Count() ) {
			file_exe	.=	file_name := SubStr( path[A_Index], 1, -4 ) ".exe"
			Break
		}
		Else
			file_exe	.=	path[A_Index] "\"
	file_name	:=	StrRep( file_name,,".exe" )
;

;	Version
	FileReadLine,	version,%		file_ahk, 1
	FileReadLine,	save_to_sql,%	file_ahk, 2
	If !version
		version 	=	0.0.0.0
	version_in_file	:=	StrSplit( StrRep( version,, "File_Version=" ), "." )
	save_to_sql		:=	StrRep( save_to_sql,, "Save_To_Sql=" )

	;	update version	-	IN DEVELOPMENT
		; s	=
			; (
				; SELECT	[vars]
				; FROM	[ASM].[dbo].[software_config]
				; WHERE	[software] = '%file_name%'
			; )
		; pre_config	:=	sql( s, 3 )
		; config		:=	StrSplit( pre_config[2,1], ";" )
			; Loop,%	config.Count()
			; If InStr( config[A_index], "current_version" )
				; version_in_db	:=	StrSplit( StrRep( config[A_index],, "current_version="), "." )
		; If version_in_db[4]	> version_in_file[4]
		; If version_in_db[3]	> version_in_file[3]
		; If version_in_db[2]	> version_in_file[2]
		; If version_in_db[1]	> version_in_file[1]

	file_new_version :=	version_in_file[1] "." version_in_file[2] "." version_in_file[3] "." version_in_file[4]+1
;

;	CMD
	ahk2exe	=	"C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\Ahk2Exe.exe"
	in		=	/in "%file_ahk%"
	out		=	/out "%file_exe%"
	; log	= 	>> "C:\users\dsantos\desktop\execuátveis\Compile_AHK.log"	;	se quiser gerar arquivo de log
;

;	Code
	RunWait, %comspec% /c "%ahk2exe% %in% %out%", , UseErrorLevel Hide
	Sleep, 1000
	FileGetTime, time,%	file_exe

	If (A_Now - time < 300
	&&	save_to_sql	=	1	)	{	;	se o arquivo novo foi criado a menos de 5 minutos
		file_b64		:=	base64.FileEnc( file_exe )
		file_new_date	:=	datetime( 1, time )
		insert_new_exe	=
			(
				INSERT INTO
					[ASM].[dbo].[softwares]
					(name,bin,version,date)
				VALUES
					('%file_name%','%file_b64%','%file_new_version%','%file_new_date%')
			)
		sql( insert_new_exe, 3 )
	}
	MsgBox
	FileMove,% file_exe, C:\Users\dsantos\Desktop\Executáveis\%file_name% %file_new_version%.exe, 1
;
ExitApp
