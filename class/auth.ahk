if	inc_auth
	Return
Global	inc_auth = 1
#include C:\Users\dsantos\Desktop\AutoHotkey\class\Gui.ahk
#include C:\Users\dsantos\Desktop\AutoHotkey\class\Windows.ahk
Class	Auth	{
	login( operadores="", user="", pass="", software="", prompt="1", teste="" )	{
		/*
		operadores	=	Qualquer valor inserido, informa que e liberado login para qualquer usuario, caso em branco apenas admins podem logar
		user		=	Usuario para login
		pass		=	Senha de autenticacao do usuario
		software	=	Qualquer valor informado, fara a janela de login sobrepor as outras janelas
		Retorna 1|user caso ok ou 0|user caso falhe o login
		*/
			global	autenticou
				,	users
				,	passs
			if( A_UserName = "dsantos"
			&&	teste = "" )	{
				users = dsantos
				Goto	AutAdmin
			}
			if( StrLen( user ) > 0
			&&	StrLen( pass ) > 0 )	{
				users := user
				passs := pass
				if( StrLen( operadores ) > 0 )
					Goto	AutOperador
				else
					goto	AutAdmin
			}
			gui.Cores("loginx")
			Gui, loginx:Font,	Bold	S10 cWhite
			Gui, loginx:Add, Text,		x10	y10		w80		h20									, Usuário
			Gui, loginx:Add, Text,		x10	y30		w80		h20									, Senha
			Gui, loginx:Font
			Gui, loginx:Add, Edit,		x90	y10		w140	h20		vusers
			Gui, loginx:Add, Edit,		x90	y30		w140	h20		vpasss	Password	
			Gui, loginx:Font,	Bold	S10
			if( StrLen( operadores ) > 0 )
				Gui, loginx:Add, Button,	x10	y55		w221	h25				gAutOperador	, Ok
			else
				Gui, loginx:Add, Button,	x10	y55		w221	h25				gAutAdmin		, Ok
			Gui,	loginx:Font
			if( StrLen( software ) > 0 )
				Gui,	loginx: +AlwaysOnTop	-MinimizeBox
			else
				Gui,	loginx:-Caption +AlwaysOnTop -MinimizeBox
			Gui, loginx:Show,																	, Login Cotrijal
		return

		AutAdmin:
			Gui,	loginx:Submit, NoHide
			if( instr( "dsantos|arsilva|ddiel|alberto", users ) = 0 ) {
				WinSet, AlwaysOnTop,	Off, Login Cotrijal
				MsgBox Você não tem permissão para administrar o sistema.
				ExitApp
			}
			if( Windows.LoginAd( users, passs ) = 0 )	{
				if( prompt = 1 )	{
					WinSet, AlwaysOnTop,	Off, Login Cotrijal
					MsgBox ,,Falha no login, Senha ou Usuário inválidos!
				}
				return	"0|"	users
			}
			if( Windows.LoginAd( users, passs ) = 1 )	{
				Gui,	loginx:Destroy
				return	"1|"	users
			}
		return

		AutOperador:
			Gui,	loginx:Submit, NoHide
			if( Windows.LoginAd( users, passs ) = 0 )	{
				if( prompt = 1 )	{
					WinSet, AlwaysOnTop,	Off, Login Cotrijal
					MsgBox ,,Falha no login, Senha ou Usuário inválidos!
				}
				Gui,	loginx:Destroy
				return	"0|"	users
			}
			if( Windows.LoginAd( users, passs ) = 1 )	{
				Gui,	loginx:Destroy
				return	"1|"	users
			}

		loginxGuiClose:
			Gui,	loginx:Destroy
			return	"0|"	users
		return
	}

}