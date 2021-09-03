
; #IfWinActive, Login Cotrijal
	#SingleInstance Force
	#Persistent
	#Include ..\class\sql.ahk
	#Include ..\class\functions.ahk
	; #Include ..\class\windows.ahk
	; #Include ..\class\array.ahk
	; #Include ..\class\gui.ahk
	; #Include ..\class\safedata.ahk

b64 := b64_file_enc( "C:\Dguard Advanced\ddguard player.exe" )
version = 2.7.3
obs = teste inicial
sistema = Sistema Monitoramento
i	=
	(
		INSERT INTO
			[ASM].[dbo].[Softwares]
			([name],[bin],[version],[obs])
		VALUES
			('%sistema%','%b64%','%version%','%obs%')

	)
sql( i, 3 )
; MsgBox % Clipboard:=b64
; s =
	(
		SELECT	TOP 1
					 name
					,bin
					,version
					,obs
		FROM
			[ASM].[dbo].[Softwares]
		where [name] = 'Sistema Monitoramento'
	)
bins := sql( s, 3 )
MsgBox %  bins.Count()-1 "`n" bins[2,3]
b64_file_dec(b64, "C:\Users\dsantos\Desktop\teste.exe")
ExitApp
