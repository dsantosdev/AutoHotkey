Class Base64 {
	Dec( ByRef B64, ByRef Bin ) {  ; By SKAN / 18-Aug-2017
		Local Rqd := 0, BLen := StrLen(B64)                 ; CRYPT_STRING_BASE64 := 0x1
		DllCall("Crypt32.dll\CryptStringToBinary"
			,	"Str"	,	B64
			,	"UInt"	,	BLen
			,	"UInt"	,	0x1
			,	"UInt"	,	0
			,	"UIntP"	,	Rqd
			,	"Int"	,	0
			,	"Int"	,	0	)
		VarSetCapacity( Bin , 128 ), VarSetCapacity( Bin , 0 ),  VarSetCapacity( Bin , Rqd , 0 )
		DllCall("Crypt32.dll\CryptStringToBinary"
			,	"Str"	,	B64
			,	"UInt"	,	BLen
			,	"UInt"	,	0x1
			,	"Ptr"	,	&Bin
			,	"UIntP"	,	Rqd
			,	"Int"	,	0
			,	"Int"	,	0	)
		Return Rqd
	}

	Enc( ByRef Bin, bytes, lenght := 64, l_spaces := 0 ) { ; By SKAN / 18-Aug-2017
		Local Rqd := 0, B64, B := "", N := 0 - lenght + 1  ; CRYPT_STRING_BASE64 := 0x1
		DllCall("Crypt32.dll\CryptBinaryToString"
			,	"Ptr"	,	&Bin
			,	"UInt"	,	bytes
			,	"UInt"	,	0x1
			,	"Ptr"	,	0
			,	"UIntP"	,	Rqd )
		VarSetCapacity( B64 , Rqd * ( A_Isunicode ? 2 : 1 ) , 0 )
		DllCall("Crypt32.dll\CryptBinaryToString"
			,	"Ptr"	,	&Bin
			,	"UInt"	,	bytes
			,	"UInt"	,	0x1
			,	"Str"	,	B64
			,	"UIntP"	,	Rqd	)
		If (lenght = 64
		&&	! l_spaces )
			Return B64
		B64 := StrReplace( B64, "`r`n" )        
		Loop % Ceil( StrLen(B64) / lenght )
			B .= Format("{1:" l_spaces "s}","" ) . SubStr( B64, N += lenght, lenght ) . "`n" 
		Return RTrim( B,"`n" )    
	}

	FileEnc( FileName ) {
		FileGetSize, nBytes, %FileName%
		FileRead, Bin, *c %FileName%
		return Base64.Enc(Bin, nBytes)
	}

	FileDec( ByRef B64, FileName ) {
		nBytes := Base64.Dec( B64, Bin )
		FileOpen( FileName , "w" ).RawWrite( Bin , nBytes )
	}
}