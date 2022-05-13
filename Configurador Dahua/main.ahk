/*
	* * * Compile_AHK SETTINGS BEGIN * * *
	[AHK2EXE]
		Exe_File=C:\users\dsantos\desktop\executáveis\Dahua Config.exe
		Created_Date=1
	[VERSION]
		Set_Version_Info=1
		Company_Name=Heimdall
		File_Description=
		File_Version=0.0.0.1
		Inc_File_Version=1
		Product_Name=main
		Product_Version=1.1.33.2
		Set_AHK_Version=1
	* * * Compile_AHK SETTINGS END * * *
*/

;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

;	-Configurações
	; #NoTrayIcon
	#SingleInstance, Force

	is_cargo	= 1
	default		= 1

	show_tooltip	:=	A_Args[1]	;	recebe o argumento 1 para exibir
		if ( A_UserName = "dsantos" )
			show_tooltip = 1
		CoordMode, ToolTip, Screen

	if ( A_IsCompiled = 1 )
		ext	=	exe
	Else
		ext = ahk
;

Goto	interface
; Goto Dguard	;	Informações do dguard
return
	; InputBox, ip, Title, Prompt
	; Goto vars
	; Return
; Goto Dguard

;	Variáveis
	vars:
		Gui.Submit()
		URL				:=	"http://admin:tq8hSKWzy5A@" ip "/cgi-bin/configManager.cgi?action=setConfig"
		LANGUAGE		:=	url "&Language=English"
		MACHINE_NAME	:=	url "&General.MachineName=" StrReplace( ip , "." , "_" )
		NTP				:=	url "&NTP.Enable=true&NTP.Address=192.9.200.113"
		DAY_NIGHT		:=	url "&VideoInOptions[0].DayNightColor=0"
		SNAPSHOT		:=	url "&Encode[0].SnapFormat[1].Video.Quality=6"
		if is_cargo {
			OVERLAY		:=	url "&VideoWidget[0].ChannelTitle.PreviewBlend=false"
							.	"&VideoWidget[0].ChannelTitle.EncodeBlend=false"
			ENCODE		:=	url "&Encode[0].MainFormat[0].Video.Compression=H.264"
							.	"&Encode[0].MainFormat[0].Video.BitRate=768"
							.	"&Encode[0].MainFormat[0].Video.BitRateControl=VBR"
							.	"&Encode[0].MainFormat[0].Video.resolution=1280x720"
							.	"&Encode[0].MainFormat[0].Video.FPS=12"
							.	"&Encode[0].MainFormat[0].Video.GOP=24"
							.	"&Encode[0].MainFormat[0].Video.Quality=6"
		}
		Else	{
			OVERLAY		:=	url "&VideoWidget[0].ChannelTitle.PreviewBlend=false"
							.	"&VideoWidget[0].ChannelTitle.EncodeBlend=false"
							.	"&VideoWidget[0].TimeTitle.PreviewBlend=false"
							.	"&VideoWidget[0].TimeTitle.EncodeBlend=false"
			ENCODE		:=	url "&Encode[0].MainFormat[0].Video.Compression=H.265"
							.	"&Encode[0].MainFormat[0].Video.BitRate=768"
							.	"&Encode[0].MainFormat[0].Video.BitRateControl=VBR"
							.	"&Encode[0].MainFormat[0].Video.resolution=1280x720"
							.	"&Encode[0].MainFormat[0].Video.FPS=12"
							.	"&Encode[0].MainFormat[0].Video.GOP=24"
							.	"&Encode[0].MainFormat[0].Video.Quality=6"
		}
		DESTINATION		:=	url "&RecordStoragePoint[0].VideoDetectSnapShot.FTP=true"
							.	"&RecordStoragePoint[0].VideoDetectSnapShot.Local=false"
							.	"&RecordStoragePoint[0].AlarmSnapShot.Local=false"
							.	"&RecordStoragePoint[0].TimingSnapShot.Local=false"
		FTP				:=	url "&NAS[0].Name=FTP"
							.	"&NAS[0].Enable=true"
							.	"&NAS[0].Protocol=FTP&NAS[0].Address=172.22.0.20"
							.	"&NAS[0].UserName=cameras"
							.	"&NAS[0].Password=c4m3r45"
							.	"&NAS[0].Directory=FTP/Motion/Dahua"
	Goto	array
;

;	Arrays
	array:
		command := []
			command.Push( LANGUAGE )
			command.Push( MACHINE_NAME )
			command.Push( NTP )
			command.Push( ENCODE )
			command.Push( DAY_NIGHT )
			command.Push( SNAPSHOT )
			command.Push( OVERLAY )
			command.Push( DESTINATION )
			command.Push( FTP )
	Goto,	Run
;


;	Interface
	interface:
		;	vars interface
			Gui.Cores()
			first_cb	=	y10	x10		w130	Section	Checked
			t			=	ys	Center	w130
			ts			=	xs	Center	w130	Section	ReadOnly	-Tabstop
			ts2			=	xs	Center	w230	Section	ReadOnly	-Tabstop
			lv			=	xs	Center	w230	Section
			ys			=	ym	Center	w230	Section
		;
		Gui,Add,CheckBox,%	first_cb	Gui.Font( "cWhite" , "Bold" )	"	vdefault		gdefault"	,	Definições padrão
		Gui,Add,CheckBox,%	"ys												vis_cargo		gis_cargo"	,	Câmera de Pesagem
		Gui,Add,Edit,%		ts	Gui.Font( "cWhite" , "Bold" )											,	IP da Câmera
		Gui,Add,Edit,%		t	Gui.Font()								"	vip"
		Gui,Add,Edit,%		ts 	Gui.Font( "cWhite" , "Bold" )											,	Nome da Câmera
		Gui,Add,Edit,%		t	Gui.Font()								"	vcam_name"
		Gui,Add,Edit,%		ts	Gui.Font( "cWhite" , "Bold" )											,	Usuário da Câmera
		Gui,Add,Edit,%		t	Gui.Font()								"	vusername"					,	admin
		Gui,Add,Edit,%		ts	Gui.Font( "cWhite" , "Bold" )											,	Senha da Câmera
		Gui,Add,Edit,%		t	Gui.Font()					"	password	vpassword"					,	tq8hSKWzy5A
		Gui,Add,Edit,%		ts	Gui.Font( "cWhite" , "Bold" )											,	Operador
		Gui,Add,DDl,%		t	Gui.Font()	"AltSubmit"					"	voperator"					,	||Operador 1|Operador 2|Operador 3|Operador 4|Operador 5|Operador 6
		Gui,Add,Edit,%		ts	Gui.Font( "cWhite" , "Bold" )											,	Sinistro
		Gui,Add,DDl,%		t	Gui.Font()	"AltSubmit"					"	vincident"					,	||Operador 1|Operador 2|Operador 3|Operador 4|Operador 5|Operador 6
		Gui,Add,Edit,%		ys	Gui.Font()								"	vvendor_filter	gfill_vendor",	Dahua
		Gui,Add,ListView,%	"xs		w230	Grid					h150	vlv_vendor"					,	Marca|Guid
			; Gosub fill_vendor
		Gui,Add,Edit,%		ys											"	vmodel_filter	gfill_model",	DH-IPC-HDBW2320RN-ZS
		Gui,Add,ListView,%	lv		"		Grid					h150	vlv_model"					,	Modelo|Guid|VendorGuid
			; Gosub	fill_model
			Gui.Font( "cWhite" , "s10" )
		Gui,Add,Edit,%		"xm	w760		ReadOnly				h142	vdebug_output"				,	Output Debug...
		; Gui,Add,Button,%	"xm	w760															gVars"	,	Configurar	;	Executa configuração
		Gui,Add,Button,%	"xm	w760															gDguard",	Configurar	;	Executa cadastro ou atualização
		Gui,Show,																						,	Dahua Config
	return
;

;	Code
	run:
		Loop,% command.Count()	{
			debug	.=	A_Index	= 1
								? "Configurando a câmera '" ip "'`n`n...`n" http( command[A_index] ) " ao configurar idioma.`n"
					:	A_Index = 2
								? http( command[A_index] ) " ao configurar nome da câmera(ip com underlines).`n"
					:  A_Index	= 3
								? http( command[A_index] ) " ao configurar servidor NTP.`n"
					:  A_Index	= 4
								? http( command[A_index] ) " ao configurar codec de vídeo e stream da câmera.`n"
					:  A_Index	= 5
								? http( command[A_index] ) " ao configurar modo de vídeo sempre colorido.`n"
					:  A_Index	= 6
								? http( command[A_index] ) " ao configurar qualidade das imagens de detecção de movimento.`n"
					:  A_Index	= 7
								? http( command[A_index] ) " ao configurar a exibição de texto sobre a imagem da câmera.`n"
					:  A_Index	= 8
								? http( command[A_index] ) " ao configurar a geração de imagens em detecção de movimento.`n"
								: http( command[A_index] ) " ao configurar o servidor FTP.`n`n`n"
			GuiControl, , debug_output,% debug
			SendMessage,0x115,7,0,Edit13,Dahua Config
		}
		MsgBox % http( "http://admin:tq8hSKWzy5A@" ip "/cgi-bin/magicBox.cgi?action=reboot" )
		; debug .= SubStr( http( "http://admin:tq8hSKWzy5A@" ip "/cgi-bin/magicBox.cgi?action=reboot" ), 1, 2 )	= "Ok"
																												; ? "`nCâmera configurada!`n`nReiniciando a câmera agora..."
																												; : "`nCâmera configurada!`n`nFalha ao reiniciar a câmera, reinicie a câmera manualmente."

		GuiControl, , debug_output,% debug
		SendMessage,0x115,7,0,Edit13,Dahua Config
	Return

	Dguard:
		Gui.Submit()
		Loop,	4 {	;	Servidores

			main_index			:= A_Index
			token_%A_Index%		:= dguard.token( "vdm0" A_Index )
			license_%A_Index%	:= json( dguard.http( "http://192.9.100.18" A_Index ":8081/api/licenses/projects" , token_%A_Index% ) )

			servers_%A_Index%	:=	json( servidores := dguard.http( "http://192.9.100.18" A_Index ":8081/api/servers" , token_%A_Index% ) )

			; MsgBox % Clipboard:=unicode(servidores)
			StringReplace,	servidores, servidores, "active":true, "active":true	, UseErrorLevel
				ativas	:= ErrorLevel

			sigla := SubStr( cam_name, 1, InStr( cam_name , " |" )-1 )
			StringReplace,	servidores, servidores, "%sigla% |	, "%sigla% |	, UseErrorLevel
				existentes_mesma_unidade := ErrorLevel

			Loop,% license_%A_Index%.licenses.Count() {	;	Contagem de licenças para saber em qual server adicionar

				if		(license_%main_index%.licenses[A_index].name = "DGPIP4" )
					dgip_%main_index%	:= license_%main_index%.licenses[A_index].ipcameras

				else if ( license_%main_index%.licenses[A_index].name = "DGPDVR" )
					dgdvr_%main_index%	:= license_%main_index%.licenses[A_index].dvrs

			}

			ip_livres_%A_Index%	:=	( dgip_%A_Index% + dgdvr_%A_Index% ) - servers_%A_Index%.servers.Count()
			; MsgBox % ativas "`n" dgip_%main_index% "`n" dgdvr_%main_index%
		}
		Loop, 4
			MsgBox %	"Licenças IP`t"		dgip_%A_Index%
				.		"`nIp Cam`t`t"		servers_%A_Index%.servers.Count()
				.		"`nDvr's`t`t"		dgdvr_%A_Index%
				.		"`nDisponíveis`t"	ip_livres_%A_Index%

		StringReplace,	servidores, servidores, "active":true, "active":true	, UseErrorLevel
			ativas	:= ErrorLevel
		StringReplace,	servidores, servidores, "%sigla% |	, "%sigla% |	, UseErrorLevel
			existentes	:= ErrorLevel
		OutputDebug %	existentes "`n" ativas
		OutputDebug %	dgip - ativas
		; Loop,%	servers.servers.Count()
			; MsgBox % servers.servers[A_Index].active
		
	Return
;

;	Funções
	fill_vendor:
		Gui, Listview, lv_vendor
		Gui.Submit()
		search_delay()
		Gui.Submit()
		LV_Delete()
		if vendor_filter
			where_vendor = WHERE [name] like '`%%vendor_filter%`%'
		Else
			where_vendor =
		LV_ModifyCol( 2 , 0)
		LV_ModifyCol( 1 , 215)
		v	=
			(
				SELECT	[name]
					,	[guid]
				FROM
					[Dguard].[dbo].[vendors]
				%where_vendor%
				ORDER BY
					[name]
			)
			v	:=	sql( v , 3 )
				Loop,%	v.Count()-1
					LV_Add("", v[ A_Index+1 , 1 ], v[ A_Index+1 , 2 ])
	Return
		
	fill_model:
		Gui, Listview, lv_model
		Gui.Submit()
		search_delay()
		Gui.Submit()
		LV_Delete()
		if model_filter
			where_model = WHERE [name] like '`%%model_filter%`%'
		Else
			where_model =
		LV_Delete()
		LV_ModifyCol( 3 , 0)
		LV_ModifyCol( 2 , 0)
		LV_ModifyCol( 1 , 215)
		m	=
			(
				SELECT	[name]
					,	[guid]
					,	[vendorguid]
				FROM
					[Dguard].[dbo].[models]
				%where_model%
				ORDER BY
					[vendorguid] , [name]
			)
			MsgBox % s
			m	:=	sql( m , 3 )
				Loop,%	m.Count()-1
					LV_Add("", m[ A_Index+1 , 1 ], m[ A_Index+1 , 2 ], m[ A_Index+1 , 3 ])
	Return

	is_cargo:	;	toggle cargo mode
		Gui.Submit()
		is_cargo	:=	!is_cargo
	Return

	default:	;	Set or remove default values
		default := !default
		if !default {
			GuiControl, ,ip				,
			GuiControl, ,cam_name		,
			GuiControl, ,username		,
			GuiControl, ,password		,
			GuiControl, ,vendor_filter	,
			GuiControl, ,model_filter	,
			GuiControl, Choose			,	operator,	0
			GuiControl, Choose			,	incident,	0
		}
		Else {
			GuiControl, ,username		,	admin
			GuiControl, ,password		,	tq8hSKWzy5A
			GuiControl, ,vendor_filter	,	Dahua
			GuiControl, ,model_filter	,	2320
		}	
	Return

	config:
		
	Return

;

;	GuiClose
	GuiClose:
		ExitApp
;