/*
	Depende da instalação do cUrl e configuração do path do mesmo
*/
if	inc_dguard
	Return
Global inc_dguard = 1

Class	dguard {
	
	cameras( server = "" , token = "" )											{
		;	Retorna guid, name, active e connected das câmeras cadastradas no servidor do dguard
		server	:=	StrLen( server ) = 0	;	parâmetro de servidor não enviado
				?	"localhost"
				:	server
		url := "http://" server ":8081/api/servers"
		retorno := Dguard.http( url , token )
		return	json( retorno )
	}
	
	cameras_info( server = "" , guid = "" , token = "" )						{
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
		retorno := Dguard.http( url , token )
		return	json( retorno )
	}

	contact_id( server = "" , guid = "" , token = "" )							{
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
		retorno := Dguard.http( url , token )
		return	json( retorno )
	}

	curl( comando , server = "" , tipo = "" )									{
		comando	:=	StrReplace( comando , "`n" )
		DetectHiddenWindows On
		Run %ComSpec%,, Hide, pid
		WinWait ahk_pid %pid%
		DllCall( "AttachConsole" , "UInt" , pid )
		WshShell := ComObjCreate( "Wscript.Shell" )
		if ( StrLen( tipo ) > 0 && StrLen( server ) > 0 )	{												;	Tem servidor e tipo
			; clipboard := "curl -X " tipo " " StrReplace( comando , "servidor" , server ) 
			exec := WshShell.Exec( "cmd /c curl -X " tipo " " StrReplace( comando , "servidor" , server ) )
			}
		else if ( StrLen( tipo ) > 0 && StrLen( server ) = 0 )												;	Não tem servidor e tem tipo
			exec := WshShell.Exec( "cmd /c curl -X " tipo " " comando )
		else if ( StrLen( tipo ) = 0 && StrLen( server ) > 0 )												;	Tem servidor e não tem tipo
			exec := WshShell.Exec( "cmd /c curl -X " StrReplace( comando , "servidor" , server ) )
		else if ( ( StrLen( TIPO ) = 0 && StrLen( SERVER ) = 0 ) && InSTr( COMANDO , "GET" ) = 0 )			;	Não tem servidor e não tem tipo, mas não é do tipo GET
			exec := WshShell.Exec( "cmd /c curl -X " comando )
		else																								;	Tipo GET
			exec := WshShell.Exec( "cmd /c curl -X GET " comando " -d" )
		DllCall( "FreeConsole" )
		Process Close,%	pid
		return exec.StdOut.ReadAll()
	}

	get_image( guid_da_camera , token = "" )									{	;	não está pronto
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

	http( url , token="" , data="" )												{
		; data:={"username":"demo","password":"test123"} ; key-val data to be posted
		; if StrLen( data ) {
		; 	try	{
		; 	createFormData(rData,rHeader,data) ; formats the data, stores in rData, header info in rHeader
		; 	hObject:=comObjectCreate("WinHttp.WinHttpRequest.5.1") ; create WinHttp object
		; 	hObject.setRequestHeader("Content-Type",rHeader) ; set content header
		; 	hObject.open("POST",endpoint) ; open a post event to the specified endpoint
		; 	hObject.send(rData) ; send request with data
			
		; 	}
		; 	catch e	{
		; 		return e.message
		; 	}
		; }
		; Else	{
			static req := ComObjCreate( "Msxml2.XMLHTTP" )
			req.open( "GET", url, false )
			req.SetRequestHeader( "Authorization", "Bearer " token )	;	login local do dguard(admin)
			req.SetRequestHeader( "If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT" )
			req.send()
			return	% req.responseText
		; }
	}

	layouts( server , token )													{
		/*	utilização do retorno em loop, var.layouts.count()
			var.layouts[A_Index].guid
			var.layouts[A_Index].name
			var.layouts[A_Index].readOnly
			var.layouts[A_Index].status
			var.layouts[A_Index].camerasCount
			var.layouts[A_Index].firstCameraId
			var.layouts[A_Index].mosaicGuid
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

		url		:=	"http://" server ":8081/api/layouts"

		retorno	:=	Dguard.http( url , token )

		return	json( retorno )
	}

	lista_cameras_layout( server , token , layoutGuid )							{
		;	var.servers[A_Index].CAMPO
		/*	Usado pelos sistemas abaixo
			C:\Users\dsantos\Desktop\AutoHotkey\D-Guard API\Câmeras nos Layouts.ahk
			*/

		layoutGuid := RegExReplace(  layoutGuid , "[{}]" )

		server	:=	StrLen( server ) = 0	;	parâmetro de servidor não enviado
				?	"localhost"
				:	server

		url		:= "http://" server ":8081/api/layouts/%7B" layoutGuid "%7D/cameras"
		
		retorno := Dguard.http( url , token )
		
		return	json( retorno )
	}

	lista_cameras_operador( server , token )									{
		;	var.servers[A_Index].CAMPO
		/*	Usado pelos sistemas abaixo
			C:\Users\dsantos\Desktop\AutoHotkey\D-Guard API\Câmeras nos Layouts.ahk
		*/
		server	:=	StrLen( server )	=	0	;	parâmetro de servidor não enviado
				?	"localhost"
				:	server
		; url := 
		return	json( Dguard.http( "http://" server ":8081/api/servers" , token ) )
	}

	Mover( win_id := "", win_title := "A" )										{
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

	select_server( haystack_obj , value , key , return_key = "" , warn = 0 )	{
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

	server( server = "" , guid = "" , token = "" )								{	;	TROCAR POR CAMERAS_INFO
		server	:=	StrLen( server ) = 0	;	parâmetro de servidor não enviado
				?	"localhost"
				:	server
		url := "http://" server ":8081/api/servers/`%7B" StrReplace( StrReplace( guid , "{" ) , "}" ) "`%7D"
		retorno := Dguard.http( url , token )
		return	json( retorno )
	}

	token( server = "" , pass = "" , user = "" )								{
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
		if (ip[4] > 100
		&&	ip[4] < 126 )							;	Se o servidor solicitado for coluna de operador define a senha de administrador
			pass := "@dm1n"
		url	=	"http://%server%:8081/api/login" -H "accept: application/json"  -H "Content-Type: application/json" -d "{ \"username\": \"%user%\", \"password\": \"%pass%\"}"
		OutputDebug % "Classe Dguard:`n`t" server
					. "`n`t" user
					. "`n`t" pass
		retorno	:=	StrReplace(	Dguard.curl( url , server , "POST" ) , """" )
		retorno	:=	SubStr( StrReplace( retorno , "{login:{") , 1 , InStr( retorno , ",serverDate")-9 )
		return	SubStr( retorno , InStr( retorno , "userToken:" )+10 )
	}

}