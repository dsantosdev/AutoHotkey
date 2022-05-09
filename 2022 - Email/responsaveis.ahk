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

;@Ahk2Exe-SetMainIcon C:\AHK\icones\Heimdall Blue\report.ico

;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

;	-Arrays
	; ids_inseridos	:=	[]
	; _unidades		:=	{}
	; _responsaveis	:=	{}	;	noSql
;

;	-Configurações
	#SingleInstance, Foce

	image_list :=  IL_Create( 1 , , 1 )
	LV_SetImageList( image_list )
	IL_Add( image_list, "C:\AHK\icones\images\Blue\w.png" , "0xFFFFFF" , 1)
	IL_Add( image_list, "C:\AHK\icones\images\Blue\m.png" , "0xFFFFFF" , 1)

	conf_text			=	0x1000 ReadOnly
	cor_groupbox_tex	=	c4cc2c1
	conf_botões			=	Disabled
	conf_listview		=	Grid	AltSubmit
;

;	-Variáveis
	Global	Nome_da_Unidade
		,	limpa_contexto			;	Click to call
		,	numero_1				;	Click to call
		,	numero_2				;	Click to call
		,	numero_3				;	Click to call
		,	ramal					;	Click to call
	Gui.ScreenSizes()				;	Chama as variáveis para automatizar tamanho da gui
	operador		:=	operador()
	_operador		=	1			;	para o toggle
	tamanho_fonte	:=	1			;	fontes do e-mail
;

;	-Login
	
;

;	-Interface
	; Gui, -Caption -Border
	Gui.Cores()
	Gui.GroupBox(	"Seleção de Exibição" 
				,	"x2		y9		w290	h940	Center"
				,	
				,	cor_groupbox_tex	"	Bold	S10"	)
				Gui.Font()
		Gui,	Add,	Radio,		x12		y29		w130	h20		Center	0x1000 	v_operador1	gmuda_visualizacao	Checked	,	Operador
		Gui,	Add,	Radio,		x152	y29		w130	h20		Center	0x1000	v_operador2	gmuda_visualizacao			,	Geral

		Gui.GroupBox(	"Unidades" 
					; ,	"x2		y59		w290	h890"
					,	"x2		y59		w290	h790"
					,	
					,	cor_groupbox_tex	"	Bold	S10"	)
					Gui.Font()
			; Gui,	Add,	ListView,	x12		y79		w270	h860	%conf_listview%	gLV_Unidades	vLV_Unidades	,	Local|Sigla|Entreposto|id_local|address
			Gui,	Add,	ListView,	x12		y79		w270	h760	%conf_listview%	gLV_Unidades	vLV_Unidades	,	Local|Sigla|Entreposto|id_local|address
				Gosub, muda_visualizacao
				LV_ModifyCol( 1 , 199)
				LV_ModifyCol( 2 , 50 )
				LV_ModifyCol( 3 , 0 )
				LV_ModifyCol( 4 , 0 )
				LV_ModifyCol( 5 , 0 )

	Gui.GroupBox(	"Nome da Unidade Selecionada - ID unidade" 
				,	"x290	y5		w970	h714 vNome_da_Unidade"
				,	
				,	cor_groupbox_tex	"	Bold	S15"	)
		Gui.Font( "S9 cWhite" )
		Gui,	Add,	Text,			x302	y39		w460	h80		%conf_text%	vEndereço_Unidade
		Gui,	Add,	Text,			x782	y39		w230	h20		%conf_text%	vinterfone	Center
		Gui,	Add,	Text,			x1022	y39		w230	h20		%conf_text%	vcorneta	Center
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
			; LV_ModifyCol( 4 , 0 )
			LV_ModifyCol( 4 , 120 )
			LV_ModifyCol( 5 , 0 )
			; LV_ModifyCol( 5 , 120 )
			LV_ModifyCol( 6 , 0 )
			; LV_ModifyCol( 6 , 50 )
			LV_ModifyCol( 7 , 0 )
			; LV_ModifyCol( 7 , 100 )
			LV_ModifyCol( 8 , 0 )
			; LV_ModifyCol( 8 , 150 )
			LV_ModifyCol( 9 , 0 )
			; LV_ModifyCol( 10 , 80 )
			LV_ModifyCol( 10 , 0 )

	Gui.GroupBox(	"Autorizados" 
				,	"x772	y129	w490	h330"
				,	""
				,	cor_groupbox_tex	"	Bold	S10"	)
			Gui.Font( "S9 cGray" )
		Gui,	Add,	Edit,			x782	y149	w470	h20				
			Gui.Font( "S9 cWhite" )
		Gui,	Add,	Text,			x782	y369	w470	h80		%conf_text%	,%	obs_autorizado
			Gui.Font()
		Gui,	Add,	ListView,		x782	y179	w470	h180	%conf_listview%	vLV_Autorizados			,	Nome|Cargo|Matrícula|Telefone|Telefone|Ramal|Setor|Unidade|Sexo|Situação|Observação
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
			Gui.Font()
			Gui.Font( "S10 Bold " cor_groupbox_tex )
		; Gui,	Add,	Text,			x782	y479	w150	h20		%conf_text%						Center
		Gui,	Add,	Slider,			x782	y479	w150	h20		Range1-3		vtamanho_fonte	gtamanho_fonte
		Gui,	Add,	Text,			x932	y479	w150	h20		%conf_text%						Center			,	Tamanho da Fonte
			Gui.Font()
			Gui.Font( "S9 Bold" )
		Gui,	Add,	Edit,			x782	y509	w470	h200					vexibe_email
			Gui.Font()
		Gui,	Add,	ListView,		x302	y509	w470	h200	%conf_listview%	vlv_emails 		glv_emails	-HDR,	Assunto|Prévia|Importante
			LV_ModifyCol( 1 , 150 )
			LV_ModifyCol( 2 , 295 )
			LV_ModifyCol( 3 , 0 )
	
	; Gui.GroupBox(	"Mapas" 
		; 		,	"x290	y719	w480	h230"
		; 		,	""
		; 		,	cor_groupbox_tex	"	Bold	S10"	)
		; 		Gui.Font()
		; Gui,	Add,	Button,			x302	y740	w100	h20		vMapa_Balança			%conf_botões%	gMapa_Balança			,	Balança
		; Gui,	Add,	Button,			x302	y766	w100	h20		vMapa_Administrativo	%conf_botões%	gMapa_Administrativo	,	Administrativo
		; Gui,	Add,	Button,			x302	y792	w100	h20		vMapa_Defensivos		%conf_botões%	gMapa_Defensivos		,	Defensivos
		; Gui,	Add,	Button,			x302	y818	w100	h20		vMapa_Fertilizantes		%conf_botões%	gMapa_Fertilizantes		,	Fertilizantes
		; Gui,	Add,	Button,			x302	y844	w100	h20		vMapa_Loja				%conf_botões%	gMapa_Loja				,	Loja
		; Gui,	Add,	Button,			x302	y870	w100	h20		vMapa_Supermercado		%conf_botões%	gMapa_Supermercado		,	Supermercado
		; Gui,	Add,	Button,			x302	y896	w100	h20		vMapa_AFC				%conf_botões%	gMapa_AFC				,	AFC
		; Gui,	Add,	Button,			x302	y922	w100	h20		vMapa_Casa				%conf_botões%	gMapa_Casa				,	Casa
		; Gui,	Add,	Picture,		x432	y739	w320	h200											gExibir_Mapa			,	C:\Users\dsantos\Desktop\AutoHotkey\Testes - Descartáveis\interface.jpg

	; Gui.GroupBox(	"Eventos Especiais" 
		; 		,	"x770	y719	w490	h230"
		; 		,	""
		; 		,	cor_groupbox_tex	"	Bold	S10"	)
		; 	Gui.Font( "S9 cGray" )
		; Gui,	Add,	Edit,			x782	y739	w470	h20				
		; 	Gui.Font( "S9 cWhite" )
		; Gui,	Add,	Text,			x782	y859	w470	h80		%conf_text%	,%	exibe_evento_especial
		; 	Gui.Font()
		; Gui,	Add,	ListView,		x782	y769	w470	h90					,	ListView

	; Gui,	Show,								x0	y-1800,	Central do Operador
	Gui,	Show,								x0	y0,	Central do Operador
	; Gui,	Show,								x1917	y0,	Central do Operador
	return
;

;	-Code
	;	Goto
		Exibir_Mapa:

		Return

		;	Seleciona ListViews
			lv_unidades:
				if (A_GuiEvent = "Normal" )	{
					Gui, Submit, NoHide
					OutputDebug % A_GuiEvent
					Gui, ListView, LV_Unidades
					LV_GetText( _unidade
							,	A_EventInfo, 1 )
					LV_GetText( _sigla
							,	A_EventInfo, 2 )
					LV_GetText( _id_local
							,	A_EventInfo, 4 )
					LV_GetText( _address
							,	A_EventInfo, 5 )
					LV_GetText( _entreposto
							,	A_EventInfo, 3 )
					;	Adiciona o endereço da unidade
						GuiControl, , Endereço_Unidade,%	StrReplace( FORMAT( "{:T}" , _address ) , ", " , "`n" )

					;	Adiciona número da corneta
						GuiControl, , corneta,%	 StrLen( _entreposto ) = 1 ? "Corneta`t:`t30" _entreposto "2" : "Corneta`t:`t3" _entreposto "2"

					;	Adiciona número do interfone
						GuiControl, , interfone,% StrLen( _entreposto ) = 1 ? "Interfone`t:`t30" _entreposto "1" : "Interfone`t:`t3" _entreposto  "1"

					;	Adiciona os horários do portão
						; GuiControl, , Endereço

					;	Adiciona os Nome da unidade
						GuiControl, , Nome_da_Unidade,%	StrReplace( FORMAT( "{:T}" , _unidade ) , ", " , "`n" ) " - Unidade " _entreposto
					Gosub, preenche_responsaveis
					Goto, preenche_autorizados
				}
				Else
					Return
			Return
	
			lv_emails:
				if (A_GuiEvent = "Normal" )	{
					Gui, Submit, NoHide
					
					tamanho_fonte	:=	tamanho_fonte	= 1
														? 9
									: 	tamanho_fonte	= 2
														? 10
									: 	tamanho_fonte	= 3
														? 12
					Gui, ListView, LV_Emails
					LV_GetText( _assunto
							,	A_EventInfo, 1 )
					LV_GetText( _email
							,	A_EventInfo, 2 )
					LV_GetText( _importante
							,	A_EventInfo, 3 )

					If _importante {
						Gui, Font, S%tamanho_fonte% Bold
						GuiControl, Font, exibe_email
						GuiControl, +cDA4F49, exibe_email
					}
					Else {
						Gui, Font, S%tamanho_fonte% Bold
						GuiControl, Font, exibe_email
						GuiControl, +c000000, exibe_email
					}
					GuiControl, , exibe_email,%	_email
				}
				Else
					Return
			Return

			
		;

		;	Font Size
			tamanho_fonte:
				Gui, Submit, NoHide
				tamanho_fonte	:=	tamanho_fonte	= 1
													? 9
								: 	tamanho_fonte	= 2
													? 10
								: 	tamanho_fonte	= 3
													? 12
					Gui, Font, S%tamanho_fonte% Bold
				GuiControl, Font, exibe_email
				if _importante
					GuiControl, +cDA4F49, exibe_email
				Else
					GuiControl, +c000000, exibe_email
			Return

		;	Preenche ListViews	;	09/04/2022	- [ASM] | _responsaveis e _colaboradores

			preenche_unidades:
				Gui, ListView, LV_Unidades
				LV_Delete()
				default_list_view := A_DefaultListView	;	apenas para point break
				s_unidades =
					(
						SELECT
							[nome]
							,[sigla]
							,[entreposto]		--	usado para verificar se já consta na lista de unidades
							,[id_local]
							,[endereco]
							,[pkid]				--	por hora, sem uso
						FROM
							[Cotrijal].[dbo].[unidades]
						WHERE
							[Cliente_de_email] = 1
						%WHERE%
						ORDER BY
							1
					)

				sql_unidades := sql( s_unidades , 3 )

				Loop,%	sql_unidades.count()-1	{
					; if( array.InArray( ids_inseridos , sql_unidades[ A_Index+1 , 3 ] ) = 0	; se não consta ou é unidade da sede adiciona
					; ||	sql_unidades[ A_Index+1 , 3 ] = 1 )
					; 	ids_inseridos.Push( sql_unidades[ A_Index+1 , 3 ] )					; insere o id no array
					; Else																	; se constar, passa para o próximo
					; 	Continue
					LV_Add(	""
						,	Format( "{:T}" , sql_unidades[ A_index+1 , 1 ] )	;	Nome
						,	sql_unidades[ A_index+1 , 2 ]						;	Sigla
						,	sql_unidades[ A_index+1 , 3 ]						;	Entreposto
						,	sql_unidades[ A_index+1 , 4 ]						;	Id_Local - para contatos
						,	sql_unidades[ A_index+1 , 5 ] )						;	Endereço
				}
			Return

			preenche_responsaveis:
				Gui, ListView, LV_Responsaveis
				LV_Delete()
				default_list_view := A_DefaultListView	;	apenas para point break
				mat_responsaveis	=
					(
						SELECT	[id_gerente]
							,	[id_administrativo]
							,	[id_operacional]
						FROM
							[Cotrijal].[dbo].[responsaveis]
						WHERE
							[id_local] = '%_entreposto%'
					)
					mat_responsaveis := sql( mat_responsaveis , 3 )
				mat_in	:=	StrRep( "('" mat_responsaveis[2 , 1] "','" mat_responsaveis[2 , 2] "','" mat_responsaveis[2 , 3] "')" , , ",'',''):)", ",''):)" )
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
							[matricula] IN %mat_in%
						OR
							( [responsavel] < '20'	--	teste de responsaveis
						AND
							[cd_entreposto] = '%_entreposto%' )
						ORDER BY
							[responsavel]
					)
					s_responsaveis := sql( s_responsaveis , 3 )
					Loop,% s_responsaveis.count()-1	{
						LV_Add(	"icon"
							,	String.Name(s_responsaveis[ A_Index+1 , 1 ])
							,	String.Cargo(s_responsaveis[ A_Index+1 , 2 ])
							,	s_responsaveis[ A_Index+1 , 3 ]
							,	String.Telefone(s_responsaveis[ A_Index+1 , 4 ])	= ""	;	Se o telefone 1 for em branco, usa o 2
																					? sem_telefone := String.Telefone(s_responsaveis[ A_Index+1 , 5 ])
																					: String.Telefone(s_responsaveis[ A_Index+1 , 4 ])
							,	sem_telefone	= ""										;	Se o telefone 2 não foi usado no 1
												? String.Telefone(s_responsaveis[ A_Index+1 , 5 ])
												: ""
							,	s_responsaveis[ A_Index+1 , 6 ]
							,	s_responsaveis[ A_Index+1 , 7 ]
							,	s_responsaveis[ A_Index+1 , 8 ]
							,	s_responsaveis[ A_Index+1 , 9 ]
							,	s_responsaveis[ A_Index+1 , 10 ]	)
					}
			Return

			preenche_autorizados:
				;	Nome|Cargo|Matrícula|Telefone|Telefone|Ramal|Setor|Unidade|Sexo|Situação|Observação
				Gui, ListView, LV_autorizados
				LV_Delete()
				default_list_view := A_DefaultListView	;	apenas para point break
				s_autorizados =
					(
						SELECT	c.[nome]
							,	c.[cargo]
							,	c.[matricula]
							,	c.[telefone1]
							,	c.[telefone2]
							,	c.[ramal]
							,	c.[setor]
							,	c.[local]
							,	c.[sexo]
							,	c.[situacao]
							,	a.[observacao]
						FROM
							[ASM].[dbo].[_autorizados] a
						LEFT JOIN
							[ASM].[dbo].[_colaboradores] c
						ON
							a.[matricula] = c.[matricula]
						WHERE
							c.[id_local] = '%_id_local%'
						ORDER BY
							c.[responsavel]
					)
					s_autorizados := sql( s_autorizados , 3 )
					Loop,% s_autorizados.count()-1	{
						LV_Add(	"icon"
							,	String.Name( s_autorizados[ A_Index+1, 1 ] )
							,	String.Cargo( s_autorizados[ A_Index+1, 2 ] )
							,	s_autorizados[ A_Index+1, 3 ]
							,	String.Telefone( s_autorizados[ A_Index+1, 4 ] )
							,	String.Telefone( s_autorizados[ A_Index+1, 5 ] )
							,	s_autorizados[ A_Index+1, 6 ]
							,	s_autorizados[ A_Index+1, 7 ]
							,	s_autorizados[ A_Index+1, 8 ]
							,	s_autorizados[ A_Index+1, 9 ]
							,	s_autorizados[ A_Index+1, 10 ]
							,	s_autorizados[ A_Index+1, 11 ]	)
					}
			;

			preenche_emails:
				Gui, ListView, LV_Emails
				LV_Delete()
				default_list_view := A_DefaultListView	;	apenas para point break
				s_emails =
					(
						SELECT	a.[assunto]
							,	a.[mensagem]
							,	a.[importante]
						FROM
							[ASM].[ASM].[dbo].[_agenda] a
						LEFT JOIN
							[IrisSql].[dbo].[clientes] c
						ON
							c.[idunico] = a.[id_cliente]
						WHERE
							c.[complemento] = '%_id_local%'
						ORDER BY
							a.[pkid]
						DESC
					)
					Clipboard := s_emails
					s_emails := sql( s_emails )
					Loop,% s_emails.count()-1	{
						LV_Add(	"icon"
							,	s_emails[ A_Index+1, 1 ]
							,	s_emails[ A_Index+1, 2 ]
							,	s_emails[ A_Index+1, 3 ]	)
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

		;	Modo de visualização
			muda_visualizacao:
				_operador	:=	!_operador
				If( _operador = 1
				&& operador <> "ERRO" ) {
					GuiControl, , _operador1, 1
					GuiControl, , _operador2, 0
					WHERE := "AND [operador] = '" operador "'"
				}
				Else {
					GuiControl, , _operador1, 0
					GuiControl, , _operador2, 1
					WHERE = 
				}
			Goto preenche_unidades
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

GuiContextMenu() {
	if !A_eventInfo
		return
	menu1 := menu2 := menu3 :=
	if ( limpa_contexto > 0 )
		Menu, ClickToCall, DeleteAll
	if		( A_GuiControl = "LV_Responsaveis" )	{
		Gui, ListView, LV_Responsaveis
		listview_ok = 1
	}
	Else if	( A_GuiControl = "LV_Autorizados" )		{
		Gui, ListView, LV_Autorizados
		listview_ok = 1
	}
	Else if	( A_GuiControl = "LV_Colaboradores" )	{
		Gui, ListView, LV_Colaboradores
		listview_ok = 1
	}
	Else
		listview_ok = 
	define_ramal_local:	;	Define ramal
		ramal =
		ip := StrSplit( A_IpAddress1 , "." )
		if ( ip[4] < 100 AND ip[4] > 124 )
		|| ( ip[1] "." ip[2] "." ip[3] = "192.9.100") 
			IniRead, ramal, C:\Users\%A_UserName%\ramal.ini, Ramal, NR
		if ( ramal = "ERROR" )
			ramal =
		if ( ip[1] "." ip[2] "." ip[3] = "192.9.100" )	{
			if ip[4] > 101 AND ip[4] < 104
				ramal = 2530
			else if ip[4] > 105 AND ip[4] < 108
				ramal = 2852
			else if ip[4] > 109 AND ip[4] < 112
				ramal = 2853
			else if ip[4] > 113 AND ip[4] < 116
				ramal = 2854
			else if ip[4] > 117 AND ip[4] < 121
				ramal = 2855
			else if ip[4] > 122 AND ip[4] < 124
				ramal = 2860
			else if ip[4] = 100
				ramal = 2524
		}
		else if ( ramal = "" )	{	;	se não faz parte de rede 100
			InputBox,	ramal,	Ramal,	Digite o ramal que deseja utilizar para efetuar a ligação:
			If ErrorLevel
				return
			Else	{
				if ( ramal = "666" )	{
					MsgBox, ,O bebado e o Diabo, 	O bebado chega no inferno e grita: `n`tCadê as mulheres desse caraioo?`nO Diabo responde:`n`tAqui não tem mulher doido.`nO bebado diz:`n`tEntão onde tu arrumou esses chifres disgraçaaaaaaa?, 15
					Goto	define_ramal_local
				}
				else if (StrLen( ramal ) < 4
				||	StrLen( ramal ) > 6 )	{
					MsgBox	Digite um ramal válido.
					Goto define_ramal_local
				}
				else if ( array.InArray( ramais , ramal ) = 0 )	{
					MsgBox	O ramal que você digitou não existe na base de dados da Cotrijal. Digite um ramal válido.
					Goto	define_ramal_local
				}
				Else
					IniWrite, %ramal%, C:\Users\%A_UserName%\ramal.ini, Ramal, Nr
			}
		}
	;
	if listview_ok {
		limpa_contexto++
		;	Pega dados
			LV_GetText(	nome_contato,	A_EventInfo, 1	)	;	nome
			LV_GetText(	numero_1,		A_EventInfo, 4	)	;	telefone 1
			LV_GetText(	numero_2,		A_EventInfo, 5	)	;	telefone 2
			LV_GetText(	numero_3,		A_EventInfo, 6	)	;	ramal
			LV_GetText(	sexo,			A_eventinfo, 9	)
		;
		numero_1_exibe	:= numero_1
		numero_1		:= StrRep( numero_1, , "(" , ")" , "-" , " " )
		numero_2_exibe	:= numero_2
		numero_2		:= StrRep( numero_2, , "(" , ")" , "-" , " " )
		numero_3_exibe	:= numero_3
		numero_3		:= StrRep( numero_3, , "(" , ")" , "-" , " " )
		if SubStr( numero_1, -10) = SubStr( numero_2, -10)
			numero_2 =
		Menu, ClickToCall, Add,% nome_contato,	numero_1
			Menu, ClickToCall, Add			;	linha
		
		if StrLen( numero_1 )
			Menu, ClickToCall, Add,% numero_1_exibe, numero_1
		if StrLen( numero_2 )	{
			if StrLen( numero_1 )
				Menu, ClickToCall, Add	;	Linha
			Menu, ClickToCall, Add,% numero_2_exibe, numero_2
		}
		if StrLen( numero_3 )	{
			if StrLen( numero_1 )
			|| StrLen( numero_2 )
				Menu, ClickToCall, Add	;	linha
			Menu, ClickToCall, Add,% numero_3_exibe, numero_3
		}
		if (StrLen( numero_1 ) = 0
		&&	StrLen( numero_2 ) = 0
		&&	StrLen( numero_3 ) < 3 )
			return
		if( sexo = "M" )
			Menu,	ClickToCall, Icon,%	nome_contato,	C:\Seventh\Backup\ico\bman.png,,	0
		else
			Menu,	ClickToCall, Icon,%	nome_contato,	C:\Seventh\Backup\ico\bwoman.png,,	0
		Menu, ClickToCall, Show,% A_GuiX,% A_GuiY
	}
}

numero_1:
	index = 1
	Goto efetuar_ligacao

numero_2:
	index = 2
	Goto efetuar_ligacao

numero_3:
	index = 3
	Goto efetuar_ligacao

efetuar_ligacao:
	convert.discar( ramal, numero_%Index% )
	Menu, ClickToCall, DeleteAll
Return



;	-GuiClose
	ESC::
		GuiClose:
		ExitApp

	F5::
		Reload
;

;	Atalhos
;