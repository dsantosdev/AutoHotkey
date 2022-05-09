/*
	*	*	*	Compile_AHK	SETTINGS	BEGIN	*	*	*
	[AHK2EXE]
		Exe_File=C:\users\dsantos\desktop\executáveis\Gestor	-	Motion	Detection.exe
		Created_Date=1
	[VERSION]
		Set_Version_Info=1
		Company_Name=Heimdall
		File_Description=
		File_Version=0.0.0.1
		Inc_File_Version=1
		Product_Name=Gestor	-	Motion	Detection
		Product_Version=1.1.33.2
		Set_AHK_Version=1
	*	*	*	Compile_AHK	SETTINGS	END	*	*	*
*/


;	Includes
	;	#Include	..\class\alarm.ahk
	;	#Include	..\class\array.ahk
	;	#Include	..\class\base64.ahk
	;	#Include	..\class\convert.ahk
	;	#Include	..\class\cor.ahk
	;	#Include	..\class\dguard.ahk
		#Include	..\class\functions.ahk
	;	#Include	..\class\gui.ahk
	;	#Include	..\class\listview.ahk
	;	#Include	..\class\mail.ahk
	;	#Include	..\class\safe_data.ahk
		#Include	..\class\SB_SetProgress.ahk
		#Include	..\class\sql.ahk
	;	#Include	..\class\string.ahk
	;	#Include	..\class\telegram.ahk
	;	#Include	..\class\windows.ahk
;

;	-Arrays
	;
;

;	-Configurações
	;	#NoTrayIcon
	#SingleInstance,	Force

	show_tooltip	:=	A_Args[1]	;	recebe	o	argumento	1	para	exibir
		if	(	A_UserName	=	"dsantos"	)
			show_tooltip	=	1
		CoordMode,	ToolTip,	Screen

	if	(	A_IsCompiled	=	1	)
		ext	=	exe
	Else
		ext	=	ahk

;

;	-Variáveis
	WinGetPos,,,, taskbar, ahk_class Shell_TrayWnd
	for_mod			:=	Mod( A_Yday, 1 ) = 0 ? "2" : "1"
	lv_width		:=	(A_ScreenWidth//10) * 2
	picture_width	:=	(A_ScreenWidth//10) * 6
	height			:=	A_ScreenHeight - taskbar - 80
;

;	-Login
	;
;

;	-Interface
	Gui,	Add,	ListView,%	"	x5	y30"
							.	"	w"	lv_width
							.	"	h"	height
							.	"	Section"
							.	"	vlv_cam"
							.	"	gchoose_cam"
							,	Câmera|Contagem|ip
	Gui,	Add,	StatusBar,%	"	x5"

								,	teste
	Gui,	Add,	ListView,%	"		ys"
							.	"	w"	lv_width
							.	"	h"	height
							.	"	Section"
							.	"	vlv_image"
							.	"	gchoose_image"
							,	path|Data e Hora
	Gui,	Add,	Picture,%	"		ys"
							.	"	w"	picture_width
							.	"	h"	height
							.	"	vpicture"

	Gui,	Show
	Gosub	cam_list
	progressBar( "destroy" )
	LV_ModifyCol( 2 , "SortDesc Auto Integer" )

	return
;

;	-Code
	;	Preenche listas
		cam_list:
			Gui,	ListView,	lv_cam
			items_in_folder	:=	ComObjCreate("Shell.Application").NameSpace("\\srvftp\Monitoramento\FTP\Verificados").Items.Count
			progressBar( , "Carregando câmeras de " items_in_folder " imagens de detecção geradas." )
			SB_SetProgress( 0, 2, "Range1-" items_in_folder )

			Loop,	\\srvftp\Monitoramento\FTP\Verificados\*.* {

				SB_SetProgress( "+1", 2, "Range1-" items_in_folder )
				SB_SetText(	"Carregando câmeras de " items_in_folder " imagens de detecção geradas. " A_Index " de " items_in_folder , 1 )

				split 	:=  StrSplit( StrReplace( A_LoopFileName , ".jpg" ),	" - " )

				date	:=	SubStr( StrReplace( split[5] , "_" ),	1 , 8 )

				if ( (	time := SubStr( StrReplace( split[5] , "_" ) , 9 ) )	>  "200000"
					||			SubStr( StrReplace( split[5] , "_" ) , 9 )		<   "70000" ) {
					date	+=	1, Days
					date	:=	SubStr( date, 1, 8 )
				}

				if !Mod(  A_Now - date , for_mod )		;	verificação de imagens dos dias do facilitador apenas
					Continue
				if ( InStr(In_List , Split[1]) > 0 )
					Continue
				In_List .= Split[1] "`n"

				LV_Add(	""
					,	Split[3] " | " Split[4]
					,	count_images( Split[1] )
					,	Split[1]	)
			}
		Return

		image_list:
			Gui,	ListView,	lv_image

		Return
	;
	;	Functions
		choose_cam:
			LV_GetText( cam, A_EventInfo, 3 )
			MsgBox % cam
			LV_ModifyCol( 3, 0 )
		Return

		choose_image:
			LV_GetText( image, A_EventInfo, 1 )
			MsgBox % image
			LV_ModifyCol( 1, 0 )
		Return

		count_images( ip ) {
			loop,	\\srvftp\Monitoramento\FTP\Verificados\*.*
				if InStr( A_LoopFileName , ip )
					count++
			Return	count
		}
	;


;

;	-GuiClose
	GuiClose:
	ExitApp
;
	



	

