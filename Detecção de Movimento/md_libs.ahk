Global	sql_le
	,	sql_lq
	,	ShowData

sql( query, type=1, Show_error="0" , update_in_query="0" ) {

	ListLines, Off
	;	ADOSQL modified
	if(		instr( query, "UPDATE" ) > 0 && instr( query, "WHERE" ) = 0
		&&	update_in_query = 0 )	{
		MsgBox,4 , ,% "Você está tentando executar um UPDATE sem definir WHERE`, deseja realmente continuar? Isso alterará TODOS os dados da tabela.`n`n`n" Query
		IfMsgBox,	No
			return
		}

		if( type = 1 )
			type	=	Driver={SQL Server};Server=srvvdm-bd\iris10db;Uid=ahk;Pwd=139565Sa

		else if( type = 2 )
			type	=	Driver={Oracle in ora_moni};dbq=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oraprod)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=prod)));Uid=asm;Pwd=cot2020asm

		else if( type = 3 )
			type	=	Driver={SQL Server};Server=srvvdm-bd\ASM;Uid=ahk;Pwd=139565Sa

		else {

			MsgBox type de conexão indefinido.
			return
		}

		if !InStr( query, "[ASM].[ASM]." )
			if( type = 1 )
				query := StrReplace( query, "[ASM].[dbo]", "[ASM].[ASM].[dbo]", , -1 )

		coer	:= ""
		str		:= type
		oTbl	:= 9

		ComObjError( 0 )	;	oculta erros

		If !( oCon := ComObjCreate( "ADODB.Connection" ) )
			Return "", ComObjError( 1 ), ErrorLevel := "Error"
			, sql_le := "Fatal Error: ADODB is not available."

		oCon.ConnectionTimeout	:= 9
		oCon.CursorLocation		:= 3
		oCon.CommandTimeout		:= 1800
		oCon.Open( str )

		If !( coer := A_LastError )
			oRec := oCon.execute( sql_lq := query )

		If !( coer	:= A_LastError )	{

			o3DA	:= []
			While	IsObject( oRec ) {
				If( !oRec.State )
					oRec := oRec.NextRecordset()
				Else	{
					oFld := oRec.Fields
					o3DA.Insert( oTbl := [] )
					oTbl.Insert( oRow := [] )
					Loop,% cols := oFld.Count
						oRow[ A_Index ] := oFld.Item( A_Index - 1 ).Name

					While !oRec.EOF
					{
						oTbl.Insert( oRow := [] )
						oRow.SetCapacity( cols )
						Loop % cols
							oRow[ A_Index ] := oFld.Item( A_Index - 1 ).Value

						oRec.MoveNext()
					}
					oRec := oRec.NextRecordset()
				}
			}
		}
		Else	{	;	Erros

			oErr	:= oCon.Errors
			query	:= "x"
			Loop,% oErr.Count	{

				oFld	:= oErr.Item( A_Index - 1 )
				str		:= oFld.Description
				query	.= "`n`n" SubStr( str, 1 + InStr( str, "]", 0, 2 + InStr( str, "][", 0, 0 ) ) )
						. "`n   Number: " oFld.Number
						. ", NativeError: " oFld.NativeError
						. ", Source: " oFld.Source
						. ", SQLState: " oFld.SQLState

			}
			sql_le	:= SubStr( query, 4 )
			query	:= ""
			txtout	:= 1

		}

		oCon.Close()
		ComObjError( 0 )
		ErrorLevel := coer
		if (	StrLen( sql_le ) > 0
			&&	StrLen( Show_error ) > 0
			&&	Show_error <> "0" )
			MsgBox % sql_le "`n" sql_lq

		ListLines, On

		Return	o3DA.Count() =	1
								?	o3DA[1]
								:	o3DA

}

datetime( sql=0, date="", format="" ) {

	sql	:= RegExReplace( sql, "[^\d]+" )
	date:= RegExReplace( date, "[^\d]+" )
	if Strlen( sql ) = 14	;	 se a data foi passada no campo de sql, ajusta as variáveis
		is_date:=sql, sql:=0, date:=is_date
	If(	sql = 2
	&&	StrLen( date ) = 0 )	{
		MsgBox,0x40,ERRO, A função datetime() em modo SQL 2`, necessita que seja enviado o valor date para funcionar.
		Return
	}
	If( sql = 1 )
		Return		SubStr( A_Now, 1, 4 ) "-"  SubStr( A_Now, 5, 2 ) "-"  SubStr( A_Now, 7, 2 )
			.	" " SubStr( A_Now, 9, 2 ) ":"  SubStr( A_Now, 11, 2) ":"  SubStr( A_Now, 13, 2 ) ".000"
	else If ( sql = 2 )
		Return		SubStr( date, 5, 4 ) "-"  SubStr( date, 3, 2 ) "-"  SubStr( date, 1, 2 )
			.	" " SubStr( date, 9, 2 ) ":"  SubStr( date, 11, 2) ":"  SubStr( date, 13, 2 )
	else If(	sql	=	3
	&&			date!=	"" )	;	valor passado junto
		Return		SubStr( date, 1, 4 ) "-"  SubStr( date, 5, 2 ) "-"  SubStr( date, 7, 2 )
			.	" " SubStr( date, 9, 2 ) ":"  SubStr( date, 11, 2) ":"  SubStr( date, 13, 2 )
	Else If(	sql	=	0
	&&			date!=  "")
		return		SubStr( date, 7, 2 ) "/"  SubStr( date, 5, 2 ) "/"  SubStr( date, 1, 4 )
			.	" " SubStr( date, 9, 2 ) ":"  SubStr( date, 11, 2) ":"  SubStr( date, 13, 2 )
	Else
		Return		SubStr( A_Now, 7, 2 ) "/"  SubStr( A_Now, 5, 2 ) "/"  SubStr( A_Now, 1, 4 )
			.	" " SubStr( A_Now, 9, 2 ) ":"  SubStr( A_Now, 11, 2) ":"  SubStr( A_Now, 13, 2 )

}

process_exist( process, pause = "0", server = "." ) {
	OutputDebug, % "SELECT * FROM Win32_Process WHERE Caption = '" StrRep(process,,".exe") ".exe'"
	for objItem in ComObjGet("winmgmts:\\" server "\root\CIMV2").ExecQuery("SELECT * FROM Win32_Process WHERE Caption = '" StrRep(process,,".exe") ".exe'")
	{
		if	Pause	{
			passed:= A_Now - SubStr( objItem.CreationDate, 1, 14 ) > pause ? 1 : pause - (A_Now - SubStr( objItem.CreationDate, 1, 14 ))
			Sleep,% passed "000"
		}
		return	StrLen( objItem.Caption ) = 0 ? 0 : 1
	}
}

StrRep( haystack , separator = ":" , needles* )	{

	for i, v in needles
	{
		if ( InStr( v , separator ) > 0 )	{
			SearchText	:= SubStr( v, 1 , InStr( v , separator )-1 )	
			ReplaceText := SubStr( v,InStr( v , separator )+1 )
		}
		Else	{
			SearchText	:=	v
			ReplaceText	:=	""
		}
		haystack := StrReplace( haystack, SearchText , ReplaceText )
	}
	Return haystack

}

sql_version()	{
	s =
		(
			DELETE FROM
				[ASM].[dbo].[Softwares]
			WHERE
				[PKID] NOT IN (SELECT TOP (1)
									[pkid]
								FROM
									[ASM].[dbo].[Softwares]
								WHERE
									[name] = 'preparaimagens'
								ORDER BY
									1
								DESC	)
			AND
				[Name] = 'preparaimagens';

			SELECT TOP (1)
				[version],
				[date]
			FROM
				[ASM].[dbo].[Softwares]
			WHERE
  				[name] = 'preparaimagens'
  			ORDER BY
			  	1
			DESC;
		)
	o := sql( s, 3 )
	Return	[o[2,1], o[2,2]]
}

wm_read(wParam, lParam)	{
    StringAddress := NumGet(lParam + 2*A_PtrSize)	; Retrieves the CopyDataStruct's lpData member.
    If StrGet(StringAddress)						; Copy the string out of the structure.
		ShowData = 1
	Else
		ShowData = 0
    return true										; Returning the message
}

wm_send(ByRef StringToSend, ByRef TargetScriptTitle)	{	; ByRef saves a little memory in this case.
/*
	This function sends the specified string to the specified window and returns the reply.
	The reply is 1 if the target window processed the message, or 0 if it ignored it.
 */
	VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0) 			; Set up the structure's memory area.
															; First set the structure's cbData member to the size of the string, including its zero terminator:
	SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
	NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)			; OS requires that this be done.
	NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)		; Set lpData to point to the string itself.
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows On
	SetTitleMatchMode 2
	TimeOutTime := 4000 									; Optional. Milliseconds to wait for response from receiver.ahk. Default is 5000
															; Must use SendMessage not PostMessage.
	SendMessage, 0x004A, 0, &CopyDataStruct,, %TargetScriptTitle%,,,, %TimeOutTime% ; 0x004A is WM_COPYDATA.
	DetectHiddenWindows %Prev_DetectHiddenWindows% 			; Restore original setting for the caller.
	SetTitleMatchMode %Prev_TitleMatchMode%					; Same.
	return ErrorLevel										; Return SendMessage's reply back to our caller.
}

Class	Folder	{
	
	Clear( dir )	{
		if !dir
			Return "Sem diretório definido"
		Loop, %dir%\*.*, 2 
		{
			FileDelete,%	dir "\DVRWorkDirectory"
			FileDelete,%	dir "\IPCWorkDirectory"
			FileDelete,%	A_LoopFileFullPath "\DVRWorkDirectory"
			FileDelete,%	A_LoopFileFullPath "\IPCWorkDirectory"
			This.Clear( A_LoopFileFullPath )
		}
		FileRemoveDir,%	dir, 1
		return
	}

}

Class	Mail	{

	new( to, subject, body, from := "", attach := "", cc* )	{
		if ( StrLen( from ) = 0 )
			from := """Sistema Monitoramento"" <do-not-reply@cotrijal.com.br>"
		Else
			from := """Sistema Monitoramento"" <" from ">"
		if cc
			Loop,% cc.Count()
				copia .= cc[ A_Index ] ","

		pmsg						:= ComObjCreate( "CDO.Message" )
		pmsg.From					:= from
		pmsg.To						:= to
		pmsg.CC						:= copia
		pmsg.Subject				:= subject
		pmsg.TextBody				:= body
		sAttach						:= attach

		fields						:= Object()
		fields.smtpserver			:= "mail.cotrijal.com.br"
		fields.smtpserverport		:= 587
		fields.smtpusessl			:= false
		fields.sendusing			:= 2
		fields.smtpauthenticate		:= 1
		fields.sendusername			:= "SistemaMonitoramento@cotrijal.com.br"
		fields.sendpassword			:= ""
		fields.smtpconnectiontimeout:= 10
		schema						:= "http://schemas.microsoft.com/cdo/configuration/"
		pfld 						:= pmsg.Configuration.Fields

		For	field, value in fields
			pfld.Item( schema field ) := value
		pfld.Update()


		Loop, Parse, sAttach, |, %A_Space%%A_Tab%
			pmsg.AddAttachment( A_LoopField )

		pmsg.Send()
		return
	}

}