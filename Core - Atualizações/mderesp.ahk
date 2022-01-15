;@Ahk2Exe-SetMainIcon C:\Dih\zIco\2resp.ico

;	include
	#Include, ..\class\array.ahk
	#Include, ..\class\functions.ahk
	#Include, ..\class\gui.ahk
	#Include, ..\class\string.ahk
	#Include, ..\class\sql.ahk
;

;	Arrays
	unidades_lv	:=	{}

;

;	Variáveis
	software	=	asm
		fundo		=	BDDBFF
	fundo		=	cfff7e1
		frente		=	c3D9AE2
	frente		=	c595653
		f_titulo	=	c9df80
	f_titulo	=	cfff2cc
	Global	clicado=1
;

;	Configurações
	#SingleInstance, Force
	SetBatchLines, -1
;

;	Definição de ramal
	if		( InStr( A_IpAddress1 , "184" ) > 0 )
		ramal = 2524
	else if ( InStr( A_IpAddress1 , "162" ) > 0 )
		ramal = 2530
	else if ( InStr( A_IpAddress1 , "166" ) > 0 )
		ramal = 2852
	else if ( InStr( A_IpAddress1 , "169" ) > 0 )
		ramal = 2853
	else if ( InStr( A_IpAddress1 , "176" ) > 0 )
		ramal = 2854
	else if ( InStr( A_IpAddress1 , "179" ) > 0 )
		ramal = 2855
;

;	Select de Unidades
	uni =
		(
		SELECT
				[id_entreposto]
			,	[nm_unidade]
			,	[safra]
			,	[endereco1]
			,	[endereco2]
			,	[endereco3]
			,	[id_gerencia]
			,	[tipo_unidade]
			,	[ids_estabs]
			,	[id_mail]
		FROM
			[ASM].[dbo].[_unidades]
		ORDER BY
			2
		ASC
		)
	uni := sql( uni , 3 )
	Loop,% uni.Count()-1
		unidades_lv.push({	unidade	:	uni[A_Index+1,1]
						,	Nome	:	uni[A_Index+1,2]
						,	Safra	:	uni[A_Index+1,3]
						,	end1	:	uni[A_Index+1,4]
						,	end2	:	uni[A_Index+1,5]
						,	end3	:	uni[A_Index+1,6]
						,	gerencia:	uni[A_Index+1,7]
						,	tipos	:	uni[A_Index+1,8]
						,	estabs	:	uni[A_Index+1,9]
						,	id_mail	:	uni[A_Index+1,10]	})
;

; Interface
	Gui, destroy
		Gui.Cores( "1" , fundo , frente )
		Gui.Font( "1" , f_titulo , "Bold" , "s10" )
	Gui, 1:Add,	Text,		x5								y5																																	,	Buscar unidade 
	Gui, 1:Add,	Text,		x252							y5																									Section
		Gui.Font()
	Gui, 1:Add, Edit,		x120							yp							w105	h20								vb_unidade	gUnidades
	Gui, 1:Add, ListView,%	"xs-255							yp+30 						w300	h"( A_ScreenHeight - 120 ) "				gSelecionaUnidade	NoSortHdr	0x3	Grid	-HDR"	,	ID|UNIDADE|Safra|e1|e2|e3|gerencia|tipos|estabs|mail
		LV_ModifyCol( 1 , 0 )
		Loop,	10
			LV_ModifyCol( 2 + A_Index , 0 )
		LV_ModifyCol( 2 , 230 )
	Gosub, Unidades
	Gui, 1:Add, Button,%	"x2								y"( A_ScreenHeight - 82 ) "	w226	h40											gGuiClose										"	,	Fechar
		Gui, 1:  -Border
	Gui, 1:Show,%			"x"( A_ScreenWidth - 234 ) "	y0							w230	h"( A_ScreenHeight - 35 )																		,	Unidades Cotrijal, GUI-1
		GuiControl, 1:Focus, b_unidade
return

Unidades:	;	Listview do menu principal
	Gui, 1:Submit, NoHide
	LV_Delete()
	if ( StrLen( b_unidade ) = 0 )	;	Pesquisa dinâmica
		for i in unidades_lv
			LV_Add(	""
				,	unidades_lv[i].unidade
				,	unidades_lv[i].Nome
				,	unidades_lv[i].Safra
				,	unidades_lv[i].end1
				,	unidades_lv[i].end2
				,	unidades_lv[i].end3
				,	unidades_lv[i].gerencia
				,	unidades_lv[i].tipos
				,	unidades_lv[i].estabs
				,	unidades_lv[i].id_mail	)
	else
		for i in unidades_lv
			if ( InStr( unidades_lv[i].Nome , b_unidade ) > 0 )
				LV_Add(	""
					,	unidades_lv[i].unidade
					,	unidades_lv[i].Nome
					,	unidades_lv[i].Safra
					,	unidades_lv[i].end1
					,	unidades_lv[i].end2
					,	unidades_lv[i].end3
					,	unidades_lv[i].gerencia
					,	unidades_lv[i].tipos
					,	unidades_lv[i].estabs
					,	unidades_lv[i].id_mail	)
return

SelecionaUnidade:
	Gui, 1:Submit, NoHide
	Gui, 2:Destroy
	Gui, 3:Destroy
	Gui, 4:Destroy
	Gui, mapa:Destroy
	if ( unidade = "ID" )
		return
	RowNumber = 0
	LV_GetText(	unidade		, LV_GetNext()			)
	LV_GetText(	nome_unidade, LV_GetNext()	,	2	)
	LV_GetText(	Safra		, LV_GetNext()	,	3	)
	LV_GetText(	end1		, LV_GetNext()	,	4	)
	LV_GetText(	end2		, LV_GetNext()	,	5	)
	LV_GetText(	end3		, LV_GetNext()	,	6	)
	LV_GetText(	gerencia	, LV_GetNext()	,	7	)
	LV_GetText(	tipos		, LV_GetNext()	,	8	)
	LV_GetText(	estabs		, LV_GetNext()	,	9	)
	LV_GetText(	id_mail		, LV_GetNext()	,	10	)
	Address =
	Loop,	3
		if ( StrLen ( end%A_Index% ) > 0 )	{
			s_mapa := SubStr( end%A_Index% , 1 , 1 )	=	1
														?	"Geral:`n"
														:	SubStr( end%A_Index% , 1 , 1 )	=	2
																							?	"Supermercado/Atacado:`n"
																							:	SubStr( end%A_Index% , 1 , 1 )	=	3
																																?	"Viveiro:`n"
																																:	SubStr( end%A_Index% , 1 , 1 )	=	4
																																									?	"Expodireto:`n"
																																									:	SubStr( end%A_Index% , 1 , 1 )	= 5
																																																		?	"Fábrica de Ração:`n"
																																																		:	SubStr( end%A_Index% , 1 , 1 )	=	6
																																																											?	"Loja:`n"
																																																											:	""
			if ( InStr( Address , string.case( SubStr( end%A_Index% , 3 ) ) , "T" ) = 1 )
				Address .= s_mapa "`t" StrReplace( string.case( SubStr( end%A_Index% , 3 ) , "T" ), "`n", "`n`t" ) "`n`n"
		}
	Address := SubStr( Address , 1 , StrLen( Address ) - 2 )
;

Responsaveis:	;	Gui de Responsáveis
	Gui, 2:Default
	direto	=	1
	campos	=
	mapas	:=	{}
	Loop,	Files,	\\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\mapz\*.jpg	;	Carrega os mapas
		mapas.push({unidade	:	StrReplace( A_LoopFileName , ".jpg" )
				,	setor	:	SubStr( StrReplace( A_LoopFileName , ".jpg" ) , -0 )	=	1
																						?	"Balança"
																						:	SubStr( StrReplace( A_LoopFileName , ".jpg" ) , -0 )	=	2
																																					?	"Administrativo"
																																					:	SubStr( StrReplace( A_LoopFileName , ".jpg" ) , -0 )	=	3
																																																				?	"Defensivos"
																																																				:	SubStr( StrReplace( A_LoopFileName , ".jpg" ) , -0 )	=	4
																																																																			?	"Fertilizantes"
																																																																			:	SubStr( StrReplace( A_LoopFileName , ".jpg" ) , -0 )	=	5
																																																																																		?	"Loja"
																																																																																		:	SubStr( StrReplace( A_LoopFileName , ".jpg" ) , -0 )	=	6
																																																																																																	?	"Supermercado"
																																																																																																	:	SubStr( StrReplace( A_LoopFileName , ".jpg" ) , -0 )	=	7
																																																																																																																?	"AFC"
																																																																																																																:	SubStr( StrReplace( A_LoopFileName , ".jpg" ) , -0 )	=	8
																																																																																																																															?	"Casa"
																																																																																																																															:	""	})
	l =
	Loop, 8	{
		mapa_index	:=	Array.InDict( mapas , unidade A_Index , "unidade" )
		if ( mapa_index > 0 )	{
			campos .= mapas[ mapa_index ].Setor "|"
			l++
		}
	}
	campos .= "Selecione para exibir o Mapa"
	;	fim da carga de mapas

	l++

;	Interface	
		Gui.Cores( "2" , fundo , frente )
		Gui.Font( "2" , "S12" , "Bold" , f_titulo )
	Gui, 2:Add, Text,			x10		y10		w600	h30		vds_unidade			Center
		Gui.Font()
	Gui, 2:Add, DropDownList,	x20		y450	w220	h30		vmapa				Choose%l%	gAbre_Mapa	R%l%											, %campos%
	Gui, 2:Add, Button,			x850	y0		w180	h30		vmails							gAbre_Mail
		Gosub Abre_Mail
		Gui.Font( "2" , "s10" , "Bold" , f_titulo )
	Gui, 2:Add, Text,			x250	y450	w300	h30																									, CLIQUE NO MAPA PARA EXPANDIR
	Gui, 2:Add, GroupBox,		x650	y35		w390	h395																								, Informações da Unidade
	Gui, 2:Add, GroupBox,		x10		y210	w630	h220																								, Autorizados
	Gui, 2:Add, GroupBox,		x10		y430	w1030	h530																								, Mapas
	Gui, 2:Add, Text,			x30		y230	w150																										, Buscar autorizado:
	Gui, 2:Add, Text,			x660	y50				h20																									, Endereço
		Gui.Font( "2" , "s10" , "Bold" , "cWhite" )
	Gui, 2:Add, Text,			x660	y70		w360			vds_endereco			0x1000																, %	Address
		; Gui, 2:Add, Text,						x630	y130				h20																									, Observações
		Gui.Font()
		; Gui, 2:Add, Edit,						x630	y150	w390	h40		vds_observacao
	Gui, 2:Add, Edit,			x170	y230	w460			vds_buscaautorizado				gbuscaAutorizado
	Gui, 2:Add, ListView,		x20		y260	w610	R8		vlv_autorizados					Grid														, Nome|Matrícula|Cargo|Observação|sexo|t1|t2|Ramal
	Gui, 2:Add, ListView,		x10		y40		w630	R8		vlv_responsaveis	AltSubmit	Grid														, Cargo|Nome|Matrícula|Telefone 1|Telefone 2|Ramal|Situação|sexo
	Gui, 2:Add, Picture,		x20		y480	w1000	h470	vpic_mapa			Hidden		gExpandeMapa
;

;	SQL's
	;	Seleciona o gerente da unidade
		g =
			(
			SELECT
					[cargo]
				,	[nome]
				,	[telefone1]
				,	[telefone2]
				,	[matricula]
				,	[situacao]
				,	[responsavel]
				,	[ramal]
				,	[sexo]
				,	[cd_entreposto]
				,	[cd_estab]
				,	[cd_unidade]
			FROM
				[ASM].[dbo].[_colaboradores]
			WHERE
				[responsavel]	= '1' and
				[cd_unidade]	= '%gerencia%'
			)
		g := sql( g , 3 )
	;

	;	Seleciona os coordenadores
		query =
		if ( InStr( estabs , "." ) > 0 ) {	;	QUANDO HÁ MAIS DE UM
			estab := StrSplit( estabs , "." )
			Loop,%	estab.Count()
				if ( A_Index = 1 )
					query .=  " ([cd_estab] = '"	estab[A_Index] "'"
				else if ( estab.Count() = A_Index )
					query .=  " or [cd_estab] = '"	estab[A_Index] "')"
				else
					query .=  " or [cd_estab] = '"	estab[A_Index]	"'"
		}
		else
			if ( estabs = "101" )	;	viveiro
				query = [cd_estab] = '101'
			else if ( estabs = "47" )	;	coqueiros
				query = [cd_estab] = '47'
			else if ( estabs = "64" )	;	vila langaro
				query = [cd_estab] = '64'
			else if ( estabs = "72" )	;	Charrua
				query = [cd_estab] = '72'
			else if ( estabs = "98" )	;	Cruzaltinha
				query = [cd_estab] = '98'
			else
				query = [cd_entreposto] = '%gerencia%' or [cd_estab] = '%estabs%'

		if ( estabs = "47" )	;	coqueiros
			responsaveis = [responsavel] in (4)
		if ( estabs = "101" )	;	viveiro
			responsaveis = [responsavel] in (1,11)
		if ( estabs = "64" )	;	vila langaro
			responsaveis = [responsavel] in (1,2)
		if ( estabs = "72" )	;	charrua
			responsaveis = [responsavel] in (1,2)
		if ( estabs = "98" )	;	Cruzaltinha
			responsaveis = [responsavel] in (1,2)
	;

	;	Filtro de tipos de responsáveis necessários
		tipos_responsaveis = 25	
		if ( InStr( tipos , "1" ) > 0 )
			tipos_responsaveis .= 1
		if ( InStr( tipos , "2" ) > 0 )
			tipos_responsaveis .= 4
		if ( InStr( tipos , "6" ) > 0 )
			tipos_responsaveis .= 3
		if ( InStr( tipos , "8" ) > 0 )
			tipos_responsaveis .= 8
		responsaveis =
		Loop,%	StrLen( tipos_responsaveis )
			responsaveis .= SubStr( tipos_responsaveis , A_Index , 1 ) ","
		responsaveis := "[responsavel] in (" SubStr( responsaveis , 1 , StrLen( responsaveis ) - 1 ) ")"

		m =
			(
			SELECT
					[cargo]
				,	[nome]
				,	[telefone1]
				,	[telefone2]
				,	[matricula]
				,	[situacao]
				,	[responsavel]
				,	[ramal]
				,	[sexo]
				,	[cd_entreposto]
				,	[cd_estab]
				,	[cd_unidade]
			FROM
				[ASM].[dbo].[_colaboradores]
			WHERE
				%responsaveis%	AND ( %query% )
			ORDER BY
					7
				,	11
			)
		m := sql( m , 3 )
	;

	;	Seleciona os autorizados
		id := LTrim( unidade , "0" )
		a =
			(
			SELECT
					c.[nome]
				,	a.[matricula]
				,	c.[cargo]
				,	a.[Observacao]
				,	c.[telefone1]
				,	c.[telefone2]
				,	c.[ramal]
				,	c.[sexo]
			FROM
				[ASM].[dbo].[_autorizados] a
			LEFT JOIN
				[ASM].[dbo].[_colaboradores] c
			ON
				a.[matricula] = c.[matricula]
			WHERE
				a.[id_unidade] = '%id%' AND
				c.[nome] IS NOT NULL
			ORDER BY
				1
			)
		a := sql( a , 3 )
	;

	;	Interface
		adicionado := []
		Gui, 2:ListView, lv_responsaveis	;{
		GuiControl,	2:,	ds_unidade,	% Safra = 1 ? nome_unidade " - EM SAFRA" : nome_unidade
		;	Gerente
			if ( Substr( g[2,3] , -7 ) = Substr( g[2,4] , -7 ) ) {	;	se o número já está na lista, adiciona apenas 1
				if ( array.InArray( adicionado , g[2,5] ) != 0 )	;	se ja foi adicionado o responsável, ignora
					return
				LV_Add(	""
					,	String.Cargo( g[2,1] )
					,	string.Name( g[2,2] )
					,	g[2,5]
					,	string.Telefone( g[2,3] )
					,	""
					,	g[2,8]
					,	g[2,6]
					,	g[2,9]	)
				adicionado.push( g[2,5] )
			}
			else {			
				if ( array.InArray( adicionado , g[2,5] ) != 0 )		;	 se ja foi adicionado o responsável, ignora
					return												;	caso contrário os 2 números
				LV_Add(	""
					,	string.Cargo( g[2,1] )
					,	string.Name( g[2,2] )
					,	g[2,5]
					,	string.Telefone( g[2,3] )
					,	string.Telefone( g[2,4] )
					,	g[2,8]
					,	g[2,6]
					,	g[2,9]	)
				adicionado.push( g[2,5] )
			}
		;

		;	Responsáveis
			Loop,%	m.Count()-1	{
				if ( array.InArray( adicionado , m[A_Index+1,5] ) != 0 )				;	 se ja foi adicionado o responsável, ignora
					continue
				if ( Substr( m[A_Index+1,3] , -7 ) = Substr( m[A_Index+1,4] , -7 ) )	;	se o número já está na lista, adiciona apenas 1
					LV_Add(	""
						,	string.Cargo( m[A_Index+1,1] )
						,	string.Name( m[A_Index+1,2] )
						,	m[A_Index+1,5]
						,	string.Telefone( m[A_Index+1,3] )
						,	""
						,	m[A_Index+1,8]
						,	m[A_Index+1,6]
						,	m[A_Index+1,9]	)
				else																	; caso contrário os 2 números
					LV_Add(	""
						,	string.Cargo( m[A_Index+1,1] )
						,	string.Name( m[A_Index+1,2] )
						,	m[A_Index+1,5]
						,	string.Telefone( m[A_Index+1,3] )
						,	string.Telefone( m[A_Index+1,4] )
						,	m[A_Index+1,8]
						,	m[A_Index+1,6]
						,	m[A_Index+1,9]	)
				adicionado.push( m[A_Index+1,5] )
			}
		;

		; LV_ModifyCol()
			LV_ModifyCol(	1	,	90	)
			LV_ModifyCol(	2	,	120	)
			LV_ModifyCol(	3	,	60	)
			LV_ModifyCol(	4	,	110	)
			LV_ModifyCol(	5	,	110	)
			LV_ModifyCol(	6	,	50	)
			LV_ModifyCol(	7	,	80	)
			LV_ModifyCol(	8	,	0	)
		;

		Loop,	6
			if (A_Index = 1
			||	A_index = 2 )	;	Ajusta a listview
				continue
			else
				LV_ModifyCol( A_Index , "center" )
		;	Autorizados
			Gui,	2:ListView,	lv_autorizados
			a_autorizados := {}
			Loop,%	a.Count()-1	{
				Nome_a	:=	string.Name( a[A_Index+1,1] )
				Cargo_a	:=	string.Cargo( a[A_Index+1,3] )
				if ( array.InArray( adicionado , a[A_Index+1,2] ) != 0 )			;	 se ja foi adicionado o responsável, ignora
					continue
				LV_Add(	""
					,	string.Name( a[A_Index+1,1] )
					,	a[A_Index+1,2]
					,	string.Cargo( a[A_Index+1,3] )
					,	a[A_Index+1,4]
					,	string.Telefone( a[A_Index+1,5] )
					,	string.Telefone( a[A_Index+1,6] )
					,	a[A_Index+1,7]
					,	a[A_Index+1,8]	)
				a_autorizados.push({	Nome		:	Nome_a
									,	Matrícula	:	a[A_Index+1,2]
									,	Cargo		:	Cargo_a
									,	Obs			:	a[A_Index+1,4]
									,	t1			:	a[A_Index+1,5]
									,	t2			:	a[A_Index+1,6]
									,	ramal		:	a[A_Index+1,7]
									,	sex			:	a[A_Index+1,8]	})
			}
			LV_ModifyCol(	1 ,	150					)
			LV_ModifyCol(	2 ,	60 " Integer Center")
			LV_ModifyCol(	3 ,	130					)
			LV_ModifyCol(	4 ,	230					)
			LV_ModifyCol(	5 ,	0					)
			LV_ModifyCol(	6 ,	0					)
			LV_ModifyCol(	7 ,	0					)
			LV_ModifyCol(	8 ,	0					)
		;
		Gui, 2:Show,%	"x-3 y0  w1046 NoActivate h"( A_ScreenHeight - 56 )	, Responsáveis
		GuiControl,	2:Focus, ds_buscaautorizado
	;
return

buscaAutorizado:
	Gui, 2:Submit, NoHide
	Gui, 2:ListView, lv_autorizados
	LV_Delete()
	if ( StrLen( ds_buscaautorizado ) = 0 )	{	;	Se a consulta ficar em branco repõe todos os autorizados
		Loop,%	a_autorizados.Count()
			LV_Add(	""
				,	a_autorizados[A_Index].nome
				,	a_autorizados[A_Index].Matrícula
				,	a_autorizados[A_Index].Cargo
				,	a_autorizados[A_Index].Obs
				,	a_autorizados[A_Index].t1
				,	a_autorizados[A_Index].t2
				,	a_autorizados[A_Index].ramal
				,	a_autorizados[A_Index].sex	)
		return
	}
	Indexes	:=	StrSplit( Array.Has( a_autorizados , ds_buscaautorizado , "nome,matrícula" ) , "|" )
	Loop,%	Indexes.Count()
		LV_Add(	""
			,	a_autorizados[Indexes[A_Index]].nome
			,	a_autorizados[Indexes[A_Index]].Matrícula
			,	a_autorizados[Indexes[A_Index]].Cargo
			,	a_autorizados[Indexes[A_Index]].Obs
			,	a_autorizados[A_Index].t1
			,	a_autorizados[A_Index].t2
			,	a_autorizados[A_Index].ramal
			,	a_autorizados[A_Index].sex	)
return

Abre_Mapa:
	Gui, 2:Submit, NoHide
	ssetor	:= InStr( mapa , "bal" ) >	0
									?	1
									:	InStr( mapa , "adm" )	>	0
																?	2
																:	InStr( mapa , "def" )	>	0
																								?	3
																								:	InStr( mapa , "fert" )	>	0
																															?	4
																															:	InStr( mapa , "loja" )	>	0
																																						?	5
																																						:	InStr( mapa , "merc" )	>	0
																																													?	6
																																													:	InStr( mapa , "AFC" )	>	0
																																																				?	7
																																																				:	InStr( mapa , "Casa" )	>	0
																																																											?	8
																																																											:	9
	file	:= "\\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\mapz\" . LTrim( unidade , "0" ) ssetor ".jpg"
	if ( unidade = "" )
		return
		Gui.Cores( "3" )
	if FileExist( file )	{
	    GuiControl,	2:-Redraw	,	pic_mapa
		GuiControl,	2:			,	pic_mapa,%	file
		GuiControl,	2:+Redraw	,	pic_mapa	
		GuiControl,	2:Show		,	pic_mapa	
	}
	else
		GuiControl,	2:Hide		,	pic_mapa	
return

ExpandeMapa:
	Gui.Cores( mapa )
	if FileExist( file )	{
		Gui, mapa:-Border	-SysMenu	+Owner	-Caption	+ToolWindow
		Gui, mapa:Add,		Pic,%	"x2	y2	gContraiMapa	w" A_ScreenWidth-4 " h" A_ScreenHeight-40,	%	file
		Gui, mapa:Show			,	AutoSize
	}
return

ContraiMapa:
	Gui,	mapa:Destroy
return

Abre_Mail:				;{	14/04/2021 - Precisa melhorias visuais e funcionais(filtro)
	mails = 
	Particao:=(StrLen(id_mail)=2)?("0" id_mail):(id_mail)
	; MsgBox % Particao
	q=SELECT a.[Mensagem],a.[QuandoGerou] FROM [IrisSQL].[dbo].[Agenda] a LEFT JOIN [IrisSQL].[dbo].[Clientes] c on a.IdCliente=c.IdUnico WHERE QuandoGerou >= DATEADD(day,-7, GETDATE()) AND c.[Particao] = '%Particao%'
	; Clipboard:=q
	qs := sql(q)
	if(qs.Count()-1=0)	{
		GuiControl,	,mails,	%	"( " qs.Count()-1 " ) E-Mail(s) nos últimos 7 dias"
		return
	}
	GuiControl,	,mails,	%	"( " qs.Count()-1 " ) E-Mail(s) nos últimos 7 dias"
	Loop,% qs.Count()-1	{
		col		:=	A_Index+1
		descr	:=	qs[col,1]
		data	:=	qs[col,2]
		if ( descr != older	)	{
			total_mail ++
			mails	.=	data "`n »`n" descr "`n`n_________________________________________________________________________`n"
		}
		older	:=	descr
	}
	if ( direto = 1 ) {
		older =
		direto = 0
		return
	}
	Gui.Cores(4)
	Gui, 4:Font, s10
	Gui, 4:Add, Edit, x5 w1026 h560 0x1000, %mails%
	Gui, 4:Add, Button, w100 h18 vOk gOk ,OK
	Gui, 4:Show, x-2 y0 , %	nome_unidade
	GuiControl,	4:Focus, Ok
Return

2GuiContextMenu()	{
	if ( A_eventInfo = 0 )
		return
	Gui, 2:Submit, NoHide
	menu1:=menu2:=menu3:=""
	if ( clicado > 1 )
		Menu, ClickToCall, DeleteAll
	if ( A_GuiControl = "lv_responsaveis" )	{
		Gui, 2:ListView,	lv_responsaveis
		LV_GetText(	tnome ,A_EventInfo , 2 )
		LV_GetText(	Menu1 ,A_EventInfo , 4 )
		LV_GetText(	Menu2 ,A_EventInfo , 5 )
		LV_GetText(	Menu3 ,A_EventInfo , 6 )
		LV_GetText(	sex ,A_eventinfo , 8 )
	}
	else if ( A_GuiControl = "lv_autorizados" )		{
		Gui, 2:ListView,	lv_autorizados
		LV_GetText(	tnome , A_EventInfo , 1 )
		LV_GetText(	Menu1 , A_EventInfo , 4 )
		LV_GetText(	Menu2 , A_EventInfo , 5 )
		LV_GetText(	Menu3 , A_EventInfo , 6 )
		LV_GetText(	sex , A_eventinfo , 8 )
	}
	if ( StrLen( tnome ) > 0 )	{
		clicado++
		Loop,	3
			m%A_Index%	:=	StrReplace( StrReplace( StrReplace( StrReplace( menu%A_Index% , "(") , ")" ) , "-" ) ," " )
		if ( menu1 = menu2 )
			menu2 =
		Loop,	2
			if ( StrLen( m%A_Index% ) = 12 )
				if (Substr( m%A_Index% , 5 , 1 ) = "9"
				||	Substr( m%A_Index% , 5 , 1 ) = "8" )
					m%A_Index% := Substr( m%A_Index% , 1 , 4 ) "9" Substr( m%A_Index% , 5 )
		;	Prepara o Menu
			Menu, ClickToCall, Add, %	tnome,	tip
			Menu, ClickToCall, Add
			if ( StrLen( m1 ) > 0 )
				Menu, ClickToCall, Add,% menu1, Call1
			if ( StrLen( m2 ) > 0 ) {
				if ( StrLen( m1 ) > 0 )
					Menu, ClickToCall, Add
				Menu, ClickToCall, Add,% menu2, Call2
			}
			if ( StrLen( m3 ) > 0 ) {
				if (StrLen( m1 ) > 0
				||	StrLen( m2 ) > 0 )
					Menu, ClickToCall, Add
				Menu, ClickToCall, Add,% menu3, Call3
			}
			if (StrLen( m1 ) = 0
			&&	StrLen( m2 ) = 0
			&&	StrLen( m3 ) < 3 )
				return
		;

		;	Ícones
			if ( sex = "M" )
				Menu,	ClickToCall,	Icon,%	tnome	,	C:\Seventh\Backup\ico\bman.png,, 0
			else
				Menu,	ClickToCall,	Icon,%	tnome	,	C:\Seventh\Backup\ico\bwoman.png,, 0
		;

		Menu, ClickToCall, Color, 0xBDDBFF
		Menu, ClickToCall, Show,%	A_GuiX,%	A_GuiY
	}
	return
}

;	Ligações
	tip:
		if ( StrLen( m1 ) > 0 )
			Goto, Call1
		if ( StrLen( m2 ) > 0 )
			Goto,	Call2
		if ( StrLen( m3 ) > 0 )
			Goto,	Call3
	return

	Call1:
		Convert.Call( "http://192.9.200.245/portal/api/LigacaoAutomatica/executarLigacaoNumero/?origem=" ramal "&destino="	m1 )
		Menu, ClickToCall, DeleteAll
		ra := ramal
		de := m1
		; goto	feedback
	return

	Call2:
		Convert.Call( "http://192.9.200.245/portal/api/LigacaoAutomatica/executarLigacaoNumero/?origem=" ramal "&destino="	m2 )
		Menu, ClickToCall, DeleteAll
		ra := ramal
		de := m2
		; goto	feedback
	return

	Call3:
		Convert.Call( "http://192.9.200.245/portal/api/LigacaoAutomatica/executarLigacaoNumero/?origem=" ramal "&destino="	m3 )
		Menu, ClickToCall, DeleteAll
		ra := ramal
		de := m3
		; goto	feedback
	return

	feedback:
		; feedback_ctc(ra,de,tnome)
	return
;

GuiClose:
	ExitApp
	2GuiClose:
		Gui,	2:Destroy
	3GuiClose:
		Gui,	3:Destroy
	4GuiClose:
		Ok:
			Gui,	4:Destroy
	older =
	Gui,	mapa:Destroy
return