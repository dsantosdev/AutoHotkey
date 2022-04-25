		data:=20211231235959
		; data+=121,Seconds
		
		MsgBox % dia	:= A_Yday * 24 * 60 * 60		;	dia
		MsgBox % hora	:= SubStr(data, 9, 2) * 60 * 60	;	hora
		MsgBox % min	:= SubStr(data, 11, 2) * 60		;	minutos
		MsgBox % SubStr(data, 13, 2) + hora + min		;	segundos
		MsgBox % SubStr(data, 13, 2) + hora + min + dia	;	segundos

		MsgBox % toSeconds(data)


toSeconds(YYYYMMDDHHMMSS){	;	Transforma data no formato "YYYYMMDDHHMMSS" em segundos do ANO vigente, com o ano final na frente
		/*	Exemplo de uso
		data:=20211231235959
		data+=121,Seconds
		MsgBox % toSeconds(data)
		*/
		if(StrLen(YYYYMMDDHHMMSS)=0)
			YYYYMMDDHHMMSS:=A_Now
		FormatTime,	yday,	%YYYYMMDDHHMMSS%,	YDay
		MsgBox % YYYYMMDDHHMMSS "`n" SubStr( YYYYMMDDHHMMSS, 1, 4 ) ( yday * ( 24 * 60 ) * 60 ) + ( ( SubStr( YYYYMMDDHHMMSS, 9, 2 ) * 60 * 60 ) + ( SubStr( YYYYMMDDHHMMSS, 11, 2 ) * 60 ) + SubStr( YYYYMMDDHHMMSS, 13, 2 ) )
		return	SubStr( YYYYMMDDHHMMSS, 1 , 4 ) > A_YYYY	? SubStr( YYYYMMDDHHMMSS, 1, 4 ) ( ( yday - 1 ) * ( 24 * 60 ) * 60 ) + ( ( SubStr( YYYYMMDDHHMMSS, 9, 2 ) * 60 * 60 ) + ( SubStr( YYYYMMDDHHMMSS, 11, 2 ) * 60 ) + SubStr( YYYYMMDDHHMMSS, 13, 2 ) )
															: SubStr( YYYYMMDDHHMMSS, 1, 4 ) ( yday * ( 24 * 60 ) * 60 ) + ( ( SubStr( YYYYMMDDHHMMSS, 9, 2 ) * 60 * 60 ) + ( SubStr( YYYYMMDDHHMMSS, 11, 2 ) * 60 ) + SubStr( YYYYMMDDHHMMSS, 13, 2 ) )
	}