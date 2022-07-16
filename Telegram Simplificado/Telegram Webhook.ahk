File_Version=0.6.2
Save_to_SQL=1
Keep_Versions=1
;@Ahk2Exe-SetMainIcon C:\AHK\icones\fun\telegram.ico

FileEncoding, UTF-8

#Include	%A_ScriptDir%\configs.ahk
	OutputDebug % "config carregado"
; #Include	%A_ScriptDir%\image.ahk
	; OutputDebug % "image carregado"
#Include	%A_ScriptDir%\functions.ahk
	OutputDebug % "functions carregado"
#Include	%A_ScriptDir%\telegram.ahk
	OutputDebug % "telegram carregado"
#Include	%A_ScriptDir%\registro.ahk
	OutputDebug % "registro carregado"
#Include	%A_ScriptDir%\json.ahk
	OutputDebug % "json carregado"
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
	users	:= sql( users, 3 )
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
	OutputDebug % "Usuários carregados"

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
	OutputDebug % "Stickers carregados"
SetTimer,	webhook,%	poolTime
	OutputDebug % "Webhook setado"
return

webhook:
	dados	:=	{}
	updates	:=	GetNewMessages( ( offset+1 ) )
	oUpdates:=	Json( updates )
	OutputDebug % "offset carregado " oUpdates.result.Count()
	If oUpdates.result.Count() 	{
		OutputDebug	%	"`n`nNova Mensagem Offset:`t" offset
		Loop,%	oUpdates.result.Count() {
			; MsgBox % oUpdates.result[ A_index ].message.from.id
			dados.Push( oUpdates.result[ A_index ] )
		}
		For key, received in dados
		{
			;	Limpa as variáveis
				from_id:=first_name:=mtext:=last_name:=username:=sticker_id:=texto:=""
			;	Variáveis quando for INLINE
				if( received.callback_query.data != "" )	{
					inline		=	1
					from_id		:=	received.callback_query.from.id
					mtext		:=	received.callback_query.data
					message_id	:=	received.callback_query.message.message_id
					texto		:=	received.callback_query.message.text
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
			
			If MAP( usuarios, from_id, "ChatID" ) {						;	verifica se o usuário tem cadastro
				OutputDebug % "usuario cadastrado"
				
				if	Inline	{
					OutputDebug % "Resposta Inline`n`t" A_LineNumber "`nComando`t" SubStr( mtext, 1, InStr( mtext, "_" )-1 ) "`n`tTexto = " texto
					RemoveKeyb()
					If	InStr( texto, "Selecione a " ) {
						OutputDebug, % "Câmera selecionada"
						Inline =
						pic("1")
					}
					If	InStr( texto, "Selecione o colaborador" ) {
						OutputDebug, % "colaborador selecionado"
						Inline =
						info( mtext )
					}
					If	InStr( texto, "Tentar recuperar o banco de dados" ) {
						OutputDebug, % "restaurando"
						Inline =
						%mtext%()
					}
					Else
						; Goto,%	SubStr( mtext, 1, InStr( mtext, "_" )-1 )
						OutputDebug, % SubStr( mtext, 1, InStr( mtext, "_" )-1 )
					Return
				}

				if	( usuarios[MAP( usuarios, from_id, "ChatID" )].admin = 99 ) {	;	admin MAX commands 
					OutputDebug % "usuário é admin"
					if	InStr(mtext, " ")
						comando_recebido	:=	SubStr( mtext, 1, InStr( mtext, " " )-1 )
					Else
						comando_recebido	:=	StrReplace( mtext, "/" )
					OutputDebug % "Executando comando ADM`n" comando_recebido
								. "`n`t" A_LineNumber

					pos		:=	InArray( comandos_adm, StrReplace( comando_recebido, "/"))
					if pos {
						executa	:=	comandos_adm[pos]
						%executa%()
					}
					Else
						OutputDebug % "Não encontrou nos comandos`n`t" A_LineNumber
				}

				else if( pos := InArray( comandos, StrRep( mtext,, "/" ) ) ) {
					OutputDebug % "Executando comando`n`t" A_LineNumber "`n`t" comandos[pos]
					executa := comandos[pos]
					%executa%()
				}

				else if( InStr( mtext, A_Space ) ) {
					if( pos := InArray( comandos, SubStr( mtext, 1, InStr( mtext, A_Space )-1 ) ) ) {
						OutputDebug % "Executando comando`n`t" A_LineNumber "`n`t" comandos[pos]
						executa := comandos[pos]
						%executa%()
					}
				}

				Else if !pos	{
					OutputDebug % "Comando não existe`n`t" A_LineNumber "`n`t" mtext
					mensagem := html_encode("Comando desconhecido!")
					SendText( mensagem )
				}
			}
		}
	}
Return
;	Normal Commands
	db_status() {
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
					?	html_encode("Banco de dados de Detecção está:`n`n`t") "\xE2\x9C\x85 " status " \xF0\x9F\xA5\xB6"
					:	html_encode("Banco de dados de Detecção está:`n`n`t") "\xE2\x9C\x85 " status " \xF0\x9F\x99\x8F"
		SendText( mensagem )

		; status=INDISPONÍVEL
		if ( status = "INDISPONÍVEL" 
		||	 status = "OFFLINE" 
		||	 status = "RECOVERING" 
		||	 status = "RECOVERY_PENDING" )	{
			no	:=	html_encode("Não")
			is_keyb= 1
			keyb=
				(JOIN
				{"inline_keyboard"		:	[ [
				{"text": "Sim"	, "callback_data" 	: "db_restore"},
				{"text": "%no%"	, "callback_data" 	: "db_ignore"}
				] ]									, "resize_keyboard" : true }
				)
			mensagem:=	html_encode( "Tentar recuperar o banco de dados?"	)
			url		:=	token "/sendMessage?text=" mensagem ".&chat_id=" from_id "&reply_markup=" keyb
			mtext	=
			request( url )
		}
		Return
	}

	db_restore() {
		if	(is_keyb = 1)	{
			 is_keyb = 0
			RemoveKeyb()
		}

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
					?	"\xE2\x9C\x85 " status " \xF0\x9F\xA5\xB6"
					:	"\xE2\x9C\x85 " status " \xF0\x9F\x99\x8F"
		Sleep, 1000
		mensagem := html_encode("Tentativa de recuperação efetuada.`n`n`nEstado atual do banco de dados de Detecção de Movimento é:`n`n`t`t"  )
		SendText( mensagem estado)
		Return
	}

	db_Ignore() {
		if	(is_keyb = 1)	{
			 is_keyb = 0
			RemoveKeyb()
		}
		RemoveKeyb()
		mensagem := html_encode("Banco de dados não recuperado... ")
		SendText( mensagem " \xF0\x9F\x98\x95" )
		Return
	}

	reseta_saidas()	{
		u =
			(
				UPDATE [ASM].[dbo].[_registro_saidas]
				SET [retorno] = getdate()
					,[duracao] = 9999
				WHERE retorno is NULL
			)
		sql( u, 3 )
		if sql_le
			SendText( "Erro de SQL:`n" sql_le ) 
		Else
			SendText( html_encode("Saídas restauradas!") ) 
		Return
	}
;
;	Elevated commands
	pic( inline="" ) {
		cam_name:= StrReplace( StrReplace( StrReplace( StrReplace( mtext, "/" ), "pic " ), "`n"), "`r")
		if	inline	{
			OutputDebug % "Executando pic(inline)`n`t" A_LineNumber
			param_where	 =	[guid]
			cam_name	:=	mtext
			inline		 =
		}
		Else {
			OutputDebug % "Executando pic(rotina)`n`t" A_LineNumber
			param_where	= [name]
		}
		if InStr( cam_name, "[" )
			cam_name := StrReplace( cam_name, "[", "[[]")
		s =
			(
				SELECT
					 [name]
					,[guid]
					,[server]
				FROM
					[Dguard].[dbo].[cameras]
				WHERE
					%param_where% LIKE '`%%cam_name%`%'
				ORDER BY
					1
			)
		cameras := sql( s, 3 )
		if ( cameras.Count()-1 = 0 )	{		;	Nenhuma câmera
			OutputDebug, % StrRep( cam_name,, "[[]:[" ) "`n" cam_name
			mensagem := "Nenhuma " html_encode( "câmera com`n   " ) "```" html_encode( StrRep( cam_name,, "[[]:\[" ) ) "```" html_encode( "`n" ) "no nome encontrada, verifique o nome e solicite novamente\!"
			outputdebug % SendText( mensagem,,"MarkdownV2" )
		}
		Else if	 ( cameras.Count()-1 = 1 )	{	;	Uma câmera apenas
			guid		:=	cameras[2,2]
			dguard_token:=	dguard_token( cameras[2,3], "admin", "admin" )
			imagem		:=	dguard_get_image( guid, cameras[2,3], dguard_token )
			OutputDebug, % "`t" imagem
			; SendImage( imagem,  cameras[2,1] "%0A%0A" datetime() )
			outputdebug % SendImage( imagem, cameras[2,1] "%0A%0A" datetime(), "reply_to_message_id=" pic_message_id )
			FileDelete,% imagem
		}
		Else									;	Várias câmeras
			Cam_list( cameras )
			pic_message_id := message_id
		OutputDebug % "Finalizando getpictures`n`t" A_LineNumber
		Return
	}

	Reload() {
		mensagem := html_encode( "Serviço reiniciado." )
		SendText( mensagem )
		Reload
		Return
	}

	reboot() {
		url = http://admin:tq8hSKWzy5A@10.2.255.216/cgi-bin/magicBox.cgi?action=reboot
		SendText( Request( url ) )
		Return
	}

	info(id="") {
		if !id {
			is_line =
			OutputDebug % "Executando info()`n`t" A_LineNumber
			info		:=	StrReplace( mtext, "info " )
			s =
				(
					SELECT	 [nome]
							,[matricula]
							,[usuario]
							,[cargo]
							,[email]
							,[telefone1]
							,[telefone2]
							,[ramal]
							,[sexo]
							,[c_custo]
							,[setor]
							,[local]
							,[situacao]
							,[admissao]
							,[id]
					FROM
						[ASM].[dbo].[_colaboradores] 
					WHERE
						[nome]		LIKE	'`%%info%`%'
					OR	[matricula]	LIKE	'`%%info%`%'
					OR	[usuario]	LIKE	'`%%info%`%'
					OR	[cargo]		LIKE	'`%%info%`%'
					OR	[telefone1]	LIKE	'`%%info%`%'
					OR	[telefone2]	LIKE	'`%%info%`%'
					OR	[ramal]		LIKE	'`%%info%`%'
					OR	[c_custo]	LIKE	'`%%info%`%'
					OR	[setor]		LIKE	'`%%info%`%'
					OR	[local]		LIKE	'`%%info%`%'
					ORDER BY
						1
				)
		}
		Else {
			OutputDebug % "Executando info(" id ")`n`t" A_LineNumber
			s =
				(
					SELECT	 [nome]
							,[matricula]
							,[usuario]
							,[cargo]
							,[email]
							,[telefone1]
							,[telefone2]
							,[ramal]
							,[sexo]
							,[c_custo]
							,[setor]
							,[local]
							,[situacao]
							,[admissao]
							,[id]
					FROM
						[ASM].[dbo].[_colaboradores] 
					WHERE
						[id]	=	'%id%'
				)
				id=
				is_line=1	;	usado devido a inline button
		}
		dados := sql( s, 3 )
		if ( dados.Count()-1 = 0 )	{
			mensagem := html_encode( "Nenhum colaborador com " info " nas informações e/ou nome encontrado, verifique a informação e solicite novamente!" )
			OutputDebug, % mensagem
			SendText( mensagem )
		}
		Else if	 ( dados.Count()-1 = 1 )	{
			;	emojis
				_ma	:=	"\xF0\x9F\x86\x94"
				; _us	:=	"\xF0\x9F\x9A\xBA"
				_ca	:=	"\xF0\x9F\x91\x94"
				_em	:=	"\xF0\x9F\x93\xA7"
				_t1	:=	"\xF0\x9F\x93\xB1"
				_t2	:=	"\xF0\x9F\x93\x9E"
				_ra	:=	"\xE2\x98\x8E"
				_sx	:=	dados[2,9] = "M" ? "\xF0\x9F\x9A\xB9" : "\xF0\x9F\x9A\xBA"
				_un	:=	"\xF0\x9F\x8F\xA2"
				_se	:=	"\xF0\x9F\x8F\xA3"
				_lo	:=	"\xF0\x9F\x8F\xAD"
				_si	:=	dados[2,13] = "Trabalhando" ? "\xF0\x9F\x92\xAF" : "\xF0\x9F\x92\xA4"
				_ad	:=	"\xF0\x9F\x93\x85"
			;
			mensagem:=	(dados[2,1]	=	""
									?	""
									:	"    *          __"											dados[2,1]) "__*"
					.	(dados[2,2]	=	""
									?	""
									:	"%0A%0A"	_ma	html_encode(" *Matrícula*`n        "	)	dados[2,2])
					; .	(dados[2,3]	=	""
									; ?	""
									; :	"%0A%0A"	_us	html_encode("    *Usuário*      "		)	dados[2,3])
					.	(dados[2,4]	=	""
									?	""
									:	"%0A%0A"	_ca	html_encode(" *Cargo*`n        "		)	dados[2,4])
					.	(dados[2,5]	=	""
									?	""
									:	"%0A%0A"	_em	html_encode(" *E-Mail*`n        "		)	dados[2,5])
					.	(dados[2,6]	=	""
									?	""
									:	"%0A%0A"	_t1	html_encode(" *Telefone*`n        "		)	phone( dados[2,6]) )
					.	(dados[2,7]	=	""
									?	""
									:	"%0A%0A"	_t2	html_encode(" *Telefone*`n        "		)	phone( dados[2,7]) )
					.	(dados[2,8]	=	""
									?	""
									:	"%0A%0A"	_ra html_encode(" *Ramal*`n        "		)	dados[2,8])
					.	(dados[2,9]	=	""
									?	""
									:	"%0A%0A"	_sx	html_encode(" *Sexo*`n        "			) ( dados[2,9] = "M" ? "Masculino" : "Feminino") )
					.	(dados[2,10]	=	""
									?	""
									:	"%0A%0A"	_un	html_encode(" *Unidade*`n        "		)	dados[2,10])
					.	(dados[2,11]	=	""
									?	""
									:	"%0A%0A"	_se	html_encode(" *Setor*`n        "		)	dados[2,11])
					.	(dados[2,12]	=	""
									?	""
									:	"%0A%0A"	_lo	html_encode(" *Local*`n        "		)	dados[2,12])
					.	(dados[2,13]	=	""
									?	""
									:	"%0A%0A"	_si	html_encode(" *Situação*`n        "		)	dados[2,13])
					.	(dados[2,14]	=	""
									?	""
									:	"%0A%0A"	_ad	html_encode(" *Admissão*`n        "		)	dados[2,14])

			SendText( StrRep( mensagem,, ".:\.", "-:\-", "%2D:\-", "(:\(" , "):\)" ),, "MarkdownV2", "reply_to_message_id=" ( is_line = 1 ? (message_id-1) : message_id ) )
		}
		Else									;	Várias câmeras
			user_list( dados )
		OutputDebug % "Finalizando info`n`t" A_LineNumber
		Return
	}

	talk_to() {
		OutputDebug % "Executando talkto(rotina)`n`t" A_LineNumber
		fulltext:= StrReplace( StrReplace( StrReplace( StrReplace( mtext, "/" ), "talkto " ), "`n"), "`r")

		param	:= StrSplit( fulltext, " ")
		cmd		:= param[1]
		operator:= param[2]
		Loop,% param.Count()-2
			text.= param[A_Index+2] " "
		text	:= SubStr( text, 1, -1 )

		s =
			(
				IF NOT EXISTS (SELECT * FROM [Telegram].[dbo].[command] WHERE [command] LIKE '%operator%][%text%][`%' AND [return] IS NULL)
					INSERT INTO
						[Telegram].[dbo].[command]
						([command])
					VALUES
						('%cmd%][%operator%][%text%][%message_id%][%from_id%')
			)
		sql( s, 3 )
		SendText( html_encode( "Mensagem enviada, aguardando execução na máquina do operador " operator " em até 30 segundos..." ) )
		Return
	}

;	Check auth

	check_auth() {

		Return
	}

^+END::
	ExitApp