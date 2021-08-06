
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