/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=\\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\mdage.exe
Created_Date=1
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Version=0.0.0.3
Inc_File_Version=1
Legal_Copyright=WTFL
Product_Name=mdage
Product_Version=1.1.33.2
Set_AHK_Version=1
[ICONS]
Icon_1=C:\Dih\zIco\compiler.ico

* * * Compile_AHK SETTINGS END * * *
*/

;@Ahk2Exe-SetMainIcon C:\Dih\zIco\2agenda.ico
; #Include ..\class\classes.ahk
	#Include ..\class\sql.ahk
	; #Include ..\class\array.ahk
	; #Include ..\class\safedata.ahk
	#Include ..\class\gui.ahk
	; #Include ..\class\windows.ahk
	; #Include ..\class\string.ahk
	#Include ..\class\functions.ahk
;

; #NoTrayIcon
	maquina := SubStr( A_IPAddress1 , -2 )	= 162
				?	1
				:	SubStr( A_IPAddress1 , -2 )	= 166
					?	2
					:	SubStr( A_IPAddress1 , -2 )	= 169
						?	3
						:	SubStr( A_IPAddress1 , -2 )	= 176
							?	4
							:	SubStr( A_IPAddress1 , -2 )	= 179
								?	5
								:	SubStr( A_IPAddress1 , -2 )	= 184
									?	6
									:	""

	SetTimer, agendados, -1000
return

agendados:
	FormatTime, agora, A_Now, ddMMyyyHHmm
	restart := SubStr( agora , 9 , 4 )
	if (restart = "1900"
	||	restart = "0700" )
		Reload
	FormatTime, dem, A_Now, ddMMyyy
	getagenda =
		(
		SELECT
			 [id_aviso]
			,[data_alerta]
		FROM
			[ASM].[dbo].[_agenda_alertas]
		WHERE
			[visualizado] IS NULL
		ORDER BY
			[data_alerta]
		ASC
		)
		agenda	:=	sql( getagenda , 3 )
		agenda.Count()-1 "`n" sql_le
	Loop, % agenda.Count()-1	{
		id_aviso:= agenda[ A_Index+1 , 1 ]
		data	:= RegExReplace( agenda[ A_Index+1 , 2 ] , "\D" )
		compara	:= A_DD A_MM
		inicio	:= A_Hour A_Min
		fim		:= A_Hour A_Min+10
		if ( SubStr( data , 1 , 4 ) != compara )	;	Se a data do agendamento não for a mesma do dia, passa para o próximo
			continue
		if (SubStr( data , 9 , 4 ) > inicio
		&&	SubStr( data , 9 , 4 ) < fim )	{
			ano		:= SubStr( data , 5 , 4 )
			mes 	:= SubStr( data , 3 , 2 )
			dia 	:= SubStr( data , 1 , 2 )
			hora	:= SubStr( data , 9 , 2 )
			min		:= SubStr( data , 11 , 2 )
			op		=
				(
				SELECT
					 a.[operador]
					,a.[mensagem]
					,a.[inserido]
					,c.[data_alerta]
					,b.[Nome]
					,a.[pkid]
				FROM
					[ASM].[ASM].[dbo].[_Agenda] a
				LEFT JOIN
					[IrisSQL].[dbo].[Clientes] b on a.[Id_Cliente]=b.[IdUnico]
				LEFT JOIN
					[ASM].[ASM].[dbo].[_agenda_alertas] c on a.[pkid] = c.[id_aviso]
				WHERE
					a.[pkid] = '%id_aviso%'
				AND	( DATEPART(yy, c.[data_alerta]) = %ano%
				AND	DATEPART(mm, c.[data_alerta]) = %mes%
				AND	DATEPART(dd, c.[data_alerta]) = %dia%
				AND	DATEPART(hh, c.[data_alerta]) = %hora%
				AND	DATEPART(mi, c.[data_alerta]) = %min% )
				)
				op := sql( op )
			operador	:= op[2,1]
			_texto	:= op[2,2]
			qnd		:= op[2,3]
			qnda		:= op[2,4]
			cliente	:= op[2,5]
			pkid		:= op[2,6]
			if (operador != 0
			&&	operador != maquina )
				return
			;	easteregg
				Random, easteregg, 1, 100
				If ( easteregg < 99 )
					som = car
				Else if (  easteregg <= 3 )
					som = yoda
				Else
					som = fart
			;
			SoundPlay, \\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\%som%.wav
				Gui.Font( "s10" , "bold" )
			Gui, Add, GroupBox, x10 y50 w455 h65 +Center, % cliente
				Gui.Font()
			Gui, Add, Text, x20 yp+20	, Adicionado em:
			Gui, Add, Text, xp+320 yp , Lembrar Evento em:
			Gui, Add, Text, x20 yp+20 , % qnd
			Gui, Add, Text, xp+320 yp , % qnda
				Gui.Font( "s10" , "underline" , "Bold" , "cWhite" )
			Gui, Add, Text, x12 y125 w453 Center, % _texto
				Gui.Font()
			Gui, Add, Button, x10 y10 w455 vas h30 gfinaliza_agendamento , Confirmar visualização
				Gui, +AlwaysOnTop
				Gui.Cores()
			visto :=  datetime( 1 )
			Gui, Show,  , Evento Agendado
			WinWaitClose, Evento Agendado
		}
		else
			Continue
	}
	SetTimer, agendados, -30000
return

GuiClose:
	finaliza_agendamento:
	finalizado := datetime( 1 )
	define_visualizado =
		(
		UPDATE
			[ASM].[dbo].[_agenda_alertas]
		SET
			 [visualizado] = '1'
			,[data_visualizado] = GetDate()
		WHERE
			[id_aviso] = '%pkid%'
		)
		sql( define_visualizado , 3 )
	user =
		(
		SELECT TOP (1)
			[LOG~USUARIO]
		FROM
			[BdIrisLog].[dbo].[SYS~Log]
		WHERE
			[LOG~DADOS] LIKE 'Login no Painel`%'
		AND [LOG~ESTACAO] = '%A_ComputerName%'
		ORDER BY
			1
		DESC
		)
		us := sql( user )
		usuario := us[2,1]
	if ( StrLen( usuario ) = 0 )
		usuario := A_IPAddress1
	ins =
		(
		INSERT INTO
			[Sistema_Monitoramento].[dbo].[agenda]
				(	[mensagem]
				,	[visualizado]
				,	[nome]
				,	[setor]
				,	[atendente]
				,	[finalizado]	)
			VALUES
				(	'%_texto%'
				,	'%visto%'
				,	'%cliente%'
				,	'%maquina%'
				,	'%usuario%'
				,	'%finalizado%'	)
		)
		sql( ins , 3 )
	limpa_passados =
		(
		UPDATE
			[ASM].[dbo].[_agenda_alertas]
		SET
			 [visualizado] = '1'
			,[data_visualizado] = GetDate()
		WHERE
			[data_alerta] < GetDate()
			AND [visualizado] IS NULL
		)
		sql( limpa_passados , 3 )
	Gui, Destroy
	Goto, agendados
return