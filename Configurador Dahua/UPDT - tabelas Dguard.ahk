/*
	* * * Compile_AHK SETTINGS BEGIN * * *
	[AHK2EXE]
		Exe_File=C:\users\dsantos\desktop\executáveis\UPDT - tabelas Dguard.exe
		Created_Date=1
	[VERSION]
		Set_Version_Info=1
		Company_Name=Heimdall
		File_Description=
		File_Version=0.0.0.1
		Inc_File_Version=1
		Product_Name=UPDT - tabelas Dguard
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
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
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

;	-Arrays
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

;	-Variáveis
;

;	-Login
;

;	-Interface
;

;	Code
	token	:= dguard.token( "vdm01" )
	v		:=	json( dguard.http( "http://192.9.100.181:8081/api/vendors" , token ) )
	Loop,%	v.vendors.Count()	{
		name := v.vendors[A_index].name
		guid := v.vendors[A_index].guid

		i	=
			(
				IF NOT EXISTS (SELECT * FROM [Dguard].[dbo].[vendors] WHERE [guid] = '%guid%')
				BEGIN
					INSERT INTO [Dguard].[dbo].[vendors]( name, guid )
					VALUES( '%name%' , '%guid%' )
				END
			)
			sql( i , 3 )
			if strlen( sql_le )
				MsgBox % sql_le "`n" Clipboard := sql_lq
			m	:=	json( dguard.http( "http://192.9.100.181:8081/api/vendors/%7B" StrRep( guid , "{", "}", "%7D/models:" token ) ) )
			Loop,%	m.models.Count()	{
				mname	:= m.models[A_index].name
				mguid	:= m.models[A_index].guid
				mvguid	:= m.models[A_index].vendorguid

				i	=
					(
						IF NOT EXISTS (SELECT * FROM [Dguard].[dbo].[models] WHERE [guid] = '%mguid%')
						BEGIN
							INSERT INTO [Dguard].[dbo].[models]( name, guid, vendorguid )
							VALUES( '%mname%' , '%mguid%' , '%mvguid%' )
						END
					)
					sql( i , 3 )
					if strlen( sql_le )
						MsgBox % sql_le "`n" Clipboard := sql_lq
			}
	}
	
MsgBox FINALIZADO

;

;	-GuiClose
	;
;
