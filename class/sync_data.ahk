if	inc_sync_data
	Return

; teste := Sync_Data.alarms()
;	Necessários
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
;
global	inc_sync_data = 1

Class	Sync_Data	{

	alarms()	{
		;	Busca os colaboradores que possuem senha de alarme e tem cadastro com a matrícula no nome.
			s=
				(
					SELECT
						DISTINCT  '1' + e.valor																	AS Cliente_Iris		--	1
						,d.[IdUnico]																			AS ID_Central		--	2
						,u.[ID_USUARIO]																			AS Index_Central	--	3
						,(SELECT [NOME]			FROM [ASM].[dbo].[_colaboradores] WHERE [matricula] = u.[nome])	AS Nome				--	4
						,(SELECT [CARGO]		FROM [ASM].[dbo].[_colaboradores] WHERE [matricula] = u.[nome])	AS Cargo			--	5
						,(SELECT [telefone1]	FROM [ASM].[dbo].[_colaboradores] WHERE [matricula] = u.[nome])	AS Fone1			--	6
						,(SELECT [telefone2]	FROM [ASM].[dbo].[_colaboradores] WHERE [matricula] = u.[nome])	AS Fone2			--	7
						,SUBSTRING(u.[CODIGO],1,4)																AS Senha			--	8
						,d.[Nome]																				AS Unidade			--	9
						,u.[Nome]																				AS matricula		--	10 usado para identificar demitido
						,(SELECT [id_local]	FROM [ASM].[dbo].[_colaboradores] WHERE [matricula] = u.[nome])		AS Id_local			--	11 usado para identificar transferido de unidade
					FROM
						[vw_programação].[dbo].[INSTALACAO]	i
					LEFT JOIN
						[vw_programação].[dbo].[USUARIOS]	u on i.[ID_INSTALACAO]	= u.[ID_INSTALACAO]
					LEFT JOIN
						[vw_programação].[dbo].[PROG_EQTO]	e on i.[ID_INSTALACAO]	= e.[ID_EQTO]
					LEFT JOIN
						[IRIS].[IrisSQL].[dbo].[Clientes]	d on '1' + e.[valor]	= d.[Cliente]
					WHERE
						ISNUMERIC(u.[NOME]) = 1 AND
						e.[id_funcao] BETWEEN '66' AND '73' AND
						e.[valor] NOT IN ('0000','9999') AND
						LEN(e.[VALOR]) = 4
					ORDER BY 2, 4
				)
			data	:=	sql(s , 3)

		;	Insere ou atualiza o IRIS e prepara o array para deletar
			fired	:=	{}
			;	Limpa os usuários do iris
				d	=
					(
						DELETE
							FROM
								[IrisSQL].[dbo].[Usuarios]
							WHERE
								[Codigo_Usuario]
							NOT IN (000,	--	Programação automática
									001,	--	Facilitador
									002,	--	Monitoramento
									006 ) 	--	Manutenção
									--099 )	--	Programação automática
					)
				sql( d )
			;
			Loop,%	data.Count()-1	{
				cliente	:=	data[A_Index+1, 1]
				idc		:=	data[A_Index+1, 2]
				user_id	:=	( StrLen( data[A_Index+1, 3] ) = 1 )
						?	( "00" data[ A_Index+1, 3] )
						: ( ( StrLen( data[A_Index+1, 3] ) = 2 )
						?	( "0" data[A_Index+1, 3] )
						:	( data[A_Index+1, 3] ) )
				nome	:=	String.name( data[A_Index+1, 4] )
				cargo	:=	String.cargo( data[A_Index+1, 5] )
				fone1	:=	StrRep( String.Telefone( data[A_Index+1, 6] ), "|", " ", "(0|(" )
				fone2	:=	StrRep( String.Telefone( data[A_Index+1, 7] ), "|", " ", "(0|(" )
				senha	:=	data[A_Index+1, 8]
				mat		:=	data[A_Index+1, 10]
				id_local:=	data[A_Index+1, 11]
				if mat = 999999
					nome = [ Programação Automática ]
				If (!StrLen( nome )
				&&	mat != "999999" )	{	;	Se não encontrar o nome, foi demitido e não é matrícula 999999
					fired.Push({mat	:	mat
							,	uni	:	cliente	})
					Continue
				}
				; Outputdebug % cliente "`n" user_id "`n" idc "`n" nome "`n" cargo "`n" fone1 "`n" fone2 "`n" senha
				insert =
					(
					INSERT INTO
						[IrisSQL].[dbo].[Usuarios]
						(	[Cliente],			-- 1
							[Cargo],			-- 2
							[Fone],				-- 3
							[FCelular],			-- 4
							[TextoReferencia],	-- 5
							[Codigo_Usuario],	-- 6
							[Nome_Usuario],		-- 7
							[PrioridadeLigar],	-- 8
							[IdCliente],		-- 9
							[Cod~lan],			-- 10
							[Particao]	)		-- 11
					VALUES
						(	'%cliente%',		-- 1
							'%cargo%',			-- 2
							'%fone1%',			-- 3
							'%fone2%',			-- 4
							'%senha%',			-- 5
							'%user_id%',		-- 6
							'%nome%',			-- 7
							'1',				-- 8
							'%idc%',			-- 9
							'%id_local%',		-- 10
							'000'	)			-- 11
					)
				sql( insert )
				if sql_le	{
					; MsgBox % sql_le Clipboard := sql_lq
					mail.new( "dsantos@cotrijal.com.br", "Erro SQL no Módulo SYNC_DATA", sql_le "`n`n" sql_lq )
				}
			}
		;	Verifica os atuais do iris com os inseridos, para remover os que foram demitidos
			if	!fired.Count()
				Return
			Loop,% fired.Count()
				if	A_Index = 1
					fireds .= "`tCentral de Alarme :   " 					SubStr( fired[A_Index].uni, 2 ) "`n`tMatrícula Usuário  :   " fired[A_Index].mat
				Else
					fireds .= "`n____________`n`n`tCentral de Alarme :   "	SubStr( fired[A_Index].uni, 2 ) "`n`tMatrícula Usuário  :   " fired[A_Index].mat

			subject := "Usuários com Senha - Não constam como colaboradores "	SubStr( datetime(), 1, 8 )
			body	:=	"As matrículas abaixo possuem senha de alarme`ne não foram encontradas no cadastro de colaboradores da cotrijal:`n`n" fireds

			; mail.new( "dsantos@cotrijal.com.br", subject, body)
			mail.new( "alberto@cotrijal.com.br", subject, body, , , "ddiel@cotrijal.com.br", "arsilva@cotrijal.com.br", "dsantos@cotrijal.com.br" )
		Return
	}

}