File_Version=0.0.1.0

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

;	Globais
	Global	clicado
		,	m1
		,	m2
		,	m3
		,	ramal
		,	ramais := []
		,	ips_monitoramento := []
;

;	Variabels & Arrays
		; ips_monitoramento.Push("192.9.100.100")
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
	lv_size		:=	A_ScreenWidth-395	;	385 dos valores fixos e 10 para não exibir a barra horizontal
	autosearch	=	1
	delay		=	2
;

;	Config
	#IfWinActive, Buscar Colaboradores
	Menu, Tray, Icon
	if(	A_UserName != "dsantos"	)
		Menu, Tray,  NoStandard
	Menu, Tray, Tip,    Buscar Colaboradores
	Gui, +lastFound
	Gui.Cores()
;

;	GUI
	Gui,	Add,	Edit,		x5		y5	w200					h20		vmat	gsubmit ; autosearch
	Gui,	Add,	Edit,				y5	w50						h20		vdelay2	gSet_Delay Number
	if ( A_UserName != "dsantos" )
		Gui,	Add,	UpDown,				y5	w150					h20		vdelay	gSet_Delay	Range1-5, 2
	Else
		Gui,	Add,	UpDown,				y5	w150					h20	vdelay	gSet_Delay	Range1-5, 1
		Gui.Font( "cWhite" , "Bold" )
	Gui,	Add,	Text,				y7	w300					h20						, ←`tIntervalo para busca automática(segundos)
		Gui.Font()
	; Gui,	Add,	Button,		x160	yp	w350					h20				gsubmit	, Buscar por Matrícula, Nome, Ramal, Celular, Cargo, Setor ou Unidade
	Gui,	Add,	ListView,%	"x5		y35	w" A_ScreenWidth-10 "	h260	vlv	Grid"		, Matrícula|Nome|Telefone 1|Telefone 2|Ramal|Cargo|Setor|Local|E-Mail|Situação|Sexo
		LV_ModifyCol( 1 , "Integer" )
		LV_ModifyCol( 1 , 75 )
		LV_ModifyCol( 2 , Floor(lv_size * 0.17) )
		LV_ModifyCol( 3 , 115 )
		LV_ModifyCol( 4 , 115 )
		LV_ModifyCol( 5 , 75 )
		LV_ModifyCol( 6 , Floor(lv_size * 0.19) )
		LV_ModifyCol( 7 , Floor(lv_size * 0.17) )
		LV_ModifyCol( 8 , Floor(lv_size * 0.17) )
		LV_ModifyCol( 9	, Floor(lv_size * 0.17) )
		LV_ModifyCol( 10, Floor(lv_size * 0.13) )
		LV_ModifyCol( 11, 0 )
	Gui,	Show,%				"x-2	y0	w" A_ScreenWidth	"	h310"					, Buscar Colaboradores
return
; a
GuiContextMenu() {
	if ( A_eventInfo = 0 )
		return
	menu1:=menu2:=menu3:=""
	if ( clicado > 0 ) {
		Menu, ClickToCall, DeleteAll
		clicado =
	}
	if ( A_GuiControl = "lv" )	{
		s_ramal:
		
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
			IniRead, ramal, C:\Users\%A_UserName%\ramal.ini, Ramal, NR
			If ( ramal = "ERROR" )	{
			InputBox,	ramal,	Ramal,	Digite o ramal que deseja utilizar para efetuar a ligação:
				If ErrorLevel
					return
				Else	{
					If (StrLen( ramal ) < 4
					||	StrLen( ramal ) > 7 )	{
						MsgBox	Digite um ramal válido.
						Goto s_ramal
					}
					Else If ( array.InArray( ramais , ramal ) = 0 )	{
						MsgBox	O ramal que você digitou não existe na base de dados da Cotrijal.`nDigite um ramal válido.
						Goto	s_ramal
					}
					Else
						IniWrite, %ramal%, C:\Users\%A_UserName%\ramal.ini, Ramal, Nr
				}
		}

		}
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
			Menu,	ClickToCall,	Icon,	%	tnome,	C:\Seventh\Backup\ico\bman.png,,	0
		else
			Menu,	ClickToCall,	Icon,	%	tnome,	C:\Seventh\Backup\ico\bwoman.png,,	0
		Menu, ClickToCall, Show, %A_GuiX%, %A_GuiY%
	}
}

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

up:
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
	if ( autosearch = 1 )
		search_delay( delay "000" )
	mat_list	=
	GuiControl, Disable, mat
	Gui, Submit, NoHide
	accent  :=  mat
	matx	:=  string.Remove_accents( mat )
	StringUpper, matx, matx
	StringUpper, accent, accent
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
		gosub  number
	else
		gosub other
return

number:
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
		gosub submit
return
