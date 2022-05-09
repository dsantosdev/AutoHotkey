if	inc_safe_data
	Return
Global	Coded
	,	Base_Key
	,	Alfabeto:="abcdefghijklmnopqrstuvwxyz"
	,	inc_safe_data = 1
;end global

Class Safe_Data	{

	Encrypt( String, key )	{
		if ( StrLen( key ) = 0 )	{
			MsgBox % "Você precisa passar uma key de codificação para encriptar o arquivo"
			Return
			}
		StringCaseSenseSetting := A_StringCaseSense 
		StringCaseSense Off
		Coded := Safe_Data.Crypt_Key( key )
		if ( debug >= 4 )
			OutputDebug % key " - " coded
		Loop, Parse, String
			{
			Ascii := Asc( A_LoopField )
			If ( InStr( Coded, A_LoopField ) >= 1 )	{
				Replace := SubStr( coded, Ascii-96, 1 )
				If ( Ascii > 64 && Ascii < 91 )	{
					Replace := SubStr( coded, Ascii-64, 1 )
					StringUpper, Replace, Replace
					}
				Encrypted .= Replace
				}
				Else
					Encrypted .= A_LoopField
			}
		StringCaseSense %	StringCaseSenseSetting
		Return Encrypted ;"`n__`nEncriptado: " Coded
	}

	Decrypt( String, key )	{
		if ( StrLen( key ) = 0 )	{
			MsgBox % "Você precisa passar uma key de decodificação para decriptar o arquivo"
			Return
			}
		StringCaseSenseSetting := A_StringCaseSense 
		StringCaseSense Off
		Coded := Safe_Data.Crypt_Key( key )
		Loop, Parse, String
			{
			Ascii := Asc( A_LoopField )
			If ( InStr( Coded, A_LoopField ) >= 1 )	{
				Replace := Chr( InStr( Coded, A_LoopField )+96 )
				If ( Ascii > 64 && Ascii < 91 )	{
					Replace := Chr( InStr( Coded, A_LoopField )+64 )
					StringUpper, Replace, Replace
					}
				Decrypted .= Replace
				}
			Else
				Decrypted .= A_LoopField
			}
		StringCaseSense %	StringCaseSenseSetting
		Return Decrypted ;"`n___`nDecriptado: " Coded
	}

	Crypt_Key( key )		{
		Alfabeto:="abcdefghijklmnopqrstuvwxyz"
		StringLower, key, key
		Loop,	% StrLen( key )	;	Remove espaços
			key := StrReplace( key, " " )
		base_key :=
		Loop,	% StrLen( key )
			base_key .= InStr( base_key, n_key := SubStr( key, A_Index, 1) ) = 0
														? n_key
														: ""
		Loop,	%	StrLen( base_key )
			Alfabeto := StrReplace( Alfabeto
									, SubStr( base_key
											, A_Index
											, 1			 ) )
		Return	Alfabeto . base_key
	}

}
