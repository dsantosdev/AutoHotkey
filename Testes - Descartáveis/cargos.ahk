cargo = Coordenador Facilitador Lojas
if(  InStr(cargo, "gerente") || InStr(cargo, "coordenador") )
&&( !InStr(cargo, "trainee" ) )
	If		InStr(	cargo, "Administrativo" )
		responsavel	:=	2
	Else If InStr(	cargo, "Operacional" )
		responsavel	:=	5
	Else If InStr(	cargo, "Loja" )
		If		InStr( cargo, "Facilitador" )
			responsavel = 99
		Else If	InStr( cargo, "Comercial" )
			responsavel = 99
		Else
			responsavel	:=	3
	Else If InStr(	cargo, "Supermercado" )
		responsavel	:=	4
	Else If(		cargo = "Gerente De Unidade De Negocios" )
		responsavel	:=	1
MsgBox % responsavel

If	!A_IsCompiled
