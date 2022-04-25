;@Ahk2Exe-SetMainIcon C:\AHK\icones\_gray\2update.ico
update = 12/05/2021
#Include ..\Libs\_.ahk
;{ Starter GUI
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow 
Gui, Font, s15 ceef442
Gui,	Add,	Text,  x2	y100	h20 ,	Update em andamento
Gui, Font, s10 cFF0000
Gui, Color, 000000
Gui,	Add,	Text,	x2	y20	    h20	vg2,	Deletando arquivos antigos...
Gui,	Add,	Text,	x2	y40	    h20	vg3,	Copiando arquivos novos...
Gui,	Add,	Text,	x2	y60	    h20	vg4,	Atualizando Sistema Monitoramento...
Gui,	Add,	Text,	x2	y80	    h20	vg5,	Finalizando update...
Gui, Font, s10 cFF0000
Gui,	Add,	Text,	x2	y140    h20	vg6,	---------------------------------------------------------------------
Gui, Show, x0  y0  NoActivate
Gui, Font, s10 c229b1b ;}

if(A_UserName="dsantos")
	Menu, Tray, Icon
PostMessage, 0x111, 424, 0,, ahk_class Shell_TrayWnd ; Lock taskbar
s=SELECT [complemento1] FROM [ASM].[DBO].[_gestao_sistema] WHERE [Funcao] = 'Sistemas'
s:=adosql(s,3)
s:=StrSplit(s[2,1],",")
Loop,	%	s.Count()
	Process,	Close,	%	 s[A_Index]	".exe"
																			GuiControl, ,   g6, Verificando Existência dos Arquivos
if(StrLen(FileExist(smk "DDguard Player.exe"))=0)	{
	MsgBox, , , Arquivo executável não encontrado`, update  cancelado!
	ExitApp
}
																			GuiControl, ,   g6, Deletando folder Sistema
FileRemoveDir,	C:\Dguard Advanced,	1
																			GuiControl, ,   g6,	Deletando folder Backup
FileRemoveDir,	C:\Seventh\Backup,	1
																			GuiControl, Font, g2
																			GuiControl, ,   g2,	Arquivos antigos deletados!
FileCreateDir,	C:\Dguard Advanced
if(InStr(estacoes,A_IPAddress1)>0 or A_UserName = "Alberto")	{	;	estações operadoras
	FileCreateDir,													C:\Dguard Advanced\Color
	GuiControl, ,   g6, Color
	FileCopy,%smk%map\color\*.png,					C:\Dguard Advanced\Color,									1
	FileCopy, %smk%AutRem.exe,						C:\DGuard Advanced\AutRem.exe, 					1
	FileCopy, %smk%AutAdd.exe,							C:\DGuard Advanced\AutAdd.exe, 					1
	FileCopy, %smk%RespAdd.exe,						C:\DGuard Advanced\RespAdd.exe,					1
	FileCopy, %smk%RespDel.exe,						C:\DGuard Advanced\RespDel.exe,						1
	FileCopy, %smk%LembEdit.exe,						C:\DGuard Advanced\LembEdit.exe					1
	FileCopy, %smk%MDKah.exe,							C:\DGuard Advanced\MDKah.exe, 						1
	FileCopy, %smk%MDAge.exe,							C:\DGuard Advanced\MDAge.exe, 					1
	FileCopy, %smk%_Insere_Cameras.exe,			C:\DGuard Advanced\_Insere_Cameras.exe,		1
	FileCopy, %smk%_Edita_Cameras.exe,			C:\DGuard Advanced\_Edita_Cameras.exe,		1
	FileCopy, %smk%agenda.exe, 						C:\DGuard Advanced\agenda.exe,						1
	FileCopy, %smk%agenda_user.exe,					C:\DGuard Advanced\agenda_user.exe,				1
	FileCopy, %smk%MDCol.exe,							C:\DGuard Advanced\MDCol.exe, 						1
	FileCopy, %smk%MDMapas.exe,					C:\DGuard Advanced\MDMapas.exe,					1
	FileCopy, %smk%MDRelatorios.exe,				C:\DGuard Advanced\MDRelatorios.exe,			1
	FileCopy, %smk%MDResp.exe,						C:\DGuard Advanced\MDResp.exe,					1
	FileCopy, %smk%relatorio_individual.exe,		C:\DGuard Advanced\relatorio_individual.exe,	1
	}
																																							GuiControl, ,   g6, Backup
	FileCreateDir,													C:\Seventh\Backup
																																							GuiControl, ,   g6, Pasta Mapas
	FileCreateDir,													C:\Seventh\Backup\Map
																																							GuiControl, ,   g6, Icones
	FileCreateDir,													C:\Seventh\Backup\ico
																																							GuiControl, ,   g6, Icones Cópia
	FileCopyDir,	%smk%ico,							C:\Seventh\Backup\ico,								1
																																							GuiControl, ,   g6, Mapas
	FileCopy,		%smk%map\*.jpg,				C:\Seventh\Backup\map,								1
																																							GuiControl, ,   g6, Sistema Monitoramento
	FileCopy, %smk%DDguard Player.exe, C:\DGuard Advanced\DDguard Player.exe, 	1
																																							GuiControl, Font, g3
																																							GuiControl, ,   g3, Arquivos novos copiados!
																																							GuiControl, Font, g4
																																							GuiControl, ,   g4, Sistema Monitoramento Atualizado!  %ErrorLevel%
																																							GuiControl, Font, g5
																																							GuiControl, ,   g5, Update Finalizado!
	Sleep 1000
	Gui,	Destroy
	Run, C:\Dguard Advanced\DDguard Player.exe
	ExitApp

up:
return