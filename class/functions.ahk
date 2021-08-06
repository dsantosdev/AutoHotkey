
datetime( sql = "0", date = "" )	{
	If (	sql = 2
		&&	StrLen( date ) = 0 )	{
		MsgBox,0x40,ERRO, A função datetime() em modo SQL 2`, necessita que seja enviado o valor date para funcionar.
		Return
		}
	If ( sql = 1 )
		Return SubStr( A_Now, 1, 4 ) "-"  SubStr( A_Now, 5, 2 ) "-"  SubStr( A_Now, 7, 2 ) " "  SubStr( A_Now, 9, 2 ) ":"  SubStr( A_Now, 11, 2) ":"  SubStr( A_Now, 13, 2 ) ".000"
	else If ( sql = 2 )	{
		date := RegExReplace(date, "\D")
		Return SubStr( date, 5, 4 ) "-"  SubStr( date, 3, 2 ) "-"  SubStr( date, 1, 2 ) " "  SubStr( date, 9, 2 ) ":"  SubStr( date, 11, 2) ":"  SubStr( date, 13, 2 )
		}
	Return SubStr( A_Now, 7, 2 ) "/"  SubStr( A_Now, 5, 2 ) "/"  SubStr( A_Now, 1, 4 ) " "  SubStr( A_Now, 9, 2 ) ":"  SubStr( A_Now, 11, 2) ":"  SubStr( A_Now, 13, 2 )
}

send_mail( destino, assunto, corpo, at:="")	{
	pmsg := ComObjCreate("CDO.Message")
	pmsg.From := """Sistema Monitoramento"" <CapitaoCaverna@cotrijal.com.br>"
	pmsg.To := destino
	pmsg.Subject := assunto
	pmsg.TextBody := corpo
	sAttach := at
	fields := Object()
	fields.smtpserver := "mail.cotrijal.com.br"
	fields.smtpserverport := 587
	fields.smtpusessl := false
	fields.sendusing := 2 
	fields.smtpauthenticate := 1
	fields.sendusername := "SistemaMonitoramento@cotrijal.com.br"
	fields.sendpassword := ""
	fields.smtpconnectiontimeout := 10
	schema := "http://schemas.microsoft.com/cdo/configuration/"
	pfld := pmsg.Configuration.Fields
	For	field,	value	in	fields
		pfld.Item(schema . field):=value
	pfld.Update()
	Loop, Parse, sAttach, |, %A_Space%%A_Tab%
		pmsg.AddAttachment(A_LoopField)
	pmsg.Send()
	return
}