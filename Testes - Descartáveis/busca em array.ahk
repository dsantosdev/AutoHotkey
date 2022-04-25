


bas( Array, SearchText, bas = "" ) {
	if(StrLen(SearchText)=0)	{
		;~ MsgBox,,Função BAS, Valor para verificação está em branco`, impossível buscá-lo no Array.
		return 0
	}
	for i, v in Array
		if(StrLen(bas)=0)	{
			if(Array[i].nome=SearchText or Array[i].ip=SearchText)	{
				;~ MsgBox % Array[i].nome "`n" SearchText "`n" i
				return i
			}
		}
		else	if(Array[i].nome=SearchText or Array[i].ip=SearchText or Array[i].bas=SearchText)	{
				;~ MsgBox % Array[i].bas "`n" SearchText
				return i
		}
	if !(IsObject(Array))
		throw Exception("Não é um array associativo!", -1, array)
	return 0
}