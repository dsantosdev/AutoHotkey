#SingleInstance	Force
#Persistent
Global	comandos	:=	["ignore","Restore","dbstatus","resetabanheiro"]
	,	comandos_adm:=	["ignore","Restore","dbstatus","getpicture","getinfo","talkto","reload","reboot"]
	,	debug
	,	fail		:=	{}
	,	from_id
	,	inc_config	=	1
	,	message_id
	,	pass
	,	registering	:=	{}
	,	restam
	,	stickers	:=	{}
	,	token	:=	"https://api.telegram.org/bot1510356494:AAFkppxELD9JISyZglP0r0c-Q3STc4tKTpo"
	,	user
	,	usuarios	:=	{}
poolTime=	1000