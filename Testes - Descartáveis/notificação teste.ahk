/*
	* * * Compile_AHK SETTINGS BEGIN * * *
	[AHK2EXE]
		Exe_File=C:\users\dsantos\desktop\executáveis\notificação teste.exe
		Created_Date=1
	[VERSION]
		Set_Version_Info=1
		Company_Name=Heimdall
		File_Description=
		File_Version=0.0.0.1
		Inc_File_Version=1
		Product_Name=notificação teste
		Product_Version=1.1.33.2
		Set_AHK_Version=1
	* * * Compile_AHK SETTINGS END * * *
*/

;	Includes
	;#Include ..\class\array.ahk
	;#Include ..\class\base64.ahk
	;#Include ..\class\convert.ahk
	;#Include ..\class\cor.ahk
	;#Include ..\class\dguard.ahk
	#Include ..\class\functions.ahk
	;#Include ..\class\gui.ahk
	;#Include ..\class\mail.ahk
	;#Include ..\class\safedata.ahk
	#Include ..\class\sql.ahk
	;#Include ..\class\string.ahk
	;#Include ..\class\windows.ahk
;

;	-Arrays
	
;

;	-Configurações
	
;

;	-Variáveis
	
;

;	-Login
	
;

;	-Interface
	
;

;	-GuiClose
	
;

F1::
	SetTimer, teste, 1000
Return

teste:
	email_notify()
Return

email_notify()	{
	Global last_id
	s =
		(
		SELECT TOP(1)
			 p.[Mensagem]
			,p.[operador]
			,c.[Nome]
			,p.[pkid]
		FROM
			[ASM].[dbo].[_Agenda] p
		LEFT JOIN
			[Iris].[IrisSQL].[dbo].[Clientes] c
		ON
			p.[id_cliente] = c.[IdUnico]
		ORDER BY
			4
		DESC
		)
		email := sql( s , 3 )
	If ( StrLen( last_id ) = 0 ) {
		OutputDebug % "Last_ID = 0"
		last_id := email[2,4]
		return	last_id
	}
	Else if ( last_id < email[2,4] ) {
		OutputDebug	% "Novo e-mail"
		operador	:= email[2,2]
		id_aviso	:= email[2,4]
		last_id		:= email[2,4]
		SoundPlay,	\\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\car.wav
		TrayTip,%	email[2,3] "`nNOVO E-MAIL - " datetime(), % email[2,1]
	}
	if ( last_id > email[2,4] )	{
		OutputDebug % "Maior que o identificador"
		last_id := email[2,4]
	}
		OutputDebug % "id igual"
	return	last_id
}