if	inc_functions
	Return
Global	inc_functions = 1

#Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
#Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk

; auto_update( software, version, script_dir, full_path ) {	;	Auto update do sistema via versão nova na base de dados
auto_update( version, software="" ) {	;	NECESSITA TESTE - Auto update do sistema via versão nova na base de dados	
	if Software
		if InStr( software, ".exe" )
			software := SubStr( software, 1, -4 )
	Else
		software := SubStr( A_ScriptName, 1, -4 )

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
	if ( sql.count()-1 = 0 )
		Return "Sem atualização disponível."

	version_sql := StrSplit( sql[ 2, 3 ], "." )
	version_file:= StrSplit( version, "." )

	Loop, 3	{ ;	Compara versão do executável com a base de dados
		if (A_Index = 3)
			sql_version := version_sql[A_Index]-1
		Else
			sql_version := version_sql[A_Index]
		; OutputDebug % sql_version " " version_file[A_Index]
		if ( sql_version > version_file[A_Index] )	{	;	se qualquer um dos campos de versão na base de dados for maior, atualiza
			MsgBox, 4, Atualização Disponível,% "Atualização disponível, gostaria de atualizar?"
				IfMsgBox No
				{
					skip = 1
					Return
				}
			base64.FileDec( sql[ 2, 2 ], A_ScriptDir "\" software "_new.exe" )
			Loop	{
				Sleep, 1000
				If fileExist( A_ScriptDir "\" software "_new.exe" )	;	se criou o novo executável, sai do loop para atualizar
					Break
				Else If ( A_Index > 25 ) {	;	se não criou o executável após 25 segundos, retorna falha e interrompe a atualização
					fail = 1
					mail.new(	"dsantos@cotrijal.com.br"
						.	,	"Falha ao atualizar o software " software
						.	,	"Falha ao atualizar o software " software " na máquina " A_IPAddress1 ", usuário logado " A_UserName " em " datetime() )
					Break
				}
			}
			if	Skip
				Return "Skip"
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
			ExitApp
		}
	}
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
	sql	:= RegExReplace( sql, "[^\d]+" )
	date:= RegExReplace( date, "[^\d]+" )
	if Strlen( sql ) = 14	;	 se a data foi passada no campo de sql, ajusta as variáveis
		is_date:=sql, sql:=0, date:=is_date
	If(	sql = 2
	&&	StrLen( date ) = 0 )	{
		MsgBox,0x40,ERRO, A função datetime() em modo SQL 2`, necessita que seja enviado o valor date para funcionar.
		Return
	}
	If( sql = 1 )
		Return		SubStr( A_Now, 1, 4 ) "-"  SubStr( A_Now, 5, 2 ) "-"  SubStr( A_Now, 7, 2 )
			.	" " SubStr( A_Now, 9, 2 ) ":"  SubStr( A_Now, 11, 2) ":"  SubStr( A_Now, 13, 2 ) ".000"
	else If ( sql = 2 )
		Return		SubStr( date, 5, 4 ) "-"  SubStr( date, 3, 2 ) "-"  SubStr( date, 1, 2 )
			.	" " SubStr( date, 9, 2 ) ":"  SubStr( date, 11, 2) ":"  SubStr( date, 13, 2 )
	else If(	sql	=	3
	&&			date!=	"" )	;	valor passado junto
		Return		SubStr( date, 1, 4 ) "-"  SubStr( date, 5, 2 ) "-"  SubStr( date, 7, 2 )
			.	" " SubStr( date, 9, 2 ) ":"  SubStr( date, 11, 2) ":"  SubStr( date, 13, 2 )
	Else If(	sql	=	0
	&&			date!=  "")
		return		SubStr( date, 7, 2 ) "/"  SubStr( date, 5, 2 ) "/"  SubStr( date, 1, 4 )
			.	" " SubStr( date, 9, 2 ) ":"  SubStr( date, 11, 2) ":"  SubStr( date, 13, 2 )
	Else
		Return		SubStr( A_Now, 7, 2 ) "/"  SubStr( A_Now, 5, 2 ) "/"  SubStr( A_Now, 1, 4 )
			.	" " SubStr( A_Now, 9, 2 ) ":"  SubStr( A_Now, 11, 2) ":"  SubStr( A_Now, 13, 2 )
}

debug( linha, params* ) {
	; Return
	output := "`n"
	for i, v in params
		output .= v "`n`t"
	OutputDebug % SubStr( output, 1, -2 ) "`n`tLinha:`t" linha
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
			If InStr( req.responseText, "OK" )
				Return	"Sucesso"
			Else
				Return	"Falha"
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
    ; exec	:= shell.Exec( A_AhkPath )
    exec	:= shell.Exec( A_AhkPath " /ErrorStdOut *")
	; MsgBox % Script
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

process_exist( process, pause = "0", server = "." ) {
	OutputDebug, % "SELECT * FROM Win32_Process WHERE Caption = '" StrRep(process,,".exe") ".exe'"
	for objItem in ComObjGet("winmgmts:\\" server "\root\CIMV2").ExecQuery("SELECT * FROM Win32_Process WHERE Caption = '" StrRep(process,,".exe") ".exe'")
	{
		if	Pause	{
			passed:= A_Now - SubStr( objItem.CreationDate, 1, 14 ) > pause ? 1 : pause - (A_Now - SubStr( objItem.CreationDate, 1, 14 ))
			Sleep,% passed "000"
		}
		return	StrLen( objItem.Caption ) = 0 ? 0 : 1
	}
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

randomName(MinLength=4, MaxLength=0)	{

	;This is a table of probabilities of given letter combinations.
	;Each list is the probability of any letter coming after the letter that is the variable name.
	;The 27th value is the probability that the word ends with the current letter.

	A=0.005129|0.020532|0.038276|0.031753|0.005903|0.009913|0.027038|0.014457|0.023527|0.003511|0.021702|0.086397|0.045315|0.192551|0.002685|0.014491|0.001136|0.142056|0.059445|0.043698|0.041322|0.018312|0.010774|0.001824|0.020584|0.010240|0.107428
	B=0.184518|0.021072|0.000500|0.002564|0.243982|0.000125|0.000188|0.002564|0.076033|0.001313|0.001563|0.055274|0.000875|0.002376|0.132933|0.000063|0.000000|0.133683|0.009192|0.000313|0.090977|0.000188|0.000125|0.000000|0.022447|0.000313|0.016820
	C=0.131713|0.001253|0.042204|0.003536|0.053348|0.001566|0.008727|0.275689|0.051557|0.000090|0.154493|0.028375|0.003849|0.004117|0.123255|0.001343|0.002954|0.036744|0.002506|0.003043|0.028419|0.000806|0.001343|0.000000|0.004699|0.017678|0.016694
	D=0.103809|0.005881|0.001079|0.024765|0.256609|0.003345|0.017266|0.006367|0.102029|0.000701|0.002968|0.027085|0.008849|0.007985|0.107424|0.000432|0.000432|0.046833|0.019208|0.017427|0.044783|0.001619|0.007068|0.000000|0.020557|0.005288|0.160192
	E=0.031341|0.012931|0.019802|0.020976|0.022773|0.007726|0.014163|0.010930|0.034414|0.002392|0.012409|0.104894|0.023455|0.108561|0.004291|0.007973|0.000464|0.239084|0.062957|0.042633|0.006958|0.011727|0.010582|0.001363|0.039371|0.008379|0.137452
	F=0.111275|0.000369|0.000985|0.000246|0.170236|0.139463|0.000985|0.000985|0.112752|0.000492|0.003570|0.058961|0.004677|0.004677|0.114476|0.000246|0.000123|0.100197|0.011324|0.021295|0.041113|0.000369|0.000246|0.000000|0.003570|0.000862|0.096504
	G=0.140257|0.004596|0.000919|0.003493|0.199694|0.002145|0.030944|0.064951|0.064767|0.000551|0.000919|0.053922|0.006311|0.020282|0.084191|0.000551|0.000368|0.083027|0.019179|0.012316|0.063725|0.000797|0.004718|0.000245|0.003309|0.000123|0.133701
	H=0.214954|0.004703|0.001599|0.001035|0.189466|0.002116|0.000564|0.002069|0.102610|0.000658|0.003621|0.037903|0.020973|0.022384|0.124759|0.000329|0.000000|0.032683|0.006207|0.021067|0.054221|0.000517|0.009358|0.000000|0.009828|0.000141|0.136233
	I=0.044717|0.012847|0.076362|0.026840|0.088736|0.009884|0.035604|0.003560|0.000896|0.001320|0.015511|0.082586|0.027886|0.216811|0.031571|0.012474|0.001270|0.031247|0.081889|0.054502|0.004158|0.011802|0.001494|0.002938|0.001245|0.009262|0.112588
	J=0.333844|0.000510|0.012251|0.006126|0.211843|0.000000|0.001021|0.003063|0.059214|0.001021|0.010720|0.002552|0.003063|0.009188|0.197550|0.000000|0.000000|0.000000|0.002552|0.007657|0.110260|0.000000|0.001021|0.000000|0.000510|0.001531|0.024502
	K=0.105301|0.002453|0.000239|0.000658|0.194089|0.001615|0.000120|0.013522|0.166507|0.000838|0.003889|0.046787|0.009633|0.017470|0.101412|0.000299|0.000060|0.036078|0.023932|0.001137|0.039069|0.000897|0.004786|0.000239|0.025009|0.000179|0.203781
	L=0.142144|0.012700|0.007785|0.033484|0.190748|0.007136|0.004641|0.004666|0.115222|0.000499|0.010554|0.157140|0.017815|0.003019|0.079568|0.004042|0.000549|0.002146|0.023429|0.022031|0.025599|0.007884|0.002770|0.000075|0.015320|0.004292|0.104743
	M=0.313971|0.039109|0.071357|0.001102|0.144316|0.001552|0.001502|0.001252|0.093991|0.000300|0.003756|0.007561|0.032849|0.001753|0.110366|0.030796|0.000451|0.004507|0.016475|0.000701|0.039509|0.000150|0.001052|0.000000|0.007161|0.000801|0.073660
	N=0.061413|0.016703|0.021091|0.069684|0.122481|0.004871|0.078736|0.008455|0.062562|0.000942|0.020976|0.004802|0.002481|0.042114|0.058036|0.001011|0.000712|0.003538|0.053877|0.050017|0.007168|0.001746|0.003331|0.000000|0.007099|0.011970|0.284182
	O=0.008524|0.017299|0.028237|0.027181|0.024717|0.015061|0.013377|0.013477|0.008725|0.002338|0.011843|0.083101|0.033291|0.169068|0.030248|0.016394|0.000654|0.114958|0.060421|0.038018|0.047975|0.020140|0.041337|0.002791|0.010611|0.008725|0.151492
	P=0.176699|0.000875|0.001459|0.000972|0.201984|0.015365|0.000292|0.038802|0.113099|0.000097|0.010503|0.051055|0.002334|0.003209|0.103958|0.076145|0.000000|0.074492|0.021103|0.010114|0.033064|0.000194|0.000875|0.000000|0.007002|0.000097|0.056209
	Q=0.006831|0.001366|0.000000|0.001366|0.000000|0.000000|0.000000|0.000000|0.005464|0.000000|0.000000|0.000000|0.000000|0.000000|0.000000|0.000000|0.000000|0.001366|0.000000|0.000000|0.968579|0.001366|0.000000|0.000000|0.000000|0.000000|0.013661
	R=0.107889|0.012734|0.012774|0.039466|0.114066|0.005515|0.027955|0.005334|0.100509|0.000762|0.014499|0.017507|0.018449|0.029038|0.095937|0.004171|0.001043|0.037882|0.037180|0.049252|0.031785|0.005475|0.003068|0.000160|0.020154|0.005715|0.201681
	S=0.063337|0.009701|0.073814|0.002910|0.097763|0.001774|0.001525|0.060925|0.050808|0.000554|0.061286|0.020318|0.015134|0.008482|0.067384|0.021426|0.002328|0.001663|0.053885|0.132300|0.016797|0.001247|0.011808|0.000000|0.003964|0.007429|0.211437
	T=0.091587|0.001630|0.012519|0.000347|0.159384|0.001595|0.001769|0.072652|0.074005|0.001283|0.006208|0.018484|0.009294|0.007352|0.110522|0.000555|0.000069|0.065543|0.026564|0.109169|0.024691|0.000763|0.005098|0.000000|0.013525|0.036447|0.148946
	U=0.021849|0.032911|0.052449|0.040176|0.074243|0.017281|0.047056|0.012163|0.041827|0.002862|0.015190|0.084205|0.058118|0.084810|0.006219|0.021354|0.001101|0.136984|0.111833|0.065658|0.000881|0.005449|0.002367|0.008806|0.007320|0.013979|0.032911
	V=0.281558|0.000162|0.000647|0.001293|0.327461|0.000162|0.000323|0.000162|0.251657|0.000485|0.001616|0.010991|0.000162|0.003071|0.078390|0.000000|0.000000|0.012769|0.007435|0.000323|0.004687|0.000162|0.000323|0.000000|0.007112|0.000485|0.008566
	W=0.204323|0.006032|0.003770|0.009801|0.191380|0.000880|0.001131|0.037824|0.200804|0.000000|0.005278|0.018472|0.003644|0.016210|0.092109|0.000377|0.000126|0.013948|0.074265|0.004398|0.007665|0.000628|0.000628|0.000000|0.015582|0.000628|0.090098
	X=0.063694|0.022293|0.004777|0.001592|0.081210|0.012739|0.000000|0.011146|0.065287|0.000000|0.001592|0.039809|0.014331|0.014331|0.044586|0.001592|0.000000|0.004777|0.033439|0.078025|0.007962|0.000000|0.014331|0.003185|0.004777|0.001592|0.472930
	Y=0.061443|0.012165|0.011753|0.016289|0.072062|0.003505|0.004845|0.004845|0.003505|0.000206|0.016907|0.026495|0.018763|0.042268|0.032680|0.003711|0.000206|0.014330|0.026186|0.011856|0.008763|0.001443|0.004021|0.000206|0.000412|0.002887|0.598247
	Z=0.165246|0.006787|0.005366|0.004261|0.174085|0.000947|0.004261|0.003946|0.121370|0.000000|0.014205|0.018466|0.017045|0.009154|0.066761|0.000789|0.001578|0.001578|0.004104|0.000631|0.035827|0.000631|0.008996|0.000000|0.034722|0.058396|0.240846
	Start=0.037129|0.091544|0.068008|0.055260|0.020789|0.036464|0.052670|0.058435|0.006802|0.012894|0.051228|0.053638|0.085992|0.020597|0.016318|0.052275|0.002725|0.047647|0.109494|0.038852|0.004460|0.023480|0.036127|0.000180|0.006261|0.010732


	;This allows numerical values to easily be converted to letters.
	Alphabet = ABCDEFGHIJKLMNOPQRSTUVWXYZ

	Loop
	{
		;Checks for the previous letter to determine which set of probabilities to use.
		If (!Word)
			Previous = Start
		Else
			Previous := SubStr(Word, 0, 1)


		;Randomly chooses the next letter, based on the probabilities listed above.
		Random, rand, 0.0, 1.0
		Sum = 0
		Next =
		Loop, parse, %Previous%, |
		{
			Sum += A_LoopField
			If (rand<Sum)
			{
				Next := SubStr(Alphabet, A_Index, 1)
				Break
			}
		}


		;Finishes the word if the word randomly ends or reaches the maximum length.
		If ((!Next AND StrLen(Word)>=MinLength) OR (MaxLength AND StrLen(Word)=MaxLength))
			Break

		Word .= Next
	}

	StringLower, Word, Word, T
	Return, Word
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

SetCtrlIp(hControl, IPAddress)	{
    static WM_USER			:= 0x0400
    static IPM_SETADDRESS	:= WM_USER + 101
    ; Pack the IP address into a 32-bit word for use with SendMessage.
    IPAddrWord := 0
    Loop, Parse, IPAddress, .
        IPAddrWord := ( IPAddrWord * 256 ) + A_LoopField
    SendMessage IPM_SETADDRESS, 0, IPAddrWord,, ahk_id %hControl%
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
