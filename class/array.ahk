if	inc_array
	Return

Global inc_array = 1

Class Array	{
	InArray( Array, SearchText, Partial="0" )											{
		; OutputDebug % searchtext
		if ( debug > 2 )
			OutputDebug % "_____InArray`n`tSearchText: " SearchText "`n`tArray: " array.Count() "`n`tPartial: " partial "`n"
		if ( StrLen( SearchText ) = 0 )	{
			OutputDebug % "SearchText em branco"
			return 0
		}
		if !IsObject( Array )	{
			if ( debug > 2 )
				OutputDebug % "Não é um array!"
			throw Exception("Não é um array!", -1, Array)
			return 0
		}
		if ( Partial = 0 )	{
			if ( debug > 2 )
				OutputDebug % "partial Zero"
			for index, ArrayText in Array
				{
				if ( debug > 2 )
					OutputDebug % ArrayText " = " SearchText
				if ( ArrayText = SearchText )
					Return index
				}
		}
		else	{
			list := []
			for index, ArrayText in Array
				{
				if ( debug > 2 )
					OutputDebug % ArrayText " = " SearchText "`n" InStr( ArrayText, SearchText )
				if ( InStr( ArrayText, SearchText ) > 0 )	{
					if ( debug > 2 )
						OutputDebug % "Deu match no index " index
					list.Push(index)
					}
				}
			Return list.Count() = "" || list.Count() = "0" ? "0" :	list
			}
		Return 0
	}

	InDict( Array, SearchText, key_is="", partial="0", fill="" )						{
		; OutputDebug % SearchText
		if ( fill = 1 )	{
			list:=[]
			For index in Array
				list.Push(index)
		}
		if ( StrLen(SearchText) = 0 and StrLen(fill) = 0 )
			return 0
		if !( IsObject(Array) )	{
			throw Exception("Não é um dicionário!", -1, Array)
			return 0
			}
		if ( strLen(key_is) = 0 )	{
			For index in Array
				For key, ArrayText in Array[index]
					if ( ArrayText = SearchText )
						return	index
			}
		if ( StrLen(key_is) != 0 and partial = 0 )	{
			For index in Array
				For key, ArrayText in Array[index]
				{
					; MsgBox % key "`t" key_is
					if ( key = key_is )	{
						; MsgBox % ArrayText "`n" SearchText
						if ( ArrayText = SearchText )
							return	index
					}
				}
			}
		if ( StrLen(key_is) != 0 and partial = 1 )	{
			list:=[]
			For index in Array
				For key, ArrayText in Array[index]
					if ( key = key_is )	{
						; OutputDebug % "INARRAY:`n`t" ArrayText "`t" SearchText
						if ( InStr( ArrayText, SearchText ) > 0 )
							list.Push( index )
						}
			; OutputDebug % "Lista: " list.Count()
			}
		return list.Count() = "" ? 0 : list
	}

	InDict2( Array, SearchText, key_is="", partial="0", fill="" )						{
		; OutputDebug % SearchText

		if !( IsObject(Array) )	{
			throw Exception("Não é um dicionário!", -1, Array)
			return 0
		}

		if ( fill = 1 )	{
			list:=[]
			For index in Array
				list.Push(index)
		}

		if (StrLen( SearchText ) = 0
		&&	StrLen( fill ) = 0 )
			return 0

		;
			For index in Array
				For key, ArrayText in Array[index]
					msgbox % index "&&" key "&&"  ArrayText "`n"
					; for_regex .= index "&&" key "&&"  ArrayText "`n"
		;

		if ( strLen( key_is)  = 0 )	{
			For index in Array
				For key, ArrayText in Array[index]
					if ( ArrayText = SearchText )
						return	index
			}
		if ( StrLen(key_is) != 0 and partial = 0 )	{
			For index in Array
				For key, ArrayText in Array[index]
				{
					; MsgBox % key "`t" key_is
					if ( key = key_is )	{
						; MsgBox % ArrayText "`n" SearchText
						if ( ArrayText = SearchText )
							return	index
					}
				}
			}
		if ( StrLen(key_is) != 0 and partial = 1 )	{
			list:=[]
			For index in Array
				For key, ArrayText in Array[index]
					if ( key = key_is )	{
						; OutputDebug % "INARRAY:`n`t" ArrayText "`t" SearchText
						if ( InStr( ArrayText, SearchText ) > 0 )
							list.Push( index )
						}
			; OutputDebug % "Lista: " list.Count()
			}
		return list.Count() = "" ? 0 : list
	}

	QueryInDict( Array, params* )														{
		if ( debug > 2 )
			OutputDebug % params.Count()
		Loop, %  params.Count()
			Switch Mod(A_index, 2 ) = 0 ? 1 : 0	{
				Case 1:
					if ( debug > 2 )
						OutputDebug % "Header: " params[A_index]
				Case 0:
					if ( debug > 2 )
						OutputDebug % "Body: " params[A_index]
				}
	}

	Reverse( Array )																	{
		;	original from jeeswg
		Array2 := Array.Clone()
		Temp := {}
		for Key in Array
			Temp.Push( Key )
		Index := Temp.Count()
		for Key in Array
			Array[ Key ] := Array2[ Temp[ Index-- ] ]
		Array2 := Temp := ""
	}

	Sort( Array, Order = "ASC", Is_Map = "0" , Delimiter = "`n" , Sort_Position = "1" )	{	;	Para MAP's precisa ser atualizado
		index	:=	[]
		If ( Is_Map = 1 )	{	;	Retorna um array SIMPLES com a ordem do dictionary
			for Key in Array
				For Key2, Value in Array[Key]
					list .=  StrReplace( value , "`n" , "§" ) "|" key Delimiter
			list	:=	SubStr( list, 1, -1 )

			if ( Order = "desc" )
				Sort, list, R N D%Delimiter%
			else
				Sort, list, N D%Delimiter%

			Split_list := StrSplit( list, Delimiter )
			Loop,	% Split_list.Count()	{
				
				; OutputDebug % Split_list[ A_index ]
				Split_index := StrSplit( Split_list[ A_index ], "|" )
				index.Push( Split_index[2] )
			}
			Return	index
		}
		Else	{				;	Retorna o array simples completo reordenado(necessita um objeto para receber as informações)
			For key, value in Array
				list .= StrReplace( value , "`n" , "§" ) Delimiter

			list := SubStr( list, 1, -1 )
			; MsgBox % clipboard := list
			pre_list := list	;	for debug

			if ( Order = "DESC" )
				Sort, list, R N D%Delimiter% P%Sort_Position%
			Else
				Sort, list, N D%Delimiter% P%Sort_Position%

			; MsgBox % clipboard := list "`n`n" pre_list

			Split_list := StrSplit( list, Delimiter )
			Loop,% Split_list.Count()	{
				; OutputDebug % Split_list[ A_index ]
				index.Push(  StrReplace( Split_list[ A_index ] , "§" , "`n" ) )
			}

			Return	index
			}
	}

	sort_matrix( matrix, order="ASC", column="1" )	{	;	Para MAP's precisa ser atualizado
		linhas_matriz	:= matrix.Count()
		colunas_matriz	:= matrix[1][1].Count()

		If( column > colunas_matriz )
			Return "Coluna solicitada não existe nessa Matriz.`nA matriz possui apenas " matrix[1][1].Count() " colunas."

		layout_return := []

		Loop,% linhas_matriz
			for_order .=	matrix[A_Index][1][column] "`t" A_Index "`n"
	
		for_order	:=	 SubStr( for_order,1,-1)
		Sort, for_order,% order

		for_return := StrSplit(for_order, "`n" )
		Loop,%	for_return.Count() {	;	prepara nova matriz
			index	:=	A_Index
			i		:= StrSplit(for_return[A_Index], "`t" )
			c%index% := []
			Loop,% colunas_matriz
				c%index%.Insert( matrix[i[2]][1][A_index] )

			layout_return.Insert( c%A_Index% )
		}
		
		Return layout_return
	}
}