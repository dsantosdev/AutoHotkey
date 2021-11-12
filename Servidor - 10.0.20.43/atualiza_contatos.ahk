﻿/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\users\dsantos\desktop\executáveis\atualiza_contatos.exe
Created_Date=1
Run_After="C:\Users\dsantos\Desktop\Executáveis\AHK2BD.exe "atualiza_contatos" "0.0.0.14" """
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Version=0.0.0.14
Inc_File_Version=1
Product_Name=atualiza_contatos
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\Dih\zIco\fun\low.ico

* * * Compile_AHK SETTINGS END * * *
*/

;@Ahk2Exe-SetMainIcon C:\Dih\zIco\fun\low.ico

;	Includes
	;#Include ..\class\array.ahk
	#Include ..\class\base64.ahk
	;#Include ..\class\convert.ahk
	;#Include ..\class\cor.ahk
	;#Include ..\class\dguard.ahk
	;#Include ..\class\functions.ahk
	;#Include ..\class\gui.ahk
	;#Include ..\class\mail.ahk
	;#Include ..\class\safedata.ahk
	#Include ..\class\sql.ahk
	#Include ..\class\string.ahk
	;#Include ..\class\windows.ahk
;

;	Variáveis
	show_tooltip	:=	A_Args[1]
	update_server	:=	A_Args[2]
	if ( update_server = 1 )
		Goto, update
	if ( A_UserName = "dsantos" )
		show_tooltip = 1
;

;	Configuração
	CoordMode, ToolTip, Screen
	#NoTrayIcon
;

;	Arrays
	funcionarios := []
;

;	Busca contatos no oracle
	contatos_oracle =
		(
		SELECT
			f.nm_razao_social,
			f.numcad,
			f.dn_cargo,
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
		Return								;	criar sistema para notificar o módulo principal do erro
;


;	Prepara contatos e atualiza o banco do monitoramento
	Loop,%	contatos_oracle.Count()-1	{	;	Loop de atualização de contatos
		if ( show_tooltip = "1" )
			ToolTip		% "Contatos restantes: " ( contatos_oracle.Count()-1 ) - A_Index "`nColaborador: " contatos_oracle[A_Index+1,1] "`nMatrícula: " contatos_oracle[A_Index+1,2], 50, 50
		nome			:=	String.Remove_accents( Format( "{:T}" , contatos_oracle[ A_Index+1 , 1 ] ) )
		mat				:=	contatos_oracle[ A_Index+1 , 2 ]
		cargo			:=	String.Remove_accents( Format( "{:T}" , contatos_oracle[ A_Index+1 , 3 ] ) )
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
					,'99'
					,'%admissao%'
					,'%id_local%'		)
			)
			; Clipboard:= atualiza_dados
			; MsgBox
		atualiza_dados := sql( atualiza_dados , 3 )
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

;	Update
	update:
		s =
			(
			SELECT	TOP (1)
					[Name]
					,[Bin]
					,[Version]
					,[Obs]
			FROM
				[ASM].[dbo].[Softwares]
			WHERE
				[Name] = 'servidor'
			AND
				[Obs] = ''
			ORDER BY
				3
			DESC
			)
			bins := sql( s, 3 )
		FileGetVersion, exe_version , C:\Dieisson\Motion Detection\servidor.exe
		if ( exe_version != bins[ 2 , 3 ] )
			FileDelete, C:\Dieisson\Motion Detection\servidor.exe
		if (FileExist( "C:\Dieisson\Motion Detection\atualiza_contatos.exe") = ""				;	Garante a existência do executável
		||	exe_version != bins[ 2 , 3 ] ) 	
			Base64.FileDec( bins[2, 2] , "C:\Dieisson\Motion Detection\" bins[ 2 , 1 ] ".exe" )	;	transforma o arquivo bas64 em executável
		Loop
			If ( FileExist( "C:\Dieisson\Motion Detection\" bins[ 2 , 1 ] ".exe" ) != "" )
				Break
		Run, C:\Dieisson\Motion Detection\servidor.exe "1"
	ExitApp
;