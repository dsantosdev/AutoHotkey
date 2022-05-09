/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\users\dsantos\desktop\executáveis\agenda.exe
Created_Date=1
Run_After="C:\Users\dsantos\Desktop\Executáveis\AHK2BD.exe"
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
Inc_File_Version=1
Legal_Copyright=WTFL
Product_Version=1.1.33.2
Set_AHK_Version=1

* * * Compile_AHK SETTINGS END * * *
*/

;@Ahk2Exe-SetMainIcon	C:\AHK\icones\_gray\2mail.ico

/*
	Changelog
	08/01/2021	|	Inserido auto select de unidade
	22/01/2021	|	Inserido auto ajuste de datas e hora para agendamento, quando respectivamente nos formatos  dd/mm/yyyy, dd/mm/yy e hh:mm, h:mm
	01/02/2021	|	Alterado classe de login, agora verifica os admins pelo banco de dados
	01/02/2021	|	Verifica os formatos de hora para adicionar 0 na frente quando necessário
	19/02/2021	|	Ajustado as variáveis de multidatas que não estavam limpando após inserção
*/


/*	teste ocomon
	102225
	Área Responsável:	
	TI - Infraestrutura
	Problema:	
	Aberto Por:	
	Dieisson Santos
	Categorias do problema	| |
	Descrição:	Chamado aberto para validação do sistema monitoramento.
*/

/*	Teste email
	Bom dia,
	No dia de hoje a unidade de Caseiros, vai estar  com movimentação de pessoal,  mas não vão acessar o escritório e depósitos. O proprietário do imóvel  com a prefeitura, estarão cascalhando o pátio. 
	Qualquer coisa me avisa que lhe ligo ligo para o proprietário. 
	Att:
	Carlos Renato Grandeaux
	Administrativo - Coordenador Administrativo Unidade
	cgrandeaux@cotrijal.com.br
	Fone: (54) 3191-2559
	Unidade - Caseiros
	Caseiros/RS
*/

;	Includes
	#Persistent
	; #Include ..\class\array.ahk
	; #Include ..\class\cor.ahk
	; #Include ..\class\dguard.ahk
	#Include ..\class\functions.ahk
	#Include ..\class\gui.ahk
	; #Include ..\class\mail.ahk
	; #Include ..\class\safe_data.ahk
	; #Include ..\class\string.ahk
	#Include ..\class\sql.ahk
	#Include ..\class\windows.ahk
;

;	Variáveis e Arrays
	istest = 0
	multidatas := []
;

;	Autenticação
	if ( A_UserName = "dsantos" )
		Goto, interface
	Else
		Goto, Login
;

;	configuração
	#SingleInstance Force
	Menu Tray,	Tip,	Agendamento e Inserção de E-mails
;

;	Bloco de login
	;	Necessita de:
		;	#Include ..\class\functions.ahk
		;	#Include ..\class\windows.ahk
	Login:
		gui.Cores( "login" , "9BACC0" , "374658" )
			Gui.Font( "login:" , "Bold" , "S10" , "cWhite" )
		Gui, login:Add, Text,	x10	y10		w80		h25		0x1200		center			, Usuário
		Gui, login:Add, Text,	x10	y40		w80		h25		0x1200		center			, Senha
			Gui.Font( "login:" )
			Gui.Font( "login:" , "Bold" , "S10" )
		Gui, login:Add, Edit,	x90	y10		w140	h25		v@usuario
		Gui, login:Add, Edit,	x90	y40		w140	h25		v@senha		Password
			Gui.Font( "login:" )
		Gui, login:+AlwaysOnTop	-MinimizeBox
		Gui, login:Show,																, Login Cotrijal
		Sleep, 500
		Gui, login:+LastFound
		Guicontrol, login:Focus, @usuario
	Return

	_Autenticar:
		Gui, Login:Submit, NoHide
		is_login := Login( @usuario , @senha )
		if ( logou = "interface" )
			Return
		goto,	%	logou := Login( @usuario , @senha ) =	0
														?	"GuiClose"
														:	"Interface"
	Return

	~Enter::
		~NumpadEnter::
		if ( WinActive( "Login Cotrijal" ) != "0x0" )
			Goto _Autenticar
	Return

	GuiClose:
		if ( logou = "GuiClose" )	{
			Gui, Login:Destroy
			MsgBox % Windows.Status( @usuario )
		}
		loginGuiCLose:
			ExitApp
;

interface:
	Gui, Login:Destroy
	gui:
		Gui, Destroy
		Gui.Cores()
			Gui.Font( "S10" , "Bold" , "CWhite" )
		Gui,	Add,	Text,			x10		y0		w410	h30													0x1201	Section	,	ADICIONAR E-MAIL
		Gui,	Add,	DateTime,		x10		yp+40	w200	h30					v_date	hwndHdate	gDC							,	dd/MM/yyyy HH:mm:ss
		Gui,	Add,	Checkbox,		x230	yp		w150	h25					v_multidate			gMulti_data					,	Mais de um dia
		Gui,	Add,	Text,			x10		yp+40	w100	h20													0x1200	Center	,	Unidade:
			Gui.Font( )
		Gui,	Add,	DropDownList,	x120	yp		w300	R25					v_uni				gcl
			Gui.Font( "S10" , "Bold" )
		Gui,	Add,	Edit,			x10		yp+30	w410	h280				v_text				g_inserido	+WantTab
			Gui.Font( )
		Gui,	Add,	Button,			x220	yp+280	w200	h30										g_add						,	Adicionar
			Gui.Font( "S10" )
		Gui,	Add,	ListView,				ys		w600	h220	AltSubmit	v_lv				g_lv2						,	Unidade|Mensagem|Inserido|ID
			Gui.Font( "Bold" )
		Gui,	Add,	Edit,					yp+221	w600	h170				vshowbox
			Gui.Font()
		Gui,	Add,	Button,					yp+170	w600	h30										gpreenche_lv				,	Recarregar Avisos
			gosub	preenche_lv
		Menu, menudecontexto, Add, Excluir, Exclude
		Menu, menudecontexto, Add, Editar, Edit
		Gui,	Show,,	Adicionar E-Mail
			gosub	ddl
return

cl:				;	Usado em debug apenas
	Gui,	Submit,	NoHide
	; MsgBox % _multidate
	; Clipboard:=_uni
return

_inserido:
	search_delay()
	Gui,	Submit,	NoHide
	inmsg := StrSplit( _text , "`n" )	;	Auto select da unidade no drop down list
	unidade_ := LTRIM ( RTRIM ( SubStr( inmsg[inmsg.Count() ] , 1 , InStr( inmsg[inmsg.Count()] , "/" ) > 0 ? InStr( inmsg[inmsg.Count()] , "/" )-1 : InStr( inmsg[inmsg.Count()] , "/" ) ) ) )
	if ( unidade_ = "" )				;	padrão novo de e-mails
		Loop,% inmsg.Count()
			if (InStr( inmsg[A_Index] , "Unidade - ") > 0
			&&	InStr( inmsg[A_Index] , " Unidade - ") = 0 )
				unidade_ := StrReplace( inmsg[ A_Index ] , "Unidade - " )
	GuiControl,	Choose,	_uni,  %	strings.Remove_accents( unidade_ )
	if (InStr( unidade_ , "Não-" ) > 0	;	Casos especiais de nome de unidade e ocomon
		&&	InStr( _text , "Rações" ) > 0 )
			GuiControl,	Choose,	_uni,  Sede   Fabrica De Ração
		Else if ( InStr( unidade_ , "Expodireto" ) > 0 )
			GuiControl,	Choose,	_uni,  Sede   Expodireto
		Else if (InStr( unidade_ , "esmeralda" ) > 0
		&& (InStr( _text , "Juvêncio" ) > 0
		||	InStr( _text , "Juvencio" ) > 0 ) )
			GuiControl,	Choose,	_uni, Esmeralda Juvencio
		Else if ( InStr( _text , "Área Responsável" ) > 0 )	{	;	Se for chamado do ocomon
			_text := StrReplace( _text , "`r" , "--" )
			_text := StrReplace( _text , "`n" , "++" )
			_text := StrReplace( _text , "`t" , "**" )
			Loop,	3		{
				if ( substr( _text , 1 , 2 ) = "**" )
					_text := SubStr( _text , 3 )
				if ( substr( _text , 1 , 2 ) = "++" )
					_text := SubStr( _text , 3 )
				if ( substr( _text , 1 , 2 ) = "--" )
					_text := SubStr( _text , 3 )
			}
			_text := StrReplace( _text , "**" , "`t" )
			_text := StrReplace( _text , "--" , "`r" )
			_text := StrReplace( _text , "++" , "`n" )
				; OutputDebug % _text ; Na integra
			texto_ := SubStr( _text , 1 , 6 )
					. "`n"	SubStr( _text , Instr( _text , "Descrição:" ) +11 )
				; OutputDebug % texto_
			split := strsplit( _text , "`n" )
			abertura =
			Loop,% split.Count()
				if ( InStr( split[ A_Index ] , "Aberto por:" ) > 0 )
					abertura := "`n`nAberto por:`n`t" SubStr( split[ A_Index + 1 ] , 1 , InStr( split[ A_index + 1] , " " ) -1 )
			GuiControl, , _text, % texto_ . abertura
			GuiControl,	Choose,	_uni,  Ocomon
			gosub _add
	}
	Else
		GuiControl,	Choose,	_uni,% unidade_
	;	Se há data e hora no texto, tenta fazer um autoparse dos valores
	tem_hora:=tem_data:=data_agenda:=hora_agenda:=saida:=""
	Loop,	24	;	Verifica se existe formato de horário no corpo do texto
		if ( StrLen( A_Index ) = 1 )
			if ( InStr( _text , "0" A_Index ":" ) > 0 )
				tem_hora++
		else
			if ( InStr( _text , A_Index ":" ) > 0 )
				tem_hora++
	if ( tem_hora > 0 )	{	;	Caso sim, salva o horário na var
		hora_agenda := StrReplace( SubStr( _text , InStr( _text , ":" )-2 , +5 ) , ":" )
		hora_agenda := RegExReplace( RegExReplace( RegExReplace( hora_agenda , "[^,\d]+" , " ") , "," , "" ) , "^\s*(\S.*\S|\S)\s*$" , "$1" )
		if ( StrLen( hora_agenda ) = 3 )
			hora_agenda := "0" hora_agenda
	}
	Loop,	31	;	Verifica se existe formato de data no corpo do texto
		if ( StrLen( A_Index ) = 1 )
			if (InStr( _text , "0" A_Index "/" ) > 0
			||	InStr( _text , "0" A_Index "-" ) > 0 )
				tem_data++
		else
			if (InStr( _text , A_Index "/" ) > 0
			||	InStr( _text , A_Index "-" ) > 0 )
				tem_data++
	if ( tem_data > 0 )	;	Caso sim, salva a data na var
		data_agenda := SubStr( _text , InStr( _text , "/" )-2 , +10 )
	StringReplace, data_agenda, data_agenda, /, , UseErrorLevel	;	Verifica se há dia mês e ano na data
	if ErrorLevel = 1 	;	Caso não, adiciona o ano ao fim da var
		data_agenda := StrReplace( SubStr( data_agenda , 1 , 5 ) , "/" ) A_Year
	numbers = 1234567890	;	Var para remover tudo que não for número da data(caso o ano tenha apenas 2 digitos no email)
	Loop,%	StrLen( data_agenda )	{	;	Verifica todos os caracteres
		character := SubStr( data_agenda , A_Index , 1 )	;	pega cada caracter na var
		If ( InStr(	numbers , character ) = 0 )	;	 verifica se ele é número
				continue
		saida .= character	;	se for número salva na saida
	}
	if ( SubStr( saida , 5 , 2 ) = 21 )	;	se não conter o ano completo(2021), adiciona o prefixo de ano 20 antes do 21
		saida := SubStr( saida , 1 , 4 ) "20" SubStr( saida , 5 , 2 )
	data_agenda := SubStr( saida , 5 , 4 ) SubStr( saida , 3 , 2 ) SubStr( saida , 1 , 2 )	;	define a var de data de saida na ordem YYYYMMDD
	; MsgBox % data_agenda
	if (tem_data = 0
	&&	InStr( _text , "amanhã" ) > 0 )
		data_agenda := A_YYYY A_MM A_DD + 1
	if (SubStr( data_agenda , 5 , 2 ) > A_MM
	||	SubStr( data_agenda , 7 , 2 ) > A_DD )	;	Se o dia ou mês for maior que os de hoje, altera a programação, caso contrário retira uma hora para não gerar evento
		GuiControl, , _date,	%	data_agenda hora_agenda
	else if ( hora_agenda > A_Hour A_Min )
		GuiControl, , _date,	% A_YYYY A_MM A_DD hora_agenda
return

preenche_lv:
	LV_Delete()
	s =
		(
		SELECT TOP 100
				p.[Mensagem]
			,	c.[Nome]
			,	p.[Inserido]
			,	p.[pkid]
			,	p.[Id_Cliente]
		FROM
			[IrisSQL].[dbo].[Clientes]	c
		LEFT JOIN
			[ASM].[ASM].[dbo].[_Agenda]	p
		ON
			p.[Id_Cliente] = c.[IdUnico]
		WHERE p.[inserido] IS NOT NULL
		ORDER BY
			3 DESC
		)
	dados_lv := sql( s )
	Loop,%	dados_lv.Count()-1
		LV_Add(	""
			,	dados_lv[ A_Index+1 , 2 ]
			,	dados_lv[ A_Index+1 , 1 ]
			,	dados_lv[ A_Index+1 , 3 ]
			,	dados_lv[ A_Index+1 , 4 ]	)
	LV_ModifyCol( 1 , 140 )
	LV_ModifyCol( 2 , 250 )
	LV_ModifyCol( 3 , 140 )
	LV_ModifyCol( 4 , 40 )
return

_lv2:			;{	Select da listView
	if A_GuiEvent = Normal	;	não funciona entre parenteses
	{
		LV_GetText( _lv , A_EventInfo , 2 )
		Loop	{
			edb := RegExReplace( _lv , "\R+\R" , "`r`n " )	;	remove linhas em branco desnecessários
			if ErrorLevel = 0
				break
		}
	}
	if	(A_EventInfo = 40
	||	 A_EventInfo = 38 )	{	;	usando as setas cima e baixo
		LV_GetText( _lv , LV_GetNext() , 2 )
		edb := RegExReplace( _lv , "\R+\R" , "`r`n " )
	}
	GuiControl,	,	showbox,	%	_lv
return

GuiContextMenu:	;{	Exibe o menu de exlusão
	if ( A_GuiControl != "_lv" )
		return
	lastline := A_EventInfo 
	Menu, menudecontexto, Show, %A_GuiX%, %A_GuiY%
return

Exclude:		;{	Menu de exclusão
	Gui,	Submit,	NoHide
	LV_GetText( Mensagem , lastline , 2 )
	LV_GetText( idremove , lastline , 4 )
	MsgBox,	1,	Exclusão de Evento,	Deseja realmente excluir o seguinte evento:`n`n`n"%Mensagem%"
	IfMsgBox,	No
		return
	else {
		d = DELETE FROM [ASM].[dbo].[_Agenda] WHERE [pkid] = '%idremove%'
			sql( d , 3 )
			; MsgBox % sql_le
		d = DELETE FROM [ASM].[dbo].[_agenda_alertas] WHERE [id_aviso] = '%idremove%'
			sql( d , 3 )
			; MsgBox % sql_le
		GuiControl,	,	showbox
	}
	LV_Delete()
	goto preenche_lv
;

;	Menu de edição
	Edit:
		Gui,	Submit,	NoHide
		LV_GetText( _nome	, lastline , 1 )
		LV_GetText( Mensagem, lastline , 2 )
		LV_GetText( _data	, lastline , 3 )
		LV_GetText( id_edit	, lastline , 4 )
		Gui,	Destroy
			Gui.Cores()
		Gui, +ToolWindow +AlwaysOnTop
		Gui, Margin, 0, 0
			Gui.Font( "Bold" , "s10" )
		Gui, Add, Edit, 	x10		y15		w580	h300	v_mensagem	,%	mensagem
			Gui.Font( )
		Gui, Add, Button,	x10		y320	w280	h30		gFinalizar	,	Finalizar
		Gui, Add, Button,	x310	y320	w280	h30		gCancelar	,	Cancelar
		Gui, Show,							w600	h360				,	Editar
		Send, {Down}
	Return

	Cancelar:
		Gui, Destroy
		Goto, Interface
	;

	Finalizar:
		Gui, Submit, NoHide
		e =
			(
			UPDATE
				[ASM].[dbo].[_Agenda]
			SET
				[Mensagem] = '%_mensagem%'
			WHERE
				[pkid] = '%id_edit%'
			)
			sql( e , 3 )
		Gui, Destroy
		Gosub, Interface
		Gui, Submit, NoHide
		GuiControl, Focus, _lv
		LV_GetText( mensagem, lastline, 2 )
		LV_Modify( lastline , "Select" )
		GuiControl, , showbox,% mensagem
	Return
;

_add:
	Gui,	Submit,	NoHide
	if ( _text = "" )	{
		MsgBox Você precisa adicionar algum texto para poder salvar!
		return
	}
	if ( _uni = "" )	{
		MsgBox Você precisa selecionar uma unidade para poder salvar!
		return
	}
	Loop	{	;	Remove blank lines
		_text := RegExReplace( _text , "\R+\R" , "`r`n " )
		if ErrorLevel = 0
			break
	}
	Loop, parse, forid,  `n, `r
		If ( InStr( A_LoopField , _uni ) > 0 )
			If ( InStr( A_LoopField ,	"Sede -" ) = 0 ) {
				iduni	:=	StrSplit( A_LoopField , "-" )
				idu		:=	iduni[2]
				op		:=	iduni[3] = "1;2;3;4;5" ? 0 : iduni[3]
				cli		:=	iduni[4]
			}	
			else {
				iduni	:=	StrSplit( A_LoopField , "-" )
				idu		:=	iduni[3]
				op		:=	iduni[4] = "1;2;3;4;5" ? 0 : iduni[4]
				cli		:=	iduni[5]
			}
	FormatTime, dataagendado	,% _date, yyyy-MM-dd HH:mm:ss.000
	FormatTime, inserido		,% A_Now, yyyy-MM-dd HH:mm:ss.000
	dataagendado_ := _date
	;	Message Box
		if ( multidatas.Count() != "" )	{	;	Para exibição na msgbox apenas
			dataagendado_ := datetime( 3 , RegExReplace( dataagendado_ , "\D" ) )
			Loop,%	multidatas.Count()	{
				if ( A_Index = 1 )
					dataagendado_ .= "`n`t" datetime( 3, multidatas[A_Index] )
				else
					dataagendado_ .= "`n`t" datetime( 3, multidatas[A_Index] )
			}
		}
		else
			dataagendado_ := Dataagendado
		If ( InStr( _text , "'" ) > 0 )
			_text := StrReplace( _text , "'" , "’" )
		if ( StrLen( user ) = 0 )
			user := A_IPAddress1
		quantos_dias := _multidate = 1 ? multidatas.Count()+1 : 1
		MsgBox,	0x1, Confirmar inserção de E-Mail,%	"`tConfirma adicionar os seguintes dados no sistema?"
			.	"`n`nOperador:	"				op
			.	"`nMensagem:`n---------`n`t"	_text "`n---------"
			.	"`nInserido por:`t"				user
			.	"`nInserido em:	"				agora
			.	"`nCliente:`t`t"				cli
			.	"`nAgendado para`t"				quantos_dias "`tdia(s)."
			.	"`nAgendado para:`n`t"			dataagendado_
		IfMsgBox Cancel
		{
			GuiControl, Focus, _text
			return
		}
	;

	;	Insere a mensagem na tabela Agenda
		Ins =
			(
			INSERT INTO
				[ASM].[dbo].[_Agenda]
				(	[Mensagem]
				,	[Inserido]
				,	[Gerado_Por]
				,	[Id_Cliente]
				,	[Estacao]
				,	[operador] )
			VALUES
				(	'%_text%'
				,	'%inserido%'
				,	'%user%'
				,	'%idu%'
				,	'%A_ComputerName%'
				,	'%op%'	)
			)
			sql( ins , 3 )
	;

	;	Seleciona o ID da mensagem para os Alertas
		top_1 =
			(
			SELECT TOP 1
				[pkid]
			FROM
				[ASM].[dbo].[_Agenda]
			ORDER BY
				1
			DESC
			)
		id	:= sql( top_1 , 3 )
		id	:= id[ 2 , 1 ] = "" ? "1" : id[ 2 , 1 ]
	;

	;	Datas de agendamento de alertas
		OutputDebug % "contagem " multidatas.Count()
		if ( _multidate = 1 )	;	mais de 1 dia
			Loop,% multidatas.Count()	{
				FormatTime, _add_day ,% multidatas[A_Index] , yyyy-MM-dd HH:mm:ss.000
				if (	A_Index = multidatas.Count()	;	Último
					&&	multidatas.Count() > 1 )	{
					OutputDebug % "index = último"
					notificacao .= "('" id "'`n,`t'" _add_day "'`n,`t'" op "'`n,`tNULL`n,`tNULL )"
				}
				else if (	A_Index = 1					;	Primeiro com mais de 2 dias
						&&	multidatas.Count() != 1 )	{
					OutputDebug % "index 1 e mais de 2 dias"
					_visualizado		:= RegExReplace( dataagendado, "\D") > RegExReplace( datetime(1) , "\D") ? "NULL" : "'1'"
					_data_visualizado	:= RegExReplace( dataagendado, "\D") > RegExReplace( datetime(1) , "\D") ? "NULL" : "'" dataagendado "'"
					notificacao :=	"('" id "'`n,`t'" dataagendado "'`n,`t'" op "'`n,`t" _visualizado "`n,`t" _data_visualizado " ),`n"
								.	"('" id "'`n,`t'" _add_day "'`n,`t'" op "'`n,`tNULL`n,`tNULL ),`n"
				}
				else if (	A_Index = 1					;	Primeiro com apenas 2 dias
						&&	multidatas.Count() = 1 )	{
					OutputDebug % "index 1 e 2 dias apenas"
					_visualizado		:= RegExReplace( dataagendado, "\D") > RegExReplace( datetime(1) , "\D") ? "NULL" : "'1'"
					_data_visualizado	:= RegExReplace( dataagendado, "\D") > RegExReplace( datetime(1) , "\D") ? "NULL" : "'" dataagendado "'"
					notificacao :=	"('" id "'`n,`t'" dataagendado "'`n,`t'" op "'`n,`t" _visualizado "`n,`t" _data_visualizado " )"
								.	",`n('" id "'`n,`t'" _add_day "'`n,`t'" op "'`n,`tNULL`n,`tNULL )"
				}
				else	{								;	Datas entre meio primeira e última
					OutputDebug % "Entre meio datas"
					notificacao .= "('" id "'`n,`t'" _add_day "'`n,`t'" op "'`n,`tNULL`n,`tNULL ),`n"
				}
			}
		else	{	;	1 dia apenas
			_visualizado		:= RegExReplace( dataagendado, "\D") > RegExReplace( datetime(1) , "\D") ? "NULL" : "'1'"
			_data_visualizado	:= RegExReplace( dataagendado, "\D") > RegExReplace( datetime(1) , "\D") ? "NULL" :  "'" dataagendado "'"
			notificacao			:= "('" id "'`n,`t'" dataagendado "'`n,`t'" op "'`n,`t" _visualizado "`n,`t" _data_visualizado " )"
		}
		ins =
			(
			INSERT INTO
				[ASM].[dbo].[_Agenda_Alertas]
					(	[id_aviso]
					,	[data_alerta]
					,	[quem_avisar]
					,	[visualizado]
					,	[data_visualizado]	)
				VALUES
					`n%notificacao%
			)
			sql( ins , 3 )
	;
	Gui, Destroy	;	rever para carregar sem destruir
	_multidate	= 0
	Dataagendado= dataagendado_ = ""
	multidatas	:= []
	Goto, gui
;

DC:
	If !DMC( Hdate )
		Send {Right}
Return

DMC( HWND ) {
	Static DTM_GETMONTHCAL := 0x1008
	Return DllCall(	"User32.dll\SendMessage",	"Ptr"
				,	HWND					,	"UInt"
				,	DTM_GETMONTHCAL			,	"Ptr"
				,	0						,	"Ptr"
				,	0						,	"Ptr"	)
}

ddl:
	d =
		(
		SELECT
				[Nome]
			,	[IdUnico]
			,	[Classe]
			,	[Cliente]
		FROM
			[IrisSQL].[dbo].[Clientes]
		WHERE
			[Cliente] = '10001'	AND
			[Particao] > '001'
		ORDER BY
			1
		ASC
		)
	u := sql( d )
	Loop,% u.Count()-1	{
		unidade		:=	u[A_Index+1,1]
		If ( InStr(	unidade , "-" ) > 0 )
			unidade	:=	StrReplace( unidade , "-" , " " )
		unidadeid	:=	u[A_Index+1,2] "-" u[A_Index+1,3] "-" u[A_Index+1,4]
		StringLower, unidade, unidade, T
		unidades	:=	unidades	"|"	unidade	;	ddl
		forid		:=	unidade "-" unidadeid "`n" forid
	}
	GuiControl, , _uni, %unidades%
return

Multi_data:				;{	Email para mais de um dia
	Gui,	Submit,	NoHide
	if ( _multidate = 0 )	{	;	Limpar o array caso for desmarcado
		multidatas := []
		return
	}
	InputBox, dias,	Multi Datas, E-Mail válido para mais quantos dias?, ,,130, , , , , 1
	numeros = 0123456789
	if ( InStr( numeros , dias ) = 0
	||	ErrorLevel = 1 )
		return
	pre_date	:= _date	;	data autal
	_date		+= 1 , Days	;	mais um dia na data atual
	ndate		:= _date	;	data nova
	Gui.Cores( "Multi" )
	Gui, multi:Add,	DateTime,	x10	w200	h30	hwndHdate	Choose%_date%						v_date1				gDC,	dd/MM/yyyy HH:mm:ss
		Loop,%	dias-1	{
			ndate += 1 ,	Days
			Gui, multi:Add,	DateTime,	%	"x10	w200	h30	hwndHdate	Choose"	ndate	"	v_date"	A_Index+1 "	gDC",	dd/MM/yyyy HH:mm:ss
		}
	Gui, multi:Add,	Button,		x10	W200																		gOkDatas,	Finalizar
	Gui, multi:Show,				w220																				,	Mais Dias
	Gui, multi:+AlwaysOnTop
return

OkDatas:
	Gui, multi:Submit,	NoHide
	_date += -1 ,	Days
	; multidatas.push( _date )
	Loop,%	dias
		multidatas.push( _date%A_Index% )
	Gui,	multi:Destroy
Return

MultiGuiClose:
	multidatas := []
	Gui,	multi:Destroy
return