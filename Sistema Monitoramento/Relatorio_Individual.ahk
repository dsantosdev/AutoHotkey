;@Ahk2Exe-SetMainIcon \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\ico\rel.ico

is_test =

#IfWinActive, Login Cotrijal
#SingleInstance Force
#Persistent
#Include sql.ahk
#Include windows.ahk
#Include array.ahk

#Include classes.ahk

Global	Coded
	,	Base_Key
	,	Alfabeto:="abcdefghijklmnopqrstuvwxyz"

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
	version = 1.0.0.5
	changelog = Adicionado criptografia AES nos relatórios.
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
	}
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
if ( A_IsCompiled && c[2,1] < version )	{
	FileMove, % A_ScriptFullPath, % A_ScriptDir "\" 4delete, 1
	FileCopy, \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\relatorio_individual.exe,% A_ScriptDir "\relatorio_individual.exe", 1
	}
if ( is_test = 1 )	{
	@usuario = julitak
	Goto interface
	}
	Else
		Goto, Login
;	Return

Interface:
	; OutputDebug % "Interface pré " logou
	Gui, Login:Destroy
	nm_usuario_ad := Windows.Users( @usuario )
	GuiConfig.Cores( "", "9BACC0", "374658" )
	Gui, Add, MonthCal,	x20		y20			w230	h300	v@Date					g_Executa_Busca_data
		Gui,	Font,	S12 Bold cWhite
	Gui, Add, Text,		x255	y20			w150	h30		+Center	0x1000									, Buscar
		Gui,	Font
	Gui, Add, ListView,	x255	y60			w430	h260	v@LV AltSubmit	Grid	g_Seleciona_Relatorio	, Data|Relatório|Nome|id|pre|edicoes|ip
	;	Edit's
			Gui,	Font,	S10 Bold
		Gui, Add, Edit,		x405	y20		w280	h30		v@Busca_em_Relatorios	g_Executa_Busca
			Gui,	Font
			Gui,	Font,	S10
		Gui, Add, Edit,		x690	y60		w560	h260	v@Exibicao_de_Relatorio	g_Editar_Relatorio
		Gui, Add, Edit,		x20		y350	w1230	h260	v@Novo_Relatorio		+WantTab
			; Gui,	Font
	;	Button's
		Gui, Add, Button,	x1050	y625	w200	h40								g_Inserir_Novo_Relatorio, INSERIR
	;	GroupBox'es
		Gui, Add, GroupBox,	x10		y0		w1250	h620	vbox_geral
		Gui, Add, GroupBox,	x10		y330	w1250	h290	vbox_inserir
		Gui, Add, GroupBox,	x1040	y612	w220	h60		vbox_botoes
	;	Infos
		Gui, Add, Button,	x1150	y20												g_informacoes			, Informações
			Gosub, Carrega_Relatorios
	Gui, Show,				x0		y0		w1276	h675													, Relatório Individual
return

Carrega_Relatorios:
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
			if(is_test =1)
			Clipboard:=select
		relatorios_existentes := sql( select, 3 )
		OutputDebug % relatorios_existentes.Count()-1
		Loop, %	relatorios_existentes.Count()-1	{
			if ( StrLen( relatorios_existentes[A_Index+1,8] ) > 0 )	{	;	temporario
				GuiControl, , @Novo_Relatorio,%	relatorios_existentes[A_Index+1,8]
				continue
				}
			relat_ := Safe_Data.Decrypt( relatorios_existentes[A_Index+1,2], relatorios_existentes[A_Index+1,9] )
			OutputDebug % relat
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
			Loop,	8
				LV_ModifyCol(A_index+2,0)
			LV_ModifyCol( 1, 120 )
			LV_ModifyCol( 2, 300 )
		; OutputDebug % "relatorios: " relatorios.count()
Return

_Executa_Busca_data:
	GuiControl, , @Busca_em_Relatorios
_Executa_Busca:
	Gui,	Submit,	NoHide
	; OutputDebug % A_GuiEvent
	LV_Delete()
	if ( @Date != SubStr(A_Now,1,8) and StrLen(@busca_em_relatorios) = 0 )			{
		; OutputDebug % "Filtrou data diferente e sem filtro"
		data:=SubStr(@date,7,2) "/" SubStr(@date,5,2) "/" SubStr(@date,1,4)
		existentes:=array.indict(relatorios,data,"data",1,1)
		}
	else if ( @Date = SubStr(A_Now,1,8) and StrLen(@busca_em_relatorios) = 0 )		{
		; OutputDebug % "Filtrou data igual e sem filtro"
		existentes:=array.indict(relatorios,@busca_em_relatorios,"relatorio",1,1)
		}
	else if ( @Date != SubStr(A_Now,1,8) and StrLen(@busca_em_relatorios) != 0 )	{
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
		existentes:=array.indict(subfilter,@busca_em_relatorios,"Relatorio",1,1)
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
		existentes:=array.indict(relatorios,@busca_em_relatorios,"Relatorio",1,1)
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
	; OutputDebug Executou Busca de: %@busca_em_relatorios%
Return

_Seleciona_Relatorio:
	Gui,	Submit,	NoHide
	if ( A_GuiEvent != "Normal" )
		Return
	if ( A_EventInfo = 0 )
		lv_GetText(@relatorio,A_EventInfo+1,2)
		Else
			lv_GetText(@relatorio,A_EventInfo,2)
	GuiControl, , @Exibicao_de_Relatorio ,% @Relatorio
	; OutputDebug %  @relatorio "`t" A_EventInfo "`t" A_GuiEvent
	; OutputDebug Exibe Relatório: %@Relatorio%
Return

_Inserir_Novo_Relatorio:
	Gui,	Submit,	NoHide
	Gui, -AlwaysOnTop
	if ( strlen(@Novo_Relatorio) < 9 ) {
		MsgBox,,Texto insuficiente, Seu relatório necessita ter pelo menos 10 caractéres para poder ser salvo.
		Return
		}
	@Novo_Relatorio_ := Safe_Data.Encrypt( @Novo_Relatorio, @usuario)
	; OutputDebug % "Insere Novo Relatório:`n`t" user_ad "`n_____"
	insert=
		(
		IF NOT EXISTS (SELECT [relatorio_temporario] FROM [ASM].[dbo].[_relatorios_individuais] WHERE [user_ad] = '%@Usuario%' and [relatorio_temporario] is not NULL)
			INSERT INTO
				[ASM].[dbo].[_relatorios_individuais]
					([nome],[data],[relatorio],[edicoes],[ip],[user_ad])
				VALUES
					('%nm_usuario_ad%',GETDATE(),'%@Novo_Relatorio_%','0','%A_IpAddress1%','%@Usuario%')
		ELSE
			UPDATE
				[ASM].[dbo].[_relatorios_individuais]
			SET
				[relatorio] = '%@Novo_Relatorio_%',
				[relatorio_temporario] = NULL,
				[Data] = GETDATE()
			WHERE
				[user_ad] = '%@Usuario%' AND
				[relatorio_temporario] is not NULL
		)
		insert := sql( insert, 3 )
		index := relatorios.Count()+1
		relatorios.push({	data		:	A_DD "/" A_MM "/" A_yyyy " " A_Hour ":" A_Min ":" A_Sec
						,	relatorio	:	@Novo_Relatorio
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
		GuiControl,	,@Novo_Relatorio
	GuiControl, , @Exibicao_de_Relatorio ,% @Novo_Relatorio
Return

Login:
	GuiConfig.Cores("login","9BACC0","374658")
		Gui, login:Font,	Bold	S10 cWhite
	Gui, login:Add, Text,	x10	y10		w80		h20									, Usuário
	Gui, login:Add, Text,	x10	y30		w80		h20									, Senha
		Gui, login:Font
		Gui, login:Font, Bold S10
	Gui, login:Add, Edit,	x90	y10		w140	h20		v@usuario
	Gui, login:Add, Edit,	x90	y30		w140	h20		v@senha		Password
	Gui, login:Add, Button,	x10	y55		w221	h25		vAutentica	g_Autenticar	, Ok
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
		if	( logou = "interface" )
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

;return

~Enter::
	~NumpadEnter::
	Goto _Autenticar
Return

GuiClose:
	loginGuiCLose:
	if ( StrLen(@usuario) != 0 and StrLen(@senha) != 0 or is_login = 0 )	{
		OutputDebug % "Login Gui Close"
		login_in := Login(@usuario,@senha) = 0 ? 0 : 1
		if ( login_in = 0 )	{
			Gui,	Login:Destroy
			MsgBox,,Falha de Login, Usuário ou Senha inválido!
			}
		}
		OnExit, Relatorio_Temporario
;return

Relatorio_Temporario:
	Gui,	Submit, NoHide
	OutputDebug % StrLen(@Novo_Relatorio)
	if ( StrLen(@Novo_Relatorio) > 0 ) {
		; OutputDebug % "Temp Save: " @Novo_Relatorio "`n`t" user_ad "`n_____"
		insert=
			(
			IF NOT EXISTS (SELECT [relatorio_temporario] FROM [ASM].[dbo].[_relatorios_individuais] WHERE [user_ad] = '%@Usuario%' and [relatorio_temporario] is not NULL)
				INSERT INTO
					[ASM].[dbo].[_relatorios_individuais]
						([nome],[data],[relatorio_temporario],[edicoes],[ip],[user_ad])
					VALUES
						('%nm_usuario_ad%',GETDATE(),'%@Novo_Relatorio%','0','%A_IpAddress1%','%@Usuario%')
			ELSE
				UPDATE
					[ASM].[dbo].[_relatorios_individuais]
				SET
					[relatorio_temporario]='%@Novo_Relatorio%'
				WHERE
					[user_ad] = '%@Usuario%' AND
					[relatorio_temporario] is not NULL
			)
		Clipboard:=insert
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
			OutputDebug % "sai normal COM login"
			}
			OutputDebug % "sai normal SEM login"
		}
ExitApp

_informacoes:
	infos := !infos
	if ( infos = 0 )	{
		Goto infoGuiClose
		Return
		}
	dicas=
		(
		> Utilize o filtro de CALENDÁRIO para buscar um dia específico
		> Busque relatórios com palavras específicas pelo campo BUSCAR
		> O relatório necessita ter pelo menos 10 caracteres para poder ser inserido.
		> Lembre-se de FECHAR o programa de Relatórios Individuais após inserir ou visualizar a informação que necessita.
		)
	dicas := StrReplace(dicas, "`t")
	GuiConfig.Cores("info","9BACC0","374658")
	Gui,	+AlwaysOnTop
	Gui,	info:-Caption -Border +AlwaysOnTop +OwnDialogs
	Gui,	info:Font,	cWhite Bold
	Gui,	info:Add,	Text,	x10		y10		w420	h20		0x1000,	Versão:	%version%
	Gui,	info:Add,	Text,	x10		y40		w420	h20		0x1000,%	"Atualizado em " c[2,3]
	Gui,	info:Add,	Text,	x10		y250	w650	h130	0x1000,	%	dicas
	Gui,	info:Add,	Text,	xm		y390	w650	h60		Right,`nDieisson S. Santos`ndsantos@cotrijal.com.br`n(54) 3332 2524`t(549) 9202 8091
	Gui,	info:Add,	Edit,	x10		y70		w650	h170	ReadOnly,%	c[2,2]
	Gui,	info:Add,	Button,	x440	y10		w220	h50	ginfoGuiClose vfoco,	Fechar
	Gui,	info:Show,x0 y0,	Informações
	GuiControl, info:Focus, foco
return

infoGuiClose:
	Gui, -AlwaysOnTop
	if(infos=1)
		infos=0
	Gui,	Info:Destroy
Return

GuiContextMenu()	{
	Gui, Submit, NoHide
	OutputDebug, % A_GuiControl
	if ( A_GuiControl = "@LV" )	{
		LV_GetText(@relatorio_anterior, A_EventInfo , 2)
		LV_GetText(@data_relatorio, A_EventInfo , 1)
		LV_GetText(@edicoes, A_EventInfo , 6)
		@data_relatorio :=	SubStr( A_Now, 1, 8 )
						-	(SubStr( @data_relatorio, 7, 4 ) SubStr( @data_relatorio, 4, 2 ) SubStr( @data_relatorio, 1, 2 ))
						>	3
							?	"Você só pode editar relatórios de no máximo 3 dias atrás"
							:	@edicoes > 1
							?	"Excedido o número possível de edições para esse relatório"
							:	(SubStr( @data_relatorio, 7, 4 ) SubStr( @data_relatorio, 4, 2 ) SubStr( @data_relatorio, 1, 2 ))
		OutputDebug % @data_relatorio "`n" @relatorio_anterior
		Menu,	editar_relatorio, Add, Salvar Relatório, _Editar_Relatorio
		Menu,	editar_relatorio, Show, %A_GuiX%, %A_GuiY%
		}
	
}

_Editar_Relatorio:
	Gui, Submit, NoHide
	OutputDebug % A_GuiCOntrol "`n" A_EventInfo "`n" A_GuiCOntrolEvent
Return

up:
	Return