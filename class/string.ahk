
Class	String		{

	Name( name )	{
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
		Loop, 5
		return StrReplace( new_name, "  ", " " )
	}

}