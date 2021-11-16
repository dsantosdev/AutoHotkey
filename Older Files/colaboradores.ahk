/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\users\dsantos\desktop\executáveis\colaboradores.exe
Created_Date=1
Run_After="C:\Users\dsantos\Desktop\Executáveis\AHK2BD.exe "" "..." """
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
Inc_File_Version=1
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\Dih\zIco\2mdcol.ico

* * * Compile_AHK SETTINGS END * * *
*/

;@Ahk2Exe-SetMainIcon C:\Dih\zIco\2mdcol.ico
/*	ChangeLog
	Criado em: 01/01/2020
	16/11/2021
		Migrado para os arquivos do vs code
*/

/*	LGPD
	uso:Busca Matricula, Nome, Telefones, Ramal, Cargo, Setor de trabalho, Local de trabalho, E-Mail, Situacao na empresa(trabalhando, em ferias, licencas, etc..), Sexo(utilizado internamente para exibicao do ícone do clickToCall), com discagem rapida para os contatos utilizando menu de contexto.
	acessos:[ASM].[dbo].[_colaboradores]
	MetodoAcesso:ODBC mssql
	Encrypt:MPRESS - LZMAT
	QuemAcessa:(Agentes de monitoramento|Facilitadores|Coordenador TI Infra|Recepcionistas|Vigilantes Recepcao)
	Auth:Livre
	Log:Nao
*/

/*
	* * * Compile_AHK SETTINGS BEGIN * * *
	[AHK2EXE]
		Exe_File=C:\users\dsantos\desktop\executáveis\mdcol.exe
		Created_Date=1
	[VERSION]
		Set_Version_Info=1
		Company_Name=Heimdall
		File_Description=
		File_Version=0.0.0.1
		Inc_File_Version=1
		Product_Name=colaboradores
		Product_Version=1.1.33.2
		Set_AHK_Version=1
	* * * Compile_AHK SETTINGS END * * *
*/


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

ramais := []
	r = select distinct ramal from [ASM].[dbo].[_colaboradores] where LEN(ramal) >= 4 and ramal <> '(55)99158-2861'
	r := sql( r )
	Loop,%	r.Count()-1
		ramais.push( r[A_Index+1,1] )

;	Config
	#IfWinActive, Buscar Colaboradores
	Menu, Tray, Icon
	if(	A_UserName != "dsantos"	)
		Menu, Tray,  NoStandard
	Menu, Tray, Tip,    Buscar Colaboradores
	Gui, +lastFound
	gui.Cores()
;

;	GUI
	Gui,	Add,	Edit,		x5		y5	w150	h20		vmat
	Gui,	Add,	Button,		x160	y5	w350	h20				gsubmit	, Buscar por Matrícula, Nome, Ramal, Celular, Cargo, Setor ou Unidade
	Gui,	Add,	ListView,	x5		y35	w1270	h260	vlv	Grid		, Matrícula|Nome|Telefone 1|Telefone 2|Ramal|Cargo|Setor|Local|E-Mail|Situação|Sexo
		LV_ModifyCol(1,"Integer")
		LV_ModifyCol(5,75)
		LV_ModifyCol(1,75)
		LV_ModifyCol(2,150)
		LV_ModifyCol(3,115)
		LV_ModifyCol(4,115)
		LV_ModifyCol(5,50)
		LV_ModifyCol(6,170)
		LV_ModifyCol(7,150)
		LV_ModifyCol(8,150)
		LV_ModifyCol(9,150)
		LV_ModifyCol(10,120)
		LV_ModifyCol(11,0)
	Gui,	Show,				x0		y0	w1280	h310					, Buscar Colaboradores
return

GuiContextMenu()	{
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
		OutputDebug % m1 "`t" m2 "`t" m3

		if ( m1 = m2 )
			menu2 =
		; if ( StrLen( m1 ) = 11 )	{
			; if (Substr( m1 , 5 , 1 ) = "9"
			; ||	Substr( m1 , 5 , 1 ) = "8" )
				; m1 := Substr( m1 , 1 , 4 )	"9"	Substr( m1 , 5 )
		; }
		; if ( StrLen( m2 ) = 11 )
			; if (Substr( m2 , 5 , 1 ) = "9"
			; ||	Substr( m2 , 5 , 1 ) = "8" )
				; m2 := Substr( m2 , 1 , 4 )	"9"	Substr( m2 , 5 )
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
return

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
	convert.call("https://convert.cotrijal.local/portal/api/LigacaoAutomatica/executarLigacaoNumero/?origem="	ramal	"&destino="	m1)
	Menu, ClickToCall, DeleteAll
	ra	:= ramal
	des	:= m1
	; goto	feedback
	Return
Call2:
	convert.call("https://convert.cotrijal.local/portal/api/LigacaoAutomatica/executarLigacaoNumero/?origem="	ramal	"&destino="	m2)
	Menu, ClickToCall, DeleteAll
	ra	:= ramal
	des	:= m2
	; goto	feedback
	Return
Call3:
	convert.call("https://convert.cotrijal.local/portal/api/LigacaoAutomatica/executarLigacaoNumero/?origem="	ramal	"&destino="	m3)
	Menu, ClickToCall, DeleteAll
	ra	:= ramal
	des	:= m3
	; goto	feedback
; feedback:
; return
	; feedback_ctc(ra,des,name)
return
;}
up:	;{
return	;}
GuiClose: ;{
ExitApp ;}
submit:	;{
	mat_list	=
	GuiControl, Disable, mat
	Gui, Submit, NoHide
	accent  :=  mat
	matx :=  string.Remove_accents( mat )
	StringUpper, matx, matx
	StringUpper, accent, accent
	matz := StrSplit(matx,A_Space,A_Space)
	matz1 := matz[1]
	matz2 := matz[2]
	if(mat="") {
	 GuiControl, Enable, mat
	 GuiControl, Focus, mat
	 return
	}
	LV_Delete()
	if(mat is number and StrLen(mat) > 7 and StrLen(mat) < 12)
		gosub  number
	else
		gosub other
return

number:
mat :=  StrReplace(mat," ")
mat :=  StrReplace(mat,"(")
mat :=  StrReplace(mat,")")
q_ddl =
	(
	with first as ( select cast(matricula as int) as matricula, nome, [telefone1], [telefone2], ramal, cargo, setor, local, email,sexo, situacao
	FROM [ASM].[dbo].[_colaboradores]
	WHERE ( matricula like '%matz1%`%' or nome like '`%%matz1%`%'or nome like '`%%accent%`%'  or telefone1 like '`%%matz1%`%' or telefone2 like '`%%matz1%`%' or cargo like '`%%matz1%`%' or setor like '`%%matz1%`%' or local like '`%%matz1%`%' or local like '`%%accent%`%' or ramal like '%matz1%`%' ) )

	select cast(matricula as int), nome, [telefone1], [telefone2], ramal, cargo, setor, local, email,sexo, situacao
	FROM first
	WHERE ( matricula like '%matz2%`%' or nome like '`%%matz2%`%' or cargo like '`%%matz2%`%' or setor like '`%%matz2%`%' or local like '`%%matz2%`%' or ramal like '`%%matz2%`%' ) 
	order by 1, 8, 2
	)
Table :=
Table := sql( q_ddl , 3 )
;~ Clipboard   :=  adosql_lq
Loop % Table.Count() -1
{
	matri   :=  Table[A_Index+1, 1]
	IfInString, mat_list,   -%matri%-
		continue
	tel1=
	tel2=
	mat_list.="-" matri "-"
	name	:=	string.name(Table[A_Index+1, 2])
	tel1		:=	string.telefone(Table[A_Index+1,3])
	if(SubStr(Table[A_Index+1,3],-7) <> SubStr(Table[A_Index+1,4],-7))
		tel2	:=	string.telefone(Table[A_Index+1, 4] )
	cargo	:=	string.cargo(Table[A_Index+1, 6] )
	setor	:=	Table[A_Index+1, 7]
	unidade := Table[A_Index+1, 8] 
	mail := Table[A_Index+1, 9] 
	StringUpper, cname, name, T
	StringUpper, ccargo, cargo, T
	StringUpper, csetor, setor, T
	StringUpper, cuni, unidade, T
	LV_Add("", matri ,  name , tel1 , tel2 , Table[A_Index+1, 5] , ccargo,csetor,cuni,mail,Table[A_Index+1, 11],Table[A_Index+1, 10])
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
;~ Clipboard   :=  adosql_lq
Loop % Table.MaxIndex()-1
{
	matri := Table[A_Index+1,1] 
	IfInString, mat_list,   -%matri%-
		continue
	tel1=
	tel2=
	mat_list .= "-" matri "-"
	name :=string.name(Table[A_Index+1,2])
	tel1 := string.telefone(Table[A_Index+1,3])
	if(SubStr(Table[A_Index+1,3],-7) <> SubStr(Table[A_Index+1,4],-7))
		tel2 := string.telefone(Table[A_Index+1,4])
	cargo := string.cargo(Table[A_Index+1,6] )
	setor := Table[A_Index+1,7] 
	unidade := Table[A_Index+1,8] 
	mail := Table[A_Index+1,9] 
	t1 := StrLen(tel1)
	t2 := StrLen(tel2)
	StringUpper, cname, name, T
	StringUpper, ccargo, cargo, T
	StringUpper, csetor, setor, T
	StringUpper, cuni, unidade, T
	LV_Add("", matri,  cname , tel1 , tel2 , Table[A_Index+1, 5] , ccargo,csetor,cuni,mail,Table[A_Index+1,11],Table[A_Index+1,10])
}
GuiControl, , lv
GuiControl, , mat
GuiControl, Enable, mat
GuiControl, Focus, mat
return ;}
$Enter:: ;{
$NumpadEnter::
gosub submit
return ;}
