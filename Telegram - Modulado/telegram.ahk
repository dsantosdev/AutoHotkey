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

RemoveKeyb( text="Botões fechados." )			{
	keyb={"remove_keyboard" : true }
	url:=Token "/sendMessage?text=" text "&chat_id=" from_id "&reply_markup=" keyb
	r:=request(url)
	DeleteMessage()
	Return	r
}

SendText( text, replyMarkup="", parseMode="" )	{
	url:=token "/sendmessage?chat_id=" from_ID "&text=" text "&reply_markup=" replyMarkup "&parse_mode=" parseMode
	Clipboard := url
	MsgBox
	jxon_message:=request(url)
	return jxon_message
}

SendSticker( text, replyMarkup="", parseMode="" ){
	url:=token "/sendSticker?chat_id=" from_ID "&sticker=" text "&reply_markup=" replyMarkup "&parse_mode=" parseMode
	return request(url)
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