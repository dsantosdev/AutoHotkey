File_Version=0.0.0.0
Save_to_Sql=0
;	DEFASADO - UTILIZAR CAMERAS DGUARD

;@Ahk2Exe-SetMainIcon	C:\AHK\icones\srv.ico
;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
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
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

;	Configurações
	; #NoTrayIcon
	#SingleInstance, Force

	show_tooltip	:=	A_Args[1]	;	recebe o argumento 1 para exibir
		if ( A_UserName = "dsantos" )
			show_tooltip = 1
		CoordMode, ToolTip, Screen

	if ( A_IsCompiled = 1 )
		ext	=	exe
	Else
		ext = ahk

;

;	Code
	Loop,	4	{
		token	:=	dguard.token( "vdm0" A_Index )
		v		:=	dguard.cameras( "vdm0" A_Index, token )						;	Objeto tipo MAP
		index	:=	A_Index
		Loop,%	v.servers.Count()	{
			name		:= v.servers[A_index].name
			guid		:= v.servers[A_index].guid
			active		:= v.servers[A_index].active							;	Coluna contactid
			connected	:= v.servers[A_index].connected
			guid		:=	strRep( guid, , "{", "}" )							;	REMOVER AO RECRIAR A TABELA	-	Nome e guid
				remove_deletados .= "'" guid "',"
				i	=
					(
						IF NOT EXISTS ( SELECT * FROM [Dguard].[dbo].[cameras] WHERE [guid] = '%guid%' )

							INSERT INTO [Dguard].[dbo].[cameras]
								( name,		guid,		active,		connected )
							VALUES
								( '%name%', '%guid%',	'%active%', '%connected%' )

						ELSE

							UPDATE [Dguard].[dbo].[cameras]
							SET [name]		=	'%name%',
								[active]	=	'%active%',
								[connected]	=	'%connected%'
							WHERE	[guid]	=	'%guid%'

					)
				sql( i , 3 )
				if (StrLen( sql_le )
				&&	A_IsCompiled )
					MsgBox % "ERRO AO INSERIR OU ATUALIZAR GUID E NAME`n`n" sql_le "`n" Clipboard := sql_lq

			m			:=	dguard.cameras_info( "vdm0" index, guid , token )	;	Objeto tipo ARRAY	-	Dados das câmeras
				address		:= m.server.address
				notes		:= m.server.notes	;	45 = operador 4, sinistro 5	↓
					operador	:=	SubStr( notes, 1, 1)
					sinistro	:=	SubStr( notes, 2, 1)
				port		:= m.server.port
				recording	:= m.server.recording
				url			:= m.server.url = "" ? "http://" address ":" port : m.server.url
				; MsgBox % "-" url "-`n" m.server.url 
				vendormodel	:= m.server.vendormodelname
				offlineSince:= m.server.offlineSince	=	"-"
														?	"NULL"
														:	"'" datetime("1", m.server.offlineSince ) "'"
				i	=
					(
						UPDATE	[Dguard].[dbo].[cameras]
						SET		[ip]			=	'%address%',
								[operador]		=	'%operador%',
								[sinistro]		=	'%sinistro%',
								[port]			=	'%port%',
								[recording]		=	'%recording%',
								[url]			=	'%url%',
								[vendormodel]	=	'%vendormodel%',
								[server]		=	'%index%',
								[offlineSince]	=	%offlineSince%	--ASPAS VAI NA VAR
						WHERE	[guid]			=	'%guid%'
					)
					sql( i, 3 )
					if strlen( sql_le )
						MsgBox % "ERRO AO ATUALIZAR DADOS DAS CÂMERAS`n`n" sql_le "`n" Clipboard := sql_lq
			r			:=	dguard.contact_id( "vdm0" index, guid , token )		;	Objeto tipo ARRAY	-	contact id info
				receiver	:= r.contactid.receiver
				account		:= r.contactid.account
				partition	:= r.contactid.partition

				i	=
					(
						UPDATE	[Dguard].[dbo].[cameras]
						SET		[receiver]	=	'%receiver%',
								[contactid]	=	'%account%',
								[partition]	=	'%partition%'
						WHERE	[guid]		=	'%guid%'
					)
					sql( i, 3 )
					if (strlen( sql_le )
					&&	A_IsCompiled )
						MsgBox % "ERRO AO ATUALIZAR CONTACT ID DAS CÂMERAS`n`n" sql_le "`n" Clipboard := sql_lq
		}
	}

	remove_deletados :=	SubStr( remove_deletados, 1, -1 )
		d	=
			(
				DELETE FROM [Dguard].[dbo].[cameras]
				WHERE guid NOT IN ( %remove_deletados% )
			)
		sql( d, 3 )
		if ( strlen( sql_le )
		&&	A_IsCompiled )
			MsgBox % "ERRO AO DELETAR CÂMERAS NÃO MAIS EXISTENTES NO DGUARD`n`n" sql_le "`n" Clipboard := sql_lq
	ExitApp
;