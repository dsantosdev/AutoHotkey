Class	dguard {

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

	get_image( guid_da_camera , token = "" )									{
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

	token( server = "" , pass = "" , user = "" )								{
		ip_s = 160									;	Prepara var com os ips do monitoramento
			Loop, 20
				monitoramento .= ip_s+A_Index ","
				monitoramento .= "184"
				ip := StrSplit( A_IpAddress1 , "." )
		if (user = "conceitto"
		&&	StrLen( pass ) = 0 )					;	Específico para o sistema da conceitto
			pass = cjal2021
		server	:=	StrLen( server )		=	0	;	parâmetro de servidor não enviado
				?	"localhost"
				:	server
		user	:=	StrLen( user )			=	0	;	parâmetro de usuário não enviado
									?	"admin"
									:	user
		pass	:=	InStr( server , "vdm" )	>	0	;	se o parâmetro de servidor conter "vdm", define a senha padrão
											?	StrLen( pass ) = 0
												?	InStr( monitoramento , ip[4] )
													?	"admin"	:	pass
												:	pass
											:	pass
		url	=	"http://%server%:8081/api/login" -H "accept: application/json"  -H "Content-Type: application/json" -d "{ \"username\": \"%user%\", \"password\": \"%pass%\"}"
		retorno	:=	StrReplace(	Dguard.curl( url , server , "POST" ) , """" )
		retorno	:=	SubStr( StrReplace( retorno , "{login:{") , 1 , InStr( retorno , ",serverDate")-9 )
		return	SubStr( retorno , InStr( retorno , "userToken:" )+10 )
	}

	http( url , token )															{
		static req := ComObjCreate( "Msxml2.XMLHTTP" )
		req.open( "GET", url, false )
		req.SetRequestHeader( "Authorization", "Bearer " token )	;	login local do dguard(admin)
		req.SetRequestHeader( "If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT" )
		req.send()
		return	% req.responseText
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

	server( server = "" , guid = "" , token = "" )								{
		server	:=	StrLen( server )	=	0	;	parâmetro de servidor não enviado
				?	"localhost"
				:	server
		url := "http://" server ":8081/api/servers/`%7B" StrReplace( StrReplace( guid , "{" ) , "}" ) "`%7D"
		retorno := Dguard.http( url , token )
		return	json( retorno )
	}

}

