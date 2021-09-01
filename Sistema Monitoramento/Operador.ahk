﻿;@Ahk2Exe-SetMainIcon \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\ico\rel.ico

global	debug				;	Core = 1, funções 2, core e funções = 3, classes = 4, core e classes = 5, funções e classes = 6, tudo = 7
	,	edit_row			;	guicontext
	,	in_edit				;	guicontext
	,	relatorio_anterior	;	guicontext
	,	pkid				;	guicontext
	,	edicoes				;	guicontext

;local Vars
	is_test =1
	debug = 
	WinGetPos,,,,taskbar, ahk_class Shell_TrayWnd

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
	version = 2.0.0.1
	changelog = Reestruturado a Interface principal e melhorado a lógica de busca.
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
;

if (A_IpAddress1 = "192.9.100.184"
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
	if (A_IsCompiled
	&&	c[2,1] < version )	{
		FileDelete, % A_ScriptFullPath
		FileCopy, \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\Operador.exe,% A_ScriptDir "\Operador.exe", 1
	}
	if ( is_test = 1 )	{
		@usuario = dsantos
		Goto interface
	}
	Else
		Goto, Login
;	Return

Interface:
	nm_usuario_ad := Windows.Users( @usuario )
		Gui, Login:Destroy
		gui.Cores( "individual", "9BACC0", "374658" )
		gui.Font( "individual:", "S11", "Bold", "cWhite" )
	Gui, individual:-Caption -Border
	Gui, individual:Add,	Button,%	"x" A_ScreenWidth-100 "	y1										h25													g_informacoes"								,	Informações
	Gui, individual:Add,	Tab3,%		"x5						y5		w" A_ScreenWidth-5 	"											v@tab				g_tab"										,	Relatório Individual|Registros|Fechar
	Gui, individual:Add,	MonthCal,%	"								w230							h465							v@data				g_busca_data					Section"
	Gui, individual:Add,	Text,%		"						ys		w" A_ScreenWidth-275 "			h25																			+Center	0x1000"		,	Buscar
		gui.Font( "individual:" )
	Gui, individual:Add,	Edit,%		"								w" A_ScreenWidth-275 "			h25								v@busca				g_busca"
	Gui, individual:Add,	ListView,%	"								w" (A_ScreenWidth-275)/2-5 "	R22								v@list_view 		g_select_lv	Grid	AltSubmit	Section"	,	Data|Relatório|Nome|id|pre|edicoes|ip
		gui.Font( "individual:", "S11", "Bold", "cWhite" )
	Gui, individual:Add,	Edit,%		"						ys		w" (A_ScreenWidth-275)/2-7 "	h403							v@exibe_relatorio	g_exibe_relatorio	+ReadOnly	+WantTab"
		gui.Font( "individual:" )
		gui.Font( "individual:", "S12", "Bold" )
	Gui, individual:Add,	Edit,%		"xs-240							w" A_ScreenWidth-35 "			h" A_ScreenHeight-taskbar-570 "	v@novo_relatorio									+WantTab"
	Gui, individual:Add,	Button,%	"xs-240							w200							h30													g_insere_novo_relatorio"					,	Inserir Novo Relatório
		Gosub, Carrega_Relatorios
	Gui, individual:Show,%				"x-2					y0		w" A_ScreenWidth+2	"			h"	A_ScreenHeight-taskbar																		,	Relatório Individual
return

;	Relatório Individual
	_tab:
		Gui, individual:Submit, NoHide
		if ( @tab = "Fechar" )
			Goto, individualGuiClose
	Return

	Carrega_Relatorios:
		Gui,	individual:Default
		Gui,	individual:ListView, @list_view
		relatorios	:=	{}
		select =
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
				GuiControl, , @novo_relatorio,%	relatorios_existentes[A_Index+1,8]
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
		LV_GetText( _insere_relatorio, 1, 2 )
		GuiControl, , @exibe_relatorio ,% _insere_relatorio
	Return

	_busca_data:
		GuiControl, , @busca
	;

	_busca:
		Gui,	individual:Submit,	NoHide
		search_delay()
		Gui,	individual:Submit,	NoHide
		LV_Delete()
		if ( @data != SubStr( A_Now, 1, 8 )
		&&	StrLen( @busca ) = 0 )			{
			data := SubStr( @data, 7 , 2 ) "/" SubStr( @data, 5 , 2 ) "/" SubStr( @data, 1, 4 )
			existentes:=array.indict( relatorios, data, "data", 1 ,1 )
		}
		else if ( @data = SubStr( A_Now, 1, 8 ) 
		&&	StrLen( @busca ) = 0 )
			existentes:=array.indict( relatorios, @busca, "relatorio", 1, 1 )
		else if ( @data != SubStr( A_Now, 1, 8 )
		&&	StrLen( @busca ) != 0 )	{
			subfilter := {}
			data:=SubStr( @data, 7, 2 ) "/" SubStr( @data, 5, 2 ) "/" SubStr( @data, 1, 4 )
			existentes:=array.indict( relatorios, data, "data", 1, 1 )
			Loop,	%	existentes.Count()	{
				subfilter.Push({	data		:	relatorios[existentes[A_index]].data
								,	relatorio	:	relatorios[existentes[A_index]].relatorio
								,	nome		:	relatorios[existentes[A_index]].nome
								,	id			:	relatorios[existentes[A_index]].id
								,	anteriores	:	relatorios[existentes[A_index]].anteriores
								,	edicoes		:	relatorios[existentes[A_index]].edicoes
								,	ip			:	relatorios[existentes[A_index]].ip			})
			}
			existentes := array.indict( subfilter, @busca, "Relatorio", 1, 1 )
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
		Else
			existentes:=array.indict( relatorios, @busca, "Relatorio", 1, 1 )
		Loop,	%	existentes.Count()
				LV_Add(
					,	relatorios[existentes[A_Index]].data
					,	relatorios[existentes[A_Index]].relatorio
					,	relatorios[existentes[A_Index]].nome
					,	relatorios[existentes[A_Index]].id
					,	relatorios[existentes[A_Index]].anteriores
					,	relatorios[existentes[A_Index]].edicoes
					,	relatorios[existentes[A_Index]].ip	)
	Return

	_select_lv:
		relatorio_editado := @exibe_relatorio
		Gui,	individual:Submit,	NoHide
		if (A_GuiEvent	=	"ColClick"
		&&	A_EventInfo	=	"1"	)	{
			sort := !sort
			order := sort	=	1
							?	""
							:	"Desc"
			if ( debug = 1 )
				OutputDebug % "Sort = " sort "`n`tOrder: "	 order
			LV_ModifyCol( 4 , "Sort" order )
		}
		if (A_GuiEvent	=	"Normal"
		||	A_GuiEvent	=	"K" )	{
			if ( A_EventInfo = 0 )
				lv_GetText( @relatorio, s_row := A_EventInfo+1, 2 )
			Else
				lv_GetText( @relatorio, s_row := A_EventInfo, 2 )
			if (A_GuiEvent	=	"K"
			&&	(	A_EventInfo = 40	;	trata select com as arrow keys
				||	A_EventInfo = 38 ) )
				lv_GetText( @relatorio, s_row := LV_GetNext(), 2 )
			GuiControl, , @exibe_relatorio ,% @Relatorio
		}
		if ( A_GuiEvent	=	"RightClick" )
			Goto, _editar_relatorio
	Return

	_insere_novo_relatorio:
		Gui, individual:Submit,	NoHide
		Gui, individual:-AlwaysOnTop
		if ( strlen(@novo_relatorio) < 9 ) {
			MsgBox,,Texto insuficiente, Seu relatório necessita ter pelo menos 10 caractéres para poder ser salvo.
			Return
			}
		@novo_relatorio_ := Safe_Data.Encrypt( @novo_relatorio, @usuario)
		; OutputDebug % "Insere Novo Relatório:`n`t" user_ad "`n_____"
		insert=
			(
			IF NOT EXISTS (SELECT [relatorio_temporario] FROM [ASM].[dbo].[_relatorios_individuais] WHERE [user_ad] = '%@Usuario%' and [relatorio_temporario] is not NULL)
				INSERT INTO
					[ASM].[dbo].[_relatorios_individuais]
						([nome],[data],[relatorio],[edicoes],[ip],[user_ad])
					VALUES
						('%nm_usuario_ad%',GETDATE(),'%@novo_relatorio_%','0','%A_IpAddress1%','%@Usuario%')
			ELSE
				UPDATE
					[ASM].[dbo].[_relatorios_individuais]
				SET
					[relatorio] = '%@novo_relatorio_%',
					[relatorio_temporario] = NULL,
					[Data] = GETDATE()
				WHERE
					[user_ad] = '%@Usuario%' AND
					[relatorio_temporario] is not NULL
			)
			insert := sql( insert, 3 )
			index := relatorios.Count()+1
			relatorios.push({	data		:	A_DD "/" A_MM "/" A_yyyy " " A_Hour ":" A_Min ":" A_Sec
							,	relatorio	:	@novo_relatorio
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
			GuiControl,	,@novo_relatorio
		GuiControl, , @exibe_relatorio ,% @novo_relatorio
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
												?	"individualGuiClose"
												:	"Interface"
		Return

		~Enter::
			~NumpadEnter::
			Goto _Autenticar
	Return

	individualGuiClose:
		loginGuiCLose:
		if (StrLen( @usuario ) != 0
		&&	StrLen( @senha ) != 0
		||	is_login = 0 )	{
			if ( debug = 1 )
				OutputDebug % "Login Gui Close"
			login_in := Login( @usuario, @senha ) = 0 ? 0 : 1
			if ( login_in = 0 )	{
				Gui,	Login:Destroy
				MsgBox,,Falha de Login, Usuário ou Senha inválido!
				}
			}
			OnExit, Relatorio_Temporario
	; return

	Relatorio_Temporario:
		Gui,	individual:Submit, NoHide
		if ( debug = 1 )
			OutputDebug % StrLen(@novo_relatorio)
		if ( StrLen( @novo_relatorio ) > 0 ) {
			; OutputDebug % "Temp Save: " @novo_relatorio "`n`t" user_ad "`n_____"
			insert=
				(
				IF NOT EXISTS (SELECT [relatorio_temporario] FROM [ASM].[dbo].[_relatorios_individuais] WHERE [user_ad] = '%@Usuario%' and [relatorio_temporario] is not NULL)
					INSERT INTO
						[ASM].[dbo].[_relatorios_individuais]
							([nome],[data],[relatorio_temporario],[edicoes],[ip],[user_ad])
						VALUES
							('%nm_usuario_ad%',GETDATE(),'%@novo_relatorio%','0','%A_IpAddress1%','%@Usuario%')
				ELSE
					UPDATE
						[ASM].[dbo].[_relatorios_individuais]
					SET
						[relatorio_temporario]='%@novo_relatorio%'
					WHERE
						[user_ad] = '%@Usuario%' AND
						[relatorio_temporario] is not NULL
				)
			; Clipboard:=insert
			sql( insert, 3 )
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

	;	Informações
		_informacoes:
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
			WinHide,	Relatório Individual
			GuiControl, info:Focus, foco
		return

		infoGuiClose:
			WinShow,	Relatório Individual
			Gui,		Info:Destroy
		Return
	;

	_editar_relatorio:
		Gui, individual:Submit, NoHide
		if (A_GuiControl	= "@list_view"
		&&	A_EventInfo		> 0 )	{
			in_edit		=	0
			edit_row	:=	A_EventInfo
			LV_GetText( data_relatorio, A_EventInfo, 1 )
			LV_GetText( relatorio_anterior,A_EventInfo, 2 )
			LV_GetText( pkid, A_EventInfo, 4 )
			LV_GetText( edicoes, A_EventInfo, 6 )
			if ( debug = 1 )
				OutputDebug % "edicoes: " edicoes
			GuiControl, , @exibe_relatorio,% relatorio_anterior
			data_relatorio :=	SubStr( A_Now, 1, 8 )
							-	( SubStr( data_relatorio, 7, 4 ) SubStr( data_relatorio, 4, 2 ) SubStr( data_relatorio, 1, 2 ) )
							>	3
								?	"Você só pode editar relatórios de no máximo 2 dias atrás."
								:	edicoes	>=	1
											?	"Não é possível editar novamente este relatório."
											:	( SubStr( data_relatorio, 7, 4 ) SubStr( data_relatorio, 4, 2 ) SubStr( data_relatorio, 1, 2 ) )
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
			Menu,	editar_relatorio, Add, Editar Relatório, _exibe_relatorio
			Menu,	editar_relatorio, Color, 9BACC0
			MouseGetPos, x, y
			Menu,	editar_relatorio, Show, %X%, %Y%
		}
	Return

	_exibe_relatorio:
		in_edit := 1
		Gui, individual:Submit, NoHide
		; Guicontrol,	-ReadOnly +cBlack,	@exibe_relatorio
			gui.Cores( "editado", "9BACC0", "374658" )
		WinHide,	Relatório Individual
		Gui,	editado:-Caption -Border +AlwaysOnTop +OwnDialogs
			gui.Font( "editado:", "cWhite", "Bold" )
		Gui,	editado:Add,	Text,%		"xm				w" A_ScreenWidth-20 "	h30																0x1200	+Center	Section",	RELATÓRIO EDITADO
			gui.Font( "editado:" )
		Gui,	editado:Add,	Button,%	"				w220					h50													geditar"							,	Salvar Alterações`n(Só pode ser editado UMA vez)
		Gui,	editado:Add,	Button,%	"				w220					h50													geditadoGuiClose"					,	Cancelar Alterações
			gui.Font( "editado:", "cBlack", "S10" )
		Gui,	editado:Add,	Edit,%		"xm+230	ym+35	w" A_ScreenWidth-250 "	h" (A_ScreenHeight-taskbar)/2-30 "	vrelatorio_editado"									,% relatorio_anterior
			gui.Font( "editado:", "cWhite", "Bold" )
		Gui,	editado:Add,	Edit,%		"				w" A_ScreenWidth-250 "	h" (A_ScreenHeight-taskbar)/2-30 "		ReadOnly"										,%	"Relatório Anterior:`n`tEditado em:`n`t" datetime()  "`n`n" relatorio_anterior
		Gui,	editado:Show,%				"x0				y0						h" A_ScreenHeight-taskbar																,	Relatório Editado
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
		Guicontrol,	+ReadOnly +cWhite,	@exibe_relatorio
		if ( editado = 1 )
			editado = 0
		Gui,	editado:Destroy
	Return
;

;	Registros

;