/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\users\dsantos\desktop\executáveis\AHK2BD.exe
Created_Date=1
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Description=Compilador com armazenamento em base de dados SQL.
File_Version=0.0.0.6
Inc_File_Version=1
Internal_Name=Kah's Compiler
Legal_Copyright=WTFL
Original_Filename=Compiler_AHK
Product_Name=Kah's Compiler
Product_Version=1.1.33.2
Set_AHK_Version=1

* * * Compile_AHK SETTINGS END * * *
*/

; #IfWinActive, Login Cotrijal
	#SingleInstance Force
	#Persistent
	#Include ..\class\sql.ahk
	#Include ..\class\functions.ahk
; sistema := A_Args[1]
; version	:= A_Args[2]
; obs		:= A_Args[3]
; b64 := b64_file_enc( "C:\users\dsantos\desktop\executáveis\" sistema ".exe" )
; MsgBox % b64
; i	=
; 	(
; 		INSERT INTO
; 			[ASM].[dbo].[Softwares]
; 			([name],[bin],[version],[obs])
; 		VALUES
; 			('%sistema%','%b64%','%version%','%obs%')

; 	)
; sql( i, 3 )
s =
	(
	SELECT	TOP 1
				 name
				,bin
				,version
				,obs
	FROM
		[ASM].[dbo].[Softwares]
	where [name] = 'Relatórios'
	)
bins := sql( s, 3 )
MsgBox %  bins.Count()-1 "`n" bins[2,3]
b64_file_dec(bins[2, 2], "C:\Users\dsantos\Desktop\" bins[2, 1] ".exe")

MsgBox,,, Done!,1
ExitApp
