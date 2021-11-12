/*
	* * * Compile_AHK SETTINGS BEGIN * * *
	[AHK2EXE]
		Exe_File=C:\users\dsantos\desktop\executáveis\unidades.exe
		Created_Date=1
	[VERSION]
		Set_Version_Info=1
		Company_Name=Heimdall
		File_Description=
		File_Version=0.0.0.1
		Inc_File_Version=1
		Product_Name=unidades
		Product_Version=1.1.33.2
		Set_AHK_Version=1
	* * * Compile_AHK SETTINGS END * * *
*/

/*	Descrição
	Atualiza o banco de dados Cotrijal.Unidades
*/

;	Includes
	#Include ..\class\array.ahk
	;#Include ..\class\base64.ahk
	;#Include ..\class\convert.ahk
	;#Include ..\class\cor.ahk
	;#Include ..\class\dguard.ahk
	;#Include ..\class\functions.ahk
	;#Include ..\class\gui.ahk
	;#Include ..\class\mail.ahk
	;#Include ..\class\safedata.ahk
	#Include ..\class\sql.ahk
	; #Include ..\class\string.ahk
	;#Include ..\class\windows.ahk
;

;	-Arrays
	id_locais := {}
;

;	-Configurações
	
;

;	-Variáveis
	
;

;	-Login
	
;

;	-Interface
	
;

;	-GuiClose
	
;

;	Code
	;	oracle - id's
		select_locais =
			(
			SELECT DISTINCT
				cd_local,
				cd_estab
			FROM
				cad_funcionarios
			WHERE
				cd_estab not in (1)
				AND cd_local not in ('01.01.90'
									,'01.01.95'
									,'01.01.10')
			ORDER BY
				2
			)
		locais := sql( select_locais , 2 )
		Loop,%	locais.Count()-1
			id_locais.Push({local :	locais[ A_Index+1 , 1 ]
						,	estab : Floor( locais[ A_Index+1 , 2 ] )	})
			id_locais.Push({local :	"01.01.10"	;	Sede - Fábrica de Ração
						,	estab : "29"	})
			id_locais.Push({local :	"01.01.40"	;	Sede - Administrativo Financeiro
						,	estab : "1"	})
	;

	;	oracle - Unidades
		OutputDebug % "Oracle selection"
		select_cadest	=
			(
			SELECT DISTINCT
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(
																REPLACE(
																	REPLACE(
																		REPLACE( nm_fantasia,'COTRIJAL - '
																							, '')
																	,'NAO-ME-TOQUE', 'SEDE')
																,'SALVADOR ', '')
															,'STO ANTONIO PLANALTO - SUPER', 'SANTO ANTONIO DO PLANALTO - SUPER')
														,'IGREJINHA - COQUEIROS DO SUL', 'IGREJINHA')
													,'XADREZ - COQUEIROS DO SUL', 'XADREZ')
												,'- KM 143', '- VELHO')
											,'- KM 274', '')
											--,'- KM 274', '- NOVO')
										,' - BR 285', ' - CD DEFENSIVOS')
									,'TERM.', 'TERMINAL ')
								,'CARAZINHO GLORIA - LOJA', 'CARAZINHO - LOJA')
							,'ESMERALDA ANEXO', 'ESMERALDA - ANEXO')
						,'ASSOC. FUNCIONARIOS', 'SEDE - AFC')
					,'VIVEIRO', 'PASSO FUNDO - VIVEIRO')
				,'ESMERALDA CENTRO', 'ESMERALDA - CENTRO'),
				abrev,
				cd_entreposto,
				cd_estabel,
				bairro || ', ' || endereco || ' ' || end_numero || ' ' || end_compl
			FROM
				cadest
			WHERE
				tipo_estab != 9
			AND
				cd_emp IN (1,3)
			AND
				cd_estabel NOT IN ('48','16','30','45','61')
			ORDER BY
				1
			)
		cadest := sql( select_cadest , 2 )
	;

	;	insert mssql
		OutputDebug % "Loop places"
		Loop,% cadest.Count()-1	{
			if ( A_Index = cadest.Count()-1 )	{
				unidade :=	cadest[A_Index+1 , 1]	= "SEDE"
													? "('SEDE - ADMINISTRATIVO FINANCEIRO'`n,'"
													: cadest[A_Index+1 , 1]	= "DEPOSITO CONSUMO - SEDE"
																			? "('SEDE - CD SUPERMERCADOS'`n,'"
																			: cadest[A_Index+1 , 1]	= "EXPODIRETO SEDE"
																									? "('SEDE - EXPODIRETO'`n,'"
																									: cadest[A_Index+1 , 1]	= "SEDE - ATACADO NMT"
																															? "('SEDE - ATACADO'`n,'"
																															:	cadest[A_Index+1 , 1]	= "CD LOJA - SEDE"
																																						? "('SEDE - CD LOJA'`n,'"
																																						: cadest[A_Index+1 , 1]		= "PASSO FUNDO - LOJA"
																																						&&	cadest[A_Index+1 , 4]	= "102"
																																													? "('PASSO FUNDO - LOJA NOVA'`n,'"
																																													: "('" cadest[A_Index+1 , 1] "'`n,'"
				values	.=	unidade																	
						.	cadest[A_Index+1 , 2] "'`n,'"
						.	cadest[A_Index+1 , 3] "'`n,'"
						.	cadest[A_Index+1 , 4] "'`n,'"
						.	cadest[A_Index+1 , 5] "'`n,"
						.	 "NULL)"
			}
			Else	{
				unidade :=	cadest[A_Index+1 , 1]	= "SEDE"
													? "('SEDE - ADMINISTRATIVO FINANCEIRO'`n,'"
													: cadest[A_Index+1 , 1]	= "DEPOSITO CONSUMO - SEDE"
																			? "('SEDE - CD SUPERMERCADOS'`n,'"
																			: cadest[A_Index+1 , 1]	= "EXPODIRETO SEDE"
																									? "('SEDE - EXPODIRETO'`n,'"
																									: cadest[A_Index+1 , 1]	= "SEDE - ATACADO NMT"
																															? "('SEDE - ATACADO'`n,'"
																															:	cadest[A_Index+1 , 1]	= "CD LOJA - SEDE"
																																						? "('SEDE - CD LOJA'`n,'"
																																						: cadest[A_Index+1 , 1]		= "PASSO FUNDO - LOJA"
																																						&&	cadest[A_Index+1 , 4]	= "102"
																																													? "('PASSO FUNDO - LOJA NOVA'`n,'"
																																													: "('" cadest[A_Index+1 , 1] "'`n,'"
				values	.=	unidade		
						.	cadest[A_Index+1 , 2] "'`n,'"
						.	cadest[A_Index+1 , 3] "'`n,'"
						.	cadest[A_Index+1 , 4] "'`n,'"
						.	cadest[A_Index+1 , 5] "'`n,"
						.	 "NULL),`n"
			}
		}
		insert_cotrijal =
			(
			DELETE FROM [Cotrijal].[dbo].[unidades];
			DBCC CHECKIDENT ('[Cotrijal].[dbo].[unidades]', RESEED, 0);
			INSERT INTO
				[Cotrijal].[dbo].[unidades]
				([nome]
				,[sigla]
				,[id]
				,[id_unico]
				,[endereco]
				,[id_local])
			VALUES
				%values%;
			)
		sql( insert_cotrijal , 3 )
	;

	;	Update locais
		Loop,% id_locais.Count() {
			id_local := id_locais[A_Index].local
			id_estab := id_locais[A_Index].estab
			; if ( id_estab = 29 )
			; 	id_local = 01.01.10
			; else if ( id_estab = 1 )
			; 	id_local = 01.01.40
			update	=
				(
				UPDATE
					[Cotrijal].[dbo].[unidades]
				SET
					[id_local] = '%id_local%'
				WHERE
					[id_unico] = '%id_estab%'
				)
				sql( update , 3 )
		}
	;
;
