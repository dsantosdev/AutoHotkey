;	Header & Globals
	Global	inc_telegram	=	1
		,	bot_token		:=	"https://api.telegram.org/bot1510356494:AAFkppxELD9JISyZglP0r0c-Q3STc4tKTpo"
		,	chat_id			=	-1001729068003	;	canal de teste
	; #IncludeAgain	..\class\functions.ahk
;

Class	Telegram {

	Request( url )					{
		req := ComObjCreate( "WinHttp.WinHttpRequest.5.1" )
		req.open( "GET" , url , false )
		req.SetRequestHeader( "If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT" )
		req.send()
		; MsgBox % url
		if(	strLen( req.responseText ) = 0 ){
			req := ComObjCreate("Msxml2.XMLHTTP")
			req.open( "GET" , url , false )
			req.SetRequestHeader( "If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT" )
			req.send()
			if ( debug = 3 )
				OutputDebug	%	"`t`tMSXML2:`n" req.responseText
			return	%	req.responseText
		}
		if ( debug = 3 )
			OutputDebug	%	"`t`tWinHttp:`n"	req.responseText
		return	req.responseText
	}

	SendMessage( texto , params* )	{
		;	exemplo de uso
			;	telegram.SendMessage( "exemplo[n]```_texto_[n]*bold*```", "parse_mode=markdownv2" , "chat_id=-1001729068003" )
		if ( params.Count() > 0 )
			Loop,% params.Count()	{									;	Altera chat_id da conversa destino se enviado
				if ( InStr( params[A_Index], "chat_id" ) > 0 )	{
					chat_id	:=	SubStr( params[A_Index] , InStr( params[A_Index] , "=" )+1 )
					Continue
				}
				parametros .= "&" params[A_Index]
			}
		; chat_id = -1001729068003	;	Canal de testes
		url	:=	bot_token												;	URL e TOKEN do bot
			.	"/sendmessage?chat_id=" chat_id							;	Chat_id da conversa que deverá receber a msg
			.	"&text=" StrRep( texto , , "[n]:%0A", "[t]:%09%09" )	;	Insere as novas linhas e tabulações no formato URI
			.	parametros												;	Adiciona parâmetros adicionas a mensagem
		; MsgBox % telegram.request( url )
		return	telegram.request( url )
	}

}