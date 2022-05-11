#SingleInstance	Force
#Persistent
Global	comandos	:=	["ignore","Restore","dbstatus"]
	,	comandos_adm:=	["ignore","Restore","dbstatus","getpicture","getinfo","talk","reload"]
	,	debug
	,	fail		:=	{}
	,	from_id
	,	inc_config	=	1
	,	message_id
	,	pass
	,	registering	:=	{}
	,	restam
	,	stickers	:=	{}
	,	token
	,	user
	,	usuarios	:=	{}
token	:=	"https://api.telegram.org/bot1510356494:AAFkppxELD9JISyZglP0r0c-Q3STc4tKTpo"
poolTime=	1000