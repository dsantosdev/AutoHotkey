File_Version=0.1.1
Save_To_Sql=1
Keep_Versions=2
;@Ahk2Exe-SetMainIcon C:\AHK\icones\fun\mag.ico

;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

;	Configuração
	#NoTrayIcon
	#SingleInstance Force
	SetBatchLines, -1
	CoordMode, ToolTip, Screen
;

;	Arrays
	funcionarios	:= []
;

;	Busca contatos no oracle
	contatos_oracle =
		(
		SELECT
			f.nm_razao_social,
			f.numcad,
			TRANSLATE(f.dn_cargo,'ÁáÀàÂâÃãÄäÅåÇçÐÉéÈèÊêËëÍíÌìIiÎîIiÏïIiIiIiÑñÓóÒòÔôÖöÕõØøÚúÙùÛûÜüÝýŸÿŽž','AaAaAaAaAaAaCcDEeEeEeEeIiIiIiIiIiIiIiIiIiNnOoOoOoOoOoOoUuUuUuUuYyYyZz'),
			f.email_com,
			f.fone,
			f.celular,
			f.ramal,
			f.sexo,
			replace(replace(replace(l.nm_fantasia, 'COTRIJAL - '), 'STO', 'SANTO'), 'NAO-ME-TOQUE', 'NMT'),
			TRANSLATE(f.dn_setor,'ÁáÀàÂâÃãÄäÅåÇçÐÉéÈèÊêËëÍíÌìIiÎîIiÏïIiIiIiÑñÓóÒòÔôÖöÕõØøÚúÙùÛûÜüÝýŸÿŽž','AaAaAaAaAaAaCcDEeEeEeEeIiIiIiIiIiIiIiIiIiNnOoOoOoOoOoOoUuUuUuUuYyYyZz'),
			TRANSLATE(f.dn_local,'ÁáÀàÂâÃãÄäÅåÇçÐÉéÈèÊêËëÍíÌìIiÎîIiÏïIiIiIiÑñÓóÒòÔôÖöÕõØøÚúÙùÛûÜüÝýŸÿŽž','AaAaAaAaAaAaCcDEeEeEeEeIiIiIiIiIiIiIiIiIiNnOoOoOoOoOoOoUuUuUuUuYyYyZz'),
			TRANSLATE((SELECT dessit from senior.r010sit where codsit = f.situacao),'ÁáÀàÂâÃãÄäÅåÇçÐÉéÈèÊêËëÍíÌìIiÎîIiÏïIiIiIiÑñÓóÒòÔôÖöÕõØøÚúÙùÛûÜüÝýŸÿŽž','AaAaAaAaAaAaCcDEeEeEeEeIiIiIiIiIiIiIiIiIiNnOoOoOoOoOoOoUuUuUuUuYyYyZz'),
			f.situacao,
			f.cd_estab,
			f.cd_entreposto,
			f.cd_unidade,
			f.dt_admissao_colaborador,
			f.cd_local
		FROM
			cad_funcionarios	f
		RIGHT OUTER JOIN
			cadest	l ON l.cd_estabel = f.cd_estab
		WHERE
			l.cd_emp = f.CD_EMP AND f.SITUACAO NOT IN (7,22,23,33)
		ORDER BY
			2
		)
		contatos_oracle	:=	sql( contatos_oracle , 2 )
		OutputDebug % contatos_oracle.Count()-1 " contatos encontrados no oracle"
		if ( strlen( sql_le ) > 0 )			;	Se der erro na consulta, retorna sem atualizar e sem gerar erro
			Return							;	criar sistema para notificar o módulo principal do erro
;

;	Prepara contatos e atualiza o banco do monitoramento
	Loop,%	contatos_oracle.Count()-1	{	;	Loop de atualização de contatos
		; OutputDebug % aaaaa ; apenas para contagem
		if ( show_tooltip = "1" )
			ToolTip		% "Contatos restantes: " ( contatos_oracle.Count()-1 ) - A_Index "`nColaborador: " contatos_oracle[A_Index+1,1] "`nMatrícula: " contatos_oracle[A_Index+1,2], 50, 50
		nome			:=	String.Remove_accents( Format( "{:T}" , contatos_oracle[ A_Index+1 , 1 ] ) )
		mat				:=	contatos_oracle[ A_Index+1 , 2 ]
		cargo			:=	String.Remove_accents( Format( "{:T}" , contatos_oracle[ A_Index+1 , 3 ] ) )
		responsavel		:=	99
			if(  InStr(cargo, "coordenador") )
			&&( !InStr(cargo, "trainee" ) )
				If		InStr(	cargo, "Administrativo" )
					responsavel	:=	2
				Else If InStr(	cargo, "Operacional" )
					responsavel	:=	5
				Else If InStr(	cargo, "Loja" )
					If		InStr( cargo, "Facilitador" )
						responsavel = 99
					Else If	InStr( cargo, "Comercial" )
						responsavel = 99
					Else
						responsavel	:=	3
				Else If InStr(	cargo, "Supermercado" )
					If		InStr( cargo, "Facilitador" )
						responsavel = 99
					Else If	InStr( cargo, "Comercial" )
						responsavel = 99
					Else
					responsavel	:=	4
			If InStr(cargo , "Gerente De Unidade De Negocios" )
			|| InStr(cargo , "Gerente De Lojas" )
			|| InStr(cargo , "Gerente De Supermercados" )
			|| InStr(cargo , "Gerente Da Expodireto" )
			|| InStr(cargo , "Gerente De Fabrica De Racoes" )
				responsavel	:=	1
		mail			:=	contatos_oracle[ A_Index+1 , 4 ]
		tel1			:=	contatos_oracle[ A_Index+1 , 5 ]
		tel2			:=	contatos_oracle[ A_Index+1 , 6 ]
		ramal			:=	StrLen( contatos_oracle[ A_Index+1 , 7 ] ) < 3 ? "" : contatos_oracle[ A_Index+1 , 7 ]
		sexo			:=	contatos_oracle[ A_Index+1 , 8 ]
		ccus			:=	String.Remove_accents( Format( "{:T}" , contatos_oracle[ A_Index+1 , 9 ] ) )
		setor			:=	String.Remove_accents( Format( "{:T}" , contatos_oracle[ A_Index+1 , 10 ] ) )
		local			:=	String.Remove_accents( Format( "{:T}" , contatos_oracle[ A_Index+1 , 11 ] ) )
		sit				:=	String.Remove_accents( contatos_oracle[ A_Index+1 , 12 ] )
		num_sit			:=	contatos_oracle[ A_Index+1 , 13 ]
		cdestab			:=	Round( contatos_oracle[ A_Index+1 , 14 ] )
		cdentreposto	:=	Round( contatos_oracle[ A_Index+1 , 15 ] )
		cdunidade		:=	contatos_oracle[ A_Index+1 , 16 ]
		admissao		:=	SubStr( contatos_oracle[ A_Index+1 , 17 ] , 7 , 4 )
						.	"/" SubStr( contatos_oracle[ A_Index+1 , 17 ] , 4 , 2 )
						.	"/" SubStr( contatos_oracle[ A_Index+1 , 17 ] , 1 , 2 )
		id_local		:=	contatos_oracle[ A_Index+1 , 18 ]
		Funcionarios.push( mat )
		atualiza_dados =					;	Usado na atualização do _colaboradores	-	19/06/2021 - admissao
			(
			IF EXISTS( SELECT [matricula] FROM [ASM].[dbo].[_colaboradores] WHERE [matricula] = '%mat%' )
				UPDATE [ASM].[dbo].[_colaboradores]
					SET
						[nome]			= LTRIM( RTRIM( '%nome%' ) ),
						[cargo]			= '%cargo%',
						[email]			= '%mail%',
						[telefone1]		= '%tel1%',
						[telefone2]		= '%tel2%',
						[ramal]			= '%ramal%',
						[sexo]			= '%sexo%',
						[c_custo]		= '%ccus%',
						[setor]			= '%setor%',
						[local]			= '%local%',
						[situacao]		= '%sit%',
						[cd_estab]		= '%cdestab%',
						[cd_entreposto]	= '%cdentreposto%',
						[cd_unidade]	= '%cdunidade%',
						[admissao]		= '%admissao%',
						[responsavel]	= '%responsavel%',
						[id_local]		= '%id_local%'
					WHERE
						[matricula]		= '%mat%'
			ELSE
				INSERT INTO [ASM].[dbo].[_colaboradores]
					([nome]
					,[matricula]
					,[cargo]
					,[email]
					,[telefone1]
					,[telefone2]
					,[ramal]
					,[sexo]
					,[c_custo]
					,[setor]
					,[local]
					,[situacao]
					,[cd_estab]
					,[cd_entreposto]
					,[cd_unidade]
					,[responsavel]
					,[admissao]
					,[id_local]			)
				VALUES
					(LTRIM(RTRIM('%nome%'))
					,'%mat%'
					,'%cargo%'
					,'%mail%'
					,'%tel1%'
					,'%tel2%'
					,'%ramal%'
					,'%sexo%'
					,'%ccus%'
					,'%setor%'
					,'%local%'
					,'%sit%'
					,'%cdestab%'
					,'%cdentreposto%'
					,'%cdunidade%'
					,'%responsavel%'
					,'%admissao%'
					,'%id_local%'		)
			)

		atualiza_dados := sql( atualiza_dados , 3 )
		if InStr( cargo, "agente de monitoramento" ) {
			OutputDebug % "Atualizando usuário ad monitoramento`n`t" nome
			Run,	C:\Dieisson\Motion Detection\operadores_update_ad_user.%ext% "%nome%"
		}

	}
	
;

;	Remove demitidos
	ficam =
	for	i,	v	in	funcionarios
		if ( A_Index = 1 )
			ficam := v
		else
			ficam .= "," v
	limpa_demitidos =
		(
			DELETE FROM
				[ASM].[dbo].[_colaboradores]
			WHERE
				[matricula] NOT IN ( %ficam% )
		)
		sql( limpa_demitidos , 3 )
	ToolTip
	ExitApp
;