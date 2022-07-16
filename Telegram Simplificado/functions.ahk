if	functions_
	Return

functions_ = 1

Global sql_le, sql_lq

cam_list( cameras, message="" )	{
	message := html_encode( "Selecione a Câmera" )
	Loop,%	cameras.Count()-1	{
		nome	:=	cameras[A_Index+1,1]
		guid	:=	cameras[A_Index+1,2]
		server	:=	cameras[A_Index+1,3]
		if ( A_Index = cameras.Count()-1 )
		
			list	.=	"[{""text"" : """ nome """ , ""callback_data"" : """ guid """} ]"
		Else
			list	.=	"[{""text"" : """ nome """ , ""callback_data"" : """ guid """} ],`n"
	}

	keyb={
		(join
		"inline_keyboard":
		[	%list%
		],
		"resize_keyboard" : true }
		)
	OutputDebug, % "id " message_id " reply send cam list"
	url:=Token "/sendMessage?text=" message "&chat_id=" from_id "&reply_markup=" keyb ; "&reply_to_message_id=" message_id "&chat_id=" from_id
	return request(url)	
}

curly( comando, assync="0" )											{
	DetectHiddenWindows On
	Run %ComSpec%,, Hide, pid
	WinWait ahk_pid %pid%
	DllCall( "AttachConsole" , "UInt" , pid )
	WshShell	:= ComObjCreate( "Wscript.Shell" )
	; OutputDebug % clipboard := comando
	exec		:= WshShell.Exec(  clipboard := "cmd /c curl -X " comando )
	DllCall( "FreeConsole" )
	Process Close,%	pid
	return exec.StdOut.ReadAll()
}

datetime( sql=0, date="", format="" )							{
	sql	:= RegExReplace( sql, "[^\d]+" )
	date:= RegExReplace( date, "[^\d]+" )
	if Strlen( sql ) = 14	;	 se a data foi passada no campo de sql, ajusta as variáveis
		is_date:=sql, sql:=0, date:=is_date
	If(	sql = 2
	&&	StrLen( date ) = 0 )	{
		MsgBox,0x40,ERRO, A função datetime() em modo SQL 2`, necessita que seja enviado o valor date para funcionar.
		Return
	}
	If( sql = 1 )
		Return		SubStr( A_Now, 1, 4 ) "-"  SubStr( A_Now, 5, 2 ) "-"  SubStr( A_Now, 7, 2 )
			.	" " SubStr( A_Now, 9, 2 ) ":"  SubStr( A_Now, 11, 2) ":"  SubStr( A_Now, 13, 2 ) ".000"
	else If ( sql = 2 )
		Return		SubStr( date, 5, 4 ) "-"  SubStr( date, 3, 2 ) "-"  SubStr( date, 1, 2 )
			.	" " SubStr( date, 9, 2 ) ":"  SubStr( date, 11, 2) ":"  SubStr( date, 13, 2 )
	else If(	sql	=	3
	&&			date!=	"" )	;	valor passado junto
		Return		SubStr( date, 1, 4 ) "-"  SubStr( date, 5, 2 ) "-"  SubStr( date, 7, 2 )
			.	" " SubStr( date, 9, 2 ) ":"  SubStr( date, 11, 2) ":"  SubStr( date, 13, 2 )
	Else If(	sql	=	0
	&&			date!=  "")
		return		SubStr( date, 7, 2 ) "/"  SubStr( date, 5, 2 ) "/"  SubStr( date, 1, 4 )
			.	" " SubStr( date, 9, 2 ) ":"  SubStr( date, 11, 2) ":"  SubStr( date, 13, 2 )
	Else
		Return		SubStr( A_Now, 7, 2 ) "/"  SubStr( A_Now, 5, 2 ) "/"  SubStr( A_Now, 1, 4 )
			.	" " SubStr( A_Now, 9, 2 ) ":"  SubStr( A_Now, 11, 2) ":"  SubStr( A_Now, 13, 2 )
}

dguard_curl( comando , server = "" , tipo = "" )				{
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

dguard_token( server, pass = "", user = "" )					{
	/*	Usado pelos sistemas abaixo
		C:\Users\dsantos\Desktop\AutoHotkey\D-Guard API\Câmeras nos Layouts.ahk
	*/
	server := StrLen( server )	= 1
								? "vdm0" server
								: "vdm" server
	if	!user
		user = admin
	if	!pass
		pass = admin
	url	=	"http://%server%:8081/api/login" -H "accept: application/json"  -H "Content-Type: application/json" -d "{ \"username\": \"%user%\", \"password\": \"%pass%\"}"
	OutputDebug % "Classe Dguard:`n`t" server
				. "`n`t" user
				. "`n`t" pass
	retorno	:=	StrReplace(	dguard_curl( url , server , "POST" ) , """" )
	retorno	:=	SubStr( StrReplace( retorno , "{login:{") , 1 , InStr( retorno , ",serverDate")-9 )
	return	SubStr( retorno , InStr( retorno , "userToken:" )+10 )
}

dguard_get_image( guid_da_camera, server, token = "" )								{	;	não está pronto
	horario := A_Now
	if StrLen( server ) = 1
		server := "vdm0" server
	comando	:=	"GET ""http://" server ":8081/api/servers/%7B" guid_da_camera "%7D/cameras/0/image.jpg"""
			.	" -H ""accept: image/jpeg"""
			.	" -H ""Authorization: bearer " token """"
			.	" --output """ A_ScriptDIr "\" guid_da_camera " " horario ".jpg"""
	curly( comando )
	; loop {
		; if	FileExist( A_ScriptDIr "\" guid_da_camera " " horario ".jpg" ) {
			; Sleep, 2000
			; break
		; }

	; }
	Return A_ScriptDIr "\" guid_da_camera " " horario ".jpg"
}

html_encode(str)												{
	f:=A_FormatInteger
	SetFormat, Integer, Hex
	If	RegExMatch( str, "^\w+:/{0,2}", pr )
		StringTrimLeft, str, str, StrLen( pr )
	str	:=	StrReplace( str, "%","%25" )
	Loop
		If	RegExMatch( str, "i)[^\w\.~%]", char )
			str:=	Asc(char)="0xA"
			?		StrReplace(str,char,"%0" SubStr(Asc(char),3,1))
			:		StrReplace(str,char,"%" SubStr(Asc(char),3))
		Else Break
	if( InStr( str, "%9" ) > 0 )
		str	:=	StrReplace( str, "%9", "%09" )
	SetFormat, Integer, %f%
	Return, pr . str
}

InArray(Array, SearchText, MatchWord="0")						{
	if(StrLen(SearchText)=0)
		return 0
	if !(IsObject(Array))	{
		throw Exception("Não é um array!", -1, Array)
		return 0
		}
	if(MatchWord=1) {
		for index, ArrayText in Array
			if(ArrayText=SearchText)
				return index
	}
	else {
		for index, ArrayText in Array
		; {
			; MsgBox % ArrayText " - " SearchText
		
			if(InStr(ArrayText,SearchText)>0)
				return index
		; }
	}
	return 0
}

new_mail( to, subject, body, from := "", attach := "", cc* )	{
	OutputDebug, % "sending mail"
	if ( StrLen( from ) = 0 )
		from := """Bot Telegram Monitoramento"" <do-not-reply@cotrijal.com.br>"
	Else
		from := """Bot Telegram Monitoramento"" <" from ">"
	if cc
		Loop,% cc.Count()
			copia .= cc[ A_Index ] ","
	pmsg							:= ComObjCreate( "CDO.Message" )
	pmsg.From						:= from
	pmsg.To							:= to
	pmsg.CC							:= copia
	pmsg.Subject					:= subject
	pmsg.TextBody					:= body
	sAttach							:= attach

	fields							:= Object()
	fields.smtpserver				:= "mail.cotrijal.com.br"
	fields.smtpserverport			:= 587
	fields.smtpusessl				:= false
	fields.sendusing				:= 2
	fields.smtpauthenticate			:= 1
	fields.sendusername				:= "TelegramBotMonitoramento@cotrijal.com.br"
	fields.sendpassword				:= ""
	fields.smtpconnectiontimeout	:= 10
	schema							:= "http://schemas.microsoft.com/cdo/configuration/"
	pfld 							:= pmsg.Configuration.Fields

	For	field, value in fields
		pfld.Item( schema field ) := value
	pfld.Update()


	Loop, Parse, sAttach, |, %A_Space%%A_Tab%
		pmsg.AddAttachment( A_LoopField )

	pmsg.Send()
	return
}

map( Array, SearchText, KeyIs="", Partial="0" )					{
	if( StrLen( SearchText ) = 0 )
		return 0
	if !IsObject( Array )	{
		throw Exception( "Não é um dicionário!", -1, Array )
		return 0
	}
	if( StrLen( KeyIs ) = 0 )	{
		For index in Array
			For key, ArrayText in Array[index]
				if( ArrayText = SearchText )
					return	index
	}
	if( StrLen( KeyIs ) != 0
	&&	Partial = 0 )	{
		For index in Array
			For key, ArrayText in Array[index]
				if( key = KeyIs )
					if( ArrayText = SearchText )
						return	index
	}
	if( StrLen( KeyIs) !=0
	&&	Partial = 1 )	{
		list	:=	[]
		For index in Array
			For key, ArrayText in Array[index]
				if( key = KeyIs )
					if( InStr( ArrayText, SearchText ) > 0 )
						list.Push( index )
	}
	return list.Count() = ""
						? 0
						: list
}

phone( number )													{
	; Msgbox	%	subStr( number, 3, 1 ) "`n" number
	if(	SubStr( number, 3, 1 ) != "9"
	&&	SubStr( number, 3, 1 ) != "8" )
		Return "0 ( " SubStr( number, 1, 2 ) " ) " SubStr( number, 3, 4 ) "-" SubStr( number, 7 )
	Else
		Return "0 ( " SubStr( number, 1, 3 ) " ) " SubStr( number, 4, 4 ) "-" SubStr( number, 8 )
}

request(url)													{
	req	:=	ComObjCreate( "WinHttp.WinHttpRequest.5.1" )
	req.open( "GET", url, false )
	req.SetRequestHeader( "If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT" )
	req.send()
	if( StrLen( req.responseText ) = 0 )	{
		req := ComObjCreate( "Msxml2.XMLHTTP" )
		req.open( "GET", url, false )
		req.SetRequestHeader( "If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT" )
		req.send()
		if( debug = 3 )
			OutputDebug	%	"`t`tMSXML2:`n" req.responseText
		return	req.responseText
	}
	if( debug = 3 )
		OutputDebug	%	"`t`tWinHttp:`n"	req.responseText
	return	req.responseText
}

strrep( haystack , separator = ":" , needles* )	{
	/*
		texto :=	"Nome da câmera alterado dê:[n]'a'[n][t]para:[n]'b'[n]"
		MsgBox %  StrRep( texto , , "[n]:%0A", "[t]:%09" ) parametros
	*/
	for i, v in needles
	{
		if ( InStr( v , separator ) > 0 )	{
			SearchText	:= SubStr( v, 1 , InStr( v , separator )-1 )	
			ReplaceText := SubStr( v,InStr( v , separator )+1 )
		}
		Else	{
			SearchText	:=	v
			ReplaceText	:=	""
		}
		haystack := StrReplace( haystack, SearchText , ReplaceText )
	}
	Return haystack

}

strreplacen(Haystack,Needle,Replacement="",Instance=1)			{
	If !(Instance:=0 | Instance)	{
		StringReplace, Haystack, Haystack, %Needle%, %Replacement%, A
		Return Haystack
		}
	Else Instance:="L" Instance
	StringReplace, Instance, Instance, L-, R
	StringGetPos, Instance, Haystack, %Needle%, %Instance%
	If ErrorLevel
		Return Haystack
	StringTrimLeft, Needle, HayStack, Instance+ StrLen( Needle )
	StringLeft, HayStack, HayStack, Instance
	Return HayStack Replacement Needle
}

sql(query,tipo=1,d="")											{
	ListLines, Off
	;	ADOSQL modified
	if ( instr( query, "UPDATE" ) > 0 && instr( query, "WHERE" ) = 0
		&&	update_in_query = 0 )	{
			clipboard := query
		MsgBox,4 , ,% "Você está tentando executar um UPDATE sem definir WHERE`, deseja realmente continuar? Isso alterará TODOS os dados da tabela`n." SubStr( query, InStr(query, "update")-10, instr(query, "update")+20 )
		IfMsgBox,	No
			return
		Else
			clipboard := query
		}

	if ( tipo = 1 )
		tipo=Driver={SQL Server};Server=srvvdm-bd\iris10db;Uid=ahk;Pwd=139565Sa
	else if ( tipo = 2 )
		tipo=Driver={Oracle in ora_moni};dbq=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oraprod)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=prod)));Uid=asm;Pwd=cot2020asm
	else if ( tipo = 3 )
		tipo=Driver={SQL Server};Server=srvvdm-bd\ASM;Uid=ahk;Pwd=139565Sa
	else {
		MsgBox Tipo de conexão indefinido.
		return
	}

	if !InStr( query, "[ASM].[ASM]." )
		if ( tipo = 1 )
			query := StrReplace( query, "[ASM].[dbo]", "[ASM].[ASM].[dbo]", , -1 )
	coer := "", txtout := 0, rd := "`n", cd := "CSV", str := tipo
	If ( 9 < oTbl := 9 + InStr( ";" str, ";RowDelim=" ) )	{
		rd := SubStr( str, oTbl, 0 - oTbl + oRow := InStr( str ";", ";", 0, oTbl ) )
		str := SubStr( str, 1, oTbl - 11 ) SubStr( str, oRow )
		txtout := 1
		}
	If ( 9 < oTbl := 9 + InStr( ";" str, ";ColDelim=" ) )	{
		cd := SubStr( str, oTbl, 0 - oTbl + oRow := InStr( str ";", ";", 0, oTbl ) )
		str := SubStr( str, 1, oTbl - 11 ) SubStr( str, oRow )
		txtout := 1
		}
	ComObjError( 0 )
	If !( oCon := ComObjCreate( "ADODB.Connection" ) )
		Return "", ComObjError( 1 ), ErrorLevel := "Error"
		, sql_le := "Fatal Error: ADODB is not available."
	oCon.ConnectionTimeout := 9
	oCon.CursorLocation := 3
	oCon.CommandTimeout := 1800
	oCon.Open(str)
	If !( coer := A_LastError )
		oRec := oCon.execute( sql_lq := query )
	If !( coer := A_LastError )	{
		o3DA := []
		While IsObject( oRec )
			If !oRec.State 
				oRec := oRec.NextRecordset()
			Else	{
				oFld := oRec.Fields
				o3DA.Insert( oTbl := [] )
				oTbl.Insert( oRow := [] )
				Loop % cols := oFld.Count
					oRow[ A_Index ] := oFld.Item( A_Index - 1 ).Name
				While !oRec.EOF
				{
					oTbl.Insert( oRow := [] )
					oRow.SetCapacity( cols )
					Loop % cols
						oRow[ A_Index ] := oFld.Item( A_Index - 1 ).Value	
					oRec.MoveNext()
					}
				oRec := oRec.NextRecordset()
				}
		If (txtout)	{
			query := "x"
			Loop % o3DA.Count()	{
				query .= rd rd
				oTbl := o3DA[ A_Index ]
				Loop % oTbl.Count()	{
					oRow := oTbl[ A_Index ]
					Loop % oRow.Count()
						If ( cd = "CSV" )	{
							str := oRow[ A_Index ]
							StringReplace, str, str, ", "", A
							If !ErrorLevel || InStr( str, "," ) || InStr( str, rd )
								str := """" str """"
							query .= ( A_Index = 1 ? rd : "," ) str
							}
						Else
							query .= ( A_Index = 1 ? rd : cd ) oRow[ A_Index ]
					}
				}
			query := SubStr( query, 2 + 3 * StrLen( rd ) )
			}
		}
	Else	{
		oErr := oCon.Errors
		query := "x"
		Loop % oErr.Count	{
			oFld := oErr.Item( A_Index - 1 )
			str := oFld.Description
			query .= "`n`n" SubStr( str, 1 + InStr( str, "]", 0, 2 + InStr( str, "][", 0, 0 ) ) )
				. "`n   Number: " oFld.Number
				. ", NativeError: " oFld.NativeError
				. ", Source: " oFld.Source
				. ", SQLState: " oFld.SQLState
			}
		sql_le := SubStr( query, 4 )
		query := ""
		txtout := 1
		}
	oCon.Close()
	ComObjError( 0 )
	ErrorLevel := coer
	if (	StrLen( sql_le ) > 0
		&&	StrLen( d ) > 0
		&&	d <> "o" )
		MsgBox % sql_le "`n" sql_lq
	if (	d	= "o"
			&&	StrLen(sql_le) > 0 )
		OutputDebug % "Error:`n`t"	sql_le "`nQuery`n`t" clipboard:=sql_lq
	ListLines, On
	Return txtout
				?	query
				:	o3DA.MaxIndex() =	1
									?	o3DA[1]
									:	o3DA
}

randompass(unidade="")											{
	FileEncoding, UTF-8
	if !unidade
		unidade := SubStr(mtext, InStr( mtext, A_Space )+1)
	if( StrLen(unidade) < 4 )
		Loop,% 4 - StrLen(unidade)
			unidade := "0" unidade
	s=
		(
			SELECT TOP(3)
				Cliente,
					SUBSTRING(Evento,1,1),
					CONCAT(SUBSTRING(evento,2,3),Substring(zona,1,1)),
					sequencia
				FROM
					[IrisSQL].[dbo].[Eventos]
				WHERE
					(	Evento LIKE '2`%'
					OR	Evento LIKE '4`%'
					OR	Evento LIKE '6`%') AND
					Cliente = '1%unidade%'
				ORDER BY
					4 DESC
		)
		s	:=	sql(s)
	mensagem := s.Count()-1 > 0
				?	  "Senha 1 = "		s[2,3]
					. "`nSenha 2 = "	s[3,3]
					. "`nSenha 3 = "	s[4,3]
				:	"Não há senha de uso único ativada neste cliente"
	new_mail( "dsantos@cotrijal.com.br", "Senha de uso unico Solicitada", "Cliente do Iris:`n`t" s[2,1]"`n`n" mensagem "`n`nSolicitadas por:`n`t" first_name "`nTelegram ID:`n`t" from_id,,,"alberto@cotrijal.com.br", "arsilva@cotrijal.com.br", "ddiel@cotrijal.com.br", "egraff@cotrijal.com.br" )
	SendText( html_encode( mensagem ) )
	return	
}

user_list( dados, message="" )	{
	message := html_encode( "Selecione o colaborador" )
	Loop,%	dados.Count()-1	{
		nome	:=	dados[A_Index+1,1]
		pkid	:=	dados[A_Index+1,15]
		if ( A_Index = dados.Count()-1 )
		
			list	.=	"[{""text"" : """ nome """ , ""callback_data"" : """ pkid """} ]"
		Else
			list	.=	"[{""text"" : """ nome """ , ""callback_data"" : """ pkid """} ],`n"
	}

	keyb={
		(join
		"inline_keyboard":
		[	%list%
		],
		"resize_keyboard" : true }
		)
	OutputDebug, % "id " message_id " reply send user list"
	url:=Token "/sendMessage?text=" message "&chat_id=" from_id "&reply_markup=" keyb ; "&reply_to_message_id=" message_id "&chat_id=" from_id
	return request(url)	
}


;	BLOCO DE PREPARAÇÃO DE IMAGEM PARA ENVIO
	RequestFormData( url_str, objParam )	{								; Upload multipart/form-data
			CreateFormData( postData, hdr_ContentType, objParam )
			whr := ComObjCreate( "WinHttp.WinHttpRequest.5.1" )
			whr.Open( "POST", url_str, true )
			whr.SetRequestHeader( "Content-Type", hdr_ContentType )
			whr.Option( 6 ) := False ; No auto redirect
			whr.Send( postData )
			whr.WaitForResponse()
			json_resp := whr.ResponseText
			whr :=										; free COM object
			return json_resp							; will return a JSON string that contains, among many other things, the file_id of the uploaded file
	}
	;###################################################################################################################
	/*
		CreateFormData - Creates "multipart/form-data" for http post

		Usage: CreateFormData(ByRef retData, ByRef retHeader, objParam)

			retData   - (out) Data used for HTTP POST.
			retHeader - (out) Content-Type header used for HTTP POST.
			objParam  - (in)  An object defines the form parameters.

						To specify files, use array as the value. Example:
							objParam := { "key1": "value1"
										, "upload[]": ["1.png", "2.png"] }

		Requirement: BinArr.ahk -- https://gist.github.com/tmplinshi/a97d9a99b9aa5a65fd20
		Version    : 1.20 / 2016-6-17 - Added CreateFormData_WinInet(), which can be used for VxE's HTTPRequest().
					1.10 / 2015-6-23 - Fixed a bug
					1.00 / 2015-5-14
	*/

	; Used for WinHttp.WinHttpRequest.5.1, Msxml2.XMLHTTP ...
	CreateFormData( ByRef retData, ByRef retHeader, objParam ) {
		New CreateFormData( retData, retHeader, objParam )
	}

	; Used for WinInet
	CreateFormData_WinInet( ByRef retData, ByRef retHeader, objParam ) {
		New CreateFormData( safeArr, retHeader, objParam )

		size := safeArr.MaxIndex() + 1
		VarSetCapacity(retData, size, 1)
		DllCall( "oleaut32\SafeArrayAccessData", "ptr", ComObjValue( safeArr ), "ptr*", pdata )
		DllCall( "RtlMoveMemory", "ptr", &retData, "ptr", pdata, "ptr", size )
		DllCall( "oleaut32\SafeArrayUnaccessData", "ptr", ComObjValue( safeArr ) )
	}

	Class CreateFormData {

		__New( ByRef retData, ByRef retHeader, objParam ) {

			CRLF := "`r`n"

			Boundary := this.RandomBoundary()
			BoundaryLine := "------------------------------" . Boundary

			; Loop input paramters
			binArrs := []
			For k, v in objParam
			{
				If IsObject(v) {
					For i, FileName in v
					{
						str := BoundaryLine . CRLF
							. "Content-Disposition: form-data; name=""" . k . """; filename=""" . FileName . """" . CRLF
							. "Content-Type: " . this.MimeType(FileName) . CRLF . CRLF
						binArrs.Push( BinArr_FromString( str ) )
						binArrs.Push( BinArr_FromFile( FileName ) )
						binArrs.Push( BinArr_FromString( CRLF ) )
					}
				}
				Else {
					str := BoundaryLine . CRLF
						. "Content-Disposition: form-data; name=""" . k """" . CRLF . CRLF
						. v . CRLF
					binArrs.Push( BinArr_FromString( str ) )
				}
			}

			str := BoundaryLine . "--" . CRLF
			binArrs.Push( BinArr_FromString( str ) )

			retData := BinArr_Join( binArrs* )
			retHeader := "multipart/form-data; boundary=----------------------------" . Boundary
		}

		RandomBoundary() {
			str := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"
			Sort, str, D| Random
			str := StrReplace( str, "|" )
			Return SubStr( str, 1, 12 )
		}

		MimeType( FileName ) {
			n := FileOpen( FileName, "r" ).ReadUInt()
			Return	( n        = 0x474E5089 ) ? "image/png"
				:	( n        = 0x38464947 ) ? "image/gif"
				:	( n&0xFFFF = 0x4D42     ) ? "image/bmp"
				:	( n&0xFFFF = 0xD8FF     ) ? "image/jpeg"
				:	( n&0xFFFF = 0x4949     ) ? "image/tiff"
				:	( n&0xFFFF = 0x4D4D     ) ? "image/tiff"
				:	"application/octet-stream"
		}

	}
	;#############################################################################################################
	; Update: 2015-6-4 - Added BinArr_ToFile()

	BinArr_FromString( str ) {
		oADO := ComObjCreate( "ADODB.Stream" )

		oADO.Type := 2 ; adTypeText
		oADO.Mode := 3 ; adModeReadWrite
		oADO.Open
		oADO.Charset := "UTF-8"
		oADO.WriteText( str )

		oADO.Position := 0
		oADO.Type := 1 ; adTypeBinary
		oADO.Position := 3 ; Skip UTF-8 BOM
		return oADO.Read, oADO.Close
	}

	BinArr_FromFile( FileName ) {
		oADO := ComObjCreate( "ADODB.Stream" )

		oADO.Type := 1 ; adTypeBinary
		oADO.Open
		oADO.LoadFromFile( FileName )
		return oADO.Read, oADO.Close
	}

	BinArr_Join( Arrays* ) {
		oADO := ComObjCreate( "ADODB.Stream" )

		oADO.Type := 1 ; adTypeBinary
		oADO.Mode := 3 ; adModeReadWrite
		oADO.Open
		For i, arr in Arrays
			oADO.Write( arr )
		oADO.Position := 0
		return oADO.Read, oADO.Close
	}

	BinArr_ToString( BinArr, Encoding := "UTF-8" ) {
		oADO := ComObjCreate( "ADODB.Stream" )

		oADO.Type := 1 ; adTypeBinary
		oADO.Mode := 3 ; adModeReadWrite
		oADO.Open
		oADO.Write(BinArr)

		oADO.Position := 0
		oADO.Type := 2 ; adTypeText
		oADO.Charset  := Encoding 
		return oADO.ReadText, oADO.Close
	}

	BinArr_ToFile( BinArr, FileName ) {
		oADO := ComObjCreate( "ADODB.Stream" )

		oADO.Type := 1 ; adTypeBinary
		oADO.Open
		oADO.Write( BinArr )
		oADO.SaveToFile( FileName, 2 )
		oADO.Close
	}