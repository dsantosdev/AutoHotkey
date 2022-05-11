File_Version=0.0.0.0
Save_To_Sql=0
;@Ahk2Exe-SetMainIcon C:\AHK\icones\_gray\2resp.ico

;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\auth.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cameras.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\date.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\file.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\folder.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\sync_data.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

/*	Bancos de Dados utilizados

*/

;	Configurações
	#SingleInstance, Force

	show_tooltip	:=	A_Args[1]	;	recebe o argumento 1 para exibir
		if ( A_UserName = "dsantos" )
			show_tooltip = 1
		CoordMode, ToolTip, Screen

	if A_IsCompiled
		ext	=	exe
	Else
		ext = ahk

;

;	Code
	New	Iris		;	MIGRAR PARA AS CLASSES NOVAS
	; #NoTrayIcon
	SetBatchLines, -1

; GUI de Seleção
	Gui, destroy
	;	Precisa definir as cores
		Gui, Color, %bggui%	
		Gui, Color, , %bgctrl%
	;
	Gui.Font( "1:", "c9dff80", "Bold", "s10" )
	Gui, 1:Add, Text, x5 y5, 																																							Buscar unidade 
	Gui, 1:Add, Text, Section x252 y5
	Gui, 1:font
	Gui, 1:Add, Edit, 		 x140						yp							w109	h20	vb_unidade	gUnidades
	Gui, 1:Add, ListView,%	"xs-252						yp+30 						w300					gSelecionaUnidade NoSortHdr 0x3 h"( A_ScreenHeight - 120 ) ,ID|UNIDADE
	Gui, 1:Add, Button,% 	"x2							y" A_ScreenHeight - 82 "	w246	h40				gGuiClose", 												Fechar
		LV_ModifyCol(1, 0)
		LV_ModifyCol(2, Center)
		Gosub Unidades	;	Carrega as unidades para a lista
	Gui, 1:  -Border
	Gui, 1:Show,%			"x" A_ScreenWidth - 256 "	y0							w250	h" A_ScreenHeight - 40 , 													Unidades Cotrijal, GUI-1
	GuiControl, 1:Focus, b_unidade
return

Unidades:
	Gui, 1:Submit, NoHide
	LV_Delete()
	s =
		(
			SELECT
				[id],
				[local]
			FROM
				[Sistema_Monitoramento].[dbo].[id locais]
			WHERE
				(id	<> '998' AND
				 id	<> '997' AND
				 id	<> '996')
			ORDER by
				2
		)
	unidades := sql( s, 3 )

	Loop,% unidades.Count()-1
		if( b_unidade != "" )	{	;	parte da pesquisa dinâmica
			if( InStr( unidades[A_Index+1, 2], b_unidade ) > 0 )
				LV_Add( "", unidades[A_Index+1, 1], unidades[A_Index+1, 2] )
		}
		Else
			LV_Add( "", unidades[A_Index+1, 1], unidades[A_Index+1, 2] )
return

SelecionaUnidade:
	Gui, 1:Submit, NoHide
	Gui, 1:+Disabled
	menos3	=	0	;	ID da unidade com menos de 3 dígitos
	Gui, 2:Destroy
	Gui, 3:Destroy
	Gui, login_senhas:Destroy
	Process, Close, MDMapas.exe

	RowNumber	=	0
	Loop	{
		RowNumber	:=	LV_GetNext( RowNumber )
		if !RowNumber
			break
		LV_GetText( unidade,	RowNumber, 1 )
		LV_GetText( unidadex,	RowNumber, 2 )
	}

	if( StrLen( unidade ) < 3 )	{
		unidade := "0" . unidade
		menos3 = 1
	}

		Gosub	Responsaveis
return

Responsaveis:
	id := LTrim( unidade, "0" )
	; Gui.Cores( "", "dbdbdb", "425942" )
	Gui, 2:Add, ListView,% "x0 y10 w" A_ScreenWidth-260 " h" A_ScreenHeight-50 " v_responsaveis geditor Altsubmit", Nome|Matricula|Cargo|Telefone 1|Telefone 2|Unidade
		Gosub Sql_responsaveis
	;{																								Lembretes
									;{	Acesso Portões	14/12/2018
	;{																								Gui	Acesso aos portões
	Gui, 2:-Border
	Gui, 2:Show,% "x0 y0 w" A_ScreenWidth-262 " h" A_ScreenHeight-40
	
	Gui, 1:-Disabled
return

sql_responsaveis:
	Gui, 2:Default
	LV_Delete()
	s	=
		(
			SELECT
				b.[Nome],
				a.[matricula],
				b.[cargo],
				b.[telefone1],
				b.[telefone2],
				a.[unidade],
				a.[nome] as nome2,
				a.[telefone 1],
				a.[telefone 2]
			FROM
				[Sistema_Monitoramento].[dbo].[contatos] a
			LEFT JOIN
				[ASM].[DBO].[_colaboradores]	b
			ON
				a.[matricula] = b.[matricula]
			WHERE
				[unidade]	=	'%id%'	AND
				a.[ordem] != 'm'
			ORDER BY
				[ordem], [nome]
		)
	funcionarios := sql( s, 3 )

	Loop,%	funcionarios.Count()-1
		LV_Add( ""
				, funcionarios[A_Index+1, 1]	=	""
												?	funcionarios[A_Index+1, 7]	;	Nome da Brigada Militar
												:	funcionarios[A_Index+1, 1]	;	Nome do banco da cotrijal
				, funcionarios[A_Index+1, 2]
				, String.Cargo( funcionarios[A_Index+1, 3] )	=	""
																?	"Emergência"
																:	funcionarios[A_Index+1, 3]
				, funcionarios[A_Index+1, 1]	=	""
												?	String.Telefone( funcionarios[A_Index+1, 8] )
												:	String.Telefone( funcionarios[A_Index+1, 4] )
				, funcionarios[A_Index+1, 1]	=	""
												?	String.Telefone( funcionarios[A_Index+1, 9] )
												:	String.Telefone( funcionarios[A_Index+1, 5] )
				, funcionarios[A_Index+1, 6] )
	LV_ModifyCol()
	LV_ModifyCol(2, 100)
	LV_ModifyCol(6, 50)
Return

editor:
	Gui, Edita:Destroy
	Gui, 2:Submit, nohide
	if (A_GuiControlEvent	= "RightClick"
	&&	A_Eventinfo			!= 0	) {
		LV_GetText( del_nome,		A_EventInfo, "1" )
		LV_GetText( del_matricula,	A_EventInfo, "2" )
		LV_GetText( del_tel1,		A_EventInfo, "4" )
		LV_GetText( del_tel2,		A_EventInfo, "5" )
		LV_GetText( del_unidade,	A_EventInfo, "6" )
		Gui, edita:Add, Text,	x5		y10		w100	h30	,								Matricula
		Gui, edita:Add, Text,	x5		y40		w100	h30	,								Telefone 1
		Gui, edita:Add, Text,	x5		y70		w100	h30	,								Telefone 2
		Gui, edita:Add, Text,	x5		y100	w100	h30	,								Nome BM
		Gui, edita:Add, Edit,	x105	y10		w300	h30		ve_matricula gsearch_data,	999999 < - Para BM
		Gui, edita:Add, Edit,	x105	y40		w300	h30		ve_tel1	Disabled, 			Telefone 1 para BM
		Gui, edita:Add, Edit,	x105	y70		w300	h30		ve_tel2	Disabled, 			Telefone 2 para BM
		Gui, edita:Add, Edit,	x105	y100	w300	h30		ve_bm	Disabled, 			Nome para BM
		Gui, edita:Add, Text,	x5		y140	w400	h210	ve_not_bm	0x1000
		Gui, edita:Add, Button,	x5		y360	w190	h30		gedita,				 		Editar`n%del_matricula% - %del_nome%
		Gui, edita:Add, Button,	x215	y360	w190	h30		gdeleta,					Remover`n%del_matricula% - %del_nome%
		Gui, edita:Add, Button,	x5		y390	w400	h30		gnovo	v_add_new,			Adicionar
		Gui, edita:Show
		action=
	}
Return

search_data:
	search_delay()
	Gui, Edita:Submit, NoHide
	if( e_matricula = 999999 ) {
		GuiControl, edita:Enable,	e_tel1
		GuiControl, edita:Enable,	e_tel2
		GuiControl, edita:Enable,	e_bm
		if ( del_matricula != 999999 ) {
			del_tel1 =
			del_tel2 =
		}
		GuiControl, edita:,			e_tel1,%	del_tel1
		GuiControl, edita:,			e_tel2,%	del_tel2
		GuiControl, edita:,			e_bm,		Brigada Militar
		Gui, Edita:Submit, NoHide
		mat		:= "999999"
		cargo	:= "Emergência"
		ordem	:= "k"
		GuiControl, edita:, e_not_bm,% "Verifique os dados antes de prosseguir`n`nMatrícula:`n`t" at
									.	"`nCargo:`n`t" cargo
									.	"`nTelefone 1:`n`t" del_tel1
									.	"`nTelefone 2:`n`t" del_tel2
		Return
	}
	s =
		(
			SELECT
				 [nome]
				,[matricula]
				,[cargo]
				,[telefone1]
				,[telefone2]
			FROM
				[ASM].[dbo].[_colaboradores] 
			WHERE
				[matricula] = '%e_matricula%'
		)
	colaborador	:=	sql( s, 3 )
	if colaborador.Count()-1 = 0
		MsgBox "Colaborador não encontrado, verifique a matrícula!"
	Else	{
		nome	:=	colaborador[2,1]
		mat		:=	colaborador[2,2]
		cargo	:=	colaborador[2,3]
		e_tel1	:=	colaborador[2,4]
		e_tel2	:=	colaborador[2,5]
		if ( InStr( colaborador[2,2], "Coordenador" ) ){
			if ( InStr( colaborador[2,2], "administrativo" ) )
				ordem = b
			if ( InStr( colaborador[2,2], "Operacional" ) )
				ordem = c
			if ( InStr( colaborador[2,2], "Trr" ) )
				ordem = c
			if ( InStr( colaborador[2,2], "projeto Social" ) )
				ordem = c
			if ( InStr( colaborador[2,2], "De Loja" ) )
				ordem = e
			if ( InStr( colaborador[2,2], "Supermercado" ) )
				ordem = f
			if ( InStr( colaborador[2,2], "Centro" ) )
				ordem = g
		}
		else if (InStr( colaborador[2,2], "Gerente" )
		||	InStr( colaborador[2,2], "Superintendente" ) )
			ordem = a
		Else
			ordem = z
		GuiControl, edita:, e_not_bm,% "Verifique os dados antes de prosseguir`n`nNome:`n`t" nome "`nMatrícula:`n`t" mat "`nCargo:`n`t" cargo "`nTelefone 1:`n`t" tel1 "`nTelefone 1:`n`t" tel2 "`nOrdem = " ordem
	}
Return

edita:
	action++
deleta:
	action++
novo:
	action++
	Gui, Edita:Submit, NoHide
	if (!nome
	&&	mat = "999999" )
		nome := e_bm
	if ( action = 3 ) {	;	edita
		s =
			(
				UPDATE [Sistema_Monitoramento].[dbo].[contatos]
				SET [nome]		= '%nome%',
					[matricula]	= '%mat%',
					[cargo]		= '%cargo%',
					[telefone 1]= '%e_tel1%',
					[telefone 2]= '%e_tel2%',
					[Ordem]		= '%ordem%'
				WHERE
					[matricula]	= '%del_matricula%'
				AND
					[unidade]	= '%del_unidade%'
			)
		sql( s, 3 )
	}
	Else if ( action = 2 ) {	;	deleta
		s = 
			(
				DELETE
				FROM
					[Sistema_Monitoramento].[dbo].[contatos]
				WHERE
					[Matricula] = '%del_matricula%'
				AND
					[unidade]	= '%del_unidade%'
			)
		sql( s, 3 )
	}
	Else if ( action = 1 ) {	;	adiciona
		s =
			(
				INSERT INTO
					[Sistema_Monitoramento].[dbo].[contatos]
					([nome],[matricula],[cargo],[telefone 1],[telefone 2],[Ordem],[unidade])
				VALUES
					('%nome%','%mat%','%cargo%','%e_tel1%','%e_tel2%','%ordem%','%del_unidade%')
			)
		sql( s, 3 )
	}
	clipboard:=sql_lq
	Gosub	sql_responsaveis
	Gui, edita:Destroy
Return

Abre_Mapa:			;{	22/12/2018
	unidade :=	LTrim(unidade, "0")
	Run, C:\Dguard Advanced\MDMapas.exe "%con%" "%ora%" "%unidade%"
	;~ Run, ..\1 - Core\a_mdMapas.ahk "%con%" "%ora%" "%unidade%"
return

Login_Senhas:			;{	03/12/2020
	Gui.Cores("login_senhas")
		Gui,	login_senhas:Font,	S11 Bold cYellow
	Gui,	login_senhas:Add,	Text, 	x10		y10		w450	h40	+Center					,	A senha de uso único só deve ser gerada em casos de emergência:
	Gui,	login_senhas:Add,	Text, 	x10		y200	w450	h40									,	Seu coordenador será notificado do compartilhamento dessa senha. Justifique abaixo.
		Gui,	login_senhas:Font,	S9 Bold cWhite
	Gui,	login_senhas:Add,	Text, 	x10		y50		w450	h70	0x1000					,	Onde:`n`tNão seja possível fazer o desarme remoto da central.`n`tQue não haja ninguém com senha no local.`n`tQue o desarme seja devidamente autorizado por um dos responsáveis da unidade`, preferencialmente com registro por e-mail.
	Gui,	login_senhas:Add,	Text, 	x10		y130	w450	h60	0x1000					,	Necessitando registro de:`n`tQuem autorizou.`n`tPorque foi gerado.`n`tPara quem foi passado a senha.
	Gui,	login_senhas:Add,	Text,	 x10		y300	w75		h30									,	Usuario:
	Gui,	login_senhas:Add,	Text,	 x240	y300	w75		h30									,	Senha:
		Gui,	login_senhas:Font
	Gui,	login_senhas:Add,	Edit,	 x10		y240	w450	h50	vreason
	Gui,	login_senhas:Add,	Edit,	 x65		y300	w150	h20	vuser_
	Gui,	login_senhas:Add,	Edit,	 x285	y300	w150	h20	vsenha_	Password
	Gui,	login_senhas:Add,	Button, xm					w220	glogin_senhasok			,	Confirmar
	Gui,	login_senhas:Add,	Button, xp+230			w220	glogin_senhasGuiClose	,	Cancelar
	Gui,	login_senhas:Show,,	Justificativa
return

login_senhasGuiClose:
	Gui,	login_senhas:Destroy
return

login_senhasok:
	Gui,	login_senhas:Submit,	NoHide
	if(strlen(reason)<10)	{
		MsgBox	Motivo com caracteres insuficientes
		return
		}
		Gui,	login_senhas:Destroy
		if(StrLen(user_)=0 or StrLen(senha_)=0)
			auth.login("","","","mdresp")
		else
			auth.login("",user_,senha_,"mdresp")
		SetTimer,	Senhas_Unicas, 100
	return	;}
	Senhas_Unicas:		;{	03/12/2020
		if(InStr(autenticou,"1")=0 or autenticou="")
			return
		SetTimer,	Senhas_Unicas, Off
		senha:=Iris.random_pass(unidade,reason)
		r:="INSERT INTO [ASM].[Logs].[dbo].[Log_ASM] ([data],[software],[user],[descricao],[local],[cmp1]) VALUES ('"	datetime()	"','MDResp','"	SubStr(autenticou,3)	"','"	reason	"','"	unidade	"','"	senha	"')"
		sql(r)
		MsgBox, ,Senha de Uso Único, % "Senha:`n`t"	senha "`nDisponibilizada em:`n`t" datetime()	"`nPara o usuário:`n`t" SubStr(autenticou,3) "`nDa central de id:`n`t"	unidade	"`nDevido a:`n`t" reason ;	"`n" sql_le "`n" sql_lq
		senha=
		reason=
		autenticou=
return

2GuiCLose:
	Gui, 2:Destroy
	Process, Close, MDMapas.exe
	Gui,	login_senhas:Destroy
return
	Esc::
	GuiClose:
	Gui,	login_senhas:Destroy
	Process,Close,	MDMapas.exe
ExitApp

