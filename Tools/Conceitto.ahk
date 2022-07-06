File_Version=0.2.0
Save_to_sql=1
Keep_Versions=2
;@Ahk2Exe-SetMainIcon	C:\AHK\icones\fun\conceitto.ico
	#IfWinActive, Cadastro de Câmeras
	inicio	:=	A_Now
	#Persistent
	#SingleInstance Force
	#Include	C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include	C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	#Include	C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	#Include	C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	#Include	C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	#Include	C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include	C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include	C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	#Include	C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include	C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

;	Definições
	global	debug						 = 
	Coordmode, ToolTip, Screen
;

;	Interface
	OutputDebug % "Iniciando construção da interface."
	Gui.Cores()
		Gui.Font( "S10" , "Bold" )
	Gui, +DPIScale
	Gui, Add, Edit,		x10		y10	w300					h30		v_busca					Section
		Gui.Font( "cWhite" )
	Gui, Add, Checkbox,	xs									h30		v_definidos	g_filtro	Section	, Exibir apenas câmeras já configuradas
	Gui, Add, Checkbox,			ys							h30		v_run					Checked	, Abrir imagem no navegador ao gerar link
		Gui.Font( )
		Gui.Font( "S10" , "Bold" )
	Gui, Add, ListView,%	"xs		w" A_ScreenWidth-20 "	h" A_ScreenHeight-200 " v_listview	Grid", Nome|Ip|Receptora|Conta|guid|id|Servidor|api|Marcae
		LV_ModifyCol( 1 , 300 )
		LV_ModifyCol( 2 , 100 )
		LV_ModifyCol( 3 , 100 " integer" )
		LV_ModifyCol( 4 , 100 " integer" )
		LV_ModifyCol( 5 , 0 )
		LV_ModifyCol( 6 , 0 )
		LV_ModifyCol( 7 , 75 )
		LV_ModifyCol( 8 , 0 )
		LV_ModifyCol( 9 , 0 )
		Gosub, preenche_listview
	Gui, Add, Button,	xm			w400					h30					g_copyUrl	Section	, Copiar URL
	Gui, Add, Button,			ys	w400					h30		gGuiClose						, Cancelar
	Gui, Show, x0 y0, Cadastro de Câmeras
return

Enter::
	NumpadEnter:
	_filtro:
	Gui, Submit, NoHide
		OutputDebug % "filtro de unidade = " _definidos
	GuiControl, Disable, _busca
	GuiControl, Disable, _definidos
	GuiControl, Disable, _listview
	if ( _definidos = 1 )
		definidos = AND [receiver] != 10001
	Else 
		definidos =
	LV_Delete()
Goto, preenche_listview

preenche_listview:
	Gui, Submit, NoHide
	s =
		(
		SELECT	[name]
			,	[ip]
			,	[receiver]
			,	[contactId]
			,	[guid]
			,	[id]
			,	[server]
			,	[api_get]
			,	[vendormodel]
		FROM
			[Dguard].[dbo].[cameras]
		WHERE
			([name] like '%_busca%`% [[] BAL ] Plat`%'
		OR
			[name] like '%_busca%`% [[] BAL ] Carga`%')
		%definidos%
		ORDER BY
			[name]
		)
	servers	:=	sql( s , 3 )
	Loop,%	servers.Count()-1
		LV_Add( ""
			,	servers[A_Index+1, 1]
			,	servers[A_Index+1, 2]
			,	servers[A_Index+1, 3]	= "10001"
										? ""
										: servers[A_Index+1, 3] = "10000"
										? ""
										: servers[A_Index+1, 3]
			,	servers[A_Index+1, 4]	= "0000"
										? ""
										: servers[A_Index+1, 4]
			,	servers[A_Index+1, 5]
			,	servers[A_Index+1, 6]
			,	servers[A_Index+1, 7]
			,	servers[A_Index+1, 8]
			,	servers[A_Index+1, 9]	)
	GuiControl, Enable,	_definidos
	GuiControl, Enable,	_busca
	GuiControl, Enable,	_listview
	GuiControl, Focus,	_busca
	where =
Return

^c::
	_copyURL:
	OutputDebug % "Iniciando preparação ou cópia de URL"
	Gui, Submit, NoHide
	listview_line			:=	LV_GetNext()
	LV_GetText( nome		,	LV_GetNext() , 1 )
	LV_GetText( ip			,	LV_GetNext() , 2 )
	LV_GetText( receptora	,	LV_GetNext() , 3 )
	LV_GetText( conta		,	LV_GetNext() , 4 )
	LV_GetText( guid		,	LV_GetNext() , 5 )
	LV_GetText( id_unidade	,	LV_GetNext() , 6 )
	LV_GetText( server		,	LV_GetNext() , 7 )
	LV_GetText( api			,	LV_GetNext() , 8 )
	LV_GetText( marca		,	LV_GetNext() , 9 )
	receptora	:=	RegExReplace( receptora,	"\D")
	conta		:=	RegExReplace( conta,		"\D")
	id_unidade	:=	RegExReplace( id_unidade,	"\D")
	server		:=	RegExReplace( server,		"\D")
	if (receptora = "10001"
	||	receptora = "" )
		Gosub, Cadastra
	Else
		Clipboard := api
	OutputDebug % "URL Copiada com sucesso"
	OutputDebug % "Verificando ping`n`t" ping( ip ) "`n`t" ip
	Clipboard	:= LTrim( RTrim( Clipboard ) )
	ToolTip, URL copiada para o Clipboard com sucesso!
	if ( ping( ip ) = 0 )
		MsgBox A câmera que você selecionou`, não respondeu ao teste de ping. Verificar se a mesma não está indisponível.
	Else {
		if _run
			Run,% "microsoft-edge:" Clipboard
		if	(	InStr( marca,	"Dahua" )
		&&	(	InStr( nome,	" Carga" )
		OR		InStr( nome,	" Plataforma" ) ) ) {
			URL		:=	"http://admin:tq8hSKWzy5A@" ip "/cgi-bin/configManager.cgi?action=setConfig"
			OVERLAY	:=	url	"&VideoWidget[0].ChannelTitle.PreviewBlend=false"
						.	"&VideoWidget[0].ChannelTitle.EncodeBlend=false"
						.	"&VideoWidget[0].TimeTitle.PreviewBlend=true"
						.	"&VideoWidget[0].TimeTitle.EncodeBlend=true"
			ENCODE	:=	url	"&Encode[0].MainFormat[0].Video.Compression=H.264"
						.	"&Encode[0].MainFormat[0].Video.BitRate=512"
						.	"&Encode[0].MainFormat[0].Video.BitRateControl=VBR"
						.	"&Encode[0].MainFormat[0].Video.resolution=1280x720"
						.	"&Encode[0].MainFormat[0].Video.FPS=12"
						.	"&Encode[0].MainFormat[0].Video.GOP=24"
						.	"&Encode[0].MainFormat[0].Video.Quality=6"
			CODEC	:=	"http://admin:tq8hSKWzy5A@" ip "/cgi-bin/configManager.cgi?action=getConfig&name=Encode[0].MainFormat[0].Video.Compression"
			http( OVERLAY )
			codec := StrRep( http( CODEC, , 1 ),, "table.Encode[0].MainFormat[0].Video.Compression=", "`n", "`r" )
			OutputDebug, % codec
			If	!InStr( codec, "264" ) {
				MsgBox, , CODEC ERRADO, Câmera com codec %codec%`, a câmera será configurada para o codec H264 e reiniciada à seguir.
				http( ENCODE )
				http( "http://admin:tq8hSKWzy5A@" ip "/cgi-bin/magicBox.cgi?action=reboot" )
			}
		}
	}
	Sleep, 3000
	ToolTip
Return

cadastra:
	erro =
	id_unidade := LTrim( RTrim( id_unidade ) )
	s	=
		(
		SELECT	TOP(1)
			[contactId]
		FROM
			[Dguard].[dbo].[cameras]
		WHERE
			[receiver] = '%id_unidade%'
			ORDER BY 1 DESC
		)
	contacts := sql( s , 3 )
	if ( (contacts.Count()-1) = 0 )
		new_contact := 1
	Else
		new_contact := contacts[2,1] + 1


	OutputDebug % "New Contact-ID = " new_contact "`n" id_unidade
	OutputDebug % "Iniciando cadastro"
	OutputDebug % "Adquirindo token"
	token_new	:=	Dguard.token( "vdm0" server )
	bar	:= "\"""
	comando :=	"""http://SERVIDOR:8081/api/servers/%7B" guid "%7D/contact-id"
			.	""" -H ""accept: application/json"
			.	""" -H ""Authorization: bearer " token_new ""
			.	""" -H ""Content-Type: application/json"
			.	""" -d ""{"
			.	bar "receiver"	bar ":" id_unidade ","
			.	bar "account"	bar ":" bar new_contact bar ","
			.	bar "partition"	bar ":" bar "00" bar "}"""
	if ( InStr( erro := dguard.curl( comando , "vdm0" server , "PUT" ), "contactid" ) > 0 ) {		;	adiciona o novo receiver
		OutputDebug % "Vinculado câmera à receptora sem erros."
		Clipboard := new_api := "http://conceitto:cjal2021@vdm0" server ":85/camera.cgi?Receiver=" id_unidade "&server=" new_contact "&camera=0&resolucao=640x480&qualidade=100"
		u	=
			(
			UPDATE [Dguard].[dbo].[cameras]
			SET
				 [receiver]	= '%id_unidade%'
				,[contactid]= '%new_contact%'
				,[api_get]	= '%new_api%'
			WHERE
				[guid]		= '%guid%'
			)
		sql( u , 3 )
		LV_Delete(	listview_line )
		LV_Insert(	listview_line , ""
				,	nome
				,	ip
				,	id_unidade
				,	new_contact
				,	guid
				,	id_unidade
				,	server
				,	new_api	)
	}
	OutputDebug % "Finalizado vinculação de câmera a receptora Existente"
Return

GuiClose:
	ExitApp