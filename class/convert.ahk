Global inc_convert = 1

Class	Convert	{

	call( URL )	{
		OutputDebug % URL
		static req := ComObjCreate( "Msxml2.XMLHTTP" )
		req.open( "GET" , URL , false )
		req.SetRequestHeader( "Authorization" , "Basic bW9uaXRvcmFtZW50bzpNMG4xMjBpNw==" )
		
		req.send()
		OutputDebug % req.responseText
	}

	discar( origem, destino )	{
		OutputDebug % origem "`n" destino
		static req := ComObjCreate( "WinHttp.WinHttpRequest.5.1" )
		req.Option(4) := 0x3300	;	ignore certificate errors
		req.open( "GET" , "https://convert.cotrijal.com.br/portal/api/LigacaoAutomatica/executarLigacaoNumero/?origem="	origem	"&destino="	destino  , false )
		req.SetRequestHeader( "Authorization" , "Basic bW9uaXRvcmFtZW50bzpNMG4xMjBpNw==" )
		req.send()

		req:=
	}

}