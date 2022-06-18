File_Version=0.0.0
Save_To_Sql=0
;@Ahk2Exe-SetMainIcon C:\AHK\icones\pc.ico

;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\auth.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cameras.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\date.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\file.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\folder.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\sync_data.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

/*	Bancos de Dados utilizados

*/

;	Configurações
	; #NoTrayIcon
	#SingleInstance, Force
;
Loop,	1	{
; Loop,	6	{
	OutputDebug, % "Operador " A_index
	indexed	:=	A_Index
	index = 123
	; if		A_Index = 1
	; 	Index = 102
	; Else if	A_Index = 2
	; 	Index = 106
	; Else if	A_Index = 3
	; 	Index = 109
	; Else if	A_Index = 4
	; 	Index = 114
	; Else if	A_Index = 5
	; 	Index = 118
	; Else if	A_Index = 6
	; 	Index = 123

	s	:=	"192.9.100." index
	t	:=	Dguard.token( s )

	Gosub Rename_layout

	c	:=	"GET ""http://" s ":8081/api/servers"" -H ""accept: application/json"" -H ""Authorization: bearer " t """"
	r	:=	Dguard.Curly( c )
	cam	:=	json( r )
	if InStr( r, "{""error"":{" )
		Return

	Loop,% cam.servers.Count() {
		; OutputDebug, % "Operador " indexed "`tCâmeras restantes " cam.servers.Count()-A_index
		; OutputDebug, % cam.servers[A_index].name "`n" SubStr( cam.servers[A_index].name, 1, 11 )

		If	!InStr( cam.servers[A_index].name, "[" ) 
			Continue

		n	:=	StrSplit( cam.servers[A_index].name, "]" )


		; if	!InStr( output%indexed%, n[1] "]" )
		if	!InStr( output%indexed%, SubStr( n[1], 1, 3) )
		&&	!InStr( nmt%indexed%, SubStr( cam.servers[A_index].name, 1, 13 ) )
		&&	!InStr( lvd%indexed%, SubStr( cam.servers[A_index].name, 1, 13 ) )
		&&	!InStr( sol%indexed%, SubStr( cam.servers[A_index].name, 1, 11 ) )	{
			OutputDebug, % SubStr( cam.servers[A_index].name, 1, 11 ) "`t" SubStr( n[1], 1, 3)
			if		( SubStr( n[1], 1, 3 ) = "NMT" ) {
				If	( Trim( SubStr( n[1], -3 ) ) = "SUP" ) {
					nmt%indexed%	.=	"`t" s
									.	"`t" SubStr( cam.servers[A_index].name, 1, 13 ) "`n"
					Dguard._cria_layout( s,	SubStr( cam.servers[A_index].name, 1, 13 ) )
				}
			}
			Else if	( SubStr( n[1], 1, 3 ) = "SOL" ) {
				; OutputDebug, % SubStr( cam.servers[A_index].name, 1, 11 ) "`t" A_LineNumber
					sol%indexed%	.=	"`t" s
									.	"`t" SubStr( cam.servers[A_index].name, 1, 11 ) "`n"
					Dguard._cria_layout( s,	SubStr( cam.servers[A_index].name, 1, 11 ) )

			}
			Else If	( SubStr( n[1], 1, 3 ) = "LVD" ){
				; OutputDebug, % "`tlvd " n[1]
					Dguard._cria_layout( s, n[1] )
					lvd%indexed%	.=	"`t" s
									.	"`t" n[1] "]`n"

			}
			Else {
				; OutputDebug, %  "`telse " n[1]
				Dguard._cria_layout( s, SubStr( n[1], 1, 3) )
				output%indexed%	.=	"`t" s
								.	"`t" SubStr( n[1], 1, 3) "`n"
			}
		}		
	}
}


MsgBox, , Fim, Done
ExitApp

rename_layout:
	var	:=	dguard.layouts( s , t )
	layouts = Layout1,Layout2,Layout3,Layout4
	Loop,% var.layouts.Count()
		If 	InStr( layouts, var.layouts[A_Index].name )		{
			name	:= var.layouts[A_Index].name
			guid	:= var.layouts[A_Index].guid
			mosaic	:= var.layouts[A_Index].mosaicGuid
			c	:=	"PUT ""http://" s ":8081/api/layouts/%7B" StrRep( guid,, "{", "}" ) "%7D"""
				.	" -H ""accept: application/json"""
				.	" -H ""Authorization: bearer " t """"
				.	" -H ""Content-Type: application/json"""
				.	" -d ""{ \""name\"": \""_" StrRep( name,, "_" ) "\""}"""
			Dguard.Curly( c )
		}
Return