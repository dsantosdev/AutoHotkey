File_Version=0.3.0
Save_To_Sql=1
Keep_Versions=2
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
	dns			= 192.9.100.18
	
	operador := {}
	s =
		(
			SELECT DISTINCT
				 [sigla]
				,[operador]
				,[sinistro]
			FROM
				[Cotrijal].[dbo].[unidades]
		)
	s	:=	sql( s, 3 )
	Loop,% s.Count()
		operador[ s[A_Index+1, 1] ] := s[A_index+1, 2] s[A_Index+1, 3]
	locais	:=	{}
		locais["Acerto"]			:=	 "[ ACE ]"
		locais["Administrativo"]	:=	 "[ ADM ]"
		locais["AFC"]				:=	 "[ AFC ]"
		locais["Atacado"]			:=	 "[ ATA ]"
		locais["Balança"]			:=	 "[ BAL ]"
		locais["CD Defensivos"]		:=	 "[ CDD ]"
		locais["CD Loja"]			:=	 "[ CDL ]"
		locais["CD Supermercado"]	:=	 "[ CDS ]"
		locais["Defensivos"]		:=	 "[ DEF ]"
		locais["Expodireto"]		:=	 "[ EXP ]"
		locais["Fertilizantes"]		:=	 "[ FER ]"
		locais["Loja"]				:=	 "[ LOJ ]"
		locais["Supermercado"]		:=	 "[ SUP ]"
		locais["Transportes"]		:=	 "[ TRA ]"
		locais["TRR"]				:=	 "[ TRR ]"
		locais["UBS"]				:=	 "[ UBS ]"

	Goto	interface

;	Interface
	interface:
		;	vars interface
			Gui.Cores()
			Loop, 6 {	;	r1 a r6 =rows | c1 a c6 = columns | w1 a w6 = widths
				c%A_Index% := " x" A_index * 135 - 125 " center"
				w%A_Index% := " w" A_index * 130 + ( A_index * 5 )
				r%A_index% := " y" A_index * 25
			}
			c1	:=	" x10 center"
			ds	:=	" Disabled"
			ro	:=	" ReadOnly -TabStop"
			cb	:=	" Checked"
		;

		Gui,	+AlwaysOnTop
		Gui,Add,CheckBox,%	r1	c1	w1		Gui.Font( "cWhite" , "Bold" )	"				vis_cargo				-Center"	,	Câmera Pesagem
		Gui,Add,CheckBox,%	r1	c2	w1	cb										"			vcamera					-Center"	,	Configurar Câmera 
		Gui,Add,CheckBox,%	r1	c3	w1	cb										"			vc_dguard				-Center"	,	Cadastro DGuard
		Gui,Add,CheckBox,%	r1	c4	w1											"			vdia					-Center"	,	Modo COR
		Gui,Add,CheckBox,%	r2	c1	w1	cb										"			vdo_reboot				-Center"	,	Reboot na Câmera
		Gui,Add,CheckBox,%	r2	c2	w1											"			vkeep_full	gkeep_debug	-Center"	,	Exibir log completo

		Gui,Add,Button,%	r3	c1	w2											"						gver_imagem	"			,	Ver imagem do local
		Gui,Add,Button,%	r3	c3	w2											"						gconfigurar	"			,	Abrir no Navegador

		Gui,Add,Edit,%		r4	c1	w1	ro																						,	IP da Câmera
		Gui,Add,Edit,%		r4	c2	w1	ro																						,	Local da Câmera
		Gui,Add,Edit,%		r4	c4	w1	ro																						,	Servidor
		Gui,Add,Edit,%		r4	c3	w1	ro																						,	Setor
		

		Gui,Add,Custom,%	r5	c1	w1		Gui.Font()	"	ClassSysIPAddress32	R1			vip			hwndIPCtrl"
		Gui,Add,Edit,%		r5	c2	w1					"									vcam_name"
		Gui,Add,DDl,%		r5	c4	w1					" AltSubmit							vserver"							,	1|2|3|4||
		Gui,Add,DDl,%		r5	c3	w1					" 									vlocal"								,	Acerto|Administrativo|AFC|Atacado|Balança|CD Defensivos|CD Loja|CD Supermercado|Defensivos|Expodireto|Fertilizantes|Loja|Supermercado|Transportes|TRR|UBS

		height	:= A_ScreenHeight- (StrReplace( r5, " y" )*2)
		Gui,Add,Edit,%		r6	c1	w4	ro	Gui.Font( "cWhite" , "Bold" )	" h" height	"	voutput					-Center"	,	Output Debug...
		
		Gui,Add,Button,%	w4										" xm								gArray"					,	Configurar	;	Executa configuração
		Gui,Show,%												" x-5	y0	  h" A_ScreenHeight-55								,	Dahua Config

		GuiControl, Focus, IP
		SetCtrlIp( IPCtrl, "10.2.1.1" )

		Send, {Lctrl Down}{Right 2}{LCtrl Up}
	return
;

Array:
	Gui.Submit()
	debug	=


	If	InStr( http( "http://admin:tq8hSKWzy5A@" ip "/cgi-bin/configManager.cgi?action=getConfig&name=ChannelTitle[0].Name", , 1 ), "PTZ" )
		is_ptz		=	1
	Else
		is_ptz		=	0
	URL				:=	"http://admin:tq8hSKWzy5A@" ip "/cgi-bin/configManager.cgi?action=setConfig"
	; CAM_MODEL		:=	"http://admin:tq8hSKWzy5A@" ip "/cgi-bin/magicBox.cgi?action=getSystemInfo"
	cam_model		:=	SubStr( SubStr( retorno , InStr( retorno := http( "http://admin:tq8hSKWzy5A@" ip "/cgi-bin/magicBox.cgi?action=getSystemInfo",,1 ), "deviceType=" )+11, 20 ), 1, InStr( retorno, "`n" )-3 )
	LANGUAGE		:=	url "&Language=English"
	MACHINE_NAME	:=	url "&General.MachineName=" StrReplace( ip , "." , "_" )
	NTP				:=	url "&NTP.Enable=true&NTP.Address=192.9.200.113&NTP.TimeZone=22&NTP.TimeZoneDesc=Brasilia"
	MOTION_DETECTION:=	url "&MotionDetect[0].Enable=false"
	;	Dia - Noite
		If	dia
			DAY_NIGHT		:=	url "&VideoInOptions[0].DayNightColor=0"
		Else
			DAY_NIGHT	:=	url "&VideoInOptions[0].DayNightColor=1"
	SNAPSHOT		:=	url "&Encode[0].SnapFormat[1].Video.Quality=6"
	;	OVERLAY & ENCODE
		if is_cargo {
			OVERLAY		:=	url "&VideoWidget[0].ChannelTitle.PreviewBlend=false&VideoWidget[0].TimeTitle.PreviewBlend=true&VideoWidget[0].TimeTitle.EncodeBlend=true"
							.	"&VideoWidget[0].ChannelTitle.EncodeBlend=false"
			ENCODE		:=	url "&Encode[0].MainFormat[0].Video.Compression=H.264"
							.	"&Encode[0].MainFormat[0].Video.BitRate=512"
							.	"&Encode[0].MainFormat[0].Video.BitRateControl=VBR"
							.	"&Encode[0].MainFormat[0].Video.resolution=1280x720"
							.	"&Encode[0].MainFormat[0].Video.FPS=12"
							.	"&Encode[0].MainFormat[0].Video.GOP=24"
							.	"&Encode[0].MainFormat[0].Video.Quality=6"
		}
		Else	{
			OVERLAY		:=	url "&VideoWidget[0].ChannelTitle.PreviewBlend=false&VideoWidget[0].TimeTitle.PreviewBlend=false&VideoWidget[0].TimeTitle.EncodeBlend=false"
							.	"&VideoWidget[0].ChannelTitle.EncodeBlend=false"
							.	"&VideoWidget[0].TimeTitle.PreviewBlend=false"
							.	"&VideoWidget[0].TimeTitle.EncodeBlend=false"
			If	!is_ptz
				ENCODE		:=	url "&Encode[0].MainFormat[0].Video.Compression=H.265"
								.	"&Encode[0].MainFormat[0].Video.BitRate=512"
								.	"&Encode[0].MainFormat[0].Video.BitRateControl=VBR"
								.	"&Encode[0].MainFormat[0].Video.resolution=1280x720"
								.	"&Encode[0].MainFormat[0].Video.FPS=12"
								.	"&Encode[0].MainFormat[0].Video.GOP=24"
								.	"&Encode[0].MainFormat[0].Video.Quality=6"
			Else								;	PTZ
				ENCODE		:=	url "&Encode[0].MainFormat[0].Video.Compression=H.265"
								.	"&Encode[0].MainFormat[0].Video.BitRate=1024"
								.	"&Encode[0].MainFormat[0].Video.BitRateControl=VBR"
								.	"&Encode[0].MainFormat[0].Video.resolution=1920x1080"
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
						.	"&NAS[0].Directory=FTP/Motion"
	;	FTP_PATH
		Loop, 3	{
			retorno	:=	http( "http://admin:tq8hSKWzy5A@" ip "/cgi-bin/configManager.cgi?action=getConfig&name=StorageGroup[" A_Index-1 "].Memo",,1 )

			If( InStr( SubStr( retorno, InStr( retorno, "=" )+1 ), "FTP" ) ) {
				FTP_PATH:=	url	"&StorageGroup[" A_Index-1 "].PicturePathRule="
						.	StrRep( ip,, "_:." ) "_%y%M%d-%h%m%s.jpg"
				Break
			}
		}
	command := []
	command.Push( LANGUAGE )			;	1
	command.Push( MACHINE_NAME )		;	2
	command.Push( NTP )					;	3
	command.Push( ENCODE )				;	4
	command.Push( DAY_NIGHT )			;	5
	command.Push( SNAPSHOT )			;	6
	command.Push( OVERLAY )				;	7
	command.Push( DESTINATION )			;	8
	command.Push( FTP )					;	9
	command.Push( MOTION_DETECTION	)	;	10
	command.Push( FTP_PATH	)			;	11
Goto	Config_Dahua

;	Code
	Config_Dahua:
		if (c_dguard= 1
		&&	camera	= 0 )
			Goto	Dguard
		if (c_dguard= 1)	{
			if (cam_name = "") {
				MsgBox, , Falta de Informação, Verifique todos os campos antes de prosseguir.`nCâmera sem nome...
				Return
			}
			if (local = "") {
				MsgBox, , Falta de Informação, Verifique todos os campos antes de prosseguir.`nCâmera sem local...
				Return
			}
		}
		ping := ping( ip )
		If ( ping = 0)	{
			MsgBox % ip " não respondeu ao teste de ping, verifique os dados inseridos no campo IP ou se há conexão com a câmera."
			Return
		}
		Loop,% command.Count()	{
			debug	.=	A_Index	= 1		? configurada "`n`nConfigurando a câmera '" ip "'`n`n...`n" http( command[A_index],,0 ) " ao configurar idioma.`n"
					:	A_Index = 2		? http( command[A_index],,0 ) " ao configurar nome da câmera(" StrRep( ip,, ".:_" ) ").`n"
					:	A_Index	= 3		? http( command[A_index],,0 ) " ao configurar servidor NTP(192.9.200.113).`n"
					:	A_Index	= 4		? http( command[A_index],,0 ) " ao configurar codec de vídeo(" (is_cargo = 1 ? "H.264" : "H.265") ") e parâmetros de vídeo da câmera.`n"
					:	A_Index	= 5		? dia	= 1
												? http( command[A_index],,0 ) " ao configurar modo de vídeo sempre colorido.`n"
												: http( command[A_index],,0 ) " ao configurar modo de vídeo automático.`n"
					:	A_Index	= 6		? http( command[A_index],,0 ) " ao configurar qualidade das imagens de detecção de movimento.`n"
					:	A_Index	= 7		? http( command[A_index],,0 ) " ao " (is_cargo = 1 ? "desativar" : "ativar") " a exibição de texto sobre a imagem da câmera.`n"
					:	A_Index	= 8		? http( command[A_index],,0 ) " ao configurar o DIRETÓRIO FTP(FTP/Motion).`n"
					:	A_Index	= 9		? http( command[A_index],,0 ) " ao configurar o SERVIDOR FTP(172.22.0.20).`n"
					; :	A_Index	= 10	? "Modelo de câmera " cam_model :=	SubStr( SubStr( retorno , InStr( retorno := http( "http://admin:tq8hSKWzy5A@10.2.78.59/cgi-bin/magicBox.cgi?action=getSystemInfo",,1 ), "deviceType=" )+11, 20 ), 1, InStr( retorno, "`n" )-3 ) "`n"
					:	A_Index	= 10	? http( command[A_index],,0 ) " ao desabilitar a detecção de movimento simples.`n"
					:	A_Index	= 11	? http( command[A_index],,0 ) " ao configurar nome de saída do arquivo em detecções de movimento.`n"
					: ""
			; OutputDebug % command[A_index]
			GuiControl, , output,%  debug 
			SendMessage, 0x115, 7, 0, Edit13, Dahua Config
		}
		if	do_reboot	{
			do_reboot =
			debug	.= http( "http://admin:tq8hSKWzy5A@" ip "/cgi-bin/magicBox.cgi?action=reboot" ) " ao enviar o comando para reiniciar.`n`n"
			GuiControl, , output,% debug
			SendMessage, 0x115, 7, 0, Edit13, Dahua Config
		}
		If ( c_dguard = 0) {
			configurada .= "Câmera IP " ip " configurada.`n"
			if	!keep_full {
				GuiControl, , output,% configurada
				SendMessage, 0x115, 7, 0, Edit13, Dahua Config
			}
			Return
		}

	Dguard:
		if	(c_dguard = 0) {
			debug=
			Return
		}
		Gui.Submit()
		debug .= "`n------------------------------------------`nIniciando cadastro de câmera no D-Guard`n------------------------------------------`nVerificando existência de câmera nos servidores...`n"
		GuiControl, , output,% debug
		SendMessage, 0x115, 7, 0, Edit13, Dahua Config
		vendor_guid	= {CA014F07-32AE-46B9-83A2-8A9B836E8120}
		If	http( "http://admin:tq8hSKWzy5A@" ip "/cgi-bin/magicBox.cgi?action=getDeviceClass") in ("SD","PTZ")
			model_guid	= {3D8D1B92-130A-9C6A-423A-F714888A6807}
		Else
			model_guid	= {5BA4689B-6DD0-2C27-C0F8-C6B514DC5533}

		s = 
			(
				SELECT
					 [name]			--	1
					,[active]		--	2
					,[connected]	--	3
					,[ip]			--	4
					,[server]		--	5
					,[operador]		--	6
					,[sinistro]		--	7
					,[cam_model]	--	8
					,[data_cadastro]--	9
				FROM
					[Dguard].[dbo].[cameras]
				WHERE
					[name]	= '%cam_name%'
				OR
					[ip]	= '%ip%'
			)
		s	:=	sql( s, 3 )
		If ( s.Count()-1 > 0 ) {
			MsgBox, 48, Duplicidade,%	"O NOME câmera ou IP cadastrados para essa câmera já estão em uso em:`n"
									.	"Servidor = "		s[A_Index+1, 5]
									.	"`nCâmera = "		s[A_Index+1, 1]
									.	"`nIP = "			s[A_Index+1, 4]
									.	"`nConectada = "	s[A_Index+1, 3] = 1 ? "Sim" : "Não"
									.	"`nAtiva = "		s[A_Index+1, 2] = 1 ? "Sim" : "Não"
									.	"`nOperador = "		s[A_Index+1, 6]
									.	"`nSinistro = "		s[A_Index+1, 7]
									.	"`nModelo = "		s[A_Index+1, 8]
									.	"`nCadastrada = "	s[A_Index+1, 9]
			Return
		}	

		s =
			(
				SELECT	DISTINCT
						LEFT( name, charindex('[', [name]) - 1)
				FROM
					[Dguard].[dbo].[cameras]
				WHERE
					PARSENAME([ip], 2) = PARSENAME('%ip%', 2)
				ORDER BY
					1
			)
			s	:= sql( s, 3 )
		if	(s.Count() < 2) {
			s	=
				(
					SELECT
						[sigla]
					FROM
						[Cotrijal].[dbo].[unidades]
					WHERE
						[entreposto] = PARSENAME('%ip%', 2)
				)
			s	:= sql( s, 3 )
		}
		sigla		:= Trim( s[2,1] )

		token		:= for_output := dguard.token( "vdm0" server )
				if InStr( for_output, """Error"":" ) {
					debug .= "Falha`tAo resgatar token de acesso ao D-Guard, e-mail enviado ao desenvolvedor."
					body := for_output "`n`n" curl
					mail.new( "dsantos@cotrijal.com.br", "Erro no sistema de configuração Dahua", body )
					MsgBox, 48, Falha de Token,% "Falha`tAo resgatar token de acesso ao D-Guard, e-mail enviado ao desenvolvedor."
					Return
				}
				Else
					debug .= "Sucesso`tToken de acesso resgatado"
					GuiControl, , output,% debug
					SendMessage, 0x115, 7, 0, Edit13, Dahua Config
		cam_place	:= StrRep( unicode( cam_name ),, "|:\u007c" )
		o_s			:= operador[ sigla ]
		operator	:= SubStr( o_s, 1 , 1 )
		incident	:= SubStr( o_s, 2 , 1 )
		cam_name := unicode( sigla " " locais[local] " " cam_place )

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
					GuiControl, , output,% debug
					SendMessage, 0x115, 7, 0, Edit13, Dahua Config
			
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
					GuiControl, , output,% debug
					SendMessage, 0x115, 7, 0, Edit13, Dahua Config
			
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
				-d "{ \"guid\": \"%cam_guid_for_group%\", \"cameras\": [ 0 ], \"ptzs\": [ 0 ]}"
			)
			for_output := dguard.curl( curl, server, "POST" )
				if InStr( for_output, """Error"":" ) {
					debug	.=	"`nFalha`tLiberar câmera para o operador " operator ", verifique as configurações de grupo para a câmera, no servidor " server
					body := for_output "`n`n" curl
					mail.new( "dsantos@cotrijal.com.br", "Erro no sistema de configuração Dahua", body )
				}
				Else
					debug .= "`nSucesso`tCâmera liberada na coluna do operador " operator
				GuiControl, , output,% debug
				SendMessage, 0x115, 7, 0, Edit13, Dahua Config

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
					debug .= "`nSucesso`tConfiguração de gravação efetuada`nSucesso`tConfiguração finalizada.`n"
				GuiControl, , output,% debug
				SendMessage, 0x115, 7, 0, Edit13, Dahua Config
				debug =
				GuiControl, Focus, ip
				Send {LControl Down}{Right 3}{Lctrl Up}
		;	atualiza banco de dados
		ip_sql	:=	ip
		ip		:=	StrSplit( ip, "." )
		id		:=	ip[3]
		cam_name:=	sigla " " locais[local] " " cam_place
		cam_guid:=	StrRep( cam_guid,, "%7B", "%7D" )
		i	=
			(
				INSERT INTO
					[Dguard].[dbo].[cameras]
					(	 name
						,guid
						,active
						,connected
						,ip
						,port
						,id
						,receiver
						,contactid
						,partition
						,server
						,operador
						,sinistro
						,url
						,cam_model	)
				VALUES
					(	'%cam_name%'
					,	'%cam_guid%'
					,	'1'
					,	'1'
					,	'%ip_sql%'
					,	'80'
					,	'%id%'
					,	'10001'
					,	'0000'
					,	'00'
					,	'%server%'
					,	'%operator%'
					,	'%incident%'
					,	'http://%ip_sql%'
					,	'%cam_model%'	)
			)
			sql( i, 3 )
			Clipboard := i
		if	sql_le
			MsgBox % sql_le "`n`n" Clipboard := sql_lq
		if !keep_full {
			Sleep 3000
			configurada .= "Câmera IP " ip_sql " configurada.`n"
			GuiControl, , output,% configurada
			SendMessage, 0x115, 7, 0, Edit13, Dahua Config
		}
		; Deleta câmera, para refazer se for teste
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
	configurar:
		Gui.Submit()
		Run, C:\Program Files\Google\Chrome\Application\chrome.exe	"http://%ip%"
		Loop	{
			CoordMode, Pixel, Window
			ImageSearch, FoundX, FoundY, 759, 434, 849, 520, C:\Users\Public\Pictures\Screen_20220608103944.png
			If !ErrorLevel
				Break
		}
		Until ErrorLevel = 0
		Sleep, 100
		MouseClick, Left, 970, 560
		Sleep, 100
		Send, {LCtrl down}a{LCtrl Up}admin{Tab}tq8hSKWzy5A{tab 2}{Enter}
	Return

	keep_debug:
		Gui.Submit()
		if	keep_full {
			GuiControl, , output,% debug
			SendMessage, 0x115, 7, 0, Edit13, Dahua Config
		}
		Else {
			GuiControl, , output,% configurada
			SendMessage, 0x115, 7, 0, Edit13, Dahua Config
		}

	Return

	ver_imagem:
		Gui.Submit()
		ping := ping( ip )
		If ( ping = 0)	{
			MsgBox % ip " não respondeu ao teste de ping, verifique os dados inseridos no campo IP."
			Return
		}
		WinGetPos, main_x, main_y, main_w, main_h, Dahua Config
		url_view:= "http://admin:tq8hSKWzy5A@" ip "/cgi-bin/snapshot.cgi"
		is_w	:= Floor( (A_ScreenWidth-main_w) )
		Gui, 2:Destroy
		Gui.Cores( 2 )
		Gui, 2:Add, ActiveX,% "xm vWB w" is_w-20 " h" Floor( is_w/16*9 ),	Shell.Explorer
		wb.navigate("about:<meta charset='utf-8'><meta http-equiv='X-UA-Compatible' content='IE=Edge'>")
		while (wb.readyState != 4 || wb.busy)
			Sleep -1
		wb.document.body.innerHTML := "<style> * { border: 0; margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; } </style><img src='" url_view "'>"
		Gui, 2:Show,% "x" main_w-10 " y0 w" A_ScreenWidth-main_w
		Sleep, 1000
	Return
;

;	Atalhos
	~Enter::
	~NumpadEnter::
		IfWinActive, dahua config
			Goto, ver_imagem
		Else
			Return

;

;	GuiClose
	GuiClose:
		ExitApp
;
