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
	receiversx := {}
	ToolTip, Preparando variáveis do ambiente
	
	token_1 := Dguard.token( "vdm01" )
		OutputDebug % StrLen( token_1 ) > 0 ? "-Obtido token 1`n`t" token_1 	: "Falha ao obter token 1"
	token_2 := Dguard.token( "vdm02" )
		OutputDebug % StrLen( token_2 ) > 0 ? "-Obtido token 2`n`t" token_2		: "Falha ao obter token 2"
	token_3 := Dguard.token( "vdm03" )
		OutputDebug % StrLen( token_3 ) > 0 ? "-Obtido token 3`n`t" token_3 "`n" : "Falha ao obter token 3`n"
;

	OutputDebug % http( "http://vdm01:8081/api/contact-id/receivers" , "Bearer " token_1 )
	receptoras := json( http( "http://vdm01:8081/api/contact-id/receivers" , "Bearer " token_1 ) )
		Loop,% receptoras.receivers.Count()	{
			; comando	= "http://SERVIDOR:8081/api/contact-id/receivers/1" -H "accept: application/json" -H "Authorization: bearer %token_1%"
			; dguard.curl( comando , "vdm01" , "DELETE" )
			receiversx.push({ code : receptoras.receivers[A_index].code , server : "1" })
		}
		; comando	= "http://SERVIDOR:8081/api/contact-id/receivers/0" -H "accept: application/json" -H "Authorization: bearer %token_1%" -H "Content-Type: application/json" -d "{ \"name\": \"Default\", \"code\": 10001, \"protocol\": 0, \"enabled\": false}"
		; dguard.curl( comando , "vdm01" , "PUT" )
	OutputDebug % "receptoras 1 ok"

	receptoras := json( http( "http://vdm02:8081/api/contact-id/receivers" , "Bearer " token_2 ) )
		Loop,% receptoras.receivers.Count()	{
			; comando	= "http://SERVIDOR:8081/api/contact-id/receivers/1" -H "accept: application/json" -H "Authorization: bearer %token_2%"
			; dguard.curl( comando , "vdm02" , "DELETE" )
			OutputDebug % receptoras.receivers.code
			receiversx.push({ code : receptoras.receivers[A_index].code , server : "2" })
		}
		; comando	= "http://SERVIDOR:8081/api/contact-id/receivers/0" -H "accept: application/json" -H "Authorization: bearer %token_2%" -H "Content-Type: application/json" -d "{ \"name\": \"Default\", \"code\": 10001, \"protocol\": 0, \"enabled\": false}"
		; dguard.curl( comando , "vdm02" , "PUT" )
	OutputDebug % "receptoras 2 ok"

	receptoras := json( http( "http://vdm03:8081/api/contact-id/receivers" , "Bearer " token_3 ) )
		Loop,% receptoras.receivers.Count()	{
			; comando	= "http://SERVIDOR:8081/api/contact-id/receivers/1" -H "accept: application/json" -H "Authorization: bearer %token_3%"
			; dguard.curl( comando , "vdm03" , "DELETE" )
			OutputDebug % receptoras.receivers.code
			receiversx.push({ code : receptoras.receivers[A_index].code , server : "3" })
		}
		; comando	= "http://SERVIDOR:8081/api/contact-id/receivers/0" -H "accept: application/json" -H "Authorization: bearer %token_3%" -H "Content-Type: application/json" -d "{ \"name\": \"Default\", \"code\": 10001, \"protocol\": 0, \"enabled\": false}"
		; dguard.curl( comando , "vdm03" , "PUT" )
	OutputDebug % "receptoras 3 ok"


	OutputDebug % receiversx.Count()
ToolTip

;GUi
	Gui.Cores()
	Gui.Font( "S10" , "Bold" )
	Gui, Add, Edit,		x10		y10		w300	h30		v_busca		g_filtro	Section
	Gui.Font( "cWhite" )
	Gui, Add, Checkbox,			ys		w300	h30		v_definidos	g_filtro			, Exibir apenas câmeras já configuradas
	Gui.Font( )
	Gui.Font( "S10" , "Bold" )
	Gui, Add, ListView,	x10		y50		w615	h700	v_listview						, Nome|Ip|Receptora|Conta|guid|id|server|api
		LV_ModifyCol( 1 , 175 )
		LV_ModifyCol( 2 , 100 )
		LV_ModifyCol( 3 , 100 )
		LV_ModifyCol( 4 , 100 )
		Loop, 4
			LV_ModifyCol( A_Index + 4, 0 )
		Gosub, preenche_listview
	Gui, Add, Button,	xm				w300	h30					g_copyUrl	Section	, Copiar URL
	Gui, Add, Button,			ys		w300	h30		gGuiClose						, Cancelar
	Gui, Show
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
		Loop,%	servers.Count()	{
			LV_Add( ""
				,	servers[A_Index+1,1]
				,	servers[A_Index+1,2]
				,	servers[A_Index+1,3]
				,	servers[A_Index+1,4]
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
		OutputDebug % _definidos
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
		Gui, Submit, NoHide
		LV_GetText( guid		, LV_GetNext() , 5 )
		LV_GetText( receptora	, LV_GetNext() , 3 )
		LV_GetText( conta		, LV_GetNext() , 4 )
		LV_GetText( id			, LV_GetNext() , 6 )
		LV_GetText( server		, LV_GetNext() , 7 )
		LV_GetText( api			, LV_GetNext() , 8 )
		if ( receptora = "10001" )
			Goto, Cadastra
		Clipboard := api
		ToolTip, URL copiada para o Clipboard com sucesso!
		Sleep, 3000
		ToolTip

	Return

	cadastra:
		s	=
			(
			SELECT TOP(1) [contactId]
			FROM
				[Dguard].[dbo].[cameras]
			WHERE
				[receiver] = '%id%'
				ORDER BY 1 DESC
			)
		contacts := sql( s , 3 )
		if ( (contacts.Count()-1) = 0 )
			new_contact := 1
		Else
			new_contact := contacts[2,1] + 1
		Loop,% receiversx.Count()
			outputdebug % receivers[A_index].code
		MsgBox %  array.InDict( receiversx, id, "code" ) "`n" id "`n" server "`n" guid
		if ( array.InDict( receiversx, id, "code" ) > 0 )	{	;	Já existe o receiver
			if ( server = 1 )	{
				comando = 
					(
					"http://SERVIDOR:8081/api/servers/`%7B%guid%`%7D/contact-id"
					-H "accept: application/json"
					-H "Authorization: bearer %token_1%"
					-H "Content-Type: application/json"
					-d "{ \"receiver\": %id%, \"account\": \"%new_contact%\", \"partition\": \"00\"}"
					)
				dguard.curl( comando , "vdm01" , "PUT" )		;	adiciona o novo receiver
			}
			if ( server = 2 )	{
				comando =
					(
						"http://SERVIDOR:8081/api/servers/`%7B%guid%`%7D/contact-id"
						-H "accept: application/json"
						-H "Authorization: bearer %token_2%"
						-H "Content-Type: application/json"
						-d "{ \"receiver\": %id%, \"account\": \"%new_contact%\", \"partition\": \"00\"}"
					)
				dguard.curl( comando , "vdm02" , "PUT" )		;	adiciona o novo receiver
			}
			Else	{
				comando =
					(
						"http://SERVIDOR:8081/api/servers/`%7B%guid%`%7D/contact-id"
						-H "accept: application/json"
						-H "Authorization: bearer %token_3%"
						-H "Content-Type: application/json"
						-d "{ \"receiver\": %id%, \"account\": \"%new_contact%\", \"partition\": \"00\"}"
					)
				dguard.curl( comando , "vdm03" , "PUT" )		;	adiciona o novo receiver
			}
		}
		Else	{	;	Não existe ainda o receiver
			if ( server = 1 )	{
				comando = "http://SERVIDOR:8081/api/contact-id/receivers" -H "accept: application/json" -H "Authorization: bearer %token_1%" -H "Content-Type: application/json" -d "{ \"name\": \"%id%\", \"code\": %id%, \"protocol\": 0, \"enabled\": false}"
				dguard.curl( comando , "vdm01" , "POST" )	;	adiciona o novo receiver
				comando = "http://SERVIDOR:8081/api/servers/`%7B%guid%`%7D/contact-id" -H "accept: application/json" -H "Authorization: bearer %token_1%" -H "Content-Type: application/json" -d "{ \"receiver\": %id%, \"account\": \"%new_contact%\", \"partition\": \"00\"}"
				dguard.curl( comando , "vdm01" , "PUT" )
			}
			if ( server = 2 )	{
				comando = "http://SERVIDOR:8081/api/contact-id/receivers" -H "accept: application/json" -H "Authorization: bearer %token_2%" -H "Content-Type: application/json" -d "{ \"name\": \"%id%\", \"code\": %id%, \"protocol\": 0, \"enabled\": false}"
				dguard.curl( comando , "vdm02" , "POST" )	;	adiciona o novo receiver
				comando = "http://SERVIDOR:8081/api/servers/`%7B%guid%`%7D/contact-id" -H "accept: application/json" -H "Authorization: bearer %token_2%" -H "Content-Type: application/json" -d "{ \"receiver\": %id%, \"account\": \"%new_contact%\", \"partition\": \"00\"}"
				dguard.curl( comando , "vdm02" , "PUT" )

			}
			Else	{
				comando = "http://SERVIDOR:8081/api/contact-id/receivers" -H "accept: application/json" -H "Authorization: bearer %token_3%" -H "Content-Type: application/json" -d "{ \"name\": \"%id%\", \"code\": %id%, \"protocol\": 0, \"enabled\": false}"
				dguard.curl( comando , "vdm03" , "POST" )
				comando = "http://SERVIDOR:8081/api/servers/`%7B%guid%`%7D/contact-id" -H "accept: application/json" -H "Authorization: bearer %token_3%" -H "Content-Type: application/json" -d "{ \"receiver\": %id%, \"account\": \"%new_contact%\", \"partition\": \"00\"}"
				dguard.curl( comando , "vdm03" , "PUT" )
			}
			MsgBox % "ok"
		}
	Return

	GuiClose:
		ExitApp