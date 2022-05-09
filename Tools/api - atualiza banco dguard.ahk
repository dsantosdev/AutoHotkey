/*
 * * * Compile_AHK SETTINGS BEGIN * * *

	[AHK2EXE]
	Exe_File=%In_Dir%\Update_dguard_db.exe
	Created_Date=1
	[VERSION]
	Set_Version_Info=1
	Company_Name=Heimdall
	File_Description=Atualizador de dados das câmeras no banco de dados
	File_Version=1.0.0.2
	Inc_File_Version=1
	Product_Version=1.1.33.2
	Set_AHK_Version=1
	[ICONS]
	Icon_1=C:\AHK\icones\db_update.ico

	* * * Compile_AHK SETTINGS END * * *
*/

;@Ahk2Exe-SetMainIcon C:\AHK\icones\db_update.ico

	inicio	:=	A_Now
	#Persistent
	#SingleInstance Force
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

;	Definições
	global	debug = 
		,	info_das_cameras := {}
	WinGetPos,,,, taskbar, ahk_class Shell_TrayWnd
;

;	Servers


	Gui, -Border -Caption +AlwaysOnTop
	Gui, Color, cGray
	; Gui, Color, , cGray
	Gui, Font, s10
	Gui, Add, Progress,%	"w" A_ScreenWidth - 20 "	h20	c6CEAE9	Smooth	Background008081	vhide_progress"
	Gui, Add, StatusBar,%	"w" A_ScreenWidth - 10 "						 -Theme				vstbar"			, Preparando variáveis do ambiente para atualização de dados...
		GuiControl, +BackgroundGray, stbar
	Gui, Show,% 			"w" A_ScreenWidth " 		h60	y" A_ScreenHeight - taskbar - 60					, Progresso

	size_w	:= A_ScreenWidth

	SB_SetParts( size_w/3 , size_w/3 )
	SB_SetIcon("C:\AHK\icones\db.ico", 1 , 1)
	SB_SetIcon("C:\AHK\icones\camera.ico", 1 , 2)
	SB_SetIcon("C:\AHK\icones\timer.ico", 1, 3)
	s =
	 (
		SELECT	[server_dns]
			,	[password]
			,	[login]
			,	[dgip_licenses]
			,	[dgdvr_licenses]
			,	[active_ip]
			,	[active_dvr]
		FROM
			[Dguard].[dbo].[servers]
	 )
	 servers_db := sql( s , 3 )
;

;	Tokens dos servidores
	Loop,% servers_db.Count()-1 {
		OutputDebug % StrLen( token_%A_Index% := Dguard.token(	servers_db[ A_index+1 , 1 ], servers_db[ A_index+1 , 2 ],	servers_db[ A_index+1 , 3 ] ) ) > 0
																																							? "Obtido token " A_Index
																																							: "Falha ao obter token " A_Index
	}
	Loop,%	servers_db.Count()-1 {	;	for count only

		has_cam := json( Dguard.http( "http://" servers_db[ A_index+1 , 1 ] ":8081/api/servers", token_%A_index% ) )
		total += has_cam.servers.Count()
		decorrido := A_Now - inicio
		SB_SetText(	"Tempo decorrido " formatseconds( decorrido ), 3)
		
	}

	Gui, Add, Progress,% "w" A_ScreenWidth-20 " h20 c6CEAE9 vprogress Smooth Background008081 Range0-" total
	GuiControl, MoveDraw, progress,% "x12 y8 w" A_ScreenWidth-20
	GuiControl,Hide , hide_progress
;	

;	Informações das câmeras contidas no d-guard
	cam_data_dguard := {}

	Loop,%	servers_db.Count()-1 {

		main_index	:= A_Index
		json_data	:= json( Dguard.http( "http://" servers_db[ A_index+1 , 1 ] ":8081/api/servers", token_%main_index% ) )

			Loop,% json_data.servers.Count()	{

				feitas++
				GuiControl,, Progress, +1
				decorrido := A_Now - inicio
				SB_SetText(	"Armazenando os dados das câmeras do servidor " main_index , 1 )
				SB_SetText(	feitas " câmeras inseridas | " total - feitas " câmeras restantes" , 2 )
				SB_SetText(	"Tempo decorrido " formatseconds( decorrido ), 3)

				_guid		:= StrReplace( StrReplace( json_data.servers[A_Index].guid , "{") , "}" )
				receiver	:= json( dguard.http( "http://" servers_db[ main_index+1, 1 ] ":8081/api/servers/%7B" _guid "%7D/contact-id" , token_%main_index% ) )
				json_camera := Dguard.Server( servers_db[ main_index+1, 1 ] , _guid , token_%main_index% )
				cam_data_dguard.Push({	name	:	json_camera.server.name
												,	guid		:	_guid
												,	active		:	json_camera.server.active
												,	connected	:	json_camera.server.connected
												,	address		:	json_camera.server.address
												,	port		:	json_camera.server.port
												,	vendor		:	json_camera.server.vendorModelName
												; ,	vendor		:	SubStr( json_camera.server.vendorModelName , 1 , InStr( json_camera.server.vendorModelName , " ")-1 )
												,	contactid	:	json_camera.server.contactIdCode
												,	offline		:	json_camera.server.offlineSince
												,	setor		:	SubStr( json_camera.server.notes , 1 , 1 )
												,	sinistro	:	SubStr( json_camera.server.notes , 2 , 1 )
												,	url			:	StrReplace( json_camera.server.url , "\" )
												,	receiver	:	receiver.contactId.receiver
												,	partition	:	receiver.contactId.partition	})
				if ( receiver.contactId.receiver != "10001" )
					api_get	:=	"http://conceitto:cjal2021@vdm01.cotrijal.local:85/camera.cgi?receiver=" receiver.contactId.receiver "&server=" json_camera.server.contactIdCode "&camera=0&resolucao=640x480&qualidade=100"
				Else
					api_get = 
				; MsgBox % api_get "`n-" receiver.contactId.receiver "-"
				ID			:=	StrSplit( json_camera.server.address , "." )
				date_off	:=	json_camera.server.offlineSince
				offline		:=	date_off = "-"
										? "NULL"
										: "CAST('" SubStr( date_off , 7 , 4 ) "-" SubStr( date_off , 4 , 2 ) "-" SubStr( date_off , 1 , 2 ) " " SubStr( date_off , 12 ) "' as datetime)"
				active		:=	json_camera.server.active	= "true"
															? "1"
															: "0"
				connected	:=	json_camera.server.connected= "true"
															? "1"
															: "0"
				url			:=	StrLen( json_camera.server.url )	= 0
																	? "http://" json_camera.server.address ":80"
																	: json_camera.server.url
				output		.=	"(	'" json_camera.server.name
								.	"','" StrReplace( StrReplace( json_camera.server.guid, "{") , "}" )
								.	"','" active
								.	"','" connected
								.	"','" json_camera.server.address
								.	"','" json_camera.server.port
								.	"','" json_camera.server.vendorModelName
								.	"','" json_camera.server.contactIdCode
								.	"',"  offline
								.	",'"  SubStr( json_camera.server.notes , 1 , 1 )
								.	"','" SubStr( json_camera.server.notes , 2 , 1 )
								.	"','" url
								.	"','1'"
								.	",'" api_get
								.	"','" receiver.contactId.receiver
								.	"','" receiver.contactId.partition
								.	"','" id[3]
								.	"','" json_camera.server.type "'),`n"
		}

	}
;

;	Popula a tabela sql com as informações
	output	:=	SubStr( output , 1 , -2 )
	d =
		(
			DELETE FROM
				[Dguard].[dbo].[cameras];
			DBCC CHECKIDENT ('[Dguard].[dbo].[cameras]', RESEED, 0);
		)
		sql( d , 3 )
	i =
		(
		INSERT INTO
			[Dguard].[dbo].[cameras]
				([name]
				,[guid]
				,[active]
				,[connected]
				,[ip]
				,[port]
				,[vendormodel]
				,[contactId]
				,[offlineSince]
				,[operador]
				,[sinistro]
				,[url]
				,[server]
				,[api_get]
				,[receiver]
				,[partition]
				,[id]
				,[type]	)
			VALUES
				%output%
		)
	;
	sql( i , 3 )
	if ( StrLen( sql_le ) > 2 )
		MsgBox	% sql_le "`n`n" Clipboard := sql_lq
	
	Else	{
		decorrido := A_Now - inicio
		SB_SetText(	"Dados Atualizados.  Tempo decorrido = " formatseconds( decorrido ) , 1 )
		Sleep, 3000
	}

ExitApp


END::
	ExitApp