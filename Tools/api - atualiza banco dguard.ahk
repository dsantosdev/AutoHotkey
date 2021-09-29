/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=%In_Dir%\Câmeras Cadastradas.exe
Created_Date=1
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Description=Atualizador de dados das câmeras no banco de dados
File_Version=1.0.0.2
Inc_File_Version=1
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\Dih\zIco\fun\conceitto.ico

* * * Compile_AHK SETTINGS END * * *
*/

inicio	:=	A_Now
;@Ahk2Exe-SetMainIcon	C:\Dih\zIco\fun\conceitto.ico
	#Persistent
	#SingleInstance Force
	#Include ..\class\array.ahk
	; #Include ..\class\cor.ahk
	#Include ..\class\dguard.ahk
	#Include ..\class\functions.ahk
	; #Include ..\class\gui.ahk
	; #Include ..\class\mail.ahk
	; #Include ..\class\safedata.ahk
	#Include ..\class\string.ahk
	#Include ..\class\sql.ahk
	; #Include ..\class\windows.ahk
;

;	Definições
	global	debug = 
		,	info_das_cameras := {}
;

;	Tokens dos servidores
	token_1 := Dguard.token( "vdm01" )
		OutputDebug % StrLen( token_1 ) > 0 ? "-Obtido token 1`n`t" token_1 	: "Falha ao obter token 1"
	token_2 := Dguard.token( "vdm02" )
		OutputDebug % StrLen( token_2 ) > 0 ? "-Obtido token 2`n`t" token_2		: "Falha ao obter token 2"
	token_3 := Dguard.token( "vdm03" )
		OutputDebug % StrLen( token_3 ) > 0 ? "-Obtido token 3`n`t" token_3 "`n" : "Falha ao obter token 3`n"
;

;	Informações das câmeras contidas no d-guard
		OutputDebug % "-Armazenando os dados das câmeras do dguard em array."
	dados_das_cameras_no_dguard := {}

	json_return := json( Dguard.http( "http://vdm01:8081/api/servers", token_1 ) )
		ToolTip,% "-Armazenando os dados das câmeras do servidor 1 do dguard em array.`nDados restantes = " json_return.servers.Count() "`nTotal de câmeras = " dados_das_cameras_no_dguard.Count(), 50 , 50
		Loop,% json_return.servers.Count()	{
			OutputDebug % qwer
			_guid := StrReplace( StrReplace( json_return.servers[A_Index].guid , "{") , "}" )
			receiver := json( http( "http://vdm01:8081/api/servers/%7B" _guid "%7D/contact-id" , "Bearer " token_1 ) )
			json_camera := Dguard.Server( "vdm01" , _guid , token_1 )
			dados_das_cameras_no_dguard.Push({	name		:	json_camera.server.name
											,	guid		:	_guid
											,	active		:	json_camera.server.active
											,	connected	:	json_camera.server.connected
											,	address		:	json_camera.server.address
											,	port		:	json_camera.server.port
											,	vendor		:	json_camera.server.vendorModelName
											; ,	vendor		:	SubStr( json_camera.server.vendorModelName , 1 , InStr( json_camera.server.vendorModelName , " ")-1 )
											,	contactid	:	json_camera.server.contactIdCode
											,	offline		:	json_camera.server.offlineSince
											,	setor		:	SubStr( json_camera.server.notes , 1 , 1 )
											,	sinistro	:	SubStr( json_camera.server.notes , 2 , 1 )
											,	url			:	StrReplace( json_camera.server.url , "\" )
											,	receiver	:	receiver.contactId.receiver
											,	partition	:	receiver.contactId.partition	})
			if ( receiver.contactId.receiver != "10001" )
				api_get	:=	"http://conceitto:cjal2021@vdm01.cotrijal.local:85/camera.cgi?receiver=" receiver.contactId.receiver "&server=" json_camera.server.contactIdCode "&camera=0&resolucao=640x480&qualidade=100"
			Else
				api_get = 
			; comando	= "http://SERVIDOR:8081/api/servers/`%7B%_guid%`%7D/contact-id" -H "accept: application/json" -H "Authorization: bearer %token_1% " -H "Content-Type: application/json" -d "{ \"receiver\": 10001, \"account\": \"0000\", \"partition\": \"00\"}"
			; OutputDebug % Dguard.curl( comando , "vdm01" , "PUT"  ) "`n`t" json_camera.server.name
			ID			:=	StrSplit( json_camera.server.address , "." )
			date_off	:=	json_camera.server.offlineSince
			offline		:=	date_off = "-"
									? "NULL"
									: "CAST('" SubStr( date_off , 7 , 4 ) "-" SubStr( date_off , 4 , 2 ) "-" SubStr( date_off , 1 , 2 ) " " SubStr( date_off , 12 ) "' as datetime)"
			active		:=	json_camera.server.active = "true"
													? "1"
													: "0"
			connected	:=	json_camera.server.connected = "true"
														 ? "1"
														 : "0"
			url			:=	StrLen( json_camera.server.url )	= 0
																? "http://" json_camera.server.address ":80"
																: json_camera.server.url
			output		.=	"(	'" json_camera.server.name
							.	"','" StrReplace( StrReplace( json_camera.server.guid, "{") , "}" )
							.	"','" active
							.	"','" connected
							.	"','" json_camera.server.address
							.	"','" json_camera.server.port
							.	"','" json_camera.server.vendorModelName
							.	"','" json_camera.server.contactIdCode
							.	"',"  offline
							.	",'"  SubStr( json_camera.server.notes , 1 , 1 )
							.	"','" SubStr( json_camera.server.notes , 2 , 1 )
							.	"','" url
							.	"','1'"
							.	",'" api_get
							.	"','" receiver.contactId.receiver
							.	"','" receiver.contactId.partition
							.	"','" id[3] "'),`n"
	}

	json_return := json( Dguard.http( "http://vdm02:8081/api/servers", token_2 ) )
		ToolTip,% "-Armazenando os dados das câmeras do servidor 2 do dguard em array.`nDados restantes = " json_return.servers.Count() "`nTotal de câmeras = " dados_das_cameras_no_dguard.Count(), 50 , 50
		Loop,% json_return.servers.Count() {
			OutputDebug % qwer
			_guid := StrReplace( StrReplace( json_return.servers[A_Index].guid , "{") , "}" )
			receiver := json( http( "http://vdm02:8081/api/servers/%7B" _guid "%7D/contact-id" , "Bearer " token_2 ) )
			json_camera := Dguard.Server( "vdm02" , _guid , token_2 )
			dados_das_cameras_no_dguard.Push({	name		:	json_camera.server.name
											,	guid		:	_guid
											,	active		:	json_camera.server.active
											,	connected	:	json_camera.server.connected
											,	address		:	json_camera.server.address
											,	port		:	json_camera.server.port
											,	vendor		:	json_camera.server.vendorModelName
											; ,	vendor		:	SubStr( json_camera.server.vendorModelName , 1 , InStr( json_camera.server.vendorModelName , " ")-1 )
											,	contactid	:	json_camera.server.contactIdCode
											,	offline		:	json_camera.server.offlineSince
											,	setor		:	SubStr( json_camera.server.notes , 1 , 1 )
											,	sinistro	:	SubStr( json_camera.server.notes , 2 , 1 )
											,	url			:	StrReplace( json_camera.server.url , "/" )
											,	receiver	:	receiver.contactId.receiver
											,	partition	:	receiver.contactId.partition	})
			if ( receiver.contactId.receiver != "10001" )
				api_get	:=	"http://conceitto:cjal2021@vdm02.cotrijal.local:85/camera.cgi?Receiver=" receiver.contactId.receiver "&server=" json_camera.server.contactIdCode "&camera=0&resolucao=640x480&qualidade=100"
			Else
				api_get = 
			; comando	=	"http://SERVIDOR:8081/api/servers/`%7B%_guid%`%7D/contact-id" -H "accept: application/json" -H "Authorization: bearer %token_2% " -H "Content-Type: application/json" -d "{ \"receiver\": 10001, \"account\": \"0000\", \"partition\": \"00\"}"
			; OutputDebug % Dguard.curl( comando , "vdm02" , "PUT"  ) "`n`t" json_camera.server.name
			ID			:=	StrSplit( json_camera.server.address , "." )
			date_off	:=	json_camera.server.offlineSince
			offline		:=	date_off = "-"
									? "NULL"
									: "CAST('" SubStr( date_off , 7 , 4 ) "-" SubStr( date_off , 4 , 2 ) "-" SubStr( date_off , 1 , 2 ) " " SubStr( date_off , 12 ) "' as datetime)"
			active		:=	json_camera.server.active = "true"
													? "1"
													: "0"
			connected	:=	json_camera.server.connected = "true"
														 ? "1"
														 : "0"
			url			:=	StrLen( json_camera.server.url )	= 0
																? "http://" json_camera.server.address ":80"
																: json_camera.server.url
			output		.=	"(	'" json_camera.server.name
							.	"','" StrReplace( StrReplace( json_camera.server.guid, "{") , "}" )
							.	"','" active
							.	"','" connected
							.	"','" json_camera.server.address
							.	"','" json_camera.server.port
							.	"','" json_camera.server.vendorModelName
							.	"','" json_camera.server.contactIdCode
							.	"',"  offline
							.	",'"  SubStr( json_camera.server.notes , 1 , 1 )
							.	"','" SubStr( json_camera.server.notes , 2 , 1 )
							.	"','" url
							.	"','2'"
							.	",'" api_get
							.	"','" receiver.contactId.receiver
							.	"','" receiver.contactId.partition
							.	"','" id[3] "'),`n"
	}

	json_return := json( Dguard.http( "http://vdm03:8081/api/servers", token_3 ) )
		ToolTip,% "-Armazenando os dados das câmeras do servidor 3 do dguard em array." , 50 , 50
		Loop,% json_return.servers.Count() {
			ToolTip,% "-Armazenando os dados das câmeras do servidor 3 do dguard em array.`nDados restantes = " json_return.servers.Count() "`nTotal de câmeras = " dados_das_cameras_no_dguard.Count() , 50 , 50
			_guid := StrReplace( StrReplace( json_return.servers[A_Index].guid , "{") , "}" )
			receiver := json( http( "http://vdm03:8081/api/servers/%7B" _guid "%7D/contact-id" , "Bearer " token_3 ) )
			json_camera := Dguard.Server( "vdm03" , _guid , token_3 )
			dados_das_cameras_no_dguard.Push({	name		:	json_camera.server.name
											,	guid		:	_guid
											,	active		:	json_camera.server.active
											,	connected	:	json_camera.server.connected
											,	address		:	json_camera.server.address
											,	port		:	json_camera.server.port
											,	vendor		:	json_camera.server.vendorModelName
											; ,	vendor		:	SubStr( json_camera.server.vendorModelName , 1 , InStr( json_camera.server.vendorModelName , " ")-1 )
											,	contactid	:	json_camera.server.contactIdCode
											,	offline		:	json_camera.server.offlineSince
											,	setor		:	SubStr( json_camera.server.notes , 1 , 1 )
											,	sinistro	:	SubStr( json_camera.server.notes , 2 , 1 )
											,	url			:	StrReplace( json_camera.server.url , "/" )
											,	receiver	:	receiver.contactId.receiver
											,	partition	:	receiver.contactId.partition	})
			if ( receiver.contactId.receiver != "10001" )
				api_get	:=	"http://conceitto:cjal2021@vdm03.cotrijal.local:85/camera.cgi?Receiver=" receiver.contactId.receiver "&server=" json_camera.server.contactIdCode "&camera=0&resolucao=640x480&qualidade=100"
			Else
				api_get = 
			; comando	=	"http://SERVIDOR:8081/api/servers/`%7B%_guid%`%7D/contact-id" -H "accept: application/json" -H "Authorization: bearer %token_3% " -H "Content-Type: application/json" -d "{ \"receiver\": 10001, \"account\": \"0000\", \"partition\": \"00\"}"
			; OutputDebug % Dguard.curl( comando , "vdm03" , "PUT"  ) "`n`t" json_camera.server.name
			ID			:=	StrSplit( json_camera.server.address , "." )
			date_off	:=	json_camera.server.offlineSince
			offline		:=	date_off = "-"
									? "NULL"
									: "CAST('" SubStr( date_off , 7 , 4 ) "-" SubStr( date_off , 4 , 2 ) "-" SubStr( date_off , 1 , 2 ) " " SubStr( date_off , 12 ) "' as datetime)"
			active		:=	json_camera.server.active = "true"
													? "1"
													: "0"
			connected	:=	json_camera.server.connected = "true"
														 ? "1"
														 : "0"
			url			:=	StrLen( json_camera.server.url )	= 0
																? "http://" json_camera.server.address ":80"
																: json_camera.server.url
			if ( A_Index  =  json_return.servers.Count() )
				output	.=	"(	'" json_camera.server.name
							.	"','" StrReplace( StrReplace( json_camera.server.guid, "{") , "}" )
							.	"','" active
							.	"','" connected
							.	"','" json_camera.server.address
							.	"','" json_camera.server.port
							.	"','" json_camera.server.vendorModelName
							.	"','" json_camera.server.contactIdCode
							.	"',"  offline
							.	",'"  SubStr( json_camera.server.notes , 1 , 1 )
							.	"','" SubStr( json_camera.server.notes , 2 , 1 )
							.	"','" url
							.	"','3'"
							.	",'" api_get
							.	"','" receiver.contactId.receiver
							.	"','" receiver.contactId.partition
							.	"','" id[3] "')"
			Else
				output	.=	"(	'" json_camera.server.name
							.	"','" StrReplace( StrReplace( json_camera.server.guid, "{") , "}" )
							.	"','" active
							.	"','" connected
							.	"','" json_camera.server.address
							.	"','" json_camera.server.port
							.	"','" json_camera.server.vendorModelName
							.	"','" json_camera.server.contactIdCode
							.	"',"  offline
							.	",'"  SubStr( json_camera.server.notes , 1 , 1 )
							.	"','" SubStr( json_camera.server.notes , 2 , 1 )
							.	"','" url
							.	"','3'"
							.	",'" api_get
							.	"','" receiver.contactId.receiver
							.	"','" receiver.contactId.partition
							.	"','" id[3] "'),`n"
	}
;

;	Popula a tabela sql com as informações
	ToolTip, Populando o Banco de Dados , 50 , 50
	d =
		(
			DELETE FROM
				[Dguard].[dbo].[cameras];
			DBCC CHECKIDENT ('[Dguard].[dbo].[cameras]', RESEED, 0);
		)
		sql( d , 3 )
	i =
		(
		INSERT INTO
			[Dguard].[dbo].[cameras]
				([name]
				,[guid]
				,[active]
				,[connected]
				,[ip]
				,[port]
				,[vendormodel]
				,[contactId]
				,[offlineSince]
				,[operador]
				,[sinistro]
				,[url]
				,[server]
				,[api_get]
				,[receiver]
				,[partition]
				,[id]	)
			VALUES
				%output%
		)
	;
	sql( i , 3 )
	if ( StrLen( sql_le ) > 2 )	{
		Clipboard:=sql_lq
		MsgBox % sql_le
	}
	Else	{
		decorrido := A_Now - inicio
		MsgBox,,,% "Dados Atualizados.`nTempo decorrido = " formatseconds( decorrido )
	}
	ToolTip, Iniciando 
ExitApp


END::
ExitApp