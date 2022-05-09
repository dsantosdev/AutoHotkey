File_Version=0.0.0.16
Save_To_Sql=1
;@Ahk2Exe-SetMainIcon C:\AHK\icones\fun\cam.ico

;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;
	timer("Inicio")

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
	software		=	câmeras_dguard
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
	OutputDebug % "Carregando banco de dados"
		timer("carrega informações e configurações do banco de dados")
		Gosub,	banco_de_dados
		OutputDebug % "banco de dados carregado"

	OutputDebug % "Carregando Keys"
		timer("carrega keys")
		Gosub,	keys
		OutputDebug % "Keys carregadas"

	OutputDebug % "Carregando servidores do d-guard"
		timer("carrega informações dos servidores")
		Gosub,	servidores
		OutputDebug % "Servidores D-Guard carregados"

	OutputDebug % "Iniciando comparação de dados"
		timer("compara informações do banco de dados com as dos servidores")
		Gosub,	comparar_dados
		OutputDebug % "Comparação de dados finalizada"

	OutputDebug % timer("finalizado")
	ExitApp
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
					[Dguard].[dbo].[Cameras]
				ORDER BY
					1
			)
		bd := sql( s, 3 )
		Loop,%	bd.Count()-1 {
			; OutputDebug %  bd[ A_Index+1 , 2 ] "[t]" bd[ A_Index+1 , 1 ]
			bd_câmeras.Push({	name		:	bd[ A_Index+1 , 1 ]		;	Insere as informações no map para comparação posterior
							,	guid		:	bd[ A_Index+1 , 2 ]
							,	active		:	bd[ A_Index+1 , 3 ]	=	"-1"
																	?	"True"
																	:	"False"
							,	connected	:	bd[ A_Index+1 , 4 ]	=	"-1"
																	?	"True"
																	:	"False"
							,	address		:	bd[ A_Index+1 , 5 ]
							,	port		:	bd[ A_Index+1 , 6 ]
							,	id			:	bd[ A_Index+1 , 7 ]
							,	vendor		:	bd[ A_Index+1 , 8 ]
							,	receiver	:	bd[ A_Index+1 , 9 ]
							,	contactid	:	bd[ A_Index+1 , 10]
							,	partition	:	bd[ A_Index+1 , 11]
							,	offline		:	bd[ A_Index+1 , 12]	= ""
																	? "NULL"
																	: SubStr( bd[ A_Index+1 , 12 ] , 7 , 4 )
																		.	"/" SubStr( bd[ A_Index+1 , 12 ] , 4 , 2 )
																		.	"/" SubStr( bd[ A_Index+1 , 12 ] , 1 , 2 )
																		.	" " SubStr( bd[ A_Index+1 , 12 ] , 12 )
							,	server		:	bd[ A_Index+1 , 13]
							,	operador	:	bd[ A_Index+1 , 14]
							,	sinistro	:	bd[ A_Index+1 , 15]
							,	url			:	bd[ A_Index+1 , 16]
							,	api_get		:	bd[ A_Index+1 , 17]
							,	recording	:	bd[ A_Index+1 , 18]	=	"-1"
																		?	"True"
																		:	"False"	})
		}
	;

	;	Configurações de variáveis pelo bd	-	 PERTENCE A SEQUENCIA ACIMA
		s =
			(
				SELECT	[software]
					,	[vars]
				FROM
					[ASM].[dbo].[Software_Config]
				WHERE
					[Software] = '%software%'
				OR
					[Software] = 'servidores'
			)
		config	:= sql( s , 3 )
		Loop,%	config.Count()-1 {
			configs	:= StrSplit( config[ A_Index+1 , 2 ] , ";" )
			Loop,% configs.Count()	{
				definition	:= StrSplit( configs[ A_index ] , "=" )
				var			:= definition[1]
				%var%		:= definition[2]
			}
		}		
	Return

	keys:
		Loop,%	servidores {
			if StrLen( A_Index ) = 2
				indice := A_index
			Else
				indice := "0" A_index
			key_vdm%indice%	:=	dguard.token(	"vdm" indice ".cotrijal.local" 
											,	senha
											,	login	)
			Gosub, % StrLen( key_vdm%indice% )	= 0
												? "ExitApp"
												: "KeyOk"

		}
		
		Menu, Tray, Tip , Atualizador [dguard].[dbo].[cameras]`nVersão %Current_Version%
		Return

		ExitApp:
			MsgBox Falha ao resgatar key do servidor %indice%
			ExitApp

		keyOk:
			OutputDebug %	"`tChave Server " A_Index " Ok"
	Return

	servidores:
		if	testar
			servidores = 1

		Loop,%	servidores	{
			if StrLen( A_Index ) = 2
				indice := A_index
			Else
				indice := "0" A_index

			cameras	:=	dguard.cameras( "vdm" indice, key_vdm%indice% )
				OutputDebug % "`t" cameras.servers.Count() " a serem inseridas no map"
			Loop,%	cameras.servers.Count()	{	;	câmeras do dguard para o map
				guid			:= StrRep(	cameras.servers[A_Index].guid
									,
									,	"{"
									,	"}" )
				remove_deletados.= "'" guid "',"

				receiver		:= dguard.contact_id( "vdm" indice ".cotrijal.local", guid, key_vdm%indice% )
				info			:= dguard.cameras_info( "vdm" indice											;	dados da câmera seleciona
											,	guid
											,	key_vdm%indice% )
				for_id			:= StrSplit( info.server.address , "." )
				dguard_câmeras.Push({	name		:	info.server.name										;	Insere as informações no map para comparação posterior
									,	guid		:	guid
									,	active		:	info.server.active
									,	connected	:	info.server.connected
									,	address		:	info.server.address
									,	port		:	info.server.port
									,	id			:	for_id[3]
									,	vendor		:	info.server.vendorModelName
									,	receiver	:	receiver.contactId.receiver
									,	contactid	:	info.server.contactIdCode
									,	partition	:	receiver.contactId.partition
									,	offline		:	info.server.offlineSince	= "-"
																					? "NULL"
																					: DateTime( 1, info.server.offlineSince )
									,	server		:	indice
									,	type		:	info.server.type	=	"0"
																			?	"IPC"
																			:	"DVR"
									,	operador	:	SubStr( info.server.notes , 1 , 1 ) = "" ? "0" : SubStr( info.server.notes , 1 , 1 )
									,	sinistro	:	SubStr( info.server.notes , 2 , 1 ) = "" ? "0" : SubStr( info.server.notes , 2 , 1 )
									,	url			:	StrRep( info.server.url,, "\" )
									,	api_get		:	receiver.contactId.receiver != "10001"
																					?	"http://conceitto:cjal2021@vdm" indice ".cotrijal.local:85/camera.cgi?receiver=" receiver.contactId.receiver "&server=" info.server.contactIdCode "&camera=0&resolucao=640x480&qualidade=100"
																					:	""
									,	recording	:	info.server.recording	})
				;
			}
		}
	Return
	
	comparar_dados:
		OutputDebug % "`tCâmeras no Banco de Dados`t= " bd.Count()-1
		OutputDebug % "`tCâmeras no dguard`t`t= " dguard_câmeras.Count()

		; msgbox %	dguard_câmeras.Count() "`n" bd_câmeras.Count()
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
	;

	;	Verifica Removida:
		timer("verifica câmeras removidas")
		OutputDebug % "Verificando câmeras excluídas"

		if	testar
			Goto send

		remove_deletados :=	SubStr( remove_deletados, 1, -1 )
			If	!A_IsCompiled
				Clipboard := remove_deletados

		select_deleted	=
			(
				SELECT
					 [guid]
					,[name]
					,[server]
				FROM
					[Dguard].[dbo].[cameras]
				WHERE
					[guid] NOT IN ( %remove_deletados% );
			)
		deleted_cam	:=	sql( select_deleted )
		d	=
			(
				DELETE FROM [Dguard].[dbo].[cameras]
				WHERE guid NOT IN ( %remove_deletados% )
			)
		sql( d, 3 )

		Loop,%	deleted_cam.Count()-1 {
			index			:=	array.InDict( dguard_câmeras, deleted_cam[ A_index+1, 1 ], "guid" )
			name_excluded	:=	dguard_câmeras[ index ].name
			MsgBox % name_excluded
			pre				:=	"[n]<b>" deleted_cam[ A_index+1, 2 ] "</b>[n]└┬[t]<b>Excluída</b>[n][t] └─  Servidor:   <code>" deleted_cam[ A_index+1, 3 ] "</code>"
			notifica_email	=
				(
					INSERT INTO [ASM].[dbo].[_agenda]
						([mensagem]
						,[inserido]
						,[gerado_por]
						,[id_cliente]
						,[estacao]
						,[operador])
					VALUES
						('Câmera excluída:`n`n%name%'
						,getdate()
						,'Sistema de Notificação Automatizado'
						,'232'
						,'Sistema Monitoramento'
						,'0')	;
				)
			câmera_removida	=	1
			StrRep( pre, , "[n]:`n", "[t]:`t" )
		}
		Gosub Send
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

		if ( offlinesince	!= "NULL" )
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
		if ( StrLen( sql_le ) > 0 )
			MsgBox % sql_le "`n`n" Clipboard := i
		câmera_nova = 1
		set	:=	"name"
		Gosub, update
	Return

	;	Valida dados
		name:		;	18/11
			set		:=	"name"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>[n]└┬[t]<b>Nome</b>[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ indice ].name
			value_dg:=	dguard_câmeras[ A_index ].name
			Gosub,	update
		Return

		active:		;	18/11
			set		:=	"active"
			pre		:=	"[n]┌<b>" dguard_câmeras[ A_index ].name "</b>"
					.	"[n]└┬   <b>Status de Ativação</b>[n]"
					.	"[t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ indice ].active
			value_dg:=	dguard_câmeras[ A_index ].active
			Gosub,	update
		Return

		address:	;	18/11
			set		:=	"ip"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>Endereço IP</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ indice ].address
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
			value_bd:=	bd_câmeras[ indice ].id
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
			value_bd:=	bd_câmeras[ indice ].vendor
			value_dg:=	dguard_câmeras[ A_index ].vendor
			Gosub,	update
		Return

		receiver:	;	18/11
			set		:=	"receiver"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>Receptora</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ indice ].receiver
			value_dg:=	dguard_câmeras[ A_index ].receiver
			Gosub,	update
		Return

		contactid:	;	18/11
			set		:=	"contactid"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>ContactID</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ indice ].contactid
			value_dg:=	dguard_câmeras[ A_index ].contactid
			Gosub,	update
		Return

		partition:	;	18/11
			set		:=	"partition"
			value_dg:=	dguard_câmeras[ A_index ].partition
			value_bd:=	bd_câmeras[ indice ].partition
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
			value_bd:=	bd_câmeras[ indice ].offline
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
			value_bd:=	bd_câmeras[ indice ].recording
			value_dg:=	dguard_câmeras[ A_index ].recording
			if ( off_change = 0 )
				Gosub,	update
		Return

		connected:	;	18/11
			set		:=	"connected"
			; pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					; .	"[n]└┬[t]<b>Status de Conexão</b>"
					; .	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ indice ].connected
			value_dg:=	dguard_câmeras[ A_index ].connected
			if ( off_change = 0 )
				Gosub,	update
		Return

		server:		;	18/11
			set		:=	"server"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]Alterado do <b>Servidor</b><code>"
			value_bd:=	bd_câmeras[ indice ].server
			value_dg:=	dguard_câmeras[ A_index ].server
			Gosub,	update
		Return

		operador:	;	18/11
			set		:=	"operador"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>Operador</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ indice ].operador
			value_dg:=	dguard_câmeras[ A_index ].operador
			Gosub,	update
		Return

		sinistro:	;	18/11
			set		:=	"sinistro"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>Operador de Sinistro</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ indice ].sinistro
			value_dg:=	dguard_câmeras[ A_index ].sinistro
			Gosub,	update
		Return

		api_get:	;	18/11
			set		:=	"api_get"
			pre		:=	"[n]┌<b><u>[t]" dguard_câmeras[ A_index ].name "</u></b>"
					.	"[n]└┬[t]<b>API GET</b>"
					.	"[n][t] └┬  Antigo:   <code>"
			value_bd:=	bd_câmeras[ indice ].api_get
			value_dg:=	dguard_câmeras[ A_index ].api_get
			Gosub,	update
		Return
	;

	Send:
		timer("Envia Telegram")
		OutputDebug % "Preparando mensagens para envio para o Telegram"
		if ( InStr( mensagens, "º") > 1 )
			mensagem := StrSplit( mensagens , "º")
			Else
				mensagem := StrSplit( SubStr( mensagens, -1 ) , "º")
		Loop,%	mensagem.Count()
			for_order.Push( mensagem[ A_Index ] )
		; mensagens_telegram := array.sort( for_order )

		mensagens_telegram := array.sort( for_order, , , , 14 )
		OutputDebug % "Iniciando envio de mensagens para o Telegram.`n`tMensagens a serem enviadas = " mensagens_telegram.Count() ""
		Loop,%	mensagens_telegram.Count()
			if !testar
				telegram.SendMessage( mensagens_telegram[ A_Index ] , "parse_mode=html", "chat_id=" chat_id )
			Else
				telegram.SendMessage( mensagens_telegram[ A_Index ] , "parse_mode=html", "chat_id=" chat_id_test )
		OutputDebug % timer("Fim")
	Return

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
		; MsgBox % set "`n" value_dg
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