/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\users\dsantos\desktop\executáveis\AHK2BD.exe
Created_Date=1
Run_After="C:\Users\dsantos\Desktop\Executáveis\AHK2BD.exe "AHK2BD" "0.0.0.2" "Conversor de executável para b64 e b64 to executável""
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Description=Conversor de executável para b64 e b64 to executável
File_Version=0.0.0.3
Inc_File_Version=1
Internal_Name=Kah's Converter
Legal_Copyright=WTFL
Product_Name=AHK2BD
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\Dih\zico\compiler.ico

* * * Compile_AHK SETTINGS END * * *
*/
;@Ahk2Exe-SetMainIcon C:\Dih\zico\compiler.ico
;	Bibliotecas
	#SingleInstance Force
	#Persistent
	#Include ..\class\sql.ahk
	#Include ..\class\base64.ahk
;

;	Variáveis
	sistema := A_Args[1]
	version	:= A_Args[2]
	obs		:= A_Args[3]
;

;	b64 -> SQL
	if (sistema = ""
	&&	version = ""
	&&	obs = "" ) {
		MsgBox , , , Nenhuma informação recebida`, encerrando aplicação!, 3
		ExitApp
	}
	b64 := Base64.FileEnc( "C:\users\dsantos\desktop\executáveis\" sistema ".exe" )
	if ( StrLen( b64 ) = 0 ) {
		MsgBox , , , base64 nula!
		ExitApp
	}

	i	=
		(
		INSERT INTO
			[ASM].[dbo].[Softwares]
			([name]
			,[bin]
			,[version]
			,[obs])
		VALUES
			('%sistema%'
			,'%b64%'
			,'%version%'
			,'%obs%')
		)
	sql( i, 3 )
	if ( sql_le <> "" )
		MsgBox % sql_le
	Else
		MsgBox, , ,Executável gravado na base de dados com sucesso! , 1
;

;	Decode example
	; s =
	; 	(
	; 	SELECT	TOP 1
	; 				name
	; 				,bin
	; 				,version
	; 				,obs
	; 	FROM
	; 		[ASM].[dbo].[Softwares]
	; 	where [name] = 'Relatórios'
	; 	)
	; bins := sql( s, 3 )
	; MsgBox %  bins.Count()-1 "`n" bins[2,3]
	; Base64.FileDec( bins[2, 2] , "C:\Users\dsantos\Desktop\" bins[2, 1] ".exe" )
;
ExitApp
