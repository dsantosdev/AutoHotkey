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
				chat_ID		:	users[ A_Index+1, 5 ],
				key			:	users[ A_Index+1, 6 ],
				processo	:	users[ A_Index+1, 7 ],
				iniciado	:	users[ A_Index+1, 8 ],
				finalizado	:	users[ A_Index+1, 9 ],
				autenticado	:	users[ A_Index+1, 10]	}	)
				)
		}
		Else								;	Com falha de login
			fail.push(
				(Join
				{	id		:	users[ A_Index+1, 5 ],
					falhas	:	users[ A_Index+1, 11]	} )
				)
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
	dados	:=	{}	;	precisa ser limpo em cada request
	updates	:=	GetNewMessages( ( offset+1 ) )
	oUpdates:=	Json( updates )
	If( StrLen( updates ) > 25) 	{
		if( debug = 1 or debug = 3 )
			OutputDebug	%	"`n`nNova Mensagem`noffset:`t" offset
		Loop,%	oUpdates.result.Count()
			dados.Push( oUpdates.result[ A_index ] )
		For key, message in dados
			{
			;	Bloco relacionado a variáveis da mensagem
				from_id:=first_name:=mtext:=last_name:=username:=sticker_id:=""			;	Limpa as variáveis
				if( message.callback_query.data != "" )	{								;	Se for 'inline' | Prepara as variáveis

					from_id		:=	message.callback_query.from.id
					mtext		:=	message.callback_query.data
					message_id	:=	message.callback_query.message.message_id

				}
				else	{																;	Se for mensagem normal ou button | Prepara as variáveis

					from_id		:=	message.message.from.id
					mtext		:=	message.message.text
					first_name	:=	message.message.from.first_name
					last_name	:=	message.message.from.last_name
					username	:=	message.message.from.username
					message_id	:=	message.message.message_id

				}
				sticker_id	:=	message.message.sticker.file_id							;	Id de sticker enviado
				offset		:=	message.update_id										;	offset da mensagem para ser apagada

			if( debug = 1 or debug = 3 )			;	Variaveis
				OutputDebug	%	"|Variaveis`n`t" mtext "`n`t" message_id "`n|Parte Logica"

			if( InDict( usuarios, from_id ) = 0		;	Inicio de cadastro | Não consta nos usuários
			&& InDict( registering, from_id ) = 0	;	Não está em fase de registro
			&& mtext = "/start"						;	Enviou comando /start
			&& InDict( fail, from_id ) = 0 )	{	;	Não consta falha de logins(autenticação com o AD durante o cadastro)
				if( debug = 1 || debug = 3 )
					OutputDebug	%	"NewRegister"
				NewRegister()
				Return
			}
			
			if( InDict( registering, from_id ) > 0
			&&	InDict( usuarios, mtext, "key" ) = 0 )	{	;	Se registro iniciado e a senha ERRADA

				if( debug = 1 || debug = 3 )
					OutputDebug	%	"|Registrando:`n||Status:`t" registering[InDict(registering,from_id)].status "`n||InDict:`t" InDict(comandos,mtext,"cmd") "`n_______________________"

				if( registering[InDict( registering, from_id )].status = "CheckCode"
				&&	InDict( comandos, mtext, "cmd" ) != 0 )	{	;	Executa no inlinebutton de validação de matrícula
					executa := comandos[InDict( comandos, mtext, "cmd" )].cmd

					if( debug = 1 )
						OutputDebug	%	executa " " A_Now
						
					%executa%()	;	Chama a função dinamicamente
					Return
				}
				if(debug=1 or debug=3)
					OutputDebug	%	"|direto`n`t" mtext "|WrongCode"
				WrongCode()	;	Se não for inline button, registra +1 para senha errada
				Return
				}
			if(	InDict( registering, from_id ) != 0
			&&	usuarios[InDict( usuarios, mtext, "key" )].key = mtext )	{	;	Se registrando e a senha for correta
				if( debug = 1 || debug = 3 )
					OutputDebug	%	"||"	registering[index:=InDict(registering,from_id)].status	" 3 if"
				go	:=	registering[index := InDict( registering, from_id )].status
				%go%( mtext, index )	;	Executa dinamicamente a função definida no dictionary de Registro, no campo status
				Return
			}
			if( InDict( fail, from_id ) > 0 )	{	;	Se excedeu as 3 tentativas ou errou a matrícula
				if( debug = 1 || debug = 3 )
					OutputDebug	%	"Bloqueado " A_Now
				WrongCode()
				Return
			}

			; Gosub	InicioRegistro
			; Gosub	Registrando
			; Gosub	VerificaSenha
			; Gosub	Bloqueado
			; MsgBox % InDict(usuarios,from_id) "`n" InDict(registering,from_id) "`n" InDict(fail,from_id) "`n" mtext
			}
		}
Return

InicioRegistro:
	if(InDict(usuarios,from_id)=0 and InDict(registering,from_id)=0	and mtext="/start"	and InDict(fail,from_id)=0)	{	;	Inicio de cadastro
		if(debug=1 or debug=3)
			OutputDebug	%	"NewRegister"
		NewRegister()
		Return
		}
	Return
Registrando:
	if(InDict(registering,from_id)>0 and InDict(usuarios,mtext,"key")=0){	;	Se registro iniciado e a senha ERRADA
		if(debug=1 or debug=3)
			OutputDebug	%	"|Registrando:`n||Status:`t" registering[InDict(registering,from_id)].status "`n||InDict:`t" InDict(comandos,mtext,"cmd") "`n_______________________"
		if(registering[InDict(registering,from_id)].status="CheckCode" and InDict(comandos,mtext,"cmd")!=0)	{	;	Executa no inlinebutton de validação de matrícula
			executa:=comandos[InDict(comandos,mtext,"cmd")].cmd
			if(debug=1)
				OutputDebug	%	executa " " A_Now
			%executa%()	;	Chama a função dinamicamente
			Return
			}
		if(debug=1 or debug=3)
			OutputDebug	%	"|direto`n`t" mtext "|WrongCode"
		WrongCode()	;	Se não for inline button, registra +1 para senha errada
		Return
		}
	Return
VerificaSenha:
	if(InDict(registering,from_id)!=0 and usuarios[InDict(usuarios,mtext,"key")].key=mtext){	;	Se registrando e a senha for correta
		if(debug=1 or debug=3)
			OutputDebug	%	"||"	registering[index:=InDict(registering,from_id)].status	" 3 if"
		go:=registering[index:=InDict(registering,from_id)].status
		%go%(mtext,index)	;	Executa dinamicamente a função definida no dictionary de Registro, no campo status
		Return
		}
	Return

Bloqueado:
	if(InDict(fail,from_id)>0)	{	;	Se excedeu as 3 tentativas ou errou a matrícula
		if(debug=1 or debug=3)
			OutputDebug	%	"Bloqueado " A_Now
		WrongCode()
		Return
		}
	Return

	;;;;;;
			; else	{	;	Usuário cadastrado
			; 	cmds:={
			; 		(join
			; 					"/Start"					:	"start"	
			; 					,"Login"					:	"executor"
			; 					,"Acesso fora de Horário"	:	"solicitaAcesso"
			; 					,"Contato de Colaborador"	:	"solicitaContato"
			; 					,"Verificar Código"			:	"verificaCodigo"
			; 					,"Teste"					:	"executor"
			; 					,"Mostrar botoes em linha"	:	"inlinebuttons"
			; 					,"Fechar"					:	"RemoveKeyb"
			; 					,"Falha ao registrar"		:	"registroFail"
			; 					,"Sucesso ao registrar"		:	"registroOk"
			; 					,"Reboot"					:	"reboot"
			; 					,"Callme"					:	"Callme"
			; 					,"Ligar"					:	"ligar"
			; 					}
			; 		)
			; 		}
			; 	chatID:=from_ID															;	var de chatid
			; 	_processo:=a_dados[Existe(a_dados,chatID)].processo						;	Verifica se está no meio de alguma solicitação
			; 	_finalizado:=a_dados[Existe(a_dados,chatID)].finalizado					;	Verifica se a última/atual solicitação já foi finalizada
			; 	if(cmds.Haskey(mtext)){													;	Executa se o texto recebido é algum comando
			; 		executa:=cmds[mtext]
			; 		%executa%(botToken, message, from_id, mtext, chatID, message_id)
			; 		}
			; 	else if(arraySearch(a_Cadastrados,mtext)>0){							;	Se a matrícula consta nos cadastrados
			; 		executa:=a_Cadastrados[arraySearch(a_Cadastrados,_matricula_,1)]	;	Verificar quando executa????
			; 		MsgBox % executa
			; 		%executa%(botToken, message, from_id, mtext, chatID, message_id)
			; 		}
			; 	else if(_processo in operações and StrLen(_finalizado)=0){				;	Se estiver em alguma operação e a mesma não estiver finalizada
			; 		%_processo%(botToken, mtext, chatID, message_id)
			; 		}
			; 	else	{																;	Caso o comando enviado não seja válido
			; 		text := "Comando desconhecido"
			; 		Random, e, 1, 5
			; 		SendSticker(botToken,sticker("bean_e" e), from_id)
			; 		SendText(botToken, encode(text), from_id)
			; 		}
			; 	}	;	já cadastrados
			; }	;	for key
		return
; s=select * from [Telegram].[dbo].[users]
; a:=sql(s)
; Loop	%	a.count()
; 	MsgBox, %	a[A_Index,2]