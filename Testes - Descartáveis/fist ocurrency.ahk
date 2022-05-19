    Clipboard:= "-Classes Essay on Hobbes"
    Gosub % subroutine := SubStr( Clipboard, 1, InStr( Clipboard, " " )-1 )

    Clipboard:= "-diary diary example"
    Gosub % subroutine := SubStr( Clipboard, 1, InStr( Clipboard, " " )-1 )
    Return
    
    -diary:
    	MsgBox % "Diary:`n"  StrReplace( clipboard, subroutine " " ) 
        ;Create file in /Diary/Entry 27.MD
    Return
    
    -Classes:
    	MsgBox % "Classes:`n"  StrReplace( clipboard, subroutine " " )
        ;Create file in /Classes/Essay on Hobbes.MD
    Return