SetBatchLines, -1  ; Make the operation run at maximum speed.


Gui, Add, ListView,% "x0 y0 w" A_ScreenWidth-10 " h" A_ScreenHeight-45 " v_lv", Arquivo|Tamanho(KB)|Criado em:|Local
	Loop, Files,X:\*.*, R
	{
		LV_Add("", A_LoopFileName, A_LoopFileSizeKB, A_LoopFileTimeCreated, A_LoopFileFullPath )
		ToolTip, %A_Index% ARQUIVOS DO "X:\" CARREGADOS - AGUARDE
	}
	LV_ModifyCol(2,"Integer SortDesc")
	LV_ModifyCol()
	LV_ModifyCol(2,200)
Gui, Show
ToolTip
return

GuiClose:
ExitApp

