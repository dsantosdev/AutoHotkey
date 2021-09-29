;	Requisições
	server	:= StrSplit( pslist( "192.9.100.181" , "cotrijal\srv.dguard" , "M0n_DG20" , "dguard" ) , "`n" )
		MsgBox % get_status( server[9] )
	server	:= StrSplit( pslist( "192.9.100.181" , "cotrijal\srv.dguard" , "M0n_DG20" , "dguard" ) , "`n" )
		MsgBox % get_status( server[9] )
	server	:= StrSplit( pslist( "192.9.100.181" , "cotrijal\srv.dguard" , "M0n_DG20" , "dguard" ) , "`n" )
		MsgBox % get_status( server[9] )
	server	:= StrSplit( pslist( "192.9.100.187" , "cotrijal\srv.dguard" , "M0n_DG20" , "dguard" ) , "`n" )
		MsgBox % get_status( server[9] )
;

get_status( string ) {
	if ( StrLen( string ) = 0 )
		Return	"Processo não está em execução!"
	Loop, 10
		string := StrReplace( string , "  " , " " )
	split := StrSplit( string , " " )
	Return SubStr( split[ split.Count() ] , 1 , -5 )
}

pslist( server , user , pass , software ) {
	DetectHiddenWindows On
	Run %ComSpec%,, Hide, pid
	WinWait,% "ahk_pid " pid
	DllCall( "AttachConsole" , "UInt" , pid )
    shell := ComObjCreate( "WScript.Shell" )
    exec  := shell.Exec( ComSpec " /C pslist \\" server " -u " user " -p " pass " " software )
	DllCall( "FreeConsole" )
    return exec.StdOut.ReadAll()
}

psexec() {
	DetectHiddenWindows On
	Run %ComSpec%,, Hide, pid
	WinWait,% "ahk_pid " pid
	DllCall( "AttachConsole" , "UInt" , pid )
    shell := ComObjCreate( "WScript.Shell" )
    exec  := shell.Exec( ComSpec " /C psexec \\" server " -u " user " -p " pass " " software )
	DllCall( "FreeConsole" )
    return exec.StdOut.ReadAll()
}
