File_Version=0.0.0
Save_To_Sql=0
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
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\folder.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\sync_data.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

/*	Bancos de Dados utilizados

*/

#SingleInstance, Force

s	=
	(
		SELECT
			 [nome]			--1
			,[matricula]	--2
			,[cargo]		--3
			,[email]		--4
			,[telefone1]	--5
			,[telefone2]	--6
			,[c_custo]		--7
			,[local]		--8
			,[setor]		--9
		FROM [ASM].[dbo].[_colaboradores]
		WHERE sexo = 'f'
		AND (Len(telefone1) > 1
		OR Len(telefone2) > 1)
	)
 c := sql( s, 3 )
Sleep, 500
Loop,% c.Count()-1	{
	ToolTip % a_index - c.Count()
	; MsgBox % clipboard :=	"-" c[A_index+1, 1] "-`n"
	; 		.	"-" c[A_index+1, 2] "-`n"
	; 		.	"-" c[A_index+1, 3] "-`n"
	; 		.	"-" c[A_index+1, 4] "-`n"
	; 		.	"-" c[A_index+1, 5] "-`n"
	; 		.	"-" c[A_index+1, 6] "-`n"
	; 		.	"-" c[A_index+1, 7] "-`n"
	; 		.	"-" c[A_index+1, 8] "-`n"
	; 		.	"-" c[A_index+1, 9] "-"
	a	:=	c[A_index+1, 8]	= "varejo"
							? c[A_index+1, 7] 
							: c[A_index+1, 8]	=	c[A_index+1, 7]
												?	c[A_index+1, 8]
							: c[A_index+1, 8] " - " c[A_index+1, 9]

	contact	:= "`n"	a " | " c[A_index+1, 1]
			.	","	a
			.	","	c[A_index+1, 1]
			.	","	c[A_index+1, 2]
			.	",* Contatos Cotrijal"
			.	","
			.	","	c[A_index+1, 5] "`:`:`:"	c[A_index+1, 6]
			.	","	c[A_index+1, 3]
			.	",`* "
			.	","	c[A_index+1, 4]
		; MsgBox % StrReplace( contact, ",", "`n" )
	FileAppend,% contact, contacts.csv
	if ErrorLevel
		MsgBox % StrReplace( contact, ",", "`n" )
}
