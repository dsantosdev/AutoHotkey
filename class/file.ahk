if	inc_file
	Return
global	inc_file = 1

Class	File	{

	appendToLine( line, file, text, replace_line="" )	{
		FileRead, file_content,% file
		FileDelete,% file
		split_content	:=	StrSplit( file_content, "`n" )
		Loop,%	split_content.Count() {
			actual_line++	;	devido ao NÃO replace
			If( actual_line = line )	{
				if replace_line {	;	substitui a linha
					actual_line++
					FileAppend,% text "`n",% file ".txt"
					Continue
				}
				FileAppend,% text "`n",% file
				FileAppend,% split_content[actual_line] "`n",% file ".txt"

			}
			Else					;	apenas insere
				FileAppend,% split_content[actual_line] "`n",% file ".txt"
		}
		return
	}

}