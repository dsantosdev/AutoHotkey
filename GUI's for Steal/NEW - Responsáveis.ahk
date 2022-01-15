/*
	* * * Compile_AHK SETTINGS BEGIN * * *
	[AHK2EXE]
		Exe_File=C:\users\dsantos\desktop\executáveis\NEW - Responsáveis.exe
		Created_Date=1
	[VERSION]
		Set_Version_Info=1
		Company_Name=Heimdall
		File_Description=
		File_Version=0.0.0.1
		Inc_File_Version=1
		Product_Name=NEW - Responsáveis
		Product_Version=1.1.33.2
		Set_AHK_Version=1
	* * * Compile_AHK SETTINGS END * * *
*/


;	Includes
	#Include ..\class\array.ahk
	;#Include ..\class\base64.ahk
	;#Include ..\class\convert.ahk
	;#Include ..\class\cor.ahk
	;#Include ..\class\dguard.ahk
	;#Include ..\class\functions.ahk
	#Include ..\class\gui.ahk
	; #Include ..\class\listview.ahk
	;#Include ..\class\mail.ahk
	;#Include ..\class\safedata.ahk
	#Include ..\class\sql.ahk
	#Include ..\class\string.ahk
	;#Include ..\class\windows.ahk
;

;	-Arrays
	ids_inseridos	:=	[]
	_unidades		:=	{}
;

;	-Configurações
	#SingleInstance, Foce

	; image_list :=  IL_Create( 1 , , 1 )
	; LV_SetImageList( image_list )
	; IL_Add( image_list, "C:\Dih\zIco\Blue\w.png" , "0xFFFFFF" , 1)
	; IL_Add( image_list, "C:\Dih\zIco\Blue\m.png" , "0xFFFFFF" , 1)

	conf_text			=	0x1000 ReadOnly
	cor_groupbox_tex	=	c4cc2c1
	conf_botões			=	Disabled
	conf_listview		=	Grid	AltSubmit
;

;	-Variáveis
	
;

;	-Login
	
;

;	-Interface
	Gui, -Caption -Border
	Gui.Cores()
	Gui.GroupBox(	"Seleção de Exibição" 
				,	"x2		y9		w290	h940	Center"
				,	
				,	cor_groupbox_tex	"	Bold	S10"	)
				Gui.Font()
		Gui,	Add,	Radio,		x12		y29		w130	h20		Center	0x1000 Checked	,	Operador
		Gui,	Add,	Radio,		x152	y29		w130	h20		Center	0x1000			,	Geral

		Gui.GroupBox(	"Unidades" 
					,	"x2		y59		w290	h890"
					,	
					,	cor_groupbox_tex	"	Bold	S10"	)
					Gui.Font()
			Gui,	Add,	ListView,	x12		y79		w270	h860	%conf_listview%	gLV_Unidades	vLV_Unidades	,	Local|Sigla|id_local|address
				Gosub, sql_unidades
				LV_ModifyCol( 1 , 199)
				LV_ModifyCol( 2 , 50 )
				LV_ModifyCol( 3 , 0 )
				LV_ModifyCol( 4 , 0 )

	Gui.GroupBox(	"Nome da Unidade Selecionada - ID unidade" 
				,	"x290	y5		w970	h714"
				,	
				,	cor_groupbox_tex	"	Bold	S15"	)
		Gui.Font( "S9 cWhite" )
		Gui,	Add,	Text,			x302	y39		w460	h80		%conf_text%	vEndereço_Unidade
		Gui,	Add,	Text,			x782	y39		w230	h20		%conf_text%
		Gui,	Add,	Text,			x1022	y39		w230	h20		%conf_text%
		Gui,	Add,	Text,			x782	y69		w230	h20		%conf_text%
		Gui,	Add,	Text,			x1022	y69		w230	h20		%conf_text%
		Gui,	Add,	Text,			x782	y99		w230	h20		%conf_text%
		Gui,	Add,	Text,			x1022	y99		w230	h20		%conf_text%

		; Tela toda
	; Gui.GroupBox(	"Responsáveis e Emergência" 
				; ,	"x290	y129	w970	h330"
				; ,	""
				; ,	cor_groupbox_tex	"	Bold	S10"	)
			; Gui.Font( "S9 cGray" )
		; Gui,	Add,	Edit,			x300	y149	w300	h20
			; Gui.Font( "S9 cWhite" )
		; Gui,	Add,	Text,			x300	y369	w950	h80		%conf_text%											,%	obs_responsável
			; Gui.Font()
	
	Gui.GroupBox(	"Responsáveis e Emergência" 
				,	"x290	y129	w970	h330"
				,	""
				,	cor_groupbox_tex	"	Bold	S10"	)
			Gui.Font( "S9 cGray" )
		Gui,	Add,	Edit,			x300	y149	w465	h20						vf_responsavel		gf_responsavel
			Gui.Font( "S9 cWhite" )
		Gui,	Add,	Text,			x300	y369	w465	h80		%conf_text%											,%	obs_responsável
			Gui.Font()
		Gui,	Add,	ListView,		x300	y179	w465	h180	%conf_listview%	vLV_Responsaveis					,	Nome|Cargo|Matrícula|Telefone|Telefone|Ramal|Setor|Unidade|Sexo|Situação
			LV_ModifyCol( 1 , 150 )
			LV_ModifyCol( 2 , 100 )
			LV_ModifyCol( 3 , 60 )
			; LV_ModifyCol( 3 , 50 )
			LV_ModifyCol( 4 , 0 )
			; LV_ModifyCol( 4 , 120 )
			LV_ModifyCol( 5 , 0 )
			; LV_ModifyCol( 5 , 120 )
			LV_ModifyCol( 6 , 0 )
			; LV_ModifyCol( 6 , 50 )
			LV_ModifyCol( 7 , 0 )
			; LV_ModifyCol( 7 , 100 )
			LV_ModifyCol( 8 , 0 )
			; LV_ModifyCol( 8 , 150 )
			LV_ModifyCol( 9 , 0 )
			LV_ModifyCol( 10 , 80 )

	Gui.GroupBox(	"Autorizados" 
				,	"x772	y129	w490	h330"
				,	""
				,	cor_groupbox_tex	"	Bold	S10"	)
			Gui.Font( "S9 cGray" )
		Gui,	Add,	Edit,			x782	y149	w470	h20				
			Gui.Font( "S9 cWhite" )
		Gui,	Add,	Text,			x782	y369	w470	h80		%conf_text%	,%	obs_autorizado
			Gui.Font()
		Gui,	Add,	ListView,		x782	y179	w470	h180	%conf_listview%	vLV_Autorizados			,	Nome|Cargo|Matrícula|Telefone|Telefone|Ramal|Setor|Unidade|Sexo|Situação
			LV_ModifyCol( 1 , 150 )
			LV_ModifyCol( 2 , 100 )
			LV_ModifyCol( 3 , 60 )
			; LV_ModifyCol( 3 , 50 )
			LV_ModifyCol( 4 , 0 )
			; LV_ModifyCol( 4 , 120 )
			LV_ModifyCol( 5 , 0 )
			; LV_ModifyCol( 5 , 120 )
			LV_ModifyCol( 6 , 0 )
			; LV_ModifyCol( 6 , 50 )
			LV_ModifyCol( 7 , 0 )
			; LV_ModifyCol( 7 , 100 )
			LV_ModifyCol( 8 , 0 )
			; LV_ModifyCol( 8 , 150 )
			LV_ModifyCol( 9 , 0 )
			LV_ModifyCol( 10 , 80 )

	
	Gui.GroupBox(	"E-Mails" 
				,	"x290	y459	w970	h260	Center"
				,	""
				,	cor_groupbox_tex	"	Bold	S10"	)
			Gui.Font( "S9 cGray" )
		Gui,	Add,	Edit,			x302	y479	w470	h20				
		Gui,	Add,	Text,			x782	y479	w470	h230	%conf_text%	,%	exibe_email
			Gui.Font()
		Gui,	Add,	ListView,		x302	y509	w470	h200				,	ListView
	
	Gui.GroupBox(	"Mapas" 
				,	"x290	y719	w480	h230"
				,	""
				,	cor_groupbox_tex	"	Bold	S10"	)
				Gui.Font()
		Gui,	Add,	Button,			x302	y740	w100	h20		vMapa_Balança			%conf_botões%	gMapa_Balança			,	Balança
		Gui,	Add,	Button,			x302	y766	w100	h20		vMapa_Administrativo	%conf_botões%	gMapa_Administrativo	,	Administrativo
		Gui,	Add,	Button,			x302	y792	w100	h20		vMapa_Defensivos		%conf_botões%	gMapa_Defensivos		,	Defensivos
		Gui,	Add,	Button,			x302	y818	w100	h20		vMapa_Fertilizantes		%conf_botões%	gMapa_Fertilizantes		,	Fertilizantes
		Gui,	Add,	Button,			x302	y844	w100	h20		vMapa_Loja				%conf_botões%	gMapa_Loja				,	Loja
		Gui,	Add,	Button,			x302	y870	w100	h20		vMapa_Supermercado		%conf_botões%	gMapa_Supermercado		,	Supermercado
		Gui,	Add,	Button,			x302	y896	w100	h20		vMapa_AFC				%conf_botões%	gMapa_AFC				,	AFC
		Gui,	Add,	Button,			x302	y922	w100	h20		vMapa_Casa				%conf_botões%	gMapa_Casa				,	Casa
		Gui,	Add,	Picture,		x432	y739	w320	h200											gExibir_Mapa			,	C:\Users\dsantos\Desktop\AutoHotkey\Testes - Descartáveis\interface.jpg

	Gui.GroupBox(	"Eventos Especiais" 
				,	"x770	y719	w490	h230"
				,	""
				,	cor_groupbox_tex	"	Bold	S10"	)
			Gui.Font( "S9 cGray" )
		Gui,	Add,	Edit,			x782	y739	w470	h20				
			Gui.Font( "S9 cWhite" )
		Gui,	Add,	Text,			x782	y859	w470	h80		%conf_text%	,%	exibe_evento_especial
			Gui.Font()
		Gui,	Add,	ListView,		x782	y769	w470	h90					,	ListView

	; Gui,	Show,								x0	y0,	Central do Operador
	Gui,	Show,								x1917	y0,	Central do Operador
	return
;

;	-Code
	;	SQL's
		sql_unidades:
			s_unidades =
				(
				SELECT
					 [nome]
					,[sigla]
					,[id]		--	usado para verificar se já consta na lista de unidades
					,[id_local]
					,[endereco]
					,[id_unico]	--	por hora, sem uso
				FROM
					[Cotrijal].[dbo].[unidades]
				ORDER BY
					1
				)
			sql_unidades := sql( s_unidades , 3 )
			Loop,% sql_unidades.count()-1	{
				if (array.inarray( ids_inseridos , sql_unidades[ A_Index+1 , 3 ] ) = 0	; se não consta ou é unidade da sede adiciona
				||	sql_unidades[ A_Index+1 , 3 ] = 1	)
					ids_inseridos.Push( sql_unidades[ A_Index+1 , 3 ] )					; insere o id no array
				Else																	; se constar, passa para o próximo
					Continue
				LV_Add(	""
					,	Format( "{:T}" , sql_unidades[ A_index+1 , 1 ] )
					,	sql_unidades[ A_index+1 , 2 ]
					,	sql_unidades[ A_index+1 , 4 ]
					,	sql_unidades[ A_index+1 , 5 ]	)
			}
		Return

		sql_responsáveis:	
			s_unidades =
				(
				SELECT
					nm_razao_social,
					fone,
					celular,
					dn_cargo,
					dn_setor,
					ramal,
					numcad,
					sexo
				FROM
					cad_funcionarios
				WHERE
						cd_local = '01.02.07'
					AND situacao NOT IN ( 7, 23, 33 )
				)
			sql_unidades := sql( s_unidades , 3 )
			Loop,% sql_unidades.count()-1	{
				if (array.inarray( ids_inseridos , sql_unidades[ A_Index+1 , 3 ] ) = 0	; se não consta ou é unidade da sede adiciona
				||	sql_unidades[ A_Index+1 , 3 ] = 1	)
					ids_inseridos.Push( sql_unidades[ A_Index+1 , 3 ] )					; insere o id no array
				Else																	; se constar, passa para o próximo
					Continue
				LV_Add(	""
					,	Format( "{:T}" , sql_unidades[ A_index+1 , 1 ] )
					,	sql_unidades[ A_index+1 , 2 ]
					,	sql_unidades[ A_index+1 , 4 ]
					,	sql_unidades[ A_index+1 , 5 ]	)
			}
		Return
		
		sql_colaboradores:	;	N
			s_colaboradores =
				(
				SELECT
					nm_razao_social,
					fone,
					celular,
					dn_cargo,
					dn_setor,
					ramal,
					numcad,
					sexo
				FROM
					cad_funcionarios
				WHERE
						cd_local = '01.02.07'
					AND situacao NOT IN ( 7, 23, 33 )
				)
			sql_unidades := sql( s_unidades , 3 )
			Loop,% sql_unidades.count()-1	{
				if (array.inarray( ids_inseridos , sql_unidades[ A_Index+1 , 3 ] ) = 0	; se não consta ou é unidade da sede adiciona
				||	sql_unidades[ A_Index+1 , 3 ] = 1	)
					ids_inseridos.Push( sql_unidades[ A_Index+1 , 3 ] )					; insere o id no array
				Else																	; se constar, passa para o próximo
					Continue
				LV_Add(	""
					,	Format( "{:T}" , sql_unidades[ A_index+1 , 1 ] )
					,	sql_unidades[ A_index+1 , 2 ]
					,	sql_unidades[ A_index+1 , 4 ]
					,	sql_unidades[ A_index+1 , 5 ]	)
			}
		Return

	;

	;	Goto
		Exibir_Mapa:

		Return

		;	Seleciona ListViews
			LV_Unidades:
				if ( A_GuiEvent = "Normal" )	{
					Gui, Submit, NoHide
					OutputDebug % A_GuiEvent
					Gui, ListView, LV_Unidades
					LV_GetText( _unidade
							,	A_EventInfo, 1 )
					LV_GetText( _sigla
							,	A_EventInfo, 2 )
					LV_GetText( _id_local
							,	A_EventInfo, 3 )
					LV_GetText( _address
							,	A_EventInfo, 4 )
					OutputDebug % _unidade "`n" _sigla "`n" _id_local "`n" _address

					;	Adiciona o endereço da unidade
						GuiControl, , Endereço_Unidade,%	StrReplace( FORMAT( "{:T}" , _address ) , ", " , "`n" )

					;	Adiciona número da corneta e interfone
						; GuiControl, , Endereço_Unidade,%	StrReplace( FORMAT( "{:T}" , _address ) , ", " , "`n" )

						; Adiciona os horários do portão
						; GuiControl, , Endereço_Unidade,%	StrReplace( FORMAT( "{:T}" , _address ) , ", " , "`n" )
					Gosub, preenche_responsaveis
					Goto, preenche_autorizados
				}
				Else
					Return
			Return
		;

		;	Preenche ListViews
			preenche_responsaveis:
				Gui, ListView, LV_Responsaveis
				LV_Delete()
				; MsgBox % A_DefaultListView
				s_responsaveis =
					(
					SELECT
						 [nome]			--	1
						,[cargo]		--	2
						,[matricula]	--	3
						,[telefone1]	--	4
						,[telefone2]	--	5
						,[ramal]		--	6
						,[setor]		--	7
						,[local]		--	8
						,[sexo]			--	9
						,[situacao]		--	10
					FROM
						[ASM].[dbo].[_colaboradores]
					WHERE
						[id_local] = '%_id_local%'
					AND
						([cargo] LIKE 'gere`%' OR [cargo] LIKE 'coord`%')
					ORDER BY
						[cargo]
					DESC
					)
					s_responsaveis := sql( s_responsaveis , 3 )
					Loop,% s_responsaveis.count()-1	{
						LV_Add(	"icon"
							,	String.Name(s_responsaveis[ A_Index+1 , 1 ])
							,	String.Cargo(s_responsaveis[ A_Index+1 , 2 ])
							,	s_responsaveis[ A_Index+1 , 3 ]
							,	String.Telefone(s_responsaveis[ A_Index+1 , 4 ])
							,	String.Telefone(s_responsaveis[ A_Index+1 , 5 ])
							,	s_responsaveis[ A_Index+1 , 6 ]
							,	s_responsaveis[ A_Index+1 , 7 ]
							,	s_responsaveis[ A_Index+1 , 8 ]
							,	s_responsaveis[ A_Index+1 , 9 ]
							,	s_responsaveis[ A_Index+1 , 10 ]	)
					}
			Return

			preenche_autorizados:
				Gui, ListView, LV_autorizados
				LV_Delete()
				; MsgBox % A_DefaultListView
				s_autorizados =
					(
					SELECT
						 c.[nome]		--	1
						,c.[cargo]		--	2
						,c.[matricula]	--	3
						,c.[telefone1]	--	4
						,c.[telefone2]	--	5
						,c.[ramal]		--	6
						,c.[setor]		--	7
						,c.[local]		--	8
						,c.[sexo]		--	9
						,c.[situacao]	--	10
					FROM
						[Cotrijal].[dbo].[autorizados] a
					LEFT JOIN
						[ASM].[dbo].[_colaboradores] c
						ON
							a.[matricula] = c.[matricula]
					WHERE
						a.[id_local] = '%_id_local%'
					ORDER BY
						c.[nome]
					)
					Clipboard := s_autorizados
					s_autorizados := sql( s_autorizados , 3 )
					Loop,% s_autorizados.count()-1	{
						LV_Add(	"icon"
							,	String.Name(s_autorizados[ A_Index+1 , 1 ])
							,	String.Cargo(s_autorizados[ A_Index+1 , 2 ])
							,	s_autorizados[ A_Index+1 , 3 ]
							,	String.Telefone(s_autorizados[ A_Index+1 , 4 ])
							,	String.Telefone(s_autorizados[ A_Index+1 , 5 ])
							,	s_autorizados[ A_Index+1 , 6 ]
							,	s_autorizados[ A_Index+1 , 7 ]
							,	s_autorizados[ A_Index+1 , 8 ]
							,	s_autorizados[ A_Index+1 , 9 ]
							,	s_autorizados[ A_Index+1 , 10 ]	)
					}
			Return
		;

		;	Filtro
			f_responsavel:
				Gui, Submit, NoHide
				; MsgBox % f_responsavel
				; OutputDebug % f_responsavel
				; if ( f_responsavel = "Digite aqui para filtrar os resultados..." )
					; GuiControl, , f_responsavel
			Return
		;

		;	Mapas
			Mapa_Balança:

			Return

			Mapa_Administrativo:

			Return

			Mapa_Defensivos:

			Return

			Mapa_Fertilizantes:

			Return

			Mapa_Loja:

			Return

			Mapa_Supermercado:

			Return

			Mapa_AFC:

			Return

			Mapa_Casa:

			Return
		;
	;
;

;	-GuiClose
	ESC::
		GuiClose:
		ExitApp

	F5::
		Reload
;

;	Atalhos
;