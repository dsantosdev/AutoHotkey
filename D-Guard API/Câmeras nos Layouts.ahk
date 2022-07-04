debug = 2
;	Includes
	#Include, ..\class\dguard.ahk
	#Include, ..\class\functions.ahk
	#Include, ..\class\sql.ahk
;

;	Variáveis
	Início				:= datetime()
	end_ip				:= 100
	layouts	:= {}
;

Loop,	24	{	;	por coluna
	;Server atual
		end_ip++
		server := "192.9.100." end_ip
		ToolTip,% server, 50, 50
	;

	;Definição de token para requisições
		token := dguard.token( server )
		OutputDebug, % server

	;	comando
		comando := "GET ""http://192.9.100.101:8081/api/monitors"" -H ""accept: application/json"" -H ""Authorization: bearer " token """"
		retorno := Dguard.curly( comando )

	;Layouts e câmeras pertencentes
		_ := dguard.layouts( server , token )
		Loop,% _.layouts.Count()	;	efetua a busca por cada guid de layout que não for padrão
			if (_.layouts[A_index].name != "Todas as câmeras"
			&&	_.layouts[A_index].name != "Nenhum" )	{	;	Busca guid do layout
				index	:=	A_Index
				__		:=	dguard.lista_cameras_layout( server , token , _.layouts[A_Index].guid)	;	busca câmeras por layout
				Loop,%		__.cameras.Count() {	;	armazena as informações em um map
					layouts.Push({	server	:	server
								,	layout	:	_.layouts[index].name
								,	guid	:	__.cameras[A_Index].serverGuid
								,	câmera	:	__.cameras[A_Index].ServerName	})
								; Msgbox	%	__.cameras[index].serverGuid
				}
			}
	;
	}
	ToolTip
	;	Saída de dados para clipboard
		Loop,% layouts.Count()
			a .= layouts[A_index].server "`t" layouts[A_index].layout "`t" layouts[A_index].câmera  "`t" layouts[A_index].guid "`n"
		MsgBox % clipboard := a
	ExitApp