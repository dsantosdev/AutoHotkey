;	Início registro
	NewRegister()			{
		url:=token	"/sendMessage?text=Bem vindo ao Monitoramento - Cotrijal%0A%0AEnvie sua senha para iniciar o registro.&chat_id=" from_id
		Clipboard := url
		; MsgBox
		registering.push({id:from_id,status:"CheckCode"})
		comandos.Push({"cmd":"CheckCode"})
		comandos.Push({"cmd":"TooManyFails"})
		comandos.Push({"cmd":"WrongNumcad"})
		comandos.Push({"cmd":"CodeOk"})
		r:=request(url)
		deleteMessage()
		return r
		}
;	Código inválido
	WrongCode()				{
		if(fail[InDict(fail,from_id)].falhas="")	{
			falhou=1
			restam=2
			fail.Push({falhas:falhou,id:from_id,resta:restam})
			OutputDebug % fail[InDict(fail,from_id)].falhas " entrou"
			u:="INSERT INTO [telegram].[dbo].[users] ([name],[fails],[chat_id]) VALUES ('falha_" from_id "','1','" from_id "')"
			}
		Else if(fail[InDict(fail,from_id)].falhas<3){
			restam:=fail[InDict(fail,from_id)].resta-1
			falhou:=fail[InDict(fail,from_id)].falhas+1
			fail.pop(InDict(fail,from_id))
			fail.Push({falhas:falhou,id:from_id,resta:restam})
			OutputDebug % fail[InDict(fail,from_id)].falhas " meio"
			u:="UPDATE [telegram].[dbo].[users] SET [fails]='" falhou "' WHERE [chat_id]='" from_id "'"
			}
		Else if(fail[InDict(fail,from_id)].falhas=3){
			falhou:=fail[InDict(fail,from_id)].falhas+1
			fail.pop(InDict(fail,from_id))
			fail.Push({falhas:falhou,id:from_id,resta:restam})
			OutputDebug % fail[InDict(fail,from_id)].falhas " saiu"
			TooManyFails()
			Return
			}
		Else										{
			OutputDebug % fail[InDict(fail,from_id)].falhas " else"
			TooManyFails()
			Return
			}

		adosql(u,3)
		mensagem:=html_encode("A senha enviada é inválida.`nTentativas restantes:`t" restam "`n`nEnvie a senha correta ou Solicite uma senha válida com seu gestor.")
		url:=token	"/sendMessage?text=" mensagem "&chat_id=" from_id
		r:=request(url)
		deleteMessage()
		return r
		}
;	Verifica o código(se ele existir na base de dados) enviando 4 matrículas falsas e 1 real
	CheckCode(mtext,index)	{
		if(InDict(fail,from_id)>0)	{
			deleteMessage()
			fail.pop(InDict(fail,from_id))
			}
		u=
			(
			DELETE FROM [telegram].[dbo].[users] WHERE [name] = 'falha_%from_id%';
			UPDATE [telegram].[dbo].[users] SET [current] = 'CodeOk', [chat_id] = '%from_id%' WHERE [activation_key] = '%mtext%';
			SELECT [matricula] FROM [telegram].[dbo].[users] WHERE [activation_key] = '%mtext%';
			)
		s:=adosql(u)
		if(debug="sql")
			OutputDebug	%	"adosql`n`n"	adosql_lq "`n" adosql_le	"`n_____________________________"
		;	Bloco de matrícula aleatória
			matriculas:=[]
			matriculas.Push(	StrLen(s[A_Index+1,1])	>	0
								?	s[A_Index+1,1]
								:	s[A_Index+2,1]		>	0
								?	s[A_Index+2,1]
								:	s[A_Index+3,1]		>	0
								?	s[A_Index+3,1]
								:	s[A_Index+4,1]		>	0
								?	s[A_Index+4,1]
								:	s[A_Index+5,1]		)
			first_char:=SubStr(matriculas[1],1,1)
			registering.push({id:from_id,status:"CheckCode",matricula:matriculas[1]})
			_matriculas=
			Loop,	4	{	;	gera 4 matrículas de 5 digitos aleatórias para o usuário confirmar que é ele mesmo
				mmmm=
				Loop,	4	{
					Random,	_matriculas,	0,	9
					mmmm.=_matriculas
					}
				matriculas.Push(first_char mmmm)
				}
			foi=
			_matriculas:=[]
			Loop,	%	matriculas.Count()	{
				Loop
					Random,	qual,	1,	5
				until	InStr(foi,qual)=0
				foi.=qual
				if(matriculas[qual]=s[A_Index+2,1]){
					vaipara=CodeOk
					}
				else	{
					vaipara=WrongNumcad
					}
				_matriculas.Push(matriculas[qual] ":" vaipara)
				}
			comando:=_matriculas[InArray(_matriculas,s[A_Index+2,1],1)]
			Loop % _matriculas.Count()	{
				split:=StrSplit(_matriculas[A_Index],":")
				botao%A_Index%:=split[1]
				data%A_Index%:=split[2]
				}
		keyb=
			(JOIN
			{"inline_keyboard"	:	[ [
			{"text": "%botao1%" , "callback_data" 	: "%data1%"},
			{"text": "%botao2%" , "callback_data" 	: "%data2%"},
			{"text": "%botao3%" , "callback_data"	: "%data3%"},
			{"text": "%botao4%" , "callback_data"	: "%data4%"},
			{"text": "%botao5%" , "callback_data" 	: "%data5%"}
			] ]					, "resize_keyboard" : true }
			)
		mensagem:=html_encode("Senha Aceita!`n`nSelecione sua matrícula para confirmar.")
		url:=token "/sendMessage?text="	mensagem	".&chat_id=" from_id "&reply_markup=" keyb
		r:=request(url)
 		deleteMessage()
		return r
		}
;	Após exceder 3 senhas erradas, bloqueia o usuário
	TooManyFails()			{
		mensagem:=html_encode("Limite de falhas excedido ou Matrícula selecionada incorreta.`n`nSolicite ao seu gestor uma NOVA senha para registro.")
		url:=token "/sendMessage?text="	mensagem "&chat_id=" from_id
		return request(url)
		}
;	Número de matrícula inválido
	WrongNumcad()			{
		fail.Push({falhas:4,id:from_id,resta:0})
		RemoveKeyb("_")
		deleteMessage()
		falhou:=4
		u:="UPDATE [telegram].[dbo].[users] SET [fails]='" falhou "' WHERE [chat_id]='falha_" from_id "'"
		adosql(u,3)
		mensagem:=html_encode("Matrícula selecionada incorreta.`n`nSolicite ao seu gestor uma NOVA senha para registro.")
		url:=token "/sendMessage?text="	mensagem "&chat_id=" from_id
		return request(url)
		}
;	Registrado
	CodeOk()				{
		url:=token "/sendMessage?text=Registrado com sucesso.&chat_id=" from_id "&show_alert=true"
		a=UPDATE [Telegram].[dbo].[users] SET [autenticado]=1 WHERE [chat_id]='%from_id%'
		a_Cadastrados.Push({chatID:chatID})
		adosql(a,3)
		; start(token, message, from_id, mtext, chatID)
		deleteMessage(5)
		return request(url) 
		}
