/*
	* * * Compile_AHK SETTINGS BEGIN * * *
	[AHK2EXE]
		Exe_File=C:\users\dsantos\desktop\executáveis\update mac.exe
		Created_Date=1
	[VERSION]
		Set_Version_Info=1
		Company_Name=Heimdall
		File_Description=
		File_Version=0.0.0.1
		Inc_File_Version=1
		Product_Name=update mac
		Product_Version=1.1.33.2
		Set_AHK_Version=1
	* * * Compile_AHK SETTINGS END * * *
*/


;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\cameras.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

;	Arrays
;

;	Configurações
	; #NoTrayIcon
	#SingleInstance, Force

	show_tooltip	:=	A_Args[1]	;	recebe o argumento 1 para exibir
		if ( A_UserName = "dsantos" )
			show_tooltip = 1
		CoordMode, ToolTip, Screen

	if ( A_IsCompiled = 1 )
		ext	=	exe
	Else
		ext = ahk

;

;	Variáveis
;

;	Code
	select_cameras =
		(
			SELECT
				a.[ip],
				a.[VendorModel],
				b.[mac]
			FROM
				[Dguard].[dbo].[cameras] a
			LEFT JOIN
				[Dguard].[dbo].[cameras_mac] b
			ON
				a.[ip]	=	b.[ip]
			WHERE
				( a.[ip] LIKE '`%' + '.' + '`%' + '.' + '`%' + '.' + '`%' )
			--AND			a.VendorModel like 'HANWHA`%'
			--AND			b.[mac] is null
			ORDER BY
				a.[IP]
		)
		dados := sql( select_cameras, 3 )
		OutputDebug % "Total " dados.Count()

	Loop,% dados.Count()-1	{
		if !ping( dados[A_Index+1, 1] ) {
			OutputDebug % dados[A_Index+1, 1] "`tFalha de ping`t" A_Index
			continue
		}

		mac :=	cameras.mac( dados[A_Index+1, 1], dados[A_Index+1, 2] )
			if !instr( mac, "NULL" )
				mac := "'" mac "'"
			Else
				mac = NULL
			if InStr( mac, "''" )	;	Se não conseguiu resgatar o mac, ignora
				continue

		ip		:=	dados[A_index+1, 1]
		brand	:=	dados[A_index+1, 2]
	
		OutputDebug % ip "`t" mac "`t" A_Index

		update =
			(
				IF NOT EXISTS (SELECT * FROM [Dguard].[dbo].[cameras_mac] WHERE [ip] = '%ip%' )

					INSERT INTO [Dguard].[dbo].[cameras_mac]
								( IP,		MAC,		BRAND )
					VALUES
								( '%ip%',	%mac%,	'%brand%' )

				ELSE
					
					UPDATE	[Dguard].[dbo].[cameras_mac]
					SET		[mac]	= %mac%,
							[ip]	= '%ip%',
							[brand]	= '%brand%'
					WHERE	[ip]	= '%ip%'
			)
			sql( update, 3)
			if sql_le
				MsgBox % sql_le "`n`n`n" Clipboard	:=	sql_lq
	}
	MsgBox done
	ExitApp
;
