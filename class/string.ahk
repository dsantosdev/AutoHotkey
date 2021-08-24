
Class	String		{

	Name( name )				{
		if !name
			Return
		StringUpper, name, name, T
		name_split := StrSplit( name, A_Space )
		Loop, % name_split.Count()
			if	( A_index = 1 )
				new_name := name_split[A_Index]
			else if(	name_split[A_index] = "do"
					||	name_split[A_index] = "da"
					||	name_split[A_index] = "dos"
					||	name_split[A_index] = "das"
					||	name_split[A_index] = "de" )
				new_name .= " " Format( "{:L}", name_split[A_index] )
			else if ( A_Index = name_split.Count() )
				new_name .= " " name_split[A_Index]
			else
				new_name .= " " SubStr( name_split[A_Index] , 1, 1 ) ". "
		return StrReplace( new_name, "  ", " " )
	}

	Cargo( cargo )				{
		StringUpper,	cargo,	cargo,	T
		cargo	:=	StrReplace(	StrReplace(	StrReplace(	cargo
										,	" - Feira"	)
								," de ", " "	)
					," em ", " "	)
		If ( InStr( cargo,	"Representante" ) > 0 )	{
			fim		:=	StrSplit(	cargo,	" "	)
			Retorno	:=	"Rep. Tec. Com. " fim[4] " " fim[5]
		}
		;{	Trata nomes de cargos
			Else If ( InStr( cargo,	"TECNICO QUALIDARACOES" )
							> 0 )
				Retorno = Tec. Qualidade Rações
			Else If ( InStr( cargo,	"TECNICO SEGURANCA" )
							> 0 )
				Retorno = Tec. Seg. do Trabalho
			Else If ( InStr( cargo,	"TECNICO ENFERMAGEM" )
							> 0 )
				Retorno = Tec. Enfermagem
			Else If ( InStr( cargo,	"TECNICO PROJETOS" )
							> 0 )
				Retorno = Tec. Projetos
			Else If ( InStr( cargo,	"TECNICO PROGRAMACAO" )
							> 0 )
				Retorno = Tec. Programação UBS
			Else If ( InStr( cargo,	"TECNICO LABORATORIO" )
							> 0 )
				Retorno = Tec. Laboratório
			Else If ( InStr( cargo,	"Tecnico Controle" )
							> 0 )
				Retorno = Tec. Cont. Qualidade
			Else If ( InStr( cargo,	"Tecnico Agricola" )
							> 0 )
				Retorno = Tec. Agrícola
			Else If ( InStr( cargo,	"Tecnico Manutencao" )
							> 0 )
				Retorno = Tec. Manutenção
			Else If ( InStr( cargo,	"Responsavel" )
							> 0 )
				Retorno = Resp. Tec. Sementes
			Else If ( InStr( cargo,	"Projetista" )
							> 0 )
				Retorno = Projetista
			Else If ( InStr( cargo,	"Padeiro" )
							> 0 )
				Retorno = Padeiro
			Else If ( InStr( cargo,	"Motorista" )
							> 0 )
				Retorno = Motorista
			Else If ( InStr( cargo,	"Conferente" )
							> 0 )
				Retorno = Conferente
			Else If ( InStr( cargo,	"Comprador" )
							> 0 )
				Retorno = Comprador
			Else If ( InStr( cargo,	"Auditor" )
							> 0 )
				Retorno = Auditor
			Else If ( InStr( cargo,	"Assist" )
							> 0 )
				Retorno = Assist. Produção
			Else If ( InStr( cargo,	"ALMOXARIFE" )
							> 0 )
				Retorno = Almoxarife
			Else If (	InStr(	cargo,	"Analista"	)		>	0
					||	InStr(	cargo,	"auxiliar"	)		>	0
					||	InStr(	cargo,	"engenheiro"	)	>	0
					||	InStr(	cargo,	"Medico"	)		>	0
					||	InStr(	cargo,	"Operador"	)		>	0
					||	InStr(	cargo,	"Promotor"	)		>	0
					||	InStr(	cargo,	"Superint"	)		>	0	)	{
				Retorno	:=	StrSplit(cargo," ")
				Retorno	:=	Retorno[1] " " Retorno[2]
				if ( Retorno[2] = "Frente" )
					Retorno = Frente de Caixa
			}

		if ( Strlen( Retorno ) = 0 )
			Retorno := cargo
		Retorno	:=	StrReplace(	StrReplace(	StrReplace(	StrReplace(	StrReplace(	StrReplace(	StrReplace(	StrReplace(	StrReplace(	Retorno
																															,	"COORDENADOR ", "C. " )
																									,	" UNIDADES" )
																						,	" UNIDADE" )
																			,	"DE " )
																,	" UNIDANEGOCIOS" )
													,	" NEGOCIOS" )
										,	"CENTRO DISTRIBUICAO", "CD" )
							,	"DA " )
				,	" Obras E Manutencoes" )
		if ( InStr( Retorno, "auxiliar" )
				>	0	)
			Retorno	:=	StrReplace( Retorno, "Auxiliar", "Aux." )
			Else if ( InStr( Retorno, "Operador") > 0 )
				Retorno := StrReplace( Retorno, "Operador", "Op." )
			Else if ( InStr( Retorno, "Engenheiro" ) > 0 )
				Retorno := StrReplace( Retorno, "Engenheiro", "Eng." )
		return	%	Retorno
	}

	Case( word, type )				{
		StringUpper, word, word ,% type
		Return word
	}

	Destaca_Busca( phrase, word )	{
		if ( InStr( word, " " ) > 0 )
			wordx := StrSplit( word, " " )
		Else
			wordx := [word]
		Loop,%	wordx.Count()	{
			phrase := StrReplace( phrase, wordx[A_index], "[" Format("{:U}", wordx[A_index] ) "]" )
			if ( InStr( phrase,  "@"  wordx[A_index] ) )
				phrase := StrReplace( phrase, wordx[A_index], "[" Format("{:U}", wordx[A_index] ) "]" )
		}
		Return phrase
	}
		
}