Global	sql_le
	,	sql_lq

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

Class	Folder	{
	
	Clear( dir )	{
		Loop, %dir%\*.*, 2 
		{
			FileDelete,%	dir "\DVRWorkDirectory"
			FileDelete,%	dir "\IPCWorkDirectory"
			FileDelete,%	A_LoopFileFullPath "\DVRWorkDirectory"
			FileDelete,%	A_LoopFileFullPath "\IPCWorkDirectory"
			This.Clear( A_LoopFileFullPath )
		}
		FileRemoveDir,%	A_LoopFileFullPath, 1
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