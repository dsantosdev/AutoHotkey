File_Version=0.0.0.1

/*
	[0.0.0.1]
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
	Gui,	Add,	ListView,%		"w"	Round((A_ScreenWidth/10)*2)	" R58	gL1	vL1	AltSubmit" 								,	Câmera|ip|Eventos	;|Soma
	Gui,	Add,	ListView,%	"ym w"	Round((A_ScreenWidth/10)*2)	" R58	gL2	vL2	AltSubmit"								,	Horário|FullPath
			LV_ModifyCol( 2, 0 )
			LV_ModifyCol( 1, 200 )
			LV_ModifyCol( 2, "Integer" )
	Gui,	Add,	Picture,%	"ym w"	Round((A_ScreenWidth/10)*6)	"			vpic	h"Round((A_ScreenWidth/10)*6)/16*9
	Gosub	i_lv1
	Gui,	Show,	,	Gestão
	Menu,	mcm,	Add,	Configurar,		_configurar
	Menu,	mcm,	Add,	Deletar todas,	_limpar
	return
;
	GuiClose:
		ExitApp
	L1:
		if( A_EventInfo = ""
		||	A_EventInfo = "0" )
			return
		Gui,	ListView,	L1
		LV_GetText( ip1, A_EventInfo, 2 )
		if ( A_GuiEvent = "Normal" )	{
			Gui,	ListView,	L2
			LV_Delete()
			Loop,	Files,	\\srvftp\Monitoramento\FTP\Verificados\%dia_verificar%\%ip1%*
			{
				image		:= StrSplit( StrRep( A_LoopFileName,,".jpg"), "_" )
				image_time	:= image[4] image[5] 
				LV_Add( "" , datetime( image_time ), A_LoopFileFullPath )
			}
			LV_Modify( 0, "-Select" )
			LV_Modify( 1, "Focus Select" )
			GuiControl, Focus, L1
			Send {right}
			Gui, Submit, NoHide
			row	:=	LV_GetNext()
			LV_GetText( p, row, 2 )
			GuiControl,	-Redraw,	pic
			GuiControl,	,			pic,%	p
			GuiControl,	+Redraw,	pic
		}
	return

	L2:
		if( A_GuiEvent = "Normal" )	{
			Gui,	ListView,	L2
			LV_GetText( p, A_EventInfo, 2 )
		GuiControl,	,			pic,%	p
		GuiControl,	MoveDraw,	pic,%	"w" Round((A_ScreenWidth/10)*6)	"	h"Round((A_ScreenWidth/10)*6)/16*9
		}
		If( A_GuiEvent = "K" )	{
			if( A_EventInfo	= 40 )		{
				r	:= LV_GetNext()
				Sleep	100
				LV_GetText( p, r, 2 )
			}
			if( A_EventInfo = 38 )		{
				r	:= LV_GetNext()
				Sleep	100
				LV_GetText( p, r, 2 )
			}
		GuiControl,	,			pic,%	p
		GuiControl,	MoveDraw,	pic,%	"w" Round((A_ScreenWidth/10)*6)	" h"Round((A_ScreenWidth/10)*6)/16*9
		}
	return

	GuiContextMenu:
		IfWinActive,	Gestão
		if( A_GuiControl != "L1" )
			return
		Menu, mcm, Show, %A_GuiX%, %A_GuiY%
	return

	i_lv1:
		Gui,	ListView,	L1
		dia_verificar	:= MOD( A_YDay, 2 ) = 1 ? "Dia 1" : "Dia 2"
		Loop,	Files,	\\srvftp\Monitoramento\FTP\Verificados\%dia_verificar%\*.*
		{
			vez	++
			IfInString,	A_LoopFileName,	Thumbs
				continue
			i	:=	StrSplit( A_LoopFileName, "_")
			ip	:=	i[1]
			if RegExMatch( deleted, ip )
				Continue
			IfInString, tem,%	ip
				continue
			LV_Add( "", StrRep( i[3], , " - : | "), i[1] )
			tem	.=	i[1] "`n"
		}
		Loop,%	LV_GetCount()	{
			soma	=
			LV_GetText( isip, A_Index, 2 )
			Loop,	Files,	\\srvftp\Monitoramento\FTP\Verificados\%dia_verificar%\%isip%*
				soma ++
			LV_Modify( A_Index, Col3, , , soma )
			contagem += soma
		}
		LV_ModifyCol()
			LV_ModifyCol( 2, 0 )
			LV_ModifyCol( 3, "Integer" )
			LV_ModifyCol( 3, "SortDesc" )
			LV_ModifyCol( 3, 75 )
			LV_Modify( 0, "-Select" )
			LV_Modify( 1,"Focus Select" )
		GuiControl, Focus, l2
		Send {right}
		Gui, Submit, NoHide
		LV_GetText( p, row, 2 )
		GuiControl,	-Redraw,	pic
		GuiControl,	,			pic,%	p
		GuiControl,	+Redraw,	pic
	return

	_configurar:
		Gui,	ListView,	L1
		d := LV_GetNext( 0, "F" )
		LV_GetText( d, d, 2 )
		Run,	http://%d%
	return

	~Delete::
		_limpar:
			deletou := 1
			Gui,	ListView,	L2
			LV_Delete()
			Gui,	ListView,	L1
			Gui,	Submit,	NoHide
			row := LV_GetNext(0, "F")
			LV_GetText(ip,row,2)
			LV_Delete(row)
			LV_Modify(1,"Focus Select")
			deleted .= ip "`n"
			code := "#notrayicon`nLoop,	Files,	\\srvftp\Monitoramento\FTP\Verificados\" dia_verificar "\"	ip	"*`n FileDelete,	`%	A_LoopFileFullPath"
			ExecScript(code)
			Send {right}
			Send {right}
			Send {right}
			GuiControl,	,	pic
	return

	Home::
		Send, admin{tab}tq8hSKWzy5A{Enter}
		return

	Numpad3::
		MouseGetPos, x, y
		Send, {3}{Tab}{Tab}{Enter}
		MouseMove, %x%, %y%
	return

	OnClipboardChange:
		return
		Clipboard := StrReplace( Clipboard, ".", "_" )
	return

ExecScript( Script, Wait := false )  {
    shell := ComObjCreate( "WScript.Shell" )
    exec := shell.Exec( A_AhkPath " /ErrorStdOut *" )
    exec.StdIn.Write( script )
    exec.StdIn.Close()
}