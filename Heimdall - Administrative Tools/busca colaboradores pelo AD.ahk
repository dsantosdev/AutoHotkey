/*	Campos
	AccountType
	Description
	Disabled
	Domain
	FullName
	InstallDate
	LocalAccount
	Lockout
	Name
	PasswordChangeable
	PasswordExpires
	PasswordRequired
	SID
	SIDType
	Status
*/
; for o in ComObjGet("winmgmts:").ExecQuery("Select * From Win32_UserAccount")
	; saida .= o.Name "`t" o.FullName "`n"
	; Clipboard := saida
	; ExitApp
F1::
	InputBox, userad, Buscar Informações de Conta no AD, Insira o USUÁRIO do AD que deseja consultar:
	Goto executa
F2::
	InputBox, userad, Buscar Informações de Conta no AD, Insira o NOME COMPLETO do usuário que deseja consultar:
	Goto executa
F3::
	Goto teste

executa:
	; for o in ComObjGet("winmgmts:").ExecQuery("Select * From Win32_UserAccount where FullName = '" userad "'" )
	for o in ComObjGet("winmgmts:").ExecQuery("Select * From Win32_UserAccount where Name = '" userad "'" )
	{
		MsgBox %	"`n"
				; .	"Descrição :`t"				o.Description
				.	"`nNome Completo :`t"		o.FullName
				.	"`nUsuário :`t`t"			o.Name
				.	"`nDesabilitada :`t"		o.Disabled
				.	"`nDominio :`t"				o.domain
				.	"`nConta Local :`t"			o.localaccount
				.	"`nBloqueada :`t"			o.Lockout	;	-1 = Bloqueada
				; .	"`nsId :`t`t"				o.sid
				.	"`nEstado :`t`t"			o.status
	}
ExitApp

teste:
	for o in ComObjGet("winmgmts:").ExecQuery("Select * From Win32_UserAccount WHERE FullName = 'Djeison Andrei Diel' " )
		MsgBox % o.Name "`n" o.FullName "`n" o.status
Return