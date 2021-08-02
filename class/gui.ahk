
Class	Gui	{

	Cores(id="",cor1="",cor2="")	{
		if(StrLen(cor1)=0)
			cor1=dbdbdb
		if(StrLen(cor2)=0)
			cor2=425942
		if(Strlen(id)>0)	{
			Gui,	%id%:Color,	,	%cor1%
			Gui,	%id%:Color,		%cor2%
			}
		else	{
			Gui,	Color,	,	%cor1%
			Gui,	Color,		%cor2%
			}
	}

	Font(params*)					{
		Loop, % params.count()	{
			if ( InStr( params[ A_Index ], ":") > 0 )
				named := params[ A_index ]
				Else
					config .= " " params[ A_index ]
				}
		Gui,% named "Font",% config
	}

}
