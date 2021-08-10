;@Ahk2Exe-SetMainIcon \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\ico\rel.ico

global	debug				;	Core = 1, funções 2, core e funções = 3, classes = 4, core e classes = 5, funções e classes = 6, tudo = 7
	,	edit_row			;	guicontext
	,	in_edit				;	guicontext
	,	relatorio_anterior	;	guicontext
	,	pkid				;	guicontext
	,	edicoes				;	guicontext
is_test = 
debug = 

#IfWinActive, Login Cotrijal
#SingleInstance Force
#Persistent
#Include ..\class\sql.ahk
#Include ..\class\functions.ahk
#Include ..\class\windows.ahk
#Include ..\class\array.ahk
#Include ..\class\gui.ahk
#Include ..\class\safedata.ahk

; #Include classes.ahk

if ( A_IsCompiled )	{
	usuario_logado := a_args[1]
	if ( usuario_logado = "liberar" )
		goto skip
	if ( usuario_logado = "" )
		ExitApp
		Else	{
			nome_user := Windows.Users( usuario_logado )
			S =
				(
				SELECT
					[cargo]
				FROM
					[ASM].[dbo].[_colaboradores]
				WHERE
					[nome] = '%nome_user%'
				)
			s := sql( s, 3 )
			if ( InStr(s[2,1], "Agente de monitoramento") = 0 )	{
				MsgBox, , Finalizando,% "Seu cargo (" S[2,1] ") não tem autorização para acessar esse sistema."
				ExitApp
				}
			}
	;	Update
	skip:
	version = 1.0.0.6
	changelog = Adicionado função de edição de relatórios.
	}
v =
	(
	SELECT	[version]
		,	[changelog]
		,	[updated]
	FROM
		[ASM].[dbo].[_versionamento]
	WHERE
		[sistema] = 'RelatorioIndividual'
	)
c := sql( v, 3 )
if (	A_IpAddress1 = "192.9.100.184"
	&&	c[2,1] < version )	{
	if ( StrLen(Changelog) > 0 and instr( c[2,2], changelog ) = 0 )	{
		changelog := "> "Date.Now() ":`t" changelog "`n" c[2,2]
		v=
			(
			IF NOT EXISTS (SELECT [version] FROM [ASM].[dbo].[_versionamento] WHERE [sistema]='RelatorioIndividual')
				INSERT INTO
					[ASM].[dbo].[_versionamento]
						(version,sistema,updated,changelog)
					VALUES
						('%version%','RelatorioIndividual',GETDATE(),'%changelog%')
			ELSE
				UPDATE
					[ASM].[dbo].[_versionamento]
				SET
					[version]='%version%',
					[updated]=GETDATE(),
					[Changelog]='%changelog%'
				WHERE
					[sistema]='RelatorioIndividual'
			)
		}
	Else
		v=
			(
			IF NOT EXISTS (SELECT [version] FROM [ASM].[dbo].[_versionamento] WHERE [sistema]='RelatorioIndividual')
				INSERT INTO
					[ASM].[dbo].[_versionamento]
						(version,sistema,updated)
					VALUES
						('%version%','RelatorioIndividual',GETDATE())
			ELSE
				UPDATE
					[ASM].[dbo].[_versionamento]
				SET
					[version]='%version%',
					[updated]=GETDATE()
				WHERE
					[sistema]='RelatorioIndividual'
			)
	sql(v,3)
	}
if (	A_IsCompiled
	&&	c[2,1] < version )	{
	FileMove, % A_ScriptFullPath, % A_ScriptDir "\" 4delete, 1
	FileCopy, \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\relatorio_individual.exe,% A_ScriptDir "\relatorio_individual.exe", 1
	}
if ( is_test = 1 )	{
	@usuario = dsantos
	Goto interface
	}
	Else
		Goto, Login
;	Return

Interface:
	; OutputDebug % "Interface pré " logou
	Gui, Login:Destroy
	nm_usuario_ad := Windows.Users( @usuario )
		gui.Cores( "", "9BACC0", "374658" )
	Gui, Add, MonthCal,%		"x20					y20		w230					h300	v@date			g_b_data"
		gui.Font( "S12", "Bold", "cWhite" )
		Gui, Add, Text,%		"x255					y20		w150					h25										+Center	0x1000	",	Buscar
		gui.Font()
	Gui, Add, ListView,%		"x255					y60		w430					h260	v@lv AltSubmit	g_s_relatorio	Grid					",	Data|Relatório|Nome|id|pre|edicoes|ip
		gui.Font( "S10", "Bold" )
	Gui, Add, Edit,%			"x405					y20		w" A_ScreenWidth-530 "	h25		v@b_relatorios	g_busca"
		gui.Font()
		gui.Font( "S10", "cWhite" )
	Gui, Add, Edit,%			"x690					y60		w" A_ScreenWidth-715 "	h260	v@e_relatorios	g_e_relatorio	+ReadOnly	+WantTab"
		gui.Font()
		gui.Font( "S10" )
	Gui, Add, Edit,%			"x20					y350	w" A_ScreenWidth-45 "	h260	v@n_relatorio								+WantTab"
	Gui, Add, Button,%			"x" A_ScreenWidth-225 "	y625	w200					h30						g_i_relatorio							",	INSERIR
		Gui, Add, GroupBox,%	"x10					y0		w" A_ScreenWidth-25 "	h620	vb_geral"
		Gui, Add, GroupBox,%	"x10					y330	w" A_ScreenWidth-25 "	h290	vb_inserir"
		Gui, Add, GroupBox,%	"x" A_ScreenWidth-235 "	y612	w220					h50		vb_botoes"
	Gui, Add, Button,%			"x" A_ScreenWidth-115 "	y20								h25						g_informacoes							",	Informações
		Gosub, Carrega_Relatorios
	Gui, Show,%					"x-2					y0		w" A_ScreenWidth "																		",	Relatório Individual
	OutputDebug % "Show"
return

Carrega_Relatorios:
	Gui,	1:Default
	Gui,	ListView, @lv
	relatorios:={}
	select=
		(
			SELECT	[data]
				,	[relatorio]
				,	[nome]
				,	[pkid]
				,	[relatorio_pre_edit]
				,	[edicoes]
				,	[ip]
				,	[relatorio_temporario]
				,	[user_ad]
			FROM
				[ASM].[DBO].[_Relatorios_Individuais]
			WHERE
				[user_ad] = '%@Usuario%'
			ORDER BY
				[pkid] DESC
		)
	if ( debug = 1 )	{
		OutputDebug % relatorios_existentes.Count()-1
		Clipboard := select
		}
	relatorios_existentes := sql( select, 3 )
	LV_Delete()
	Loop, %	relatorios_existentes.Count()-1	{
		if ( StrLen( relatorios_existentes[A_Index+1,8] ) > 0 )	{	;	temporario
			GuiControl, , @n_relatorio,%	relatorios_existentes[A_Index+1,8]
			continue
			}
		relat_ := Safe_Data.Decrypt( relatorios_existentes[A_Index+1,2], relatorios_existentes[A_Index+1,9] )
		relatorios.push({	data		:	relatorios_existentes[A_Index+1,1]
						,	relatorio	:	relat_
						,	nome		:	relatorios_existentes[A_Index+1,3]
						,	id			:	relatorios_existentes[A_Index+1,4]
						,	anteriores	:	relatorios_existentes[A_Index+1,5]
						,	edicoes		:	relatorios_existentes[A_Index+1,6]
						,	ip			:	relatorios_existentes[A_Index+1,7]
						,	temp		:	relatorios_existentes[A_Index+1,8]
						,	user		:	relatorios_existentes[A_Index+1,9]	})
		LV_Add(
			,	relatorios_existentes[A_Index+1,1]
			,	relat_
			,	relatorios_existentes[A_Index+1,3]
			,	relatorios_existentes[A_Index+1,4]
			,	relatorios_existentes[A_Index+1,5]
			,	relatorios_existentes[A_Index+1,6]
			,	relatorios_existentes[A_Index+1,7])
		}
	Loop, 8
		LV_ModifyCol( A_index+2, 0 )
		LV_ModifyCol( 1, 120 )
		LV_ModifyCol( 4, "Integer" )
		LV_ModifyCol( 2, 300 )
	; OutputDebug % "relatorios: " relatorios.count()
	LV_GetText( _insere_relatorio, 1, 2 )
	GuiControl, , @e_relatorios ,% _insere_relatorio
Return

_b_data:
	GuiControl, , @b_relatorios
_busca:
	Gui,	Submit,	NoHide
	; OutputDebug % A_GuiEvent
	LV_Delete()
	if ( @date != SubStr(A_Now,1,8) and StrLen(@b_relatorios) = 0 )			{
		; OutputDebug % "Filtrou data diferente e sem filtro"
		data:=SubStr(@date,7,2) "/" SubStr(@date,5,2) "/" SubStr(@date,1,4)
		existentes:=array.indict(relatorios,data,"data",1,1)
		}
	else if ( @date = SubStr(A_Now,1,8) and StrLen(@b_relatorios) = 0 )		{
		; OutputDebug % "Filtrou data igual e sem filtro"
		existentes:=array.indict(relatorios,@b_relatorios,"relatorio",1,1)
		}
	else if ( @date != SubStr(A_Now,1,8) and StrLen(@b_relatorios) != 0 )	{
		; OutputDebug % "Filtrou data diferente e com filtro"
		subfilter:={}
		data:=SubStr(@date,7,2) "/" SubStr(@date,5,2) "/" SubStr(@date,1,4)
		existentes:=array.indict(relatorios,data,"data",1,1)
		; outputdebug % "encontrados com data: " existentes.Count()
		Loop,	%	existentes.Count()	{
			subfilter.Push({	data		:	relatorios[existentes[A_index]].data
							,	relatorio	:	relatorios[existentes[A_index]].relatorio
							,	nome		:	relatorios[existentes[A_index]].nome
							,	id			:	relatorios[existentes[A_index]].id
							,	anteriores	:	relatorios[existentes[A_index]].anteriores
							,	edicoes		:	relatorios[existentes[A_index]].edicoes
							,	ip			:	relatorios[existentes[A_index]].ip			})
			}
		existentes:=array.indict(subfilter,@b_relatorios,"Relatorio",1,1)
		; OutputDebug %  existentes.Count()
		Loop,	%	existentes.Count()
			LV_Add(
				,	subfilter[existentes[A_Index]].data
				,	subfilter[existentes[A_Index]].relatorio
				,	subfilter[existentes[A_Index]].nome
				,	subfilter[existentes[A_Index]].id
				,	subfilter[existentes[A_Index]].anteriores
				,	subfilter[existentes[A_Index]].edicoes
				,	subfilter[existentes[A_Index]].ip	)
		Return
		}
	Else	{
		; OutputDebug % "Filtrou data igual e com filtro"
		existentes:=array.indict(relatorios,@b_relatorios,"Relatorio",1,1)
		}
	Loop,	%	existentes.Count()
			LV_Add(
				,	relatorios[existentes[A_Index]].data
				,	relatorios[existentes[A_Index]].relatorio
				,	relatorios[existentes[A_Index]].nome
				,	relatorios[existentes[A_Index]].id
				,	relatorios[existentes[A_Index]].anteriores
				,	relatorios[existentes[A_Index]].edicoes
				,	relatorios[existentes[A_Index]].ip	)
	; OutputDebug Executou Busca de: %@b_relatorios%
Return

_s_relatorio:
	relatorio_editado := @e_relatorios
	Gui,	Submit,	NoHide
	if (	A_GuiEvent	=	"ColClick"
		&&	A_EventInfo	=	"1"	)	{
			sort := !sort
			order := sort	=	1
							?	""
							:	"Desc"
		if ( debug = 1 )
			OutputDebug % "Sort = " sort "`n`tOrder: "	 order
		LV_ModifyCol( 4 , "Sort" order )
		}
	if (	A_GuiEvent	=	"Normal"
		||	A_GuiEvent	=	"K" )	{
		if ( A_EventInfo = 0 )
			lv_GetText( @relatorio, s_row := A_EventInfo+1, 2 )
			Else
				lv_GetText( @relatorio, s_row := A_EventInfo, 2 )
		if (	A_GuiEvent	=	"K"
			&&	(	A_EventInfo = 40
				||	A_EventInfo = 38 ) )	;	trata select com as arrow keys
			lv_GetText( @relatorio, s_row := LV_GetNext(), 2 )
	
		GuiControl, , @e_relatorios ,% @Relatorio
		Return
		}
Return

_i_relatorio:
	Gui,	Submit,	NoHide
	Gui, -AlwaysOnTop
	if ( strlen(@n_relatorio) < 9 ) {
		MsgBox,,Texto insuficiente, Seu relatório necessita ter pelo menos 10 caractéres para poder ser salvo.
		Return
		}
	@n_relatorio_ := Safe_Data.Encrypt( @n_relatorio, @usuario)
	; OutputDebug % "Insere Novo Relatório:`n`t" user_ad "`n_____"
	insert=
		(
		IF NOT EXISTS (SELECT [relatorio_temporario] FROM [ASM].[dbo].[_relatorios_individuais] WHERE [user_ad] = '%@Usuario%' and [relatorio_temporario] is not NULL)
			INSERT INTO
				[ASM].[dbo].[_relatorios_individuais]
					([nome],[data],[relatorio],[edicoes],[ip],[user_ad])
				VALUES
					('%nm_usuario_ad%',GETDATE(),'%@n_relatorio_%','0','%A_IpAddress1%','%@Usuario%')
		ELSE
			UPDATE
				[ASM].[dbo].[_relatorios_individuais]
			SET
				[relatorio] = '%@n_relatorio_%',
				[relatorio_temporario] = NULL,
				[Data] = GETDATE()
			WHERE
				[user_ad] = '%@Usuario%' AND
				[relatorio_temporario] is not NULL
		)
		insert := sql( insert, 3 )
		index := relatorios.Count()+1
		relatorios.push({	data		:	A_DD "/" A_MM "/" A_yyyy " " A_Hour ":" A_Min ":" A_Sec
						,	relatorio	:	@n_relatorio
						,	nome		:	@Usuario
						,	id			:	relatorios_existentes[index,4]
						,	anteriores	:	""
						,	edicoes		:	"0"
						,	ip			:	A_IPAddress1	})
		LV_Insert(	1,
				,	relatorios[index].data
				,	relatorios[index].relatorio
				,	relatorios[index].nome
				,	relatorios[index].id
				,	relatorios[index].anteriores
				,	relatorios[Index].edicoes
				,	relatorios[Index].ip )
			LV_ModifyCol()
			Loop,	5
				LV_ModifyCol(A_index+2,0)
		GuiControl,	,@n_relatorio
	GuiControl, , @e_relatorios ,% @n_relatorio
Return

Login:
	gui.Cores("login","9BACC0","374658")
		Gui, login:Font,	Bold	S10 cWhite
	Gui, login:Add, Text,	x10	y10		w80		h25		0x1200		center			, Usuário
	Gui, login:Add, Text,	x10	y40		w80		h25		0x1200		center			, Senha
		Gui, login:Font
		Gui, login:Font, Bold S10
	Gui, login:Add, Edit,	x90	y10		w140	h25		v@usuario
	Gui, login:Add, Edit,	x90	y40		w140	h25		v@senha		Password
	; Gui, login:Add, Button,	x10	y55		w221	h25					g_Autenticar	, Ok
		Gui, login:Font
	Gui, login: +AlwaysOnTop	-MinimizeBox
	Gui, login:Show,																, Login Cotrijal
	Sleep, 500
	Gui, login:+LastFound
	Guicontrol, login:Focus, @usuario
	Return

	_Autenticar:
		Gui,	Login:Submit,	NoHide
		is_login := Login(@usuario,@senha)
		if ( logou = "interface" )
			Return
		goto,	%	logou := Login(@usuario,@senha) =	0
											?	"GuiClose"
											:	"Interface"
	Return

	Login(@usuario,@senha)	{
		return DllCall(	"advapi32\LogonUser"
					,	"str",	@usuario
					,	"str",	"Cotrijal"
					,	"str",	@senha
					,	"Ptr",	3
					,	"Ptr",	3
					,	"UintP"
					,	nSize	)	=	1
						?	"1"
						:	"0"
	}
	~Enter::
		~NumpadEnter::
		Goto _Autenticar
Return

GuiClose:
	loginGuiCLose:
	if ( StrLen(@usuario) != 0 and StrLen(@senha) != 0 or is_login = 0 )	{
		if ( debug = 1 )
			OutputDebug % "Login Gui Close"
		login_in := Login(@usuario,@senha) = 0 ? 0 : 1
		if ( login_in = 0 )	{
			Gui,	Login:Destroy
			MsgBox,,Falha de Login, Usuário ou Senha inválido!
			}
		}
		OnExit, Relatorio_Temporario
; return

Relatorio_Temporario:
	Gui,	Submit, NoHide
	if ( debug = 1 )
		OutputDebug % StrLen(@n_relatorio)
	if ( StrLen(@n_relatorio) > 0 ) {
		; OutputDebug % "Temp Save: " @n_relatorio "`n`t" user_ad "`n_____"
		insert=
			(
			IF NOT EXISTS (SELECT [relatorio_temporario] FROM [ASM].[dbo].[_relatorios_individuais] WHERE [user_ad] = '%@Usuario%' and [relatorio_temporario] is not NULL)
				INSERT INTO
					[ASM].[dbo].[_relatorios_individuais]
						([nome],[data],[relatorio_temporario],[edicoes],[ip],[user_ad])
					VALUES
						('%nm_usuario_ad%',GETDATE(),'%@n_relatorio%','0','%A_IpAddress1%','%@Usuario%')
			ELSE
				UPDATE
					[ASM].[dbo].[_relatorios_individuais]
				SET
					[relatorio_temporario]='%@n_relatorio%'
				WHERE
					[user_ad] = '%@Usuario%' AND
					[relatorio_temporario] is not NULL
			)
		; Clipboard:=insert
		insert:=sql(insert,3)
		}
	Else	{
		if ( login_in = 1 ) {
			delete =
				(
				DELETE FROM
					[ASM].[dbo].[_relatorios_individuais]
				WHERE
					[user_ad] = '%@Usuario%' and
					[relatorio_temporario] is not NULL
				)
			sql( delete, 3 )
			if ( debug = 1 )
				OutputDebug % "sai normal COM login"
			}
			if ( debug = 1 )
				OutputDebug % "sai normal SEM login"
		}
ExitApp

_informacoes:
	WinHide,	Relatório Individual
	dicas=
		(
		> Utilize o filtro de CALENDÁRIO para buscar um dia específico
		> Busque relatórios com palavras específicas pelo campo BUSCAR
		> O relatório necessita ter pelo menos 10 caracteres para poder ser inserido.
		> Lembre-se de FECHAR o programa de Relatórios Individuais após inserir ou visualizar a informação que necessita.
		> Você pode editar um relatório de até 2 dias atrás.
		> Cada relatório só pode ser editado UMA vez e seu coordenador será notificado que o mesmo foi editado.
		> Para editar um relatório, basta clicar com o botão direito no mesmo na lista de exibição e selecionar a opção "EDITAR RELATÓRIO".
		)
	dicas := StrReplace( dicas, "`t" )
	gui.Cores( "info", "9BACC0", "374658" )
	Gui,	info:+AlwaysOnTop
	Gui,	info:-Caption -Border +AlwaysOnTop +OwnDialogs
	gui.Font( "info:", "cWhite", "Bold" )
	Gui,	info:Add,	Text,%		"x10						y10		w" A_ScreenWidth-250 "	h20		0x1000"			,	Versão:	%version%
	Gui,	info:Add,	Text,%		"x10						y40		w" A_ScreenWidth-250 "	h20		0x1000"			,%	"Atualizado em " c[2,3]
	Gui,	info:Add,	Text,%		"x10						y250	w" A_ScreenWidth-20  "	h130	0x1000"			,%	dicas
	Gui,	info:Add,	Text,%		"xm							y390	w" A_ScreenWidth-20  "	h60		Right"			,	`nDieisson S. Santos`ndsantos@cotrijal.com.br`n( 54 ) 3332 2524`t( 549 ) 9202 8091
	Gui,	info:Add,	Edit,%		"x10						y70		w" A_ScreenWidth-20  "	h170	ReadOnly"		,%	c[2,2]
	Gui,	info:Add,	Button,%	"x"	A_ScreenWidth-230	"	y10		w220					h50	ginfoGuiClose vfoco",	Fechar
	Gui,	info:Show,				x0							y0														,	Informações
	GuiControl, info:Focus, foco
return

infoGuiClose:
	Gui,	Info:Destroy
	WinShow,	Relatório Individual
Return

GuiContextMenu()	{
	Gui, Submit, NoHide
	if (	A_GuiControl	= "@lv"
		&&	A_EventInfo		> 0 )	{
		in_edit		=	0
		edit_row	:=	A_EventInfo
		LV_GetText( data_relatorio, A_EventInfo , 1 )
		LV_GetText( relatorio_anterior, A_EventInfo , 2 )
		LV_GetText( pkid, A_EventInfo , 4 )
		LV_GetText( edicoes, A_EventInfo , 6 )
		if ( debug = 1 )
			OutputDebug % "edicoes: " edicoes
		GuiControl, , @e_relatorios ,% relatorio_anterior
		data_relatorio :=	SubStr( A_Now, 1, 8 )
						-	(SubStr( data_relatorio, 7, 4 ) SubStr( data_relatorio, 4, 2 ) SubStr( data_relatorio, 1, 2 ))
						>	3
							?	"Você só pode editar relatórios de no máximo 2 dias atrás."
							:	edicoes	>=	1
										?	"Não é possível editar novamente este relatório."
										:	(SubStr( data_relatorio, 7, 4 ) SubStr( data_relatorio, 4, 2 ) SubStr( data_relatorio, 1, 2 ) )
		If data_relatorio is not digit
			{
			If ( edicoes > 1 )	{
				WinHide,	Relatório Individual
				MsgBox, 48, Quantidade de Edições Excedida, % data_relatorio
				}
				Else	{
				WinHide,	Relatório Individual
				MsgBox, 48, Período de Edição Excedido, % data_relatorio
				}
			WinShow,	Relatório Individual
			Return
			}
		Menu,	editar_relatorio, Add, Editar Relatório, _e_relatorio
		Menu,	editar_relatorio, Color, 9BACC0
		Menu,	editar_relatorio, Show, %A_GuiX%, %A_GuiY%
		}
}

_e_relatorio:
	in_edit := 1
	Gui, Submit, NoHide
	; Guicontrol,	-ReadOnly +cBlack,	@e_relatorios
		gui.Cores( "editado", "9BACC0", "374658" )
	WinHide,	Relatório Individual
	Gui,	editado:-Caption -Border +AlwaysOnTop +OwnDialogs
		gui.Font( "editado:", "cWhite", "Bold" )
	Gui,	editado:Add,	Text,%		"xm				w" A_ScreenWidth-20 "	h30							0x1200	+Center	Section	",	RELATÓRIO EDITADO
		gui.Font( "editado:" )
	Gui,	editado:Add,	Button,%	"				w220					h50							geditar			 		",	Salvar Alterações`n(Só pode ser editado UMA vez)
	Gui,	editado:Add,	Button,%	"				w220					h50							geditadoGuiClose 		",	Cancelar Alterações
		gui.Font( "editado:", "cBlack", "S10" )
	Gui,	editado:Add,	Edit,%		"xm+230	ym+35	w" A_ScreenWidth-250 "	h340	vrelatorio_editado							",% relatorio_anterior
		gui.Font( "editado:", "cWhite", "Bold" )
	Gui,	editado:Add,	Edit,%		"				w" A_ScreenWidth-250 "	h340								ReadOnly		",%	"Relatório Anterior:`n`tEditado em:`n`t" datetime()  "`n`n" relatorio_anterior
	Gui,	editado:Show,%				"x0				y0																			",	Relatório Editado
	GuiControl, editado:Focus, foco
Return

editar:
	Gui,	editado:Submit, NoHide
	Gui,	editado:Destroy
	r_editado	:=	"__________________________`n" safe_data.encrypt( "Editado em:`n`t" datetime() "`n__________________________`n" relatorio_editado, @usuario )
	r_anterior	:=	safe_data.encrypt( relatorio_anterior, @usuario )
	edicoes++
	if ( debug = 1 )
		OutputDebug % "edicoes = " edicoes
	u	=
		(
		UPDATE
			[ASM].[dbo].[_relatorios_individuais]
		SET
			[usuario]				= NULL,
			[visualizado]			= NULL,
			[relatorio]				= '%r_editado%',
			[relatorio_pre_edit]	= '%r_anterior%',
			[edicoes]				= '%edicoes%'
		WHERE
			[pkid]					= '%pkid%'
		)
	sql( u, 3 )
	WinShow,	Relatório Individual
	goto Carrega_Relatorios
Return

editadoGuiClose:
	WinShow,	Relatório Individual
	Guicontrol,	+ReadOnly +cWhite,	@e_relatorios
	if ( editado = 1 )
		editado = 0
	Gui,	editado:Destroy
Return

up:
	Return