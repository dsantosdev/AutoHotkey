/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\users\dsantos\desktop\executáveis\mdcol.exe
Created_Date=1
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Version=0.0.0.2
Inc_File_Version=1
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\AHK\ico\mdcol.ico

* * * Compile_AHK SETTINGS END * * *
*/

/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\users\dsantos\desktop\executáveis\colaboradores.exe
Created_Date=1
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Version=0.0.0.1
Inc_File_Version=1
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\AHK\ico\mdcol.ico

* * * Compile_AHK SETTINGS END * * *
*/

/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\users\dsantos\desktop\executáveis\colaboradores.exe
Created_Date=1
Run_After="C:\Users\dsantos\Desktop\Executáveis\AHK2BD.exe "colaboradores" "0.0.0.1" """
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
Inc_File_Version=1
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\AHK\ico\mdcol.ico

* * * Compile_AHK SETTINGS END * * *
*/

;@Ahk2Exe-SetMainIcon C:\AHK\ico\mdcol.ico

;	Includes
	#Include ..\class\array.ahk
	;#Include ..\class\base64.ahk
	#Include ..\class\convert.ahk
	;#Include ..\class\cor.ahk
	;#Include ..\class\dguard.ahk
	#Include ..\class\functions.ahk
	#Include ..\class\gui.ahk
	;#Include ..\class\mail.ahk
	;#Include ..\class\safedata.ahk
	#Include ..\class\sql.ahk
	#Include ..\class\string.ahk
	;#Include ..\class\windows.ahk
;

;	Globais
	Global	m1
		,	m2
		,	m3
		,	ramal
;

;	Variabels & Arrays
	ramais := []
		r = select distinct ramal from [ASM].[dbo].[_colaboradores] where LEN(ramal) >= 4 and ramal <> '(55)99158-2861'
		r := sql( r )
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
	Gui,	Add,	UpDown,				y5	w150					h20		vdelay	gSet_Delay	Range1-5, 2
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

GuiContextMenu() {
	if ( A_eventInfo = 0 )
		return
	menu1:=menu2:=menu3:=""
	if ( clicado > 1 )
		Menu, ClickToCall, DeleteAll
	if ( A_GuiControl = "lv" )	{
		s_ramal:
		ramal=
		if ( A_IpAddress1 = "192.9.100.162" )
			ramal = 2530
		else if ( A_IpAddress1 = "192.9.100.166" )
			ramal = 2852
		else if ( A_IpAddress1 = "192.9.100.169" )
			ramal = 2853
		else if ( A_IpAddress1 = "192.9.100.176" )
			ramal = 2854
		else if ( A_IpAddress1 = "192.9.100.179" )
			ramal = 2855
		else if ( A_IpAddress1 = "192.9.100.184" )
			ramal = 2524
		else if ( ramal = "" )	{
			InputBox,	ramal,	Ramal,	Digite o ramal que deseja utilizar para efetuar a ligação:
			If ErrorLevel
				return
			Else	{
				if ( ramal = "666" )	{
					MsgBox, ,O bebado e o Diabo, 	O bebado chega no inferno e grita: `n`tCadê as mulheres desse caraioo?`nO Diabo responde:`n`tAqui não tem mulher doido.`nO bebado diz:`n`tEntão onde tu arrumou esses chifres disgraçaaaaaaa?, 15
					Goto	s_ramal
				}
				if (StrLen( ramal ) < 4
				||	StrLen( ramal ) > 6 )	{
					MsgBox	Digite um ramal válido.
					Goto s_ramal
				}
				if ( array.InArray( ramais , ramal ) = 0 )	{
					MsgBox	O ramal que você digitou não existe na base de dados da Cotrijal. Digite um ramal válido.
					Goto	s_ramal
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
			Menu,	ClickToCall,	Icon,	%	tnome,	C:\Seventh\Backup\ico\bman.png,, 0
		else
			Menu,	ClickToCall,	Icon,	%	tnome,	C:\Seventh\Backup\ico\bwoman.png,, 0
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
	convert.call("https://convert.cotrijal.com.br/portal/api/LigacaoAutomatica/executarLigacaoNumero/?origem="	ramal	"&destino="	m1)
	Menu, ClickToCall, DeleteAll
	ra	:= ramal
	des	:= m1
	Gosub	feedback
Return

Call2:
	convert.call("https://convert.cotrijal.com.br/portal/api/LigacaoAutomatica/executarLigacaoNumero/?origem="	ramal	"&destino="	m2)
	Menu, ClickToCall, DeleteAll
	ra	:= ramal
	des	:= m2
	Gosub	feedback
Return

Call3:
	convert.call("https://convert.cotrijal.com.br/portal/api/LigacaoAutomatica/executarLigacaoNumero/?origem="	ramal	"&destino="	m3)
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
