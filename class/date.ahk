if	inc_date
	Return
global	inc_date = 1

Class	Date	{
	
	toSeconds( date )				{
		/*	Exemplo de uso
		data:=20211231235959
		data+=121,Seconds
		MsgBox % toSeconds(data)
		*/
		If( StrLen( date ) = 0 )
			Date := A_Now
		FormatTime,	yday,	%date%,	YDay
		return	SubStr( date ,1 ,4 )>	A_YYYY	;	Se for no ano
									?	SubStr( date, 1, 4 ) ( ( yday - 1 ) * ( 24 * 60 ) * 60 )	;	Dia
										.	+ ( ( SubStr( date, 9, 2 ) * 60 * 60 )	;	horas
										.	+ ( SubStr( date, 11, 2 ) * 60 )	;	minutos
										.	+ SubStr( date, 13, 2 ) )	;	segundos
									:	SubStr( date, 1, 4 ) ( yday * ( 24 * 60 ) * 60 )	;	dia
										.	+ ( ( SubStr( date, 9, 2 ) * 60 * 60 )	;	horas
										.	+ ( SubStr( date, 11, 2 ) * 60 )	;	minutos
										.	+ SubStr( date, 13 ,2 ) )	;	segundos
	}

}