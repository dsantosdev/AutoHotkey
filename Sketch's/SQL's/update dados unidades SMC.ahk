/*
	* * * Compile_AHK SETTINGS BEGIN * * *
	[AHK2EXE]
		Exe_File=C:\users\dsantos\desktop\executáveis\update dados unidades SMC.exe
		Created_Date=1
	[VERSION]
		Set_Version_Info=1
		Company_Name=Heimdall
		File_Description=
		File_Version=0.0.0.1
		Inc_File_Version=1
		Product_Name=update dados unidades SMC
		Product_Version=1.1.33.2
		Set_AHK_Version=1
	* * * Compile_AHK SETTINGS END * * *
*/


;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safedata.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

;	Arrays
;

;	Configurações
	; #NoTrayIcon
	#SingleInstance, Force

	show_tooltip	:=	A_Args[1]	;	recebe o argumento 1 para exibir
		if ( A_UserName = "dsantos" )
			show_tooltip = 1
		CoordMode, ToolTip, Screen

	if ( A_IsCompiled = 1 )
		ext	=	exe
	Else
		ext = ahk

;

;	Variáveis
;

;	Login
;

;	Interface
;

;	Code
	select_data =
	(
		SELECT
			dn_local,
			matr_gerente,
			matr_adm,
			matr_oper,
			cd_estab
		FROM
			v_email_unidades
	)
	select_data	:=	sql( select_data , 2 )
	Loop,% select_data.Count()
		values	.=	"('"	select_data[A_Index+1 , 1] "',`n"
				.	"'"		select_data[A_Index+1 , 2] "',`n"
				.	"'"		select_data[A_Index+1 , 3] "',`n"
				.	"'"		select_data[A_Index+1 , 4] "',`n"
				.	"'"		select_data[A_Index+1 , 5] "'),"
	values	:=	SubStr( values , 1, -1 )
	insert_data =
	(
		INSERT INTO [SMC].[dbo].[unidades]
			([nome]
			,[matricula_gerente]
			,[matricula_administrativo]
			,[matricula_operacional]
			,[estabelecimento]	)
    	VALUES
	 		%values%
	)
	Clipboard := insert_data
	insert_data := sql( insert_data , 3 )
	MsgBox	%	sql_le
;

;	GuiClose
;
