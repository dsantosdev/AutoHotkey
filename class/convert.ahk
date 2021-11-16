Class	Convert	{

	call( URL )	{
		OutputDebug % URL
		static req := ComObjCreate( "Msxml2.XMLHTTP" )
		req.open( "GET" , URL , false )
		req.SetRequestHeader( "Authorization" , "Basic bW9uaXRvcmFtZW50bzpNMG4xMjBpNw==" )
		req.send()
		OutputDebug % req.responseText
	}

}