Interface:
	Gui,	Add,	ListView,	x22		y89	w1010	h610	, Nome|ID|parte 3|parte 4|parte 5
	Gui,	Add,	Button,		x872	y49	w160	h30		, Button
	Gui,	Add,	Edit,		x22		y9	w330	h30		, Nome e setor da unidade
	Gui,	Add,	Edit,		x22		y49	w150	h30		, id da unidade(3 dígitos)
	Gui,	Add,	Edit,		x182	y49	w680	h30		, endereço da unidade
	Gui,	Add,	Edit,		x362	y9	w200	h30		, nome do arquivo de imagem do mapa
	Gui,	Add,	CheckBox,	x572	y9	w180	h30		, Defensivos?
	Gui,	Show,							w1050	h750	, Gerenciador de Unidades
return

GuiClose:
	ExitApp