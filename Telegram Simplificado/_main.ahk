;@Ahk2Exe-SetMainIcon C:\AHK\icones\fun\telegram.ico
#Include	configs.ahk
#Include	functions.ahk
#Include	telegram.ahk
#Include	registro.ahk
#Include	json.ahk
#Persistent
debug	=	1
users	=
	(
		SELECT	u.[name]			--	1
		,		u.[matricula]		--	2
		,		u.[is_admin]		--	3
		,		u.[is_manager]		--	4
		,		u.[chat_id]			--	5
		,		u.[activation_key]	--	6
		,		o.[processo]		--	7
		,		o.[iniciado]		--	8
		,		o.[finalizado]		--	9
		,		u.[autenticado]		--	10
		,		u.[fails]			--	11
		FROM
			[Telegram].[dbo].[users] 	u
		LEFT JOIN
			[Telegram].[dbo].[operacao]	o
		ON
			u.[chat_id] = o.[chatid]
	)
	users	:= sql( users )
	Loop,%	users.Count()-1	{
		if( users[A_Index+1, 11] = 0 )	{	;	Sem falha de login
			usuarios.Push(
				(Join
				{
				nome		:	users[ A_Index+1, 1 ],
				matricula	:	users[ A_Index+1, 2 ],
				admin		:	users[ A_Index+1, 3 ],
				manager		:	users[ A_Index+1, 4 ],
				ChatID		:	users[ A_Index+1, 5 ],
				key			:	users[ A_Index+1, 6 ],
				processo	:	users[ A_Index+1, 7 ],
				iniciado	:	users[ A_Index+1, 8 ],
				finalizado	:	users[ A_Index+1, 9 ],
				autenticado	:	users[ A_Index+1, 10]	}	)
				)
		}
		Else								;	Com falha de login
			fail.push( {id		:	users[ A_Index+1, 5 ],
					.	falhas	:	users[ A_Index+1, 11]	} )
	}

stickers=
		(
		SELECT	[pkid]
    	,		[file_id]
    	,		[cmd]
		FROM
				[Telegram].[dbo].[stickers]
		)
		stickers := sql( stickers, 3 )
	Loop,%	stick.Count()-1
		ObjRawSet(	stickers,
				.	stick[ A_Index+1, 3 ],
				.	sticstickkers[ A_Index+1, 2 ]	)
SetTimer,	webhook,%	poolTime
return



webhook:
	dados	:=	{}
	updates	:=	GetNewMessages( ( offset+1 ) )
	oUpdates:=	Json( updates )
	OutputDebug % oUpdates.result.Count()
	If oUpdates.result.Count() 	{
		OutputDebug	%	"`n`nNova Mensagem Offset:`t" offset
		Loop,%	oUpdates.result.Count()
			dados.Push( oUpdates.result[ A_index ] )
		For key, received in dados
		{
			;	Limpa as variáveis
				from_id:=first_name:=mtext:=last_name:=username:=sticker_id:=""
			;	Variáveis quando for INLINE
				if( received.callback_query.data != "" )	{
					from_id		:=	received.callback_query.from.id
					mtext		:=	received.callback_query.data
					message_id	:=	received.callback_query.message.message_id
				}
			;	Variáveis para mensagens normais
				else	{														
					from_id		:=	received.message.from.id
					mtext		:=	received.message.text
					first_name	:=	received.message.from.first_name
					last_name	:=	received.message.from.last_name
					username	:=	received.message.from.username
					message_id	:=	received.message.message_id
				}
			;	Variáveis globais
				sticker_id		:=	received.message.sticker.file_id	;	Id de sticker enviado
				offset			:=	received.update_id					;	offset da mensagem para ser apagada
			OutputDebug % from_id "`n" mtext "`n" first_name "`n" last_name "`n" username "`n" message_id "`n" offset "`n______________"
			If MAP( usuarios, from_id, "ChatID" ) {
				if InArray( comandos, StrReplace( mtext, "/" ) ) {
					function:=	comandos[InArray( comandos, StrReplace( mtext, "/" ) )]
					Goto,%	function
				}
				; If		( mtext = "/start" ) {
							; keyb=
								; (JOIN
								; {"inline_keyboard"		:	[ [
								; {"text": "Estado do Banco de Dados"	, "callback_data" 	: "status"}
								; ] ]									, "resize_keyboard" : true }
								; )
							; mensagem:=	html_encode( "Verificar"	)
							; url		:=	token "/sendMessage?text=" mensagem "&chat_id=" from_id "&reply_markup=" keyb
							; mtext=
							; request( url )
				; }
			}
		}
	}
Return

DBStatus:
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
	SendText( mensagem )

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
		request( url )
	}
Return

Restore:
	if	is_keyb = 1, is_keyb =0
		RemoveKeyb()

	mensagem := html_encode( "Executando restauração, por favor aguarde..." )
	SendText( mensagem )
	s =
		(
			ALTER DATABASE MotionDetection SET OFFLINE;
			ALTER DATABASE MotionDetection SET ONLINE;
		)
	sql( s, 3 )
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
	status	:= s[2, 1]
	estado	:=	status = "RECOVERY_PENDING"
				?	"\xE2\x9D\x8C " html_encode("INDISPONÍVEL") " \xF0\x9F\xA5\xB6"
				:	status = "OFFLINE"
				?	"\xE2\x9D\x8C " html_encode("INDISPONÍVEL") " \xF0\x9F\xA5\xB6"
				:	status = "RECOVERING"
				?	"\xE2\x9C\x85 " status " \xF0\x9F\x99\x8F"
				:	"\xE2\x9C\x85 " status " \xF0\x9F\x99\x8F"
	Sleep, 1000
	mensagem := html_encode("Tentativa de recuperação efetuada.`n`n`nEstado atual do banco de dados de Detecção de Movimento é:`n`n`t`t"  )
	SendText( mensagem estado)
Return

Ignore:
	RemoveKeyb()
	mensagem := html_encode("Banco de dados não recuperado... ")
	SendText( mensagem " \xF0\x9F\x98\x95" )
Return

^+END::
	ExitApp