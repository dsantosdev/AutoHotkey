File_Version=0.0.3
Save_To_Sql=1
;@Ahk2Exe-SetMainIcon C:\AHK\icones\mail.ico

;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\auth.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cameras.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\date.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\file.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\folder.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

/*	Bancos de Dados utilizados
	[ASM].[dbo].[_relatorios_individuais]
	[ASM].[dbo].[_agentes_de_monitoramento]
	[ASM].[dbo].[_colaboradores]
*/

;	Configurações
	; #NoTrayIcon
	#SingleInstance, Force

	show_tooltip	:=	A_Args[1]	;	recebe o argumento 1 para exibir
		if ( A_UserName = "dsantos" )
			show_tooltip = 1
		CoordMode, ToolTip, Screen

	if A_IsCompiled
		ext	= exe
	Else
		ext = ahk

;

;	Code
	operadores	:=	{}
		s	=
			(
				SELECT
					 a.[login_ad]
					,a.[turno]
					,b.[nome]
				FROM
					[ASM].[dbo].[_agentes_de_monitoramento] a
				LEFT JOIN
					[ASM].[dbo].[_colaboradores] b
				ON
					a.[matricula] = b.[matricula]	
				WHERE
					[turno] < 2
			)
		s	:=	sql( s ,3 )
		Loop,%	s.Count()-1 {
			if( s[A_index+1, 2] != Mod( A_YDay, 2 ) )
			; if( s[A_index+1, 2] = Mod( A_YDay, 2 ) )	;	DEBUG do outro dia
				operadores.Push({	user_ad		:	s[A_Index+1, 1]
							,		user_name	:	s[A_Index+1, 3] })
		}

		OutputDebug % "Operadores preparados"

		quebra_linha	:=	"`n_______________________________________________________________________`n`n`n"

		select_reports	=
			(
				SELECT
					[nome],
					[data],
					[relatorio],
					[user_ad]
				FROM
					[ASM].[dbo].[_relatorios_individuais]
				WHERE	--	Dia de trabalho anterior do turno atual
					(	DATEPART( dayofyear, [data] ) = DATEPART( dayofyear, GETDATE()-2 )
					AND	(	DATEPART(hour,[data]) >= 8										--	Turno do dia ← ↓
						AND	DATEPART(hour,[data]) <= 19	)	)
				OR		--	Noite de trabalho anterior do turno atual
					(	DATEPART( dayofyear, [data] ) = DATEPART( dayofyear, GETDATE()-3 )
					AND	(	DATEPART(hour,[data]) >= 20										--	Turno da noite ← ↓
						OR	DATEPART(hour,[data]) <= 7	)	)
				AND		--	Relatório não está vazio
					[relatorio] IS NOT NULL
				ORDER BY
					[data]
				DESC
			)
		relatorios	:=	sql( select_reports,3 )
		Loop,%	relatorios.Count()-1	{	;	lista de relatórios para o Alberto
			nome		:= "** " relatorios[A_Index+1, 1] " **" 
			user		:= relatorios[A_Index+1, 4]
			relatorio	:= safe_data.Decrypt( relatorios[A_Index+1, 3], relatorios[A_Index+1, 4] )

			operadores.RemoveAt( array.Indict( operadores, user, "user_ad" ) )	;	remove da lista dos que não fizeram relatório

			if A_Index = 1
				mail_beto	.=	nome "`n`n" relatorio
			Else
				mail_beto	.=	quebra_linha nome "`n`n" relatorio
		}
		Loop,%	operadores.Count()	;	prepara lista de operadores sem relatório
			if A_Index = 1
				sem_relatorio	.=	"`t" operadores[ A_Index ].user_name "`n`t"
			Else
				sem_relatorio	.=	operadores[ A_Index ].user_name "`n`t"
		Sort, sem_relatorio
		sem_relatorio	:=	"Lista de colaboradores do turno de hoje`nque não fizeram relatório Individual no último dia de trabalho:`n`n`t" sem_relatorio
		mail_beto		:=	sem_relatorio quebra_linha "`nRelatórios Individuais do turno de hoje, do dia de trabalho anterior:`n`n`n" mail_beto
		subject			:=	"Relatórios Individuais " SubStr( datetime(), 1, 10)
		OutputDebug % "Relatórios preparados"

		mail.new( "alberto@cotrijal.com.br", subject, mail_beto )
		OutputDebug % "E-mail do Alberto enviado"

		; mail.new( "dsantos@cotrijal.com.br", subject, sem_relatorio )	;	debug
		mail.new( "dsantos@cotrijal.com.br", subject, sem_relatorio,,,"ddiel@cotrijal.com.br","arsilva@cotrijal.com.br" )
		OutputDebug % "E-mail dos tucos enviado"
	ExitApp	


;