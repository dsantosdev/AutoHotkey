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
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
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
	;	oracle - Unidades
		OutputDebug % "Oracle selection"
		select_cadest	=
			(
			SELECT DISTINCT
				INITCAP(REPLACE(
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
					,'ESMERALDA CENTRO', 'ESMERALDA - CENTRO')	) AS UNIDADES,
				abrev,
				cd_entreposto,
				cd_estabel,
				INITCAP( bairro || ', ' || endereco || ' ' || end_numero || ' ' || end_compl )
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

	;	insert unidades - mssql
		OutputDebug % "Loop places"
		Loop,% cadest.Count()-1	{
			nome			:=	cadest[A_Index+1 , 1]
			sigla			:=	cadest[A_Index+1 , 2]
			entreposto		:=	cadest[A_Index+1 , 3]
			estabelecimento	:=	cadest[A_Index+1 , 4]
			endereco		:=	cadest[A_Index+1 , 5]
			insert_cotrijal =
				(
					IF NOT EXISTS (SELECT * FROM [Cotrijal].[dbo].[unidades] WHERE [estabelecimento] = '%estabelecimento%')
						INSERT INTO
							[Cotrijal].[dbo].[unidades]
								([nome]
								,[sigla]
								,[entreposto]
								,[estabelecimento]
								,[endereco])
							VALUES
								('%nome%'
								,'%sigla%'
								,'%entreposto%'
								,'%estabelecimento%'
								,'%endereco%')
					ELSE
						UPDATE
							[Cotrijal].[dbo].[unidades]
						SET
							 [nome]				=	'%nome%'
							,[sigla]			=	'%sigla%'
							,[entreposto]		=	'%entreposto%'
							,[estabelecimento]	=	'%estabelecimento%'
							,[endereco]			=	'%endereco%'
						WHERE
							[estabelecimento]	=	'%estabelecimento%'
				)
			sql( insert_cotrijal , 3 )
		}

	;

	;	oracle - id's	01.01.01....
		OutputDebug % "Select Locais"
		select_locais =
			(
			SELECT DISTINCT
				cd_local,
				cd_estab,
  				cd_entreposto
			FROM
				cad_funcionarios
			WHERE
				cd_estab not in (1)
				AND cd_local not in ('01.01.90'
									,'01.01.95')
			ORDER BY
				2
			)
		locais := sql( select_locais , 2 )

		; 	id_locais.Push({local :	"01.01.10"	;	Sede - Fábrica de Ração
		; 				,	estab : "29"	})
		; 	id_locais.Push({local :	"01.01.40"	;	Sede - Administrativo Financeiro
		; 				,	estab : "1"	})
		OutputDebug % "Loop id_locais"
		Loop,% locais.Count() {
			id_local	:=	locais[A_Index+1 , 1]
			id_estab	:=	Floor( locais[A_Index+1 , 2] )
			id_entre	:=	Floor( locais[A_Index+1 , 3] )
			update	=
				(
				UPDATE
					[Cotrijal].[dbo].[unidades]
				SET
					[id_local]			= '%id_local%'
				WHERE
					[estabelecimento]	= '%id_estab%'
				AND
					[entreposto]		= '%id_entre%'

				)
			sql( update , 3 )
		}
		
		OutputDebug % "Done"
	;
;
