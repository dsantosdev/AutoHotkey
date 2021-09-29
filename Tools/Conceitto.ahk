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
#IfWinActive, Cadastro de Câmeras
inicio	:=	A_Now
;@Ahk2Exe-SetMainIcon	C:\Dih\zIco\fun\conceitto.ico
	#Persistent
	#SingleInstance Force
	#Include ..\class\array.ahk
	; #Include ..\class\cor.ahk
	#Include ..\class\dguard.ahk
	#Include ..\class\functions.ahk
	#Include ..\class\gui.ahk
	; #Include ..\class\mail.ahk
	; #Include ..\class\safedata.ahk
	#Include ..\class\string.ahk
	#Include ..\class\sql.ahk
	; #Include ..\class\windows.ahk
;

;	Definições
	global	debug = 
		,	info_das_cameras	:= {}
		,	receiversx			:= {}
;

;	Tokens dos servidores
	ToolTip, Requisitando token do servidor 1 , 50 , 50
	token_1 := Dguard.token( "vdm01" )
		OutputDebug % StrLen( token_1 ) > 0
										? "-Obtido token 1`n`t" token_1
										: "Falha ao obter token 1"
	ToolTip, Requisitando token do servidor 2 , 50 , 50
	token_2 := Dguard.token( "vdm02" )
		OutputDebug % StrLen( token_2 ) > 0
										? "-Obtido token 2`n`t" token_2
										: "Falha ao obter token 2"
	ToolTip, Requisitando token do servidor 3 , 50 , 50
	token_3 := Dguard.token( "vdm03" )
		OutputDebug % StrLen( token_3 ) > 0
										? "-Obtido token 3`n`t" token_3 "`n"
										: "Falha ao obter token 3`n"
;

;	Informações das câmeras contidas no d-guard
		OutputDebug % "-Armazenando os dados das câmeras do dguard em array."
	dados_das_cameras_no_dguard := {}

	json_return := json( Dguard.http( "http://vdm01:8081/api/servers", token_1 ) )
		Loop,% json_return.servers.Count()	{
		ToolTip,% "-Armazenando os dados das câmeras do servidor 1 do dguard em array.`nDados restantes = " json_return.servers.Count()-A_Index "`nTotal de câmeras = " dados_das_cameras_no_dguard.Count(), 50 , 50
			_guid := StrReplace( StrReplace( json_return.servers[A_Index].guid , "{") , "}" )
			receiver := json( http( "http://vdm01:8081/api/servers/%7B" _guid "%7D/contact-id" , "Bearer " token_1 ) )
			json_camera := Dguard.Server( "vdm01" , _guid , token_1 )
			ID			:=	StrSplit( json_camera.server.address , "." )
			if ( receiver.contactId.receiver != "10001" )
				api_get	:=	"http://conceitto:cjal2021@vdm01.cotrijal.local:85/camera.cgi?receiver=" receiver.contactId.receiver "&server=" json_camera.server.contactIdCode "&camera=0&resolucao=640x480&qualidade=100"
			Else
				api_get = 
			dados_das_cameras_no_dguard.Push({	name		:	json_camera.server.name
											,	guid		:	_guid
											,	active		:	json_camera.server.active
											,	connected	:	json_camera.server.connected
											,	address		:	json_camera.server.address
											,	port		:	json_camera.server.port
											,	vendor		:	json_camera.server.vendorModelName
											,	contactid	:	json_camera.server.contactIdCode
											,	offline		:	json_camera.server.offlineSince
											,	setor		:	SubStr( json_camera.server.notes , 1 , 1 )
											,	sinistro	:	SubStr( json_camera.server.notes , 2 , 1 )
											,	url			:	StrReplace( json_camera.server.url , "\" )
											,	receiver	:	receiver.contactId.receiver
											,	partition	:	receiver.contactId.partition
											,	id			:	id
											,	server		:	"1"
											,	api			:	api_get	})
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
		Loop,% json_return.servers.Count() {
			ToolTip,% "-Armazenando os dados das câmeras do servidor 2 do dguard em array.`nDados restantes = " json_return.servers.Count()-A_Index "`nTotal de câmeras = " dados_das_cameras_no_dguard.Count(), 50 , 50
			_guid := StrReplace( StrReplace( json_return.servers[A_Index].guid , "{") , "}" )
			receiver := json( http( "http://vdm02:8081/api/servers/%7B" _guid "%7D/contact-id" , "Bearer " token_2 ) )
			json_camera := Dguard.Server( "vdm02" , _guid , token_2 )
			ID			:=	StrSplit( json_camera.server.address , "." )
			if ( receiver.contactId.receiver != "10001" )
				api_get	:=	"http://conceitto:cjal2021@vdm02.cotrijal.local:85/camera.cgi?Receiver=" receiver.contactId.receiver "&server=" json_camera.server.contactIdCode "&camera=0&resolucao=640x480&qualidade=100"
			Else
				api_get =
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
											,	partition	:	receiver.contactId.partition
											,	id			:	id
											,	server		:	"2"
											,	api			:	api_get	})
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
			ToolTip,% "-Armazenando os dados das câmeras do servidor 3 do dguard em array.`nDados restantes = " json_return.servers.Count()-A_Index "`nTotal de câmeras = " dados_das_cameras_no_dguard.Count() , 50 , 50
			_guid := StrReplace( StrReplace( json_return.servers[A_Index].guid , "{") , "}" )
			receiver := json( http( "http://vdm03:8081/api/servers/%7B" _guid "%7D/contact-id" , "Bearer " token_3 ) )
			json_camera := Dguard.Server( "vdm03" , _guid , token_3 )
			ID			:=	StrSplit( json_camera.server.address , "." )
			if ( receiver.contactId.receiver != "10001" )
				api_get	:=	"http://conceitto:cjal2021@vdm03.cotrijal.local:85/camera.cgi?Receiver=" receiver.contactId.receiver "&server=" json_camera.server.contactIdCode "&camera=0&resolucao=640x480&qualidade=100"
			Else
				api_get = 
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
											,	partition	:	receiver.contactId.partition
											,	id			:	id
											,	server		:	"3"
											,	api			:	api_get	})
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
		ToolTip, % "Dados Atualizados.`nTempo decorrido = " formatseconds( decorrido ), 50 , 50
		outputdebug, % "Dados Atualizados.`nTempo decorrido = " formatseconds( decorrido ), 50 , 50
	}
;	ToolTip, Iniciando 

;	SRV01	-	Get Receptoras
	receptoras := json( http( "http://vdm01:8081/api/contact-id/receivers" , "Bearer " token_1 ) )
	Loop,% receptoras.receivers.Count()
		receiversx.push({ code : receptoras.receivers[A_index].code , server : "1" })
	OutputDebug % "receptoras srv01 inseridas no array com sucesso."
;

;	SRV02	-	Get Receptoras
	receptoras := json( http( "http://vdm02:8081/api/contact-id/receivers" , "Bearer " token_2 ) )
	Loop,% receptoras.receivers.Count()
		receiversx.push({ code : receptoras.receivers[A_index].code , server : "2" })
	OutputDebug % "receptoras srv02 inseridas no array com sucesso."
;

;	SRV03	-	Get Receptoras
	receptoras := json( http( "http://vdm03:8081/api/contact-id/receivers" , "Bearer " token_3 ) )
	Loop,% receptoras.receivers.Count()
		receiversx.push({ code : receptoras.receivers[A_index].code , server : "3" })
	OutputDebug % "receptoras srv03 inseridas no array com sucesso."
;

ToolTip


;	Interface
	OutputDebug % "Iniciando construção da interface."
	Gui.Cores()
	Gui.Font( "S10" , "Bold" )
	Gui, Add, Edit,		x10		y10		w300	h30		v_busca		g_filtro	Section
	Gui.Font( "cWhite" )
	Gui, Add, Checkbox,			ys		w300	h30		v_definidos	g_filtro			, Exibir apenas câmeras já configuradas
	Gui.Font( )
	Gui.Font( "S10" , "Bold" )
	Gui, Add, ListView,	x10		y50		w615	h700	v_listview				Grid	, Nome|Ip|Receptora|Conta|guid|id|server|api
		LV_ModifyCol( 1 , 175 )
		LV_ModifyCol( 2 , 100 )
		LV_ModifyCol( 3 , 100 )
		LV_ModifyCol( 4 , 100 )
		Loop, 4
			LV_ModifyCol( A_Index + 4, 0 )
		Gosub, preenche_listview
	Gui, Add, Button,	xm				w300	h30					g_copyUrl	Section	, Copiar URL
	Gui, Add, Button,			ys		w300	h30		gGuiClose						, Cancelar
	Gui, Show, x0 y0, Cadastro de Câmeras
return

preenche_listview:
	s =
		(
		SELECT	[name]
			,	[ip]
			,	[receiver]
			,	[contactId]
			,	[guid]
			,	[id]
			,	[server]
			,	[api_get]
		FROM
			[Dguard].[dbo].[cameras]
			%where%
		ORDER BY
			[name]
		)
	servers	:=	sql( s , 3 )
	Loop,%	servers.Count()-1	{
		LV_Add( ""
			,	servers[A_Index+1,1]
			,	servers[A_Index+1,2]
			,	servers[A_Index+1,3] = "10001"	? "" : servers[A_Index+1,3]
			,	servers[A_Index+1,4] = "0000"	? "" : servers[A_Index+1,4]
			,	servers[A_Index+1,5]
			,	servers[A_Index+1,6]
			,	servers[A_Index+1,7]
			,	servers[A_Index+1,8]	)
	}
	GuiControl, Enable, _definidos
	GuiControl, Enable, _busca
	GuiControl, Enable, _listview
	GuiControl, Focus, _busca
	where =
Return

_filtro:
	Gui, Submit, NoHide
	search_delay()
	Gui, Submit, NoHide
		OutputDebug % "filtro de unidade = " _definidos
	GuiControl, Disable, _busca
	GuiControl, Disable, _definidos
	GuiControl, Disable, _listview
	if ( _definidos = 1 )
		where = WHERE ( [name] like '`%%_busca%`%' OR [ip] like '`%%_busca%`%' ) AND [receiver] != 10001
	Else
		where = WHERE [name] like '`%%_busca%`%' OR [ip] like '`%%_busca%`%'
		Clipboard:=where
	LV_Delete()
Goto, preenche_listview

^c::
_copyURL:
	OutputDebug % "Iniciando preparação ou cópia de URL"
	Gui, Submit, NoHide
	listview_line			:=	LV_GetNext()
	LV_GetText( nome		,	LV_GetNext() , 1 )
	LV_GetText( ip			,	LV_GetNext() , 2 )
	LV_GetText( receptora	,	LV_GetNext() , 3 )
	LV_GetText( conta		,	LV_GetNext() , 4 )
	LV_GetText( guid		,	LV_GetNext() , 5 )
	LV_GetText( id_unidade	,	LV_GetNext() , 6 )
	LV_GetText( server		,	LV_GetNext() , 7 )
	LV_GetText( api			,	LV_GetNext() , 8 )
	if (receptora = "10001"
	||	receptora = "" )
		Gosub, Cadastra
	Else
		Clipboard := api
	OutputDebug % "URL Copiada com sucesso"
	OutputDebug % "Verificando ping`n`t" ping( ip ) "`n`t" ip
	ToolTip, URL copiada para o Clipboard com sucesso!
	Clipboard := LTrim( RTrim( Clipboard ) )
	if ( ping( ip ) = 0 )
		MsgBox A câmera que você selecionou`, não respondeu ao teste de ping. Verificar se a mesma não está indisponível.
	Else
		Sleep, 3000
	ToolTip
Return

cadastra:
	erro =
	s	=
		(
		SELECT TOP(1) [contactId]
		FROM
			[Dguard].[dbo].[cameras]
		WHERE
			[receiver] = '%id_unidade%'
			ORDER BY 1 DESC
		)
	contacts := sql( s , 3 )
	if ( (contacts.Count()-1) = 0 )
		new_contact := 1
	Else
		new_contact := contacts[2,1] + 1
	id_unidade := LTrim( RTrim( id_unidade ) )
	OutputDebug % "New Contact-ID = " new_contact "`n" id_unidade
	OutputDebug % "Iniciando cadastro"
	if ( server = 1 )	{
		OutputDebug % "Servidor = SRV01"
		comando = "http://SERVIDOR:8081/api/servers/`%7B%guid%`%7D/contact-id" -H "accept: application/json" -H "Authorization: bearer %token_1%" -H "Content-Type: application/json" -d "{ \"receiver\": %id_unidade%, \"account\": \"%new_contact%\", \"partition\": \"00\"}"
		if ( InStr( erro := dguard.curl( comando , "vdm01" , "PUT" ), "contactid" ) > 0 ) {		;	adiciona o novo receiver
			OutputDebug % "Vinculado câmera à receptora sem erros."
			Clipboard := new_api := "http://conceitto:cjal2021@vdm0" server ":85/camera.cgi?Receiver=" id_unidade "&server=" new_contact "&camera=0&resolucao=640x480&qualidade=100"
			u	=
				(
				UPDATE [Dguard].[dbo].[cameras]
				SET
						[receiver]		= '%id_unidade%'
					,[contactid]	= '%new_contact%'
					,[api_get]		= '%new_api%'
				WHERE
					[guid]			= '%guid%'
				)
			sql( u , 3 )
			LV_Delete(	listview_line )
			LV_Insert(	listview_line , ""
					,	nome
					,	ip
					,	id_unidade
					,	new_contact
					,	guid
					,	id_unidade
					,	server
					,	new_api	)

		}
	}
	Else if ( server = 2 )	{
		OutputDebug % "Servidor = SRV02"
		comando = "http://SERVIDOR:8081/api/servers/`%7B%guid%`%7D/contact-id" -H "accept: application/json" -H "Authorization: bearer %token_2%" -H "Content-Type: application/json" -d "{ \"receiver\": %id_unidade%, \"account\": \"%new_contact%\", \"partition\": \"00\"}"
		if ( InStr( dguard.curl( comando , "vdm02" , "PUT" ), "contactid" ) > 0 ) {		;	adiciona o novo receiver
			OutputDebug % "Vinculado câmera à receptora sem erros"
			Clipboard := new_api := "http://conceitto:cjal2021@vdm0" server ":85/camera.cgi?Receiver=" id_unidade "&server=" new_contact "&camera=0&resolucao=640x480&qualidade=100"
			u	=
				(
				UPDATE [Dguard].[dbo].[cameras]
				SET
						[receiver]		= '%id_unidade%'
					,[contactid]	= '%new_contact%'
					,[api_get]		= '%new_api%'
				WHERE
					[guid]			= '%guid%'
				)
			sql( u , 3 )
			LV_Delete(	listview_line )
			LV_Insert(	listview_line , ""
					,	nome
					,	ip
					,	id_unidade
					,	new_contact
					,	guid
					,	id_unidade
					,	server
					,	new_api	)

		}
	}
	Else	{
		OutputDebug % "Servidor = SRV03"
		comando = "http://SERVIDOR:8081/api/servers/`%7B%guid%`%7D/contact-id" -H "accept: application/json" -H "Authorization: bearer %token_3%" -H "Content-Type: application/json" -d "{ \"receiver\": %id_unidade%, \"account\": \"%new_contact%\", \"partition\": \"00\"}"
		if ( InStr( dguard.curl( comando , "vdm03" , "PUT" ), "contactid" ) > 0 ) {		;	adiciona o novo receiver
			OutputDebug % "Vinculado câmera à receptora sem erros"
			Clipboard := new_api := "http://conceitto:cjal2021@vdm0" server ":85/camera.cgi?Receiver=" id_unidade "&server=" new_contact "&camera=0&resolucao=640x480&qualidade=100"
			u	=
				(
				UPDATE [Dguard].[dbo].[cameras]
				SET
						[receiver]		= '%id_unidade%'
					,[contactid]	= '%new_contact%'
					,[api_get]		= '%new_api%'
				WHERE
					[guid]			= '%guid%'
				)
			sql( u , 3 )
			LV_Delete(	listview_line )
			LV_Insert(	listview_line , ""
					,	nome
					,	ip
					,	id_unidade
					,	new_contact
					,	guid
					,	id_unidade
					,	server
					,	new_api	)

		}
	}
	OutputDebug % "Finalizado vinculação de câmera a receptora Existente"
Return

GuiClose:
	ExitApp