Global sql_le, sql_lq
; MsgBox	%	html_encode("O código % que você enviou é inválido.`n`nSolicite um código válido com seu gestor.")
sql(query,tipo=1,d="")								{
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

html_encode(str)										{
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
InArray(Array, SearchText,MatchWord="0")				{
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
Map( Array, SearchText, KeyIs="", Partial="0" )			{
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
Request(url)											{
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
StrReplaceN(Haystack,Needle,Replacement="",Instance=1)	{
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