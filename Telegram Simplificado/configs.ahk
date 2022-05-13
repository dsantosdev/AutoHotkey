#SingleInstance	Force
#Persistent
Global	comandos	:=	["ignore","Restore","dbstatus"]
	,	comandos_adm:=	["ignore","Restore","dbstatus","getpicture","getinfo","talkto","reload"]
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