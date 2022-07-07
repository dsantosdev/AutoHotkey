File_Version=1.3.2
Save_To_Sql=1
Keep_Versions=2
;@Ahk2Exe-SetMainIcon C:\AHK\icones\cool.ico
F1::
	FileGetVersion, Version, C:\Users\dsantos\Desktop\Executáveis\testar compilação.exe
	Msgbox	%	version
return