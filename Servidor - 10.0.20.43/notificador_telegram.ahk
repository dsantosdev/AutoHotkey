
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
	;#Include ..\class\safe_data.ahk
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
