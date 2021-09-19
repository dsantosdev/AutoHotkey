
Base64Dec( ByRef B64, ByRef Bin ) {  ; By SKAN / 18-Aug-2017
	Local Rqd := 0, BLen := StrLen(B64)                 ; CRYPT_STRING_BASE64 := 0x1
	DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
			, "UInt",0, "UIntP",Rqd, "Int",0, "Int",0 )
	VarSetCapacity( Bin, 128 ), VarSetCapacity( Bin, 0 ),  VarSetCapacity( Bin, Rqd, 0 )
	DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
			, "Ptr",&Bin, "UIntP",Rqd, "Int",0, "Int",0 )
	Return Rqd
}

Base64Enc( ByRef Bin, bytes, lenght := 64, l_spaces := 0 ) { ; By SKAN / 18-Aug-2017
	Local Rqd := 0, B64, B := "", N := 0 - lenght + 1  ; CRYPT_STRING_BASE64 := 0x1
	DllCall( "Crypt32.dll\CryptBinaryToString", "Ptr",&Bin ,"UInt",bytes, "UInt",0x1, "Ptr",0,   "UIntP",Rqd )
	VarSetCapacity( B64, Rqd * ( A_Isunicode ? 2 : 1 ), 0 )
	DllCall( "Crypt32.dll\CryptBinaryToString", "Ptr",&Bin, "UInt",bytes, "UInt",0x1, "Str",B64, "UIntP",Rqd )
	If ( lenght = 64 and ! l_spaces )
		Return B64
	B64 := StrReplace( B64, "`r`n" )        
	Loop % Ceil( StrLen(B64) / lenght )
		B .= Format("{1:" l_spaces "s}","" ) . SubStr( B64, N += lenght, lenght ) . "`n" 
	Return RTrim( B,"`n" )    
}

b64_file_enc(FileName) {
	FileGetSize, nBytes, %FileName%
	FileRead, Bin, *c %FileName%
	return Base64Enc(Bin, nBytes)
}

b64_file_dec(ByRef B64, FileName) {
	nBytes := Base64Dec(B64, Bin)
	FileOpen(FileName, "w").RawWrite(Bin, nBytes)
}

chrome_history() {	;	Bloqueia a exclusao de historico
	RegRead,	history,	HKLM,	SOFTWARE\Policies\Google\Chrome,	IncognitoEnabled
	if ( history != 0 )	{
		RegWrite, REG_DWORD,	HKEY_LOCAL_MACHINE, SOFTWARE\Policies\Google\Chrome,	AllowDeletingBrowserHistory,	0
		RegWrite, REG_DWORD,	HKLM, SOFTWARE\Policies\Google\Chrome,					AllowDeletingBrowserHistory,	0
	}
	return	OK
}

chrome_incognito() {	;	Bloqueia modo anonimo
	RegRead,	incognito,	HKLM,	SOFTWARE\Policies\Google\Chrome,	IncognitoEnabled
	if ( incognito != 0 )	{
		RegWrite, REG_DWORD,	HKEY_LOCAL_MACHINE, SOFTWARE\Policies\Google\Chrome,	IncognitoEnabled,	0
		RegWrite, REG_DWORD,	HKLM, SOFTWARE\Policies\Google\Chrome,					IncognitoEnabled,	0
	}
	return	OK
}

datetime( sql = "0", date = "" ) {
	If (	sql = 2
		&&	StrLen( date ) = 0 )	{
		MsgBox,0x40,ERRO, A função datetime() em modo SQL 2`, necessita que seja enviado o valor date para funcionar.
		Return
		}
	If ( sql = 1 )
		Return SubStr( A_Now, 1, 4 ) "-"  SubStr( A_Now, 5, 2 ) "-"  SubStr( A_Now, 7, 2 ) " "  SubStr( A_Now, 9, 2 ) ":"  SubStr( A_Now, 11, 2) ":"  SubStr( A_Now, 13, 2 ) ".000"
	else If ( sql = 2 )	{
		date := RegExReplace(date, "\D")
		Return SubStr( date, 5, 4 ) "-"  SubStr( date, 3, 2 ) "-"  SubStr( date, 1, 2 ) " "  SubStr( date, 9, 2 ) ":"  SubStr( date, 11, 2) ":"  SubStr( date, 13, 2 )
		}
	Return SubStr( A_Now, 7, 2 ) "/"  SubStr( A_Now, 5, 2 ) "/"  SubStr( A_Now, 1, 4 ) " "  SubStr( A_Now, 9, 2 ) ":"  SubStr( A_Now, 11, 2) ":"  SubStr( A_Now, 13, 2 )
}

formatseconds( Seconds ) {
	time := 19990101
	time += Seconds, seconds
	FormatTime, mmss, %time%, mm:ss
	return Seconds//3600 ":" mmss
}

json(ByRef src, args*) {
	static q := Chr(34)
	
	key := "", is_key := false
	stack := [ tree := [] ]
	is_arr := Object(tree, 1) ; ahk v1                    ; orig -> is_arr := { (tree): 1 }
	next := q "{[01234567890-tfn"
	pos := 0
	
	while ( (ch := SubStr(src, ++pos, 1)) != "" ) {
		if InStr(" `t`n`r", ch)
			continue
		if !InStr(next, ch, true) {
			testArr := StrSplit(SubStr(src, 1, pos), "`n")
			ln := testArr.Length()
			
			col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))

			msg := Format("{}: line {} col {} (char {})"
			,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
			  : (next == "'")     ? "Unterminated string starting at"
			  : (next == "\")     ? "Invalid \escape"
			  : (next == ":")     ? "Expecting ':' delimiter"
			  : (next == q)       ? "Expecting object key enclosed in double quotes"
			  : (next == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
			  : (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
			  : (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
			  : [ "Expecting JSON value(string, number, [true, false, null], object or array)"
			    , ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
			, ln, col, pos)

			throw Exception(msg, -1, ch)
		}
		
		is_array := is_arr[obj := stack[1]] 
		
		if i := InStr("{[", ch) { ; start new object / map?
			val := (i = 1) ? Object() : Array()	; ahk v1
			
			is_array ? obj.Push(val) : obj[key] := val
			stack.InsertAt(1,val)
			
			is_arr[val] := !(is_key := ch == "{")
			next := q (is_key ? "}" : "{[]0123456789-tfn")
		}
		else if InStr("}]", ch) {
			stack.RemoveAt(1)
			next := stack[1]==tree ? "" : is_arr[stack[1]] ? ",]" : ",}"
		}
		else if InStr(",:", ch) {
			is_key := (!is_array && ch == ",")
			next := is_key ? q : q "{[0123456789-tfn"
		}
		else { ; string | number | true | false | null
			if (ch == q) { ; string
				i := pos
				while i := InStr(src, q,, i+1) {
					val := StrReplace(SubStr(src, pos+1, i-pos-1), "\\", "\u005C")
					if (SubStr(val, 0) != "\")
						break
				}
				if !i ? (pos--, next := "'") : 0
					continue

				pos := i ; update pos

				val := StrReplace(val,    "\/",  "/")
				 val := StrReplace(val, "\" . q,    q)
				,val := StrReplace(val,    "\b", "`b")
				,val := StrReplace(val,    "\f", "`f")
				,val := StrReplace(val,    "\n", "`n")
				,val := StrReplace(val,    "\r", "`r")
				,val := StrReplace(val,    "\t", "`t")

				i := 0
				while i := InStr(val, "\",, i+1) {
					if (SubStr(val, i+1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
						continue 2

					xxxx := Abs("0x" . SubStr(val, i+2, 4)) ; \uXXXX - JSON unicode escape sequence
					if (A_IsUnicode || xxxx < 0x100)
						val := SubStr(val, 1, i-1) . Chr(xxxx) . SubStr(val, i+6)
				}
				
				if is_key {
					key := val, next := ":"
					continue
				}
			}
			else { ; number | true | false | null
				val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$",, pos)-pos)
				
				static number := "number", integer := "integer", float := "float"
				if val is %number%
				{
					if val is %integer%
						val += 0
					if val is %float%
						val += 0
					else if (val == "true" || val == "false")
						val := %val% + 0
					else if (val == "null")
						val := ""
					else if is_key {					; else if (pos--, next := "#")
						pos--, next := "#"					; continue
						continue
					}
				}
				
				pos += i-1
			}
			
			is_array ? obj.Push(val) : obj[key] := val
			next := obj == tree ? "" : is_array ? ",]" : ",}"
		}
	}
	
	return tree[1]
}

search_delay( delay = "500", done = "0" ) {
	if ( done = 0 )
		Loop
		{
			; OutputDebug % A_TimeIdleKeyboard
			if ( A_TimeIdleKeyboard > delay )	{
				Return	done = 0
				break
			}
		}
	Else
		Return	done = 0
}

http( url , token = "") {
	static req := ComObjCreate( "Msxml2.XMLHTTP" )
	req.open( "GET", url, false )
	if	( token = "" )
		req.SetRequestHeader( "Authorization", "Basic YWRtaW46QGRtMW4=" )	;	login local do dguard(admin)
	Else
		req.SetRequestHeader( "Authorization", token )	;	bearer custom
	req.SetRequestHeader( "If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT" )
	req.send()
	return	%	req.responseText
}

login( @usuario, @senha, @admin = "" ) {
	if ( @admin != "" )	{
		if InStr( admins, @usuario )
			return DllCall(	"advapi32\LogonUser"
						,	"str",	@usuario
						,	"str",	"Cotrijal"
						,	"str",	@senha
						,	"Ptr",	3
						,	"Ptr",	3
						,	"UintP"
						,	nSize	)	=	1
									?	"1"
									:	"0"
		Else
			Return 0
	}
	Else
		return DllCall(	"advapi32\LogonUser"
					,	"str",	@usuario
					,	"str",	"Cotrijal"
					,	"str",	@senha
					,	"Ptr",	3
					,	"Ptr",	3
					,	"UintP"
					,	nSize	)	=	1
									?	"1"
									:	"0"
}

notificar( ) {
	s =
		(
		SELECT TOP(1)	p.IdCliente
					,	p.QuandoAvisar
					,	p.Mensagem
					,	p.Assunto
					,	c.Nome
					,	p.Idaviso
		FROM
			[IrisSQL].[dbo].[Agenda] p
		LEFT JOIN
			[IrisSQL].[dbo].[Clientes] c
				ON p.IdCliente = c.IdUnico
		ORDER BY
			6 DESC
		)
		s := sql( s )
	if ( StrLen( last_id ) = 0 )	{
		last_id := s[2,6]
		return % last_id
		}
	if ( last_id < s[2, 6] )		{	;executa notificação
		subjm		:= s[2, 4]
		iadaviso	:= s[2, 6]
		if ( SubStr( A_IpAddress1, InStr( A_IpAddress1, ".",,,3 )+1 ) = 184 )	;	Remove errados
			If ( InStr( subjm, "Informou" ) > 0 )		{
				d = DELETE FROM [IrisSQL].[dbo].[Agenda] WHERE idaviso = '%iadaviso%'
				sql( d )
				return
			}
		last_id := s[2,6]
		TrayTip, % s[2,5] "`nNovo E-Mail - " datetime(), % s[2, 3]
		Random, easteregg, 1, 100
		if ( easteregg < 95 )
			som = car
			else
				som = yoda
		SoundPlay, \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\%som%.wav
		}
	if ( last_id > s[2, 6] )
		last_id := s[2, 6]
	GuiControl,	debug:,	debug4,% s[2,6] " - " last_id
	return	last_id
}

ping( address )	{
	rVal := []
	Loop, Parse, address, % A_Space
		addr	.=	addr
				?	A_Space "or Address = '" A_LoopField "'"
				:	 A_LoopField "'"
	colPings := ComObjGet( "winmgmts:" ).ExecQuery( "Select * From Win32_PingStatus where Address = '" addr )._NewEnum
	While colPings[ objStatus ]
		rVal.Push( [ ( ( oS := ( objStatus.StatusCode = "" or objStatus.StatusCode <> 0 ) ) ? "0" : "1" ) , objStatus.Address ] )
	if ( InStr( Address , A_Space ) > 0 )	;	Multi Addresses or not
		Return rVal
	Else
		Return ( ( oS := ( objStatus.StatusCode = "" or objStatus.StatusCode <> 0 ) ) ? "0" : "1" )
}


send_mail( destino, assunto, corpo, at:="") {
	pmsg := ComObjCreate("CDO.Message")
	pmsg.From := """Sistema Monitoramento"" <CapitaoCaverna@cotrijal.com.br>"
	pmsg.To := destino
	pmsg.Subject := assunto
	pmsg.TextBody := corpo
	sAttach := at
	fields := Object()
	fields.smtpserver := "mail.cotrijal.com.br"
	fields.smtpserverport := 587
	fields.smtpusessl := false
	fields.sendusing := 2 
	fields.smtpauthenticate := 1
	fields.sendusername := "SistemaMonitoramento@cotrijal.com.br"
	fields.sendpassword := ""
	fields.smtpconnectiontimeout := 10
	schema := "http://schemas.microsoft.com/cdo/configuration/"
	pfld := pmsg.Configuration.Fields
	For	field,	value	in	fields
		pfld.Item(schema . field):=value
	pfld.Update()
	Loop, Parse, sAttach, |, %A_Space%%A_Tab%
		pmsg.AddAttachment(A_LoopField)
	pmsg.Send()
	return
}

update( comando = "" ) {
	q = UPDATE [ASM].[dbo].[_gestao_sistema] SET [complemento1] = '%up%' WHERE [descricao] = '%ip%'
	sql(q, 3)
	if ( StrLen( sql_le ) = 0 )
		return 0
	return sql_le
}

