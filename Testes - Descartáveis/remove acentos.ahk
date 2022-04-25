MsgBox % word := StrUnmark("âààÁãÃóç")

no_accents( string )	{
	len :=	DllCall("Normaliz.dll\NormalizeString", "int", 2
		,	"wstr", string, "int", StrLen(string)
		,	"ptr", 0, "int", 0)
	Loop	{
		VarSetCapacity(buf, len * 2)
		len	:=	DllCall("Normaliz.dll\NormalizeString", "int", 2
			,	"wstr", string, "int", StrLen(string)
			,	"ptr", &buf, "int", len)
		if len	>=	0
			break
		if (A_LastError != 122)
			return
		len *= -1
	}
	return RegExReplace( StrGet( &buf, len, "UTF-16" ), "\pM" )
}