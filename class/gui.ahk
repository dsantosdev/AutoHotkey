Global	inc_gui = 1
	,	tray_bg_color	=	9BACC0
Class	Gui	{
	
	Cores( id = "", cor1 = "", cor2 = "" )												{
		if ( StrLen( cor1 ) = 0 )
			cor1 = 9BACC0	;	e33030 <--- vermelho
		if ( StrLen( cor2 ) = 0 )
			cor2 = 374658
		if ( Strlen( id ) > 0 )	{
			Gui,	%id%:Color,	,	%cor1%
			Gui,	%id%:Color,		%cor2%
		}
		else	{
			Gui,	Color,	,	%cor1%
			Gui,	Color,		%cor2%
		}
	}

	Font( params* )																		{
		Loop, % params.count()	{
			if ( InStr( params[ A_Index ], ":") > 0 )	{
				if ( debug => 4 )
					OutputDebug % "(Class gui.font)`n`tGui Named = " params[ A_index ]
				named := params[ A_index ]
				}
				Else
					config .= " " params[ A_index ]
		}
		Gui,% named "Font",% config
	}

	GroupBox( Text, GroupBoxOptions = "", Font = "", FontOptions = "" , Named = "" )	{
		Named := Named != "" ? Named ":" : Named
		Gui, %Named%Font,%	FontOptions,%	Font
		Gui, %Named%Add,	GroupBox,%		GroupBoxOptions,%	Text
	}

	Menu( params* )																		{	;	VALIDAR
		Loop, % params.count()	{
			if ( debug => 4 )
				OutputDebug % "(Class gui.menu)`n`tGui params[%A_Index%] = " params[ A_index ]
			if ( A_index = 1 )
				type :=	params[ A_index ] ","
				Else
					parametros .= params[ A_index ] ","
			}
			
			Menu, % type, % SubStr( parametros, 1, -1 )
	}

	ScreenSizes( )																		{
		Global	monitor_w
			,	monitor_h
			,	work_h
		; SysGet, taskbar_size, 31
		WinGetPos,,,,taskbar_size, ahk_class Shell_TrayWnd
		monitor_w	:=	A_ScreenWidth
		monitor_h	:=	A_ScreenHeight
		work_h		:=	monitor_h - taskbar_size
		Return "monitor_w, monitor_h e work_h com os valores."
	}

	Submit( named="" , hide="0" )														{
		if named
			named .= ":"
		Gui,	%named%Submit,% hide = "0" ?	"NoHide" : ""
	}
}