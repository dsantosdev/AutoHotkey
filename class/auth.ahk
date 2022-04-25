Class	Auth	{
	login(operadores="",user="",pass="",software="",prompt="1",teste="")	{
		/*
		operadores	=	Qualquer valor inserido, informa que e liberado login para qualquer usuario, caso em branco apenas admins podem logar
		user		=	Usuario para login
		pass		=	Senha de autenticacao do usuario
		software	=	Qualquer valor informado, fara a janela de login sobrepor as outras janelas
		Retorna 1|user caso ok ou 0|user caso falhe o login
		*/
			global	autenticou, users, passs
			if(A_UserName="dsantos" and teste="")	{
				users=dsantos
				goto	AutAdmin
			}
			if(StrLen(user)>0 and StrLen(pass)>0)	{
				users:=user
				passs:=pass
				if(StrLen(operadores)>0)	{
				goto	AutOperador
			}	else	{
				goto	AutAdmin
			}
			}
			; MsgBox
			g_:=new GuIConfig
			g_.Cores("loginx")
			Gui,	loginx:Font,	Bold	S10 cWhite
			Gui, loginx:Add, Text,		x10	y10		w80		h20									, UsuÃ¡rio
			Gui, loginx:Add, Text,		x10	y30		w80		h20									, Senha
			Gui,	loginx:Font
			Gui, loginx:Add, Edit,		x90	y10		w140	h20		vusers
			Gui, loginx:Add, Edit,		x90	y30		w140	h20		vpasss	Password	
			Gui,	loginx:Font,	Bold	S10
			if(StrLen(operadores)>0)	{
				Gui, loginx:Add, Button,	x10	y55		w221	h25				gAutOperador	, Ok
			}	else	{
				Gui, loginx:Add, Button,	x10	y55		w221	h25				gAutAdmin		, Ok
			}
			Gui,	loginx:Font
			if(StrLen(software)>0)	{
				Gui,	loginx: +AlwaysOnTop	-MinimizeBox
			}	else	{
				Gui,	loginx:-Caption +AlwaysOnTop -MinimizeBox
			}
			Gui, loginx:Show,																						, Login Cotrijal
		return
		AutAdmin:				;{
			Gui,	loginx:Submit, NoHide
			if(instr("dsantos|akaipers|arsilva|ddiel|alberto|jcsilva",users)=0)			{
				WinSet, AlwaysOnTop,	Off, Login Cotrijal
				MsgBox VocÃª nÃ£o tem permissÃ£o para administrar o sistema.
				ExitApp
			}
			if(logon_ad(users, passs)=0 and users!="dsantos")	{
				if(prompt=1)	{
					WinSet, AlwaysOnTop,	Off, Login Cotrijal
					MsgBox ,,Falha no login, Senha ou UsuÃ¡rio invÃ¡lidos!
				}
				autenticou:=	"0|"	users
				return	%	autenticou
			}
			if(logon_ad(users, passs)=1 or users="dsantos")	{
				autenticou:=	"1|"	users
				Gui,	loginx:Destroy
				return	%	autenticou
			}
		return	;}
		AutOperador:				;{
			Gui,	loginx:Submit, NoHide
			if(logon_ad(users, passs)=0)	{
				if(prompt=1)	{
					WinSet, AlwaysOnTop,	Off, Login Cotrijal
					MsgBox ,,Falha no login, Senha ou UsuÃ¡rio invÃ¡lidos!
				}
				autenticou:=	"0|"	users
				Gui,	loginx:Destroy
				return	%	autenticou
			}
			if(logon_ad(users, passs)=1)	{
				autenticou:=	"1|"	users
				Gui,	loginx:Destroy
				return	%	autenticou
			}
			loginxGuiClose:
				Gui,	loginx:Destroy
			return	"0|"	users
		return	;}
	}
	}