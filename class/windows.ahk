if	inc_windows
	Return

Global inc_windows = 1

Class	Windows	{
	
	LoginAd( usuario, senha )	{
		if DllCall( "advapi32\LogonUser", "str"
			.	, usuario, "str"
			.	, "Cotrijal", "str"
			.	, senha, "Ptr"
			.	, 3, "Ptr"
			.	, 3, "UintP"
			.	, nSize)
			return	1
		else
			return	0
	}

	ProcessExist( processName )	{
		Process, Exist,% processName
		return Errorlevel
	}

	Run( software )				{
		path = C:\Dguard Advanced\
		copy = \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\
		try
			Run,%   path software ".exe"
			catch	{
				FileCopy,%  copy software ".exe"
					,%  path software ".exe",   1
				Sleep,	500
				if ( errorlevel = 0 )
					try
						Run,%   path software ".exe"
			}
	}

	Speak( text, language="1", volume="100", speed="1" )	{

		speak	:= ComObjCreate("SAPI.SpVoice")
		; For languages In voice.GetVoices
			; msgbox % languages.GetDescription
		speak.Volume := volume
		speak.rate := speed
		speak.Speak( text )
		return
		; return	speak.Speak( text ).GetVoices().Item( %language% ) ; Item is Zero based
	}

	Status( where )				{
		; OutputDebug % where
		if !where
			Return
		obj := ComObjGet( "winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2" )
		query_results := obj.ExecQuery( "SELECT Lockout, Status FROM Win32_UserAccount WHERE Name = '" where "'" )._NewEnum
		While query_results[ property ]
			Return property[ "Lockout" ] = "-1" ? "Usuário bloqueado ou senha expirada" : "Usuário ou senha inválidos.`nVerifique sua senha, se a tecla CAPSLOCK não está ativada.`nE se atecla NUMLOCK está ativada!"
	}

	Users( where )				{
		if !where
			Return
		obj := ComObjGet( "winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2" )
		query_results := obj.ExecQuery( "SELECT FullName FROM Win32_UserAccount WHERE Name = '" where "'" )._NewEnum
		While query_results[ property ]
			Return property[ "FullName" ]
	}

}