debug = 2
;	Includes
	#Include, ..\class\dguard.ahk
	#Include, ..\class\functions.ahk
	#Include, ..\class\sql.ahk
;

;	Variáveis
	Início				:= datetime()
	end_ip				:= 160
	layouts	:= {}
;

Loop,	20	{	;	por coluna
	;Server atual
		end_ip++
		server := "192.9.100." end_ip
		ToolTip,% server, 50, 50
	;

	;Definição de token para requisições
		token := dguard.token( server )
	;
	;	testes
	url		:= "http://" server ":8081/api/monitors"
		
	retorno := Dguard.http( url , token )
	MsgBox % retorno
	
	;
	;Layouts e câmeras pertencentes
		_ := dguard.layouts( server , token )
		Loop,% _.layouts.Count()	;	efetua a busca por cada guid de layout que não for padrão
			if (_.layouts[A_index].name != "Todas as câmeras"
			&&	_.layouts[A_index].name != "Nenhum" )	{	;	Busca guid do layout
				index := A_Index
				__ := dguard.lista_cameras_layout( server , token , _.layouts[A_Index].guid)	;	busca câmeras por layout
				Loop,% __.cameras.Count()	;	armazena as informações em um map
					layouts.Push({	server	:	server
								,	layout	:	_.layouts[index].name
								,	câmera	:	__.cameras[A_Index].ServerName	})
			}
	;
	}
	ToolTip
	;	Saída de dados para clipboard
		; Loop,% layouts.Count()
		; 	a .= layouts[A_index].server "`t" layouts[A_index].layout "`t" layouts[A_index].câmera "`n"
		; MsgBox % clipboard := a
	;
	; MsgBox %	"done`n"	Início "`t" datetime()

	ExitApp