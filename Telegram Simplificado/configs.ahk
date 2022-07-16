#SingleInstance	Force
#Persistent
Global	comandos	:=	["Ignore","db_restore","db_status","reseta_saidas","randompass"]
	,	comandos_adm:=	["Ignore","db_restore","db_status","reseta_saidas","pic","info","talk_to","reload","reboot","randompass"]
	,	comando_recebido
	,	debug
	,	fail		:=	{}
	,	first_name
	,	from_id
	,	guid
	,	inc_config	=	1
	,	inline
	,	is_keyb
	,	message_id
	,	mtext
	,	name
	,	pass
	,	pic_message_id
	,	registering	:=	{}
	,	restam
	,	stickers	:=	{}
	,	token		:=	"https://api.telegram.org/bot1510356494:AAFkppxELD9JISyZglP0r0c-Q3STc4tKTpo"
	,	user
	,	usuarios	:=	{}
poolTime=	1000