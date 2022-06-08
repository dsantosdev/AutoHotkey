Msgbox % comando(	"localhost", "layouts",	,"\layoutGuid\: \{2F4F57EE-E44F-4424-BA80-C6085AC75E93}\", "\machineName\: \CPC016836\", "\enabled\: false", "\activationMode\: 1"	)
ExitApp

comando( server, type, token="", params* )	{
		If	!Token
			token	:=	this.token( server )
		a		:=	"\"""
		comando	:=	"POST ""http://" server ":8081/api/"	type ""
				.	"`n -H ""accept: application/json"""
				.	"`n -H ""Authorization: bearer " token """"
				.	"`n -H ""Content-Type: application/json"""
				.	"`n -d ""{"
		for	i, v in params
			{
				if	i = 1
					comando	.=	"`n`t" StrReplace( v, "\", a ) ",`n`t"
				else
					comando	.=	StrReplace( v, "\", a ) ",`n`t"
			}
		comando	:=	SubStr( comando, 1, -1 )
		comando	.=	"}"""
		MsgBox % comando
	}

F5::
	Reload