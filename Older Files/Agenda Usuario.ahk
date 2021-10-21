/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\users\dsantos\desktop\executáveis\Agenda Usuario.exe
Created_Date=1
Run_After=""C:\Users\dsantos\Desktop\Executáveis\AHK2BD.exe" "agenda_user" "0.0.0.1" """
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Version=0.0.0.2
Inc_File_Version=1
Product_Name=agenda_user
Product_Version=1.1.33.2
Set_AHK_Version=1

* * * Compile_AHK SETTINGS END * * *
*/

;@Ahk2Exe-SetMainIcon C:\Dih\zIco\2Agenda.ico

; #Include ..\class\classes.ahk
#Include ..\class\sql.ahk
#Include ..\class\array.ahk
#Include ..\class\safedata.ahk
#Include ..\class\gui.ahk
#Include ..\class\windows.ahk
#Include ..\class\string.ahk
#Include ..\class\functions.ahk
#SingleInstance,	Force
#IfWinActive		Agenda - Avisos - Ocomon - Frota
#NoTrayIcon
Menu,	Tray,	Icon
Menu,	Tray,	Tip,	Agenda - Avisos - Ocomon - Frota

;Goto, Login
interface:
test =
debug = 0
if ( debug = 1 )
	OutputDebug % "interface"
Gui, Login:Destroy

if ( A_UserName != "dsantos" )
	Menu, Tray,  NoStandard
if ( A_UserName = "arsilva" )
	admin	=	1	
	else if (	A_UserName = "alberto"
			||	A_UserName = "llopes"
			||	A_UserName = "dsantos" )
		admin	=	2	
	else
		admin	=	0
;return

;	GUI 
	if ( debug = 1 )
		OutputDebug % "GUI " SubStr( A_Now, -1 )
	;	Configurações
		if ( admin = 1 )	;	Header
			header=Agenda|Avisos|Ocomon|Frota|Registro|Vigilantes
			else if ( admin = 2 )
			header=Agenda|Avisos|Ocomon|Frota|Registro|Vigilantes|Relatórios Monitoramento ;|Detecções de Imagem|Sinistros em Andamento
			else
				header=Agenda|Avisos|Ocomon|Frota|Registro
		Gui.Cores()
	;	Tab	1	-	Agenda
		Gui,	Font,		S11	cWhite	Bold
		Gui,	Add,		Tab3,		x5		y5		w1250			vtab		gOnTabSelect	AltSubmit						,	%	header
			Gui,	Font
		Gui,	Add,		MonthCal,	x10		y35		w230	h163	vmcall		g_date
		;	FILTROS
			Gui,	Font,	Bold	cFFFFFF
			Gui,	Add, Text,			x245	y40		w120	h20														,	ÚLTIMOS EVENTOS
			Gui,	Add, DropDownList,	x370	y35						vOperador	g_date		AltSubmit				,	Todos|Operador 1|Operador 2|Operador 3|Operador 4|Operador 5
			Gui,	Add, Checkbox,		x500	y40		w550			vPeriodo	g_date								,	Filtrado por dia
			Gui,	Add, Text,			x1055	y40		w60																,	Contendo:
			Gui,	Font
			Gui,	Add, Edit	,		x1120	y40		w100			vBusca
			Gui,	Font
		Gui,	Add,		ListView,	x245	y65		w1000			vlv			g_agenda		AltSubmit	Grid	R6			,	Data|Mensagem|Operador|Unidade|IdAviso
			Gui,	Font, S11 cWhite Bold
		Gui,	Add,		Text,		x10		y210	w1235	h20									Center		0x1000				,	Conteúdo
			Gui,	Font
		Gui,	Add,		Edit,		x10		y235	w1235	h300	veditbox
			gosub	carrega_lv 
			if ( debug = 1 )
				OutputDebug % "Agenda carregada " SubStr( A_Now, -1 )
	;	Tab	2	-	Avisos
		Gui,	Tab,			2
			Gui,	Font,		S11	cWhite	Bold
		Gui,	Add,		Text,		x10		y38																					,	Buscar contendo:
			Gui,	Font
		Gui,	Add,		Edit,		x135	y35		w250	h24		vfiltro2
		Gui,	Add,		Button,		x385	y36		w250	h22					gOnTabSelect									,	Filtrar
		Gui,	Add,		ListView,	x10		y60		w1235			vlv2		g_avisos		AltSubmit	Grid	R7	NoSort	,	Agendado para:|Mensagem
			Gui,	Font,		S11	cWhite	Bold	
		Gui,	Add,		Text,		x10		y210	w1235	h20									Center		0x1000				,	Conteúdo
			Gui,	Font
		Gui,	Add,		Edit,		xp		y235	w1235	h300	veditbox2 
			if ( debug = 1 )
				OutputDebug % "Avisos " SubStr( A_Now, -1 )
	;	Tab	3	-	Ocomon
		Gui,	Tab,		3
			Gui,	Font,		S11	cWhite	Bold
		Gui,	Add,		Text,		x10		y38																					,	Buscar contendo:
			Gui,	Font
		Gui,	Add,		Edit,		x135	y35		w250	h24		vfiltro3
		Gui,	Add,		Button,		x385	y36		w250	h22					gOnTabSelect									,	Filtrar
		Gui,	Add,		ListView,	x10		y60		w1235			vlv3		g_ocomon		AltSubmit	Grid	R7	NoSort	,	Data|Mensagem
			Gui,	Font,		S11	cWhite	Bold	
		Gui,	Add,		Text,		x10		y210	w1235	h20									Center	0x1000					,	Conteúdo
			Gui,	Font
		Gui,	Add,		Edit,		xp		y235	w1235	h300	veditbox3
			if ( debug = 1 )
				OutputDebug % "Ocomon " SubStr( A_Now, -1 )
	;	Tab 4	-	Frota
		Gui,	Tab,		4
			Gui,	Font,		S11	cWhite	Bold
		Gui,	Add,		Text,		x10		y38																					,	Buscar contendo:
			Gui,	Font
		Gui,	Add,		Edit,		x135	y35		w250	h24		vfiltro4
		Gui,	Add,		Button,		x385	y36		w250	h22					gOnTabSelect									,	Filtrar
		Gui,	Add,		ListView,	x10		y60		w1235			vlv4		g_frota			AltSubmit	Grid	R7	NoSort	,	Data|Mensagem
			Gui,	Font,		S11	cWhite	Bold	
		Gui,	Add,		Text,		x10		y210	w1235	h20									Center	0x1000					,	Conteúdo
			Gui,	Font
		Gui,	Add,		Edit,		xp		y235	w1235	h300	veditbox4
			if ( debug = 1 )
				OutputDebug % "Frota " SubStr( A_Now, -1 )
	;	Tab 5	-	Registros
		Gui,	Tab,		5
		if ( admin = 1 || admin = 2 )	{
			d	=	
			e	=	Hidden
			}
			else	{
				d	=	Hidden
				e	=	
				}
		;	Modo Admin
			Gui,	Add,	MonthCal,		x10		y35		w230	h163	vmcal	gregistros		%d%
				Gui,	Font,	S11	cWhite	Bold
			Gui,	Add,	Text,			x245	y35		w1000	h30		vt1						%d%				Center	0x1200	,	USUÁRIO
			Gui,	Add,	DropDownList,	x245	y65		w1000			vd1		gregistros		%d%
			Gui,	Add,	Text,			x245	y95		w1000	h30		vt2						%d%				Center	0x1200	,	MOTIVO
			Gui,	Add,	DropDownList,	x245	y125	w1000			vd2		gregistros		%d%								,	|Banheiro|Intervalo
				Gui,	Font
			Gui,	Add,	ListView,		x10		y210	w1235			vlv5					%d%	AltSubmit	Grid	R16		,	Operador|Saída|Retorno|Ausente|Motivo
			Gui,	Add,	Button,			x10		y515					vrel	gGeraRelatorio	%d%								,	Gerar Relatório
			Gui,	Add,	Button,			x110	y515					vmudar	gChange			%d%								,	MODO OPERADOR
			if ( admin = 1 || admin = 2 )
				gosub	registros
					if ( debug = 1 )
						OutputDebug % "Voltou registros admin " SubStr( A_Now, -1 )
		;	Modo operador
			Gui,	Font,	S10	Bold	cWhite
			Gui,	Add,	Text,		x10		%e%				y28		w1240							h30	v_user		Center	0x1200
				Gui,	Font
			Gui,	Add,	Button,%	"x10					y60		w"(1240/2)-5	"	"	e	"		v_snack		g_intervalo"		,	Registrar Saída Para Intervalo
				Gui,	Font,	S11	cWhite	Bold
			Gui,	Add,	Text,%		"x10					y85		w"(1240/2)-5	"	"	e	"	h20	v_l_sai		Right		0x1000"
			Gui,	Add,	Text,%		"x10					y108	w"(1240/2)-5	"	"	e	"	h20	v_l_volta	Right		0x1000"
				Gui,	Font
			Gui,	Add,	Button,%	"x"((1240/2)+5)*1	"	y60		w"(1240/2)+5	"	"	e	"	v_bath			g_banheiro"			,	Registrar Saída Para Banheiro
				Gui,	Font,	S11	cWhite	Bold
			Gui,	Add,	Text,%		"x"((1240/2)+5)*1	"	y85		w"(1240/2)+5	"	"	e	"	h20	v_b_sai		Right		0x1000"
			Gui,	Add,	Text,%		"x"((1240/2)+5)*1	"	y108	w"(1240/2)+5	"	"	e	"	h20	v_b_volta	Right		0x1000"
				Gui,	Font
			Gui,	Add,	Button,		x10						y130					g_relatorio_individual v_relatorio_individual %e%	,	Relatório Individual
				if ( debug = 1 )
					OutputDebug % "Fim Registro "  SubStr( A_Now, -1 )
	;	Tab 6	-	Vigilantes
		Gui,	Tab,		6
			Gui,	Font,	S11	cWhite	Bold
		Gui,	Add,	Text,			x10		y38																																	,	Buscar contendo:
			Gui,	Font
		Gui,	Add,	Edit,			x135	y35		w250	h24		vfiltro6
		Gui,	Add,	Button,			x385	y36		w250	h22					gOnTabSelect																				,	Filtrar
		Gui,	Add,	ListView,		x10		y60		w1235			vlv6		g_vigilantes	AltSubmit	Grid	R7	NoSort	,	Data|Mensagem|Vigilante
			Gui,	Font,	S11	cWhite	Bold	
		Gui,	Add,	Text,			x10		y210	w1235	h20									Center		0x1000				,	Conteúdo
			Gui,	Font
		Gui,	Add,	Edit,			xp		y235	w1235	h300	veditbox6
			if ( debug = 1 )
				OutputDebug % "Vigilantes " SubStr( A_Now, -1 )
	;	Tab 7	-	Relatórios Individuais - ADMIN MODE
		Gui,	Tab,	7
		Gui,	Add,	DateTime,		x10		y35		w150	h25		v@data_relatorio	g_busca_relatorio_individual
		Gui,	Add,	Edit,			x628	y100	w617	h25		v@busca_relatorios	
		Gui,	Add,	Button,			x935	y60		w300	h30							g_busca_relatorio_individual							,	Efetuar busca em relatórios
			Gui,	Font,	S11	cWhite	Bold
		Gui,	Add,	Checkbox,		x165	y30				h30		v@100				g_top_100						Checked					,	Buscando os 100 últimos relatórios
		Gui,	Add,	Checkbox,		x450	y30				h30		v@Vistos			g_top_100												,	Incluir relatórios já visualizados
		Gui,	Add,	Text,			x10		y60		w617	h30										Center	0x1200								,	USUÁRIO
		Gui,	Add,	Text,			x628	y60		w300	h30										Center	0x1200								,	Buscar relatórios que contenham:
		Gui,	Add,	DropDownList,	x10		y100	w617			v@usuarios_ddl		g_busca_relatorio_individual						R26
			Gui,	Font
			Gui,	Font, S10
		Gui,	Add,	ListView,		x10		y140	w400			vlv_relatorios		g_exibe_relatorio_individual	AltSubmit	Grid	R19	,	Data|Operador|Relatório|Antigos|user_ad|pkid|visto|por
			LV_ModifyCol(1,80)
			LV_ModifyCol(2,130)
			LV_ModifyCol(3,185)
			LV_ModifyCol(4,0)
			LV_ModifyCol(5,0)
			LV_ModifyCol(6,0)
			LV_ModifyCol(7,0)
			LV_ModifyCol(8,0)
		Gui,	Add,	Edit,			x410	y140	w835	h408	vedb_relatorios
			Gui,	Font
		; Gui,	Add,	Button,			x10		y515					vrel				gGeraRelatorio				,	Gerar Relatório
	;	Tab 8	-	Detecção
		Gui,	Tab,	8
			Gui,	Font,	S11	cWhite	Bold
		Gui,	Add,	Text,			x5		y35		w100	h20								Center		0x1200				,	Tipo
			Gui,	Font
		Gui,	Add,	DropDownList,	x105	y35		w300			vd4			gdeteccao									,	||Inibido|Ocorrência
		Gui,	Add,	ListView,		x10		y60		w1235			vlv8		g_detection	AltSubmit	Grid	R13	NoSort	,	Camera|Gerado|Exibido|Encerrado|Operador|Tipo de Evento|Descrição do Ocorrido
			Gui,	Font,		S11	cWhite	Bold	
		Gui,	Add,	Text,			x10		y305	w1235	h20								Center		0x1000				,	Conteúdo
			Gui,	Font
		Gui,	Add,	Edit,			xp		y325	w1235	h210	veditbox8
			if ( debug = 1 )
				OutputDebug % "Detecção " SubStr( A_Now, -1 )
	;	Tab 9	-	Sinistros
		Gui,	Tab,	9
		Gui,	Add,	ListView,	x10		y35		w1235	vlv9	AltSubmit	Grid	R28	NoSort	,	Operador|Usuário do Iris|Hora Inicial do Sinistro|Hora Final do Sinistro|Verificou Imagens|Ocorrências
			if ( debug = 1 )
				OutputDebug % "Sinistros " SubStr( A_Now, -1 )
	Gui,	Show,						x0		y0																									,	Agenda - Avisos - Ocomon - Frota
		Send,	{Down}
		if ( trocou = 1 )	{
			trocou	=
			GuiControl,	Choose,	tab,	5
			}
return

_top_100:
	Gui, Submit, NoHide
	GuiControl, , @100, % @100 = 1 ? 1 : 0
	if ( @100 = 1 )	{
		busca_usuario := @busca_relatorio := busca_data := ""
		GuiControl, , @busca_relatorios
		GuiControl, , @data_relatorio,	%	A_Now
		GuiControl,	Choose,	@usuarios_ddl,	1
		}
	Else	{
		ano := SubStr( A_Now, 1, 4 )
		mes := SubStr( A_Now, 5, 2 )
		dia := SubStr( A_Now, 7, 2 )
		busca_data := "AND DATEPART(yyyy, [data]) = '" ano "' AND DATEPART(mm, [data]) = '" mes "' AND DATEPART(dd, [data]) = '" dia "'"
		}
	@last_data := SubStr( @data_relatorio, 1, 8 )
;Return

_busca_relatorio_individual:
	Gui, Submit, NoHide
	if ( StrLen( @busca_relatorios ) > 0 )
		GuiControl, , @100, 0
	if ( @last_data != SubStr( @data_relatorio, 1, 8 ) ) {
		@100 = 0
		GuiControl, , @100, 0
		ano := SubStr( @data_relatorio, 1, 4 )
		mes := SubStr( @data_relatorio, 5, 2 )
		dia := SubStr( @data_relatorio, 7, 2 )
		busca_data := "AND DATEPART(yyyy, [data]) = '" ano "' AND DATEPART(mm, [data]) = '" mes "' AND DATEPART(dd, [data]) = '" dia "'"
		}

	if (	@usuarios_ddl != "Todos" 
		&&	@last_user != @usuarios_ddl )	{
		GuiControl, , @100, 0
		busca_usuario := "AND [nome] = '" @usuarios_ddl "'"
		@last_user := @usuarios_ddl
		}
;fim da busca

_carrega_relatorio_individual:
	Gui, Submit, NoHide
	visualizados := @vistos = 0
							? ""
							: "OR [visualizado] IS NOT NULL"
	GuiControl, , @100, % @100 = 1 ? 1 : 0
	Gui, ListView, lv_relatorios
	LV_Delete()
	top	:=	@100 = 1 ? "Top(100)" : ""
	select =
		(
		SELECT	%top%
			[data]
			,	[nome]
			,	[relatorio]
			,	[relatorio_pre_edit]
			,	[user_ad]
			,	[pkid]
			,	[visualizado]
			,	[usuario]
		FROM
			[ASM].[dbo].[_relatorios_individuais]
		WHERE
			[relatorio] like '`%`%'
			%busca_usuario%
			%busca_data%
			AND ([visualizado] IS NULL
			%visualizados%)
		ORDER BY
			1 DESC
		)
	if ( debug = 0 )
		Clipboard:=select
	relatorios := sql( select, 3 )
	if ( debug = 1 )
		OutputDebug % "Iniciou LV " SubStr( A_Now, -1 )
	Loop,	% relatorios.Count()-1	{
		if (	A_Index = 2 	
			&&	StrLen( relatorios[A_Index,7] ) > 0 )
			if ( StrLen( relatorios[A_Index,4] ) > 0 )
				GuiControl, , edb_relatorios ,% "`t`t`t" String.Name( relatorios[A_Index,2] ) "`n`n" relatorio "`n`n`n" relatorios[A_Index,8] "`nvisto em:`t" datetime( 2, relatorios[A_Index,7] ) "`n`n`n_______________________________`nRELATÓRIO ANTERIOR A EDIÇÃO`n_______________________________`n" pre
				Else
					GuiControl, , edb_relatorios ,% "`t`t`t" String.Name( relatorios[A_Index,2] ) "`n`n" relatorio "`n`n`n" relatorios[A_Index,8] "`nvisto em:`t" datetime( 2, relatorios[A_Index,7] )
			Else if ( A_Index = 2 )
				if ( StrLen( relatorios[A_Index,4] ) > 0 )
					GuiControl, , edb_relatorios ,% "`t`t`t" String.Name( relatorios[A_Index,2] ) "`n`n" relatorio "`n`n`n_______________________________`nRELATÓRIO ANTERIOR A EDIÇÃO`n_______________________________`n" pre
					Else
						GuiControl, , edb_relatorios ,% "`t`t`t" String.Name( relatorios[A_Index,2] ) "`n`n" relatorio
		
		relatorio := Safe_Data.Decrypt( relatorios[A_Index+1,3], relatorios[A_Index+1,5] )
		pre := Safe_Data.decrypt( relatorios[A_Index+1,4], relatorios[A_Index+1,5] )
		if !InStr( relatorio, @busca_relatorios )
			Continue
		LV_Add(	""
			,	SubStr( relatorios[A_Index+1,1] , 1, 10 )
			,	String.Name( relatorios[A_Index+1,2] )
			,	relatorio
			,	pre
			,	relatorios[A_Index+1,5]
			,	relatorios[A_Index+1,6]
			,	relatorios[A_Index+1,7]
			,	relatorios[A_Index+1,8]	)
		}
		if ( debug = 1 )
			OutputDebug % "Finalizou LV " SubStr( A_Now, -1 )
	if ( StrLen( usuarios_ddl ) = 0 )	{
		s=
			(
			SELECT
				DISTINCT [nome]
			FROM
				[ASM].[dbo].[_relatorios_individuais]
			ORDER BY
				1 ASC
			)
		users := sql( s, 3 )
		Loop, % users.Count()-1
			usuarios_ddl .= users[A_Index+1,1] "|"
		GuiControl, , @usuarios_ddl ,% "Todos||"	SubStr(usuarios_ddl,1,StrLen(usuarios_ddl)-1)
		}
	@last_data := SubStr( @data_relatorio, 1, 8 )
	foi_busca = 1
;fim do carregamento

_exibe_relatorio_individual:
	if ( foi_busca = 1 )
		Goto, is_k
	if ( A_GuiEvent = "K"
					&& ( A_EventInfo = "40" || A_EventInfo = "38" ) )	{
		keyboard = 1
		Goto, is_k
		}
	if ( A_GuiEvent != "Normal" )
		Return
	keyboard = 0
	is_k:
		if ( A_GuiControl = "tab" )
			Return
		foi_busca = 0
		Gui,	ListView,	lv_relatorios
		Gui,	Submit,		NoHide
		if ( keyboard = 0 )	{
			LV_GetText( pkid_lv,			A_EventInfo	=	0
														?	1
														:	A_EventInfo, 6 )
			LV_GetText( exibir_relatorio,	A_EventInfo	=	0
														?	1
														:	A_EventInfo, 3 )
			LV_GetText( nome_user,			A_EventInfo	=	0
														?	1
														:	A_EventInfo, 2 )
			LV_GetText( visto_as,			A_EventInfo	=	0
														?	1
														:	A_EventInfo, 7 )
			LV_GetText( visto_por,			A_EventInfo	=	0
														?	1
														:	A_EventInfo, 8 )
			LV_GetText( pre_edit,			A_EventInfo	=	0
														?	1
														:	A_EventInfo, 4 )
			}
			Else {
				LV_GetText( pkid_lv,			LV_GetNext()	=	0
															?	1
															:	LV_GetNext(), 6 )
				LV_GetText( exibir_relatorio,	LV_GetNext()	=	0
															?	1
															:	LV_GetNext(), 3 )
				LV_GetText( nome_user,			LV_GetNext()	=	0
															?	1
															:	LV_GetNext(), 2 )
				LV_GetText( visto_as,			LV_GetNext()	=	0
															?	1
															:	LV_GetNext(), 7 )
				LV_GetText( visto_por,			LV_GetNext()	=	0
															?	1
															:	LV_GetNext(), 8 )
				LV_GetText( pre_edit,			LV_GetNext()	=	0
															?	1
															:	LV_GetNext(), 4 )
				}
		if ( A_UserName = "Alberto" )	{
			hora := datetime( 1 )
			u =
				(
				DECLARE @check DATETIME
				SELECT
					@check = [visualizado]
				FROM
					[ASM].[dbo].[_relatorios_individuais]
				WHERE
					[pkid]	=	'%pkid_lv%'
				IF @check IS NULL OR LEN(@check) = 0
					UPDATE
						[ASM].[dbo].[_relatorios_individuais]
					SET
						[usuario]		= 'Alberto',
						[visualizado]	= '%hora%'
					WHERE
						[pkid]			= '%pkid_lv%'
				)
			sql( u, 3 )
			}
			if ( StrLen( visto_as ) > 0 )
				if ( StrLen( pre_edit ) > 0 )
					GuiControl, , edb_relatorios ,% "`t`t`t" String.Name( relatorios[A_Index,2] ) "`n`n" relatorio "`n`n`n" visto_por "`nvisto em:`t" datetime( 2, visto_as ) "`n`n`n_______________________________`nRELATÓRIO ANTERIOR A EDIÇÃO`n_______________________________`n" pre_edit
					Else
						GuiControl, , edb_relatorios ,% "`t`t`t" String.Name( relatorios[A_Index,2] ) "`n`n" relatorio "`n`n`n" visto_por "`nvisto em:`t" datetime( 2, visto_as )
				Else
					if ( StrLen( pre_edit ) > 0 )
						GuiControl, , edb_relatorios ,% "`t`t`t" nome_user "`n`n" exibir_relatorio "`n`n`n_______________________________`nRELATÓRIO ANTERIOR A EDIÇÃO`n_______________________________`n" pre_edit
						Else
							GuiControl, , edb_relatorios ,% "`t`t`t" nome_user "`n`n" exibir_relatorio
Return

_relatorio_individual:
	if !FileExist("C:\Dguard Advanced\relatorio_individual.exe")
		FileCopy, \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\relatorio_individual.exe, C:\Dguard Advanced\relatorio_individual.exe, 1
	if ( StrLen( @usuario ) = 0 )
		@usuario = liberar
	Run, C:\Dguard Advanced\relatorio_individual.exe "%@Usuario%"
Return

Change:
	change:=!change
	if ( change = 1 )	{
		GuiControl,	Hide,	mcal
		GuiControl,	Hide,	t1
		GuiControl,	Hide,	d1
		GuiControl,	Hide,	t2
		GuiControl,	Hide,	d2	
		GuiControl,	Hide,	rselect	
		GuiControl,	Hide,	lv5
		GuiControl,	Hide,	rel
		GuiControl,	Show,	_relatorio_individual
		GuiControl,	Show,	_user
		GuiControl,	Show,	_snack
		GuiControl,	Show,	_bath
		GuiControl,	Show,	_l_sai
		GuiControl,	Show,	_l_volta
		GuiControl,	Show,	_l_bath
		GuiControl,	Show,	_b_sai
		GuiControl,	Show,	_b_volta
		GuiControl,	,	_user,	Usuário logado na estação:	%usuarioatual%
		GuiControl,	,	mudar,	MODO ADMIN
		}
	Else	{
		GuiControl,	Show,	mcal
		GuiControl,	Show,	t1
		GuiControl,	Show,	d1
		GuiControl,	Show,	t2
		GuiControl,	Show,	d2	
		GuiControl,	Show,	rselect	
		GuiControl,	Show,	lv5
		GuiControl,	Show,	rel
		GuiControl,	Hide,	_relatorio_individual
		GuiControl,	Hide,	_user
		GuiControl,	Hide,	_snack
		GuiControl,	Hide,	_bath
		GuiControl,	Hide,	_l_sai
		GuiControl,	Hide,	_l_volta
		GuiControl,	Hide,	_l_bath
		GuiControl,	Hide,	_b_sai
		GuiControl,	Hide,	_b_volta
		GuiControl,	,	mudar,	MODO OPERADOR
		}
return

_date:
	Gui, Submit, NoHide
	if ( StrLen(Busca) > "0" )
		b	=	AND	p.Mensagem	LIKE	'`%%Busca%`%'
		else
		b	=
	if ( periodo = 1 )	{
		FormatTime,	diaAntes,	%mcall%,	YDay
		FormatTime,	mcall,	%mcall%,	yyyy-MM-dd
		FormatTime,	Today,	%A_Now%,	yyyy-MM-dd
		periodox	:=	A_YDay - diaAntes
		GuiControl,	+cYellow	+Redraw,	periodo
		if ( operador = 1 )
			GuiControl,	,	Periodo,	Filtrado o período de %mcall% a %Today% com TODOS os operadores
			else if ( operador = 2 )	{
				op	:=	operador -1
				GuiControl,	,	Periodo,	Filtrado o período de %mcall% a %Today% apenas eventos do OPERADOR %op%
				}
			else if ( operador = 3 )	{
				op	:=	operador -1
				GuiControl,	,	Periodo,	Filtrado o período de %mcall% a %Today% apenas eventos do OPERADOR %op%
				}
			else if ( operador = 4 )	{
				op	:=	operador -1
				GuiControl,	,	Periodo,	Filtrado o período de %mcall% a %Today% apenas eventos do OPERADOR %op%
				}
			else if ( operador = 5 )	{
				op	:=	operador -1
				GuiControl,	,	Periodo,	Filtrado o período de %mcall% a %Today% apenas eventos do OPERADOR %op%
				}
			else if ( operador = 6 )	{
				op	:=	operador -1
				GuiControl,	,	Periodo,	Filtrado o período de %mcall% a %Today% apenas eventos do OPERADOR %op%
				}
			else if ( operador = 7 )	{
				op	:=	operador -1
				GuiControl,	,	Periodo,	Filtrado o período de %mcall% a %Today% apenas eventos do Monitoramento
				}
		if ( periodox = 0 )	{
			periodo	:=	"dias_entre_datas(DAY,p.QuandoAvisar,'"	mcall	"') = "	periodox
			if ( operador = 1 )
				GuiControl,	,	Periodo,	Filtrado a data de %mcall% com TODOS os operadores
				else if ( operador = 2 )	{
					op	:=	operador -1
					GuiControl,	,	Periodo,	Filtrado a data de %mcall% apenas eventos do OPERADOR %op%
					}
				else if ( operador = 3 )	{
					op	:=	operador -1
					GuiControl,	,	Periodo,	Filtrado a data de %mcall% apenas eventos do OPERADOR %op%
					}
				else if ( operador = 4 )	{
					op	:=	operador -1
					GuiControl,	,	Periodo,	Filtrado a data de %mcall% apenas eventos do OPERADOR %op%
					}
				else if ( operador = 5 )	{
					op	:=	operador -1
					GuiControl,	,	Periodo,	Filtrado a data de %mcall% apenas eventos do OPERADOR %op%
					}
				else if ( operador = 6 )	{
					op	:=	operador -1
					GuiControl,	,	Periodo,	Filtrado a data de %mcall% apenas eventos do OPERADOR %op%
					}
			}
			else
				periodo	:=	"CAST(Quandoavisar AS DATE) >= '"	mcall	"'	and CAST(Quandoavisar AS DATE) <= '"	Today	"'"
		}
		else	{
			GuiControl,	+cWhite +Redraw, periodo
			FormatTime,	mcall,	%mcall%,	yyyy-MM-dd
			periodo = CONVERT(VARCHAR(25), Quandoavisar, 126) like '%mcall%`%'
			GuiControl,	,	Periodo,	Filtrado por dia
			}
	if ( operador = 1 )
		operador=
	if ( operador = 2 )
		operador	= AND p.Assunto='1'
	if ( operador = 3 )
		operador	= AND p.Assunto='2'
	if ( operador = 4 )
		operador	= AND p.Assunto='3'
	if ( operador = 5 )
		operador	= AND p.Assunto='4'
	if ( operador = 6 )
		operador	= AND p.Assunto='5'
	lastrow=
	FormatTime,	yday,	%mcall%,	yyyy-MM-dd
	selected=1
	LV_Delete()
carrega_lv:
	if ( StrLen(periodo) >= )
		Gui,	Submit,	NoHide
	FormatTime,	mcall,	%mcall%,	yyyy-MM-dd
	if ( periodo = 0 )
		periodo	= CONVERT(VARCHAR(25), Quandoavisar, 126) like '%mcall%`%'
	Gui, ListView, lv
	LV_Delete()
	data := SubStr(mcall,1,4)	"-"	SubStr(mcall,5,2)	"-"	SubStr(mcall,7,2)
	sqlv=
		(
			SELECT	p.IdCliente
				,	p.QuandoAvisar
				,	p.Mensagem
				,	p.Assunto
				,	c.Nome
				,	p.Idaviso
			FROM
				[IrisSQL].[dbo].[Agenda] p
			LEFT JOIN
				[IrisSQL].[dbo].[Clientes] c ON
					p.IdCliente=c.IdUnico
			WHERE
				%periodo% AND
				[Assunto] IN ('1','2','3','4','5')
				%operador%
				%b%
			ORDER BY
				6 DESC;
			DELETE FROM [IrisSQL].[dbo].[Agenda] WHERE [Assunto] LIKE '`%Informou`%';
		)
	;	bloco de selecionar multi datas	POR FAZER
		; s:="SELECT Fkidaviso FROM [IrisSQL].[dbo].[AvisoAgenda] WHERE (DATEPART(yy,Dataagendado)=" SubStr(yday,1,4) " AND DATEPART(mm,Dataagendado)=" SubStr(yday,5,2) " AND DATEPART(dd,Dataagendado)=" SubStr(yday,7,2) ") order by 1 desc"
		; s:=sql(s)
	fill := sql(sqlv)
	Loop, % fill.Count()-1	{
		hour :=	fill[A_Index+1,2]
		oper :=	fill[A_Index+1,3]
		oper :=	RegExReplace(oper,"(^|\R)\K\s+")
		subj :=	fill[A_Index+1,4]
		unit :=	fill[A_Index+1,5]
		idav :=	fill[A_Index+1,6]
		if ( A_Index = 1 )
			last_id := idav
		StringUpper, unit, unit, T
		LV_Add( "", hour, oper, subj, unit, idav )
		}
		LV_ModifyCol(1,115)
		LV_ModifyCol(1,Sort)
		LV_ModifyCol(2,600)
		LV_ModifyCol(3,60)
		LV_ModifyCol(4,200)
		LV_ModifyCol(5,0)
	if ( selected = 1 )	{
		row := LV_GetNext()
		if ( row = 0 )
			row = 1
		LV_GetText(edb,row,2)
		edb := RegExReplace(oper,"(^|\R)\K\s+")
		if ( StrLen(edb) < 6 )
			edb =
		Gui, Font, S11
		GuiControl, Font, editbox
		GuiControl, , editbox,% edb
		selected=
		}
return

registros:
	Gui, Submit,	NoHide
	Gui, ListView,	lv5
	LV_Delete()
		LV_ModifyCol(2,115)
		LV_ModifyCol(3,115)
		LV_ModifyCol(4,60)
		LV_ModifyCol(5,90)
		Loop, 5
			LV_ModifyCol(A_Index,"Center")
	if ( d1 != "" )	{	;	Contém filtro por nome
		reg	 =	SELECT [login],[login2] FROM [Sistema_Monitoramento].[dbo].[Operadores]	WHERE nome = '%d1%'
		reg	 :=	sql(reg,3)
		res1 :=	StrReplace(reg[2,1],"`r`n")
		res2 :=	StrReplace(reg[2,2],"`r`n")
		if ( StrLen(res2 ) = 0 )
			if ( StrLen(d2) > 0 )	; Filtro por nome e tipo, com apenas 1 user
				isd = WHERE	nome	=	'%res1%'	AND	motivo	=	'%d2%'	AND	motivo	!=	'TESTE'
				else
				isd = WHERE	nome	=	'%res1%'	AND	motivo	!=	'TESTE'
			else
				if ( StrLen(d2) > 0 )	; Filtro por nome e tipo, com 2 user
					isd = WHERE (nome='%res1%' OR nome='%res2%') AND motivo='%d2%' AND motivo!='TESTE'
					else
					isd = WHERE (nome='%res1%' OR nome='%res2%') AND motivo!='TESTE'
		}
		else
			if ( StrLen(d2) > 0 )	;	Filtro por tipo apenas
				isd	= WHERE motivo='%d2%' AND motivo!='TESTE'
				else
				isd	=
	mc := SubStr(mcal,1,4)	"-"	SubStr(mcal,5,2)	"-"	SubStr(mcal,7,2)
	if ( StrLen(isd) = 0 )
		isd = WHERE	CONVERT(VARCHAR(25), saida, 126) like '%mc%`%'	AND	motivo	!=	'TESTE'
		else
		isd .= " and CONVERT(VARCHAR(25), saida, 126) like '" mc "`%'	AND	motivo	!=	'TESTE'"
	r =	
		(
		SELECT	[nome]
			,	[saida]
			,	[retorno]
			,	[duracao]
			,	[motivo]
		FROM
			[ASM].[dbo].[_registro_saidas]
			%isd%
		)
	
	r :=	sql(r,3)
	Loop,	%	r.Count()-1
		LV_Add(	""
			,	r[A_Index+1,1]
			,	r[A_Index+1,2]
			,	r[A_Index+1,3]
			,	InStr(_saida:=FormatSeconds(r[A_Index+1,4]),"|")>0
					?	StrReplace(_saida,"|"," dias ")
					:	_saida
			,	r[A_Index+1,5])
		LV_ModifyCol(4,100)
		LV_ModifyCol(1,100)
return

deteccao:
	Gui, Submit,	NoHide
	Gui, ListView,	lv8
	if ( d4 != "" )	;	Contém filtro por tipo
		whered4 =	WHERE [Ocorrido] like '%d4%`%'
		else
		whered4	=
	dete=
		(
		SELECT	TOP(500) [detect_id]
			,	[Camera]
			,	[Gerado]
			,	[Exibido]
			,	[Finalizado]
			,	[Computador]
			,	[Ocorrido]
			,	[Descricao]
			,	[IP]
		FROM
			[MotionDetection].[dbo].[Encerrados]
		%whered4%
		ORDER BY
			1 DESC
		)
	dete:=sql(dete,3)
	LV_Delete()
		LV_ModifyCol(1,115)
		LV_ModifyCol(2,120)
		LV_ModifyCol(3,120)
		LV_ModifyCol(4,120)
		LV_ModifyCol(5,80)
		LV_ModifyCol(6,120)
		LV_ModifyCol(7,600)
	Loop,	%	dete.Count()-1
		LV_Add(	""
			,	dete[A_Index+1,2]
			,	dete[A_Index+1,3]
			,	dete[A_Index+1,4]
			,	dete[A_Index+1,5]
			,	dete[A_Index+1,6]
			,	dete[A_Index+1,7]
			,	dete[A_Index+1,8]	)
		LV_ModifyCol(1,Sort)
return

_agenda:
	Gui,	ListView,	lv
	row	:=	LV_GetNext()
	if ( row = 0 )
		row = 1
	if ( A_GuiEvent = Normal ) {
		LV_GetText(edb, A_EventInfo, 2)
		Loop	{
			edb := RegExReplace(edb, "\R+\R", "`r`n ")
			if ( ErrorLevel = 0)
				break
			}
		Gui, Font,	S11
		GuiControl,	Font,	editbox
		GuiControl,	, editbox,%	edb
		return
		}
	LV_GetText( edb, row, 2)
	Gui, Font,	S11
	GuiControl,	Font,	editbox
	GuiControl,	,	editbox,	%	edb
return

_avisos:
	Gui, ListView,	lv2
	row2 := LV_GetNext()
	if ( row2 = 0 )
		row2			=		1
	if ( A_GuiEvent = Normal ) {
		LV_GetText( edb, A_EventInfo, 2)
		Loop {
			edb := RegExReplace(edb, "\R+\R", "`r`n ")
			if ( ErrorLevel = 0 )
				break
			}
		Gui,	Font,	S11
		GuiControl,	Font,	editbox2
		GuiControl,	,	editbox2,	%	edb
		return
		}
	LV_GetText(edb, row2, 2)
	Gui,	Font,	S11
	GuiControl,	Font,	editbox2
	GuiControl,	,	editbox2,	%	edb
return

_ocomon:
	Gui, ListView,	lv3
	row3 :=	LV_GetNext()
	if ( row3 = 0 )
		row3 = 1
	if ( A_GuiEvent = Normal ) {
		LV_GetText(edb, A_EventInfo, 2)
		Loop {
			edb := RegExReplace(edb, "\R+\R", "`r`n ")
			if ErrorLevel = 0
				break
			}
		Gui, Font,	S11
		GuiControl,	Font,	editbox3
		GuiControl,	, editbox3,%	edb
		return
		}
	LV_GetText(edb, row3, 2)
	Gui,	Font,	S11
	GuiControl,	Font,	editbox3
	GuiControl,	,	editbox3,	%	edb
return

_frota:
	Gui, ListView,	lv4
	row4 :=	LV_GetNext()
	if ( row4 = 0 )
		row4			=		1
	if ( A_GuiEvent = Normal ) {
		LV_GetText( edb, A_EventInfo, 2)
		Loop {
			edb := RegExReplace(edb, "\R+\R", "`r`n ")
			if ErrorLevel = 0
				break
			}
		Gui,	Font,	S11
		GuiControl,	Font,	editbox4
		GuiControl,	,	editbox4,	%	edb
		return
		}
	LV_GetText( edb, row4, 2)
	Gui,	Font,	S11
	GuiControl,	Font,	editbox4
	GuiControl,	,	editbox4,	%	edb
return

_vigilantes:
	Gui, ListView,	lv6
	row6 :=	LV_GetNext()
	if ( row6 = 0 )
		row6			=		1
	if ( A_GuiEvent = Normal ) {
		LV_GetText( edb, A_EventInfo, 2 )
		LV_GetText( vigilante, A_EventInfo, 3 )
		Loop	{
			edb := RegExReplace(edb, "\R+\R", "`r`n ")
			if ( ErrorLevel = 0 )
				break
			}
		Gui,	Font,	S11
		GuiControl,	Font,	editbox6
		GuiControl,	,	editbox6,	%	"`t`t`t"	vigilante "`n`n" edb
		return
		}
	LV_GetText(edb, row6, 2)
	LV_GetText(vigilante, row6, 3)
	Gui,	Font,	S11
	GuiControl,	Font,	editbox6
	GuiControl,	,	editbox6,	%	"`t`t`t"	vigilante "`n`n" edb
return

_detection:
	Gui,	ListView,	lv8
	row8	:=	LV_GetNext()
	if ( row8 = 0 )
		row8			=		1
	if ( A_GuiEvent = Normal ) {
		LV_GetText( edb, A_EventInfo, 7)
		if ( edb = "Mensagem" )
			return
		Loop	{
			edb := RegExReplace(edb, "\R+\R", "`r`n ")
			if ( ErrorLevel = 0 )
				break
			}
		Gui, Font,	S11
		GuiControl,	Font,	editbox8
		GuiControl,	,	editbox8,	%	edb
		return
		}
	LV_GetText( edb, row8, 7)
	Gui, Font,	S11
	GuiControl,	Font,	editbox8
	GuiControl,	,	editbox8,%	edb
return

OnTabSelect:
	Gui, Submit, NoHide
	if ( tab = 1 )	{
		GuiControl,	,	filtro2
		GuiControl,	,	filtro3
		GuiControl,	,	filtro4
		GuiControl,	,	filtro6
		GuiControl,	,	filtro7
		GuiControl,	Focus,	lv
		}
	if ( tab = 2 )	{
		GuiControl,	,	filtro3
		GuiControl,	,	filtro4
		GuiControl,	,	filtro6
		GuiControl,	,	filtro7
		Gui,	ListView,	lv2
		if ( filtro2 = "" )
			filtrar =
			else
			filtrar	:=	" AND p.Mensagem like '%" filtro2 "%'"
		LV_Delete()
		sqlv =
			(
			SELECT	p.IdCliente
				,	p.QuandoAvisar
				,	p.Mensagem
				,	p.Assunto
				,	c.Nome
			FROM
				[IrisSQL].[dbo].[Agenda] p
			LEFT JOIN
				[IrisSQL].[dbo].[Clientes] c ON
					p.IdCliente = c.IdUnico
			WHERE
				c.[Nome]='Avisos Monitoramento'
				%filtrar%
			ORDER BY
				2 DESC
			)
		fill := sql( sqlv )
		LV_ModifyCol(1,115)
		LV_ModifyCol(2,1100)
		Loop, % fill.Count()-1
			LV_Add(	""
				,	fill[A_Index+1,2]
				,	fill[A_Index+1,3]	)
		LV_ModifyCol(1,Sort)
		GuiControl,	Focus,	lv2
		}
	if ( tab = 3 )	{
		Gui,	ListView,	lv3
		GuiControl,	,	filtro2
		GuiControl,	,	filtro4
		GuiControl,	,	filtro6
		GuiControl,	,	filtro7
		if ( filtro3 = "" )
			filtrar	=
			else
			filtrar := " AND p.Mensagem like '%" filtro3 "%'"
		LV_Delete()
		sqlv =
			(
			SELECT	p.IdCliente
				,	p.QuandoAvisar
				,	p.Mensagem
				,	p.Assunto
				,	c.Nome
			FROM
				[IrisSQL].[dbo].[Agenda] p
			LEFT JOIN
				[IrisSQL].[dbo].[Clientes] c ON
					p.IdCliente = c.IdUnico
			WHERE
				c.[Nome]='Ocomon'
				%filtrar%
			ORDER BY
				2 DESC
			)
		fill := sql( sqlv )
		Loop, % fill.Count()-1
			LV_Add("",	fill[A_Index+1,2],	fill[A_Index+1,3])
			LV_ModifyCol(1,Sort)
			LV_ModifyCol(1,115)
			LV_ModifyCol(2,1100)
		GuiControl	Focus,	lv3
		}
	if ( tab = 4 )	{
		Gui,	ListView,	lv4
		GuiControl,	,	filtro2
		GuiControl,	,	filtro3
		GuiControl,	,	filtro6
		GuiControl,	,	filtro7
		if ( filtro4 = "" )
			filtrar	=
			else
			filtrar	:=	" AND p.Mensagem like '%" filtro4 "%'"
		LV_Delete()
		sqlv =
			(
			SELECT	p.IdCliente
				,	p.QuandoAvisar
				,	p.Mensagem
				,	p.Assunto
				,	c.Nome
			FROM
				[IrisSQL].[dbo].[Agenda] p
			LEFT JOIN
				[IrisSQL].[dbo].[Clientes] c ON
					p.IdCliente = c.IdUnico
			WHERE
				c.[Nome]='Caminhoes'
				%filtrar%
			ORDER BY
				2 DESC
			)
		fill := sql( sqlv )
		Loop, % fill.Count()-1
			LV_Add("",	fill[A_Index+1,2],	fill[A_Index+1,3])
			LV_ModifyCol(1,Sort)
			LV_ModifyCol(1,115)
			LV_ModifyCol(2,1100)
		GuiControl	Focus,	lv4
		}
	if ( tab = 5 )	{
		u =
			(
			SELECT	TOP(1) [LOG~USUARIO]
				,	[LOG~ORDEM]
			FROM
				[BdIrisLog].[dbo].[SYS~Log]
			WHERE
				[LOG~DADOS]='Login no Painel de Monitoramento.' AND
				[LOG~ESTACAO]='%A_ComputerName%'
			ORDER BY
				2	DESC
			)
		u := sql( u )
		usuarioatual := u[2,1]
		if ( StrLen( u[2,1] ) < 3 )
			usuarioatual := A_IPAddress1
		gosub	verifica
		if ( admin = 1 || admin = 2 )
			gosub registros
		GuiControl,	, _user,	Usuário logado na estação:	%usuarioatual%
		login =
			(
			SELECT
				[nome]
			FROM
				[Sistema_Monitoramento].[dbo].[Operadores]
			ORDER BY
				1
			)
		login := sql( login, 3 )
		Loop,	%	login.Count()-1
			l1 .= "|" login[A_Index+1,1] 
		GuiControl,	,	d1,% "|" l1
		SetTimer,	Checagem,	500
		}
	if ( tab = 6 )	{
		Gui,	ListView,	lv6
		GuiControl,	,	filtro2
		GuiControl,	,	filtro3
		GuiControl,	,	filtro4
		GuiControl,	,	filtro7
		LV_Delete()
			LV_ModifyCol(1,115)
			LV_ModifyCol(2,880)
			LV_ModifyCol(3,200)
		sqlv =
			(
			SELECT
					[Data]
				,	[Relatorio]
				,	[Vigilante]
			FROM
				[Guardinhas].[dbo].[Relatorios]
			ORDER BY
				1 DESC
			)
		fill := sql( sqlv, 3 )
		Loop, % fill.Count()-1
			LV_Add(	""
				,	fill[A_Index+1,1]
				,	Safe_Data.Decrypt( fill[A_Index+1,2], "vigilante" )
				,	String.Name( fill[A_Index+1,3] )	)
			LV_ModifyCol(1,Sort)
		GuiControl	Focus,	lv6
		}
	if ( tab = 7 )	{
		vistos = 0
		Gosub, _carrega_relatorio_individual
			if ( debug = 1 )
				OutputDebug % "Carregou Relatórios Individuais "  SubStr( A_Now, -1 )
		}
	if ( tab = 8 )	{
		Gui,	ListView,	lv8
		eventos	=
			(
			SELECT	TOP(500) [detect_id]
				,	[Camera]
				,	[Gerado]
				,	[Exibido]
				,	[Finalizado]
				,	[Computador]
				,	[Ocorrido]
				,	[Descricao]
				,	[IP]
			FROM
				[MotionDetection].[dbo].[Encerrados]
			ORDER BY
				1 DESC
			)
		eventos := sql( eventos )
		LV_Delete()
		Loop,	%	eventos.Count()-1
			LV_Add(	""
				,	eventos[A_Index+1,2]
				,	eventos[A_Index+1,3]
				,	eventos[A_Index+1,4]
				,	eventos[A_Index+1,5]
				,	eventos[A_Index+1,6]
				,	eventos[A_Index+1,7]
				,	eventos[A_Index+1,8]	)
			LV_ModifyCol(1,Sort)
			LV_ModifyCol(1,115)
			LV_ModifyCol(2,120)
			LV_ModifyCol(3,120)
			LV_ModifyCol(4,120)
			LV_ModifyCol(5,80)
			LV_ModifyCol(6,120)
			LV_ModifyCol(7,600)
		GuiControl	Focus,	lv8
		}
	if ( tab = 9 )	{
		Gui,	ListView,	lv9
		eventos =
			(
			SELECT	[id]
				,	[Operador]
				,	[User_Iris]
				,	[Hora_Sinistro]
				,	[Hora_Encerrado]
				,	[Verificar]
				,	[Eventos_Não_Exibidos]
			FROM
				[MotionDetection].[dbo].[Sinistro]
			ORDER BY
				1 DESC
			)
		eventos := sql( eventos )
		LV_Delete()
		Loop, % eventos.Count()-1
			LV_Add(	""
				,	eventos[A_Index+1,2]
				,	eventos[A_Index+1,3]
				,	eventos[A_Index+1,4]
				,	eventos[A_Index+1,5]
				,	eventos[A_Index+1,6]=1
					?	"Sim"
					:	"Não"
				,	eventos[A_Index+1,7]	)
			LV_ModifyCol(1,Sort)
			LV_ModifyCol(1,85)
			LV_ModifyCol(2,100)
			LV_ModifyCol(3,120)
			LV_ModifyCol(4,120)
			LV_ModifyCol(5,100)
			LV_ModifyCol(6,120)
		GuiControl	Focus,	lv9
		}
return

~Enter::
	~NumpadEnter::
	if ( tab != 1 )
		return
	Gui, Submit,	NoHide
	goto _date

up:
	comando.verificar("sistema")
return

Esc::
	GuiClose:
	LoginGuiClose:
ExitApp

GeraRelatorio:
	Gui.Cores("relatorio")
		Gui,	relatorio:Font, cWhite Bold
	Gui,	relatorio:Add,	Text,			x5		y0		w110	h20		0x1000								,	Operador
	Gui,	relatorio:Add,	Text,			x5		y30		w110	h20		0x1000								,	Motivo
	Gui,	relatorio:Add,	Text,			x5		y60		w110	h20		0x1000								,	Data	Inicial
	Gui,	relatorio:Add,	Text,			x5		y90		w110	h20		0x1000								,	Data	Final
	Gui,	relatorio:Add,	Text,			x5		y240	w270	h140	0x1000	vquery						,
	Gui,	relatorio:Add,	Radio,			x5		y120			h30				vr1							,	Nome
		Gui,	relatorio:Add,	Radio,		x5		y150			h30				vr2				Checked		,	Hora Saída
		Gui,	relatorio:Add,	Radio,		x5		y180			h30				vr3							,	Tempo Fora
		Gui,	relatorio:Add,	Radio,		x5		y210			h30				vr4							,	Tipo
		Gui,	relatorio:Font
	Gui,	relatorio:Add,	DropDownList,	x115	y0		w160	h20				voperador				R10	,	|%l1%
	Gui,	relatorio:Add,	DropDownList,	x115	y30		w160	h21				vmotivo					R5	,	|Banheiro|Chimarrão|Intervalo|Supermercado
	Gui,	relatorio:Add,	DateTime,		x115	y60		w160	h20				vd_inicio					,	
	Gui,	relatorio:Add,	DateTime,		x115	y90		w160	h20				vd_final					,	
	Gui,	relatorio:Add,	Button,			x5		y390	w270	h30									ggerar	,	Gerar
	Gui, relatorio:Show,	,	Gerador de Relatórios
	Today	:=	A_Now
	mes		:=	SubStr(Today,5,2)-1
	if ( mes = 0 )
		mes = 12
	if ( StrLen(mes) = 1 )
		mes = 0%mes%
	Today := A_Year mes "01"
	FormatTime, mesPassado,	%Today%,	yyyyMMdd
	GuiControl,	relatorio:,	d_inicio,%	mesPassado
return

_intervalo:
	if (	SubStr( A_Now, 9 ) < "070000"
		||	SubStr(A_Now,9) > "200000" )	{
		hoje := SubStr( Date.Format( A_Now ), 1, 10 )
		horav = 20:00:00
		}
		else {
			hoje := SubStr( Date.Format( A_Now ), 1, 10 )
			horav = 07:00:00
			}
	verifica_uso=	;	Verifica se alguém do TURNO ATUAL está com o intervalo marcado
		(
		SELECT TOP 1 * FROM [ASM].[dbo].[_registro_saidas]
		WHERE
			saida BETWEEN '%hoje% %horav%' AND GETDATE()
			AND	retorno is null
			AND	nome<>'%usuarioatual%'
		ORDER BY
			[SAIDA] DESC
		)
	em_uso := sql( verifica_uso, 3 )
	if ( em_uso.Count()-1 > 0 )	{
		uso_user := em_uso[2,2]
		saida_user := SubStr( em_uso[2,3],12 )
		MsgBox,	0x40030,%	em_uso[2,6]="Banheiro" ? "Banheiro em Uso" : "Intervalo em Andamento" ,%	em_uso[2,6]="Banheiro" ? "Aguarde o colaborador`n`t" uso_user "`nretornar do banheiro.`n`n`nEm uso desde as:`n`t" saida_user : "Aguarde o colaborador`n`t" uso_user "`nretornar do Intervalo.`n`n`nEm Intervalo desde as:`n`t " saida_user
		return
		}
	snack := !snack
	if ( snack = 1 )	{	;	ao sair
		GuiControl,	Disable,	_market
		GuiControl,	Disable,	_bath
		GuiControl,	Disable,	_snack
		GuiControl,	Disable,	_coffee
		GuiControl,	Disable,	_mate
		GuiControl,	,	_l_sai
		GuiControl,	,	_l_volta
		GuiControl,	,	_b_sai
		GuiControl,	,	_b_volta
		botao 		=	Registrar Retorno do Intervalo
		GuiControl,	,	_l_sai,	%	"Saída: " Date.Now()
		atualiza	=	INSERT INTO [ASM].[dbo].[_registro_saidas] ([nome],[motivo]) VALUES ('%usuarioatual%','Intervalo')
		atualiza	:=	sql( atualiza, 3 )
		}
		else	{					;	ao retornar
			GuiControl,	Disable,	_snack
			GuiControl,	,	_l_volta,	% "Retorno: " Date.Now()
			botao = Registrar Saída Para Intervalo
			atualiza =
				(
				UPDATE
					[ASM].[dbo].[_registro_saidas]
				SET
					[retorno] = GetDate(),
					[duracao] = DATEDIFF(SECOND, [saida], GetDate())
				WHERE
					pkid = (SELECT TOP 1 [pkid] FROM [ASM].[dbo].[_registro_saidas] WHERE [retorno] IS NULL AND
					[nome] = '%usuarioatual%' AND [motivo] = 'Intervalo');
				)
			atualiza := sql(atualiza,3)
			GuiControl,	Enable,	_bath
			}
	Sleep,	2000
	GuiControl,	Enable,	_snack
	GuiControl,	,	_snack,	%botao%
return

_banheiro:
	if ( SubStr(A_Now,9)<"070000" OR SubStr(A_Now,9) > "200000" )	{
		hoje := SubStr( Date.Format( A_Now ), 1, 10 )
		horav = 20:00:00
		}
		else	{
			hoje := SubStr( Date.Format( A_Now ), 1, 10 )
			horav = 07:00:00
			}
	verifica_uso =	;	Verifica se alguém do TURNO ATUAL está com o banheiro marcado
		(
		SELECT
			*
		FROM
			[ASM].[dbo].[_registro_saidas]
		WHERE
			--motivo ='banheiro' AND
			saida BETWEEN '%hoje% %horav%'
			AND	GETDATE()
			AND	retorno is null
			AND	nome<>'%usuarioatual%'
		ORDER BY
			[SAIDA] DESC
		)
	em_uso := sql( verifica_uso, 3 )
	if ( em_uso.Count()-1 > 0 )	{
		uso_user := em_uso[2,2]
		saida_user := SubStr( em_uso[2,3], 12 )
		MsgBox,	0x40030,	%	em_uso[2,6]="Banheiro"
												?	"Banheiro em Uso"
												:	"Intervalo em Andamento", %	em_uso[2,6] =	"Banheiro"
																							?	"Aguarde o colaborador`n`t" uso_user "`nretornar do banheiro.`n`n`nEm uso desde as:`n`t" saida_user
																							:	"Aguarde o colaborador`n`t" uso_user "`nretornar do Intervalo.`n`n`nEm Intervalo desde as:`n`t "saida_user
		return
		}
	bath := !bath
	if ( bath = 1 )	{
		GuiControl,	Disable,	_market
		GuiControl,	Disable,	_coffee
		GuiControl,	Disable,	_mate
		GuiControl,	Disable,	_snack
		GuiControl,	Disable,	_bath
		GuiControl,	,	_l_sai
		GuiControl,	,	_l_volta
		GuiControl,	,	_b_sai
		GuiControl,	,	_b_volta
		botao 			=		Registrar Retorno do Banheiro
		GuiControl,	,	_b_sai,	%	"Saída: " Date.Now()
		atualiza		=		INSERT INTO [ASM].[dbo].[_registro_saidas]	([nome],[motivo])	VALUES ('%usuarioatual%','Banheiro')
		atualiza		:=	sql(atualiza,3)
	}
	else	{
		GuiControl,	Disable,	_bath
		GuiControl,	,	_b_volta,	% "Retorno: " Date.Now()
		botao			= Registrar Saída Para Banheiro
		atualiza		=
			(
			UPDATE	[ASM].[dbo].[_registro_saidas]
			SET
			[retorno]			=	GetDate(),
			[duracao]			=	DATEDIFF(SECOND, [saida], GetDate())
			WHERE	pkid	=	(SELECT TOP 1 [pkid] FROM [ASM].[dbo].[_registro_saidas] WHERE [retorno] IS NULL AND [nome] = '%usuarioatual%' AND [motivo] = 'Banheiro');
			)
		atualiza		:= sql(atualiza,3)
		GuiControl,	Enable,	_snack
		}
	Sleep,	2000
	GuiControl,	Enable,	_bath
	GuiControl,	,	_bath,	%botao%
return

verifica:	;{	Verifica ao reiniciar o software os estados de banheiro e intervalo
	usuarioatual := usuarioatual="DSANTOS"
						?	"DIEISSON"
						:	usuarioatual="DDIEL"
							?	"DJEISON"
							:	usuarioatual="ARSILVA"
								?	"ANDERSON"
								:	usuarioatual="AKAIPERS"
									?	"ALISSON"
									:	usuarioatual="JCSILVA"
										?	"JOAO"
										:	usuarioatual
	if ( A_UserName = "ARSILVA" )
		usuarioatual = ANDERSON
	if ( A_UserName = "DSANTOS" )
		usuarioatual = DIEISSON
	h_null	=	SELECT TOP(1) [pkid],[nome],[saida],[Retorno],[duracao],[motivo] FROM [ASM].[dbo].[_registro_saidas] WHERE [nome] = '%usuarioatual%' ORDER BY [saida] DESC
	h_null	:=	sql(h_null,3)
	if ( StrLen(h_null[2,4]) = 0 && h_null[2,6] = "Intervalo" )	{
		botao 		=	Registrar Retorno do Intervalo
		GuiControl,	,	_snack,	%botao%
		GuiControl,	Disable,	_bath
		GuiControl,	,	_l_sai,	%	"Saída: " Date.Format( h_null[2,3], "dmy", "ymd" )
		GuiControl,	,	_l_volta
		GuiControl,	,	_b_sai
		GuiControl,	,	_b_volta
		snack			=	1
		}
		if ( StrLen(h_null[2,4]) = 0 && h_null[2,6] = "Banheiro" )	{
			botao 			=	Registrar Retorno do Banheiro
			GuiControl,	,	_bath,	%botao%
			GuiControl,	Disable,	_snack
			GuiControl,	,	_l_sai
			GuiControl,	,	_l_volta
			GuiControl,	,	_b_sai,	%	"Saída: " Date.Format( h_null[2,3], "dmy", "ymd" )
			GuiControl,	,	_b_volta
			bath			=	1
			}
return

Checagem:	;{	Verifica se o Usuário do Iris mudou
	u=	;	user logado
		(
		SELECT	TOP(1)	[LOG~USUARIO],[LOG~ORDEM]
		FROM	[BdIrisLog].[dbo].[SYS~Log]
		WHERE	[LOG~DADOS]		=	'Login no Painel de Monitoramento.'
		AND		[LOG~ESTACAO]	=	'%A_ComputerName%'
		ORDER	BY	2	DESC
		)
	u	:=	sql(u)
	usuarioa := u[2,1]
	;{	usuarios admins e normais
	if ( usuarioatual = "dsantos" && usuarioa = "dieisson" )
		return
	if ( usuarioatual = "arsilva" && usuarioa = "anderson" )
		return
	if ( usuarioatual = "ddiel" && usuarioa = "djeison" )
		return
	if ( usuarioa = "dsantos" && usuarioatual = "dieisson" )
		return
	if ( usuarioa = "arsilva" && usuarioatual = "anderson" )
		return
	if ( usuarioa = "ddiel" && usuarioatual = "djeison" )
		return	;}
	if ( usuarioa != usuarioatual )	;{	Se mudou o Usuário, reinicia
		if ( A_UserName = "alberto" || A_UserName = "dsantos" )
			return
			else
			Reload
return

gerar:
	Gui,	relatorio:Submit,	NoHide
	if ( r1 = 1)
		radio = 2
	else if ( r2 = 1 )
		radio = 3
	else if ( r3 = 1 )
		radio = 5
	else if ( r4 = 1 )
		radio = 6
	else if ( r1 = 0 && r2 = 0 && r3 = 0 && r4 = 0 )
		radio = 1
	if ( operador != "" )	{	;	Contém filtro por nome
		reg = SELECT [login],[login2] FROM [Sistema_Monitoramento].[dbo].[Operadores]	WHERE nome = '%operador%'
		reg	:=	sql(reg,3)
		res1	:=	StrReplace(reg[2,1],"`r`n")
		res2	:=	StrReplace(reg[2,2],"`r`n")
		}
	if ( StrLen(operador) > 0 )	{
		operador:=StrReplace(operador,"`r`n")
		if ( StrLen(res2) = 0 )
			nome=AND nome = '%res1%'
			else
			nome=AND (nome = '%res1%' OR nome = '%res2%')
		}
		else	{
		nome=
		operador=	
		}
	if(StrLen(motivo)>0)	{
		why= AND motivo = '%motivo%'
		motivox= pelo motivo `"%motivo%`"
		}
		else	{
		why=
		motivox=	
		}
	d_inicio := SubStr(d_inicio,1,8)
	d_final := SubStr(d_final,1,8)
	if ( d_inicio <= d_final )	{
		FormatTime,	hoje,		%A_Now%,	yyy-MM-dd
		FormatTime,	year,		%A_Now%,	yyy
		FormatTime,	month,		%A_Now%,	MM
		FormatTime,	day,		%A_Now%,	dd
		FormatTime,	d_inicio1,	%d_inicio%,	yyy-MM-dd
		FormatTime,	d_final1,	%d_final%,	yyy-MM-dd
		if ( d_inicio = d_final )	{
			data=	 no dia	`"%d_inicio1%`".
			periodo= (DATEPART(YEAR,saida)=%year% and DATEPART(MONTH,saida)=%month% and DATEPART(DAY,saida)=%day%) 
			}
			else	{
			data			=	no período de `"%d_inicio1%`" a `"%d_final1%`"
			periodo					=	saida >=  '%d_inicio%'	and saida <= DATEADD(DD,1,'%d_final%')
			}
		}
		else	{
		MsgBox	A data FINAL não pode ser INFERIOR a data INICIAL.
		return
		}
	if ( StrLen(operador) = 0 )
		texto	:=	"Consulta buscando dados:`n`n" motivox "`n" data
	if ( StrLen(motivox) = 0 )
		texto	:=	"Consulta buscando dados:`n`n" operador "`n" data
	if ( StrLen(motivox) = 0 && StrLen(operador) = 0 )
		texto	:=	"Consulta buscando dados:`n`n" data
	if ( StrLen(motivox) != 0 && StrLen(operador) != 0 )
		texto	:=	"Consulta buscando dados:`n`n" operador "`n" motivox "`n" data
	GuiControl,	relatorio:,	query,	%texto%
	sql_r = SELECT[pkid],[nome],[saida],[Retorno],[duracao],[motivo] FROM [ASM].[dbo].[_registro_saidas] WHERE %periodo% %nome% %why% ORDER BY %radio%
	sql_le=
	sql_r := sql(sql_r,3)
		r=
		Gosub CreateNewCalc
	IfWinExist,	Relatório de erros
		WinClose,	Relatório de erros
	oSheet	:=	oSheets.getByIndex(0)
	if ( StrLen(operador) = 0 )
		operador := "Todos - " d_inicio " a " d_final
	sPath		:=	A_Desktop
	sFileName	=	Controle Horarios %operador%.ods
	SheetName	:=	oSheets.getByIndex(0).Name
	;	CALC properties
		Column = A
			oColumns := oSheet.getColumns()
			oColumn := oColumns.getByName( Column )
			oColumn.Width := 3000
		Column = B
			oColumns := oSheet.getColumns()
			oColumn := oColumns.getByName( Column )
			oColumn.Width := 4000
		Column = C
			oColumns := oSheet.getColumns()
			oColumn := oColumns.getByName( Column )
			oColumn.Width := 4000
		Column = D
			oColumns := oSheet.getColumns()
			oColumn := oColumns.getByName( Column )
			oColumn.Width := 3000
		Column = E
			oColumns := oSheet.getColumns()
			oColumn := oColumns.getByName( Column )
			oColumn.Width := 3000
		Column = F
			oColumns := oSheet.getColumns()
			oColumn := oColumns.getByName( Column )
			oColumn.Width := 3000
	nFormat := oFormats.getStandardFormat( "4", oLocale )	; com.sun.star.util.NumberFormat.CURRENCY
	Loop,	%	sql_r.Count()	{
		if ( A_Index = 1 )	{
			oCell := oSheet.getCellRangeByName( "A"A_Index )
			oCell.setString("Nome")
			oCell := oSheet.getCellRangeByName( "B"A_Index )
			oCell.setString("Horário de Saída")
			oCell := oSheet.getCellRangeByName( "C"A_Index )
			oCell.setString("Horário de Retorno")
			oCell := oSheet.getCellRangeByName( "D"A_Index )
			oCell.setString("Dias Fora")
			oCell := oSheet.getCellRangeByName( "E"A_Index )
			oCell.setString("Tempo Fora")
			oCell := oSheet.getCellRangeByName( "F"A_Index )
			oCell.setString("Tipo de Saída")
			}
			else	{
				oCell := oSheet.getCellRangeByName( "A"A_Index )
				oCell.setString(sql_r[A_Index,2])	
				oCell := oSheet.getCellRangeByName( "B"A_Index )
				oCell.setString(sql_r[A_Index,3])	
				oCell := oSheet.getCellRangeByName( "C"A_Index )
				oCell.setString(sql_r[A_Index,4])	
				if ( InStr( dia := FormatSeconds(sql_r[A_Index,5]),"|") > 0 )	{
					oCell := oSheet.getCellRangeByName( "D"A_Index )
					dias:=StrSplit(dia,"|")
					oCell.setString(dias[1])
					oCell.NumberFormat := nFormat
					oCell := oSheet.getCellRangeByName( "E"A_Index )
					oCell.setString(dias[2])
					oCell.NumberFormat := nFormat
					}
					else	{
						oCell := oSheet.getCellRangeByName( "D"A_Index )
						oCell.setString(0)
						oCell.NumberFormat := nFormat
						oCell := oSheet.getCellRangeByName( "E"A_Index )
						oCell.setString(FormatSeconds(sql_r[A_Index,5]))
						oCell.NumberFormat := nFormat
						}
				oCell := oSheet.getCellRangeByName( "F"A_Index )
				oCell.setString(sql_r[A_Index,6])	
				}
		oCell	:=	oSheet.getCellRangeByName( "D" sql_R.MaxIndex()+1 )
		oCell.NumberFormat := nFormat
		}
	If !sPath
		sPath:=A_Desktop
	If !( SubStr(sPath, StrLen(sPath)-1, 1) = "\" )
		sPath := sPath "\"
	FileNameOut := sPath sFileName
	If	FileExist(FileNameOut)
		FileDelete %FileNameOut%
	oDoc.storeAsURL(FileURL(FileNameOut), Array)
	oDoc.Close(True)
	oDoc := ""
	IfWinExist,	Recuperação de documentos
		WinClose,	Recuperação de documentos
	IfWinExist,	Relatório de erros
		WinClose,	Relatório de erros
	MsgBox, 4,, Gostaria de abrir o arquivo?`n	%FileNameOut%
	IfMsgBox Yes
		Run,	%FileNameOut%
	Sleep,	2000
	IfWinExist,	Recuperação de documentos
		WinClose,	Recuperação de documentos
	IfWinExist,	Relatório de erros
		WinClose,	Relatório de erros
Reload

relatorioGuiClose:
	Gui,	relatorio:Destroy
return

CreateNewCalc:
	oSM				:=	ComObjCreate("com.sun.star.ServiceManager")				;	This line is mandatory with AHK for OOo API
	oDesk			:=	oSM.createInstance("com.sun.star.frame.Desktop")		;	Create the first and most important service
	Array			:=	ComObjArray(VT_VARIANT:=12, 2)
	Array[1]		:=	MakePropertyValue(oSM, "hidden", ComObject(0xB,true))
	sURL			:=	"private:factory/scalc"
	oDoc			:=	oDesk.loadComponentFromURL(sURL, "_blank", 0, Array)
	oBorder			:=	oSM.Bridge_GetStruct("com.sun.star.table.BorderLine")
	oSheets			:=	oDoc.getSheets()
	SheetName		:=	oSheets.getByIndex(0).Name
	oFormats		:=	oDoc.getNumberFormats()
	oLocale			:=	oSM.Bridge_GetStruct("com.sun.star.lang.Locale")
	oLocale.Language:=	"br"
	oLocale.Country	:=	"BR"
Return

MakePropertyValue( oSM, cName, uValue )	{	
	oPropertyValue					:=	oSM.Bridge_GetStruct("com.sun.star.beans.PropertyValue")
	If	cName
		oPropertyValue.Name	:=	cName
	If	uValue
		oPropertyValue.Value	:=	uValue
	Return	oPropertyValue
}

FileURL( File )	{
	Local v, INTERNET_MAX_URL_LENGTH := 2048   
	VarSetCapacity(v,4200,0)
	DllCall( "Shlwapi.dll" ( SubStr(File,1,5)="file:" ? "\PathCreateFromUrl" : "\UrlCreateFromPath" )
			, "Str",File, "Str",v, "UIntP",INTERNET_MAX_URL_LENGTH, "UInt",0 )
	Return v
}

Login:
	#IfWinActive, Login Cotrijal
	Gui.Cores("login","9BACC0","374658")
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
		is_login := Login( @usuario, @senha )
		if	( logou = "interface" )
			Return
		goto,%	logou := Login( @usuario, @senha ) =	0
													?	"GuiClose"
													:	"Interface"
	Return

return