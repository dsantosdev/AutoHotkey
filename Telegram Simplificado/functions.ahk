if	functions_
	Return

functions_ = 1

Global sql_le, sql_lq

; MsgBox	%	html_encode("O código % que você enviou é inválido.`n`nSolicite um código válido com seu gestor.")


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

dguard_get_image( guid_da_camera, server, token_dguard = "" )	{
		horario := A_Now
		
		server := StrLen( server )	= 1
									? "vdm0" server
									: "vdm" server
		static req := ComObjCreate( "Msxml2.XMLHTTP" )
		req.open(	"GET"
				; ,	"http://vdm" server ":8081/api/servers/%7B" guid_da_camera "%7D/cameras/0/image.jpg"	;	para debug apenas, não usar!
				,	"http://" server ":8081/api/servers/%7B" guid_da_camera "%7D/cameras/0/image.jpg"
				,	false	)
		req.SetRequestHeader( "Authorization", "bearer " token_dguard  )
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
			OutputDebug % cbRead
		}
		Until ( cbRead = 0 || cbRead = "" )
		if ( cbRead = "" )
			Return "Fail"
		ObjRelease( pIStream )
		oFile.Close(  )
		if FileExist(	A_ScriptDIr "\" guid_da_camera " " horario ".png" )	;	Just for test purpose
			Return	A_ScriptDIr "\" guid_da_camera " " horario ".png"
		else
			Return "Fail"
}

html_encode(str)												{
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

Map( Array, SearchText, KeyIs="", Partial="0" )					{
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

Request(url)													{
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

StrReplaceN(Haystack,Needle,Replacement="",Instance=1)			{
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
	if(instr(query,"UPDATE")>0 and instr(query,"WHERE")=0)	{
		MsgBox, Você está tentando executar um UPDATE sem definir WHERE`, deseja realmente continuar? Isso alterará TODOS os dados da tabela.
		IfMsgBox,	No
			return
		}
	tipo=Driver={SQL Server};Server=srvvdm-bd\ASM;Uid=ahk;Pwd=139565Sa
	coer:="", txtout:=0, rd:="`n", cd:="CSV", str:=tipo
	If !(oCon:=ComObjCreate("ADODB.Connection"))
		Return "", ComObjError(1), ErrorLevel:="Error"
		, sql_LE:="Fatal Error: ADODB is not available."
	oCon.ConnectionTimeout:=9
	oCon.CursorLocation:=3
	oCon.CommandTimeout:=1800
	oCon.Open(str)
	If !(coer:=A_LastError)
		oRec:=oCon.execute(sql_lq:=query)
	If !(coer:=A_LastError)	{
		o3DA:=[]
		While IsObject(oRec)
			If !oRec.State
				oRec:=oRec.NextRecordset()
			Else	{
				oFld:=oRec.Fields
				o3DA.Insert(oTbl:=[])
				oTbl.Insert(oRow:=[])
				Loop % cols:=oFld.Count	{	;	Headers
					; MsgBox, %	oFld.Item(A_Index-1).Name
					oRow[A_Index]:=oFld.Item(A_Index-1).Name
					}
				While !oRec.EOF	{
					oTbl.Insert(oRow:=[])
					oRow.SetCapacity(cols)
					Loop % cols	{	;	Values
						; MsgBox	%	oFld.Item(A_Index-1).Value	
						oRow[A_Index]:=oFld.Item(A_Index-1).Value	
						}
					oRec.MoveNext()
					}
				oRec:=oRec.NextRecordset()
				}
		If(txtout)	{
			query:="x"
			Loop % o3DA.Count()	{
				query.=rd rd
				oTbl:=o3DA[A_Index]
				Loop % oTbl.Count()	{
					oRow:=oTbl[A_Index]
					Loop % oRow.Count()
						If(cd="CSV")	{
							str:=oRow[A_Index]
							StringReplace, str, str, ", "", A
							If !ErrorLevel || InStr(str, ",") || InStr(str, rd)
								str:="""" str """"
							query.=(A_Index=1?rd:",") str
							}
						Else
							query.=(A_Index=1?rd:cd) oRow[A_Index]
					}
				}
			query:=SubStr(query,2+3*StrLen(rd))
			}
		}
	Else	{
		oErr:=oCon.Errors
		query:="x"
		Loop % oErr.Count	{
			oFld:=oErr.Item(A_Index-1)
			str:=oFld.Description
			query.="`n`n" SubStr(str,1+InStr(str,"]",0,2+InStr(str,"][",0,0)))
				. "`n   Number: " oFld.Number
				. ", NativeError: " oFld.NativeError
				. ", Source: " oFld.Source
				. ", SQLState: " oFld.SQLState
			}
		sql_le:=SubStr(query,4)
		query:=""
		txtout:=1
		}
	oCon.Close()
	ComObjError( 0 )
	ErrorLevel:=coer
	if(StrLen(sql_le)>0 and StrLen(d)>0)
		MsgBox % sql_le "`n" sql_lq
	Return txtout?query:o3DA.Count()=1?o3DA[1]:o3DA
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