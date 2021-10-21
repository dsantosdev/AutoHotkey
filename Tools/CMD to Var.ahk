;	Requisições
	; server	:= StrSplit( pslist( "192.9.100.181" , "cotrijal\srv.dguard" , "M0n_DG20" , "dguard" ) , "`n" )
		; MsgBox % get_status( server[9] )
	; server	:= StrSplit( pslist( "192.9.100.182" , "cotrijal\srv.dguard" , "M0n_DG20" , "dguard" ) , "`n" )
		; MsgBox % get_status( server[9] )
	; server	:= StrSplit( pslist( "192.9.100.183" , "cotrijal\srv.dguard" , "M0n_DG20" , "dguard" ) , "`n" )
		; MsgBox % get_status( server[9] )
	; server	:= get_status( pslist( "192.9.100.187" , "dguard" , "cotrijal\srv.dguard" , "M0n_DG20" ) , "C:\Seventh\dguardCenter\dguard.exe"  , "cotrijal\srv.dguard" , "M0n_DG20"  )
	; server	:= StrSplit( pslist( "192.9.100.187" , "cotrijal\srv.dguard" , "M0n_DG20" , "dguard" ) , "`n" )
	server	:= pslist( "192.9.100.187" , "cotrijal\srv.dguard" , "M0n_DG20" , "dguard" ) 
		; MsgBox % get_status( server[9] )
		MsgBox % server
;

get_status( string , software , user = "" , pass = "" ) {
	OutputDebug % string "`n" InStr( string , "was not found" )
	if ( InStr( string , "was not found" ) > 0 )	{
		if ( StrLen( software ) > 0 )	{
			MsgBox % psexec( "192.9.100.187" , software , user , pass )
		}
		MsgBox
		Return	"Processo não está em execução!"
	}
	Else {
		split := StrSplit( string , "`n" )
		string := server[9]
		OutputDebug % string
		Loop, 10
			string := StrReplace( string , "  " , " " )
		split := StrSplit( string , " " )
		Return SubStr( split[ split.Count() ] , 1 , -5 )
	}
}

pslist( server , software , user = "" , pass = "" ) {
	DetectHiddenWindows On
	Run %ComSpec%,, Hide, pid
	WinWait,% "ahk_pid " pid
	DllCall( "AttachConsole" , "UInt" , pid )
    shell := ComObjCreate( "WScript.Shell" )
    exec  := shell.Exec( ComSpec " /C pslist \\" server " -u " user " -p " pass " " software )
	DllCall( "FreeConsole" )
    OutputDebug % saida := exec.StdOut.ReadAll()
    return saida
}

psexec( server , software , user = "" , pass = "" ) {
	DetectHiddenWindows On
	Run %ComSpec%,, Hide, pid
	WinWait,% "ahk_pid " pid
	DllCall( "AttachConsole" , "UInt" , pid )
    shell := ComObjCreate( "WScript.Shell" )
    MsgBox % " /C" Clipboard := " psexec \\" server " -u " user " -p " pass " """ software """"
    exec  := shell.Exec( ComSpec " /C psexec \\" server " -u " user " -p " pass " """ software """" )
	DllCall( "FreeConsole" )
    return exec.StdOut.ReadAll()
}
