Class	Mail	{

	new( to, subject, body, attach := "" )	{
		pmsg							:= ComObjCreate( "CDO.Message" )
		pmsg.From						:= """Sistema Monitoramento"" <do-not-reply@cotrijal.com.br>"
		pmsg.To							:= to
		pmsg.Subject					:= subject
		pmsg.TextBody					:= body
		sAttach							:= attach

		fields							:= Object()
		fields.smtpserver				:= "mail.cotrijal.com.br"
		fields.smtpserverport			:= 587
		fields.smtpusessl				:= false
		fields.sendusing				:= 2
		fields.smtpauthenticate			:= 1
		fields.sendusername				:= "SistemaMonitoramento@cotrijal.com.br"
		fields.sendpassword				:= ""
		fields.smtpconnectiontimeout	:= 10
		schema							:= "http://schemas.microsoft.com/cdo/configuration/"
		pfld 							:= pmsg.Configuration.Fields

		For	field, value in fields
			pfld.Item( schema field ) := value
		pfld.Update()


		Loop, Parse, sAttach, |, %A_Space%%A_Tab%
			pmsg.AddAttachment( A_LoopField )

		pmsg.Send()
		return
	}

}