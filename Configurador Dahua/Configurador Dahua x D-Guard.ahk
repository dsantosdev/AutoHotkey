File_Version=0.2.0
Save_To_Sql=1

;@Ahk2Exe-SetMainIcon C:\AHK\icones\cool.ico

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
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\post_data.ahk
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
	dns = "192.9.100.18"
	; dns = "%dns%"
;
Goto	interface
return
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
		Gui,Add,CheckBox,%	first_cb	Gui.Font( "cWhite" , "Bold" )	"	vdefault		gdefault"				,	Definições padrão
		Gui,Add,CheckBox,%	"ys												vis_cargo		gis_cargo"				,	Câmera de Pesagem
		Gui,Add,Edit,%		ts	Gui.Font( "cWhite" , "Bold" )														,	IP da Câmera
		Gui,Add,Edit,%		t	Gui.Font()								"	vip"									,	10.2.6.224
		Gui,Add,Edit,%		ts 	Gui.Font( "cWhite" , "Bold" )														,	Nome da Câmera
		Gui,Add,Edit,%		t	Gui.Font()								"	vcam_name"								,	LTC | B. Carga
		Gui,Add,Edit,%		ts	Gui.Font( "cWhite" , "Bold" )														,	Usuário da Câmera
		Gui,Add,Edit,%		t	Gui.Font()								"	vusername"								,	admin
		Gui,Add,Edit,%		ts	Gui.Font( "cWhite" , "Bold" )														,	Senha da Câmera
		Gui,Add,Edit,%		t	Gui.Font()					"	password	vpassword"								,	tq8hSKWzy5A
		Gui,Add,Edit,%		ts	Gui.Font( "cWhite" , "Bold" )														,	Operador
		Gui,Add,DDl,%		t	Gui.Font()	"AltSubmit"					"	voperator"								,	|1|2|3|4|5|6
		Gui,Add,Edit,%		ts	Gui.Font( "cWhite" , "Bold" )														,	Sinistro
		Gui,Add,DDl,%		t	Gui.Font()	"AltSubmit"					"	vincident"								,	|1|2|3|4|5|6
		Gui,Add,Edit,%		ts	Gui.Font( "cWhite" , "Bold" )														,	Servidor
		Gui,Add,DDl,%		t	Gui.Font()	"AltSubmit"					"	vserver"								,	1|2|3|4||
		Gui,Add,Edit,%		ys	Gui.Font()								"	vvendor_filter	gsearch"				,	Dahua
		Gui,Add,ListView,%	"xs		w230	Grid					R9		vlv_vendor		gs_vendor	AltSubmit"	,	Marca|Guid
		Gui,Add,Edit,%		ys											"	vmodel_filter	gsearch"				,	DH-IPC-HDBW2320RN-ZS
		Gui,Add,ListView,%	lv		"		Grid					R9		vlv_model		gs_model	AltSubmit "	,	Modelo|Guid
			Gui.Font( "cWhite" , "s10" )
		; Gui,Add,Edit,%		"xm	w760		ReadOnly				h142	vdebug_output"							,	Output Debug...
		Gui,Add,Edit,%		"xm	w760		ReadOnly				h500	vdebug_output"							,	Output Debug...
		Gui,Add,Button,%	"xm	w760															gVars"				,	Configurar	;	Executa configuração
		; Gui,Add,Button,%	"xm	w760															gDguard"			,	Configurar	;	Executa cadastro ou atualização
		clear_config()
			Gosub	search
		Gui,Show,																									,	Dahua Config
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
								: http( command[A_index] ) " ao configurar o servidor FTP.`n"
			GuiControl, , debug_output,% debug
			SendMessage,0x115,7,0,Edit13,Dahua Config
		}
		GuiControl, , debug_output,% http( "http://admin:tq8hSKWzy5A@" ip "/cgi-bin/magicBox.cgi?action=reboot" ) "`n`n"
		; debug .= SubStr( http( "http://admin:tq8hSKWzy5A@" ip "/cgi-bin/magicBox.cgi?action=reboot" ), 1, 2 )	= "Ok"
																												; ? "`nCâmera configurada!`n`nReiniciando a câmera agora..."
																												; : "`nCâmera configurada!`n`nFalha ao reiniciar a câmera, reinicie a câmera manualmente."
		SendMessage,0x115,7,0,Edit13,Dahua Config
	; Return

	; Dguard:
		Gui.Submit()
		debug .= "`n------------------------------------------`nIniciando cadastro de câmera no D-Guard`n------------------------------------------`n"
		GuiControl, , debug_output,% debug
		SendMessage,0x115,7,0,Edit13,Dahua Config
		; Loop,	4 {	;	Servidores

			; main_index			:= A_Index
			; token_%A_Index%		:= dguard.token( "vdm0" A_Index )
			; license_%A_Index%	:= json( dguard.http( "http://%dns%" A_Index ":8081/api/licenses/projects" , token_%A_Index% ) )

			; servers_%A_Index%	:=	json( servidores := dguard.http( "http://%dns%" A_Index ":8081/api/servers" , token_%A_Index% ) )

			; ; MsgBox % Clipboard:=unicode(servidores)
			; StringReplace,	servidores, servidores, "active":true, "active":true	, UseErrorLevel
			; 	ativas	:= ErrorLevel

			; sigla := SubStr( cam_name, 1, InStr( cam_name , " |" )-1 )
			; StringReplace,	servidores, servidores, "%sigla% |	, "%sigla% |	, UseErrorLevel
			; 	existentes_mesma_unidade := ErrorLevel

			; Loop,% license_%A_Index%.licenses.Count() {	;	Contagem de licenças para saber em qual server adicionar

			; 	if		(license_%main_index%.licenses[A_index].name = "DGPIP4" )
			; 		dgip_%main_index%	:= license_%main_index%.licenses[A_index].ipcameras

			; 	else if ( license_%main_index%.licenses[A_index].name = "DGPDVR" )
			; 		dgdvr_%main_index%	:= license_%main_index%.licenses[A_index].dvrs

			; }

		; 	ip_livres_%A_Index%	:=	( dgip_%A_Index% + dgdvr_%A_Index% ) - servers_%A_Index%.servers.Count()
		; 	; MsgBox % ativas "`n" dgip_%main_index% "`n" dgdvr_%main_index%
		; }
		; Loop, 4
			; MsgBox %	"Licenças IP`t"		dgip_%A_Index%
			; 	.		"`nIp Cam`t`t"		servers_%A_Index%.servers.Count()
			; 	.		"`nDvr's`t`t"		dgdvr_%A_Index%
			; 	.		"`nDisponíveis`t"	ip_livres_%A_Index%

		; StringReplace,	servidores, servidores, "active":true, "active":true	, UseErrorLevel
		; 	ativas	:= ErrorLevel
		; StringReplace,	servidores, servidores, "%sigla% |	, "%sigla% |	, UseErrorLevel
		; 	existentes	:= ErrorLevel
		; OutputDebug %	existentes "`n" ativas
		; OutputDebug %	dgip - ativas
		; Loop,%	servers.servers.Count()
			; MsgBox % servers.servers[A_Index].active

		Gui, Listview, lv_vendor
		LV_GetText(vendor_guid, 1, 2 )
		Gui, Listview, lv_model
		LV_GetText(model_guid, 1, 2 )

		token	:= for_output := dguard.token( "vdm0" server )
				if InStr( for_output, """Error"":" ) {
					debug .= "Falha`tAo resgatar token de acesso ao D-Guard, e-mail enviado ao desenvolvedor."
					body := for_output "`n`n" curl
					mail.new( "dsantos@cotrijal.com.br", "Erro no sistema de configuração Dahua", body )
					MsgBox, 48, Falha de Token,% "Falha`tAo resgatar token de acesso ao D-Guard, e-mail enviado ao desenvolvedor."
					Return
				}
				Else
					debug .= "Sucesso`tToken de acesso resgatado"
				GuiControl, , debug_output,% debug
				SendMessage,0x115,7,0,Edit13,Dahua Config
		cam_name:= StrRep( unicode( cam_name ),, "|:\u007c" )

		curl =  ;	Insere a câmera no d-guard
			(
				"http://%dns%%server%:8081/api/servers"
				-H	"accept: application/json"
				-H	"Authorization: bearer %token%"
				-H	"Content-Type: application/json"
				-d	"{ \"vendorGuid\": \"%vendor_guid%\", 
					\"modelGuid\": \"%model_guid%\", 
					\"name\": \"%cam_name%\", 
					\"active\": true, 
					\"address\": \"%ip%\", 
					\"port\": 80, 
					\"username\": \"admin\", 
					\"password\": \"tq8hSKWzy5A\", 
					\"connectionType\": 0, 
					\"timeoutEnabled\": true, 
					\"timeout\": 60, 
					\"bandwidthOptimization\": true, 
					\"camerasEnabled\": 0, 
					\"notes\": \"%operator%%incident%\"}"
			)
			cam_cad	:=	json( for_output := dguard.curl( curl, server, "POST" ) )
				if InStr( for_output, """Error"":" ) {
					debug .= "`nFalha`tAo inserir câmera no D-Guard, e-mail enviado ao desenvolvedor. Verifique os parâmetros inseridos"
					body := for_output "`n`n" curl
					mail.new( "dsantos@cotrijal.com.br", "Erro no sistema de configuração Dahua", body )
					MsgBox, 48, Erro ao Inserir câmera no D-Guard,% "Câmera não pode ser inserida no d-guard, verifique os parâmetros informados."
					Return
				}
				Else
					debug .= "`nSucesso`tCâmera inserida e ativada no D-Guard"
				GuiControl, , debug_output,% debug
				SendMessage,0x115,7,0,Edit13,Dahua Config
			cam_guid:=	StrRep( cam_guid_for_group := cam_cad.server.guid,, "{:%7B", "}:%7D" )

		curl =  ;	Ajusta parâmetros de contact id
			(
				"http://%dns%%server%:8081/api/servers/%cam_guid%/contact-id"
				-H "accept: application/json"
				-H "Authorization: bearer %token%"
				-H "Content-Type: application/json"
				-d "{ \"receiver\": 10001,
				      \"account\": \"0000\",
				      \"partition\": \"00\"}"
			)
			receiver := json( for_output := dguard.curl( curl, server, "PUT" ) )
				if InStr( for_output, """Error"":" ) {
					debug	.=	"`nFalha`tConfiguração dos dados para o sistema conceitto, ajuste manualmente"
					body := for_output "`n`n" curl
					mail.new( "dsantos@cotrijal.com.br", "Erro no sistema de configuração Dahua", body )
				}
				Else
					debug	.=	"`nSucesso`tDados para o sistema conceitto configurados"
				GuiControl, , debug_output,% debug
				SendMessage,0x115,7,0,Edit13,Dahua Config
			; MsgBox % receiver.Count() "`n" receiver.contactid.receiver "`n" receiver.contactid.account "`n" receiver.contactid.partition 
			
		curl =  ;	Resgata GUID do grupo de usuário
			(
				"http://%dns%%server%:8081/api/user-groups"
				-H "accept: application/json"
				-H "Authorization: bearer %token%"
			)
			group		:= json( for_output := dguard.curl( curl, server, "GET" ) )
				if InStr( for_output, """Error"":" ) {
					body := for_output "`n`n" curl
					mail.new( "dsantos@cotrijal.com.br", "Erro no sistema de configuração Dahua", body )
				}
			Loop,% group.usergroups.Count()
				if ( group.usergroups[A_Index].name = "operador " operator ) {
						group_guid	:=	StrRep( group.usergroups[A_Index].guid,, "{:%7B", "}:%7D" )
						Break
				}
		curl =	;	permissão para a coluna da câmera
			(
				"http://%dns%%server%:8081/api/user-groups/%group_guid%/permissions/servers"
				-H "accept: application/json"
				-H "Authorization: bearer %token%"
				-H "Content-Type: application/json"
				-d "{ \"guid\": \"%cam_guid_for_group%\", \"cameras\": [ 0 ]}"
			)
			for_output := dguard.curl( curl, server, "POST" )
				if InStr( for_output, """Error"":" ) {
					debug	.=	"`nFalha`tLiberar câmera para o operador " operator ", verifique as configurações de grupo para a câmera, no servidor " server
					body := for_output "`n`n" curl
					mail.new( "dsantos@cotrijal.com.br", "Erro no sistema de configuração Dahua", body )
				}
				Else
					debug .= "`nSucesso`tCâmera liberada na coluna do operador " operator
				GuiControl, , debug_output,% debug
				SendMessage,0x115,7,0,Edit13,Dahua Config

		curl =	;	Configuração de gravação de imagens
			(
				"http://%dns%%server%:8081/api/servers/%cam_guid%/cameras/0/recording"
				-H "accept: application/json"
				-H "Authorization: bearer %token%"
				-H "Content-Type: application/json"
				-d "{ \"enabled\": true,
					  \"streamId\": 0,
					  \"type\": 0,
					  \"daysHoursLimitEnabled\": true,
					  \"daysLimit\": 40,
					  \"hoursLimit\": 0,
					  \"emergencyRecording\": true,
					  \"recordInAnyDrive\": true}"
			)
				for_output := dguard.curl( curl, server, "PUT" )
				if InStr( for_output, """Error"":" ) {
					debug	.=	"`nFalha`tConfiguração de gravação da câmera, ajuste pelo servidor"
					body := for_output "`n`n" curl
					mail.new( "dsantos@cotrijal.com.br", "Erro no sistema de configuração Dahua", body )
				}
				Else
					debug .= "`nSucesso`tConfiguração de gravação efetuada`nSucesso`tConfiguração finalizada."
				GuiControl, , debug_output,% debug
				SendMessage,0x115,7,0,Edit13,Dahua Config
		Sleep, 2000
		clear_config()
		; Deleta câmera, para refazer o teste

			; curl = 
				; (
					; "http://%dns%%server%:8081/api/servers/%cam_guid%"
					; -H "accept: application/json"
					; -H "Authorization: bearer %token%"
				; )
				; receiver := json( dguard.curl( curl, server, "DELETE" ) )
		;
	Return
;

;	Funções
	clear_config(){
		GuiControl, , is_cargo,			0
		GuiControl, , default,			1
		GuiControl, , ip
		GuiControl, , cam_name
		GuiControl, , username, 		admin
		GuiControl, , password, 		tq8hSKWzy5A
		GuiControl, Choose, operator, 	0
		GuiControl, Choose, incident, 	0
		GuiControl, , vendor_filter,	Dahua
		GuiControl, , model_filter,		DH-IPC-HDBW2320Rn-ZS
		GuiControl, , debug_output
		GuiControl, Focus, IP
		Return
	}

	search:
		search_delay()
		Gui.Submit()
		if ("-" model_filter "-" = "-" old_model "-"
		&&	"-" vendor_filter "-" = "-" old_vendor "-" )
			Return
		old_vendor	:=	vendor_filter
		old_model	:=	model_filter
		GuiControl, Disable, model_filter
		GuiControl, Disable, vendor_filter
		GuiControl, , debug_output, Carregando Listas, aguarde!
		Gui, Listview, lv_vendor
			LV_Delete()
			LV_ModifyCol( 2 , 0)
			LV_ModifyCol( 1 , 215)
		Gui, Listview, lv_model
			LV_Delete()
			LV_ModifyCol( 2 , 0)
			LV_ModifyCol( 1 , 215)

		v	=
			(
				SELECT
					 v.[name]
					,v.[guid]
					,m.[name]
					,m.[guid]
				FROM
					[Dguard].[dbo].[vendors] v
				LEFT JOIN
					[Dguard].[dbo].[models] m
				ON
					v.[guid] = m.[vendorguid]
				WHERE
					v.[name] LIKE '`%%vendor_filter%`%'
				AND
					m.[Name] LIKE '`%%model_filter%`%'
				ORDER BY
					v.[Name]
			)
			v	:=	sql( v , 3 )
			in_vendor :=
				Loop,%	v.Count()-1 {
					GuiControl, , debug_output,% "Carregando Listas, aguarde!`nRestantes: " (v.Count()-1) - A_Index
					if !RegExMatch( in_vendor, v[A_Index+1, 1] ) {
						Gui, Listview, lv_vendor
						LV_Add("", v[A_Index+1, 1], v[A_Index+1, 2])
						in_vendor .= v[A_Index+1, 1] "`n"
					}
					Gui, Listview, lv_model
						LV_Add("", v[A_Index+1, 3], v[A_Index+1, 4])
				}
		GuiControl, Enable, model_filter
		GuiControl, Enable, vendor_filter
		GuiControl, , debug_output
	Return

	s_vendor:
		if (A_GuiControlEvent = "Normal") {
			Gui, Listview, lv_vendor
			LV_GetText(a, A_EventInfo, 1)
			GuiControl, , vendor_filter,% a
		}
		Return

		s_model:
		if (A_GuiControlEvent = "Normal") {
			Gui, Listview, lv_model
			LV_GetText(a, A_EventInfo, 1)
			GuiControl, , model_filter,% a
		}
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
;

;	GuiClose
	GuiClose:
		ExitApp
;