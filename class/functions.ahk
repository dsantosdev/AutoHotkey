
datetime( sql = "0", date = "" )			{
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

http( url )							{
	static req := ComObjCreate( "Msxml2.XMLHTTP" )
	req.open( "GET", url, false )
	req.SetRequestHeader( "Authorization", "Basic YWRtaW46QGRtMW4=" )	;	login local do dguard(admin)
	req.SetRequestHeader( "If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT" )
	req.send()
	return	%	req.responseText
	}


login( @usuario, @senha, @admin = "" )		{
	if ( @admin != "" )	{
		if InStr( admins, @usuario )
			return DllCall(	"advapi32\LogonUser"
						,	"str",	@usuario
						,	"str",	"Cotrijal"
						,	"str",	@senha
						,	"Ptr",	3
						,	"Ptr",	3
						,	"UintP"
						,	nSize	)	=	1
									?	"1"
									:	"0"
		Else
			Return 0
	}
	Else
		return DllCall(	"advapi32\LogonUser"
					,	"str",	@usuario
					,	"str",	"Cotrijal"
					,	"str",	@senha
					,	"Ptr",	3
					,	"Ptr",	3
					,	"UintP"
					,	nSize	)	=	1
									?	"1"
									:	"0"
}

notificar( )							{
	s =
		(
		SELECT TOP(1)	p.IdCliente
					,	p.QuandoAvisar
					,	p.Mensagem
					,	p.Assunto
					,	c.Nome
					,	p.Idaviso
		FROM
			[IrisSQL].[dbo].[Agenda] p
		LEFT JOIN
			[IrisSQL].[dbo].[Clientes] c
				ON p.IdCliente = c.IdUnico
		ORDER BY
			6 DESC
		)
		s := sql( s )
	if ( StrLen( last_id ) = 0 )	{
		last_id := s[2,6]
		return % last_id
		}
	if ( last_id < s[2, 6] )		{	;executa notificação
		subjm		:= s[2, 4]
		iadaviso	:= s[2, 6]
		if ( SubStr( A_IpAddress1, InStr( A_IpAddress1, ".",,,3 )+1 ) = 184 )	;	Remove errados
			If ( InStr( subjm, "Informou" ) > 0 )		{
				d = DELETE FROM [IrisSQL].[dbo].[Agenda] WHERE idaviso = '%iadaviso%'
				sql( d )
				return
			}
		last_id := s[2,6]
		TrayTip, % s[2,5] "`nNovo E-Mail - " datetime(), % s[2, 3]
		Random, easteregg, 1, 100
		if ( easteregg < 95 )
			som = car
			else
				som = yoda
		SoundPlay, \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\%som%.wav
		}
	if ( last_id > s[2, 6] )
		last_id := s[2, 6]
	GuiControl,	debug:,	debug4,% s[2,6] " - " last_id
	return	last_id
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