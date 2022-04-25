/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\users\dsantos\desktop\executáveis\notificador_telegram.exe
Created_Date=1
Run_After="C:\Users\dsantos\Desktop\Executáveis\AHK2BD.exe "notificador_telegram" "0.0.0.4" """
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Version=0.0.0.4
Inc_File_Version=1
Product_Name=notificador_telegram
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\AHK\icones\telegram.ico

* * * Compile_AHK SETTINGS END * * *
*/

;@Ahk2Exe-SetMainIcon C:\AHK\icones\telegram.ico

;	Includes
	;#Include ..\class\alarm.ahk
	;#Include ..\class\array.ahk
	;#Include ..\class\base64.ahk
	;#Include ..\class\convert.ahk
	;#Include ..\class\cor.ahk
	;#Include ..\class\dguard.ahk
	#Include ..\class\functions.ahk
	;#Include ..\class\gui.ahk
	;#Include ..\class\listview.ahk
	;#Include ..\class\mail.ahk
	;#Include ..\class\safedata.ahk
	#Include ..\class\sql.ahk
	;#Include ..\class\string.ahk
	#Include ..\class\telegram.ahk
	;#Include ..\class\windows.ahk
;

;	Configurações
	if ( A_Args[1] = "" )	;	Sem mensagem
		ExitApp
	#NoTrayIcon
	#SingleInstance, Ignore
;

;	Variáveis
	if ( A_Args[3] = "" )	;	Terceiro argumento vazio = envia para o chat principal
		chat_id	= -1001160086708	;	id do canal
	Else					;	Terceiro argumento com qualquer valor, envia para o canal de teste
		chat_id	= -1001729068003	;	id do canal de teste
	; chat_id	= -1001729068003	;	id do canal de teste
;

;	Code
	telegram.SendMessage( A_Args[1] , A_Args[2] )
;
