debug = 2
;	Includes
	#Include, ..\class\array.ahk
	#Include, ..\class\dguard.ahk
	#Include, ..\class\functions.ahk
	#Include, ..\class\sql.ahk

;	Variáveis
	Início	:= datetime()
	end_ip	:= 111
	end_ip2	:= 110

; Loop,	1	{	;	por coluna
Loop,	2	{	;	por coluna
		indexador++
		layouts%indexador%	:= {}
	;	Server atual
		end_ip++
		; server := "192.9.100." end_ip
		If( A_Index = 1 )
			server := "192.9.100." end_ip
		Else
			server := "192.9.100.100"
		ToolTip,% server, 50, 50
	;

	;	Definição de token para requisições
		token%indexador% := dguard.token( server )
		OutputDebug, % server

	;	comando
		comando := "GET ""http://" server ":8081/api/monitors"" -H ""accept: application/json"" -H ""Authorization: bearer " token%indexador% """"
		retorno := Dguard.curly( comando )

	;	Layouts e câmeras pertencentes a primeira coluna
		_ := dguard.layouts( server , token%indexador% )
		
		Loop,% _.layouts.Count()																				;	efetua a busca por cada guid de layout que não for padrão

			if (_.layouts[A_index].name != "Todas as câmeras"
			&&	_.layouts[A_index].name != "Nenhum" )	{														;	Busca guid do layout
				index	:=	A_Index
				__		:=	dguard.lista_cameras_layout( server , token%indexador% , _.layouts[A_Index].guid)	;	busca câmeras por layout

				Loop,%	__.cameras.Count() {																	;	armazena as informações das câmeras em um map
					OutputDebug, % TEXT
					cameras%A_Index%	:=	[	server
											,	_.layouts[index].name
											,	__.cameras[A_Index].serverGuid
											,	__.cameras[A_Index].sequence
											,	__.cameras[A_Index].ServerName	]
				}
				Loop,%	__.cameras.Count()
					layouts%indexador%.Insert( [ cameras%A_Index% ] )

				layout_ordenado%indexador% :=	array.sort_matrix( layouts%indexador%,"asc", 4 )
			}
	}

; Loop,	2	{
Loop,	1	{
	;Server atual
		x_index++
		end_ip2++
		; server := "192.9.100." end_ip2
		server := "192.9.100.100"
		ToolTip,% server, 50, 50

	;	deleta layouts atuais
		; comando := "DELETE ""http://" server ":8081/api/layouts"" -H ""accept: application/json"" ""Authorization: bearer " token%A_Index% """"
		; retorno := Dguard.curly( comando )
		
	;	cria os novos layouts
		Loop, 4 {
			comando :=	" POST ""http://" server ":8081/api/layouts"""
					.	" -H ""accept: application/json"""
					.	" -H ""Authorization: bearer " token2 """"
					; .	" -H ""Authorization: bearer " token%A_Index% """"
					.	" -H ""Content-Type: application/json"""
					.	" -d ""{ \""name\"": \""_layout" A_Index "\""}"""
			layout_%A_Index%:=	json( Dguard.Curly( comando ) )
			l_guid%A_Index%	:=	layout_%A_Index%.layout.guid
			;	insere as câmeras
				; if( x_index = 1 ) {
				; 	Loop,%	layouts2.Count()
				; 		Dguard.cam_to_layout( server, layout_%A_Index%.layout.guid, layouts2[A_Index].guid, layouts2[A_Index].sequence )
				; }
				; Else {
				; 	Loop,%	layouts1.Count()
				; 		Dguard.cam_to_layout( server, layout_%A_Index%.layout.guid, layouts1[A_Index].guid, layouts2[A_Index].sequence )
				; }
		}

		Loop,% layout_ordenado1.Count() {
			id	:=	 StrRep( layout_ordenado1[A_Index][2],, "Layout"  )
			Dguard.cam_to_layout(	server
								,	l_guid%id%
								,	layout_ordenado1[A_Index][3]
								,	layout_ordenado1[A_Index][4] )
		}

}

ToolTip

;	Saída de dados para clipboard
	; Loop,% layouts.Count()
		; a .= layouts[A_index].server "`t" layouts[A_index].layout "`t" layouts[A_index].câmera  "`t" layouts[A_index].guid "`n"
	; MsgBox % clipboard := a
	; Msgbox	Done
	ExitApp