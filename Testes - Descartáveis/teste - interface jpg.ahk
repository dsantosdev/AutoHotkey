Gui, Add	,	Button	,	x65	y305	w450	h65		BackgroundTrans gteste	, teste
Gui, Add	,	Picture	,	x-1	y-1		w1230	h790							, C:\Users\dsantos\Desktop\AutoHotkey\Testes - Descartáveis\1.jpg
Gui, Show	,							w1225	h710							, Interface JPG
WinSet, TransColor, 0xE5F1FB
return

teste:
	MsgBox Booom
Return

GuiClose:
	ExitApp