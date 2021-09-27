#Include ..\class\Cor.ahk
#NoEnv
Gui,	Font,	S25
Gui,	-Caption	-DPIScale
Gui,	Margin,	0,	0
Gui,	Add,	Pic,	w%A_ScreenWidth%	h40	hwndHPIC
Gui,	Add,	Text,	vLoader	Center		hp wp	xp	yp	BackgroundTrans	,	Sistema Monitoramento
Cor.Gradiente(	HPIC
			,	burning
			,	
			,	1 )
Gui,	Show,	x0	y0	NoActivate
Return

GuiClose:
	GuiEscape:
	ExitApp