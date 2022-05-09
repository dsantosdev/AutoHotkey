/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\Documentos_importantes\Facilitador\Ferramentas\Atualizador Viaweb x Iris.exe
Created_Date=1
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Description=Atualizador de usuários do Painel de Monitoramento do Iris
File_Version=1.0.0.5
Inc_File_Version=1
Original_Filename=Atualizador Viaweb x Iris.ahk
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\Dih\zIco\fun\cap.ico

* * * Compile_AHK SETTINGS END * * *
*/

;@Ahk2Exe-SetMainIcon	C:\Dih\zIco\fun\cor.ico
	#Persistent
	#SingleInstance Force
	#Include ..\class\array.ahk
	#Include ..\class\cor.ahk
	#Include ..\class\functions.ahk
	#Include ..\class\gui.ahk
	#Include ..\class\mail.ahk
	#Include ..\class\safe_data.ahk
	#Include ..\class\string.ahk
	#Include ..\class\sql.ahk
	#Include ..\class\windows.ahk

if ( A_UserName = "monitoramento" )	{
	MsgBox,,, O usuário MONITORAMENTO não tem permissão para executar esse sistema.
	ExitApp
}
	

;	Dictionaries and arrays
	remover	:=	{}
	vw		:=	{}
	update	:=	{}
	tem_pai	:=	[]
;

;	limpa usuários em branco
	d	=
		(
		DELETE
		FROM	[vw_programação].[dbo].[USUARIOS]
		WHERE
			(	LEN( [NOME] )	= 0
			OR	[NOME]			IS NULL ) 
				AND
			(	LEN( [CODIGO] )	= 0
			OR	[CODIGO]		IS NULL )
				AND
			( [CODIGO_REMOTO]	LIKE 'FFFF`%' )
		)
	sql( d , 3 )
;

;	Vars
	inicia	=	1
;

;	Pre load
	gosub	sql
	gosub	atualizaIris
;

;	interface
	; Gui.Cores()
	; Gui,	Add,	DropDownList,			y10			w630			Section	gsql			vu	,% unidades
	; Gui,	Add,	ListView,		xs					w630	h410	Grid						, Unidade|ID Iris|ID Usuario|Nome|Matricula|Cargo|Senha
	; Gui,	Add,	Button,			xs					w310	h30				gatualizaIris	v_a	, Atualizar usuarios do Iris
	; Gui,	Add,	Button,			x332	yp	w310	h30						gGuiCLose		v_e	, Encerrar
	; Gui,	Show
return

sql:
	if ( inicia = 1 )
		todos =
	else	{
		Gui,	Submit,	NoHide
		todos := "and d.[Cliente] = '" u "'"
		LV_Delete()
	}
	s =												;	Busca os nomes dos clientes que estão configurados com a matrícula na senha.
		(
		SELECT
			DISTINCT 	'1' + e.[valor]																				AS Cliente_Iris
			,			d.[IdUnico]																					AS ID_Central
			,			u.[ID_USUARIO]																				AS Index_Senha
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
		ORDER BY 1, 3
		)

	q := sql( s )
	unidades	=
	ids			:=	[]
	Loop, % q.Count()-1	{							;	Monta um array associativo com os dados dos usuários para inserir no banco do iris
		; if ( inicia = 0 )	{	;	APENAS EM MODO GUI
			; OutputDebug % q[A_Index+1, 8]
			; LV_Add(""								;	Adiciona os dados na listview(desnecessário no servidor)
				; ,		q[A_Index+1, 8]
				; ,		q[A_Index+1, 2]
				; ,		q[A_Index+1, 3]
				; ,		String.Name( q[A_Index+1, 5] )
				; ,		q[A_Index+1, 4]
				; ,		String.Cargo(q[A_Index+1, 6])
				; ,		q[A_Index+1, 7]					)
		; }
		; if ( Array.InDict( ids, q[A_Index+1, 2] ) = 0 )		{	;	faz a dropdownlist
			; if ( inicia = 1 )
				; ids.Push( q[A_Index+1, 2] )
			; If ( InStr( unidades, lv_nomes := StrReplace( q[A_Index+1, 1], "|", "-" ) ) = 0 )
				; unidades .= lv_nomes "|"
		; }
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
	;	Apenas modo GUI
		; LV_ModifyCol()
			; LV_ModifyCol( 2, "Center 50" )
			; LV_ModifyCol( 3, "Center 65" )
			; LV_ModifyCol( 5, "Center 65" )
			; LV_ModifyCol( 7, "Center 50" )
			; LV_ModifyCol( 8, 0 )
	inicia = 0
return

atualizaIris:
	; GuiControl, Disable	,	_e
	; GuiControl, Disable	,	_a
	limpa =	;	Limpa os usuários(pessoas com senha) do Iris para reincerir a frente
		(
		DELETE
		FROM	[IrisSQL].[dbo].[Usuarios]
		)
		sql( limpa )
	;

	Usuarios_Padrão =	;	Seleciona os clientes do iris para inserir os usuários padrões
		(
		SELECT DISTINCT [Cliente]
			,			[idUnico]
			,			'Operador ' + SUBSTRING([Setor]	, 4, 1)
		FROM [IrisSQL].[dbo].[Clientes]
		WHERE [Cliente] BETWEEN 10002 and 10999
		)
		Clientes := sql( Usuarios_Padrão )
		GuiControl, , _a,	Atualizando Padrão | Restantes:
		Loop,%	Clientes.Count()-1	{	;	Insere os usuários padrão
			GuiControl, , _e,%	( Clientes.Count()-1 ) - A_index
			cliente	:= Clientes[A_index+1, 1]
			id_unico:= Clientes[A_index+1, 2]
			operador:= Clientes[A_Index+1, 3]
			; OutputDebug % cliente "`t" id_unico
			insere_padrão =
				(
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
						(	'%cliente%',	'000',	'001',	'[ %operador% ]'				,	'Agente de Monitoramento'	,	'1',	'%id_unico%',	'',	''	),
						(	'%cliente%',	'000',	'002',	'[ Facilitador ]'				,	'Facilitador'				,	'1',	'%id_unico%',	'',	''	),
						(	'%cliente%',	'000',	'006',	'[ Manutenção ]'				,	'Assist. Infraestrutura'	,	'1',	'%id_unico%',	'',	''	),
						(	'%cliente%',	'000',	'000',	'[ Programação Automática ]'	,	'Sistema Iris'				,	'1',	'%id_unico%',	'',	''	)
				)
			sql( insere_padrão )
		}
	;

	com_partilha =
		(
		SELECT 
				[IdUnico]
			,	[cliente]
			,	[ContaMaster]
		FROM
			[IrisSQL].[dbo].[Clientes]
		WHERE
			[Partilha] = 1
		)
	partilha := sql( com_partilha )

	; OutputDebug % "Senhas id's padrões=`t" vw.Count() "`nClientes com Partilha=`t" partilha.Count()-1
	; GuiControl, , _a,	Atualizando Usuários | Restantes:

	; for i in vw
		; saida .= vw[i].cliente "`n"
		; MsgBox % vw.Count() "`n" Clipboard := saida
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
		id_iris	:= vw[i].id
		tel1	:= vw[i].fone
		tel2	:= vw[i].cel
			if ( StrLen( tel1 ) = 0 )	{	;	Verifica telefones duplicados
				tel1 := tel2
				tel2 =
			}
			if ( SubStr( tel1, -7 ) = SubStr( tel2, -7 ) )
				tel2 =
		;

		if ( StrLen( nome ) = 0 )	{	;	cria dictionary com os colaboradores demitidos para enviar email posteriormente
			remover.Push({	user_id		:	user_id
						,	local		:	vw[i].unidade
						,	matricula	:	vw[i].matricula
						,	cliente		:	vw[i].cliente	})
			Continue
		}

		sql_update =
			(
			IF EXISTS(
				SELECT [Nome_Usuario]
				FROM
					[IrisSQL].[dbo].[Usuarios]
					WHERE
						[codigo_usuario]='%user_id%' and idcliente='%id_iris%') 
				Begin
					UPDATE [IrisSQL].[dbo].[Usuarios]
					SET
						[Nome_Usuario]		=	'%nome%'
						,[Cargo]			=	'%cargo%'
						,[IdCliente]		=	'%id_iris%'
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
					(	'%cliente%'	,'000'		,'%user_id%'		,'%nome%'		,'%cargo%'	,'1'				,'%id_iris%'	,'%tel1%'	,'%tel2%'	)
			)

		if (cliente < 10002
		||	cliente > 10999 )
			MsgBox % Clipboard:=sql_update
		sql( sql_update )

		; OutputDebug % "Inserindo informações:`nIndex = " i "`n`tid_iris= " id_iris "`n`tcliente= " cliente "`n`tnome= " nome "`n`toperador= " operador "`n`tid_vw= " id_vw
		old_client	:= cliente
		; GuiControl, , _e,%	restantes := ( vw.Count() + partilha.Count()-1 ) - i
	}

	for i in partilha
	{
		nr_usuarios := Array.Indict( vw, partilha[i+1, 3], "Cliente", 1 )
		Loop,%	nr_usuarios.Count()	{
			cliente	:= partilha[i+1, 2]
			user_id := StrLen(	vw[].user ) = 1
							?	"00" vw[ nr_usuarios[A_Index] ].user
							:	StrLen( vw[ nr_usuarios[A_Index] ].user ) = 2
								?	"0" vw[ nr_usuarios[A_Index] ].user
								:	vw[ nr_usuarios[A_Index] ].user
			nome	:= String.Name( vw[ nr_usuarios[A_Index] ].nome )
			cargo	:= String.Cargo( vw[ nr_usuarios[A_Index] ].cargo )
			id_iris	:= partilha[i+1, 1]
			tel1	:= vw[ nr_usuarios[A_Index] ].fone
			tel2	:= vw[ nr_usuarios[A_Index] ].cel

			if ( StrLen( tel1 ) = 0 )	{	;	Verifica telefones duplicados
				tel1 := tel2
				tel2 =
			}

			; OutputDebug % "Inserindo informações:`nIndex = " i "`n`tid_iris= " id_iris "`n`tcliente= " cliente "`n`tnome= " nome "`n`toperador= " operador "`n`tid_vw= " id_vw
			insere_usuarios =
				(
				IF EXISTS(
				SELECT [Nome_Usuario]
				FROM
					[IrisSQL].[dbo].[Usuarios]
					WHERE
						[codigo_usuario]= '%user_id%' AND
						[idcliente]		= '%id_iris%') 
					Begin
						UPDATE [IrisSQL].[dbo].[Usuarios]
						SET
							[Nome_Usuario]		=	'%nome%'
							,[Cargo]			=	'%cargo%'
							,[IdCliente]		=	'%id_iris%'
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
						(	'%cliente%'	,'000'		,'%user_id%'		,'%nome%'		,'%cargo%'	,'1'				,'%id_iris%'	,'%tel1%'	,'%tel2%'	)
				)
				sql_le =
			sql( insere_usuarios )
			if ( StrLen( sql_le ) > 0 )
				MsgBox % sql_le "`n" Clipboard := sql_lq
		; GuiControl, , _e,%	restantes - i
		}
	}

	; GuiControl, , _a,	Atualizar usuarios do Iris
	; GuiControl, enable, _e
	; GuiControl, , _e,	Encerrar
	; GuiControl, enable, _a

	;	notificar por e-mail os usuários inexistentes
		if ( remover.Count() > 0 )	{
			Loop % remover.count()	;	Dict com os usuarios demitidos
				usuarios_remover .= remover[A_Index].local "`n`tMatrícula:`t  " remover[A_Index].matricula "`n`tID da Senha:`t" remover[A_Index].user_id "`n`n"
			mail.new(	"monitoramento@cotrijal.com.br"
					,	"Atualização de usuários do Iris"
					,	"Os colaboradores abaixo possuem senha e não foram encontrados no cadastro de colaboradores da cotrijal:`n" usuarios_remover
					,	"monitoramento@cotrijal.com.br"	)
		}
	update =
		(
		UPDATE
			[IrisSQL].[dbo].[Usuarios]
		SET
			Cliente = b.[Cliente]
		FROM
			[IrisSQL].[dbo].[Usuarios]  a
			INNER JOIN [IrisSQL].[dbo].[Clientes]  b
			ON a.[IdCliente] = b.[IdUnico]
		WHERE
			b.[IdUnico] = a.[IdCliente]
		)
		sql( update )
return

GuiClose:
	ExitApp
;