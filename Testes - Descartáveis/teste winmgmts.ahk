MsgBox % Status( "dsantos" )
; MsgBox % users()
Return
	
	Users( where = "" )	{
		if !where
			Return
		obj := ComObjGet( "winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2" )
		query_results := obj.ExecQuery( "SELECT * FROM Win32_UserAccount WHERE Name = '" where "'" )._NewEnum
		; query_results := obj.ExecQuery( "SELECT * FROM Win32_UserAccount WHERE Status != 'Ok'" )._NewEnum
		; query_results := obj.ExecQuery( "SELECT FullName FROM Win32_UserAccount WHERE Name = '" where "'" )._NewEnum
		While query_results[ property ]
			Return	"	Acctype	=	" property[ "AccountType" ]	
				.	"`n	Caption	=	"	property[ "Caption"] 
				.	"`n	Descrip	=	"	property[ "Description"] 
				.	"`n	Disable	=	"	property[ "Disabled"] 
				.	"`n	Domain	=	"	property[ "Domain"] 
				.	"`n	FName	=	"	property[ "FullName"] 
				.	"`n	LAccou	=	"	property[ "LocalAccount"] 
				.	"`n	Lockou	=	"	property[ "Lockout"] 			;	-1
				.	"`n	Name	=	"	property[ "Name"] 
				.	"`n	PChang	=	"	property[ "PasswordChangeable"] 
				.	"`n	PExpir	=	"	property[ "PasswordExpires"] 
				.	"`n	PReq	=	"	property[ "PasswordRequired"] 
				.	"`n	SIDType	=	"	property[ "SIDType"] 
				.	"`n	Status	=	"	property[ "Status"]				;	Degraded
	}

	Status( where )	{
		OutputDebug % where
		if !where
			Return
		obj := ComObjGet( "winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2" )
		query_results := obj.ExecQuery( "SELECT Lockout, Status FROM Win32_UserAccount WHERE Name = '" where "'" )._NewEnum
		While query_results[ property ]
			Return property[ "Lockout" ] = "-1" ? "Usuário bloqueado ou senha expirada" : "Usuário ou senha inválidos.`nVerifique sua senha, se a tecla CAPSLOCK não está ativada.`nE se atecla NUMLOCK está ativada!"
	}