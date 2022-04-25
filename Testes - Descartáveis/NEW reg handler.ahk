#SingleInstance, Force
Return

dia:
	a = REG COPY HKCU\SOFTWARE\Seventh\DguardCenter HKCU\SOFTWARE\Seventh\dia /s /f
	Run( a )
Return

noite:
	a = REG COPY HKCU\SOFTWARE\Seventh\DguardCenter HKCU\SOFTWARE\Seventh\noite /s /f
	Run( a )
Return

todas:
	a = REG COPY HKCU\SOFTWARE\Seventh\DguardCenter HKCU\SOFTWARE\Seventh\todas /s /f
	Run( a )
Return

troca:
	a = REG DELETE HKCU\SOFTWARE\Seventh\DguardCenter /f
	Run( a )
	a = REG COPY HKCU\SOFTWARE\Seventh\DguardCenterNoite HKCU\SOFTWARE\Seventh\DguardCenter /s /f
	Run( a )
Return

run( command ) {
	DetectHiddenWindows On
	Run		%ComSpec%,, Hide, pid
		WinWait ahk_pid %pid%

	DllCall( "AttachConsole" , "UInt" , pid )

	Shell	:= ComObjCreate( "WScript.Shell" )
	Exec	:= Shell.Exec( ComSpec " /C " command )

	while	Exec.Status == 0
		OutputDebug % just_for_loop

	DllCall( "FreeConsole" )
	Return	Exec.StdOut.ReadAll()
}

inexistente:
	MsgBox comando inexistente
Return

^Numpad1::

Return
^Numpad2::

Return
^Numpad3::

Return

^Insert::
	InputBox, comando
	execute := comando = "dia" ? "dia" : comando = "noite" ? "noite" : comando = "todas" ? "todas" : "inexistente"
	Goto % execute
