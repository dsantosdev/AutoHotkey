/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\Documentos_importantes\Facilitador\Ferramentas\api - Atualiza banco dguard.ahk
Created_Date=1
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Description=Atualizador de dados das câmeras no banco de dados
File_Version=1.0.0.1
Inc_File_Version=1
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\Dih\zIco\fun\cor.ico

* * * Compile_AHK SETTINGS END * * *
*/

;@Ahk2Exe-SetMainIcon	C:\Dih\zIco\fun\cor.ico
	#Persistent
	#SingleInstance Force
	#Include ..\class\array.ahk
	; #Include ..\class\cor.ahk
	#Include ..\class\dguard.ahk
	#Include ..\class\functions.ahk
	; #Include ..\class\gui.ahk
	; #Include ..\class\mail.ahk
	; #Include ..\class\safedata.ahk
	; #Include ..\class\string.ahk
	#Include ..\class\sql.ahk
	; #Include ..\class\windows.ahk
;

;	Definições
	global	debug = 
		,	info_das_cameras := {}
;

;	Tokens dos servidores
	token_1 := Dguard.token( "vdm01" )
		OutputDebug % StrLen( token_1 ) > 0 ? "-Obtido token 1`n`t" token_1 		: "Falha ao obter token 1"
	token_2 := Dguard.token( "vdm02" )
		OutputDebug % StrLen( token_2 ) > 0 ? "-Obtido token 2`n`t" token_2		: "Falha ao obter token 2"
	token_3 := Dguard.token( "vdm03" )
		OutputDebug % StrLen( token_3 ) > 0 ? "-Obtido token 3`n`t" token_3 "`n" : "Falha ao obter token 3`n"
;

;	Informações das câmeras contidas no d-guard
		OutputDebug % "-Armazenando os dados das câmeras do dguard em array."
	dados_das_cameras_no_dguard := {}
	guid_das_cameras_no_dguard := {}

	json_return := json( Dguard.http( "http://vdm01:8081/api/servers", token_1 ) )
		OutputDebug % "-Armazenando os dados das câmeras do servidor 1 do dguard em array."
		Loop,% json_return.servers.Count()
			guid_das_cameras_no_dguard.Push( json_return.servers[A_index] )	;	prepara o map com as informações do dguard
		Loop,% guid_das_cameras_no_dguard.Count() {
			OutputDebug % qewr
			_guid := StrReplace( StrReplace( guid_das_cameras_no_dguard[A_Index].guid , "{") , "}" )
			json_camera := Dguard.Server( "vdm01" , _guid , token_1 )
			dados_das_cameras_no_dguard.Push({	name		:	json_camera.server.name
											,	guid		:	_guid
											,	active		:	json_camera.server.active
											,	connected	:	json_camera.server.connected
											,	address		:	json_camera.server.address
											,	port		:	json_camera.server.port
											,	vendor		:	SubStr( json_camera.server.vendor , 1 , InStr( json_camera.server.vendor , " ")-1 )
											,	contactid	:	json_camera.server.contactid
											,	recording	:	json_camera.server.recording
											,	offline		:	json_camera.server.offline
											,	setor		:	SubStr( json_camera.server.notes , 1 , 1 )
											,	sinistro	:	SubStr( json_camera.server.notes , 2 , 1 )
											,	url			:	StrReplace( json_camera.server.url , "\" )		})
	}

	json_return := json( Dguard.http( "http://vdm02:8081/api/servers", token_2 ) )
		OutputDebug % "-Armazenando os dados das câmeras do servidor 2 do dguard em array."
		guid_das_cameras_no_dguard := {}
		Loop,% json_return.servers.Count()
			guid_das_cameras_no_dguard.Push( json_return.servers[A_index] )	;	prepara o map com as informações do dguard
		Loop,% guid_das_cameras_no_dguard.Count() {
			OutputDebug % qewr
			_guid := StrReplace( StrReplace( guid_das_cameras_no_dguard[A_Index].guid , "{") , "}" )
			json_camera := Dguard.Server( "vdm02" , _guid , token_2 )
			dados_das_cameras_no_dguard.Push({	name		:	json_camera.server.name
											,	guid		:	_guid
											,	active		:	json_camera.server.active
											,	connected	:	json_camera.server.connected
											,	address		:	json_camera.server.address
											,	port		:	json_camera.server.port
											,	vendor		:	SubStr( json_camera.server.vendor , 1 , InStr( json_camera.server.vendor , " ")-1 )
											,	contactid	:	json_camera.server.contactid
											,	recording	:	json_camera.server.recording
											,	offline		:	json_camera.server.offline
											,	setor		:	SubStr( json_camera.server.notes , 1 , 1 )
											,	sinistro	:	SubStr( json_camera.server.notes , 2 , 1 )
											,	url			:	StrReplace( json_camera.server.url , "/" )		})
	}

	json_return := json( Dguard.http( "http://vdm03:8081/api/servers", token_3 ) )
		OutputDebug % "-Armazenando os dados das câmeras do servidor 3 do dguard em array."
		guid_das_cameras_no_dguard := {}
		Loop,% json_return.servers.Count()
			guid_das_cameras_no_dguard.Push( json_return.servers[A_index] )	;	prepara o map com as informações do dguard
		Loop,% guid_das_cameras_no_dguard.Count() {
			OutputDebug % qewr
			_guid := StrReplace( StrReplace( guid_das_cameras_no_dguard[A_Index].guid , "{") , "}" )
			json_camera := Dguard.Server( "vdm03" , _guid , token_3 )
			dados_das_cameras_no_dguard.Push({	name		:	json_camera.server.name
											,	guid		:	_guid
											,	active		:	json_camera.server.active
											,	connected	:	json_camera.server.connected
											,	address		:	json_camera.server.address
											,	port		:	json_camera.server.port
											,	vendor		:	SubStr( json_camera.server.vendor , 1 , InStr( json_camera.server.vendor , " ")-1 )
											,	contactid	:	json_camera.server.contactid
											,	recording	:	json_camera.server.recording
											,	offline		:	json_camera.server.offline
											,	setor		:	SubStr( json_camera.server.notes , 1 , 1 )
											,	sinistro	:	SubStr( json_camera.server.notes , 2 , 1 )
											,	url			:	StrReplace( json_camera.server.url , "/" )		})
	}
;

;	Loop para verificação de divergências
	Loop,%	dados_das_cameras_no_dguard.Count()	{
		nome		:=	dados_das_cameras_no_dguard[A_Index].name
		guid		:=	dados_das_cameras_no_dguard[A_Index].guid
		ip			:=	dados_das_cameras_no_dguard[A_Index].address
		port		:=	dados_das_cameras_no_dguard[A_Index].port
		status		:=	dados_das_cameras_no_dguard[A_Index].active
		connected	:=	dados_das_cameras_no_dguard[A_Index].connected
		modelo		:=	dados_das_cameras_no_dguard[A_Index].vendor
		setor		:=	dados_das_cameras_no_dguard[A_Index].setor
		sinistro	:=	dados_das_cameras_no_dguard[A_Index].sinistro
		offline		:=	dados_das_cameras_no_dguard[A_Index].offline
		url			:=	dados_das_cameras_no_dguard[A_Index].url
		rec			:=	dados_das_cameras_no_dguard[A_Index].rec
		MsgBox % nome "`n" guid "`n" ip "`n" port "`n" status "`n" connected "`n" modelo "`n" setor "`n" sinistro "`n" offline "`n" url "`n" rec
	}
;








;	Seleciona informaçõe das câmeras no bd
		OutputDebug % "-Selecionando informações das câmeras do banco de dados."
	; s =
		; (
		; SELECT	[pkid]
			; ,	[camera]
			; ,	[guid]
			; ,	[ip]
			; ,	[port]
			; ,	[mac]
			; ,	[server]
			; ,	[active]
			; ,	[connected]
			; ,	[brand]
			; ,	[operador]
			; ,	[sinistro]
		; FROM
			; [Dguard].[dbo].[Cameras]
		; ORDER BY	7
				; ,	2
		; )
	s =
	(
	SELECT	[id]
		,	[nome]
		,	[guid]
		,	[ip]
		,	[status]
		,	[connected]
		,	[modelo]
		,	[setor]
		,	[em_sinistro]
	FROM
		[MotionDetection].[dbo].[Cameras]
	WHERE
		LEN( [nome] ) > 3
	ORDER BY	7
			,	2
	)
	dados_das_cameras := sql( s , 3 )
		OutputDebug % "-Preparando o array com as informações das câmeras que estão no banco de dados e atualizando as informações."
	Loop,%	dados_das_cameras.Count()-1	{
		OutputDebug % asdf
		guid		:= Dguard.select_server( dados_das_cameras_no_dguard, dados_das_cameras[ A_Index+1, 2 ] , "name" , "guid"		, 0  )
		status		:= Dguard.select_server( dados_das_cameras_no_dguard, dados_das_cameras[ A_Index+1, 2 ] , "name" , "active"	, 0  )
		connected	:= Dguard.select_server( dados_das_cameras_no_dguard, dados_das_cameras[ A_Index+1, 2 ] , "name" , "connected"	, 0  )
		if ( dados_das_cameras[A_Index+1,2] = "" )
			Continue
		; info_das_cameras.push({	pkid		:	dados_das_cameras[A_Index+1,1]
							; ,	camera		:	StrReplace( RTRIM( LTRIM( dados_das_cameras[A_Index+1,2] , "`n" ) , "`n" ) , "-" , "|", , 1 )
							; ,	guid		:	guid		!= dados_das_cameras[A_Index+1,3] ? guid		: dados_das_cameras[A_Index+1,3]
							; ,	ip			:	dados_das_cameras[A_Index+1,4]
							; ,	port		:	dados_das_cameras[A_Index+1,5]
							; ,	mac			:	dados_das_cameras[A_Index+1,6]
							; ,	server		:	dados_das_cameras[A_Index+1,7]
							; ,	active		:	active		!= dados_das_cameras[A_Index+1,8] ? active		: dados_das_cameras[A_Index+1,8]
							; ,	connected	:	connected	!= dados_das_cameras[A_Index+1,9] ? connected	: dados_das_cameras[A_Index+1,9]
							; ,	brand		:	dados_das_cameras[A_Index+1,10]
							; ,	operador	:	dados_das_cameras[A_Index+1,11]
							; ,	sinistro	:	dados_das_cameras[A_Index+1,12]	})
		info_das_cameras.push({	id			:	dados_das_cameras[A_Index+1,1]
							,	name		:	StrReplace( RTRIM( LTRIM( dados_das_cameras[A_Index+1,2] , "`n" ) , "`n" ) , "-" , "|", , 1 )
							,	guid		:	guid		!= dados_das_cameras[A_Index+1,3] ? guid		: dados_das_cameras[A_Index+1,3]
							,	ip			:	dados_das_cameras[A_Index+1,4]
							,	mac			:	dados_das_cameras[A_Index+1,5]
							,	status		:	status		!= dados_das_cameras[A_Index+1,6] ? status		: dados_das_cameras[A_Index+1,6]
							,	connected	:	connected	!= dados_das_cameras[A_Index+1,7] ? connected	: dados_das_cameras[A_Index+1,7]
							,	modelo		:	dados_das_cameras[A_Index+1,8]
							,	setor		:	dados_das_cameras[A_Index+1,9]
							,	sinistro	:	dados_das_cameras[A_Index+1,10]	})
	}
;

;	Câmeras faltando no banco de dados
		OutputDebug % "Verificando câmeras não existentes na base de dados."
	Loop,%	dados_das_cameras_no_dguard.Count()	{
		if ( array.inDict( info_das_cameras, dados_das_cameras_no_dguard[A_Index].name, "name" ) = 0 )
			falta .= dados_das_cameras_no_dguard[A_Index].name "`n"
	}
	Clipboard := falta
	ExitApp
;

;	Busca as informações no dguard baseado no guid
;