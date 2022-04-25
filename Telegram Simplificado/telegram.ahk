GetNewMessages( offset = "" )					{
	return request( token "/getupdates?offset=" offset )
}
DeleteMessage( HowMany=1, minusMessageId=0 )	{
	msgid	:=	minusMessageId	> 0
								? message_id - minusMessageId
								: message_id + 1
	Loop,%	HowMany	{
		url	:=	token "/deleteMessage?chat_id=" from_id "&message_id=" msgid-1
		return request( url )
	}
}
RemoveMessage( HowMany=1 )	{
	msgid	:= message_id
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

SendText( text, replyMarkup="", parseMode="" )	{
	if InStr( text ,"\x" )
		text := StrReplace( text, "\x", "`%"  )
	url	:=	token "/sendmessage?chat_id=" from_ID "&text=" text "&reply_markup=" replyMarkup "&parse_mode=" parseMode

	return request( url )
}
SendSticker( text, replyMarkup="", parseMode="" ){
	url	:=	token "/sendSticker?chat_id=" from_ID "&sticker=" html_encode( text ) "&reply_markup=" replyMarkup "&parse_mode=" parseMode
	return request( url )
}
;InlineButtons(message="Line Buttons",mtext="")	{
	; keyb={
		; (join
		; "inline_keyboard":
		; [ [{"text"	:	"Login"			,	"callback_data"	:	"Login"},
		; {	"text"	:	"Buscar Contato",	"callback_data"	:	"buscaContato"} ] ],
		; "resize_keyboard" : true }
		; )
	; url:=Token "/sendMessage?text=" message	"&chat_id=" from_id "&reply_markup=" keyb
	; return request(url)	
; }