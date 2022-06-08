File_Version=0.1.0
Save_To_Sql=1
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
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\file.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\folder.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\sync_data.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

/*	Bancos de Dados utilizados
	[dguard].[dbo].[cameras]

*/
#NoTrayIcon
s =
	(
		SELECT
			 [ip]
			,[vendorModel]
		FROM
			[dguard].[dbo].[cameras]
		WHERE
			[vendormodel] LIKE 'Dahu`%'
		OR
			[vendormodel] LIKE 'SAMS`%'
		OR
			[vendormodel] LIKE 'INTEL`%'
		OR
			[vendormodel] LIKE 'FOSCA`%'
		ORDER BY
			[cam_model]
	)
	s := sql( s, 3 )
Loop,% s.Count()-1	{
	OutputDebug % TEXT
	; ToolTip,% (s.Count()-1) - A_Index, 100,100
	ip := s[A_index+1, 1]
	if !ping( ip )
		continue
	if	(InStr( s[A_index+1,2], "Dahua" )
	||	 InStr( s[A_index+1,2], "Intel" ))	{
		r := StrSplit( http := http( "http://admin:tq8hSKWzy5A@" ip "/cgi-bin/magicBox.cgi?action=getSystemInfo", ,1 ), "`n" )
		dahua = 1
	}
	Else If InStr( s[A_index+1,2], "Samsung" )	{
		r := StrSplit( http := http( "http://admin:tq8hSKWzy5A@" ip "/cgi-bin/about.cgi?msubmenu=about&action=view2", ,1 ), "`n" )
		samsung = 1
	}
	Else If InStr( s[A_index+1,2], "Samsung" )	{
		r := StrSplit( http := http( "http://" ip ":88/cgi-bin/CGIProxy.fcgi?cmd=getDevInfo&usr=admin&pwd=tq8hSKWzy5A", ,1 ), "`n" )
		foscam = 1
	}
	OutputDebug % "1 " dahua "`n2 " foscam "`n3 " samsung "`n" ip "`n" r "`n" http "`n" r.Count()
	cam_model =
	Loop,% r.Count() {
		OutputDebug % r[a_Index]
		if dahua {
			if	InStr( r[A_Index], "deviceType=" ) {
				cam_model	:=	 StrRep( r[A_Index],, "deviceType=", "`n", "`r" )
				if	( cam_model = "ip camera")
					wrong_device = 1
			}
			if	(	InStr( r[A_Index], "updateSerial=" )
			&&		wrong_device) {
				cam_model	:=	 StrRep( r[A_Index],, "updateSerial=", "`n", "`r" )
				wrong_device=
			}
		}
		if samsung
			if	InStr( r[A_Index], "model:" )
				cam_model	:=	 StrRep( r[A_Index],"|", "model:", "`n", "`r" )
		if foscam
			if	InStr( r[A_Index], "<productName>" )
				cam_model	:=	 StrRep( r[A_Index],, "<productName>", "`n", "`r", "</productName>" )
		if cam_model && ip {
			u =
			(
				UPDATE [Dguard].[dbo].[cameras]
				SET
					[cam_model] = '%cam_model%'
				WHERE
					[ip]		= '%ip%'
			)
			; MsgBox % "1 " dahua "`n2 " foscam "`n3 " samsung "`n" Clipboard:=u
			sql( u, 3 )
		}
	}
	dahua := samsung := foscam := ""
	; MsgBox
}
ExitApp