File_Version=0.2.2
Save_to_sql=1
#SingleInstance Force
;	LEMBRAR DE AUMENTAR O VERSION DEVIDO AO UPDATE
;@Ahk2Exe-SetMainIcon C:\AHK\ico\mdcol.ico

;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\auth.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\date.ahk
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

;	Install Settings
	If( A_IsCompiled )	{
		If !A_IsAdmin
		|| !( DllCall( "GetCommandLine", "Str" ) ~= " /restart(?!\S)" )
			Try
				RunWait, % "*RunAs """ ( A_IsCompiled ? A_ScriptFullPath """ /restart" : A_AhkPath """ /restart """ A_ScriptFullPath """" )
	}
	auto_update( File_Version, "Colaboradores Cotrijal" )
	FileCreateDir,%	dir := "C:\Users\" A_UserName "\AppData\Local\KahCool"
	FileInstall,	C:\Seventh\Backup\ico\bman.png,%	icoMan	:= dir "\man.png",	1
	FileInstall,	C:\Seventh\Backup\ico\bwoman.png,%	icoWoman:= dir "\woman.png",1
;

;	Globais
	Global	clicado
		,	m1
		,	m2
		,	m3
		,	ramal
		,	ramais := []
		,	ips_monitoramento := []
		,	icoMan
		,	icoWoman
		,	dir
;

;	Variabels & Arrays
	;	Ramais
		ips_monitoramento.Push("192.9.100.100")
		ips_monitoramento.Push("192.9.100.102")
		ips_monitoramento.Push("192.9.100.106")
		ips_monitoramento.Push("192.9.100.109")
		ips_monitoramento.Push("192.9.100.114")
		ips_monitoramento.Push("192.9.100.118")
		ips_monitoramento.Push("192.9.100.123")
		r = select distinct ramal from [ASM].[dbo].[_colaboradores] where LEN(ramal) >= 4 and ramal <> '(55)99158-2861'
		r := sql( r, 3 )
		Loop,%	r.Count()-1
			ramais.push( r[A_Index+1,1] )
		s_ramal:
		; MsgBox % array.InArray( ips_monitoramento, A_IpAddress1 ) "`n" ips_monitoramento.Count() "`n" A_IpAddress1
		if ( array.InArray( ips_monitoramento, A_IpAddress1 ) ) {
			ip := StrSplit( A_IpAddress1 , "." )
			if ( ip[1] "." ip[2] "." ip[3] = "192.9.100" )	{
				ip	:=	ip[4]
				if ip		BETWEEN 101 AND 104
					ramal = 2530
				else if ip	BETWEEN 105 AND 108
					ramal = 2852
				else if ip	BETWEEN 109 AND 112
					ramal = 2853
				else if ip	BETWEEN 113 AND 116
					ramal = 2854
				else if ip	BETWEEN 117 AND 120
					ramal = 2855
				else if ip	BETWEEN 121 AND 124
					ramal = 2860
				else if ip	= 100
					ramal = 2524
			}		
		}
		Else {
			IniRead, ramal, %dir%\settings.ini, Ramal, NR
			If ( ramal = "ERROR" )	{
				If	FileExist( "C:\users\%A_UserName%\ramal.ini" )	{
					IniRead,	ramal, C:\users\%A_UserName%\ramal.ini, Ramal, NR
					FileDelete, C:\users\%A_UserName%\ramal.ini
					IniWrite,	%ramal%, %dir%\settings.ini, Ramal, Nr
					Goto	s_ramal
				}
				Else	{
					InputBox,	ramal,	Ramal,	Digite o ramal que deseja utilizar para efetuar as ligações:
					If ErrorLevel
						return
					Else	{
						If (StrLen( ramal ) < 4
						||	StrLen( ramal ) > 7 )	{
							MsgBox	Digite um ramal válido.
							Goto s_ramal
						}
						Else If ( array.InArray( ramais , ramal ) = 0 )	{
							MsgBox	O ramal que você digitou não existe na base de dados da Cotrijal.`nEntre em contacom com o departamento pessoal e solicite o cadastro do ramal em seu contato ou`nDigite um ramal válido.
							Goto	s_ramal
						}
						Else
							IniWrite, %ramal%, %dir%\settings.ini, Ramal, Nr
					}
				}
			}
		}
	;
	lv_size	:=	A_ScreenWidth-13	;	385 dos valores fixos e 10 para não exibir a barra horizontal
	delay	=	2
	if A_ScreenDPI	= 96
		Style		= "S10", "Bold"
;

;	Config
	#IfWinActive, Buscar Colaboradores
	Menu, Tray, Icon
	if(	A_UserName != "dsantos"	)
		Menu, Tray,  NoStandard
	Menu, Tray, Tip,    Buscar Colaboradores
	Gui, +lastFound
	Gui.Cores( )

	If	array.InArray( ips_monitoramento, A_IpAddress1 )
	&&	!FileExist( "%dir%\settings.ini" )
		IniWrite,	%ramal%, %dir%\settings.ini, Ramal, Nr

		IniRead, ramal		, %dir%\settings.ini, Ramal			, NR
	;	Configuração ListView
		IniRead, matricula	, %dir%\settings.ini, ListView		, matricula
			if ( matricula = "0" )
				all++
		IniRead, nome		, %dir%\settings.ini, ListView		, nome
			if ( nome = "0" )
				all++
		IniRead, telefone1	, %dir%\settings.ini, ListView		, telefone1
			if ( telefone1 = "0" )
				all++
		IniRead, telefone2	, %dir%\settings.ini, ListView		, telefone2
			if ( telefone2 = "0" )
				all++
		IniRead, ramal_lv		, %dir%\settings.ini, ListView		, ramal
			if ( ramal_lv = "0" )
				all++
		IniRead, cargo		, %dir%\settings.ini, ListView		, cargo
			if ( cargo = "0" )
				all++
		IniRead, setor		, %dir%\settings.ini, ListView		, setor
			if ( setor = "0" )
				all++
		IniRead, local		, %dir%\settings.ini, ListView		, local
			if ( local = "0" )
				all++
		IniRead, email		, %dir%\settings.ini, ListView		, email
			if ( email = "0" )
				all++
		IniRead, situação	, %dir%\settings.ini, ListView		, situação
			if ( situação = "0" )
				all++
	;
	IniRead, search_mode, %dir%\settings.ini, Modo de Busca	, Tipo
		if (search_mode = "ERROR" ) {
			search_mode	= Enter
			IniWrite,	Enter,	%dir%\settings.ini,	Modo de Busca,	Tipo
		}
		_Button := _Delay := _Enter := ""
		just_for_initial_config	:=	search_mode = "Delay"
												? _Button	:= _Enter := "Hidden"
								: 	search_mode = "Button"
												? _Delay	:= _Enter := "Hidden"
								: 	search_mode = "Enter"
												? _Delay	:= _Button:= "Hidden"
								:	""
		_timed_ := _button_ := _enter_ := ""

		a	:=	search_mode = "Delay"
							? _timed_	:= "Checked"
			: 	search_mode = "Button"
							? _button_	:= "Checked"
			: 	search_mode = "Enter"
							? _enter_	:= "Checked"
			:	""
		; MsgBox % search_mode "`n" _button "`n" _Delay "`n" _enter
;
;	GUI
	Gui,	-DPIScale
	Gui,	Add,	Edit,%	"x5		y5	w200						h20		vmat "	(search_mode = "Delay" ? "gsubmit" : "") ; autosearch
	if 		( search_mode = "delay" ) {
		Gui,	Add,	Edit,			y5	w50						h20		vdelay2	gSet_Delay	Number		%_delay%
			if ( A_UserName != "dsantos" )
				Gui,	Add,	UpDown,	y5	w150					h20		vdelay	gSet_Delay	Range1-5	%_delay%, 2
			Else
				Gui,	Add,	UpDown,	y5	w150					h20		vdelay	gSet_Delay	Range1-5	%_delay%, 1
					Gui.Font( "cWhite" , "Bold" )
		Gui,	Add,	Text,			y7							h20		vdelay_text						%_delay%, ←`tIntervalo para busca automática(segundos)
			Gui.Font(  )
		}
	Else If ( search_mode = "Button")
		Gui,	Add,	Button,	x205	yp	w350					h20		vbotao	gsubmit					%_Button%, Executar Busca
	Else If ( search_mode = "Enter"	) {
		Gui.Font( "cWhite" , "Bold", "S10" )
		Gui,	Add,	Text,	x205	yp	w400					h20		venter			0x1000	Center	%_Enter%, Pressione [Enter] para efetuar a busca
		Gui.Font()
		}
	Gui.Font( Style )
	Gui,	Add,	Button,%	 	"	ym							h25				gsettings"						, Configurações
	Gui,	Add,	Button,%	 	"	ym							h25				0x1000 Disabled"				,% "Versão atual " File_Version
	Gui,	Add,	ListView,%	"x5		y35	w" A_ScreenWidth-10 "	h260	vlv	Grid"								, Matrícula|Nome|Telefone 1|Telefone 2|Ramal|Cargo|Setor|Local|E-Mail|Situação|Sexo
		if ( all = 10 || all = "" ) {
			LV_ModifyCol( 1 , "Integer" )				;	Matricula
			LV_ModifyCol( 1 , Floor(lv_size * 0.04) )	;	matricula
			LV_ModifyCol( 2 , Floor(lv_size * 0.12) )	;	nome
			LV_ModifyCol( 3 , Floor(lv_size * 0.08) )	;	telefone 1
			LV_ModifyCol( 4 , Floor(lv_size * 0.08) )	;	telefone 2
			LV_ModifyCol( 5 , Floor(lv_size * 0.04) )	;	ramal 
			LV_ModifyCol( 6 , Floor(lv_size * 0.12) )	;	cargo
			LV_ModifyCol( 7 , Floor(lv_size * 0.12) )	;	setor
			LV_ModifyCol( 8 , Floor(lv_size * 0.15) )	;	local
			LV_ModifyCol( 9	, Floor(lv_size * 0.14) )	;	e-mail
			LV_ModifyCol( 10, Floor(lv_size * 0.10) )	;	situação
			LV_ModifyCol( 11, 0 )						;	sexo(para icones)
		}
		Else
			Loop, 11
				IF		(	matricula	!= "0" AND A_Index = 1 ) {
					LV_ModifyCol( 1 , "Integer" )				;	Matricula
					LV_ModifyCol( 1 , Floor(lv_size * 0.04) )	;	matricula
					}
				Else If	(	nome		!= "0" AND A_Index = 2 )
					LV_ModifyCol( 2 , Floor(lv_size * 0.12) )	;	nome
				Else If	(	telefone1	!= "0" AND A_Index = 3 )
					LV_ModifyCol( 3 , Floor(lv_size * 0.08) )	;	telefone 1
				Else If	(	telefone2	!= "0" AND A_Index = 4 )
					LV_ModifyCol( 4 , Floor(lv_size * 0.08) )	;	telefone 2
				Else If	(	ramal_lv	!= "0" AND A_Index = 5 )
					LV_ModifyCol( 5 , Floor(lv_size * 0.04) )	;	ramal 
				Else If	(	cargo		!= "0" AND A_Index = 6 )
					LV_ModifyCol( 6 , Floor(lv_size * 0.12) )	;	cargo
				Else If	(	setor		!= "0" AND A_Index = 7 )
					LV_ModifyCol( 7 , Floor(lv_size * 0.12) )	;	setor
				Else If	(	local		!= "0" AND A_Index = 8 )
					LV_ModifyCol( 8 , Floor(lv_size * 0.15) )	;	local
				Else If	(	email		!= "0" AND A_Index = 9 )
					LV_ModifyCol( 9	, Floor(lv_size * 0.14) )	;	e-mail
				Else If	(	situação	!= "0" AND A_Index = 10 )
					LV_ModifyCol( 10, Floor(lv_size * 0.10) )	;	situação
				Else
					LV_ModifyCol( A_index, 0 )

	Gui,	Show,%				"x-2	y0	w" A_ScreenWidth	"	h310"											, Buscar Colaboradores
	return
;
GuiContextMenu() {
	if ( A_eventInfo = 0 )
		return
	menu1:=menu2:=menu3:=""
	if ( clicado > 0 ) {
		Menu, ClickToCall, DeleteAll
		clicado =
	}
	if ( A_GuiControl = "lv" )	{
		Gui,	ListView,	lv
		clicado++
		LV_GetText(	tnome,	A_EventInfo	,	2	)	
		LV_GetText(	Menu1,	A_EventInfo	,	3	)	
		LV_GetText(	Menu2,	A_EventInfo	,	4	)	
		LV_GetText(	Menu3,	A_EventInfo	,	5	)	
		LV_GetText(	sex,	A_eventinfo	,	11	)

		m1	:= strRep( menu1, , "(" , ")" , "-" , " " )
		m2	:= strRep( menu2, , "(" , ")" , "-" , " " )
		m3	:= strRep( menu3, , "(" , ")" , "-" , " " )
		OutputDebug % "nr 1 = " m1 "`nnr 2 = " m2 "`nnr 3 = " m3

		if ( m1 = m2 )
			menu2 =
		Menu, ClickToCall, Add, %	tnome,	tip
		Menu, ClickToCall, Add
		
		if ( StrLen( m1 ) > 0 )
			Menu, ClickToCall, Add, %menu1%, Call1
		if ( StrLen( m2 ) > 0 )	{
			if ( StrLen( m1 ) > 0 )
				Menu, ClickToCall, Add
			Menu, ClickToCall, Add,%menu2%, Call2
		}
		if ( StrLen( m3 ) > 0 )	{
			if (StrLen( m1 ) > 0
			||	StrLen( m2 ) > 0 )
				Menu, ClickToCall, Add
			Menu, ClickToCall, Add,%menu3%, Call3
		}
		if (StrLen( m1 ) = 0
		&&	StrLen( m2 ) = 0
		&&	StrLen( m3 ) < 3 )
			return
		if ( sex = "M" )
			Menu,	ClickToCall,	Icon,	%	tnome,%	icoMan,,	0
		else
			Menu,	ClickToCall,	Icon,	%	tnome,%	icoWoman,,	0
		Menu, ClickToCall, Show, %A_GuiX%, %A_GuiY%
	}
}

settings:
	Gui,	Destroy

	;	recarrega vars
		IniRead, ramal		, %dir%\settings.ini, Ramal			, NR
		all=
		IniRead, matricula	, %dir%\settings.ini, ListView		, matricula
			if ( matricula = "ERROR" ) {
				IniWrite,	1,	%dir%\settings.ini, ListView,	matricula
				matricula = 1
				all++
		}
		IniRead, nome		, %dir%\settings.ini, ListView		, nome
			if ( nome = "ERROR" )	{
				IniWrite,	1,		%dir%\settings.ini, ListView, nome
				nome = 1
				all++
		}
		IniRead, telefone1	, %dir%\settings.ini, ListView		, telefone1
			if ( telefone1 = "ERROR" ) {
				IniWrite,	1,	%dir%\settings.ini, ListView, telefone1
				telefone1 = 1
				all++
		}
		IniRead, telefone2	, %dir%\settings.ini, ListView		, telefone2
			if ( telefone2 = "ERROR" ) {
				IniWrite,	1,	%dir%\settings.ini, ListView, telefone2
				telefone2 = 1
				all++
		}
		IniRead, ramal_lv	, %dir%\settings.ini, ListView		, ramal
			if ( ramal_lv = "ERROR" ) {
				IniWrite,	1,		%dir%\settings.ini, ListView, ramal
				ramal_lv = 1
				all++
		}
		IniRead, cargo		, %dir%\settings.ini, ListView		, cargo
			if ( cargo = "ERROR" ) {
				IniWrite,	1,		%dir%\settings.ini, ListView, cargo
				cargo = 1
				all++
		}
		IniRead, setor		, %dir%\settings.ini, ListView		, setor
			if ( setor = "ERROR" ) {
				IniWrite,	1,		%dir%\settings.ini, ListView, setor
				setor = 1
				all++
		}
		IniRead, local		, %dir%\settings.ini, ListView		, local
			if ( local = "ERROR" ) {
				IniWrite,	1,		%dir%\settings.ini, ListView, local
				local = 1
				all++
		}
		IniRead, email		, %dir%\settings.ini, ListView		, email
			if ( email = "ERROR" ) {
				IniWrite,	1,		%dir%\settings.ini, ListView, email
				email = 1
				all++
		}
		IniRead, situação	, %dir%\settings.ini, ListView		, situação
			if ( situação = "ERROR" ) {
				IniWrite,	1,	%dir%\settings.ini, ListView, situação
				situação = 1
				all++
		}
	;

	Gui.Cores( "settings" )
	Gui.Font( "settings:", "cWhite", "S10", "Bold" )
	Gui,	settings:Add,	GroupBox,	x10		y10		w220	h130															,	Modo de Busca
	Gui,	settings:Add,	GroupBox,	x10		y140	w220	h90																,	Ramal para Ligação
	Gui,	settings:Add,	GroupBox,	x240	y10		w400	h220															,	Colunas para Exibir
	Gui,	settings:Add,	Radio,		x20		y40		w200	h30	vtimed			gmodo_busca	%_timed_%						,	Busca Temporizada
	Gui,	settings:Add,	Radio,		x20		y70		w200	h30	vsearch_button	gmodo_busca	%_button_%						,	Botão de Busca
	Gui,	settings:Add,	Radio,		x20		y100	w200	h30	vpress_enter	gmodo_busca	%_enter_%						,	Pressionando [ ENTER ]
	Gui,	settings:Add,	CheckBox,%	"x250	y70		w180	h30	vmatr	"	(matricula	= 1 ?	"Checked" : "")	" gcolunas"	,	Matrícula
	Gui,	settings:Add,	CheckBox,%	"x250	y100	w180	h30	vnome	"	(nome 		= 1 ?	"Checked" : "")	" gcolunas"	,	Nome
	Gui,	settings:Add,	CheckBox,%	"x250	y130	w180	h30	vtel1	"	(telefone1	= 1 ?	"Checked" : "")	" gcolunas"	,	Telefone 1
	Gui,	settings:Add,	CheckBox,%	"x250	y160	w180	h30	vtel2	"	(telefone2	= 1 ?	"Checked" : "")	" gcolunas"	,	Telefone 2
	Gui,	settings:Add,	CheckBox,%	"x250	y190	w180	h30	vrama	"	(ramal_lv	= 1 ?	"Checked" : "")	" gcolunas"	,	Ramal
	Gui,	settings:Add,	CheckBox,%	"x440	y70		w190	h30	vcarg	"	(cargo		= 1 ?	"Checked" : "")	" gcolunas"	,	Cargo
	Gui,	settings:Add,	CheckBox,%	"x440	y100	w190	h30	vseto	"	(setor		= 1 ?	"Checked" : "")	" gcolunas"	,	Setor
	Gui,	settings:Add,	CheckBox,%	"x440	y130	w190	h30	vloca	"	(local		= 1 ?	"Checked" : "")	" gcolunas"	,	Local
	Gui,	settings:Add,	CheckBox,%	"x440	y160	w190	h30	vmail	"	(email		= 1 ?	"Checked" : "")	" gcolunas"	,	E-Mail
	Gui,	settings:Add,	CheckBox,%	"x440	y190	w190	h30	vsitu	"	(situação	= 1 ?	"Checked" : "")	" gcolunas"	,	Situação
	; Gui,	settings:Add,	CheckBox,%	"x250	y40		w380	h30	v_all	"	(all 		= 10 ?	"Checked Disabled 0x1000"			;	Todos
	; 																			:all		= "" ?	"Checked Disabled 0x1000" : "") " gcolunas"	,	Todos
		Gui.Font( "Settings:" )
		Gui.Font( "Settings:", "S25", "Bold" )
	Gui,	settings:Add,	Edit,		x20		y160	w200	h60	v_new_ramal		gnew_ramal							Center	,%	Ramal
		Gui.Font( "Settings:" )
	Gui,	settings:Add,	Button,		x10		y240	w630	h30					gSettingsGuiClose							,	Finalizar Configurações
	Gui,	settings:Show,																										,	Configurações
Return

colunas:
	Gui, settings:Submit,NoHide

	if (matr = 0
	||	nome = 0
	||	tel1 = 0
	||	tel2 = 0
	||	rama = 0
	||	carg = 0
	||	seto = 0
	||	loca = 0
	||	mail = 0
	||	situ = 0) {
		GuiControl, settings:, _all, 0
		_all = 0
	}
	Else {
		GuiControl, Settings:, _all, 1
		_all = 1
		matr :=	nome :=	tel1 :=	tel2 :=	rama :=	carg :=	seto :=	loca :=	mail :=	situ := 1
	}
	set_colunas( matr, "matricula" )
	set_colunas( nome, "nome" )
	set_colunas( tel1, "telefone1" )
	set_colunas( tel2, "telefone2" )
	set_colunas( rama, "ramal" )
	set_colunas( carg, "cargo" )
	set_colunas( seto, "setor" )
	set_colunas( loca, "local" )
	set_colunas( mail, "email" )
	set_colunas( situ, "situação" )

Return

set_colunas( value, field ) {
	IniWrite,% value,	%dir%\settings.ini,	ListView,%	field
	GuiControl, settings:,% field,% value
}

modo_busca:
	Gui, settings:Submit,NoHide
	if timed
		IniWrite,	delay,	%dir%\settings.ini,	Modo de Busca,	Tipo
	Else if search_button
		IniWrite,	button,	%dir%\settings.ini,	Modo de Busca,	Tipo
	Else
		IniWrite,	enter,	%dir%\settings.ini,	Modo de Busca,	Tipo
	; Reload
Return

new_ramal:
	search_delay( 1200 )
	Gui, settings:Submit,NoHide
	If (StrLen( _new_ramal ) < 4
	||	StrLen( _new_ramal ) > 7 )	{
		MsgBox	Digite um ramal válido.
		Return
	}
	Else If ( array.InArray( ramais , _new_ramal ) = 0 )	{
		MsgBox	O ramal que você digitou não existe na base de dados da Cotrijal.`nEntre em contacom com o departamento pessoal e solicite o cadastro do ramal em seu contato ou`nDigite um ramal válido.
		Return
	}
	Else {
		IniWrite, %_new_ramal%, %dir%\settings.ini, Ramal, Nr
		MsgBox,,, Ramal %_new_ramal% definido com sucesso, 2
	}
Return

SettingsGuiClose:
	Gui,	settings:Destroy
	Gui,	1:Default
	Goto	s_ramal


tip:
	OutputDebug % m1 "`n" m2 "`n" m3
	if ( StrLen( m1 ) > 0 )
		goto	Call1
	if ( StrLen( m2 ) > 0 )
		goto	Call2
	if ( StrLen( m3 ) > 0 )
		goto	Call3
return

Call1:
	if !A_IsCompiled
		Clipboard := ramal
	convert.discar( ramal, m1 )
	Menu, ClickToCall, DeleteAll
	ra	:= ramal
	des	:= m1
	Gosub	feedback
Return

Call2:
	if !A_IsCompiled
		Clipboard := ramal
	convert.discar( ramal, m2 )
	Menu, ClickToCall, DeleteAll
	ra	:= ramal
	des	:= m2
	Gosub	feedback
Return

Call3:
	if !A_IsCompiled
		Clipboard := ramal
	convert.discar( ramal, m3 )
	Menu, ClickToCall, DeleteAll
	ra	:= ramal
	des	:= m3
	Gosub	feedback
Return

feedback:
	; feedback_ctc(ra,des,name)
return

GuiClose:
	ExitApp

Set_Delay:
	Gui, Submit, NoHide
	if ( delay2 > 5 )	{
		delay = 5
		GuiControl, , delay2, 5
	}
	Else if ( delay2 < 0 )	{
		delay = 1
		GuiControl, , delay2, 1
	}
	GuiControl, Focus, mat
Return

submit:
	if ( search_mode = "Delay" )
		search_delay( delay "000" )
	
	mat_list	=
	GuiControl, Disable, mat
	Gui, 1:ListView, LV
	Gui, 1:Submit, NoHide
	OutputDebug % A_DefaultListView
	OutputDebug % A_DefaultGui
	accent  :=  mat
	matx	:=  string.Remove_accents( mat )
	StringUpper, matx,	matx
	StringUpper, accent,accent
	matz	:= StrSplit(matx,A_Space,A_Space)
	matz1	:= matz[1]
	matz2	:= matz[2]
	if ( mat = "" ) {
		GuiControl, Enable, mat
		GuiControl, Focus, mat
		return
	}

	LV_Delete()
	if (mat is number
	&&	StrLen( mat ) > 7
	&&	StrLen( mat ) < 12 )
		gosub	number
	else
		gosub	other
return

number:
	OutputDebug % "NUMBER"
	mat :=  StrReplace( mat , " " )
	mat :=  StrReplace( mat , "(" )
	mat :=  StrReplace( mat , ")" )
	q_ddl =
		(
		WITH FIRST AS ( select cast(matricula as int) as matricula, nome, [telefone1], [telefone2], ramal, cargo, setor, local, email,sexo, situacao
		FROM
			[ASM].[dbo].[_colaboradores]
		WHERE
		( matricula like '%matz1%`%' or nome like '`%%matz1%`%'or nome like '`%%accent%`%'  or telefone1 like '`%%matz1%`%' or telefone2 like '`%%matz1%`%' or cargo like '`%%matz1%`%' or setor like '`%%matz1%`%' or local like '`%%matz1%`%' or local like '`%%accent%`%' or ramal like '%matz1%`%' ) )

		select cast(matricula as int), nome, [telefone1], [telefone2], ramal, cargo, setor, local, email,sexo, situacao
		FROM first
		WHERE ( matricula like '%matz2%`%' or nome like '`%%matz2%`%' or cargo like '`%%matz2%`%' or setor like '`%%matz2%`%' or local like '`%%matz2%`%' or ramal like '`%%matz2%`%' ) 
		order by 1, 8, 2
		)
	Table :=
	Table := sql( q_ddl , 3 )
	Loop,% Table.Count()-1	{
		matri   :=  Table[A_Index+1, 1]
		IfInString, mat_list,   -%matri%-
			continue
		tel1		=
		tel2		=
		mat_list	.=	"-" matri "-"
		name		:=	string.name( Table[ A_Index+1 , 2 ] )
		tel1		:=	string.telefone( Table[ A_Index+1 , 3 ] )
		if ( SubStr( Table[ A_Index+1 , 3 ], -7 ) <> SubStr( Table[ A_Index+1 , 4 ], -7 ) )
			tel2	:=	string.telefone( Table[ A_Index+1 , 4 ] )
		cargo	:=	string.cargo( Table[ A_Index+1 , 6 ] )
		setor	:=	Table[ A_Index+1 , 7 ]
		unidade := Table[ A_Index+1 , 8 ] 
		mail	:= Table[ A_Index+1 , 9 ] 
		StringUpper, cname, name, T
		StringUpper, ccargo, cargo, T
		StringUpper, csetor, setor, T
		StringUpper, cuni, unidade, T
		LV_Add(	""
			,	matri
			,	name
			,	tel1
			,	tel2
			,	Table[A_Index+1, 5]
			,	ccargo
			,	csetor
			,	cuni
			,	mail
			,	Table[A_Index+1, 11]
			,	Table[A_Index+1, 10]	)
	}
	GuiControl, , lv
	GuiControl, , mat
	GuiControl, Enable, mat
	GuiControl, Focus, mat
return

other:
	OutputDebug % "OTHER"
	q_ddl =
		(
		with first as (  select cast(matricula as int) as matricula, nome, [telefone1], [telefone2], ramal, cargo, setor, local, email,sexo, situacao
		FROM [ASM].[dbo].[_colaboradores]
		WHERE ( matricula like '%matz1%`%' or nome like '`%%matz1%`%' or cargo like '`%%matz1%`%' or setor like '`%%matz1%`%' or local like '`%%matz1%`%' or ramal like '%matz1%`%' ) )

		select cast(matricula as int), nome, telefone1, telefone2, ramal, cargo, setor, local, email, sexo, situacao
		FROM first
		WHERE ( matricula like '%matz2%`%' or nome like '`%%matz2%`%' or cargo like '`%%matz2%`%' or setor like '`%%matz2%`%' or local like '`%%matz2%`%' or ramal like '`%%matz2%`%' ) 
		order by 1, 8, 2
		)
	Table :=
	Table := sql( q_ddl , 3 )
	Loop % Table.Count()-1	{
		matri := Table[ A_Index+1 , 1 ] 
		IfInString, mat_list,	-%matri%-
			continue
		tel1	=
		tel2	=
		mat_list.=	"-" matri "-"
		name	:=	string.name( Table[ A_Index+1 , 2 ] )
		tel1	:=	string.telefone( Table[ A_Index+1 , 3 ] )
		if ( SubStr( Table[ A_Index+1 , 3 ] , -7 ) <> SubStr( Table[ A_Index+1 , 4 ] , -7 ) )
			tel2 := string.telefone( Table[ A_Index+1 , 4 ] )
		cargo	:=	string.cargo( Table[ A_Index+1 , 6 ] )
		setor	:=	Table[ A_Index+1 , 7 ] 
		unidade	:=	Table[ A_Index+1 , 8 ] 
		mail	:=	Table[ A_Index+1 , 9 ] 
		t1		:=	StrLen( tel1 )
		t2		:=	StrLen( tel2 )
		StringUpper, cname, name, T
		StringUpper, ccargo, cargo, T
		StringUpper, csetor, setor, T
		StringUpper, cuni, unidade, T
		LV_Add(	""
			,	matri
			,	cname
			,	tel1
			,	tel2
			,	Table[ A_Index+1 , 5 ]
			,	ccargo
			,	csetor
			,	cuni
			,	mail
			,	Table[ A_Index+1 , 11 ]
			,	Table[ A_Index+1 , 10 ]	)
	}
	GuiControl, , lv
	GuiControl, , mat
	GuiControl, Enable, mat
	GuiControl, Focus, mat
return

$Enter::
	$NumpadEnter::
		OutputDebug % "ENTER"
		Gui, 1:Default
		Gui, 1:ListView, LV
		Gosub Submit
return
