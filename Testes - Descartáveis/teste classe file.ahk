File_Version=

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
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\file.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\folder.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

file = C:\Users\dsantos\Desktop\AutoHotkey\Detecção de Movimento\Gestão Imagens.ahk
appendToLine( "1", file, "teste", 1 )

appendToLine( line, file, text, replace_line="" )	{
	ext	:=	SubStr( file, -3 )
	MsgBox % ext
	FileRead, file_content,% file
	FileDelete,% file ".txt"
	split_content	:=	StrSplit( file_content, "`n" )
	Loop,%	split_content.Count() {
		actual_line++	;	devido ao NÃO replace
		If( actual_line = line )	{
			if replace_line {
				actual_line++
				FileAppend,% text "`n",% file ".txt"
				Continue
			}
			FileAppend,% text "`n",% file ".txt"
			FileAppend,% split_content[actual_line] "`n",% file ".txt"

		}
		Else
			FileAppend,% split_content[actual_line] "`n",% file ".txt"
	}
	Run,% file ".txt"
	return
}