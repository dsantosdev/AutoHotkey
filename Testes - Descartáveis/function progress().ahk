#SingleInstance, Force
#Include C:\Users\dsantos\Desktop\AutoHotkey\class\SB_SetProgress.ahk
#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	progressBar( )

	Gui, Progress:Default	;	need to set progress gui as default to use SB_ commands

	; Loop, 5 {	;	animated ico method
		; i	++
		; if	i = 25
			; i = 1

		; SB_SetText(	"Looping through icons - " i , 1 )	;	set text on field 1

		; Sleep, 500
		; SB_SetIcon( "C:\Users\dsantos\Desktop\AutoHotkey\Testes - Descartáveis\icons\a (" i ").ico" , 1, 1)
	; }
	SB_SetProgress( "+10", 2 )
	SB_SetProgress( "+10", 2 )
	SB_SetProgress( "+10", 2 )

Sleep, 600000
	Loop,	8 {
		Sleep 500
		SB_SetProgress( A_Index * 10, 2, "BackgroundYellow cBlue" )
	}

	SB_SetText(	"Last 2 parts" , 1 )		;	set text on field 1
	
		Sleep 1000
	SB_SetProgress( 90, 2, "BackgroundYellow cBlue" )
	
		Sleep 1000
	SB_SetProgress( 100, 2, "BackgroundYellow cBlue" )

		Sleep 1000
	Gui,Progress:Destroy					; close progress bar
Return


ENd::
ExitApp