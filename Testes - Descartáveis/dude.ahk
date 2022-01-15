F1::
unidade = 1
	WinActivate, teste - Network Map
Loop, 64 {
	unidade++
	Sleep, 100
	Click, 104, 250 Left
	Sleep, 100
	WinWait, New Discover Info
	WinActivate, New Discover Info
	ControlSend, Edit1,10.2.%unidade%.201-10.2.%unidade%.222, New Discover Info
	Sleep, 100
	Click, 350, 43 Left
}
Return

END::
	ExitApp

F2::
Loop, 64 {
	Click, 180, 290, Left
	Click, 130, 250, Left
	Winwait, Confirm Discover Info Remove
	Send, {Enter}
	Sleep, 200
}
	return