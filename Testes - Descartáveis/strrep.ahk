#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk

texto :=	"Nome da câmera alterado dê:[n]'a'[n][t]para:[n]'b'[n]"
		MsgBox %  StrRep( texto , , "[n]:1", "[t]:2" ) parametros
ExitApp