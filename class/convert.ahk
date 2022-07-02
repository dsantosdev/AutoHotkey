if	inc_convert
	Return
#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
Global inc_convert = 1

Class	Convert	{

	call( URL )	{	;DEEFASADO
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
		req.SetRequestHeader( "Authorization" , "Basic bW9uaXRvcmFtZW50bzpNMG4xMjBpNw==" )	;	antigo(usado para ligação)
		req.send()
	}

	sms( texto, destino ) {
		OutputDebug % texto "`n" destino
		static req := ComObjCreate( "WinHttp.WinHttpRequest.5.1" )
		req.Option(4) := 0x3300	;	ignore certificate errors
		; req.open( "POST" , "https://cotrijal.letteldata.com.br/portal/api/SMS/envioPortal/?"
		req.open( "GET" , "http://convert.cotrijal.com.br/portal/api/SMS/envioPortal/?"
				.	"msg="		texto	"&"
				.	"numeros[]=" destino , false )
				; .	"numeros=" destino  , false )

		req.SetRequestHeader( "Authorization" , "Basic ZHNhbnRvczpDMHRyaWpAbDIwMjE=" )	;	novo
		req.send()
		Msgbox	%	Unicode( req.responseText, 0 )
	}
}