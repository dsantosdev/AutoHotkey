Class Array	{

	InArray(Array, SearchText, Partial="0")	{
		if ( debug > 2 )
			OutputDebug % "_____InArray`n`tSearchText: " SearchText "`n`tArray: " array.Count() "`n`tPartial: " partial "`n"
		if ( StrLen( SearchText ) = 0 )	{
			OutputDebug % "SearchText em branco"
			return 0
			}
		if !( IsObject( Array ) )	{
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
	}

	InDict(Array,SearchText,key_is="",partial="0",fill="")	{
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
					if ( key = key_is )
						if ( ArrayText = SearchText )
							return	index
			}
		if ( StrLen(key_is) != 0 and partial = 1 )	{
			list:=[]
			For index in Array
				For key, ArrayText in Array[index]
					if ( key = key_is )	{
						; OutputDebug % "INARRAY:`n`t" ArrayText "`t" SearchText
						if ( InStr(ArrayText,SearchText) > 0 )
							list.Push(index)
						}
			; OutputDebug % "Lista: " list.Count()
			}
		return list.Count()=""?0:list
	}

	QueryInDict(Array, params*) {
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

}