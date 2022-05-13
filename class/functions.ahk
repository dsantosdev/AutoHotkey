if	inc_functions
	Return
Global	inc_functions = 1

#Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk

; auto_update( software, version, script_dir, full_path ) {	;	Auto update do sistema via versão nova na base de dados
auto_update( software, version ) {	;	NECESSITA TESTE - Auto update do sistema via versão nova na base de dados	
	if InStr( software, ".exe" )
		software := SubStr( software, 1, -4 )
	s =
		(
			SELECT	TOP(1)
				 [name]
				,[bin]
				,[version]
			FROM
				[ASM].[dbo].[Softwares]
			WHERE
				[name] = '%software%'
			ORDER BY
				1
			DESC 
		)
	sql	:=	sql( s, 3 )
	if ( sql.count(-1 = 0) )
		Return "Atualizado"

	version_sql := StrSplit( sql[ 2, 3 ], "." )
	version_file:= StrSplit( version, "." )
	Loop, 4	;	Compara versão do executável com a base de dados
		if ( version_sql[A_Index] > version_file[A_Index] )	{	;	se qualquer um dos campos de versão na base de dados for maior, atualiza
			base64.FileDec( sql[ 2, 2 ], A_ScriptDir "\" software "_new.exe" )
			Loop	{
				Sleep, 1000
				If fileExist( A_ScriptDir "\" software "_new.exe" )	;	se criou o novo executável, sai do loop para atualizar
					Break
				Else If ( A_Index > 25 ) {	;	se não criou o executável após 25 segundos, retorna falha e interrompe a atualização
					fail = 1
					Break
				}
			}
			if	Fail	;	se não criou executável, retorna mensagem de falha 
				Return "Falha ao criar o executável."
			;	bloco de update
			update_software	:=	"ToolTip, Atualizando " software	;	prepara var para execução de script de atualização assíncrono para excluir o executável antigo
						.	"`nSleep, 2000"
						.	"`nFileMove	,"	;	Renomeia o executável antigo
										.	A_ScriptFullPath
										.	"," SubStr( A_ScriptFullPath, 1 , -4 ) "_old.exe, 1`nsleep 1000"
						.	"`nFileMove	,"	;	prepara o arquivo atualizado para executar
										.	SubStr( A_ScriptFullPath, 1 , -4 ) "_new.exe,"
										.	A_ScriptFullPath ", 1`nsleep 1000"

						.	"`nFileDelete,"	SubStr( A_ScriptFullPath, 1 , -4 ) "_old.exe`nsleep 1000"	;	deleta o executável antigo
						.	"`nRun, "		A_ScriptFullPath	;	executa o novo executável
						.	"`nExitapp"	;	sai do script de update
			new_instance( update_software )	;	executa a atualização assíncrona
		}
	return	"Atualizado"
}

chrome_history() {	;	Bloqueia a exclusao de historico
	RegRead,	history,	HKLM,	SOFTWARE\Policies\Google\Chrome,	IncognitoEnabled
	if ( history != 0 )	{
		RegWrite, REG_DWORD,	HKEY_LOCAL_MACHINE, SOFTWARE\Policies\Google\Chrome,	AllowDeletingBrowserHistory,	0
		RegWrite, REG_DWORD,	HKLM, SOFTWARE\Policies\Google\Chrome,					AllowDeletingBrowserHistory,	0
	}
	return	OK
}

chrome_incognito() {	;	Bloqueia modo anonimo
	RegRead,	incognito,	HKLM,	SOFTWARE\Policies\Google\Chrome,	IncognitoEnabled
	if ( incognito != 0 )	{
		RegWrite, REG_DWORD,	HKEY_LOCAL_MACHINE, SOFTWARE\Policies\Google\Chrome,	IncognitoEnabled,	0
		RegWrite, REG_DWORD,	HKLM, SOFTWARE\Policies\Google\Chrome,					IncognitoEnabled,	0
	}
	return	OK
}

datetime( sql=0, date="", format="" ) {
	if Strlen(sql) = 14
		is_date:=sql, sql:=0, date:=is_date
	If(	sql = 2
	&&	StrLen( date ) = 0 )	{
		MsgBox,0x40,ERRO, A função datetime() em modo SQL 2`, necessita que seja enviado o valor date para funcionar.
		Return
	}
	If( sql = 1 )
		Return SubStr( A_Now, 1, 4 ) "-"  SubStr( A_Now, 5, 2 ) "-"  SubStr( A_Now, 7, 2 ) " "  SubStr( A_Now, 9, 2 ) ":"  SubStr( A_Now, 11, 2) ":"  SubStr( A_Now, 13, 2 ) ".000"
	else If ( sql = 2 )	{
		date := RegExReplace(date, "\D")
		Return SubStr( date, 5, 4 ) "-"  SubStr( date, 3, 2 ) "-"  SubStr( date, 1, 2 ) " "  SubStr( date, 9, 2 ) ":"  SubStr( date, 11, 2) ":"  SubStr( date, 13, 2 )
	}
	else If(	sql	=	3
	&&			date!=	"" )	{	;	valor passado junto
		date := RegExReplace(date, "\D")
		Return SubStr( date, 1, 4 ) "-"  SubStr( date, 5, 2 ) "-"  SubStr( date, 7, 2 ) " "  SubStr( date, 9, 2 ) ":"  SubStr( date, 11, 2) ":"  SubStr( date, 13, 2 )
	}
	Else If(	sql	=	0
	&&			date!=  "")
		return SubStr( date, 7, 2 ) "/"  SubStr( date, 5, 2 ) "/"  SubStr( date, 1, 4 ) " "  SubStr( date, 9, 2 ) ":"  SubStr( date, 11, 2) ":"  SubStr( date, 13, 2 )
	Else
		Return SubStr( A_Now, 7, 2 ) "/"  SubStr( A_Now, 5, 2 ) "/"  SubStr( A_Now, 1, 4 ) " "  SubStr( A_Now, 9, 2 ) ":"  SubStr( A_Now, 11, 2) ":"  SubStr( A_Now, 13, 2 )
}

email_notificador( is_test = "" )	{
	ListLines, Off
	if	!is_operator && A_IPAddress1 != "192.9.100.100"
		Return
	if is_test {
			SoundPlay,	\\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\%is_test%.wav
			if (is_test = "toasty" )
				toasty()
		Return
	}
	s =
		(
		SELECT TOP(1)
			 p.[Mensagem]
			,p.[operador]
			,c.[Nome]
			,p.[pkid]
		FROM
			[ASM].[dbo].[_Agenda] p
		LEFT JOIN
			[Iris].[IrisSQL].[dbo].[Clientes] c
		ON
			p.[id_cliente] = c.[IdUnico]
		ORDER BY
			4
		DESC
		)
		email := sql( s , 3 )
	If ( StrLen( last_id ) = 0 ) {
		; OutputDebug % "Last_ID = 0"
		last_id := email[2,4]
		return	last_id
	}
	Else if ( last_id < email[2,4] ) {
		; OutputDebug	% "Novo e-mail"
		operador	:= email[2,2]
		last_id		:= email[2,4]

		;	easter_egg
			sound		=
			Random, easter_egg, 1, 100
			if ( easter_egg > 5 && easter_egg < 95 )
				sound = outlook
			else if ( easter_egg > 94 )
				sound = yoda
			else if ( easter_egg < 6 ){
				sound = toasty
				toasty()
			}
			SoundPlay,	\\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\%sound%.wav
		;
		TrayTip,%	email[2,3] "`nNOVO E-MAIL - " datetime(), % email[2,1]
	}
	if ( last_id > email[2,4] )	{
		; OutputDebug % "Maior que o identificador"
		last_id := email[2,4]
	}
		; OutputDebug % "id igual"
	ListLines,	On
	return	last_id
}

executar( software, software_path="", busca="" )	{
	if	StrLen( software_path )	= 0
		software_path	= C:\Dguard Advanced\
	if	StrLen( busca )	= 0
		busca	= \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\
	try	{
		Run, %software_path%%software%.exe
	}	catch	{
		FileCopy, %busca%%software%.exe, %software_path%%software%.exe, 1
		Sleep, 500
		if	errorlevel = 0
			Run, %software_path%%software%.exe
	}
}

formatseconds( Seconds ) {
	time := 19990101
	time += Seconds, seconds
	FormatTime, mmss, %time%, mm:ss
	return Seconds//3600 ":" mmss
}

json( ByRef src , params* ) {
	static q := Chr(34)

	if ( params.Count() != 0 )	{	;	MEU
		for index,param in params
			arg := ( p_key := SubStr( param, 1, InStr( param , "|" )-1 )) ( p_value := SubStr( param, InStr( param , "|" )+1 ) )
		; MsgBox % P_KEY "`n" p_value
	}

	key		:= "", is_key := false
	stack	:= [ tree := [] ]
	is_arr	:= Object(tree, 1) ; ahk v1                    ; orig -> is_arr := { (tree): 1 }
	next	:= q "{[01234567890-tfn"
	pos		:= 0

	while ( (ch := SubStr(src, ++pos, 1)) != "" ) {

		if InStr(" `t`n`r", ch)	;	se tab ou nova linha, skip
			continue
		if !InStr(next, ch, true) {
			testArr := StrSplit(SubStr(src, 1, pos), "`n")
			ln := testArr.Length()
			
			col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))

			msg := Format("{}: line {} col {} (char {})"
			,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
			  : (next == "'")     ? "Unterminated string starting at"
			  : (next == "\")     ? "Invalid \escape"
			  : (next == ":")     ? "Expecting ':' delimiter"
			  : (next == q)       ? "Expecting object key enclosed in double quotes"
			  : (next == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
			  : (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
			  : (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
			  : [ "Expecting JSON value(string, number, [true, false, null], object or array)"
			    , ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
			, ln, col, pos)

			throw Exception(msg, -1, ch)
		}
		
		is_array := is_arr[obj := stack[1]] 

		if i := InStr("{[", ch) { ; start new object / map?
			val := (i = 1) ? Object() : Array()	; ahk v1 != 1
			is_array ? obj.Push(val) : obj[key] := val
			stack.InsertAt(1,val)
			is_arr[val] := !(is_key := ch == "{")
			
			next := q (is_key ? "}" : "{[]0123456789-tfn")
		}
		else if InStr("}]", ch) {
			stack.RemoveAt(1)
			next := stack[1]==tree ? "" : is_arr[stack[1]] ? ",]" : ",}"
		}
		else if InStr(",:", ch) {
			is_key := (!is_array && ch == ",")
			next := is_key ? q : q "{[0123456789-tfn"
		}
		else { ; string | number | true | false | null
			if (ch == q) { ; string
				i := pos
				while i := InStr(src, q,, i+1) {
					val := StrReplace(SubStr(src, pos+1, i-pos-1), "\\", "\u005C")
					if (SubStr(val, 0) != "\")
						break
				}
				if !i ? (pos--, next := "'") : 0
					continue

				pos := i ; update pos

				val := StrReplace(val,    "\/",  "/")
				 val := StrReplace(val, "\" . q,    q)
				,val := StrReplace(val,    "\b", "`b")
				,val := StrReplace(val,    "\f", "`f")
				,val := StrReplace(val,    "\n", "`n")
				,val := StrReplace(val,    "\r", "`r")
				,val := StrReplace(val,    "\t", "`t")

				i := 0
				while i := InStr(val, "\",, i+1) {
					if (SubStr(val, i+1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
						continue 2

					xxxx := Abs("0x" . SubStr(val, i+2, 4)) ; \uXXXX - JSON unicode escape sequence
					if (A_IsUnicode || xxxx < 0x100)
						val := SubStr(val, 1, i-1) . Chr(xxxx) . SubStr(val, i+6)
				}
				
				if is_key {
					key := val, next := ":"
					continue
				}
			}
			else { ; number | true | false | null
				val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$",, pos)-pos)
				static number := "number", integer := "integer", float := "float"
				if val is %number%
				{
					if val is %integer%
						val += 0
					if val is %float%
						val += 0
					else if (val == "true" || val == "false")
						val := %val% + 0
					else if (val == "null")
						val := ""
					else if is_key {					; else if (pos--, next := "#")
						pos--, next := "#"					; continue
						continue
					}
				; MsgBox % teste "`n" key ":" val
				}
				
				pos += i-1
			}
			
			is_array ? obj.Push(val) : obj[key] := val
			next := obj == tree ? "" : is_array ? ",]" : ",}"
		}
	}
	
	return tree[1]
}

http( url , token="", show_response="0" ) {
	static req := ComObjCreate( "Msxml2.XMLHTTP" )
	req.open( "GET", url, false )
	if	( token = "" )
		req.SetRequestHeader( "Authorization", "Basic YWRtaW46QGRtMW4=" )	;	login local do dguard(admin)
	Else
		req.SetRequestHeader( "Authorization", token )						;	bearer custom
	req.SetRequestHeader( "If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT" )
	if show_response {
		req.send()
		return	%	req.responseText
	}
	Else {
		Try {
			req.send()
			Return "Sucesso"
		}
		catch
			Return "Erro"
	}
}

login( @usuario, @senha, @admin = "" ) {
	admins	:=	"dsantos","arsilva","ddiel"
	if ( @admin != "" )	{
		if InStr( admins, @usuario )
			return DllCall(	"advapi32\LogonUser"
						,	"str",	@usuario
						,	"str",	"Cotrijal"
						,	"str",	@senha
						,	"Ptr",	3
						,	"Ptr",	3
						,	"UintP"
						,	nSize	)	=	1
										?	"1"
										:	"0"
		Else
			Return 0
	}
	Else
		return DllCall(	"advapi32\LogonUser"
					,	"str",	@usuario
					,	"str",	"Cotrijal"
					,	"str",	@senha
					,	"Ptr",	3
					,	"Ptr",	3
					,	"UintP"
					,	nSize	)	=	1
									?	"1"
									:	"0"
}

new_instance( Script )	{	;	in development
    shell	:= ComObjCreate("WScript.Shell")
    exec	:= shell.Exec( A_AhkPath " /ErrorStdOut *")
    exec.StdIn.Write( script )
    exec.StdIn.Close()
}

notificar( ) {	;	DEFASADO - email_notificador() é o novo
	ListLines, Off
	s =
		(
		SELECT TOP(1)	p.IdCliente
					,	p.QuandoAvisar
					,	p.Mensagem
					,	p.Assunto
					,	c.Nome
					,	p.Idaviso
		FROM
			[IrisSQL].[dbo].[Agenda] p
		LEFT JOIN
			[IrisSQL].[dbo].[Clientes] c
				ON p.IdCliente = c.IdUnico
		ORDER BY
			6 DESC
		)
		s := sql( s )
	if ( StrLen( last_id ) = 0 )	{
		last_id := s[2,6]
		return % last_id
	}
	if ( last_id < s[2, 6] )		{	;executa notificação
		subjm		:= s[2, 4]
		iadaviso	:= s[2, 6]
		if ( SubStr( A_IpAddress1, InStr( A_IpAddress1, ".",,,3 )+1 ) = 184 )	;	Remove errados
			If ( InStr( subjm, "Informou" ) > 0 )		{
				d = DELETE FROM [IrisSQL].[dbo].[Agenda] WHERE idaviso = '%iadaviso%'
				sql( d )
				return
			}
		last_id := s[2,6]
		TrayTip, % s[2,5] "`nNovo E-Mail - " datetime(), % s[2, 3]
		Random, easteregg, 1, 100
		if ( easteregg < 95 )
			som = car
		else
				som = yoda
		SoundPlay, \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\%som%.wav
		}
	if ( last_id > s[2, 6] )
		last_id := s[2, 6]
	GuiControl,	debug:,	debug4,% s[2,6] " - " last_id
	ListLines, On
	return	last_id
}

operador() {
	Return	A_IPAddress1 = "192.9.100.102"
						? 1
		:	A_IPAddress1 = "192.9.100.106"
						? 2
		:	A_IPAddress1 = "192.9.100.109"
						? 3
		:	A_IPAddress1 = "192.9.100.114"
						? 4
		:	A_IPAddress1 = "192.9.100.118"
						? 5
		:	A_IPAddress1 = "192.9.100.123"
						? 6
		:	"2"
}

ping( address )	{
	rVal := []
	Loop, Parse, address, % A_Space
		addr	.=	addr
				?	A_Space "or Address = '" A_LoopField "'"
				:	 A_LoopField "'"
	colPings := ComObjGet( "winmgmts:" ).ExecQuery( "Select * From Win32_PingStatus where Address = '" addr )._NewEnum
	While colPings[ objStatus ]
		rVal.Push( [ ( ( oS := ( objStatus.StatusCode = "" or objStatus.StatusCode <> 0 ) ) ? "0" : "1" ) , objStatus.Address ] )
	if ( InStr( Address , A_Space ) > 0 )	;	Multi Addresses or not
		Return rVal
	Else
		Return ( ( oS := ( objStatus.StatusCode = "" or objStatus.StatusCode <> 0 ) ) ? "0" : "1" )
}

progressBar( descriptionBGColor="" , description="" ) {
	Global	stbar
	WinGetPos,,,, taskbar, ahk_class Shell_TrayWnd
	if ( descriptionBGColor = "" )
		descriptionBGColor	=	499d35
	else if ( descriptionBGColor = "destroy" ) {
		Gui,Progress:Destroy
		Return
	}
	Gui, Progress:Color,%	descriptionBGColor
	Gui, Progress:Add, Text, BackgroundTrans y-60
	Gui, Progress: -Toolwindow -Caption +AlwaysOnTop -Border
	Gui, Progress:Font,	s10 Bold

	Gui, Progress:Add, StatusBar,%	"w" A_ScreenWidth - 10 "	"
								.	"-Theme	"
								.	"vstbar	"
								,%	description
	GuiControl,% "Progress: +Background" descriptionBGColor, stbar
	
	Gui, Progress:Default
	SB_SetParts( A_ScreenWidth // 10 * 3, A_ScreenWidth // 10 * 7 )
	
	Gui, Progress:Show,%	"y-8"
						.	"w" A_ScreenWidth	"	"
						,	Progress
}

regDelete( key_name ) {
	ErrorLevel =
	RegDelete,% key_name
	Return ErrorLevel = 1 ? "Erro ao deletar o registro`nRegDelete," key_name "," value_name : "Registro deletado com sucesso!"
}

regRead( key_name , key )	{
	RegRead, value_output,% key_name,% key
	Return	value_output
}

regWrite( value_type , key_name, value_name="", value=""  ) {
	ErrorLevel			=
	types_of_value		= REG_SZ,REG_EXPAND_SZ,REG_MULTI_SZ,REG_DWORD,REG_BINARY
	types_of_key_name	= HKEY_LOCAL_MACHINE,HKEY_USERS,HKEY_CURRENT_USER,HKEY_CLASSES_ROOT,HKEY_CURRENT_CONFIG,HKLM,HKU,HKCU,HKCR,HKCC,

	if (InStr( types_of_value , value_type ) = 0 )	{
		MsgBox % "Tipo de valor informado inválido. (primeiro parâmetro)"
		Return
	}
	key_name_	:= StrSplit( key_name , "\" )
	if (InStr( types_of_key_name , key_name_[1] ) = 0 )	{
		MsgBox % "Tipo de nome de chave informado inválido. (segundo parâmetro)"
		Return
	}
	RegWrite,% value_type ,% key_name,% value_name ,% value 
	Return %	ErrorLevel	= 1
						? "Erro ao escrever o registro`nRegWrite," value_type "," key_name "," value_name "," value
						: "Registrado com sucesso!"
}

runCmd( command )	{	;	hidden cmd
	DetectHiddenWindows On
	Run		%ComSpec%,, Hide, pid
		WinWait ahk_pid %pid%

	DllCall( "AttachConsole" , "UInt" , pid )

	Shell	:= ComObjCreate( "WScript.Shell" )
	Exec	:= Shell.Exec( ComSpec " /C " command )

	; while	Exec.Status == 0
		; OutputDebug % just_for_loop

	DllCall( "FreeConsole" )
	Return	Exec.StdOut.ReadAll()
}

search_delay( delay = "500", done = "0" ) {
	/*
		Inserir antes do Submit;
		Não precisa de "if's", apenas a chamada ex: search_delay( "750" )
	*/
	if ( done = 0 )
		Loop	{
			; OutputDebug % A_TimeIdleKeyboard
			if ( A_TimeIdleKeyboard > delay )	{
				Return	done = 0
				break
			}
		}
	Else
		Return	done = 0
}

StrRep( haystack , separator = ":" , needles* )	{
	/*
		texto :=	"Nome da câmera alterado dê:[n]'a'[n][t]para:[n]'b'[n]"
		MsgBox %  StrRep( texto , , "[n]:%0A", "[t]:%09" ) parametros
	*/
	for i, v in needles
	{
		if ( InStr( v , separator ) > 0 )	{
			SearchText	:= SubStr( v, 1 , InStr( v , separator )-1 )	
			ReplaceText := SubStr( v,InStr( v , separator )+1 )
		}
		Else	{
			SearchText	:=	v
			ReplaceText	:=	""
		}
		haystack := StrReplace( haystack, SearchText , ReplaceText )
	}
	Return haystack

}

toasty() {
	x := A_ScreenWidth
	WinGetPos,,,, taskbar, ahk_class Shell_TrayWnd

	Gui, Toasty: +LastFound +AlwaysOnTop +ToolWindow -Caption
	Gui, Toasty:Color, EEAA99
	Gui, Toasty:Add, Picture, BackgroundTrans HWNDToasty, \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\toasty.png
		ControlGetPos,,, w, h,,% "ahk_id " Toasty
	WinSet, TransColor, EEAA99
	
	Gui, Toasty:Show,% "x" A_ScreenWidth " y" (A_ScreenHeight - taskbar ) - h

	Loop, 5	{
		x -= 52
		WinMove,% x ,% (A_ScreenHeight - taskbar ) - h
	}
	Gui, Toasty:Destroy
}

unicode( text , accentXunicode="1" ) {
	static unicode := {}
		unicode["á"] := "\u00e1"
		unicode["à"] := "\u00e0"
		unicode["â"] := "\u00e2"
		unicode["ã"] := "\u00e3"
		unicode["ä"] := "\u00e4"
		unicode["Á"] := "\u00c1"
		unicode["À"] := "\u00c0"
		unicode["Â"] := "\u00c2"
		unicode["Ã"] := "\u00c3"
		unicode["Ä"] := "\u00c4"
		unicode["é"] := "\u00e9"
		unicode["è"] := "\u00e8"
		unicode["ê"] := "\u00ea"
		unicode["ê"] := "\u00ea"
		unicode["É"] := "\u00c9"
		unicode["È"] := "\u00c8"
		unicode["Ê"] := "\u00ca"
		unicode["Ë"] := "\u00cb"
		unicode["í"] := "\u00ed"
		unicode["ì"] := "\u00ec"
		unicode["î"] := "\u00ee"
		unicode["ï"] := "\u00ef"
		unicode["Í"] := "\u00cd"
		unicode["Ì"] := "\u00cc"
		unicode["Î"] := "\u00ce"
		unicode["Ï"] := "\u00cf"
		unicode["ó"] := "\u00f3"
		unicode["ò"] := "\u00f2"
		unicode["ô"] := "\u00f4"
		unicode["õ"] := "\u00f5"
		unicode["ö"] := "\u00f6"
		unicode["Ó"] := "\u00d3"
		unicode["Ò"] := "\u00d2"
		unicode["Ô"] := "\u00d4"
		unicode["Õ"] := "\u00d5"
		unicode["Ö"] := "\u00d6"
		unicode["ú"] := "\u00fa"
		unicode["ù"] := "\u00f9"
		unicode["û"] := "\u00fb"
		unicode["ü"] := "\u00fc"
		unicode["Ú"] := "\u00da"
		unicode["Ù"] := "\u00d9"
		unicode["Û"] := "\u00db"
		unicode["ç"] := "\u00e7"
		unicode["Ç"] := "\u00c7"
		unicode["ñ"] := "\u00f1"
		unicode["Ñ"] := "\u00d1"
		unicode["&"] := "\u0026"
		unicode["'"] := "\u0027"
	 For Key, Value in unicode
	 	if accentXunicode
		 	text := RegExReplace( text, Key,		Value )
	 	Else
		 	text := RegExReplace( text, "\" Value,	Key )
	Return	text
}

update( comando = "" ) {
	q = UPDATE [ASM].[dbo].[_gestao_sistema] SET [complemento1] = '%up%' WHERE [descricao] = '%ip%'
	sql(q, 3)
	if ( StrLen( sql_le ) = 0 )
		return 0
	return sql_le
}