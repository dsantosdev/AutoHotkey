Global sql_le, sql_lq
sql( query, tipo = 1, d = "" ) {
	;	ADOSQL modified
	if ( instr( query, "UPDATE" ) > 0 && instr( query, "WHERE" ) = 0 )	{
		MsgBox, Você está tentando executar um UPDATE sem definir WHERE`, deseja realmente continuar? Isso alterará TODOS os dados da tabela.
		IfMsgBox,	No
			return
		}
	if ( tipo = 1 )
		tipo=Driver={SQL Server};Server=srvvdm-bd\iris10db;Uid=ahk;Pwd=139565Sa
	else if ( tipo = 2 )
		tipo=Driver={Oracle in ora_moni};dbq=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oraprod)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=prod)));Uid=asm;Pwd=cot2020asm
	else if ( tipo = 3 )
		tipo=Driver={SQL Server};Server=srvvdm-bd\ASM;Uid=ahk;Pwd=139565Sa
	else {
		MsgBox Tipo de conexão indefinido.
		return
		}
	if !InStr( query, "[ASM].[ASM]." )
		if ( tipo = 1 )
			query := StrReplace( query, "[ASM].[dbo]", "[ASM].[ASM].[dbo]", , -1 )
	coer := "", txtout := 0, rd := "`n", cd := "CSV", str := tipo
	If ( 9 < oTbl := 9 + InStr( ";" str, ";RowDelim=" ) )	{
		rd := SubStr( str, oTbl, 0 - oTbl + oRow := InStr( str ";", ";", 0, oTbl ) )
		str := SubStr( str, 1, oTbl - 11 ) SubStr( str, oRow )
		txtout := 1
		}
	If ( 9 < oTbl := 9 + InStr( ";" str, ";ColDelim=" ) )	{
		cd := SubStr( str, oTbl, 0 - oTbl + oRow := InStr( str ";", ";", 0, oTbl ) )
		str := SubStr( str, 1, oTbl - 11 ) SubStr( str, oRow )
		txtout := 1
		}
	ComObjError( 0 )
	If !( oCon := ComObjCreate( "ADODB.Connection" ) )
		Return "", ComObjError( 1 ), ErrorLevel := "Error"
		, sql_le := "Fatal Error: ADODB is not available."
	oCon.ConnectionTimeout := 9
	oCon.CursorLocation := 3
	oCon.CommandTimeout := 1800
	oCon.Open(str)
	If !( coer := A_LastError )
		oRec := oCon.execute( sql_lq := query )
	If !( coer := A_LastError )	{
		o3DA := []
		While IsObject( oRec )
			If !oRec.State 
				oRec := oRec.NextRecordset()
			Else	{
				oFld := oRec.Fields
				o3DA.Insert( oTbl := [] )
				oTbl.Insert( oRow := [] )
				Loop % cols := oFld.Count
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
		If (txtout)	{
			query := "x"
			Loop % o3DA.Count()	{
				query .= rd rd
				oTbl := o3DA[ A_Index ]
				Loop % oTbl.Count()	{
					oRow := oTbl[ A_Index ]
					Loop % oRow.Count()
						If ( cd = "CSV" )	{
							str := oRow[ A_Index ]
							StringReplace, str, str, ", "", A
							If !ErrorLevel || InStr( str, "," ) || InStr( str, rd )
								str := """" str """"
							query .= ( A_Index = 1 ? rd : "," ) str
							}
						Else
							query .= ( A_Index = 1 ? rd : cd ) oRow[ A_Index ]
					}
				}
			query := SubStr( query, 2 + 3 * StrLen( rd ) )
			}
		}
	Else	{
		oErr := oCon.Errors
		query := "x"
		Loop % oErr.Count	{
			oFld := oErr.Item( A_Index - 1 )
			str := oFld.Description
			query .= "`n`n" SubStr( str, 1 + InStr( str, "]", 0, 2 + InStr( str, "][", 0, 0 ) ) )
				. "`n   Number: " oFld.Number
				. ", NativeError: " oFld.NativeError
				. ", Source: " oFld.Source
				. ", SQLState: " oFld.SQLState
			}
		sql_le := SubStr( query, 4 )
		query := ""
		txtout := 1
		}
	oCon.Close()
	ComObjError( 0 )
	ErrorLevel := coer
	if (	StrLen( sql_le ) > 0
		&&	StrLen( d ) > 0
		&&	d <> "o" )
		MsgBox % sql_le "`n" sql_lq
	if (	d	= "o"
			&&	StrLen(sql_le) > 0 )
		OutputDebug % "Error:`n`t"	sql_le "`nQuery`n`t" clipboard:=sql_lq
	Return txtout
				?	query
				:	o3DA.MaxIndex() =	1
									?	o3DA[1]
									:	o3DA
	}
