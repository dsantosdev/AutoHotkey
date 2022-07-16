if	telegram_
	Return

telegram_ = 1

GetNewMessages( offset = "" )					{
	;	https://api.telegram.org/bot1510356494:AAFkppxELD9JISyZglP0r0c-Q3STc4tKTpo/getupdates
	return request( token "/getupdates?offset=" offset )
}

DeleteMessage( HowMany=1, minusMessageId=0 )	{
	msgid	:=	minusMessageId	> 0
								? message_id - minusMessageId
								: message_id + 1
	Loop,%	HowMany	{
		url	:=	token "/deleteMessage?chat_id=" from_id "&message_id=" msgid-1
		; Msgbox	%	url
		return request( url ) "`n`t" msgid-1
	}
}

RemoveMessage( HowMany=1, msgid="" )	{
	if	!msgid
		msgid	:= message_id
	Else
		msgid	:= msgid+1
	Loop,%	HowMany	{
		url	:=	token "/deleteMessage?chat_id=" from_id "&message_id=" msgid := msgid-1
		OutputDebug % "removido: " msgid
		request( url )
	}
	Return
}

RemoveKeyb( text="" )			{	;	NOVO
	keyb	=	{"remove_keyboard" : true }
	url		:=	Token "/sendMessage?text=" html_encode( text ) "&chat_id=" from_id "&reply_markup=" keyb
	r		:=	request(url)
	DeleteMessage()
	Return	r
}

SendImage( file, caption:="", params* )	{
	if params.Count() {
		text = teste
		Loop,% params.Count()
			parameters	.=	"&" params[A_Index]
		url := token "/sendPhoto?caption=" caption parameters
		objParam := {"chat_id"	: from_ID
					,"photo"	: [file] }
	}
	Else {
		url := token "/sendPhoto?caption=" caption
		objParam := {	"chat_id"	: from_ID																				
					, 	"photo"		: [file]  }
	}
	return RequestFormData( url, objParam )	
}

SendText( text, replyMarkup="", parseMode="", params* )	{
	if InStr( text ,"\x" )
		text := StrReplace( text, "\x", "`%"  )
	if params.Count() {
		Loop,% params.Count()
			parameters .= "&" params[A_Index]
		url	:=	token "/sendmessage?chat_id=" from_ID "&text=" text "&reply_markup=" replyMarkup "&parse_mode=" parseMode parameters
	}
	Else
		url	:=	token "/sendmessage?chat_id=" from_ID "&text=" text "&reply_markup=" replyMarkup "&parse_mode=" parseMode
		Clipboard:=url
	return Request( url )
}

SendSticker( text, replyMarkup="", parseMode="" ){
	url	:=	token "/sendSticker?chat_id=" from_ID "&sticker=" html_encode( text ) "&reply_markup=" replyMarkup "&parse_mode=" parseMode
	return request( url )
}

InlineButtons( cameras, message="Escolha a câmera:" )	{
	keyb={
		(join
		"inline_keyboard":
		[ [{"text"	:	"Login"			,	"callback_data"	:	"Login1"},
		{	"text"	:	"Buscar Contato",	"callback_data"	:	"buscaContato1"} ],
		[{"text"	:	"Login"			,	"callback_data"	:	"Login2"},
		{	"text"	:	"Buscar Contato",	"callback_data"	:	"buscaContato2"}]  ],
		"resize_keyboard" : true }
		)
	url:=Token "/sendMessage?text=" message "&chat_id=" from_id "&reply_markup=" keyb
	return request(url)	
}
