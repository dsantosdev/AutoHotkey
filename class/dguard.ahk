/*
	Depende da instalação do cUrl e configuração do path do mesmo
*/
if	inc_dguard
	Return
Global	inc_dguard	=	1
	,	token
#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk

Class	dguard {

	_cria_layout( ip, nome )												{
		l_exist	:= nome_sql := ""
		token	:=	this.token( ip )
		If	InStr(	nome, "[" )
		&&	!InStr(	nome, "]" )
			nome	:=	nome "]"

		;	Verifica se o layout ainda não existe
			c	:=	"GET ""http://" ip ":8081/api/layouts"""
				.	" -H ""accept: application/json"""
				.	" -H ""Authorization: bearer " token """"

			l	:=	json( this.curly( c ) )

			If		(nome = "NMT [ SUP ] C" )
				nome:=	SubStr( nome, 1, 11 ) " Centro"
			Else If	(nome = "NMT [ SUP ] S" )
				nome:=	SubStr( nome, 1, 11 ) " Sede"

			Loop,%	l.layouts.Count()
				If	( l.layouts[A_Index].name = nome ) {

					l_exist =	1
					l_g		:=	l.layouts[A_Index].guid

				}

		;	Cria layout se não existir
			if	l_exist
				Return

			c	:=	"POST ""http://" ip ":8081/api/layouts"""
				.	" -H ""accept: application/json"""
				.	" -H ""Authorization: bearer " token """"
				.	" -H ""Content-Type: application/json"""
				.	" -d ""{ \""name\"": \""" StrRep( nome,, "]]:]") "\""}"""

			l	:=	json( error := this.Curly( c ) )

			l_g	:=	l.layout.guid
			
		;	Insere câmeras
			nome	:=	StrRep( nome,, "]]:]" )
			nome_sql:=	StrRep( nome,, " [ : [[] " )
			select	=
				(
					SELECT
						[guid]
					FROM
						[Dguard].[dbo].[cameras]
					WHERE
						[name] LIKE '%nome_sql%`%'
				)
			sql	:=	sql( select, 3 )
			; MsgBox % select

			Loop,%	sql.Count()-1 {
				c	:=	"POST """"http://" ip ":8081/api/layouts/%7B" StrRep( l_g,, "{", "}" ) "%7D/servers"""""
						.	" -H """"accept: application/json"""""
						.	" -H """"Authorization: bearer " token """"""
						.	" -H """"Content-Type: application/json"""""
						.	" -d """"{ \""""serverGuid\"""": \""""{" sql[A_index+1, 1] "}\""""}"""""""
						
				this.Curly( c, 1 )

			}
	}

	_exibe_layout( layout_guid="", monitor_guid="", workstation_guid="" )	{
		if !Token
			token	:=	this.token( )
		;	Exibe
			c	:=	"PUT ""http://localhost:8081/api/virtual-matrix/workstations/%7B" StrRep( workstation_guid,, "{", "}" )
				.	"%7D/monitors/%7B" StrRep( monitor_guid,, "{", "}" )
				.	"%7D/layout"""
				.	" -H ""accept: application/json"""
				.	" -H ""Authorization: bearer " token """"
				.	" -H ""Content-Type: application/json"""
				.	" -d ""{ \""layoutGuid\"": \""" layout_guid "\""}"""
			return this.curly( c )
	}

	cameras( server = "" , token = "" )										{
		;	Retorna guid, name, active e connected das câmeras cadastradas no servidor do dguard
		server	:=	StrLen( server ) = 0	;	parâmetro de servidor não enviado
				?	"localhost"
				:	server
		if !token
			token := this.Token()
		url := "http://" server ":8081/api/servers"
		retorno := Dguard.Request( url , token )
		return	json( retorno )
	}

	cameras_info( server = "" , guid = "" , token = "" )					{
		/* Exemplo de Retorno:
			"server:" {
				"name": "ESM | Portão",
				"guid": "{5AAA4602-8B71-4134-96BC-B6F9F9890014}",
				"parentGuid": null,
				"hasChildren": false,
				"active": true,
				"connected": true,
				"vendorGuid": "{CA014F07-32AE-46B9-83A2-8A9B836E8120}",
				"modelGuid": "{5BA4689B-6DD0-2C27-C0F8-C6B514DC5533}",
				"address": "10.2.36.221",
				"port": 80,
				"username": "admin",
				"connectionType": 0,
				"timeoutEnabled": true,
				"timeout": 60,
				"bandwidthOptimization": true,
				"camerasEnabled": 16,
				"vendorModelName": "Dahua Technology Co., LTD DH-IPC-HDBW2320RN-ZS",
				"type": 0,
				"contactIdCode": "0000",
				"recording": true,
				"offlineSince": "-",
				"groupGuid": null,
				"notes": "54",
				"advancedSettings": "",
				"url": "http://10.2.36.221:80",
				"hasCamerasOutOfSpecifications": false
			}
		*/
		server	:=	StrLen( server ) = 0	;	parâmetro de servidor não enviado
				?	"localhost"
				:	server
		url := "http://" server ":8081/api/servers/`%7B" StrRep( guid ,, "{", "}" ) "`%7D"
		retorno := Dguard.Request( url , token )
		return	json( retorno )
	}

	cam_to_layout( server, layout_guid, cam_guid, sequence )				{
		if	!Server
			server	 =	localhost
		token	:=	this.token( server )
		layout_guid	:=	StrRep( layout_guid,, "{", "}" )
		comando	:=	" POST ""http://" server ":8081/api/layouts/%7B" layout_guid "%7D/cameras"""
					.	" -H ""accept: application/json"""
					.	" -H ""Authorization: bearer " token """"
					.	" -H ""Content-Type: application/json"""
					.	" -d ""{ \""aspectRatio\"": 1, "
					.	"\""zoom\"": 1, "
					.	"\""sequence\"":" sequence ", "
					.	"\""serverGuid\"":\""" cam_guid "\"", "
					.	"\""cameraId\"": 0, "
					.	"\""allowDuplicates\"": true }"""
		; OutputDebug, % comando
		return this.curly( comando )
	}

	comando( params* )														{
		token	=	REPLACE_TOKEN
		a		:=	"\"""
		comando	:=	" -H ""accept: application/json"""
				.	"`n -H ""Authorization: bearer " token """"
				.	"`n -H ""Content-Type: application/json"""
				.	"`n -d ""{"
		for	i, v in params
					comando	.=	StrReplace( v, "\", a ) ", "
		comando	:=	SubStr( comando, 1, -2 )
		comando	.=	"}"""
		Return comando
	}

	contact_id( server = "" , guid = "" , token = "" )						{
		/* Exemplo de Retorno: 
			"contactId": {
				"receiver": 10001,
				"account": "0000",
				"partition": "00"
  			}
		*/
		; MsgBox % server "`n" guid "`n" token
		server	:=	StrLen( server ) = 0	;	parâmetro de servidor não enviado
				?	"localhost"
				:	server
		url := "http://" server ":8081/api/servers/`%7B" StrRep( guid ,, "{", "}" ) "`%7D/contact-id"
		retorno := Dguard.Request( url , token )
		return	json( retorno )
	}

	curl( comando , server = "" , tipo = "" )								{
		comando	:=	StrReplace( comando , "`n" )
		DetectHiddenWindows On
		Run %ComSpec%,, Hide, pid
		WinWait ahk_pid %pid%
		DllCall( "AttachConsole" , "UInt" , pid )
		WshShell := ComObjCreate( "Wscript.Shell" )
		if (StrLen( tipo ) > 0
		&& 	StrLen( server ) > 0 )	{												;	Tem servidor e tipo
			; clipboard := "curl -X " tipo " " StrReplace( comando , "servidor" , server ) 
			exec := WshShell.Exec( "cmd /c curl -X " tipo " " StrReplace( comando , "servidor" , server ) )
		}
		else if (	StrLen( tipo ) > 0
		&&			StrLen( server ) = 0 )											;	Não tem servidor e tem tipo
			exec := WshShell.Exec( "cmd /c curl -X " tipo " " comando )
		else if (	StrLen( tipo ) = 0
		&&			StrLen( server ) > 0 )											;	Tem servidor e não tem tipo
			exec := WshShell.Exec( "cmd /c curl -X " StrReplace( comando , "servidor" , server ) )
		else if ( (	StrLen( TIPO ) = 0 && StrLen( SERVER ) = 0 )
		&&			InSTr( COMANDO , "GET" ) = 0 ) {								;	Não tem servidor e não tem tipo, mas não é do tipo GET
			; Clipboard := "cmd /c curl -X " comando
			exec := WshShell.Exec( "cmd /c curl -X " comando )
		}
		else																		;	Tipo GET
			exec := WshShell.Exec( "cmd /c curl -X GET " comando " -d" )
		DllCall( "FreeConsole" )
		Process Close,%	pid
		return exec.StdOut.ReadAll()
	}

	curly( comando, assync="0" )											{
		If	assync {
			for_new_instance:=	"#NoTrayIcon"
							.	"`nDetectHiddenWindows On"
							.	"`nRun		`%ComSpec`%,, Hide, pid"
							.	"`nWinWait ahk_pid `%pid`%"
							.	"`nDllCall( ""AttachConsole"", ""UInt"", pid )"
							.	"`nWshShell	:= ComObjCreate( ""Wscript.Shell"" )"
							.	"`ne		:=	WshShell.Exec( ""cmd /c curl -X " comando ")"
							.	"`nDllCall( ""FreeConsole"" )"
							.	"`nProcess Close,`% pid"
							; .	"`nMsgBox `% e.StdOut.ReadAll()"
							.	"`nExitApp"
							; OutputDebug % for_new_instance
			new_instance( for_new_instance )
			Return
		}
		Else	{
			DetectHiddenWindows On
			Run %ComSpec%,, Hide, pid
			WinWait ahk_pid %pid%
			DllCall( "AttachConsole" , "UInt" , pid )
			WshShell	:= ComObjCreate( "Wscript.Shell" )
			; OutputDebug % clipboard := comando
			exec		:= WshShell.Exec( "cmd /c curl -X " comando )
			DllCall( "FreeConsole" )
			Process Close,%	pid
			return exec.StdOut.ReadAll()
		}
	}

	delete_layout( guid )													{
		del_comando	:=	"DELETE ""http://localhost:8081/api/layouts/%7B" StrRep( guid,, "{", "}" ) "%7D"""
					.	" -H ""accept: application/json"""
					.	" -H ""Authorization: bearer " token """"
		this.curl( del_comando )
	}

	get_image( guid_da_camera , token = "" )								{	;	não está pronto
		horario := A_Now 
		static req := ComObjCreate( "Msxml2.XMLHTTP" )
		req.open(	"GET"
				,	"http://vdm01:8081/api/servers/%7B" guid_da_camera "%7D/cameras/0/image-640x480.jpg"
				,	false	)
		req.SetRequestHeader( "Authorization", "bearer " token  )
		req.SetRequestHeader( "If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT" )
		req.send()
		iStream := req.ResponseStream
		if ( ComObjType( iStream ) = 0xD )
		pIStream := ComObjQuery(iStream				;	def in ObjIdl.h
							,	"{0000000c-0000-0000-C000-000000000046}"	)
		oFile := FileOpen(	A_ScriptDIr "\" guid_da_camera " " horario ".png"
						,	"w"	)
		Loop {	
			VarSetCapacity( Buffer
						,	8192 )
			hResult := DllCall( NumGet( NumGet( pIStream + 0 ) + 3 * A_PtrSize )	; IStream::Read 
							,	"ptr",	pIStream
							,	"ptr",	&Buffer		;	pv [out] A pointer to the buffer which the stream data is read into.
							,	"uint",	8192		;	cb [in] The number of bytes of data to read from the stream object.
							,	"ptr*",	cbRead	)	;	pcbRead [out] A pointer to a ULONG variable that receives the actual number of bytes read from the stream object. 
			oFile.RawWrite( &Buffer
						,	cbRead )
		}
		Until ( cbRead = 0 )
		ObjRelease( pIStream )
		oFile.Close(  )
		if FileExist(	A_ScriptDIr "\" guid_da_camera " " horario ".png" )	;	Just for test purpose
			Run,%		A_ScriptDIr "\" guid_da_camera " " horario ".png", , , pid
		else
			MsgBox Arquivo não existe
	}

	html_encode(str)														{
		f:=A_FormatInteger
		SetFormat, Integer, Hex
		If RegExMatch(str, "^\w+:/{0,2}", pr)
			StringTrimLeft, str, str, StrLen(pr)
		str:=StrReplace(str, "%","%25")
		Loop
			If RegExMatch(str, "i)[^\w\.~%]", char)
				str:=	Asc(char)="0xA"
				?		StrReplace(str,char,"%0" SubStr(Asc(char),3,1))
				:		StrReplace(str,char,"%" SubStr(Asc(char),3))
			Else Break
		if(InStr(str,"%9")>0)
		str:=StrReplace(str,"%9","%09")
		SetFormat, Integer, %f%
		Return, pr . str
	}

	layouts( server="" , token="" )											{
		/*	utilização do retorno em loop, var.layouts.count()
			var	:=	dguard.layouts( server , token )
			Loop,% var.layouts.Count()
				Msgbox %	var.layouts[A_Index].guid			"`n"
						.	var.layouts[A_Index].name			"`n"
						.	var.layouts[A_Index].readOnly		"`n"
						.	var.layouts[A_Index].status			"`n"
						.	var.layouts[A_Index].camerasCount	"`n"
						.	var.layouts[A_Index].firstCameraId	"`n"
						.	var.layouts[A_Index].mosaicGuid
			*/
		/*	Usado pelos sistemas abaixo
			C:\Users\dsantos\Desktop\AutoHotkey\D-Guard API\Câmeras nos Layouts.ahk
			*/
		/*	Necessário
				FUNCTIONS
			*/
		server	:=	StrLen( server ) = 0	;	parâmetro de servidor não enviado
				?	"localhost"
				:	server

		If	!Token
			token	:=	this.token( server )
		url		:=	"http://" server ":8081/api/layouts"
		return	json( Dguard.Request( url , token ) )
	}

	lista_cameras_layout( server , token , layoutGuid )						{
		;	var.servers[A_Index].CAMPO
		/*	Usado pelos sistemas abaixo
			C:\Users\dsantos\Desktop\AutoHotkey\D-Guard API\Câmeras nos Layouts.ahk
			*/

		layoutGuid := RegExReplace(  layoutGuid , "[{}]" )

		server	:=	StrLen( server ) = 0	;	parâmetro de servidor não enviado
				?	"localhost"
				:	server

		url		:= "http://" server ":8081/api/layouts/%7B" layoutGuid "%7D/cameras"
		
		retorno := Dguard.Request( url , token )
		
		return	json( retorno )
	}

	lista_cameras_operador( server , token )								{
		;	var.servers[A_Index].CAMPO
		/*	Usado pelos sistemas abaixo
			C:\Users\dsantos\Desktop\AutoHotkey\D-Guard API\Câmeras nos Layouts.ahk
		*/
		server	:=	StrLen( server )	=	0	;	parâmetro de servidor não enviado
				?	"localhost"
				:	server
		; url := 
		return	json( Dguard.Request( "http://" server ":8081/api/servers" , token ) )
	}

	Mover( win_id := "", win_title := "A" )									{
		if ( StrLen( win_id  ) = 0 )	{
			if ( StrLen( win_title ) > 1 )
				WinActivate,%	win_title
			win_id := WinActive( win_title )
		}
		SysGet, MonitorPrimary	,	MonitorPrimary
		SysGet, MonitorName		,	MonitorName		, %MonitorPrimary%
		SysGet, Monitor, Monitor,	%MonitorPrimary%
		OutputDebug % "Monitor:`t" MonitorPrimary "`n`nName:`t" MonitorName "`nX:`t" MonitorLeft "`nY:`t" MonitorTop "`nW:`t" MonitorRight-MonitorLeft "`nH`t" MonitorBottom-MonitorTop
		WinMove, ahk_id %win_id%, ,% MonitorLeft,% MonitorTop  ;,% MonitorRight-MonitorLeft,% MonitorBottom-MonitorTop
		return
	}

	new_layout( name, server="" )											{
		if !Server
			server		=	localhost
		token			:=	this.Token( server )
		dguard_cameras	=	GET "http://%server%:8081/api/layouts" -H "accept: application/json" -H "Authorization: bearer %token%"
		dguard_cameras	:=	Json( this.Curly( dguard_cameras ) )
		Loop,% dguard_cameras.layouts.Count()
			If	(dguard_cameras.layouts[A_Index].name = name ) {
				; msgbox %  dguard_cameras.layouts[A_Index].guid
				return dguard_cameras.layouts[A_Index].guid "&&" dguard_cameras.layouts[A_Index].camerasCount
			}
		a		:=	"\"""
		comando	:=	"POST ""http://localhost:8081/api/layouts"""
				.	" -H ""accept: application/json"""
				.	" -H ""Authorization: bearer " token """"
				.	" -H ""Content-Type: application/json"""
				.	" -d ""{ " a "name" a ": " a Name a "}"""
		new	:=	Json( this.curl( comando ) )
		return	new.layout.guid "&&0"
	}

	request( url , token="" , data="", method="GET" )						{
		static req := ComObjCreate( "Msxml2.XMLHTTP" )
		req.open( method, url, false )
		req.SetRequestHeader( "Authorization", "Bearer " token )	;	login local do dguard(admin)
		if	data
			req.send(data)
		Else
			req.send()
		return	% req.responseText
	}

	select_server( haystack_obj , value , key , return_key = "" , warn = 0 ){
		value := StrReplace( StrReplace( value , "`n" ), "`r" )
		For index, info in haystack_obj
			if ( info[ key ] = value )	{
				if ( StrLen( return_key ) > 0 )
					return info[ return_key ]
				Else
					return info[ key_ ]
			}
		if ( warn != 0 )
			return "Value '" value "' not found in array."
	}

	server( server = "" , guid = "" , token = "" )							{	;	TROCAR POR CAMERAS_INFO
		server	:=	StrLen( server ) = 0	;	parâmetro de servidor não enviado
				?	"localhost"
				:	server
		if !token
			token := this.Token()
		url := "http://" server ":8081/api/servers/`%7B" StrRep( guid , "{", "}" ) "`%7D"
		retorno := Dguard.Request( url , token )
		return	json( retorno )
	}

	token( server = "" , pass = "" , user = "" )							{
		/*	Usado pelos sistemas abaixo
			C:\Users\dsantos\Desktop\AutoHotkey\D-Guard API\Câmeras nos Layouts.ahk
		*/
		ip_s = 99									;	Prepara var com os ips do monitoramento
			Loop, 25
				monitoramento .= ip_s + A_Index ","
		ip := StrSplit( server , "." )				;	Verifica no ip[4] qual servidor foi requisitado as informações para ajustar a senha de requisição
		if (user = "conceitto"
		&&	StrLen( pass ) = 0 )					;	Específico para o sistema da conceitto
			pass = cjal2021
		server	:=	StrLen( server )	=	0		;	parâmetro de servidor não enviado
				?	"localhost"
				:	server
		user	:=	StrLen( user )	=	0			;	parâmetro de usuário não enviado
									?	"admin"
									:	user
		pass	:=	InStr( server , "vdm" )	>	0	;	se o parâmetro de servidor conter "vdm", define a senha padrão
											?	StrLen( pass ) = 0
												?	InStr( monitoramento , ip[4] )
													?	"admin"	:	pass
												:	pass
											:	pass
		if ( (ip[4] >= 100
		||	ip[4] < 126) && pass = "" )							;	Se o servidor solicitado for coluna de operador define a senha de administrador
			pass := "@dm1n"
		url	=	"http://%server%:8081/api/login" -H "accept: application/json"  -H "Content-Type: application/json" -d "{ \"username\": \"%user%\", \"password\": \"%pass%\"}"
		; OutputDebug % "Classe Dguard:`n`t" server
					; . "`n`t" user
					; . "`n`t" pass
		retorno	:=	StrReplace(	Dguard.curl( url , server , "POST" ) , """" )
		retorno	:=	SubStr( StrReplace( retorno , "{login:{") , 1 , InStr( retorno , ",serverDate")-9 )
		; MsgBox % Dguard.curl( url , server , "POST" )  "`n" Clipboard := url
		return	SubStr( retorno , InStr( retorno , "userToken:" )+10 )
	}

	virtual_matrix( server="" , token="" )									{
		server	:=	StrLen( server ) = 0	;	parâmetro de servidor não enviado
				?	"localhost"
				:	server

		If	!Token
			token	:=	this.token( server )
		
		c	:=	"PUT ""http://" server ":8081/api/virtual-matrix"""
			.	" -H ""accept: application/json"""
			.	" -H ""Authorization: bearer " token """"
			.	" -H ""Content-Type: application/json"""
			.	" -d ""{ \""machineName\"": \""" A_ComputerName "\"", \""enabled\"": true, \""activationMode\"": 1}"""

		return this.Curly( c )
	}

	workstation( comando )													{
		retorno := Dguard.curly( comando )
		if ( retorno = "{""workstations"":[]}" ) {
			retorno  = 
				(
					{
						"workstations": [
							{
							"guid": "ERRO"
							}
						]
					}
				)
			return	json( retorno )
		}
		Else
			return json( this.curly( comando ) )
	}
}