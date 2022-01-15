/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\users\dsantos\desktop\executáveis\câmeras_dguard.exe
Created_Date=1
Run_After="C:\Users\dsantos\Desktop\Executáveis\AHK2BD.exe "câmeras_dguard" "0.0.0.13" """
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Version=0.0.0.13
Inc_File_Version=1
Product_Name=câmeras_dguard
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\AHK\icones\fun\cam.ico

* * * Compile_AHK SETTINGS END * * *
*/

;@Ahk2Exe-SetMainIcon C:\AHK\icones\fun\cam.ico

;	Includes
	#Include ..\class\array.ahk
	;#Include ..\class/base64.ahk
	;#Include ..\class\convert.ahk
	;#Include ..\class\cor.ahk
	#Include ..\class\dguard.ahk
	#Include ..\class\functions.ahk
	;#Include ..\class\gui.ahk
	;#Include ..\class\mail.ahk
	;#Include ..\class\safedata.ahk
	#Include ..\class\sql.ahk
	;#Include ..\class\telegram.ahk
	;#Include ..\class\string.ahk
	#Include ..\class\timer.ahk
	;#Include ..\class\windows.ahk
;

timer("1")

;	Arrays
	bd_câmeras			:= {}	;	informações das câmeras no banco de dados
	dguard_câmeras		:= {}	;	informações das câmeras no dguard
	mensagens_telegram	:= []
	for_order			:= []	;	Mensagens para enviar para o telegram, apenas para ordenar as mensagens
;

;	Configurações
	; #NoTrayIcon
	#SingleInstance, Force

		if ( A_UserName = "dsantos" )
			show_tooltip = 1
		CoordMode, ToolTip, Screen
;

;	Variáveis
	Software		=	câmeras_dguard
	teste			:=	A_Args[3]	;	recebe o argumento 3 para canal teste, caso em branco envia para o server principal
	show_tooltip	:=	A_Args[1]	;	recebe o argumento 1 para exibir
	if ( A_IsCompiled = 1  ) {
		path_notificador = %A_ScriptDir%\
		ext = exe
	}
	Else	{
		path_notificador = C:\Users\dsantos\Desktop\AutoHotkey\Servidor - 10.0.20.43\
		ext = ahk
	}
;

;	Execução

	if ( show_tooltip = "1" )
		ToolTip		% "Buscando câmeras no banco de dados", 50, 50
		timer("bd")
	Gosub,	banco_de_dados
		OutputDebug % "banco de dados carregado"
		OutputDebug % "Carregando Keys"
	if ( show_tooltip = "1" )
		ToolTip		% "Carregando Keys", 50, 50
		timer("keys")
	Gosub,	keys
		OutputDebug % "Keys carregadas"
		OutputDebug % "Carregando servidores do d-guard"
	if ( show_tooltip = "1" )
		ToolTip % "Carregando servidores do d-guard", 50, 50
		timer("servidores")
	Gosub,	servidores
		OutputDebug % "Servidores D-Guard carregados"
		OutputDebug % "Iniciando comparação de dados"
	if ( show_tooltip = "1" )
		ToolTip % "Iniciando comparação de dados", 50, 50
		timer("comparando")
	Gosub,	comparar_dados
		OutputDebug % "Comparação de dados finalizada"
	if ( show_tooltip = "1" )
		ToolTip % "Comparação de dados finalizada " datetime( , A_Now ), 50 , 50
		OutputDebug % timer("Comparado")
	Return
;

;	Shortcut
	^T::
		teste = 1
		ToolTip, CANAL DE TESTE ATIVADO
		Sleep, 3000
		Tooltip
	Return
;

;	Code
	keys:
		key_vdm01	:=	dguard.token( "vdm01.cotrijal.local" )
			OutputDebug % StrLen( key_vdm01 )	= 0
												? "`tFalha ao solicitar Key do servidor 01"
												: "`tChave Server 1 Ok" ; key_vdm01 "____"

		key_vdm02	:=	dguard.token( "vdm02.cotrijal.local" )
			OutputDebug % StrLen( key_vdm02 )	= 0
												? "`tFalha ao solicitar Key do servidor 02"
												: "`tChave Server 2 Ok" ; key_vdm02 "____"

		key_vdm03	:=	dguard.token( "vdm03.cotrijal.local" )
			OutputDebug % StrLen( key_vdm03 )	= 0
												? "`tFalha ao solicitar Key do servidor 03"
												: "`tChave Server 3 Ok" ; key_vdm03 "____"
		; MsgBox % key_vdm01 "`n" key_vdm02 "`n" key_vdm03
		if (key_vdm01 = ""
		||	key_vdm02 = ""
		||	key_vdm03 = "")	{
			MsgBox Falha ao resgatar as KEYS!
			ExitApp
		}

	Return

	servidores:
		Loop,	3	{
			json_guid	:= json( Dguard.http( "http://vdm0" A_Index ".cotrijal.local:8081/api/servers", key_vdm0%A_Index% ) )
			index		:=	A_Index
				OutputDebug % "`t" json_guid.servers.Count() " a serem inseridas no map"
			Loop,%	json_guid.servers.Count()	{	;	câmeras do dguard para o map
				guid		:= StrRep(	json_guid.servers[A_Index].guid											;	guid para seleção da câmera
									,
									,	"{"
									,	"}" )

				receiver	:= json( http(	"http://vdm0" index ".cotrijal.local:8081/api/servers/%7B" guid "%7D/contact-id"	;	JSON com informações do receiver e partition
										,	"Bearer " key_vdm0%index% ) )
				json_camera	:= dguard.server(	"vdm0" index													;	dados da câmera seleciona
											,	guid
											,	key_vdm0%index% )
				for_id		:= StrSplit( json_camera.server.address , "." )
				;	Tratamento de offline
					numbers		:= RegExReplace( json_camera.server.offlineSince , "\D")
					if ( numbers != "" )
						offlinesince:= SubStr( numbers, 5, 4 ) "/" SubStr( numbers, 3, 2 ) "/" SubStr( numbers, 1, 2 ) SubStr( json_camera.server.offlineSince, 11 )
					Else
						offlinesince:= "NULL"
				;
				; if ( json_camera.server.name = "ENS | B. Frente" )
					; MsgBox % json_camera.server.notes "`n" json_camera.server.name
				dguard_câmeras.Push({	name		:	json_camera.server.name									;	Insere as informações no map para comparação posterior
									,	guid		:	guid
									,	active		:	json_camera.server.active		= "true" ? "1" : "0"
									,	connected	:	json_camera.server.connected	= "true" ? "1" : "0"
									,	address		:	json_camera.server.address
									,	port		:	json_camera.server.port
									,	id			:	for_id[3]
									,	vendor		:	json_camera.server.vendorModelName
									,	receiver	:	receiver.contactId.receiver
									,	contactid	:	json_camera.server.contactIdCode
									,	partition	:	receiver.contactId.partition
									,	offline		:	offlineSince
									,	server		:	index
									,	operador	:	SubStr( json_camera.server.notes , 1 , 1 ) = "" ? "0" : SubStr( json_camera.server.notes , 1 , 1 )
									,	sinistro	:	SubStr( json_camera.server.notes , 2 , 1 ) = "" ? "0" : SubStr( json_camera.server.notes , 2 , 1 )
									,	url			:	StrReplace( json_camera.server.url , "\" )
									,	api_get		:	receiver.contactId.receiver != "10001"
																					?	"http://conceitto:cjal2021@vdm0" index ".cotrijal.local:85/camera.cgi?receiver=" receiver.contactId.receiver "&server=" json_camera.server.contactIdCode "&camera=0&resolucao=640x480&qualidade=100"
																					:	""
									,	recording	:	json_camera.server.recording	= "true" ? "1" : "0"	})
				;
			}
		}
	Return
	
	banco_de_dados:
		s =
			(
				SELECT	[name]
					,	[guid]
					,	[active]
					,	[connected]
					,	[ip]
					,	[port]
					,	[id]
					,	[vendormodel]
					,	[receiver]
					,	[contactId]
					,	[partition]
					,	[offlineSince]
					,	[server]
					,	[operador]
					,	[sinistro]
					,	[url]
					,	[api_get]
					,	[recording]
				FROM
					[Dguard].[dbo].[cameras]
				ORDER BY
					1
			)
		bd := sql( s , 3 )
		Loop,%	bd.Count()-1 {
			; OutputDebug %  bd[ A_Index+1 , 10 ] "[t]" bd[ A_Index+1 , 1 ]
			bd_câmeras.Push({	name		:	bd[ A_Index+1 , 1 ]		;	Insere as informações no map para comparação posterior
							,	guid		:	bd[ A_Index+1 , 2 ]
							,	active		:	bd[ A_Index+1 , 3 ]
							,	connected	:	bd[ A_Index+1 , 4 ]
							,	address		:	bd[ A_Index+1 , 5 ]
							,	port		:	bd[ A_Index+1 , 6 ]
							,	id			:	bd[ A_Index+1 , 7 ]
							,	vendor		:	bd[ A_Index+1 , 8 ]
							,	receiver	:	bd[ A_Index+1 , 9 ]
							,	contactid	:	bd[ A_Index+1 , 10 ]
							,	partition	:	bd[ A_Index+1 , 11 ]
							,	offline		:	bd[ A_Index+1 , 12 ]	= ""
																		? "NULL"
																		:			SubStr( bd[ A_Index+1 , 12 ] , 7 , 4 )
																			.	"/" SubStr( bd[ A_Index+1 , 12 ] , 4 , 2 )
																			.	"/" SubStr( bd[ A_Index+1 , 12 ] , 1 , 2 )
																			.	" " SubStr( bd[ A_Index+1 , 12 ] , 12 )
							,	server		:	bd[ A_Index+1 , 13 ]
							,	operador	:	bd[ A_Index+1 , 14 ]
							,	sinistro	:	bd[ A_Index+1 , 15 ]
							,	url			:	bd[ A_Index+1 , 16 ]
							,	api_get		:	bd[ A_Index+1 , 17 ]
							,	recording	:	bd[ A_Index+1 , 18 ]	})
		}
	;

	;	Configurações de variáveis pelo bd
		s =
			(
				SELECT	[software]
					,	[vars]
				FROM
					[ASM].[dbo].[Software_Config]
				WHERE
					[Software] = '%software%'
			)
		config	:= sql( s , 3 )
		configs	:= StrSplit( config[ 2 , 2 ] , ";" )
		Loop,% configs.Count()	{
			definition	:= StrSplit( configs[ A_index ] , "=" )
			var			:= definition[1]
			%var%		:= definition[2]
		}
	Return

	comparar_dados:
		OutputDebug % "Câmeras no Banco de Dados = " bd.Count()-1
		OutputDebug % "Câmeras no dguard = " dguard_câmeras.Count()
		; OutputDebug % "Ordenando por nome!" dguard_câmeras1 := array.sort( dguard_câmeras )	;	Não está pronto a classe
		; MsgBox % dguard_câmeras1.count()

		Loop,%	dguard_câmeras.Count()	{
			OutputDebug % asdffds
			index	:=	array.InDict( bd_câmeras, dguard_câmeras[ A_index ].guid, "guid" )	;	busca o INDEX no map de câmeras do BD com GUID igual ao da câmera atual do dguard

			if ( index = 0 )	{	;	câmera nova(não consta no map do banco de dados)
				Gosub,	câmera_nova
				Continue
				}
			if (dguard_câmeras[ A_index ].name			!= bd_câmeras[ index ].name
				&&	name		= 1)
				Gosub, name

			if (dguard_câmeras[ A_index ].active		!= bd_câmeras[ index ].active
				&&	active		= 1)
				Gosub, active

			if (dguard_câmeras[ A_index ].address		!= bd_câmeras[ index ].address
				&&	address		= 1)
				Gosub, address

			if (dguard_câmeras[ A_index ].port			!= bd_câmeras[ index ].port
				&&	port		= 1)
				Gosub, port

			if (dguard_câmeras[ A_index ].id			!= bd_câmeras[ index ].id
				&&	id			= 1)
				Gosub, id

			if (dguard_câmeras[ A_index ].vendor		!= bd_câmeras[ index ].vendor
				&&	vendor		= 1)
				Gosub, vendor

			if (dguard_câmeras[ A_index ].receiver		!= bd_câmeras[ index ].receiver
				&&	receiver	= 1)
				Gosub, receiver

			if (dguard_câmeras[ A_index ].contactid		!= bd_câmeras[ index ].contactid
				&&	contactid	= 1)
				Gosub, contactid

			if (dguard_câmeras[ A_index ].partition		!= bd_câmeras[ index ].partition
				&&	partition	= 1)
				Gosub, partition

			; /*
			if (dguard_câmeras[ A_index ].offline		!= bd_câmeras[ index ].offline
				&&	offline		= 1)	{	;	Lógica de conexão
				off_change	:=	1
				Gosub, offline
				}
				Else
					off_change := 0
				; */

			; /*
			if (dguard_câmeras[ A_index ].recording		!= bd_câmeras[ index ].recording
				&&	recording	= 1)
				Gosub, recording
				; */

			; /*
			if (dguard_câmeras[ A_index ].connected		!= bd_câmeras[ index ].connected
				&&	connected	= 1)
				Gosub, connected
				; */

			if (dguard_câmeras[ A_index ].server		!= bd_câmeras[ index ].server
				&&	server		= 1)
				Gosub, server

			if (dguard_câmeras[ A_index ].operador		!= bd_câmeras[ index ].operador
				&&	operador	= 1)
				Gosub, operador

			if (dguard_câmeras[ A_index ].sinistro		!= bd_câmeras[ index ].sinistro
				&&	sinistro	= 1)
				Gosub, sinistro

			if (dguard_câmeras[ A_index ].api_get		!= bd_câmeras[ index ].api_get
				&&	api_get		= 1)
				Gosub, api_get
		}
		OutputDebug % "Fim do loop."
	;

	;	Verifica Removida:
		OutputDebug % "Verificando câmeras excluídas"
		Loop,%	bd_câmeras.Count()	{
			OutputDebug % asdfasdfd
			index	:=	array.InDict( dguard_câmeras, bd_câmeras[ A_index ].guid, "guid" )
			if ( index != 0 )
				Continue
			guid	:=	bd_câmeras[ A_index ].guid
			d =
				(
					DELETE FROM
						[Dguard].[dbo].[cameras]
					WHERE
						[guid] = '%guid%'
				)			
			if ( no_sql != 1 )
				sql( d , 3 )
			if ( StrLen( sql_le ) > 0 )	{
				Clipboard := u
				MsgBox % sql_le "`n" dguard_câmeras[ A_index ].offline
			}
			pre	:=	"[n]<b>" bd_câmeras[ A_index ].name "</b>[n]└┬[t]<b>Excluída</b>[n][t] └─  Servidor:   <code>" bd_câmeras[ A_index ].server "</code>"
			câmera_removida	=	1
			StrRep( pre, , "[n]:`n", "[t]:`t" )
			Gosub, update
		}
		Gosub, send
	Return

	câmera_nova:

		new_cam			:=	1

		name			:=	dguard_câmeras[ A_index ].Name
		guid			:=	dguard_câmeras[ A_index ].guid
		active			:=	dguard_câmeras[ A_index ].active
		connected		:=	dguard_câmeras[ A_index ].connected
		ip				:=	dguard_câmeras[ A_index ].address
		port			:=	dguard_câmeras[ A_index ].port
		vendormodel		:=	dguard_câmeras[ A_index ].vendor
		contactid		:=	dguard_câmeras[ A_index ].contactid
		offlinesince	:=	dguard_câmeras[ A_index ].offline	= ""
																? "NULL"
																; : "CAST('" SubStr( dguard_câmeras[ A_index ].offline , 7 , 4 ) "-" SubStr( dguard_câmeras[ A_index ].offline , 4 , 2 ) "-" SubStr( dguard_câmeras[ A_index ].offline , 1 , 2 ) " " SubStr( dguard_câmeras[ A_index ].offline , 12 ) "' as datetime)'"
																: dguard_câmeras[ A_index ].offline
		operador		:=	dguard_câmeras[ A_index ].operador
		sinistro		:=	dguard_câmeras[ A_index ].sinistro
		server			:=	dguard_câmeras[ A_index ].server
		api_get			:=	dguard_câmeras[ A_index ].api_get
		receiver		:=	dguard_câmeras[ A_index ].receiver
		partition		:=	dguard_câmeras[ A_index ].partition
		id				:=	dguard_câmeras[ A_index ].id
		recording		:=	dguard_câmeras[ A_index ].recording
		value_dg		:=	dguard_câmeras[ A_index ].name
		pre				:=	"[n]┌<b><u>[t]" name "</u></b>"
						.	"[n]└┬[t]<b>Cadastrada</b> no Servidor<code> " server "</code>"
						.	"[n][t] ├─┬[t]<b>IP</b>"
						.	"[n][t] │ [t]└─[t]" IP
						.	"[n][t] ├─┬[t]<b>Operador</b>"
						.	"[n][t] │ [t]└─[t]" operador
						.	"[n][t] ├─┬[t]<b>Sinistro</b>"
						.	"[n][t] │ [t]└─[t]" sinistro
						; .	"[n][t] ├─┬[t]<b>Servidor"
						; .	"[n][t] │ [t]└─[t]" server
						.	"[n][t] ├─┬[t]<b>Receptora</b>"
						.	"[n][t] │ [t]└─[t]" receiver
						.	"[n][t] ├─┬[t]<b>Partição</b>"
						.	"[n][t] │ [t]└─[t]" partition
						.	"[n][t] └─┬[t]<b>ID</b>"
						.	"[n][t][t][t][t] └─[t]" ID

		if ( offlinesince != "NULL" )
			offlinesince	:= "CAST('" offlinesince "' as datetime)"
		i	=
			(
				INSERT INTO
					[Dguard].[dbo].[cameras]
						(	[name]
						,	[guid]
						,	[active]
						,	[connected]
						,	[ip]
						,	[port]
						,	[vendormodel]
						,	[contactId]
						,	[offlineSince]
						,	[operador]
						,	[sinistro]
						,	[server]
						,	[api_get]
						,	[receiver]
						,	[partition]
						,	[recording]
						,	[id]	)
					VALUES
						(	 '%name%'			--name
							,'%guid%'			--guid
							,'%active%'			--active
							,'%connected%'		--connected
							,'%ip%'				--ip
							,'%port%'			--port
							,'%vendormodel%'	--vendor
							,'%contactid%'		--contactid
							,%offlinesince%		--offline
							,'%operador%'		--operador
							,'%sinistro%'		--sinistro
							,'%server%'			--server
							,'%api_get%'		--api
							,'%receiver%'		--receiver
							,'%partition%'		--partition
							,'%recording%'		--recording
							,'%id%'	)			--id	;

					INSERT INTO [ASM].[dbo].[_agenda]
						([mensagem]
						,[inserido]
						,[gerado_por]
						,[id_cliente]
						,[estacao]
						,[operador])
					VALUES
						('Adicionado a câmera:`n`n%name%'
						,getdate()
						,'Sistema de Notificação Automatizado'
						,'232'
						,'Sistema Monitoramento'
						,'0')	;
			)
		if ( no_sql != 1 )
			sql( i , 3 )
		if ( StrLen( sql_le ) > 0 ) {
			MsgBox % sql_le "`n`n" Clipboard := i
		}
		câmera_nova = 1
		set	:=	"name"
		Gosub, update
	Return

	;	Valida dados
		name:		;	18/11
			set		:=	"name"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>[n]└┬[t]<b>Nome</b>[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ index ].name
			value_dg:=	dguard_câmeras[ A_index ].name
			Gosub,	update
		Return

		active:		;	18/11
			set		:=	"active"
			pre		:=	"[n]┌<b>" dguard_câmeras[ A_index ].name "</b>"
					.	"[n]└┬   <b>Status de Ativação<b\>[n]"
					.	"[t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ index ].active
			value_dg:=	dguard_câmeras[ A_index ].active
			Gosub,	update
		Return

		address:	;	18/11
			set		:=	"ip"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>Endereço IP</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ index ].address
			value_dg:=	dguard_câmeras[ A_index ].address
			Gosub,	update
		Return

		port:		;	18/11
			set		:=	"port"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>Porta de Conexão</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	
			value_dg:=	dguard_câmeras[ A_index ].port
			Gosub,	update
		Return

		id:			;	18/11
			set		:=	"id"
			value_dg:=	dguard_câmeras[ A_index ].id
			value_bd:=	bd_câmeras[ index ].id
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>ID</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			Gosub,	update
		Return

		vendor:		;	18/11
			set		:=	"vendormodel"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>Modelo</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ index ].vendor
			value_dg:=	dguard_câmeras[ A_index ].vendor
			Gosub,	update
		Return

		receiver:	;	18/11
			set		:=	"receiver"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>Receptora</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ index ].receiver
			value_dg:=	dguard_câmeras[ A_index ].receiver
			Gosub,	update
		Return

		contactid:	;	18/11
			set		:=	"contactid"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>ContactID</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ index ].contactid
			value_dg:=	dguard_câmeras[ A_index ].contactid
			Gosub,	update
		Return

		partition:	;	18/11
			set		:=	"partition"
			value_dg:=	dguard_câmeras[ A_index ].partition
			value_bd:=	bd_câmeras[ index ].partition
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>Partição</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			Gosub,	update
		Return

		offline:	;	18/11
			set		:=	"offlineSince"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>"  "Offline" "</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ index ].offline
			value_dg:=	dguard_câmeras[ A_index ].offline	= ""
															? "NULL"
															: dguard_câmeras[ A_index ].offline
			Gosub,	update
		Return

		recording:	;	18/11
			set		:=	"recording"
			; pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					; .	"[n]└┬[t]<b>Status de Gravação</b>"
					; .	"[n]├─[t]Antigo[t]<code>"
			value_bd:=	bd_câmeras[ index ].recording
			value_dg:=	dguard_câmeras[ A_index ].recording
			if ( off_change = 0 )
				Gosub,	update
		Return

		connected:	;	18/11
			set		:=	"connected"
			; pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					; .	"[n]└┬[t]<b>Status de Conexão</b>"
					; .	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ index ].connected
			value_dg:=	dguard_câmeras[ A_index ].connected
			if ( off_change = 0 )
				Gosub,	update
		Return

		server:		;	18/11
			set		:=	"server"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]Alterado do <b>Servidor</b> "
			value_bd:=	bd_câmeras[ index ].server
			value_dg:=	dguard_câmeras[ A_index ].server
			Gosub,	update
		Return

		operador:	;	18/11
			set		:=	"operador"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>Operador</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ index ].operador
			value_dg:=	dguard_câmeras[ A_index ].operador
			Gosub,	update
		Return

		sinistro:	;	18/11
			set		:=	"sinistro"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>Operador de Sinistro</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ index ].sinistro
			value_dg:=	dguard_câmeras[ A_index ].sinistro
			Gosub,	update
		Return

		api_get:	;	18/11
			set		:=	"api_get"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>API GET</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ index ].api_get
			value_dg:=	dguard_câmeras[ A_index ].api_get
			Gosub,	update
		Return
	;

	Send:
		OutputDebug % "Preparando mensagens para envio para o Telegram" 
		if ( InStr( mensagens, "º") > 1 )
			mensagem := StrSplit( mensagens , "º")
			Else
				mensagem := StrSplit( SubStr( mensagens, -1 ) , "º")
		Loop,%	mensagem.Count()
			for_order.Push( mensagem[ A_Index ] )
		; mensagens_telegram := array.sort( for_order )
		
		OutputDebug % "Iniciando envio de mensagens para o Telegram.`n`tMensagens a serem enviadas = " mensagens_telegram.Count()-1
		mensagens_telegram := array.sort( for_order, , , , 14 )
		Loop,%	mensagens_telegram.Count()-1
			Run,% path_notificador "notificador_telegram." ext " """ mensagens_telegram[ A_Index ] """ ""parse_mode=html"" """ teste """"
		OutputDebug % timer("Fim")
	; Return
	ExitApp


	update:
		; Return
		guid		:=	dguard_câmeras[ A_index ].guid
		tel_value	:=	value_dg	;	prepara variável para o telegram

		if ( câmera_nova != 1
		&& InStr( mensagens , pre . value_bd ) = 0)
			mensagens	.= pre . value_bd "</code>[n][t][t][t]└[t]Novo:     <code>" tel_value "</code>º"
		Else if	(	câmera_nova = 1
		&&			InStr( mensagens , pre ) = 0) {
			câmera_nova = 0
			mensagens	.= pre "º"
		}
		if ( set = "offlineSince"  && value_dg != "NULL" ) {
			if (value_dg = "" )
				value_dg := "NULL"
			Else
				value_dg	:=	"CAST(	'"	SubStr( dguard_câmeras[ A_index ].offline , 1 , 4 )
							.			"-" SubStr( dguard_câmeras[ A_index ].offline , 6 , 2 )
							.			"-" SubStr( dguard_câmeras[ A_index ].offline , 9 , 2 )
							.			" " SubStr( dguard_câmeras[ A_index ].offline , 12 ) "' AS datetime)"
		}
		if (value_dg = "NULL"
		||	InStr(value_dg, "CAST(") != 0 )
			u	=
				(
					UPDATE
						[Dguard].[dbo].[cameras]
					SET
						[%set%]	=	%value_dg%
					WHERE
						[guid]	=	'%guid%'
				)
		Else
			u	=
				(
					UPDATE
						[Dguard].[dbo].[cameras]
					SET
						[%set%]	=	'%value_dg%'
					WHERE
						[guid]	=	'%guid%'
				)
		if ( no_sql != 1 )
			sql( u , 3 )
		if ( StrLen( sql_le ) > 0 )	{
			Clipboard := u
			MsgBox % sql_le "`n" dguard_câmeras[ A_index ].offline
		}
	Return
;

;	-GuiClose
	;
;