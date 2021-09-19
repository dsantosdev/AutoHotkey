;@Ahk2Exe-SetMainIcon	C:\Dih\zIco\fun\cor.ico
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

;	Recepção de Token's
	receiversx := {}
	ToolTip, Preparando variáveis do ambiente
	
	token_1 := Dguard.token( "vdm01" )
		OutputDebug % StrLen( token_1 ) > 0 ? "-Obtido token 1`n`t" token_1 	: "Falha ao obter token 1"
	token_2 := Dguard.token( "vdm02" )
		OutputDebug % StrLen( token_2 ) > 0 ? "-Obtido token 2`n`t" token_2		: "Falha ao obter token 2"
	token_3 := Dguard.token( "vdm03" )
		OutputDebug % StrLen( token_3 ) > 0 ? "-Obtido token 3`n`t" token_3 "`n" : "Falha ao obter token 3`n"
;

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
	Gui, Show, x0 y0
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
	if ( _definidos = 1 )
		where = WHERE ( [name] like '`%%_busca%`%' OR [ip] like '`%%_busca%`%' ) AND [receiver] != 10001
	Else
		where = WHERE [name] like '`%%_busca%`%' OR [ip] like '`%%_busca%`%'
		Clipboard:=where
	LV_Delete()
Goto, preenche_listview

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
	OutputDebug % array.InDict( receiversx, id_unidade, "code" )	> 0
																	? "ID de Receptora já existe"
																	: "ID de Receptora inexistente"
				. "`nID de receptora`n`t" id_unidade
				. "`nServidor`n`tSRV0" server
				. "`nGUID da câmeras`n`t" guid
	id_unidade := LTrim( RTrim( id_unidade ) )
	if ( array.InDict( receiversx, id_unidade, "code" ) > 0 )	{	;	Já existe o receiver
		OutputDebug % "Iniciando cadastro em receptora existente"
		if ( server = 1 )	{
			OutputDebug % "Servidor = SRV01"
			comando = 
				(
				"http://SERVIDOR:8081/api/servers/`%7B%guid%`%7D/contact-id"
				-H "accept: application/json"
				-H "Authorization: bearer %token_1%"
				-H "Content-Type: application/json"
				-d "{ \"receiver\": %id_unidade%, \"account\": \"%new_contact%\", \"partition\": \"00\"}"
				)
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
			; Else	{
			; 	MsgBox % "Erro na requisição:`n" comando "`nServidor = VDM01`nTipo = PUT`n`n" erro
			; 	ExitApp
			; }
		}
		if ( server = 2 )	{
			OutputDebug % "Servidor = SRV02"
			comando =
				(
					"http://SERVIDOR:8081/api/servers/`%7B%guid%`%7D/contact-id"
					-H "accept: application/json"
					-H "Authorization: bearer %token_2%"
					-H "Content-Type: application/json"
					-d "{ \"receiver\": %id_unidade%, \"account\": \"%new_contact%\", \"partition\": \"00\"}"
				)
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
			; Else	{
			; 	MsgBox % "Erro na requisição:`n" comando "`nServidor = VDM02`nTipo = PUT`n`n" erro
			; 	ExitApp
			; }
		}
		Else	{
			OutputDebug % "Servidor = SRV03"
			comando =
				(
				"http://SERVIDOR:8081/api/servers/`%7B%guid%`%7D/contact-id"
				-H "accept: application/json"
				-H "Authorization: bearer %token_3%"
				-H "Content-Type: application/json"
				-d "{ \"receiver\": %id_unidade%, \"account\": \"%new_contact%\", \"partition\": \"00\"}"
				)
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
			; Else	{
			; 	MsgBox % "Erro na requisição:`n" comando "`nServidor = VDM03`nTipo = PUT`n`n" erro
			; 	ExitApp
			; }
		}
		OutputDebug % "Finalizado vinculação de câmera a receptora Existente"
	}
	Else	{														;	Não existe o receiver
		OutputDebug % "Iniciando cadastro em receptora inexistente"
		if ( server = 1 )	{
			OutputDebug % "Servidor = SRV01"
			comando =
				(
				"http://SERVIDOR:8081/api/contact-id/receivers"
				-H "accept: application/json"
				-H "Authorization: bearer %token_1%"
				-H "Content-Type: application/json"
				-d "{ \"name\": \"%id_unidade%\", \"code\": %id_unidade%, \"protocol\": 0, \"enabled\": false}"
				)
			OutputDebug % "Adicionando nova receptora`n" dguard.curl( comando , "vdm01" , "POST" )	;	adiciona o novo receiver
			comando =
				(
				"http://SERVIDOR:8081/api/servers/`%7B%guid%`%7D/contact-id"
				-H "accept: application/json"
				-H "Authorization: bearer %token_1%"
				-H "Content-Type: application/json"
				-d "{ \"receiver\": %id_unidade%, \"account\": \"%new_contact%\", \"partition\": \"00\"}"
				)
			if ( InStr( erro := dguard.curl( comando , "vdm01" , "PUT" ), "contactid" ) > 0 ) {
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
			; Else	{
			; 	MsgBox % "Erro na requisição:`n" comando "`nServidor = VDM01`nTipo = PUT`n`n" erro
			; 	ExitApp
			; }
		}
		Else If ( server = 2 )	{
			OutputDebug % "Servidor = SRV02"
			comando =
				(
				"http://SERVIDOR:8081/api/contact-id/receivers"
				-H "accept: application/json"
				-H "Authorization: bearer %token_2%"
				-H "Content-Type: application/json"
				-d "{ \"name\": \"%id_unidade%\", \"code\": %id_unidade%, \"protocol\": 0, \"enabled\": false}"
				)
			OutputDebug % "Adicionando nova receptora`n" dguard.curl( comando , "vdm02" , "POST" )	;	adiciona o novo receiver
			comando =
				(
				"http://SERVIDOR:8081/api/servers/`%7B%guid%`%7D/contact-id"
				-H "accept: application/json"
				-H "Authorization: bearer %token_2%"
				-H "Content-Type: application/json"
				-d "{ \"receiver\": %id_unidade%, \"account\": \"%new_contact%\", \"partition\": \"00\"}"
				)
			if ( InStr( erro := dguard.curl( comando , "vdm02" , "PUT" ), "contactid" ) > 0 ) {
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
			; Else	{
			; 	MsgBox % "Erro na requisição:`n" comando "`nServidor = VDM02`nTipo = PUT`n`n" erro
			; 	ExitApp
			; }
		}
		Else	{
			OutputDebug % "Servidor = SRV03"
			comando =
				(
				"http://SERVIDOR:8081/api/contact-id/receivers"
				-H "accept: application/json"
				-H "Authorization: bearer %token_3%"
				-H "Content-Type: application/json"
				-d "{ \"name\": \"%id_unidade%\", \"code\": %id_unidade%, \"protocol\": 0, \"enabled\": false}"
				)
			OutputDebug % "Adicionando nova receptora`n" dguard.curl( comando , "vdm03" , "POST" )		;	adiciona o novo receiver
			comando =
				(
				"http://SERVIDOR:8081/api/servers/`%7B%guid%`%7D/contact-id"
				-H "accept: application/json"
				-H "Authorization: bearer %token_3%"
				-H "Content-Type: application/json"
				-d "{ \"receiver\": %id_unidade%, \"account\": \"%new_contact%\", \"partition\": \"00\"}"
				)
			if ( InStr( erro := dguard.curl( comando , "vdm03" , "PUT" ), "contactid" ) > 0 ) {
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
			; Else	{
			; 	MsgBox % "Erro na requisição:`n" comando "`nServidor = VDM03`nTipo = PUT`n`n" erro
			; 	ExitApp
			; }
		}
		OutputDebug % "Finalizado vinculação de câmera a receptora Inexistente"
	}
Return

GuiClose:
	ExitApp