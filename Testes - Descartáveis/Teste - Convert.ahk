click_to_call("https://192.9.200.245/portal/api/LigacaoAutomatica/executarLigacaoNumero/?origem=2524&destino=2530")
click_to_call("http://cotrijal.letteldata.com.br/portal/api/LigacaoAutomatica/executarLigacaoNumero/?origem=2524&destino=2530")

Return

click_to_call( url )									{
	static req := ComObjCreate("Msxml2.XMLHTTP")
	req.open("GET", url, true)
	req.SetRequestHeader("Authorization", "Basic bW9uaXRvcmFtZW50bzpNMG4xMjBpNw==")
	req.send()
	outputdebug req.responseText()
}