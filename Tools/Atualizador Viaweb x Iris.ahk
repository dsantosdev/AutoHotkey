;@Ahk2Exe-SetMainIcon	C:\Dih\zIco\fun\cor.ico
	#Persistent
	#SingleInstance Force
	#Include ..\class\array.ahk
	#Include ..\class\cor.ahk
	#Include ..\class\functions.ahk
	#Include ..\class\gui.ahk
	#Include ..\class\mail.ahk
	#Include ..\class\safedata.ahk
	#Include ..\class\string.ahk
	#Include ..\class\sql.ahk
	#Include ..\class\windows.ahk

;	Dictionaries and arrays
	remover	:=	{}
	vw		:=	{}
	update	:=	{}
	tem_pai	:=	[]
;

;	Vars
	inicia	=	1
;

;	Pre load
	gosub	sql
;

;	interface
	Gui.Cores()
	Gui,	Add,	DropDownList,			y10			w630			Section	gsql			vu	,% unidades
	Gui,	Add,	ListView,		xs					w630	h410	Grid						, Unidade|ID Iris|ID Usuario|Nome|Matricula|Cargo|Senha
	Gui,	Add,	Button,			xs					w310	h30				gatualizaIris	v_a	, Atualizar usuarios do Iris
	Gui,	Add,	Button,			x332	yp	w310	h30						gGuiCLose		v_e	, Encerrar
	Gui,	Show
return

sql:
	if ( inicia = 1 )
		todos =
	else	{
		Gui,	Submit,	NoHide
		todos := "and d.[Cliente] = '" u "'"
		LV_Delete()
	}
	s =												;	Busca os nomes dos clientes que estão configurados  com a matrícula na senha.
		(
		SELECT
			DISTINCT 	'1' + e.[valor]																				AS Cliente_Iris
			,			d.[IdUnico]																					AS ID_Central
			,			u.[ID_USUARIO]																				AS Index_Central
			,			u.[NOME]																					AS Matricula
			,			(SELECT NOME FROM [ASM].[ASM].[dbo].[_colaboradores] WHERE [matricula] = u.[nome])			AS Nome
			,			(SELECT cargo FROM [ASM].[ASM].[dbo].[_colaboradores] WHERE [matricula] = u.[nome])			AS Cargo
			,			SUBSTRING(u.[CODIGO],1,4)																	AS Senha
			,			d.[Nome]																					AS Unidade
			,			d.[Setor]																					AS Operador
			,			(SELECT [telefone1] FROM [ASM].[ASM].[dbo].[_colaboradores] WHERE [matricula] = u.[nome])	AS Fone
			,			(SELECT [telefone2] FROM [ASM].[ASM].[dbo].[_colaboradores] WHERE [matricula] = u.[nome])	AS FCelular
			,			e.ID_EQTO																					AS id_vw
		FROM
			[ASM].[vw_programação].[dbo].[INSTALACAO] i
		LEFT JOIN
			[ASM].[vw_programação].[dbo].[USUARIOS] u
				ON	i.[ID_INSTALACAO]=u.[ID_INSTALACAO]
		LEFT JOIN
			[ASM].[vw_programação].[dbo].[PROG_EQTO] e
				ON	i.[ID_INSTALACAO]=e.[ID_EQTO]
		LEFT JOIN
			[IrisSQL].[dbo].[Clientes] d
				ON	'1' + e.[valor]=d.[Cliente]
		WHERE
			ISNUMERIC(u.[NOME]) = 1 and
			e.[id_funcao] BETWEEN '66' AND '73' AND
			e.[valor] NOT IN ('0000','9999') and
			d.partilha = 0
			%todos%
		ORDER BY 1, 4
		)
	
	q := sql( s )
		OutputDebug % q.Count()-1
	unidades	=
	ids			:=	[]
	Loop, % q.Count()-1	{							;	Monta um array associativo com os dados dos usuários para inserir no banco do iris
		if ( inicia = 0 )	{
			; OutputDebug % q[A_Index+1, 8]
			LV_Add(""								;	Adiciona os dados na listview
				,		q[A_Index+1, 8]
				,		q[A_Index+1, 2]
				,		q[A_Index+1, 3]
				,		String.Name( q[A_Index+1, 5] )
				,		q[A_Index+1, 4]
				,		String.Cargo(q[A_Index+1, 6])
				,		q[A_Index+1, 7]					)
		}
		if ( Array.InDict( ids, q[A_Index+1, 2] ) = 0 )		{	;	faz a dropdownlist
			if ( inicia = 1 )
				ids.Push( q[A_Index+1, 2] )
			If ( InStr( unidades, lv_nomes := StrReplace( q[A_Index+1, 1], "|", "-" ) ) = 0 )
				unidades .= lv_nomes "|"
		}
		if ( inicia = 1 )	{
			; Clipboard .= q[A_Index+1, 1] "`t" q[A_Index+1, 2] "`t" q[A_Index+1, 3] "`t" q[A_Index+1, 4] "`t" q[A_Index+1, 5] "`t" q[A_Index+1, 6] "`t" q[A_Index+1, 8] "`t" "Operador " SubStr( q[A_Index+1, 9], -1 ) "`t" q[A_Index+1, 10] "`t" q[A_Index+1, 11] "`t" q[A_Index+1, 12] "`t" q[A_Index+1, 13] "`n"
			vw.push({	cliente		:	q[A_Index+1, 1]
					,	id			:	q[A_Index+1, 2]
					,	user		:	q[A_Index+1, 3]
					,	matricula	:	q[A_Index+1, 4]
					,	nome		:	q[A_Index+1, 5]
					,	cargo		:	q[A_Index+1, 6]
					,	unidade		:	q[A_Index+1, 8]
					,	operador	:	"Operador " SubStr( q[A_Index+1, 9], -1 )
					,	fone		:	q[A_Index+1, 10]
					,	cel			:	q[A_Index+1, 11]
					,	id_vw		:	q[A_Index+1, 12]	})
		}
	}
	LV_ModifyCol()
		LV_ModifyCol( 2, "Center 50" )
		LV_ModifyCol( 3, "Center 65" )
		LV_ModifyCol( 5, "Center 65" )
		LV_ModifyCol( 7, "Center 50" )
		LV_ModifyCol( 8, 0 )
	inicia = 0
return

filhos:
	s =
		(
		SELECT
			DISTINCT 	'1' + e.[valor]		AS Cliente_Iris
			,			d.contamaster		as pai
		FROM
			[ASM].[vw_programação].[dbo].[INSTALACAO] i
		LEFT JOIN
			[ASM].[vw_programação].[dbo].[USUARIOS] u
				ON	i.[ID_INSTALACAO]=u.[ID_INSTALACAO]
		LEFT JOIN
			[ASM].[vw_programação].[dbo].[PROG_EQTO] e
				ON	i.[ID_INSTALACAO]=e.[ID_EQTO]
		LEFT JOIN
			[IrisSQL].[dbo].[Clientes] d
				ON	'1' + e.[valor]=d.[Cliente]
		WHERE
			ISNUMERIC(u.[NOME]) = 1 and
			e.[id_funcao] BETWEEN '66' AND '73' AND
			e.[valor] NOT IN ('0000','9999') and
			d.partilha = 1
			%todos%
		ORDER BY 1
		)
	
	Loop,%	filhos := sql( s ).Count()-1	{
			OutputDebug % "TEXT"
		}
		
Return

atualizaIris:
	GuiControl,			,	_e,	ATUALIZANDO
	GuiControl, 		,	_a,	ATUALIZANDO
	GuiControl, Disable	,	_e
	GuiControl, Disable	,	_a
	for i in vw
	{
		cliente	:= vw[i].cliente
		user_id := StrLen(	vw[i].user ) = 1
						?	"00" vw[i].user
						:	StrLen( vw[i].user ) = 2
							?	"0" vw[i].user
							:	vw[i].user
		nome	:= String.Name( vw[i].nome )
		cargo	:= String.Cargo( vw[i].cargo )
		idc		:= vw[i].id
		tel1	:= vw[i].fone
		tel2	:= vw[i].cel

		operador:= vw[i].operador
		id_vw	:= vw[i].id_vw
		
		; MsgBox % "idc= " idc "`ncliente= " cliente "`nnome= " nome "`noperador= " operador "`nid_vw= " id_vw "`npai= " pai

		if ( StrLen( nome ) = 0 )	{	;	cria dictionary com os colaboradores demitidos para enviar email posteriormente
			remover.Push({	user_id		:	user_id
						,	local		:	vw[i].unidade
						,	matricula	:	vw[i].matricula	})
			Continue
		}

		if ( StrLen( tel1 ) = 0 )	{	;	ajusta os telefones
			tel1 := tel2
			tel2 =
			}

		if (	idc != old_idc			;	Quando muda de cliente
			||	vw.Count() = i )	{
			if (	vw.Count() = i
				||	old_idc ="" )	{
				old_idc		:= idc
				old_client	:= cliente
				}
			contatos_padrão =
				(
				IF NOT EXISTS(SELECT * FROM [IrisSQL].[dbo].[Usuarios] where codigo_usuario='%user_id%' and idcliente='%idc%') 
					BEGIN
						INSERT INTO
							[IrisSQL].[dbo].[Usuarios]
								(	[Cliente]
								,	[Particao]
								,	[Codigo_Usuario]
								,	[Nome_Usuario]
								,	[Cargo]
								,	[PrioridadeLigar]
								,	[IdCliente]
								,	[Fone]
								,	[FCelular]	)
							VALUES
								(	'%old_client%',	'000',	'001',	'%operador%'				,	'MONITORAMENTO',	'1',	'%old_idc%',	'',	''	),
								(	'%old_client%',	'000',	'002',	'FACILITADOR'				,	'MONITORAMENTO',	'1',	'%old_idc%',	'',	''	),
								(	'%old_client%',	'000',	'006',	'MANUTENÇÃO'				,	'MONITORAMENTO'	,	'1',	'%old_idc%',	'',	''	),
								(	'%old_client%',	'000',	'000',	'Programação Automática'	,	'MONITORAMENTO'	,	'1',	'%old_idc%',	'',	''	)
					END
				)
				sql( contatos_padrão )
		}

		update =
			(
				IF EXISTS(SELECT * FROM [IrisSQL].[dbo].[Usuarios] where codigo_usuario='%user_id%' and idcliente='%idc%') 
					Begin
						UPDATE [IrisSQL].[dbo].[Usuarios]
						SET
							[Nome_Usuario]		=	'%nome%'
							,[Cargo]			=	'%cargo%'
							,[IdCliente]		=	'%idc%'
							,[Fone]				=	'%tel1%'
							,[FCelular]			=	'%tel2%'
						WHERE
							[Cliente]			=	'%cliente%' AND
							[Codigo_Usuario]	=	'%user_id%'
					END
				ELSE
					INSERT INTO [IrisSQL].[dbo].[Usuarios]
						(	[Cliente]	,[Particao]	,[Codigo_Usuario]	,[Nome_Usuario]	,[Cargo]	,[PrioridadeLigar]	,[IdCliente]	,[Fone]		,[FCelular]	)
					VALUES
						(	'%cliente%'	,'000'		,'%user_id%'		,'%nome%'		,'%cargo%'	,'1'				,'%idc%'		,'%tel1%'	,'%tel2%'	)
			)
		sql( update )

		old_idc		:= idc
		old_client	:= cliente
		GuiControl, , _a,	Usuários Restantes:
		GuiControl, , _e,%	vw.Count()-i
	}	;	FIM DO FOR
	GuiControl, , _a,	Atualizar usuarios do Iris
	GuiControl, enable, _e
	GuiControl, , _e,	Encerrar
	GuiControl, enable, _a
	if ( remover.Count() > 0 )	{
		Loop % remover.count()	;	Dict com os usuarios demitidos
			usuarios_remover.= remover[A_Index].user_id "`t" remover[A_Index].local "`t" remover[A_Index].matricula "`n"
		mail.new("monitoramento@cotrijal.com.br","Ex Colaboradores com senha", "Os colaboradores abaixo possuem senha e não foram encontrados no cadastro de colaboradores da cotrija:`n" usuarios_remover )
	}
return

GuiClose:
	ExitApp
;