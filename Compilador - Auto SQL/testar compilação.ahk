File_Version=1.3.0
Save_To_Sql=1
Keep_Versions=2
;@Ahk2Exe-SetMainIcon C:\AHK\icones\cool.ico
#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk

msgbox % auto_update()

Return

F2::
	FileGetVersion, Version, C:\Users\dsantos\Desktop\Executáveis\testar compilação.exe
	Msgbox	%	version
return