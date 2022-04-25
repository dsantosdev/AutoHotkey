#Include, ..\class\sb_setprogress.ahk

Gui,add,text,w280 center,Some text for the gui!
Gui,add,statusbar
Gui,show,w300,Statusbar with Progress

SB_SetParts(20,200,100) ; Make 3 different parts
SB_SetText("demotext",2) ; Set a text segment 2
SB_SetIcon(A_AhkPath,1,1) ; Set an Icon to 1st segment
; create a 50% progressbar with yellow background and blue bar
Loop, 100
	hwnd := SB_SetProgress(A_Index,3,"BackgroundYellow cBlue") 
return

	;	 GuiClose:
	;	 ExitApp

