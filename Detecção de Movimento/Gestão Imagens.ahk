File_Version=0.2.0
Save_to_sql=0
/*
	[0.1.1]
		11-05-2022=shell.Exec alterado para a variável do path do executável do AHK devido a erros de execução após compilar
*/

;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\auth.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cameras.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\date.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\folder.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;
;@Ahk2Exe-SetMainIcon C:\AHK\icones\kah.ico

;	Configurações
	; #NoTrayIcon
	#SingleInstance, Force
	#Persistent
	#IfWinActive,	Gestão

	show_tooltip	:=	A_Args[1]	;	recebe o argumento 1 para exibir
		if ( A_UserName = "dsantos" )
			show_tooltip = 1
		CoordMode, ToolTip, Screen

	if A_IsCompiled
		ext	=	exe
	Else
		ext = ahk
	deletado=0
;

;	GUI
	Gui.Cores()
	Gui,	Add,	Text,%	gui.Font( "S10", "Bold", "cWhite" )	"w"	Round((A_ScreenWidth/10)*2)	" h30		vtotal			0x1000	Center"
	Gui,	Add,	ListView,%	Gui.Font()						"w"	Round((A_ScreenWidth/10)*2)	" R55	gL1	vL1	AltSubmit" 								,	Câmera|ip|Eventos	;|Soma
	Gui,	Add,	ListView,%	"ym								 w"	Round((A_ScreenWidth/10)*2)	" R57	gL2	vL2	AltSubmit"								,	Horário|FullPath
			LV_ModifyCol( 2, 0 )
			LV_ModifyCol( 1, 200 )
			LV_ModifyCol( 2, "Integer" )
	Gui,	Add,	Picture,%	"ym								 w"	Round((A_ScreenWidth/10)*6)	"			vpic	h"Round((A_ScreenWidth/10)*6)/16*9
	; Gosub	i_lv1
	Gosub	fill_l1
	Gui,	Show,	,	Gestão
	Menu,	mcm,	Add,	Configurar,		_configurar
	Menu,	mcm,	Add,	Deletar todas,	_limpar
	return
;


fill_l1:
	OutputDebug % "fill_l1 " A_LineNumber
	Gui,	ListView,	L1
	dia_verificar	:= MOD( A_YDay, 2 ) = 1 ? "Dia 1" : "Dia 2"
	Loop,	Files,	\\srvftp\Monitoramento\FTP\Verificados\%dia_verificar%\*.jpg
	{
		total_imagens	++
		i	:=	StrSplit( A_LoopFileName, "_")	;	1	=	data e hora | 2	=	ip	|	3	=	operador | 4	=	nome da câmera
		if	RegExMatch( deleted, i[2] )
			Continue
		If	RegExMatch( inserido, i[2] )
			Continue
		LV_Add( "", StrRep( i[4],, ".jpg") , i[2] )
		inserido	.=	i[2] "`n"
	}
	GuiControl, , total, % "Total de imagens " total_imagens

	OutputDebug % LV_GetCount()
		Loop,%	LV_GetCount()	{	;	apenas contagem de quantas imagens há de cada
			soma	=
			LV_GetText( isip, A_Index, 2 )
			Loop,	Files,	\\srvftp\Monitoramento\FTP\Verificados\%dia_verificar%\*.jpg
				if RegExMatch( A_LoopFileName, isip )
					soma ++
			LV_Modify( A_Index, Col3, , , soma )
			contagem += soma
		}
		LV_ModifyCol()
		LV_ModifyCol(	2, 0 )
		LV_ModifyCol(	3, "Integer" )
		LV_ModifyCol(	3, "SortDesc" )
		LV_ModifyCol(	3, 75 )
		LV_Modify(		0, "-Select" )
		LV_Modify(		1, "Focus Select" )
	GuiControl, Focus, L1
	LV_GetText( ip1, 1, 2 )
	fill_l2( ip1 )
return


L1:
	if( A_EventInfo = ""
	||	A_EventInfo = "0" )
		return
	Gui,	ListView,	L1
		LV_Delete()
	LV_GetText( ip1, A_EventInfo, 2 )
	if ( A_GuiEvent = "Normal" ) {
		OutputDebug % "L1 " A_LineNumber
		fill_l2( ip1 )
	}
return

L2:
	if	( A_GuiEvent = "Normal" )	{
		OutputDebug % "L2 " A_LineNumber
		Gui,	ListView,	L2
		LV_GetText( p, A_EventInfo, 2 )
		OutputDebug % p
		GuiControl,	,			pic,%	p
		GuiControl,	MoveDraw,	pic,%	"w" Round((A_ScreenWidth/10)*6)	"	h"Round((A_ScreenWidth/10)*6)/16*9
	}
	If( A_GuiEvent = "K" )	{
		OutputDebug % "K L2 " A_LineNumber
		if( A_EventInfo	= 40 )		{
			OutputDebug % "L2 40 " A_LineNumber
			r	:= LV_GetNext()
			Sleep	100
			LV_GetText( p, r, 2 )
			GuiControl,	,			pic,%	p
			GuiControl,	MoveDraw,	pic,%	"w" Round((A_ScreenWidth/10)*6)	" h"Round((A_ScreenWidth/10)*6)/16*9
		}
		else if( A_EventInfo = 38 )		{
			OutputDebug % "L2 38 " A_LineNumber
			r	:= LV_GetNext()
			Sleep	100
			LV_GetText( p, r, 2 )
			GuiControl,	,			pic,%	p
			GuiControl,	MoveDraw,	pic,%	"w" Round((A_ScreenWidth/10)*6)	" h"Round((A_ScreenWidth/10)*6)/16*9
		}
	}
return

GuiContextMenu:
	IfWinActive,	Gestão
	if( A_GuiControl != "L1" )
		return
	Menu, mcm, Show, %A_GuiX%, %A_GuiY%
return

_configurar:
	Gui,	ListView,	L1
	d := LV_GetNext( 0, "F" )
	LV_GetText( d, d, 2 )
	Run,	http://%d%
return

~Delete::
	_limpar:
		OutputDebug % "Delete " A_LineNumber
		deletou := 1
		Gui,	ListView,	L2
		LV_Delete()
		Gui,	ListView,	L1
		Gui,	Submit,	NoHide
		row := LV_GetNext(0, "F")
		LV_GetText(ip,row,2)
		LV_GetText(count,row,3)
		GuiControl, , total,% "Total de imagens " total_imagens := total_imagens-count
		OutputDebug % "listview " A_DefaultListView
		LV_Delete(row)
		GuiControl, Focus, L1
		LV_GetText(ip_new,1,2)
		OutputDebug % " new ip -" ip_new "-"
		fill_l2( ip_new )
		deleted .= ip "`n"
		code	:=	"#notrayicon"
				.	"`nLoop,	Files,	\\srvftp\Monitoramento\FTP\Verificados\" dia_verificar "\*.jpg"
				.	"`nIf RegexMatch( A_LoopFileName, """ ip """ )"
				.	"`nFileDelete,`%	A_LoopFileFullPath"
				.	"`nExitApp"
		ExecScript(code)
return

ExecScript( Script, Wait := false )  {
    shell := ComObjCreate( "WScript.Shell" )
    exec := shell.Exec( A_AhkPath " /ErrorStdOut *" )
    exec.StdIn.Write( script )
    exec.StdIn.Close()
}

GuiClose:
	ExitApp

fill_l2( ip )	{
	dia_verificar	:= MOD( A_YDay, 2 ) = 1 ? "Dia 1" : "Dia 2"
	Gui,	ListView,	L2
	Sleep, 500
	OutputDebug % "listview " A_DefaultListView "`n`tip " ip "`n`tdia - " dia_verificar
	Loop,	Files,	\\srvftp\Monitoramento\FTP\Verificados\%dia_verificar%\*.jpg
	{
		Gui,	ListView,	L2
		if	!RegExMatch( A_LoopFileName, ip )
			Continue
		image	:= StrSplit( StrRep( A_LoopFileName,,".jpg"), "_" )
		OutputDebug % "`t" image[1] "`t" image[4]
		LV_Add( "" , datetime( StrRep( image[1], , "-" ) ), A_LoopFileFullPath )
	}
	LV_Modify( 0, "-Select" )
	LV_Modify( 1, "Focus Select" )
	GuiControl, Focus, L2
	Send {right}
	Gui, Submit, NoHide
	row	:=	LV_GetNext()
	LV_GetText( p, row, 2 )
	GuiControl,	-Redraw,	pic
	GuiControl,	,			pic,%	p
	GuiControl,	+Redraw,	pic
}