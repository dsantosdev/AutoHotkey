; IniWrite, teste, C:\Dih\arquivo ini.ini, Seção, Key

Loop, Read, C:\Dih\arquivo ini.ini
{
	RegExMatch( A_LoopReadLine  , "^\[(.+)]" ,  sectionx )
	RegExMatch( A_LoopReadLine , "[^=]*"  , keyx)
	
	if ( old_section != sectionx ) 
		output .= sectionx "`n`t"
	if (  )
	else
		output .=	keyx "`n`t"
}
MsgBox % output


FileGetVersion, exe_version , C:\Users\dsantos\Desktop\Executáveis\atualiza_contatos.exe
MsgBox % OutputVar

Haystack := "The quick brown fox jumps over the lazy dog."
RegExMatch(Haystack, "i)(The) (\w+)\b(?CCallout)")
Callout(m) {
    MsgBox m=%m%`nm1=%m1%`nm2=%m2%
    return 1
}