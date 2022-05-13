#Include	functions.ahk
#Include	telegram.ahk

DBStatus() {
	s =
		(
			SELECT 
				[state_desc]
			FROM
				[sys].[databases]
			WHERE
				[Name] = 'MotionDetection' 
		)
	s := sql( s, 3 )
	status := s[2, 1]
	mensagem	:=  status = "RECOVERY_PENDING"
				?	html_encode("Banco de dados de Detecção está:`n`n`t") "\xE2\x9D\x8C " html_encode("INDISPONÍVEL") " \xF0\x9F\xA5\xB6"
				:	status = "OFFLINE"
				?	html_encode("Banco de dados de Detecção está:`n`n`t") "\xE2\x9D\x8C " html_encode("INDISPONÍVEL") " \xF0\x9F\xA5\xB6"
				:	status = "RECOVERING"
				?	html_encode("Banco de dados de Detecção está:`n`n`t") "\xE2\x9C\x85 " status " \xF0\x9F\x99\x8F"
				:	html_encode("Banco de dados de Detecção está:`n`n`t") "\xE2\x9C\x85 " status " \xF0\x9F\x99\x8F"
	MsgBox % mensagem
	msgbox % SendText( mensagem )

	; status=INDISPONÍVEL
	if ( status = "INDISPONÍVEL" )	{
		no	:=	html_encode("Não")
		is_keyb= 1
		keyb=
			(JOIN
			{"inline_keyboard"		:	[ [
			{"text": "Sim"	, "callback_data" 	: "Restore"},
			{"text": "%no%"	, "callback_data" 	: "Ignore"}
			] ]									, "resize_keyboard" : true }
			)
		mensagem:=	html_encode( "Tentar recuperar o banco de dados?"	)
		url		:=	token "/sendMessage?text=" mensagem ".&chat_id=" from_id "&reply_markup=" keyb
		mtext	=
		Clipboard := url
		request( url )
	}
	MsgBox
	Return
}

talkto( text, operator ) {
	
	
}